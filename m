From: "Matt Heaton" <admin@webmersion.com>
Subject: Still having nfsd-fh problems...
Date: Sun, 7 Jul 2002 17:03:55 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <0dcc01c2260a$9245eda0$6601a8c0@c1886657a>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0DC9_01C225D8.4755E390"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sccrmhc02.attbi.com ([204.127.202.62])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17RL4a-0000fB-00
	for <nfs@lists.sourceforge.net>; Sun, 07 Jul 2002 16:04:08 -0700
Received: from c1886657a ([12.255.25.93]) by sccrmhc02.attbi.com
          (InterMail vM.4.01.03.27 201-229-121-127-20010626) with SMTP
          id <20020707230401.WNGJ6023.sccrmhc02.attbi.com@c1886657a>
          for <nfs@lists.sourceforge.net>; Sun, 7 Jul 2002 23:04:01 +0000
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

------=_NextPart_000_0DC9_01C225D8.4755E390
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Anyone know what might cause these in a 2.4.18 kernel (No patches) =
Redhat 7.2, on an NFS server exporting a reiser file system.
I am getting tons of these errors.   The files exist when I go to see =
them, but they don't exist when I try to see them from the client?

Any ideas.  Also, are Tronds nfsall patches for the NFS clients only, or =
are they some patches that I should have for the server in 2.4.18?

Jul  7 16:47:27 titan2 last message repeated 4 times
Jul  7 16:47:27 titan2 kernel: nfsd-fh: found a name that I didn't =
expect: yp/layrz.bravepages.com
Jul  7 16:47:27 titan2 kernel: nfsd-fh: found a name that I didn't =
expect: yp/layrz.bravepages.com
Jul  7 16:47:27 titan2 kernel: nfsd-fh: found a name that I didn't =
expect: er.bravepages.com/b
Jul  7 16:47:31 titan2 last message repeated 19 times
Jul  7 16:47:31 titan2 kernel: nfsd-fh: found a name that I didn't =
expect: yp/layrz.bravepages.com
Jul  7 16:47:31 titan2 last message repeated 3 times
Jul  7 16:47:31 titan2 kernel: nfsd-fh: found a name that I didn't =
expect: er.bravepages.com/b
Jul  7 16:47:39 titan2 last message repeated 21 times
Jul  7 16:49:15 titan2 kernel: nfsd-fh: found a name that I didn't =
expect: yp/layrz.bravepages.com
MJul  7 16:49:37 titan2 last message repeated 23 times
Jul  7 16:51:28 titan2 kernel: nfsd-fh: found a name that I didn't =
expect: la/de
Jul  7 16:51:28 titan2 last message repeated 2 times
Jul  7 16:51:35 titan2 kernel: nfsd-fh: found a name that I didn't =
expect: ki/grl.envy.

Thanks,
Matt


------=_NextPart_000_0DC9_01C225D8.4755E390
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
<DIV><FONT face=3DArial size=3D2>Anyone know what might cause these in a =
2.4.18=20
kernel (No patches) Redhat 7.2, on an NFS server exporting a reiser file =

system.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>I am getting tons of these =
errors.&nbsp;&nbsp; The=20
files exist when I go to see them, but they don't exist when I try to =
see them=20
from the client?</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Any ideas.&nbsp; Also, are Tronds =
nfsall patches=20
for the NFS clients only, or are they some patches that I should have =
for the=20
server in 2.4.18?</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Jul&nbsp; 7 16:47:27 titan2 last =
message repeated 4=20
times<BR>Jul&nbsp; 7 16:47:27 titan2 kernel: nfsd-fh: found a name that =
I didn't=20
expect: yp/layrz.bravepages.com<BR>Jul&nbsp; 7 16:47:27 titan2 kernel: =
nfsd-fh:=20
found a name that I didn't expect: yp/layrz.bravepages.com<BR>Jul&nbsp; =
7=20
16:47:27 titan2 kernel: nfsd-fh: found a name that I didn't expect:=20
er.bravepages.com/b<BR>Jul&nbsp; 7 16:47:31 titan2 last message repeated =
19=20
times<BR>Jul&nbsp; 7 16:47:31 titan2 kernel: nfsd-fh: found a name that =
I didn't=20
expect: yp/layrz.bravepages.com<BR>Jul&nbsp; 7 16:47:31 titan2 last =
message=20
repeated 3 times<BR>Jul&nbsp; 7 16:47:31 titan2 kernel: nfsd-fh: found a =
name=20
that I didn't expect: er.bravepages.com/b<BR>Jul&nbsp; 7 16:47:39 titan2 =
last=20
message repeated 21 times<BR>Jul&nbsp; 7 16:49:15 titan2 kernel: =
nfsd-fh: found=20
a name that I didn't expect: yp/layrz.bravepages.com<BR>MJul&nbsp; 7 =
16:49:37=20
titan2 last message repeated 23 times<BR>Jul&nbsp; 7 16:51:28 titan2 =
kernel:=20
nfsd-fh: found a name that I didn't expect: la/de<BR>Jul&nbsp; 7 =
16:51:28 titan2=20
last message repeated 2 times<BR>Jul&nbsp; 7 16:51:35 titan2 kernel: =
nfsd-fh:=20
found a name that I didn't expect: ki/grl.envy.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Thanks,<BR>Matt</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV></BODY></HTML>

------=_NextPart_000_0DC9_01C225D8.4755E390--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
We have stuff for geeks like you.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
