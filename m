From: "Matt Heaton" <admin@webmersion.com>
Subject: nfsd-fh prloblem...  Neil can you help?
Date: Mon, 8 Jul 2002 08:25:13 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <26c401c2268b$467afc90$6601a8c0@c1886657a>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_26C1_01C22658.FB8AF280"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sccrmhc02.attbi.com ([204.127.202.62])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17RZS5-0004cU-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Jul 2002 07:25:21 -0700
Received: from c1886657a ([12.255.25.93]) by sccrmhc02.attbi.com
          (InterMail vM.4.01.03.27 201-229-121-127-20010626) with SMTP
          id <20020708142514.MKMJ6023.sccrmhc02.attbi.com@c1886657a>
          for <nfs@lists.sourceforge.net>; Mon, 8 Jul 2002 14:25:14 +0000
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

------=_NextPart_000_26C1_01C22658.FB8AF280
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Anyone know what might cause these in a 2.4.18 kernel (No patches)=20
Redhat 7.2, on an NFS server exporting a reiser file system.
I am getting tons of these errors.   The files exist when I go to see=20
them on the server, but they don't exist when I try to see them from the =
client?
I get a file exists on the client when I try to go to the directory that =
is shown
in the error on the client machine.   If I then go back to the server =
make a new
directory and move the files from the "broken" directoy to the new one =
and then
delete the "broken" directory and then mv the new directory to the old =
directory
name everything works.  I keep getting new errors for new directories =
constantly
though.

Any ideas.  Also, are Tronds nfsall patches for the NFS clients only, or =
=3D
are they some patches that I should have for the server in 2.4.18?

Jul  7 16:47:27 titan2 last message repeated 4 times
Jul  7 16:47:27 titan2 kernel: nfsd-fh: found a name that I didn't =3D
expect: yp/layrz.bravepages.com
Jul  7 16:47:27 titan2 kernel: nfsd-fh: found a name that I didn't =3D
expect: yp/layrz.bravepages.com
Jul  7 16:47:27 titan2 kernel: nfsd-fh: found a name that I didn't =3D
expect: er.bravepages.com/b
Jul  7 16:47:31 titan2 last message repeated 19 times
Jul  7 16:47:31 titan2 kernel: nfsd-fh: found a name that I didn't =3D
expect: yp/layrz.bravepages.com
Jul  7 16:47:31 titan2 last message repeated 3 times
Jul  7 16:47:31 titan2 kernel: nfsd-fh: found a name that I didn't =3D
expect: er.bravepages.com/b
Jul  7 16:47:39 titan2 last message repeated 21 times
Jul  7 16:49:15 titan2 kernel: nfsd-fh: found a name that I didn't =3D
expect: yp/layrz.bravepages.com
MJul  7 16:49:37 titan2 last message repeated 23 times
Jul  7 16:51:28 titan2 kernel: nfsd-fh: found a name that I didn't =3D
expect: la/de
Jul  7 16:51:28 titan2 last message repeated 2 times
Jul  7 16:51:35 titan2 kernel: nfsd-fh: found a name that I didn't =3D
expect: ki/grl.envy.

Thanks,
Matt


------=_NextPart_000_26C1_01C22658.FB8AF280
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
<DIV>Anyone know what might cause these in a 2.4.18 kernel (No patches)=20
<BR>Redhat 7.2, on an NFS server exporting a reiser file system.<BR>I am =
getting=20
tons of these errors.&nbsp;&nbsp; The files exist when I go to see =
<BR>them on=20
the server, but they don't exist when I try to see them from the =
client?</DIV>
<DIV>I get a file exists on the client when I try to go to the directory =
that is=20
shown</DIV>
<DIV>in the error on the client machine.&nbsp;&nbsp; If I then go back =
to the=20
server make a new</DIV>
<DIV>directory and move the files from the "broken" directoy to the new =
one and=20
then</DIV>
<DIV>delete the "broken" directory and then mv the new directory to the =
old=20
directory</DIV>
<DIV>name everything works.&nbsp; I keep getting new errors for new =
directories=20
constantly</DIV>
<DIV>though.<BR><BR>Any ideas.&nbsp; Also, are Tronds nfsall patches for =
the NFS=20
clients only, or =3D<BR>are they some patches that I should have for the =
server in=20
2.4.18?<BR><BR>Jul&nbsp; 7 16:47:27 titan2 last message repeated 4=20
times<BR>Jul&nbsp; 7 16:47:27 titan2 kernel: nfsd-fh: found a name that =
I didn't=20
=3D<BR>expect: yp/layrz.bravepages.com<BR>Jul&nbsp; 7 16:47:27 titan2 =
kernel:=20
nfsd-fh: found a name that I didn't =3D<BR>expect:=20
yp/layrz.bravepages.com<BR>Jul&nbsp; 7 16:47:27 titan2 kernel: nfsd-fh: =
found a=20
name that I didn't =3D<BR>expect: er.bravepages.com/b<BR>Jul&nbsp; 7 =
16:47:31=20
titan2 last message repeated 19 times<BR>Jul&nbsp; 7 16:47:31 titan2 =
kernel:=20
nfsd-fh: found a name that I didn't =3D<BR>expect:=20
yp/layrz.bravepages.com<BR>Jul&nbsp; 7 16:47:31 titan2 last message =
repeated 3=20
times<BR>Jul&nbsp; 7 16:47:31 titan2 kernel: nfsd-fh: found a name that =
I didn't=20
=3D<BR>expect: er.bravepages.com/b<BR>Jul&nbsp; 7 16:47:39 titan2 last =
message=20
repeated 21 times<BR>Jul&nbsp; 7 16:49:15 titan2 kernel: nfsd-fh: found =
a name=20
that I didn't =3D<BR>expect: yp/layrz.bravepages.com<BR>MJul&nbsp; 7 =
16:49:37=20
titan2 last message repeated 23 times<BR>Jul&nbsp; 7 16:51:28 titan2 =
kernel:=20
nfsd-fh: found a name that I didn't =3D<BR>expect: la/de<BR>Jul&nbsp; 7 =
16:51:28=20
titan2 last message repeated 2 times<BR>Jul&nbsp; 7 16:51:35 titan2 =
kernel:=20
nfsd-fh: found a name that I didn't =3D<BR>expect:=20
ki/grl.envy.<BR><BR>Thanks,<BR>Matt<BR></DIV></BODY></HTML>

------=_NextPart_000_26C1_01C22658.FB8AF280--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Oh, it's good to be a geek.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
