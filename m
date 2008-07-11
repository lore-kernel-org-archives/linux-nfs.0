From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/14] text-based mount options: rename functions in stropts.c
Date: Fri, 11 Jul 2008 16:35:17 -0400
Message-ID: <20080711203517.478.5368.stgit@tarkus.1015granger.net>
References: <20080711203322.478.52095.stgit@tarkus.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:39553 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756255AbYGKUfj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jul 2008 16:35:39 -0400
In-Reply-To: <20080711203322.478.52095.stgit-lQeC5l55kZ7wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: rename a couple of functions in utils/mount/stropts.c to match
the naming convention of the others.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)


diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index a51cf0b..b54df40 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -230,7 +230,7 @@ static int nfs_fix_mounthost_option(const sa_family_t family,
  * Returns zero if the "lock" option is in effect, but statd
  * can't be started.  Otherwise, returns 1.
  */
-static int verify_lock_option(struct mount_options *options)
+static int nfs_verify_lock_option(struct mount_options *options)
 {
 	if (po_rightmost(options, "nolock", "lock") == PO_KEY1_RIGHTMOST)
 		return 1;
@@ -279,7 +279,7 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 	} else {
 		if (!nfs_fix_mounthost_option(mi->family, mi->options))
 			return 0;
-		if (!mi->fake && !verify_lock_option(mi->options))
+		if (!mi->fake && !nfs_verify_lock_option(mi->options))
 			return 0;
 	}
 
@@ -297,7 +297,7 @@ static int nfs_validate_options(struct nfsmount_info *mi)
  * passed-in error is permanent, thus the mount system call
  * should not be retried.
  */
-static int is_permanent_error(int error)
+static int nfs_is_permanent_error(int error)
 {
 	switch (error) {
 	case ESTALE:
@@ -316,13 +316,13 @@ static int is_permanent_error(int error)
  *
  * To handle version and transport protocol fallback properly, we
  * need to parse some of the mount options in order to set up a
- * portmap probe.  Mount options that rewrite_mount_options()
+ * portmap probe.  Mount options that nfs_rewrite_mount_options()
  * doesn't recognize are left alone.
  *
  * Returns a new group of mount options if successful; otherwise
  * NULL is returned if some failure occurred.
  */
-static struct mount_options *rewrite_mount_options(char *str)
+static struct mount_options *nfs_rewrite_mount_options(char *str)
 {
 	struct mount_options *options;
 	char *option, new_option[64];
@@ -475,7 +475,7 @@ static int nfs_retry_nfs23mount(struct nfsmount_info *mi)
 	char *retry_str = NULL;
 	char **extra_opts = mi->extra_opts;
 
-	retry_options = rewrite_mount_options(*extra_opts);
+	retry_options = nfs_rewrite_mount_options(*extra_opts);
 	if (!retry_options)
 		return 0;
 
@@ -604,7 +604,7 @@ static int nfsmount_fg(struct nfsmount_info *mi)
 		if (nfs_try_mount(mi))
 			return EX_SUCCESS;
 
-		if (is_permanent_error(errno))
+		if (nfs_is_permanent_error(errno))
 			break;
 
 		if (time(NULL) > timeout) {
@@ -637,7 +637,7 @@ static int nfsmount_parent(struct nfsmount_info *mi)
 	if (nfs_try_mount(mi))
 		return EX_SUCCESS;
 
-	if (is_permanent_error(errno)) {
+	if (nfs_is_permanent_error(errno)) {
 		mount_error(mi->spec, mi->node, errno);
 		return EX_FAIL;
 	}
@@ -672,7 +672,7 @@ static int nfsmount_child(struct nfsmount_info *mi)
 		if (nfs_try_mount(mi))
 			return EX_SUCCESS;
 
-		if (is_permanent_error(errno))
+		if (nfs_is_permanent_error(errno))
 			break;
 
 		if (time(NULL) > timeout)

