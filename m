From: <kalyan.chakravarti@wipro.com>
Subject: client not able to see the nfs mounted FS
Date: Mon, 21 Nov 2005 17:27:19 +0530
Message-ID: <BC5E0A18A8CCFD41A74E0C19FF7B78EE01739D@blr-k1-msg.wipro.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C5EE92.BA73A0B7"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EeAIh-00012C-Va
	for nfs@lists.sourceforge.net; Mon, 21 Nov 2005 03:57:35 -0800
Received: from wip-ec-wd.wipro.com ([203.91.193.32])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EeAIf-0002eA-2z
	for nfs@lists.sourceforge.net; Mon, 21 Nov 2005 03:57:35 -0800
Received: from wip-ec-wd.wipro.com (localhost.wipro.com [127.0.0.1])
	by localhost (Postfix) with ESMTP id C50B3205FD
	for <nfs@lists.sourceforge.net>; Mon, 21 Nov 2005 17:14:20 +0530 (IST)
Received: from blr-ec-bh01.wipro.com (blr-ec-bh01.wipro.com [10.201.50.91])
	by wip-ec-wd.wipro.com (Postfix) with ESMTP id A6488205F3
	for <nfs@lists.sourceforge.net>; Mon, 21 Nov 2005 17:14:20 +0530 (IST)
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

------_=_NextPart_001_01C5EE92.BA73A0B7
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi,
   I am trying to load a broadcom switch from a linux m/c. I have
created entries in the file "/etc/exports" linux m/c which directories
are to be shared/exported. I am able to see the shared folder in the
output of "/usr/sbin/exportfs". But i don't see a entry being created in
"/var/lib/nfs/xtab" file. I am not able to nail down the problem.
=20
Thanks in Advance.
=20
Regards,
kalyan =20

------_=_NextPart_001_01C5EE92.BA73A0B7
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<META content=3D"MSHTML 6.00.2900.2769" name=3DGENERATOR></HEAD>
<BODY>
<DIV><SPAN class=3D805314611-21112005><FONT face=3DArial=20
size=3D2>Hi,</FONT></SPAN></DIV>
<DIV><SPAN class=3D805314611-21112005><FONT face=3DArial =
size=3D2>&nbsp;&nbsp; I am=20
trying to load a broadcom switch from a linux m/c. I=20
have&nbsp;created&nbsp;entries in the file "/etc/exports" linux m/c =
which=20
directories are to be shared/exported. I am able to see the shared=20
folder&nbsp;in&nbsp;the output of "/usr/sbin/exportfs". But i don't see =
a=20
entry&nbsp;being created in "/var/lib/nfs/xtab" file. I am not able =
to&nbsp;nail=20
down the&nbsp;problem.</FONT></SPAN></DIV>
<DIV><SPAN class=3D805314611-21112005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D805314611-21112005><FONT face=3DArial size=3D2>Thanks =
in=20
Advance.</FONT></SPAN></DIV>
<DIV><SPAN class=3D805314611-21112005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D805314611-21112005><FONT face=3DArial=20
size=3D2>Regards,</FONT></SPAN></DIV>
<DIV><SPAN class=3D805314611-21112005><FONT face=3DArial=20
size=3D2>kalyan&nbsp;&nbsp;</FONT></SPAN></DIV></BODY></HTML>

------_=_NextPart_001_01C5EE92.BA73A0B7--


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
