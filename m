From: "Matt Heaton" <admin@webmersion.com>
Subject: Performance Woes...
Date: Tue, 4 Jun 2002 22:29:56 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <0a1701c20c49$a57f6250$6701a8c0@c1886657a>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0A14_01C20C17.5A9B8D40"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc52.attbi.com ([216.148.227.88])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17FSQz-00046S-00
	for <nfs@lists.sourceforge.net>; Tue, 04 Jun 2002 21:30:09 -0700
Received: from c1886657a ([12.254.138.126]) by rwcrmhc52.attbi.com
          (InterMail vM.4.01.03.27 201-229-121-127-20010626) with SMTP
          id <20020605042958.RGDU2751.rwcrmhc52.attbi.com@c1886657a>
          for <nfs@lists.sourceforge.net>; Wed, 5 Jun 2002 04:29:58 +0000
To: <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

This is a multi-part message in MIME format.

------=_NextPart_000_0A14_01C20C17.5A9B8D40
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi All, I am having some trouble determining whether it is my NFS server =
or Client that is the bottleneck.  I have 10 web servers hooked up to 2 =
NFS servers.
The clients all run Redhat 7.2 with 2.4.18 with NFSALL patch applied, =
and the servers are redhat 7.2 with the 2.4.18 kernel.  I am using UDP.

My problem is that my web servers when doing a "vmstat 1" get many =
blocked processes.  See below.

I can't really get ANY kind of good reading to whether or not an NFS =
server is overloaded or not.  Besides iostat and nfsstat are there any =
good tools?!?!
I am going crazy trying to test.  Please help.  If you are an NFS guru =
feel free to give me a call at (801) 361-1177 (Cell phone).  I am happy =
to pay!

PS - The numbers below were taken at 10:30 PM so traffic is NOT at a =
high during this time, you can expect 50% traffic increase at mid day.

Any help would really be appreciated!  Thanks!

r    b  w   swpd   free      buff     cache  si  so    bi    bo   in     =
cs   us   sy  id
8    1  0   9668 103728  28624 456756   0   0     0    38  588   286  29 =
  3  68
11  0  0   9668 103196  28624 457068   0   0     0    20  617   221  14  =
 5  81
9    2  0   9668 103172  28624 456988   0   0     0    12  267   104  13 =
  2  85


The 'r' at the top left is the problem.  This happens when NFS traffic =
goes way up.  The nfsstat -c for the client look like this.

Client nfs v3:
null       getattr    setattr    lookup     access     readlink  =20
19      0% 29862505 67% 5171    0% 6976413 15% 16064   0% 0       0%=20
read       write      create     mkdir      symlink    mknod     =20
7697391 17% 2287    0% 10      0% 0       0% 0       0% 0       0%=20
remove     rmdir      rename     link       readdir    readdirplus
0       0% 0       0% 0       0% 0       0% 0       0% 53      0%=20
fsstat     fsinfo     pathconf   commit    =20
5       0% 5       0% 0       0% 2287    0%=20


All clients are pretty much the same.  The nfsstat -s for the two NFS =
servers are below.

Server nfs v2:
null       getattr    setattr    root       lookup     readlink  =20
0       0% 4818    0% 457163 19% 0       0% 374516 16% 0       0%=20
read       wrcache    write      create     remove     rename    =20
1006    0% 0       0% 1338999 57% 147627  6% 550     0% 0       0%=20
link       symlink    mkdir      rmdir      readdir    fsstat    =20
0       0% 0       0% 6923    0% 73      0% 4795    0% 5       0%=20

Server nfs v3:
null       getattr    setattr    lookup     access     readlink  =20
12      0% 2487236 38% 22870   0% 2451861 38% 19225   0% 0       0%=20
read       write      create     mkdir      symlink    mknod     =20
971932 15% 274775  4% 31984   0% 1212    0% 0       0% 0       0%=20
remove     rmdir      rename     link       readdir    readdirplus
14422   0% 391     0% 10524   0% 0       0% 24138   0% 0       0%=20
fsstat     fsinfo     pathconf   commit    =20
8       0% 7       0% 0       0% 95129   1%=20


AND THE OTHER SERVER

