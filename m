From: "Matt Heaton" <admin@0catch.com>
Subject: NFSSTAT QUESTION.
Date: Mon, 18 Mar 2002 22:26:39 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <070101c1cf06$a5cfffb0$6601a8c0@c1886657a>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_06FE_01C1CECB.F92F8AD0"
Received: from rwcrmhc54.attbi.com ([216.148.227.87])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16mpdD-0001OH-00
	for <nfs@lists.sourceforge.net>; Sun, 17 Mar 2002 21:24:27 -0800
Received: from c1886657a ([12.254.138.126]) by rwcrmhc54.attbi.com
          (InterMail vM.4.01.03.27 201-229-121-127-20010626) with SMTP
          id <20020318052421.YBXC1214.rwcrmhc54.attbi.com@c1886657a>
          for <nfs@lists.sourceforge.net>; Mon, 18 Mar 2002 05:24:21 +0000
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

------=_NextPart_000_06FE_01C1CECB.F92F8AD0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

I have a HUGE directory structure on my NFS server.  I host free =
websites and have literally 390K directories on my NFS server.  Below is =
output from
my NFS box.  It shows 99% of the clients time is taken by lookups (I =
believe going through the directories).  I have heard there is a way =
through the
kernal or some other method to increase the cache associated with the =
DIRECTORY LOOKUPS so that I didn't have to hit the drive everytime to =
get
the directory.  I have 1 GIG in the this machine and can easily upgrade =
it to 4 GIG to give it a huge directory lookup cache if someone can =
point me in
the right direction.  My clients and my servers are both using kernal =
2.4.7-10 (Redhat 7.2).

Thanks,
Matt Heaton

calls      badcalls   badauth    badclnt    xdrcall
73765732   0          0          0          0      =20
Server nfs v2:
null       getattr    setattr    root       lookup     readlink  =20
0       0% 48449   0% 77378   0% 0       0% 5527260 51% 0       0%=20
read       wrcache    write      create     remove     rename    =20
3050391 28% 0       0% 1793260 16% 83335   0% 49376   0% 9001    0%=20
link       symlink    mkdir      rmdir      readdir    fsstat    =20
0       0% 0       0% 13721   0% 2258    0% 153840  1% 3       0%=20

Server nfs v3:
null       getattr    setattr    lookup     access     readlink  =20
0       0% 535201  0% 267339  0% 42856622 68% 167774  0% 0       0%=20
read       write      create     mkdir      symlink    mknod     =20
13981454 22% 2907986  4% 340093  0% 10591   0% 0       0% 0       0%=20
remove     rmdir      rename     link       readdir    readdirplus
153574  0% 5102    0% 189901  0% 0       0% 272374  0% 0       0%=20
fsstat     fsinfo     pathconf   commit    =20
42      0% 42      0% 0       0% 1269365  2%=20

Client rpc stats:
calls      retrans    authrefrsh
2043779    0          0      =20
Client nfs v2:
null       getattr    setattr    root       lookup     readlink  =20
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
read       wrcache    write      create     remove     rename    =20
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
link       symlink    mkdir      rmdir      readdir    fsstat    =20
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20

Client nfs v3:
null       getattr    setattr    lookup     access     readlink  =20
0       0% 26      0% 0       0% 2043741 99% 0       0% 0       0%=20
read       write      create     mkdir      symlink    mknod     =20
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
remove     rmdir      rename     link       readdir    readdirplus
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
fsstat     fsinfo     pathconf   commit    =20
6       0% 6       0% 0       0% 0       0%=20


------=_NextPart_000_06FE_01C1CECB.F92F8AD0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2600.0" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>I have a HUGE directory structure on my =
NFS=20
server.&nbsp; I host free websites and have literally 390K directories =
on my NFS=20
server.&nbsp; Below is output from</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>my NFS box.&nbsp; It shows 99% of the =
clients time=20
is taken by lookups (I believe going through the directories).&nbsp; I =
have=20
heard there is a way through the</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>kernal or some other method to increase =
the cache=20
associated with the DIRECTORY LOOKUPS so that I didn't have to hit the =
drive=20
everytime to get</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>the directory.&nbsp; I have 1 GIG in =
the this=20
machine and can easily upgrade it to 4 GIG to give it a huge directory =
lookup=20
cache if someone can point me in</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>the right direction.&nbsp; My clients =
and my=20
servers are both using kernal 2.4.7-10 (Redhat 7.2).</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Thanks,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Matt Heaton</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>calls&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
badcalls&nbsp;&nbsp; badauth&nbsp;&nbsp;&nbsp; badclnt&nbsp;&nbsp;&nbsp; =

