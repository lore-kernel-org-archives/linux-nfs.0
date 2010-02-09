From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] mount.nfs: make nfs_{nfs,mount}_proto set errno on error
Date: Tue,  9 Feb 2010 10:04:48 -0500
Message-ID: <1265727888-4613-2-git-send-email-jlayton@redhat.com>
References: <1265727888-4613-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18668 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754107Ab0BIPEw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Feb 2010 10:04:52 -0500
In-Reply-To: <1265727888-4613-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Have nfs_nfs_proto and nfs_mount_proto set errno to EPROTONOSUPPORT on
error. This helps default_value to display sane warning messages.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/mount/network.c |   24 ++++++++++++++++++------
 1 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index a12fbe2..f020933 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1273,7 +1273,8 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
 
 /*
  * Returns TRUE if @protocol contains a valid value for this option,
- * or FALSE if the option was specified with an invalid value.
+ * or FALSE if the option was specified with an invalid value. On
+ * error, errno is set.
  */
 int
 nfs_nfs_protocol(struct mount_options *options, unsigned long *protocol)
@@ -1290,8 +1291,13 @@ nfs_nfs_protocol(struct mount_options *options, unsigned long *protocol)
 		return 1;
 	case 2: /* proto */
 		option = po_get(options, "proto");
-		if (option != NULL)
-			return nfs_get_proto(option, &family, protocol);
+		if (option != NULL) {
+			if (!nfs_get_proto(option, &family, protocol)) {
+				errno = EPROTONOSUPPORT;
+				return 0;
+			}
+			return 1;
+		}
 	}
 
 	/*
@@ -1449,7 +1455,8 @@ nfs_mount_version(struct mount_options *options, unsigned long *version)
 
 /*
  * Returns TRUE if @protocol contains a valid value for this option,
- * or FALSE if the option was specified with an invalid value.
+ * or FALSE if the option was specified with an invalid value. On
+ * error, errno is set.
  */
 static int
 nfs_mount_protocol(struct mount_options *options, unsigned long *protocol)
@@ -1458,8 +1465,13 @@ nfs_mount_protocol(struct mount_options *options, unsigned long *protocol)
 	char *option;
 
 	option = po_get(options, "mountproto");
-	if (option != NULL)
-		return nfs_get_proto(option, &family, protocol);
+	if (option != NULL) {
+		if (!nfs_get_proto(option, &family, protocol)) {
+			errno = EPROTONOSUPPORT;
+			return 0;
+		}
+		return 1;
+	}
 
 	/*
 	 * MNT transport protocol wasn't specified.  If the NFS
-- 
1.6.6

