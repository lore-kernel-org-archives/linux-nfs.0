From: "Matt Heaton" <admin@0catch.com>
Subject: XFS for NFS
Date: Fri, 2 Aug 2002 18:43:42 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <041e01c23a86$d0f3c320$6701a8c0@c1886657a>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_041B_01C23A54.862264A0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc52.attbi.com ([216.148.227.88])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17an1K-0005Lb-00
	for <nfs@lists.sourceforge.net>; Fri, 02 Aug 2002 17:43:50 -0700
Received: from c1886657a ([12.255.25.93]) by rwcrmhc52.attbi.com
          (InterMail vM.4.01.03.27 201-229-121-127-20010626) with SMTP
          id <20020803004344.CXBL22139.rwcrmhc52.attbi.com@c1886657a>
          for <nfs@lists.sourceforge.net>; Sat, 3 Aug 2002 00:43:44 +0000
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

------=_NextPart_000_041B_01C23A54.862264A0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

A while the following post was made about XFS and that the problem was =
fixed in the 2.4.19 tree of the kernel.
My question is do I have to use 2.4.19rc5 on the server or the client or =
both to fix the problem.  Also is the 1.x version
of nfs utils for the client or server or both?

Thanks,
Matt




>We have noticed a problem with a couple of our NFS servers (running
>RedHat 7.2 with a stock 2.4.18 kernel with XFS v1.1) whereby NFS access
>slows to a crawl or stalls.
>
>The exported filesystem(s) are XFS with 8 nfsd's running - when we have
>the problem the load average is about 8 - but CPU usage, disk access =
and
>network traffic are minimal.
>
>I found, by accident, that running the command 'sync' appears to 'fix'
>the situation...
>
>I'm not sure if this is an XFS or NFS related problem (hence posting to
>both lists).

XFS.  2.4.18 would sometimes get into a situation where two XFS
operations were waiting on locks (not deadlocked) and nothing was
moving.  Performing some other disk activity such as sync would get
things moving again.

AFAICT this is fixed in the XFS CVS tree, against 2.4.19-rc1.

------=_NextPart_000_041B_01C23A54.862264A0
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
<DIV><FONT face=3DArial size=3D2>A while the following post was made =
about XFS and=20
that the problem was fixed in the 2.4.19 tree of the =
kernel.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>My question is do I have to use =
2.4.19rc5 on the=20
server or the client or both to fix the problem.&nbsp; Also is the 1.x=20
version</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>of nfs utils for the client or server =
or=20
both?</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Thanks,<BR>Matt</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><BR>&gt;We have noticed a problem with a couple of our NFS servers=20
(running<BR>&gt;RedHat 7.2 with a stock 2.4.18 kernel with XFS v1.1) =
whereby NFS=20
access<BR>&gt;slows to a crawl or stalls.<BR>&gt;<BR>&gt;The exported=20
filesystem(s) are XFS with 8 nfsd's running - when we have<BR>&gt;the =
problem=20
the load average is about 8 - but CPU usage, disk access =
and<BR>&gt;network=20
traffic are minimal.<BR>&gt;<BR>&gt;I found, by accident, that running =
the=20
command 'sync' appears to 'fix'<BR>&gt;the =
situation...<BR>&gt;<BR>&gt;I'm not=20
sure if this is an XFS or NFS related problem (hence posting =
to<BR>&gt;both=20
lists).<BR><BR>XFS.&nbsp; 2.4.18 would sometimes get into a situation =
where two=20
XFS<BR>operations were waiting on locks (not deadlocked) and nothing=20
was<BR>moving.&nbsp; Performing some other disk activity such as sync =
would=20
get<BR>things moving again.<BR><BR>AFAICT this is fixed in the XFS CVS =
tree,=20
against 2.4.19-rc1.</DIV></BODY></HTML>

------=_NextPart_000_041B_01C23A54.862264A0--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
