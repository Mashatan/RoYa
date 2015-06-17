import RoYa
import md5
import sha

if (RoYa.ListParamCount()>0) :
	p=RoYa.ListParam(0)
	hash=None;
	if p.lower().find("/md5")>-1 :
		hash= md5.new()
	if p.lower().find("/sha1")>-1 :
		hash= sha.new()	
	if hash != None :
		sum=""
		for count in range(1, RoYa.ListParamCount()):
			sum = sum+' '+RoYa.ListParam(count)
		sum=sum.strip()
		hash.update(sum)
		RoYa.InstantMessage(sum+' ['+hash.hexdigest()+']')
