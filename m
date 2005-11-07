From: "Vijay Khemka -X (vkhemka - WIPRO at Cisco)" <vkhemka@cisco.com>
Subject: Cross compiling for MIPS
Date: Tue, 8 Nov 2005 02:33:08 +0530
Message-ID: <1291FDD1356B0F4C9A1AA94C61D49077A9680D@xmb-blr-418.apac.cisco.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C5E3DE.A97D4EC6"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EZE9G-0007fk-R9
	for nfs@lists.sourceforge.net; Mon, 07 Nov 2005 13:03:26 -0800
Received: from ind-iport-1.cisco.com ([64.104.129.195])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EZE9F-0004V1-61
	for nfs@lists.sourceforge.net; Mon, 07 Nov 2005 13:03:26 -0800
Received: from xbh-blr-411.apac.cisco.com (xbh-blr-411.cisco.com [64.104.140.150])
	by india-core-1.cisco.com (8.12.10/8.12.6) with ESMTP id jA7L36xr010529
	for <nfs@lists.sourceforge.net>; Mon, 7 Nov 2005 21:03:07 GMT
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

------_=_NextPart_001_01C5E3DE.A97D4EC6
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi,
I have cross compiled nfs package for MIPS environment. There are two
issue..
1. when I run mountd daemon, I get error failed to bind -22
2. When I yun rquotad then I get segmentation fault.
=20
Please let me know what are faults can be..
=20
Regards
-Vijay
=20

------_=_NextPart_001_01C5E3DE.A97D4EC6
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<META content=3D"MSHTML 6.00.2900.2180" name=3DGENERATOR></HEAD>
<BODY>
<DIV><SPAN class=3D979325720-07112005><FONT face=3DArial=20
size=3D2>Hi,</FONT></SPAN></DIV>
<DIV><SPAN class=3D979325720-07112005><FONT face=3DArial =
size=3D2>I&nbsp;have cross=20
compiled nfs package&nbsp;for MIPS environment.&nbsp;There are two=20
issue..</FONT></SPAN></DIV>
<DIV><SPAN class=3D979325720-07112005><FONT face=3DArial size=3D2>1. =
when I run mountd=20
daemon, I get error failed to bind -22</FONT></SPAN></DIV>
<DIV><SPAN class=3D979325720-07112005><FONT face=3DArial size=3D2>2. =
When I yun=20
rquotad then I get segmentation fault.</FONT></SPAN></DIV>
<DIV><SPAN class=3D979325720-07112005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D979325720-07112005><FONT face=3DArial size=3D2>Please =
let me know=20
what are faults can be..</FONT></SPAN></DIV>
<DIV>&nbsp;</DIV>
<DIV align=3Dleft><FONT face=3DArial size=3D2>Regards</FONT></DIV>
<DIV align=3Dleft><FONT face=3DArial size=3D2>-Vijay</FONT></DIV>
<DIV>&nbsp;</DIV></BODY></HTML>

------_=_NextPart_001_01C5E3DE.A97D4EC6--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
