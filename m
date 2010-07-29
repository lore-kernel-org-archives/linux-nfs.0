Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53255 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754888Ab0G2WWi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Jul 2010 18:22:38 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/5] nfsd4: miscellaneous process_open2 cleanup
Date: Thu, 29 Jul 2010 18:21:22 -0400
Message-Id: <1280442084-17867-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1280442084-17867-1-git-send-email-bfields@redhat.com>
References: <1280442084-17867-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Move more work into helper functions.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   26 +++++++++++++++++---------
 1 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c07c988..d9c8232 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2317,10 +2317,21 @@ nfs4_alloc_stateid(void)
 	return kmem_cache_alloc(stateid_slab, GFP_KERNEL);
 }
 
+static inline int nfs4_access_to_access(u32 nfs4_access)
+{
+	int flags = 0;
+
+	if (nfs4_access & NFS4_SHARE_ACCESS_READ)
+		flags |= NFSD_MAY_READ;
+	if (nfs4_access & NFS4_SHARE_ACCESS_WRITE)
+		flags |= NFSD_MAY_WRITE;
+	return flags;
+}
+
 static __be32
 nfs4_new_open(struct svc_rqst *rqstp, struct nfs4_stateid **stpp,
 		struct nfs4_delegation *dp,
-		struct svc_fh *cur_fh, int flags)
+		struct svc_fh *cur_fh, struct nfsd4_open *open)
 {
 	struct nfs4_stateid *stp;
 
@@ -2333,8 +2344,10 @@ nfs4_new_open(struct svc_rqst *rqstp, struct nfs4_stateid **stpp,
 		stp->st_vfs_file = dp->dl_vfs_file;
 	} else {
 		__be32 status;
-		status = nfsd_open(rqstp, cur_fh, S_IFREG, flags,
-				&stp->st_vfs_file);
+		int access = nfs4_access_to_access(open->op_share_access);
+
+		status = nfsd_open(rqstp, cur_fh, S_IFREG, access,
+					&stp->st_vfs_file);
 		if (status) {
 			if (status == nfserr_dropit)
 				status = nfserr_jukebox;
@@ -2531,12 +2544,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		update_stateid(&stp->st_stateid);
 	} else {
 		/* Stateid was not found, this is a new OPEN */
-		int flags = 0;
-		if (open->op_share_access & NFS4_SHARE_ACCESS_READ)
-			flags |= NFSD_MAY_READ;
-		if (open->op_share_access & NFS4_SHARE_ACCESS_WRITE)
-			flags |= NFSD_MAY_WRITE;
-		status = nfs4_new_open(rqstp, &stp, dp, current_fh, flags);
+		status = nfs4_new_open(rqstp, &stp, dp, current_fh, open);
 		if (status)
 			goto out;
 		init_stateid(stp, fp, open);
-- 
1.7.0.4

