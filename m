Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 183.141.211.66.inaddr.G4.NET ([66.211.141.183]:46110 "EHLO
	Dobby.4dicksons.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355Ab2KSPUX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Nov 2012 10:20:23 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1TaT92-0003kl-K2
	for linux-nfs@vger.kernel.org; Mon, 19 Nov 2012 10:20:21 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [RFC PATCH] mount: Added the -o v4.1 mount option
Date: Mon, 19 Nov 2012 10:15:36 -0500
Message-Id: <1353338136-18812-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch will convert -o v4.1, vers=4.1 and nfsvers=4.1 into
the corresponding "vers=4,minorversion=1" option.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/network.c | 18 ++++++++++++++++--
 utils/mount/nfs.man   | 13 +++++++++++++
 2 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index e7bd522..209da1a 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -94,6 +94,7 @@ static const char *nfs_version_opttbl[] = {
 	"v2",
 	"v3",
 	"v4",
+	"v4.1",
 	"vers",
 	"nfsvers",
 	NULL,
@@ -1244,11 +1245,20 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
 	case 2: /* v4 */
 		*version = 4;
 		return 1;
-	case 3:	/* vers */
+	case 3: /* v4.1 */
+		*version = 4;
+		po_remove_all(options, "v4.1");
+		po_append(options, "vers=4,minorversion=1");
+		return 1;
+	case 4:	/* vers */
 		switch (po_get_numeric(options, "vers", &tmp)) {
 		case PO_FOUND:
 			if (tmp >= 2 && tmp <= 4) {
 				*version = tmp;
+				if (strcmp(po_get(options, "vers"), "4.1") == 0) {
+					po_remove_all(options, "vers");
+					po_append(options, "vers=4,minorversion=1");
+				}
 				return 1;
 			}
 			return 0;
@@ -1261,11 +1271,15 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
 					progname);
 			return 0;
 		}
-	case 4: /* nfsvers */
+	case 5: /* nfsvers */
 		switch (po_get_numeric(options, "nfsvers", &tmp)) {
 		case PO_FOUND:
 			if (tmp >= 2 && tmp <= 4) {
 				*version = tmp;
+				if (strcmp(po_get(options, "nfsvers"), "4.1") == 0) {
+					po_remove_all(options, "nfsvers");
+					po_append(options, "nfsvers=4,minorversion=1");
+				}
 				return 1;
 			}
 			return 0;
diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index c15de98..8d1bb56 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -762,6 +762,19 @@ by 'nolock'/'lock' mount option.
 Use these options, along with the options in the first subsection above,
 for NFS version 4 and newer.
 .TP 1.5i
+.BI minorversion= n
+Specifies the protocol minor version number.
+NFSv4 introduces "minor versioning," where NFS protocol enhancements can
+be introduced without bumping the NFS protocol version number.
+.IP
+The minor version can also be be specified using the
+.B vers=
+option.
+For example, specifying
+.B vers=4.1
+is the same as specifying
+.BR vers=4,minorversion=1 .
+.TP 1.5i
 .BI proto= netid
 The
 .I netid
-- 
1.7.11.7

