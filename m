From: "Jeremy Kusnetz" <JKusnetz@nrtc.org>
Subject: Chrooted BIND broke on NFS server between kernel 2.4.21 and 2.4.22
Date: Fri, 12 Dec 2003 13:36:41 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F7F4B5EA9EBD414D8A0091E80389450569D3C5@exchange.nrtc.coop>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C3C0DE.E26BC00C"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AUs9h-0001BQ-R0
	for nfs@lists.sourceforge.net; Fri, 12 Dec 2003 10:36:49 -0800
Received: from outmail.nrtc.org ([204.145.144.17] helo=exchange.nrtc.coop)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AUs9h-0006OA-Du
	for nfs@lists.sourceforge.net; Fri, 12 Dec 2003 10:36:49 -0800
To: <nfs@lists.sourceforge.net>
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

------_=_NextPart_001_01C3C0DE.E26BC00C
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hello,

I have a cluster of machines running BIND that is chrooted on an NFS =
mounted partition.

I recently upgraded both my NFS server and clients to 2.4.23 due to the =
security issues.  I was running 2.4.20 for my NFS server.

After doing this I found I could no longer start BIND, I would get the =
following error in syslog.

Dec 12 18:28:17 rs0 named[409]: errno2result.c:109: unexpected error:
Dec 12 18:28:17 rs0 named[409]: unable to convert errno to isc_result: =
116: Stale NFS file handle
Dec 12 18:28:17 rs0 named[409]: none:0: open: /etc/named.conf: =
unexpected error
Dec 12 18:28:17 rs0 named[409]: loading configuration: unexpected error
Dec 12 18:28:17 rs0 named[409]: exiting (due to fatal error)

If I was cded into the chrooted etc directory I would get the following =
error after doing an ls
/bin/ls: .: Stale NFS file handle

If I cd out and back into the etc directory all works as expected, until =
I try to start bind again.

I tried downgrading my NFS server back to 2.4.20 and I was able to start =
bind as expected.  Next I tried 2.4.22 and got the same stale NFS handle =
problem.  I then tried 2.4.21 and I was able to start bind as expected.

So there must have been some change between 2.4.21 and 2.4.22 that broke =
this functionality.  Any ideas?

------_=_NextPart_001_01C3C0DE.E26BC00C
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.6944.0">
<TITLE>Chrooted BIND broke on NFS server between kernel 2.4.21 and =
2.4.22</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/rtf format -->

<P><FONT SIZE=3D2 FACE=3D"Arial">Hello,</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">I have a cluster of machines running =
BIND that is chrooted on an NFS mounted partition.</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">I recently upgraded both my NFS server =
and clients to 2.4.23 due to the security issues.&nbsp; I was running =
2.4.20 for my NFS server.</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">After doing this I found I could no =
longer start BIND, I would get the following error in syslog.</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">Dec 12 18:28:17 rs0 named[409]: =
errno2result.c:109: unexpected error:</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">Dec 12 18:28:17 rs0 named[409]: unable =
to convert errno to isc_result: 116: Stale NFS file handle</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">Dec 12 18:28:17 rs0 named[409]: =
none:0: open: /etc/named.conf: unexpected error</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">Dec 12 18:28:17 rs0 named[409]: =
loading configuration: unexpected error</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">Dec 12 18:28:17 rs0 named[409]: =
exiting (due to fatal error)</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">If I was cded into the chrooted etc =
directory I would get the following error after doing an ls</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">/bin/ls: .: Stale NFS file =
handle</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">If I cd out and back into the etc =
directory all works as expected, until I try to start bind again.</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">I tried downgrading my NFS server back =
to 2.4.20 and I was able to start bind as expected.&nbsp; Next I tried =
2.4.22 and got the same stale NFS handle problem.&nbsp; I then tried =
2.4.21 and I was able to start bind as expected.</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">So there must have been some change =
between 2.4.21 and 2.4.22 that broke this functionality.&nbsp; Any =
ideas?</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C3C0DE.E26BC00C--


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
