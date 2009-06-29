From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 19/31] mount.nfs: Clean up nfs_is_permanent_error()
Date: Mon, 29 Jun 2009 13:37:48 -0400
Message-ID: <20090629173747.2076.52839.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:54809 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756504AbZF2RkI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:40:08 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Move nfs_is_permanent_error() closer to the functions that
call it, and update a documenting comment to reflect recent
restructuring in this area.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   45 +++++++++++++++++++++++++--------------------
 1 files changed, 25 insertions(+), 20 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 6801569..6560f1c 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -287,26 +287,6 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 }
 
 /*
- * Distinguish between permanent and temporary errors.
- *
- * Returns 0 if the passed-in error is temporary, thus the
- * mount system call should be retried; returns one if the
- * passed-in error is permanent, thus the mount system call
- * should not be retried.
- */
-static int nfs_is_permanent_error(int error)
-{
-	switch (error) {
-	case ESTALE:
-	case ETIMEDOUT:
-	case ECONNREFUSED:
-		return 0;	/* temporary */
-	default:
-		return 1;	/* permanent */
-	}
-}
-
-/*
  * Get NFS/mnt server addresses from mount options
  *
  * Returns 1 and fills in @nfs_saddr, @nfs_salen, @mnt_saddr, and @mnt_salen
@@ -634,6 +614,31 @@ static int nfs_try_mount(struct nfsmount_info *mi)
 }
 
 /*
+ * Distinguish between permanent and temporary errors.
+ *
+ * Basically, we retry if communication with the server has
+ * failed so far, but fail immediately if there is a local
+ * error (like a bad mount option).
+ *
+ * ESTALE is also a temporary error because some servers
+ * return ESTALE when a share is temporarily offline.
+ *
+ * Returns 1 if we should fail immediately, or 0 if we
+ * should retry.
+ */
+static int nfs_is_permanent_error(int error)
+{
+	switch (error) {
+	case ESTALE:
+	case ETIMEDOUT:
+	case ECONNREFUSED:
+		return 0;	/* temporary */
+	default:
+		return 1;	/* permanent */
+	}
+}
+
+/*
  * Handle "foreground" NFS mounts.
  *
  * Retry the mount request for as long as the 'retry=' option says.

