From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/3] SQUASHME: pnfsd: dlm: fixup LAYOUT_NFSV4_1_FILES
Date: Tue, 25 May 2010 08:56:34 +0300
Message-ID: <1274766994-19511-1-git-send-email-bhalevy@panasas.com>
References: <1274722623-11078-1-git-send-email-Ricardo.Labiaga@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:32910 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752835Ab0EYF4h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 01:56:37 -0400
In-Reply-To: <1274722623-11078-1-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4pnfsdlm.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index b724991..0cc295c 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -171,7 +171,7 @@ static int nfsd4_pnfs_dlm_getdeviter(struct super_block *sb,
 				     u32 layout_type,
 				     struct nfsd4_pnfs_dev_iter_res *res)
 {
-	if (layout_type != LAYOUT_NFSV4_FILES) {
+	if (layout_type != LAYOUT_NFSV4_1_FILES) {
 		printk(KERN_ERR "%s: ERROR: layout type isn't 'file' "
 			"(type: %x)\n", __func__, layout_type);
 		return -ENOTSUPP;
@@ -199,7 +199,7 @@ static int nfsd4_pnfs_dlm_getdevinfo(struct super_block *sb,
 	char   *bufp;
 
 	err = -ENOTSUPP;
-	if (layout_type != LAYOUT_NFSV4_FILES) {
+	if (layout_type != LAYOUT_NFSV4_1_FILES) {
 		dprintk("%s: ERROR: layout type isn't 'file' "
 			"(type: %x)\n", __func__, layout_type);
 		return err;
@@ -343,7 +343,7 @@ static enum nfsstat4 nfsd4_pnfs_dlm_layoutget(struct inode *inode,
 	if (index < 0)
 		return NFS4ERR_LAYOUTUNAVAILABLE;
 
-	res->lg_seg.layout_type = LAYOUT_NFSV4_FILES;
+	res->lg_seg.layout_type = LAYOUT_NFSV4_1_FILES;
 	/* Always give out whole file layouts */
 	res->lg_seg.offset = 0;
 	res->lg_seg.length = NFS4_MAX_UINT64;
@@ -357,7 +357,7 @@ static enum nfsstat4 nfsd4_pnfs_dlm_layoutget(struct inode *inode,
 	}
 
 	/* Set file layout response args */
-	layout->lg_layout_type = LAYOUT_NFSV4_FILES;
+	layout->lg_layout_type = LAYOUT_NFSV4_1_FILES;
 	layout->lg_stripe_type = STRIPE_SPARSE;
 	layout->lg_commit_through_mds = false;
 	layout->lg_stripe_unit = get_stripe_unit(inode->i_sb->s_blocksize);
@@ -392,7 +392,7 @@ error:
 static int
 nfsd4_pnfs_dlm_layouttype(struct super_block *sb)
 {
-	return LAYOUT_NFSV4_FILES;
+	return LAYOUT_NFSV4_1_FILES;
 }
 
 /* For use by DLM cluster file systems exported by pNFSD */
-- 
1.6.6.1

