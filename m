From: "Edward Hibbert" <Edward.Hibbert@dataconnection.com>
Subject: RE: Periodic NFS client cache flushing?
Date: Thu, 17 Nov 2005 21:14:34 -0000
Message-ID: <9E621559095AA746B22B21CD4FAF99A52CDBB2@EDINMAIL1.ad.datcon.co.uk>
References: <9E621559095AA746B22B21CD4FAF99A5573A1D@EDINMAIL1.ad.datcon.co.uk><1132260159.8025.16.camel@lade.trondhjem.org><9E621559095AA746B22B21CD4FAF99A52CDBB1@EDINMAIL1.ad.datcon.co.uk> <1132261979.8025.26.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C5EBBB.FC9478CD"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ecr6D-0002Qn-EW
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 13:15:17 -0800
Received: from smtp2.dataconnection.com ([192.91.191.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Ecr6C-00038y-Vv
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 13:15:17 -0800
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Sender: nfs-admin@lists.sourceforge.net
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

------_=_NextPart_001_01C5EBBB.FC9478CD
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Thanks, that's the kind of thing I was looking for.  I'll have a careful =
play and see if it affects what I'm seeing.

Cheers,

Edward,


-----Original Message-----
From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
Sent: Thu 17/11/2005 21:12
To: Edward Hibbert
Cc: nfs@lists.sourceforge.net
Subject: RE: [NFS] Periodic NFS client cache flushing?
=20
On Thu, 2005-11-17 at 20:47 +0000, Edward Hibbert wrote:
> Sorry, I wasn't clear.  When I said "is there any code", what I meant
> was code in the NFS client.
>=20
> So what I mean is, if I write data without explicitly flushing it,
> does it get flushed to the server periodically, e.g. every 30s, or
> gradually?

The closest thing you will come to something like that is the kupdate
daemon, which runs every /proc/sys/vm/dirty_writeback_centisecs 1/100 of
a second. That constant applies to the whole kernel, though, so you
might want to beware of that before deciding to tune it for NFS.

Cheers,
  Trond



------_=_NextPart_001_01C5EBBB.FC9478CD
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7638.1">
<TITLE>RE: [NFS] Periodic NFS client cache flushing?</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/plain format -->

<P><FONT SIZE=3D2>Thanks, that's the kind of thing I was looking =
for.&nbsp; I'll have a careful play and see if it affects what I'm =
seeing.<BR>
<BR>
Cheers,<BR>
<BR>
Edward,<BR>
<BR>
<BR>
-----Original Message-----<BR>
From: Trond Myklebust [<A =
HREF=3D"mailto:trond.myklebust@fys.uio.no">mailto:trond.myklebust@fys.uio=
.no</A>]<BR>
Sent: Thu 17/11/2005 21:12<BR>
To: Edward Hibbert<BR>
Cc: nfs@lists.sourceforge.net<BR>
Subject: RE: [NFS] Periodic NFS client cache flushing?<BR>
<BR>
On Thu, 2005-11-17 at 20:47 +0000, Edward Hibbert wrote:<BR>
&gt; Sorry, I wasn't clear.&nbsp; When I said &quot;is there any =
code&quot;, what I meant<BR>
&gt; was code in the NFS client.<BR>
&gt;<BR>
&gt; So what I mean is, if I write data without explicitly flushing =
it,<BR>
&gt; does it get flushed to the server periodically, e.g. every 30s, =
or<BR>
&gt; gradually?<BR>
<BR>
The closest thing you will come to something like that is the =
kupdate<BR>
daemon, which runs every /proc/sys/vm/dirty_writeback_centisecs 1/100 =
of<BR>
a second. That constant applies to the whole kernel, though, so you<BR>
might want to beware of that before deciding to tune it for NFS.<BR>
<BR>
Cheers,<BR>
&nbsp; Trond<BR>
<BR>
<BR>
</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C5EBBB.FC9478CD--


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
