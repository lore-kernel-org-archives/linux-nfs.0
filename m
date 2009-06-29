From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 20/31] mount.nfs: Clean up after restructuring
	version/protocol negotiation
Date: Mon, 29 Jun 2009 13:37:57 -0400
Message-ID: <20090629173757.2076.61492.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:51509 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755138AbZF2RkC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:40:02 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix up comments and function names to reflect the new version/protocol
negotiation scheme.  We can now remove a bunch of mount processing
that is specific to v2/v3, removing about 100 lines of logic from
stropts.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |  157 ++++++++-----------------------------------------
 1 files changed, 25 insertions(+), 132 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 6560f1c..e94265a 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -400,15 +400,15 @@ static int nfs_construct_new_options(struct mount_options *options,
  *
  * To handle version and transport protocol fallback properly, we
  * need to parse some of the mount options in order to set up a
- * portmap probe.  Mount options that nfs_rewrite_mount_options()
+ * portmap probe.  Mount options that nfs_rewrite_pmap_mount_options()
  * doesn't recognize are left alone.
  *
- * Returns a new group of mount options if successful; otherwise
- * NULL is returned if some failure occurred.
+ * Returns TRUE if rewriting was successful; otherwise
+ * FALSE is returned if some failure occurred.
  */
-static struct mount_options *nfs_rewrite_mount_options(char *str)
+static int
+nfs_rewrite_pmap_mount_options(struct mount_options *options)
 {
-	struct mount_options *options;
 	struct sockaddr_storage nfs_address;
 	struct sockaddr *nfs_saddr = (struct sockaddr *)&nfs_address;
 	socklen_t nfs_salen;
@@ -419,12 +419,6 @@ static struct mount_options *nfs_rewrite_mount_options(char *str)
 	struct pmap mnt_pmap;
 	char *option;
 
-	options = po_split(str);
-	if (!options) {
-		errno = EFAULT;
-		return NULL;
-	}
-
 	/*
 	 * Skip option negotiation for proto=rdma mounts.
 	 */
@@ -439,11 +433,11 @@ static struct mount_options *nfs_rewrite_mount_options(char *str)
 	if (!nfs_extract_server_addresses(options, nfs_saddr, &nfs_salen,
 						mnt_saddr, &mnt_salen)) {
 		errno = EINVAL;
-		goto err;
+		return 0;
 	}
 	if (!nfs_options2pmap(options, &nfs_pmap, &mnt_pmap)) {
 		errno = EINVAL;
-		goto err;
+		return 0;
 	}
 
 	/*
@@ -461,156 +455,55 @@ static struct mount_options *nfs_rewrite_mount_options(char *str)
 	if (!nfs_probe_bothports(mnt_saddr, mnt_salen, &mnt_pmap,
 				 nfs_saddr, nfs_salen, &nfs_pmap)) {
 		errno = ESPIPE;
-		goto err;
+		return 0;
 	}
 
 	if (!nfs_construct_new_options(options, &nfs_pmap, &mnt_pmap)) {
 		errno = EINVAL;
-		goto err;
+		return 0;
 	}
 
 out:
 	errno = 0;
-	return options;
-
-err:
-	po_destroy(options);
-	return NULL;
-}
-
-/*
- * Do the mount(2) system call.
- *
- * Returns 1 if successful, otherwise zero.
- * "errno" is set to reflect the individual error.
- */
-static int nfs_sys_mount(const struct nfsmount_info *mi, const char *type,
-			 const char *options)
-{
-	int result;
-
-	result = mount(mi->spec, mi->node, type,
-				mi->flags & ~(MS_USER|MS_USERS), options);
-	if (verbose && result) {
-		int save = errno;
-		nfs_error(_("%s: mount(2): %s"), progname, strerror(save));
-		errno = save;
-	}
-	return !result;
-}
-
-/*
- * Retry an NFS mount that failed because the requested service isn't
- * available on the server.
- *
- * Returns 1 if successful.  Otherwise, returns zero.
- * "errno" is set to reflect the individual error.
- *
- * Side effect: If the retry is successful, both 'options' and
- * 'extra_opts' are updated to reflect the mount options that worked.
- * If the retry fails, 'options' and 'extra_opts' are left unchanged.
- */
-static int nfs_retry_nfs23mount(struct nfsmount_info *mi)
-{
-	struct mount_options *retry_options;
-	char *retry_str = NULL;
-	char **extra_opts = mi->extra_opts;
-
-	retry_options = nfs_rewrite_mount_options(*extra_opts);
-	if (!retry_options)
-		return 0;
-
-	if (po_join(retry_options, &retry_str) == PO_FAILED) {
-		po_destroy(retry_options);
-		errno = EIO;
-		return 0;
-	}
-
-	if (verbose)
-		printf(_("%s: text-based options (retry): '%s'\n"),
-			progname, retry_str);
-
-	if (mi->fake)
-		return 1;
-
-	if (!nfs_sys_mount(mi, "nfs", retry_str)) {
-		po_destroy(retry_options);
-		free(retry_str);
-		return 0;
-	}
-
-	free(*extra_opts);
-	*extra_opts = retry_str;
-	po_replace(mi->options, retry_options);
 	return 1;
 }
 
 /*
- * Attempt an NFSv2/3 mount via a mount(2) system call.  If the kernel
- * claims the requested service isn't supported on the server, probe
- * the server to see what's supported, rewrite the mount options,
- * and retry the request.
+ * Do the mount(2) system call.
  *
- * Returns 1 if successful.  Otherwise, returns zero.
+ * Returns TRUE if successful, otherwise FALSE.
  * "errno" is set to reflect the individual error.
- *
- * Side effect: If the retry is successful, both 'options' and
- * 'extra_opts' are updated to reflect the mount options that worked.
- * If the retry fails, 'options' and 'extra_opts' are left unchanged.
  */
-static int nfs_try_nfs23mount(struct nfsmount_info *mi)
+static int nfs_try_mount(struct nfsmount_info *mi)
 {
 	char **extra_opts = mi->extra_opts;
+	int result;
 
-	if (po_join(mi->options, extra_opts) == PO_FAILED) {
-		errno = EIO;
-		return 0;
+	if (strncmp(mi->type, "nfs4", 4) != 0) {
+		if (!nfs_rewrite_pmap_mount_options(mi->options))
+			return 0;
 	}
 
-	if (verbose)
-		printf(_("%s: text-based options: '%s'\n"),
-			progname, *extra_opts);
-
-	return nfs_retry_nfs23mount(mi);
-}
-
-/*
- * Attempt an NFS v4 mount via a mount(2) system call.
- *
- * Returns 1 if successful.  Otherwise, returns zero.
- * "errno" is set to reflect the individual error.
- */
-static int nfs_try_nfs4mount(struct nfsmount_info *mi)
-{
-	char **extra_opts = mi->extra_opts;
-
 	if (po_join(mi->options, extra_opts) == PO_FAILED) {
 		errno = EIO;
 		return 0;
 	}
 
 	if (verbose)
-		printf(_("%s: text-based options: '%s'\n"),
+		printf(_("%s: trying text-based options '%s'\n"),
 			progname, *extra_opts);
 
 	if (mi->fake)
 		return 1;
 
-	return nfs_sys_mount(mi, "nfs4", *extra_opts);
-}
-
-/*
- * Perform either an NFSv2/3 mount, or an NFSv4 mount system call.
- *
- * Returns 1 if successful.  Otherwise, returns zero.
- * "errno" is set to reflect the individual error.
- */
-static int nfs_try_mount(struct nfsmount_info *mi)
-{
-	if (strncmp(mi->type, "nfs4", 4) == 0)
-		return nfs_try_nfs4mount(mi);
-	else
-		return nfs_try_nfs23mount(mi);
+	result = mount(mi->spec, mi->node, mi->type,
+			mi->flags & ~(MS_USER|MS_USERS), *extra_opts);
+	if (verbose && result) {
+		int save = errno;
+		nfs_error(_("%s: mount(2): %s"), progname, strerror(save));
+		errno = save;
+	}
+	return !result;
 }
 
 /*

