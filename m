From: "Topp, Kenneth" <Kenneth.Topp@gs.com>
Subject: cannot remove silly renamed files
Date: Tue, 19 Sep 2006 13:40:38 -0400
Message-ID: <5FD3925640200143AA51A2F603FEB86A02258293@gsmbnmp19es.firmwide.corp.gs.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0249005589=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GPjaS-0004wL-3I
	for nfs@lists.sourceforge.net; Tue, 19 Sep 2006 10:40:48 -0700
Received: from mxcd01.gs.com ([12.47.209.190])
	by mail.sourceforge.net with esmtps (TLSv1:RC4-SHA:128) (Exim 4.44)
	id 1GPjaQ-0008Ht-Jn
	for nfs@lists.sourceforge.net; Tue, 19 Sep 2006 10:40:49 -0700
Received: from gsmbnmp19es.firmwide.corp.gs.com
	(gsmbnmp19es.firmwide.corp.gs.com [148.86.24.118]) by
	insvsod01.inz.gs.com with ESMTP for nfs@lists.sourceforge.net;
	Tue, 19 Sep 2006 13:40:40 -0400
To: <nfs@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.

--===============0249005589==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C6DC12.B806E979"

This is a multi-part message in MIME format.

------_=_NextPart_001_01C6DC12.B806E979
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi,

I've searched the archive but didn't find anything related.  2.6 doesn't
allow you to delete .nfsXXX (silly renamed) files from the host that has
it open.  2.4 and solaris 2.X has allowed one to shoot oneself in the
foot.

Can we update the code to do a rename twice then allow removal rather
then blocking it indefinitely?  The current code changes breaks expect
commands like "/bin/rm -rf dir/", which I'm sure is defined somewhere in
POSIX.

Ken

------_=_NextPart_001_01C6DC12.B806E979
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7233.69">
<TITLE>cannot remove silly renamed files</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/rtf format -->

<P><FONT SIZE=3D2 FACE=3D"Courier New">Hi,</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Courier New">I've searched the archive but =
didn't find anything related.&nbsp; 2.6 doesn't allow you to delete =
.nfsXXX (silly renamed) files from the host that has it open.&nbsp; 2.4 =
and solaris 2.X has allowed one to shoot oneself in the foot.</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Courier New">Can we update the code to do a =
rename twice then allow removal rather then blocking it =
indefinitely?&nbsp; The current code changes breaks expect commands like =
&quot;/bin/rm -rf dir/&quot;, which I'm sure is defined somewhere in =
POSIX.</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Courier New">Ken</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C6DC12.B806E979--


--===============0249005589==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0249005589==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0249005589==--