Server nfs v2:
null       getattr    setattr    root       lookup     readlink  =20
0       0% 54088   0% 453322  1% 0       0% 23253032 55% 0       0%=20
read       wrcache    write      create     remove     rename    =20
1964341  4% 0       0% 13001439 31% 449191  1% 676267  1% 21247   0%=20
link       symlink    mkdir      rmdir      readdir    fsstat    =20
0       0% 0       0% 15479   0% 65541   0% 1647071  3% 51      0%=20

Server nfs v3:
null       getattr    setattr    lookup     access     readlink  =20
0       0% 416318245  2% 2678145  0% 461314618  2% 127706435  3% 0       =
0%=20
read       write      create     mkdir      symlink    mknod     =20
184416498  1% 22576823  1% 2622952  0% 92490   0% 0       0% 0       0%=20
remove     rmdir      rename     link       readdir    readdirplus
1550770  0% 61184   0% 1673675  0% 0       0% 5333994  0% 180     0%=20
fsstat     fsinfo     pathconf   commit    =20
187     0% 129     0% 0       0% 10053536  0%=20


IOSTAT 5 for the first NFS server below

Device:        tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
dev3-0        1.00         0.00        30.40          0        152
dev8-0       48.60       273.60       516.80       1368       2584

IOSTAT 5 for the second NFS server below

Device:        tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
dev3-0        0.40         0.00        17.60          0         88
dev8-0       70.60       752.00       132.80       3760        664



