From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 6/6] SQUASHME: spnfs-block: use only RETURN_* constants
Date: Wed,  9 Dec 2009 12:28:12 +0200
Message-ID: <1260354492-12289-1-git-send-email-bhalevy@panasas.com>
References: <4B1F7AF6.2080305@panasas.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:36510 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754663AbZLIK2H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Dec 2009 05:28:07 -0500
In-Reply-To: <4B1F7AF6.2080305@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/bl_ops.c   |    6 +++---
 fs/nfsd/nfs4proc.c |    2 +-
 fs/nfsd/vfs.c      |    2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/bl_ops.c b/fs/nfsd/bl_ops.c
index 86c292b..92dc27b 100644
--- a/fs/nfsd/bl_ops.c
+++ b/fs/nfsd/bl_ops.c
@@ -565,18 +565,18 @@ bl_layoutrecall(struct inode *inode, int type, u64 offset, u64 len)
 	dprintk("--> %s\n", __func__);
 	BUG_ON(!len);
 	switch (type) {
-		case RECALL_FILE:
+		case RETURN_FILE:
 			sb = inode->i_sb;
 			dprintk("  recalling layout [0x%x:%lu], %Lu:%Lu\n",
 			    inode->i_sb->s_dev, inode->i_ino,
 				_2SECTS(offset), _2SECTS(len));
 			break;
-		case RECALL_FSID:
+		case RETURN_FSID:
 			sb = inode->i_sb;
 			dprintk("%s: recalling layout for fsid x (unimplemented)\n",
 				__func__);
 			return 0;
-		case RECALL_ALL:
+		case RETURN_ALL:
 			/*
 			 * XXX figure out how to get a sb since there's no
 			 * inode ptr
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index dd8846a..07fb7a4 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -892,7 +892,7 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 #if defined(CONFIG_SPNFS_BLOCK)
 	if (pnfs_block_enabled(cstate->current_fh.fh_dentry->d_inode, 0)) {
                 status = bl_layoutrecall(cstate->current_fh.fh_dentry->d_inode,
-		    RECALL_FILE, write->wr_offset, write->wr_buflen);
+		    RETURN_FILE, write->wr_offset, write->wr_buflen);
                 if (!status) {
                         status =  nfsd_write(rqstp, &cstate->current_fh, filp,
 			     write->wr_offset, rqstp->rq_vec, write->wr_vlen,
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 97d6ffc..62358df 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -353,7 +353,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 				goto out;
 #if defined(CONFIG_SPNFS_BLOCK)
 			if (pnfs_block_enabled(inode, 0)) {
-				err = bl_layoutrecall(inode, RECALL_FILE,
+				err = bl_layoutrecall(inode, RETURN_FILE,
 				    iap->ia_size, inode->i_size - iap->ia_size);
 			}
 #endif /* CONFIG_SPNFS_BLOCK */
-- 
1.6.5.1

