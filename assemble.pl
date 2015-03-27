#!/usr/bin/env perl

#Usege: assemble.pl input_file

use IO::Handle;

#Opcode hash. Used to lookup an opcode from a mnemonic
%opcodes = 
	(
		'LOAD', 0,
		'SWAP', 1,
		'STORE', 2,
		'STOP', 3,

		'TSG', 4,
		'TSL', 5,
		'TSE', 6,
		'TSI', 7,

		'JMP', 8,
		'JMA', 9,
		#'UNDEFINED', 10,
		#'UNDEFINED', 11,

		'IOW', 12,
		'IOR', 13,
		'IOS', 14,
		'IOC', 15,

		'ADD', 16,
		'SUB', 17,
		'MUL', 18,
		'DIV', 19,

		'SHL', 20,
		'SHR', 21,
		'ROL', 22,
		'ROR', 23,

		'ADDU', 24,
		'SUBU', 25,
		'MULU', 26,
		'DIVU', 27,

		'INC', 28,
		'DEC', 29,
		'DOUBLE', 30,
		'HALF', 31
	);

#This hash is used to check if the instruction requires an argument
%opcodearg = 
	(
		'LOAD', 1,
		'SWAP', 1,
		'STORE', 1,
		'STOP', 0,

		'TSG', 1,
		'TSL', 1,
		'TSE', 1,
		'TSI', 1,

		'JMP', 1,
		'JMA', 1,
		#'UNDEFINED', 0,
		#'UNDEFINED', 0,

		'IOW', 0,
		'IOR', 0,
		'IOS', 0,
		'IOC', 0,

		'ADD', 1,
		'SUB', 1,
		'MUL', 1,
		'DIV', 1,

		'SHL', 1,
		'SHR', 1,
		'ROL', 1,
		'ROR', 1,

		'ADDU', 1,
		'SUBU', 1,
		'MULU', 1,
		'DIVU', 1,

		'INC', 0,
		'DEC', 0,
		'DOUBLE', 0,
		'HALF', 0
	);

#get the number of arguments passed
$numArgs = $#ARGV + 1;

#ensure that there is only one input
if ($numArgs != 1) {
	die "Expected exactly one argument.\n";
}

#get the name of the input
$filename = $ARGV[0];

#Generate the otuput name by replacing the extension (if any) with .bin
$outputName = $filename;
$outputName=~s/\..*^//;
$outputName .= ".bin";

print "Assmebling $filename into $outputName\n";

#Open the input file
my $file;
open($file, "<", $filename)
	or die "Can't open input file '$filename'. $!";

#Array for entire RAM space, initialise to 0
@program = (0,0,0,0,0,0,0,0);

#Number of errors encountered
my $errors = 0;
#Number of code lines seen so far
my $codeLines = 0;
#current line number in file ($. is unreliable here)
my $l = 0;

#Loop through input
for (<$file>){
	#line conuter increment
	$l++;
	#Regex matches lines that are blank or start with //
	if ((/^[ \t]*\/\//) || (/^[ \t]*$/)){
		#ignore these lines, comments or blanks
	}	
	else{
		#All other lines are considered code lines
		$codeLines++;
		#If there have been more than eight so far without error, the program is clearly too long
		if (($codeLines > 8) && ($errors == 0)){
			die "Program is too long. Please reduce program to 8 bytes or less.";
		}
		#Regex matches instruction mnemonic followed by optional spaces and argument
		if (/^[ \t]*([A-Za-z]+)([ \t]*)([0-9]*)[ \t]*$/){
			#upper case the mnemonic
			$mn = uc $1;
			#get the opcode
			$opNum = $opcodes{$mn}, "\n";
			#find out if arguments are required
			$needsArg = $opcodearg{$mn};
			#if they are required
			if ($needsArg){
				#Check if we have an argument
				if (length($3) < 1){
					#If there is no argument, print error message, increment error count
					print "Instruction $1 on line $l: requires $needsArg arguments.\n";
					$errors++;
				}
				else{
					#If we have an argument but there is no space between the mnemonic and the argument
					if (length($2) < 1){
						#print message inc count
						print "Instruction $1 on line $l: expected space between mnemonic and argument.\n";
						$errors++;
					}
					else{
						#if all of that is okay but the address is out of range (0-7)
						if ($3 > 7){
							#then also print an error and increment the count
							print "Instruction $1 on line $l: Address argument must be in range 0 to 7.\n";
							$errors++;
						}
						else{
							#When we reach here we have a valid instruction with argument
							#shift the opcode up and then OR in the argument, store in program line
							$program[$codeLines-1] = ($opNum << 3) | ($3);

						}
					}
				}
			}
			else{
				#Reach here when the instruction requires no argument
				#check for arguemnt
				if (length($3) > 0){
					#If an argument is given for an instruction that requires none, error
					print "Instruction $1 on line $l: Unexpected argument found.\n";
					$errors++;
				}
				else{
					#When we reach here we have a valid instruction with no argument
					#shift the opcode, no argument to or in this time, store in program line
					$program[$codeLines-1] = ($opNum << 3);

				}
			}
		}
		else{
			#If the instruction regex didn't match, it could be a raw number
			if (/^[ \t]*([-+]?\d+)[ \t]*/){
				#Check if raw number is within limits
				if (($1 < -128) || ($1 > 255)){
					print "Raw number on line $l: Raw numbers must be between -128 and +255\n";
					$errors++;
				}
				else{
					#add to the program (no need to worry about signs, truncating will preserve sign anyway)
					$program[$codeLines-1] = int($1);
				}
			}
			else{			
				#no match for line type print error message, inc error count.
				print "Syntax error on line $l: expected instruction nemonic.\n";
				$errors++;
			}
		}
	}
}

#Done with file
close($file);

#function to go from a byte to a bit string
sub byte_to_bits {
	return unpack("B8", pack("C", shift));
}

#Cheeky
if ($errors >= 8){
	print "Wow....\n"
}

#If we have encountered errors so far, die
if ($errors){
	die "Found $errors errors while assembling.\nAborted."
}
else{
	#If we made it this far, we can create the output file
	#open the output
	my $out;
	open ($out, ">", $outputName) or die "Can't open output file $outputName: $!";

	#enable binary file mode
	binmode($out);
	print "Program is:\n";

	#Loop through the assembled code
	for (@program){
		#print the code as raw bit strings on the screen
		print byte_to_bits($_), "\n";
		#write to binary file
		syswrite($out, pack("C", $_), 1) == 1 or die "Can't write output file: $!";
	}
	
	#All done, close output file
	close($out);	
}


