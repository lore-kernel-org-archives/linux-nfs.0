From: "imran" <imran.sheth@patni.com>
Subject: problem in compiling nlmtest.c
Date: Wed, 18 Dec 2002 10:54:57 +0530
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <002d01c2a655$e08cccb0$7dbba5cc@pcp31638>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0029_01C2A683.E78E8980"
Return-path: <nfs-admin@lists.sourceforge.net>
To: <NFS@lists.sourceforge.net>
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

------=_NextPart_000_0029_01C2A683.E78E8980
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit

Hi
  currently i am working with NLM test utility available under
nfs-utils-0.3.3. while compiling nlmtest.c I am getting following error


debian:/home/imran/LockStudy/nfs-utils-0.3.3/tools/nlmtest# make
gcc -g -O2 -D_GNU_SOURCE -Isupport/include -Wall  -pipe  -DVERSION="\"nfs-ut
ils 0.3.3\"" -D
NFS3_SUPPORTED   -c -o nlmtest.o nlmtest.c
nlmtest.c: In function `main':
nlmtest.c:101: incompatible type for argument 1 of `nlm_test_1'
nlmtest.c:135: incompatible type for argument 1 of `nlm_unlock_1'
nlmtest.c:153: incompatible type for argument 1 of `nlm_lock_1'
make: *** [nlmtest.o] Error 1

I have updated host.h with appropriate host name and appropriate directory

could anybody help me to build nlmtest.o


Thanks and regards

################################
Imran Sheth
Senior Software Engineer
Patni Computer System
SDF 5, Unit 141,SEEPZ
Andheri
ph : 28291454  extn:5017
################################

------=_NextPart_000_0029_01C2A683.E78E8980
Content-Type: text/html;
	charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META content=3D"text/html; charset=3Diso-2022-jp" =
http-equiv=3DContent-Type>
<META content=3D"MSHTML 5.00.2920.0" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT size=3D2>Hi </FONT></DIV>
<DIV><FONT size=3D2>&nbsp; currently i am working with NLM test utility =
available=20
under nfs-utils-0.3.3. while compiling nlmtest.c I am getting following =
error=20
</FONT></DIV>
<DIV><FONT size=3D2></FONT>&nbsp;</DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT =
size=3D2>debian:/home/imran/LockStudy/nfs-utils-0.3.3/tools/nlmtest#=20
make<BR>gcc -g -O2 -D_GNU_SOURCE -Isupport/include -Wall&nbsp; =
-pipe&nbsp;=20
-DVERSION=3D"\"nfs-utils 0.3.3\"" -D<BR>NFS3_SUPPORTED&nbsp;&nbsp; -c -o =
nlmtest.o=20
nlmtest.c<BR>nlmtest.c: In function `main':<BR>nlmtest.c:101: =
incompatible type=20
for argument 1 of `nlm_test_1'<BR>nlmtest.c:135: incompatible type for =
argument=20
1 of `nlm_unlock_1'<BR>nlmtest.c:153: incompatible type for argument 1 =
of=20
`nlm_lock_1'<BR>make: *** [nlmtest.o] Error 1</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT size=3D2>I have updated host.h with appropriate host name and =

appropriate directory</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT size=3D2>could anybody help me to build =
nlmtest.o</FONT></DIV>
<DIV><FONT size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT size=3D2>Thanks and regards</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT size=3D2>################################<BR>Imran =
Sheth<BR>Senior=20
Software Engineer<BR>Patni Computer System<BR>SDF 5, Unit=20
141,SEEPZ<BR>Andheri<BR>ph : 28291454&nbsp;=20
extn:5017<BR>################################</FONT></DIV></BODY></HTML>

------=_NextPart_000_0029_01C2A683.E78E8980--



-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
