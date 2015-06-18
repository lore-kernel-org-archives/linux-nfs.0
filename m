Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sperry-03.control.lth.se ([130.235.83.190]:53577 "EHLO
	sperry-03.control.lth.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605AbbFRIXK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2015 04:23:10 -0400
Received: from [130.235.83.12] (lie.control.lth.se [130.235.83.12])
	(authenticated bits=0)
	by sperry-03.control.lth.se (8.14.4/8.14.4) with ESMTP id t5I84Tja017271
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 18 Jun 2015 10:04:29 +0200
Message-ID: <55827B8D.3070103@control.lth.se>
Date: Thu, 18 Jun 2015 10:04:29 +0200
From: Anders Blomdell <anders.blomdell@control.lth.se>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Mount regression between 4.0.4 client and 2.6.35 server
Content-Type: multipart/mixed;
 boundary="------------070208010501000401080500"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070208010501000401080500
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

I have a problem with a 4.0.4 client refusing to mount from a 2.6.35 server
due to NFS4ERR_INVAL returned during nfs4_discover_server_trunking. See
https://bugzilla.redhat.com/show_bug.cgi?id=1228272.

Proposed patch attached.

Regards

Anders Blomdell
-- 
Anders Blomdell                  Email: anders.blomdell@control.lth.se
Department of Automatic Control
Lund University                  Phone:    +46 46 222 4625
P.O. Box 118                     Fax:      +46 46 138118
SE-221 00 Lund, Sweden


--------------070208010501000401080500
Content-Type: text/x-patch;
 name="nfs4_discover_server_trunking-eio.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="nfs4_discover_server_trunking-eio.patch"

Minimum viable patch to continue version autonegotiotion in
case where the server returns an unexpected NFS4ERR_INVAL,
which happens for a 4.0.4-303.fc22.x86_64 client talking to
a 2.6.35.14-106.fc14.i686.PAE server, see
https://bugzilla.redhat.com/show_bug.cgi?id=1228272

Signed-off-by: Anders Blomdell <anders.blomdell@control.lth.se>

--- utils/mount/stropts.c.orig	2015-06-18 09:51:02.091148891 +0200
+++ utils/mount/stropts.c	2015-06-18 09:48:56.859970023 +0200
@@ -838,6 +838,10 @@ check_result:
 		return result;
 
 	switch (errno) {
+	case EIO:
+		/* Fix to handle nfs4_discover_server_trunking returning
+		 * EIO in case where nfs server returns NFS4ERR_INVAL,
+		 * see https://bugzilla.redhat.com/show_bug.cgi?id=1228272 */
 	case EPROTONOSUPPORT:
 		/* A clear indication that the server or our
 		 * client does not support NFS version 4 and minor */

--------------070208010501000401080500--
