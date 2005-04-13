From: <eh@dataconnection.com>
Subject: clear_locks on Linux?
Date: Wed, 13 Apr 2005 11:28:21 +0100
Message-ID: <9E621559095AA746B22B21CD4FAF99A50A4E94@EDINMAIL1.datcon.co.uk>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C54013.83E47326"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DLf6w-0001ZL-V2
	for nfs@lists.sourceforge.net; Wed, 13 Apr 2005 03:28:42 -0700
Received: from smtp.dataconnection.com ([192.91.191.4])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DLf6f-0002Yw-LX
	for nfs@lists.sourceforge.net; Wed, 13 Apr 2005 03:28:42 -0700
To: <nfs@lists.sourceforge.net>
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

------_=_NextPart_001_01C54013.83E47326
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Solaris has a command clear_locks, to remove locks held by a specific =
remote host.

Does Linux have a similar command?  I'm having trouble finding one.  I =
have very occasionally seen a situation where a client crashes hard, =
leaving a file lock held on an NFS server, and I want to have a way to =
remove it.

Alternatively, could I achieve a similar effect by restarting lockd to =
encourage all active clients to reacquire their locks?

Edward.

------_=_NextPart_001_01C54013.83E47326
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7226.0">
<TITLE>clear_locks on Linux?</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/rtf format -->

<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">Solaris has a command =
clear_locks, to remove locks held by a specific remote host.</FONT>
</P>

<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">Does Linux have a =
similar command?&nbsp; I'm having trouble finding one.&nbsp; I have very =
occasionally seen a situation where a client crashes hard, leaving a =
file lock held on an NFS server, and I want to have a way to remove =
it.</FONT></P>

<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">Alternatively, could =
I achieve a similar effect by restarting lockd to encourage all active =
clients to reacquire their locks?</FONT></P>

<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">Edward.</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C54013.83E47326--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
