From: Andrew Schretter <schrett@math.duke.edu>
Subject: 2.6.8.1 kernel NFS client connectathon failure
Date: Wed, 15 Sep 2004 16:54:29 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200409152054.i8FKsTNV002355@roma.math.duke.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="----=GPMAIL_ATT_0.775036035316649"
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.

------=GPMAIL_ATT_0.775036035316649
Content-Type: text/plain; charset=US-ASCII

The attached code is a blatant rip from the latest connectathon code that
was stripped down to show exactly where it fails on my 2.6.8.1 NFS client.
Note that this code works on the local disk and on a 2.4.22 client (both to
a 2.6.8.1 server and a 2.4.22 server) but fail from a 2.6.8.1 client to
both 2.4.22 and 2.6.8.1 servers.

The problem has something to do with hard links and using rename(2) to
overwrite hard linked files.

Compile stright with gcc and run on a local disk partition and then on a
remote partition.  It creates a directory TEMP, creates a file FOO, links
it to TEMP/BAR, renames TEMP/BAR to FOO, then removes FOO and does an 
ls on FOO and TEMP/BAR. 

On local disk runs, TEMP/BAR still exists (I don't know why though).  On NFS
runs, it does not exists.  This breaks connectathon's test.

Any ideas?

Andrew Schretter
Systems Programmer, Duke University
Dept. of Mathematics (919) 660-2866



------=GPMAIL_ATT_0.775036035316649
Content-Type: text/plain; name="lnk.c"
Content-Transfer-Encoding: base64
Content-Description: lnk.c
Content-Disposition: ATTACHMENT; FILENAME="lnk.c"

I2luY2x1ZGUgPHVuaXN0ZC5oPgojaW5jbHVkZSA8c3RkaW8uaD4KI2luY2x1ZGUgPHN0ZGxpYi5o
PgojaW5jbHVkZSA8c3RyaW5nLmg+CiNpbmNsdWRlIDxmY250bC5oPgojaW5jbHVkZSA8ZXJybm8u
aD4KI2luY2x1ZGUgPHN5cy9zdGF0Lmg+CgojaWZuZGVmIE1BWFBBVEhMRU4KI2RlZmluZSBNQVhQ
QVRITEVOCTEyOAojZW5kaWYKCi8qIG1heGltdW0gbnVtYmVyIG9mIGNoYXJzIGZvciB0aGUgbWVz
c2FnZSBzdHJpbmcgKi8KI2RlZmluZSBTVFJDSEFSUwkxMDAKCm1haW4oaW50IGFjLCBjaGFyICph
dltdKSB7CglpbnQgY291bnQsIGZkLCBzbGVuLCBsZXJyLCBzbGVycjsKCWNoYXIgKmZuOwoJc3Ry
dWN0IHN0YXQgc2I7CiAgICAgICAgY2hhciBzdHJbMjU1XTsKCiAgICAgICAgaWYgKG1rZGlyKCJU
RU1QIiwgMDc1NSkpIHsKICAgICAgICAJcGVycm9yKCJta2RpciBURU1QIik7CiAgICAgICAgCWV4
aXQoMCk7CiAgICAgICAgfQoJZmQgPSBvcGVuKCJGT08iLCBPX1JEV1J8T19DUkVBVCwgMDY2Nik7
CglpZiAoZmQgPCAwKSB7CgkJcGVycm9yKCJjcmVhdCIpOwoJCWV4aXQoMCk7Cgl9CiAgICAgICAg
c3ByaW50ZihzdHIsICIuLi4iKTsKICAgICAgICBzbGVuID0gc3RybGVuKHN0cik7CglpZiAod3Jp
dGUoZmQsIHN0ciwgc2xlbikgIT0gc2xlbikgewoJCXBlcnJvcigid3JpdGUiKTsKCQkodm9pZCkg
Y2xvc2UoZmQpOwoJCWV4aXQoMCk7Cgl9CglpZiAoY2xvc2UoZmQpKSB7CgkJcGVycm9yKCJjbG9z
ZSIpOwoJCWV4aXQoMCk7Cgl9CglpZiAobGVyciA9IGxpbmsoIkZPTyIsICJURU1QL0JBUiIpKSB7
CgkJaWYgKGVycm5vICE9IEVPUE5PVFNVUFApIHsKCQkJcGVycm9yKCJsaW5rIik7CgkJCWV4aXQo
MCk7CgkJfQoJfSBlbHNlIGlmIChyZW5hbWUoIlRFTVAvQkFSIiwgIkZPTyIpKSB7CgkJcGVycm9y
KCJyZXJlbmFtZSIpOwoJCWV4aXQoMCk7Cgl9CglpZiAodW5saW5rKCJGT08iKSkgewoJCXBlcnJv
cigidW5saW5rIDEiKTsKCQlleGl0KDApOwoJfQogICAgICAgIHN5c3RlbSgibHMgLWwgRk9PIFRF
TVAvQkFSIik7CglleGl0KGVycm5vKTsKfQo=

------=GPMAIL_ATT_0.775036035316649--



-------------------------------------------------------
This SF.Net email is sponsored by: thawte's Crypto Challenge Vl
Crack the code and win a Sony DCRHC40 MiniDV Digital Handycam
Camcorder. More prizes in the weekly Lunch Hour Challenge.
Sign up NOW http://ad.doubleclick.net/clk;10740251;10262165;m
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
