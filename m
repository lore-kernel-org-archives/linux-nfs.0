From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 18/31] mount.nfs: rearchitect mount version/protocol
	negotiation logic
Date: Mon, 29 Jun 2009 13:37:38 -0400
Message-ID: <20090629173738.2076.24687.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:23130 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751721AbZF2Rh6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:37:58 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Text-based mounts try a mount operation first with default settings,
then negotiate via rpcbind queries and retry the mount, if the default
settings don't work.  This method introduces long delays in certain
common scenarios, and makes it difficult to tell when it is
appropriate to fail immediately or negotiate and retry.

To address these behavioral regressions, make text-based mounts
operate the same way that legacy mounts work.  Perform rpcbind queries
with short timeouts first, then use the results to determine
transport, version, and port number settings for the mount.

This allows the mount.nfs command to detect server settings, or
whether negotiation is even possible, quickly.  It also makes it
simple to determine when to fail vs. when to retry.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   42 +++++++++++++++++++++++++-----------------
 1 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 30ac5ae..6801569 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -437,6 +437,7 @@ static struct mount_options *nfs_rewrite_mount_options(char *str)
 	struct sockaddr *mnt_saddr = (struct sockaddr *)&mnt_address;
 	socklen_t mnt_salen;
 	struct pmap mnt_pmap;
+	char *option;
 
 	options = po_split(str);
 	if (!options) {
@@ -444,23 +445,39 @@ static struct mount_options *nfs_rewrite_mount_options(char *str)
 		return NULL;
 	}
 
+	/*
+	 * Skip option negotiation for proto=rdma mounts.
+	 */
+	option = po_get(options, "proto");
+	if (option && strcmp(option, "rdma") == 0)
+		goto out;
+
+	/*
+	 * Extract just the options needed to contact server.
+	 * Bail now if any of these have bad values.
+	 */
 	if (!nfs_extract_server_addresses(options, nfs_saddr, &nfs_salen,
 						mnt_saddr, &mnt_salen)) {
 		errno = EINVAL;
 		goto err;
 	}
-
 	if (!nfs_options2pmap(options, &nfs_pmap, &mnt_pmap)) {
 		errno = EINVAL;
 		goto err;
 	}
 
-	/* The kernel NFS client doesn't support changing the RPC program
-	 * number for these services, so reset these fields before probing
-	 * the server's ports.  */
+	/*
+	 * The kernel NFS client doesn't support changing the RPC
+	 * program number for these services, so force the value of
+	 * these fields before probing the server's ports.
+	 */
 	nfs_pmap.pm_prog = NFS_PROGRAM;
 	mnt_pmap.pm_prog = MOUNTPROG;
 
+	/*
+	 * If the server's rpcbind service isn't available, we can't
+	 * negotiate.  Bail now if we can't contact it.
+	 */
 	if (!nfs_probe_bothports(mnt_saddr, mnt_salen, &mnt_pmap,
 				 nfs_saddr, nfs_salen, &nfs_pmap)) {
 		errno = ESPIPE;
@@ -472,6 +489,7 @@ static struct mount_options *nfs_rewrite_mount_options(char *str)
 		goto err;
 	}
 
+out:
 	errno = 0;
 	return options;
 
@@ -532,6 +550,9 @@ static int nfs_retry_nfs23mount(struct nfsmount_info *mi)
 		printf(_("%s: text-based options (retry): '%s'\n"),
 			progname, retry_str);
 
+	if (mi->fake)
+		return 1;
+
 	if (!nfs_sys_mount(mi, "nfs", retry_str)) {
 		po_destroy(retry_options);
 		free(retry_str);
@@ -570,19 +591,6 @@ static int nfs_try_nfs23mount(struct nfsmount_info *mi)
 		printf(_("%s: text-based options: '%s'\n"),
 			progname, *extra_opts);
 
-	if (mi->fake)
-		return 1;
-
-	if (nfs_sys_mount(mi, "nfs", *extra_opts))
-		return 1;
-
-	/*
-	 * The kernel returns EOPNOTSUPP if the RPC bind failed,
-	 * and EPROTONOSUPPORT if the version isn't supported.
-	 */
-	if (errno != EOPNOTSUPP && errno != EPROTONOSUPPORT)
-		return 0;
-
 	return nfs_retry_nfs23mount(mi);
 }
 

