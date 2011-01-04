Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52656 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751014Ab1ADDHD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Jan 2011 22:07:03 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/4] nfsd4: use a single struct file for delegations
Date: Mon,  3 Jan 2011 22:06:57 -0500
Message-Id: <1294110419-3105-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1294110419-3105-1-git-send-email-bfields@redhat.com>
References: <1294110419-3105-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

When we converted to sharing struct filess between nfs4 opens I went too
far and also used the same mechanism for delegations.  But keeping
a reference to the struct file ensures it will outlast the lease, and
allows us to remove the lease with the same file as we added it.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   10 +++++-----
 fs/nfsd/state.h     |    1 +
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2e44ad2..cbe1b81 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -230,7 +230,8 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_stateid *stp, struct svc_f
 	dp->dl_client = clp;
 	get_nfs4_file(fp);
 	dp->dl_file = fp;
-	nfs4_file_get_access(fp, O_RDONLY);
+	dp->dl_vfs_file = find_readable_file(fp);
+	get_file(dp->dl_vfs_file);
 	dp->dl_flock = NULL;
 	dp->dl_type = type;
 	dp->dl_stateid.si_boot = boot_time;
@@ -252,6 +253,7 @@ nfs4_put_delegation(struct nfs4_delegation *dp)
 	if (atomic_dec_and_test(&dp->dl_count)) {
 		dprintk("NFSD: freeing dp %p\n",dp);
 		put_nfs4_file(dp->dl_file);
+		fput(dp->dl_vfs_file);
 		kmem_cache_free(deleg_slab, dp);
 		num_delegations--;
 	}
@@ -265,12 +267,10 @@ nfs4_put_delegation(struct nfs4_delegation *dp)
 static void
 nfs4_close_delegation(struct nfs4_delegation *dp)
 {
-	struct file *filp = find_readable_file(dp->dl_file);
-
 	dprintk("NFSD: close_delegation dp %p\n",dp);
+	/* XXX: do we even need this check?: */
 	if (dp->dl_flock)
-		vfs_setlease(filp, F_UNLCK, &dp->dl_flock);
-	nfs4_file_put_access(dp->dl_file, O_RDONLY);
+		vfs_setlease(dp->dl_vfs_file, F_UNLCK, &dp->dl_flock);
 }
 
 /* Called under the state lock. */
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 39adc27..84b2302 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -81,6 +81,7 @@ struct nfs4_delegation {
 	atomic_t		dl_count;       /* ref count */
 	struct nfs4_client	*dl_client;
 	struct nfs4_file	*dl_file;
+	struct file		*dl_vfs_file;
 	struct file_lock	*dl_flock;
 	u32			dl_type;
 	time_t			dl_time;
-- 
1.7.1

