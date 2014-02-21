######################
## diskIO.py
######################
class DiskIO:
	prevReadBytes = 0
	readBytes = 0
	readAvg = 0
	prevWriteBytes = 0
	writeBytes = 0
	writeAvg = 0
	readAvg = 0 
	writeAvg = 0
	count = 0

	def __init__(self):
		print "Starting a new DiskIO Object"

	def addRW(self, rb, wb):
		self.readBytes  = rb - self.prevReadBytes 
		self.writeBytes = wb - self.prevWriteBytes
		if (self.prevReadBytes != 0):
			self.count += 1
			self.readAvg  = (self.readBytes - self.readAvg)/self.count + self.readAvg
			self.writeAvg = (self.writeBytes - self.writeAvg)/self.count + self.writeAvg
		self.prevReadBytes = rb
		self.prevWriteBytes = wb

	def pDiskIO(self):
		print ("DiskIO Cur: ", self.readBytes, self.writeBytes)
		print ("DiskIO Avg: ", self.readAvg, self.writeAvg)
		
