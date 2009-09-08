From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] mount.nfs: Support "vers=4" in nfs_nfs_version()
Date: Tue, 08 Sep 2009 17:02:49 -0400
Message-ID: <20090908210249.3326.81339.stgit@matisse.1015granger.net>
References: <20090908210012.3326.57767.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:28341 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362AbZIHVEY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Sep 2009 17:04:24 -0400
In-Reply-To: <20090908210012.3326.57767.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To handle "-t nfs -o vers=4" the nfs_nfs_version() function must
recognize "vers=4," "v4," and "nfsvers=4".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index f6fa5fd..420e15a 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -90,6 +90,7 @@ static const char *nfs_transport_opttbl[] = {
 static const char *nfs_version_opttbl[] = {
 	"v2",
 	"v3",
+	"v4",
 	"vers",
 	"nfsvers",
 	NULL,
@@ -1215,10 +1216,13 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
 	case 1: /* v3 */
 		*version = 3;
 		return 1;
-	case 2:	/* vers */
+	case 2: /* v4 */
+		*version = 4;
+		return 1;
+	case 3:	/* vers */
 		switch (po_get_numeric(options, "vers", &tmp)) {
 		case PO_FOUND:
-			if (tmp >= 2 && tmp <= 3) {
+			if (tmp >= 2 && tmp <= 4) {
 				*version = tmp;
 				return 1;
 			}
@@ -1229,10 +1233,10 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
 		case PO_BAD_VALUE:
 			return 0;
 		}
-	case 3: /* nfsvers */
+	case 4: /* nfsvers */
 		switch (po_get_numeric(options, "nfsvers", &tmp)) {
 		case PO_FOUND:
-			if (tmp >= 2 && tmp <= 3) {
+			if (tmp >= 2 && tmp <= 4) {
 				*version = tmp;
 				return 1;
 			}

