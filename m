From: "Matt Heaton" <admin@0catch.com>
Subject: Millions of files and directory caching.
Date: Mon, 21 Oct 2002 00:06:26 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <086801c278c7$fd7e19c0$6801a8c0@c1886657a>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0865_01C27895.B2B12810"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc51.attbi.com ([204.127.198.38])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 183Vhx-0006Zu-00
	for <nfs@lists.sourceforge.net>; Sun, 20 Oct 2002 23:06:33 -0700
Received: from c1886657a ([12.255.25.93]) by rwcrmhc51.attbi.com
          (InterMail vM.4.01.03.27 201-229-121-127-20010626) with SMTP
          id <20021021060627.GXNT18217.rwcrmhc51.attbi.com@c1886657a>
          for <nfs@lists.sourceforge.net>; Mon, 21 Oct 2002 06:06:27 +0000
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

------=_NextPart_000_0865_01C27895.B2B12810
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

I run a hosting service that hosts about 700,000 websites.  We have 2 =
NFS servers running Redhat 7.2 (2.4.18 custom kernal, no
nfs patches).  The servers are 850 GIGS each (IDE RAID 5). THe clients =
are all 7.2 Redhat with custom 2.4.18 kernels on them.  My question is =
this.  I believe lookups/attribs on the files and directories are =
slowing down performance considerably because we literally have 4-5 =
million files on each nfs server that we export.  One of the NFS servers =
is running EXT3 and the other is XFS.  Both work ok, but under heavy =
loads the clients die because the server can't export stuff fast enough. =
 The total bandwidth out of each NFS server is LESS than 10 Mbit.  The =
trouble is that I am serving a bunch of SMALL files.  Either I am =
running out of seek time on my boxes (IDE Raid 850 GIGS per server), or =
it is taking forever to find the files.=20

Here are my questions.

1) Can I increase the cache on the client side to hold the entire =
directory structure of both NFS servers?

2) How can I tell if I am just maxing the seek time out on my NFS =
server?

3) Each NFS server serves about 60-100 files per second.  Is this too =
many per second?  Could I possibly be maxing
out seek time on the NFS servers?  My IDE Raid card is the 3ware 750 =
with 8 individual IDE ports on it.

4) Is there anything like cachefs being developed for linux??  Any other =
suggestions for persistent client caching for NFS?
Free or commercial is fine.

Thanks for your answers to some or all of my questions.

Matt



------=_NextPart_000_0865_01C27895.B2B12810
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2719.2200" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>I run a hosting service that hosts =
about 700,000=20
websites.&nbsp; We have 2 NFS servers running Redhat 7.2 (2.4.18 custom =
kernal,=20
no</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>nfs patches).&nbsp; The servers are 850 =
GIGS each=20
(IDE RAID 5). THe clients are all 7.2 Redhat with custom 2.4.18 kernels =
on=20
them.&nbsp; My question is this.&nbsp; I believe lookups/attribs on the=20
</FONT><FONT face=3DArial size=3D2>files and directories are slowing =
down=20
performance considerably because we literally have 4-5 million files on =
each nfs=20
server that we export.&nbsp; One of the NFS servers is running EXT3 and =
the=20
other is XFS.&nbsp; Both work ok, but under heavy loads the clients die =
because=20
the server can't export stuff fast enough.&nbsp; The total bandwidth out =
of each=20
NFS server is LESS than 10 Mbit.&nbsp; The trouble is that I am serving =
a bunch=20
of SMALL files.&nbsp; Either I am running out of seek time on my boxes =
(IDE Raid=20
850 GIGS per server), or it is taking forever to find the files. =
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Here are my questions.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>1) Can I increase the cache on the =
client side to=20
hold the entire directory structure of both NFS servers?</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>2) How can I tell if I am just maxing =
the seek time=20
out on my NFS server?</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>3) Each NFS server serves about 60-100 =
files per=20
second.&nbsp; Is this too many per second?&nbsp; Could I possibly be=20
maxing</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>out seek time on the NFS servers?&nbsp; =
My IDE Raid=20
card is the 3ware 750 with 8 individual IDE ports on it.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>4) Is there anything like cachefs being =
developed=20
for linux??&nbsp; Any other suggestions for persistent client caching =
for=20
NFS?</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Free or commercial is =
fine.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Thanks for your answers to some or all =
of my=20
questions.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Matt</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV></BODY></HTML>

------=_NextPart_000_0865_01C27895.B2B12810--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
