From: "David Sullivan" <david.sullivan@activant.com>
Subject: NFS reliability in Enterprise Environment
Date: Wed, 1 Feb 2006 16:01:57 -0600
Message-ID: <5573EF758F632B43A91FE1A01B6AC3D401B77D6B@exch3-dc-aus.northamerica.corporate-domain.net>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C6277B.1EF3E0BE"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F4Q3G-0003yY-2M
	for nfs@lists.sourceforge.net; Wed, 01 Feb 2006 14:02:10 -0800
Received: from outbound-ash.frontbridge.com ([206.16.192.249] helo=outbound1-ash-R.bigfish.com)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1F4Q3D-00061V-Np
	for nfs@lists.sourceforge.net; Wed, 01 Feb 2006 14:02:10 -0800
Received: from outbound1-ash.bigfish.com (localhost.localdomain [127.0.0.1])
	by outbound1-ash-R.bigfish.com (Postfix) with ESMTP id 8800E70CA31
	for <nfs@lists.sourceforge.net>; Wed,  1 Feb 2006 22:02:01 +0000 (UTC)
Received: from mail27-ash-R.bigfish.com (unknown [172.18.2.1])
	by outbound1-ash.bigfish.com (Postfix) with ESMTP id 86E2670C985
	for <nfs@lists.sourceforge.net>; Wed,  1 Feb 2006 22:02:01 +0000 (UTC)
Received: from mail27-ash.bigfish.com (localhost.localdomain [127.0.0.1])
	by mail27-ash-R.bigfish.com (Postfix) with ESMTP id 7C19A48E4EB
	for <nfs@lists.sourceforge.net>; Wed,  1 Feb 2006 22:02:01 +0000 (UTC)
Received: from smtpdcaus.corporate-domain.net (smtpdcaus1.corporate-domain.net [209.163.142.145])
	by mail27-ash.bigfish.com (Postfix) with ESMTP id 4BBF348E0A0
	for <nfs@lists.sourceforge.net>; Wed,  1 Feb 2006 22:02:01 +0000 (UTC)
Received: from exch3-dc-aus.northamerica.corporate-domain.net (exch3-dc-aus.northamerica.corporate-domain.net [172.16.4.40])
	by smtpdcaus.corporate-domain.net (8.12.8+Sun/8.12.8) with ESMTP id k11M20ZF012950
	for <nfs@lists.sourceforge.net>; Wed, 1 Feb 2006 16:02:01 -0600 (CST)
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

------_=_NextPart_001_01C6277B.1EF3E0BE
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable

Does anyone have any data they can share on the reliability of Linux NFS
servers (not clients) in an enterprise environment (e.g. server uptimes,
number of volumes shared, number of clients, IO rates)?  I have a large
enterprise application set (about 10K programs) that uses NFS for
file-sharing.  A movement is afoot at my company to port the
applications from the more expensive "big iron" Unix systems it is
currently deployed on to less expensive Linux x86 servers.  I'm trying
to do a baseline risk assessment of this move, and I'd like some
empirical data (or some speculative) on the reliability of NFS.  Even
better would be a contrast in reliability to shared-storage filesystems
like GFS or OCFS2.
 =

TIA!
 =



Notice: This transmission is for the sole use of the intended recipient(s) =
and may contain information that is confidential and/or privileged.  If you=
 are not the intended recipient, please delete this transmission and any at=
tachments and notify the sender by return email immediately.  Any unauthori=
zed review, use, disclosure or distribution is prohibited.


------_=_NextPart_001_01C6277B.1EF3E0BE
Content-Type: text/html;
	charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; charset=3Dus-ascii">
<META content=3D"MSHTML 6.00.2900.2802" name=3DGENERATOR></HEAD>
<BODY>
<DIV><SPAN class=3D119355021-01022006><FONT face=3DArial size=3D2>Does anyo=
ne have any =

data they can&nbsp;share on the reliability of Linux NFS servers (not clien=
ts) =

in an enterprise environment (e.g. server uptimes, number of volumes shared=
, =

number of clients, IO rates)?&nbsp; I have a large enterprise application s=
et =

(about 10K programs)&nbsp;that uses NFS for file-sharing.&nbsp; A movement =
is =

afoot at my company to port the applications from the more expensive "big i=
ron" =

Unix systems it is currently deployed on to less expensive Linux x86 =

servers.&nbsp; I'm trying to do a baseline risk assessment of this move, an=
d I'd =

like some empirical data (or some speculative) on the reliability of NFS.&n=
bsp; =

Even better would be a contrast in reliability to shared-storage filesystem=
s =

like GFS or OCFS2.</FONT></SPAN></DIV>
<DIV><SPAN class=3D119355021-01022006><FONT face=3DArial =

size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D119355021-01022006><FONT face=3DArial =

size=3D2>TIA!</FONT></SPAN></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV><br clear=3Dall> <br>=
=0D
<font color=3D"#000000" size=3D"1" face=3D"Arial, Helvetica, sans-serif"><s=
trong>Notice:</strong> This transmission is for the sole use of the intende=
d recipient(s) and may contain information that is confidential and/or priv=
ileged.<br>=0D
If you are not the intended recipient, please delete this transmission and =
any attachments and notify the sender by return email immediately.<br>=0D
Any unauthorized review, use, disclosure or distribution is prohibited.</fo=
nt><br>
</BODY></HTML>


------_=_NextPart_001_01C6277B.1EF3E0BE--



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
