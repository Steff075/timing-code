# This python script takes a data table produced by isis in the form freq,lag,lagerror and produces a .fits and .rsp file of the data which can be used for example in model fitting

import csv, os

Frequencies=[]
Lags=[]
LagErrors=[]
LowFrequencies=[]
HighFrequencies=[]

# Read in data produced from isis into arrays
with open('lagvalues_lo_cts_lc_segs.csv','r') as f:
    reader=csv.reader(f,delimiter=',')
    for Frequency,Lag,LagError in reader:
        Frequencies.append(Frequency)
        Lags.append(Lag)
        LagErrors.append(LagError)

NumberOfFrequencies = len(Frequencies)

# Split the frequencies into bins
LowFrequencies.append(float(float(Frequencies[0])*0.9))
for i in range(0,NumberOfFrequencies-1):
    HighFrequencies.append((float(Frequencies[i]) + float(Frequencies[i+1]))/2)
    if(i!=0):
        LowFrequencies.append(float(HighFrequencies[i-1]))
LowFrequencies.append(float(HighFrequencies[NumberOfFrequencies-2]))

HighFrequencies.append(float(float(Frequencies[NumberOfFrequencies-1])*1.1))

#Store the data in a comma separated format
LowFrequenciesString = " , ".join(str(x) for x in LowFrequencies)
HighFrequenciesString = " , ".join(str(x) for x in HighFrequencies)
LagsString = " , ".join(str(x) for x in Lags)
LagErrorsString = " , ".join(str(x) for x in LagErrors)

# Add the relevant header/ finishing material to the strings
LowFreq = str("freq_low = np.array(["+LowFrequenciesString+"])")
HighFreq = str("freq_high = np.array(["+HighFrequenciesString+"])")
TLag = str("time_lag = np.array(["+LagsString+"])")
TLagErr = str("time_lag_err = np.array(["+LagErrorsString+"])")

# Open a template 'create_spectra.py' file and replace the placeholders (Caps words) with the actual strings you want
f1=open("create_spectra_template.py","r") # Opens a segment analysis template file.
f2=open("create_spectra.py","w") # Opens a local version which will be run.
for line in f1: # For each line in the template file...
    line=line.replace("LOWFREQUENCY",str(LowFreq))
    line=line.replace("HIGHFREQUENCY",str(HighFreq))
    line=line.replace("TIMELAGERROR",str(TLagErr))
    line=line.replace("TIMELAG",str(TLag))
    f2.write(line)
f1.close()
f2.close()

#Call and run create_spectra.py
print ("Running 'create_spectra.py'")
os.system("/homeb/steff075/anaconda3/bin/python create_spectra.py")

print ("Fits and Respnse files completed!")
