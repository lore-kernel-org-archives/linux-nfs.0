From: "poczta.dotcom.pl" <myciel@dotcom.pl>
Subject: nfs performance problem
Date: Tue, 5 Nov 2002 19:03:43 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <005b01c284f5$ae1d6090$640a010a@winda>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0058_01C284FE.0FA7CCD0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rtr.pul.pl ([195.116.89.98] helo=poczta.dotcom.pl)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18988a-0008Be-00
	for <nfs@lists.sourceforge.net>; Tue, 05 Nov 2002 10:09:16 -0800
Received: from winda (office.interia.pl [213.76.176.114])
	by poczta.dotcom.pl (Postfix) with ESMTP id 52F9A159E7
	for <nfs@lists.sourceforge.net>; Tue,  5 Nov 2002 19:06:47 +0100 (CET)
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.

------=_NextPart_000_0058_01C284FE.0FA7CCD0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi All

I have really slow working nfs.
Server is build on:
- dual pentium Xeon 2GHz,
- 2 3ware 7500 controllers,
- raid 5 on 7 160GB discs on controler 1=20
- raid 5 on 6 160GB disks on cotroller 2=20

Serwer is used for ~500k maildirs,=20
all clients (~20) are freebsd boxes, when nfs transfer is around 1MB/s =
for writing and 1.5MB/s for reading=20
listing user directories even with very few file stakes up to 15 =
seconds.

I tried nfs-ALL patch, but it didn' t help.

I run 256 nfs daemons,

echo 2097152 > /proc/sys/net/core/rmem_max
echo 2097152 > /proc/sys/net/core/rmem_default


nsfstat output:

Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
25271043   17885061   0          17885061   0

Server nfs v3:
null       getattr    setattr    lookup     access     readlink
25      0% 1159    0% 89718   0% 11702395 46% 10953437 43% 34868   0%
read       write      create     mkdir      symlink    mknod
925727  3% 226250  0% 44964   0% 1089    0% 2299    0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
35040   0% 42      0% 121064  0% 535     0% 534720  2% 0       0%
fsstat     fsinfo     pathconf   commit
585179  2% 36      0% 0       0% 12493   0%

mount over tcp gives frequent errors on freebsd clients side:
kernel: nfs send error 32 from nfs server xxx.xxx.xxx.xxx:/export

thanks for any help,=20

rafal


------=_NextPart_000_0058_01C284FE.0FA7CCD0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META content=3D"text/html; charset=3Diso-8859-1" =
http-equiv=3DContent-Type>
<META content=3D"MSHTML 5.00.3103.1000" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>Hi All</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>I have really slow working =
nfs.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Server is build on:</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>-&nbsp;dual pentium Xeon =
2GHz,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>- 2 3ware 7500 =
controllers,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>- raid 5 on 7 160GB discs on controler=20
1&nbsp;</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>- raid 5 on 6 160GB disks on cotroller=20
2&nbsp;</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Serwer is used for ~500k maildirs, =
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>all clients (~20) are freebsd boxes, =
when nfs=20
transfer is around 1MB/s for writing and 1.5MB/s for reading =
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>listing user directories even with very =
few file=20
stakes up to 15 seconds.</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>I tried nfs-ALL patch, but it didn' t=20
help.</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>I run 256 nfs daemons,</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>echo 2097152 &gt;=20
/proc/sys/net/core/rmem_max<BR>echo 2097152 &gt;=20
/proc/sys/net/core/rmem_default<BR></FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2><FONT face=3DArial size=3D2>nsfstat=20
output:</DIV></FONT></FONT>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Server rpc=20
stats:<BR>calls&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; badcalls&nbsp;&nbsp;=20
badauth&nbsp;&nbsp;&nbsp; badclnt&nbsp;&nbsp;&nbsp;=20
xdrcall<BR>25271043&nbsp;&nbsp; 17885061&nbsp;&nbsp;=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
17885061&nbsp;&nbsp;=20
0<BR></FONT><FONT face=3DArial size=3D2></FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Server nfs=20
v3:<BR>null&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
getattr&nbsp;&nbsp;&nbsp;=20
setattr&nbsp;&nbsp;&nbsp; lookup&nbsp;&nbsp;&nbsp;&nbsp;=20
access&nbsp;&nbsp;&nbsp;&nbsp; =
readlink<BR>25&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
1159&nbsp;&nbsp;&nbsp; 0% 89718&nbsp;&nbsp; 0% 11702395 46% 10953437 43% =

34868&nbsp;&nbsp; 0%<BR>read&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
write&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; create&nbsp;&nbsp;&nbsp;&nbsp;=20
mkdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; symlink&nbsp;&nbsp;&nbsp;=20
mknod<BR>925727&nbsp; 3% 226250&nbsp; 0% 44964&nbsp;&nbsp; 0%=20
1089&nbsp;&nbsp;&nbsp; 0% 2299&nbsp;&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
0%<BR>remove&nbsp;&nbsp;&nbsp;&nbsp;=20
rmdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rename&nbsp;&nbsp;&nbsp;&nbsp;=20
link&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; readdir&nbsp;&nbsp;&nbsp;=20
readdirplus<BR>35040&nbsp;&nbsp; 0% 42&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
121064&nbsp; 0% 535&nbsp;&nbsp;&nbsp;&nbsp; 0% 534720&nbsp; 2%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
0%<BR>fsstat&nbsp;&nbsp;&nbsp;&nbsp;=20
fsinfo&nbsp;&nbsp;&nbsp;&nbsp; pathconf&nbsp;&nbsp; =
commit<BR>585179&nbsp; 2%=20
36&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
12493&nbsp;&nbsp; 0%<BR></FONT></DIV>
<DIV><FONT face=3DArial size=3D2>mount over tcp gives frequent errors on =
freebsd=20
clients side:</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>kernel: nfs send error 32 from nfs =
server=20
xxx.xxx.xxx.xxx:/export</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;</DIV></FONT>
<DIV><FONT face=3DArial size=3D2>thanks for any help, </FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>rafal</DIV></FONT>
<DIV>&nbsp;</DIV></BODY></HTML>

------=_NextPart_000_0058_01C284FE.0FA7CCD0--



-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
