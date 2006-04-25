From: "Mosher, Chuck C." <Chuck.C.Mosher@conocophillips.com>
Subject: Parallel I/O with NFS
Date: Tue, 25 Apr 2006 08:09:30 -0500
Message-ID: <D11A31EB48BE1143B78A4C284CD80D4803D0EC99@HOEXMB2.conoco.net>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C66869.7CF7FE16"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FYNIV-0003dn-5U
	for nfs@lists.sourceforge.net; Tue, 25 Apr 2006 06:09:43 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FYNIV-0006tg-2x
	for nfs@lists.sourceforge.net; Tue, 25 Apr 2006 06:09:43 -0700
Received: from mailman1.ppco.com ([138.32.33.10])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1FYNIT-0008HJ-DD
	for nfs@lists.sourceforge.net; Tue, 25 Apr 2006 06:09:43 -0700
Received: from bvlextrd2.conoco.net (bvlextrd2.conoco.net [158.139.203.93])
	by mailman1.ppco.com (Switch-3.1.8/Switch-3.1.7) with ESMTP id k3PD9Wmd022614
	for <nfs@lists.sourceforge.net>; Tue, 25 Apr 2006 08:09:32 -0500
Received: from bvlexbh1.conoco.net (bvlexbh1.conoco.net [138.32.45.41])
	by mail1.ppco.com (Switch-3.1.8/Switch-3.1.7) with ESMTP id k3PD9VMd003628
	for <nfs@lists.sourceforge.net>; Tue, 25 Apr 2006 08:09:31 -0500
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

------_=_NextPart_001_01C66869.7CF7FE16
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Gents,

A common pattern in parallel computing is to have a number of tasks
(from 2-1000) open the same file, and each writes a non-overlapping
section of the file.  As the write proceeds, "strips" of the file are
written by each task, with holes in between tasks, until the complete
file has been written.

We've been using this pattern for may years. We recently began testing
Fedora Core 4, and are now seeing "holes" left in these files. Reading
the archives for the "Data coherency trouble with multiple clients,
on2.6.14-rc5", it seems to me that I have a similar problem. I've seen
references to using "O_DIRECT" to solve this problem, but it is not
clear to me how this would work. Would I have to restructure my code to
write data on aligned 512 byte blocks ?
Our current applications are written in Java, and use the
java.nio.channels package.  I'd like to stay "pure java" if at all
possible. I can write a native method to access the file descriptor for
the java channel, but that would be a bit of a hack. Is there a way I
can open or mount the file to have it revert to the behavior in earlier
releases ?
Do you have any other recommendations on how to make this pattern work,
in particular with Java ?
Thanks,
Chuck Mosher
www.javaseis.org

------_=_NextPart_001_01C66869.7CF7FE16
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7226.0">
<TITLE>Parallel I/O with NFS</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/rtf format -->

<P><FONT SIZE=3D2 FACE=3D"Arial">Gents,</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">A common pattern in parallel computing =
is to have a number of tasks (from 2-1000) open the same file, and each =
writes a non-overlapping section of the file.&nbsp; As the write =
proceeds, &quot;strips&quot; of the file are written by each task, with =
holes in between tasks, until the complete file has been =
written.</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">We've been using this pattern for may =
years. We recently began testing Fedora Core 4, and are now seeing =
&quot;holes&quot; left in these files. Reading the archives for =
the</FONT><FONT SIZE=3D2 FACE=3D"Arial"> &quot;Data coherency trouble =
with multiple clients, on2.6.14-rc5&quot;, it seems to me that I have a =
similar problem. I've seen references to using &quot;O_DIRECT&quot; to =
solve this problem, but it is not clear to me how this would work. Would =
I have to restructure my code to write data on aligned 512 byte blocks =
?</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">Our current applications are written in =
Java, and use the java.nio.channels package.&nbsp; I'd like to stay =
&quot;pure java&quot; if at all possible. I can write a native method to =
access the file descriptor for the java channel, but that would be a bit =
of a hack. Is there a way I can open or mount the file to have it revert =
to the behavior in earlier releases ?</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">Do you have any other recommendations =
on how to make this pattern work, in particular with Java ?</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">Thanks,</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">Chuck Mosher</FONT>

<BR><A HREF=3D"file://www.javaseis.org"><U><FONT COLOR=3D"#0000FF" =
SIZE=3D2 FACE=3D"Arial">www.javaseis.org</FONT></U></A>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C66869.7CF7FE16--


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
