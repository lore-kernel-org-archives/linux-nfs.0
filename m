From: James Morris <jmorris@namei.org>
Subject: Compilation warning with current git on x86_64
Date: Sat, 14 Jul 2007 11:07:50 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0707141107060.26121@d.namei>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED;
	BOUNDARY="537530981-1487569339-1184425670=:26121"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9jDw-0002OQ-8g
	for nfs@lists.sourceforge.net; Sat, 14 Jul 2007 08:07:56 -0700
Received: from mail3.sea5.speakeasy.net ([69.17.117.5])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I9jDy-0007Pa-Qx
	for nfs@lists.sourceforge.net; Sat, 14 Jul 2007 08:08:00 -0700
Received: from dsl092-066-197.bos1.dsl.speakeasy.net (HELO d.namei)
	([66.92.66.197]) (envelope-sender <jmorris@namei.org>)
	by mail3.sea5.speakeasy.net (qmail-ldap-1.03) with AES256-SHA encrypted
	SMTP for <nfs@lists.sourceforge.net>; 14 Jul 2007 15:07:52 -0000
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--537530981-1487569339-1184425670=:26121
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

net/sunrpc/auth_gss/auth_gss.c:1002: warning: implicit declaration of=20
function =E2lock_kernel
net/sunrpc/auth_gss/auth_gss.c:1004: warning: implicit declaration of=20
function =E2unlock_kernel


I think these are fairly new?


--=20
James Morris
<jmorris@namei.org>
--537530981-1487569339-1184425670=:26121
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--537530981-1487569339-1184425670=:26121
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--537530981-1487569339-1184425670=:26121--