------=_NextPart_000_0A14_01C20C17.5A9B8D40
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2716.2200" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>Hi All, I am having some trouble =
determining=20
whether it is my NFS server or Client that is the bottleneck.&nbsp; I =
have 10=20
web servers hooked up to 2 NFS servers.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>The clients all run Redhat 7.2 with =
2.4.18 with=20
NFSALL patch applied, and the servers are redhat 7.2 with the 2.4.18=20
kernel.&nbsp; I am using UDP.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>My problem is that my web servers when =
doing a=20
"vmstat 1" get many blocked processes.&nbsp; See below.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>I can't really get ANY kind of good =
reading to=20
whether or not an NFS server is overloaded or not.&nbsp; Besides iostat =
and=20
nfsstat are there any good tools?!?!</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>I am going crazy trying to test.&nbsp; =
Please=20
help.&nbsp; If you are an NFS guru feel free to give me a call at (801) =
361-1177=20
(Cell phone).&nbsp; I am happy to pay!</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>PS - The numbers below were taken at =
10:30 PM so=20
traffic is NOT at a high during this time, you can expect 50% traffic =
increase=20
at mid day.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Any help would really be =
appreciated!&nbsp;=20
Thanks!</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>r&nbsp;&nbsp; &nbsp;b&nbsp; =
w&nbsp;&nbsp;=20
swpd&nbsp;&nbsp; free&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
buff&nbsp;&nbsp;&nbsp;&nbsp;=20
cache&nbsp; si&nbsp; so&nbsp;&nbsp;&nbsp; bi&nbsp;&nbsp;&nbsp; =
bo&nbsp;&nbsp;=20
in&nbsp;&nbsp;&nbsp;&nbsp; cs&nbsp;&nbsp; us&nbsp; &nbsp;sy&nbsp;=20
id</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>8&nbsp;&nbsp;&nbsp; 1&nbsp; =
0&nbsp;&nbsp; 9668=20
103728&nbsp; 28624 456756&nbsp;&nbsp; 0&nbsp;&nbsp; =
0&nbsp;&nbsp;&nbsp;&nbsp;=20
0&nbsp;&nbsp;&nbsp; 38&nbsp; 588&nbsp;&nbsp; 286&nbsp; 29&nbsp;&nbsp; =
3&nbsp;=20
68<BR>11&nbsp; 0&nbsp; 0&nbsp;&nbsp; 9668 103196&nbsp; 28624 =
457068&nbsp;&nbsp;=20
0&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp; 20&nbsp;=20
617&nbsp;&nbsp; 221&nbsp; 14&nbsp;&nbsp; 5&nbsp; =
81<BR>9&nbsp;&nbsp;&nbsp;=20
2&nbsp; 0&nbsp;&nbsp; 9668 103172&nbsp; 28624 456988&nbsp;&nbsp; =
0&nbsp;&nbsp;=20
0&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp; 12&nbsp; 267&nbsp;&nbsp; =
104&nbsp;=20
13&nbsp;&nbsp; 2&nbsp; 85</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>The 'r' at the top left is the =
problem.&nbsp; This=20
happens when NFS traffic goes way up.&nbsp; The nfsstat -c for the =
client look=20
like this.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Client nfs=20
v3:<BR>null&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
getattr&nbsp;&nbsp;&nbsp;=20
setattr&nbsp;&nbsp;&nbsp; lookup&nbsp;&nbsp;&nbsp;&nbsp;=20
access&nbsp;&nbsp;&nbsp;&nbsp; readlink&nbsp;&nbsp;=20
<BR>19&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 29862505 67% =
5171&nbsp;&nbsp;&nbsp; 0%=20
6976413 15% 16064&nbsp;&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
0%=20
<BR>read&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
write&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
create&nbsp;&nbsp;&nbsp;&nbsp; mkdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
symlink&nbsp;&nbsp;&nbsp; mknod&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
<BR>7697391 17%=20
2287&nbsp;&nbsp;&nbsp; 0% 10&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
<BR>remove&nbsp;&nbsp;&nbsp;&nbsp;=20
rmdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rename&nbsp;&nbsp;&nbsp;&nbsp;=20
link&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; readdir&nbsp;&nbsp;&nbsp;=20
readdirplus<BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
53&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
<BR>fsstat&nbsp;&nbsp;&nbsp;&nbsp; fsinfo&nbsp;&nbsp;&nbsp;&nbsp;=20
pathconf&nbsp;&nbsp; commit&nbsp;&nbsp;&nbsp;&nbsp;=20
<BR>5&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
5&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0% 2287&nbsp;&nbsp;&nbsp; 0% </FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>All clients are pretty much the =
same.&nbsp; The=20
nfsstat -s&nbsp;for the two NFS servers are below.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Server nfs=20
v2:<BR>null&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
getattr&nbsp;&nbsp;&nbsp;=20
setattr&nbsp;&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
lookup&nbsp;&nbsp;&nbsp;&nbsp; readlink&nbsp;&nbsp;=20
<BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 4818&nbsp;&nbsp;&nbsp; 0% =
457163=20
19% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 374516 16%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
<BR>read&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; wrcache&nbsp;&nbsp;&nbsp;=20
write&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; create&nbsp;&nbsp;&nbsp;&nbsp;=20
remove&nbsp;&nbsp;&nbsp;&nbsp; rename&nbsp;&nbsp;&nbsp;&nbsp;=20
<BR>1006&nbsp;&nbsp;&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
1338999=20
57% 147627&nbsp; 6% 550&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
<BR>link&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; symlink&nbsp;&nbsp;&nbsp;=20
mkdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rmdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
readdir&nbsp;&nbsp;&nbsp; fsstat&nbsp;&nbsp;&nbsp;&nbsp;=20
<BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 6923&nbsp;&nbsp;&nbsp; 0%=20
73&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 4795&nbsp;&nbsp;&nbsp; 0%=20
5&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% </FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Server nfs=20
v3:<BR>null&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
getattr&nbsp;&nbsp;&nbsp;=20
setattr&nbsp;&nbsp;&nbsp; lookup&nbsp;&nbsp;&nbsp;&nbsp;=20
access&nbsp;&nbsp;&nbsp;&nbsp; readlink&nbsp;&nbsp;=20
<BR>12&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 2487236 38% 22870&nbsp;&nbsp; 0% =
2451861=20
38% 19225&nbsp;&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
<BR>read&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
write&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
create&nbsp;&nbsp;&nbsp;&nbsp; mkdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
symlink&nbsp;&nbsp;&nbsp; mknod&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <BR>971932 =
15%=20
274775&nbsp; 4% 31984&nbsp;&nbsp; 0% 1212&nbsp;&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0% <BR>remove&nbsp;&nbsp;&nbsp;&nbsp; =
rmdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
rename&nbsp;&nbsp;&nbsp;&nbsp; link&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
readdir&nbsp;&nbsp;&nbsp; readdirplus<BR>14422&nbsp;&nbsp; 0%=20
391&nbsp;&nbsp;&nbsp;&nbsp; 0% 10524&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 24138&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
<BR>fsstat&nbsp;&nbsp;&nbsp;&nbsp;=20
fsinfo&nbsp;&nbsp;&nbsp;&nbsp; pathconf&nbsp;&nbsp;=20
commit&nbsp;&nbsp;&nbsp;&nbsp; <BR>8&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
0%=20
7&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0% 95129&nbsp;&nbsp; 1% </FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>AND THE OTHER SERVER</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Server nfs=20
v2:<BR>null&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
getattr&nbsp;&nbsp;&nbsp;=20
setattr&nbsp;&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
lookup&nbsp;&nbsp;&nbsp;&nbsp; readlink&nbsp;&nbsp;=20
<BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 54088&nbsp;&nbsp; 0% =
453322&nbsp;=20
1% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 23253032 55%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
<BR>read&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; wrcache&nbsp;&nbsp;&nbsp;=20
write&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; create&nbsp;&nbsp;&nbsp;&nbsp;=20
remove&nbsp;&nbsp;&nbsp;&nbsp; rename&nbsp;&nbsp;&nbsp;&nbsp; =
<BR>1964341&nbsp;=20
4% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 13001439 31% 449191&nbsp; 1% =