xdrcall<BR>73765732&nbsp;&nbsp;=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <BR>Server nfs=20
v2:<BR>null&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
getattr&nbsp;&nbsp;&nbsp;=20
setattr&nbsp;&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
lookup&nbsp;&nbsp;&nbsp;&nbsp; readlink&nbsp;&nbsp;=20
<BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 48449&nbsp;&nbsp; 0%=20
77378&nbsp;&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 5527260 =
51%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
<BR>read&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; wrcache&nbsp;&nbsp;&nbsp;=20
write&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; create&nbsp;&nbsp;&nbsp;&nbsp;=20
remove&nbsp;&nbsp;&nbsp;&nbsp; rename&nbsp;&nbsp;&nbsp;&nbsp; =
<BR>3050391 28%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 1793260 16% 83335&nbsp;&nbsp; =
0%=20
49376&nbsp;&nbsp; 0% 9001&nbsp;&nbsp;&nbsp; 0%=20
<BR>link&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; symlink&nbsp;&nbsp;&nbsp;=20
mkdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rmdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
readdir&nbsp;&nbsp;&nbsp; fsstat&nbsp;&nbsp;&nbsp;&nbsp;=20
<BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 13721&nbsp;&nbsp; 0%=20
2258&nbsp;&nbsp;&nbsp; 0% 153840&nbsp; 1% =
3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0% </FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Server nfs=20
v3:<BR>null&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
getattr&nbsp;&nbsp;&nbsp;=20
setattr&nbsp;&nbsp;&nbsp; lookup&nbsp;&nbsp;&nbsp;&nbsp;=20
access&nbsp;&nbsp;&nbsp;&nbsp; readlink&nbsp;&nbsp;=20
<BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 535201&nbsp; 0% =
267339&nbsp; 0%=20
42856622 68% 167774&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
<BR>read&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
write&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
create&nbsp;&nbsp;&nbsp;&nbsp; mkdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
symlink&nbsp;&nbsp;&nbsp; mknod&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
<BR>13981454 22%=20
2907986&nbsp; 4% 340093&nbsp; 0% 10591&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0% <BR>remove&nbsp;&nbsp;&nbsp;&nbsp; =
rmdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
rename&nbsp;&nbsp;&nbsp;&nbsp; link&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
readdir&nbsp;&nbsp;&nbsp; readdirplus<BR>153574&nbsp; 0% =
5102&nbsp;&nbsp;&nbsp;=20
0% 189901&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 272374&nbsp; =
0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
<BR>fsstat&nbsp;&nbsp;&nbsp;&nbsp;=20
fsinfo&nbsp;&nbsp;&nbsp;&nbsp; pathconf&nbsp;&nbsp;=20
commit&nbsp;&nbsp;&nbsp;&nbsp; <BR>42&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
42&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
1269365&nbsp; 2% </FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Client rpc=20
stats:<BR>calls&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; retrans&nbsp;&nbsp;&nbsp;=20
authrefrsh<BR>2043779&nbsp;&nbsp;&nbsp;=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <BR>Client nfs=20
v2:<BR>null&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
getattr&nbsp;&nbsp;&nbsp;=20
setattr&nbsp;&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
lookup&nbsp;&nbsp;&nbsp;&nbsp; readlink&nbsp;&nbsp;=20
<BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0% <BR>read&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
wrcache&nbsp;&nbsp;&nbsp;=20
write&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; create&nbsp;&nbsp;&nbsp;&nbsp;=20
remove&nbsp;&nbsp;&nbsp;&nbsp; rename&nbsp;&nbsp;&nbsp;&nbsp;=20
<BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0% <BR>link&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
symlink&nbsp;&nbsp;&nbsp;=20
mkdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rmdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
readdir&nbsp;&nbsp;&nbsp; fsstat&nbsp;&nbsp;&nbsp;&nbsp;=20
<BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0% </FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Client nfs=20
v3:<BR>null&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
getattr&nbsp;&nbsp;&nbsp;=20
setattr&nbsp;&nbsp;&nbsp; lookup&nbsp;&nbsp;&nbsp;&nbsp;=20
access&nbsp;&nbsp;&nbsp;&nbsp; readlink&nbsp;&nbsp;=20
<BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
26&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 2043741 99%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0% <BR>read&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
write&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; create&nbsp;&nbsp;&nbsp;&nbsp;=20
mkdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; symlink&nbsp;&nbsp;&nbsp;=20
mknod&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
<BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0% <BR>remove&nbsp;&nbsp;&nbsp;&nbsp; =
rmdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
rename&nbsp;&nbsp;&nbsp;&nbsp; link&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
readdir&nbsp;&nbsp;&nbsp; =
readdirplus<BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%=20
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
<BR>fsstat&nbsp;&nbsp;&nbsp;&nbsp;=20
fsinfo&nbsp;&nbsp;&nbsp;&nbsp; pathconf&nbsp;&nbsp;=20
commit&nbsp;&nbsp;&nbsp;&nbsp; <BR>6&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
0%=20
6&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% </FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV></BODY></HTML>

------=_NextPart_000_06FE_01C1CECB.F92F8AD0--


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
