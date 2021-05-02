function [totalFlux, SurfaceArea] = evaluateDesign(lattice1, lattice2, mix, thickness,cellSize)
%Provide file paths to nTopCL, nTop file, and output JSON file
%Assuming input and output JSON files as well as .ntop file in the same folder
pathToExe = ['"' 'C:\\Program Files\\nTopology\\nTopology\\ntopcl.exe' '"'];


% FileToRun='11.ntop';
FileToRun = sprintf('%d%d.ntop',lattice1,lattice2);
OutputFile='output.json';

%Provide a input JSON file
InputFile='input.json';
Inputs = jsondecode(fileread(InputFile));

%Modify input variables
Inputs(1).inputs{2,1}.values = thickness;
Inputs(1).inputs{3,1}.values = mix;
Inputs(1).inputs{4,1}.values.x(1) = cellSize;
Inputs(1).inputs{4,1}.values.x(2) = cellSize;
Inputs(1).inputs{4,1}.values.x(3) = cellSize;

%Write JSON file
JsonStr = jsonencode(Inputs);
JsonStr = strrep(JsonStr, ',', sprintf(',\r'));
JsonStr = strrep(JsonStr, '[{', sprintf('[\r{\r'));
JsonStr = strrep(JsonStr, '}]', sprintf('\r}\r]'));
fid = fopen(InputFile, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid, JsonStr, 'char');
fclose(fid);

%Compose a execution command
Arguments=sprintf('%s -j %s -o %s %s', pathToExe,InputFile,OutputFile,FileToRun);
%Run
system(Arguments);


% Parse Outputs
data = readmatrix('flux.csv');
flux = data(:,3:6)';
fluxMag = vecnorm(flux);
totalFlux = sum(fluxMag);

A = importdata('area.txt');
SurfaceArea = A;

writematrix([totalFlux,A],'record.xlsx','WriteMode','append');


% Overwrite values in case next design generation fails
A = 0;
writematrix(A,'area.txt');

flux = 10e-20*rand*ones(50000,6);
writematrix(flux,'flux.csv');
end