676267&nbsp; 1% 21247&nbsp;&nbsp; 0%=20
<BR>link&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; symlink&nbsp;&nbsp;&nbsp;=20
mkdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rmdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
readdir&nbsp;&nbsp;&nbsp; fsstat&nbsp;&nbsp;&nbsp;&nbsp;=20
<BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 15479&nbsp;&nbsp; 0% =
65541&nbsp;&nbsp;=20
0% 1647071&nbsp; 3% 51&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% </FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Server nfs=20
v3:<BR>null&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
getattr&nbsp;&nbsp;&nbsp;=20
setattr&nbsp;&nbsp;&nbsp; lookup&nbsp;&nbsp;&nbsp;&nbsp;=20
access&nbsp;&nbsp;&nbsp;&nbsp; readlink&nbsp;&nbsp;=20
<BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 416318245&nbsp; 2% =
2678145&nbsp; 0%=20
461314618&nbsp; 2% 127706435&nbsp; 3% =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
<BR>read&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
write&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
create&nbsp;&nbsp;&nbsp;&nbsp; mkdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
symlink&nbsp;&nbsp;&nbsp; mknod&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
<BR>184416498&nbsp; 1% 22576823&nbsp; 1% 2622952&nbsp; 0% =
92490&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0% <BR>remove&nbsp;&nbsp;&nbsp;&nbsp; =
rmdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
rename&nbsp;&nbsp;&nbsp;&nbsp; link&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
readdir&nbsp;&nbsp;&nbsp; readdirplus<BR>1550770&nbsp; 0% =
61184&nbsp;&nbsp; 0%=20
1673675&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 5333994&nbsp; =
0%=20
180&nbsp;&nbsp;&nbsp;&nbsp; 0% <BR>fsstat&nbsp;&nbsp;&nbsp;&nbsp;=20
fsinfo&nbsp;&nbsp;&nbsp;&nbsp; pathconf&nbsp;&nbsp;=20
commit&nbsp;&nbsp;&nbsp;&nbsp; <BR>187&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
129&nbsp;&nbsp;&nbsp;&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
10053536&nbsp; 0% <BR></FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>IOSTAT 5 for the first NFS server=20
below</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial =
size=3D2>Device:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
tps&nbsp;&nbsp; Blk_read/s&nbsp;&nbsp; Blk_wrtn/s&nbsp;&nbsp;=20
Blk_read&nbsp;&nbsp;=20
Blk_wrtn<BR>dev3-0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
1.00&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0.00&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
30.40&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
152<BR>dev8-0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
48.60&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
273.60&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
516.80&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
1368&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2584</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>IOSTAT 5 for the second NFS server=20
below</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial =
size=3D2>Device:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
tps&nbsp;&nbsp; Blk_read/s&nbsp;&nbsp; Blk_wrtn/s&nbsp;&nbsp;=20
Blk_read&nbsp;&nbsp;=20
Blk_wrtn<BR>dev3-0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0.40&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0.00&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
17.60&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
88<BR>dev8-0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
70.60&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
752.00&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
132.80&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
3760&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 664</DIV></FONT>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV></BODY></HTML>

------=_NextPart_000_0A14_01C20C17.5A9B8D40--


_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
