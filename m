From: "Edward Hibbert" <Edward.Hibbert@dataconnection.com>
Subject: Stale NFS mounts
Date: Tue, 1 Nov 2005 10:01:45 -0000
Message-ID: <9E621559095AA746B22B21CD4FAF99A54E3126@EDINMAIL1.ad.datcon.co.uk>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C5DECB.448B3629"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EWsxn-0004SB-GU
	for nfs@lists.sourceforge.net; Tue, 01 Nov 2005 02:01:55 -0800
Received: from smtp2.dataconnection.com ([192.91.191.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EWsxl-000534-6i
	for nfs@lists.sourceforge.net; Tue, 01 Nov 2005 02:01:55 -0800
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

------_=_NextPart_001_01C5DECB.448B3629
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

I'm having a problem with stale mount points.

What we see is that under load all the clients get stale mount points
pretty much simultaneously.  We can rule out various things:
*	There's no indication that the NFS server has rebooted (uptime
indicates it hasn't).
*	There's nothing in /var/log/messages to indicate a problem. =20
*	The nfsd processes have a start time that matches uptime, so
they haven't restarted. =20
*	We know that the directories we're mounting are not getting
renamed/deleted.

We can cure this by a client reboot, but obviously that's massively
disruptive.

We're wondering whether this is related to nested mounts - the clients
mount a top-level directory, and then subdirectories within it.  There's
circumstantial but not conclusive evidence that we've only seen stale
handles on nested mounts.

So:
*	Are nested mounts safe to use?
*	Are there any common causes of stale mounts which I might not be
aware of?
*	Any suggestions for how to investigate this further?

The NFS server is a Fedora system with kernel 2.6.9-1.667smp.  The NFS
clients are RedHat AS 4.0 2.6.9-11.ELsmp.  Do ask for more details if
needed.

Regards,

Edward.

------_=_NextPart_001_01C5DECB.448B3629
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7232.25">
<TITLE>Stale NFS mounts</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/rtf format -->

<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">I'm having a problem =
with stale mount points.</FONT>
</P>

<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">What we see is that =
under load all the clients get stale mount points pretty much =
simultaneously.&nbsp; We can rule out various things:</FONT></P>

<UL>
<LI><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">There's no =
indication that the NFS server has rebooted (uptime indicates it =
hasn't).</FONT></LI>

<LI><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">There's nothing in =
/var/log/messages to indicate a problem.&nbsp; </FONT></LI>

<LI><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">The nfsd processes =
have a start time that matches uptime, so they haven't restarted.&nbsp; =
</FONT></LI>

<LI><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">We know that the =
directories we're mounting are not getting renamed/deleted.</FONT></LI>
<BR>
</UL>
<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">We can cure this by a =
client reboot, but obviously that's massively disruptive.</FONT>
</P>

<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">We're wondering =
whether this is related to nested mounts - the clients mount a top-level =
directory, and then subdirectories within it.&nbsp; There's =
circumstantial but not conclusive evidence that we've only seen stale =
handles on nested mounts.</FONT></P>

<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">So:</FONT>

<UL>
<LI><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">Are nested mounts =
safe to use?</FONT></LI>

<LI><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">Are there any common =
causes of stale mounts which I might not be aware of?</FONT></LI>

<LI><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">Any suggestions for =
how to investigate this further?</FONT></LI>
<BR>
</UL>
<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">The NFS server is a =
Fedora system with kernel 2.6.9-1.667smp.&nbsp; The NFS clients are =
RedHat AS 4.0 2.6.9-11.ELsmp.&nbsp; Do ask for more details if =
needed.</FONT></P>

<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">Regards,</FONT>
</P>

<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">Edward.</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C5DECB.448B3629--


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
