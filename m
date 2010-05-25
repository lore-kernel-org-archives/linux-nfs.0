From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/3] SQUASHME: pnfsd-lexp: fixup LAYOUT_NFSV4_1_FILES
Date: Tue, 25 May 2010 08:56:47 +0300
Message-ID: <1274767007-19550-1-git-send-email-bhalevy@panasas.com>
References: <1274722623-11078-1-git-send-email-Ricardo.Labiaga@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:61701 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754759Ab0EYF4t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 01:56:49 -0400
In-Reply-To: <1274722623-11078-1-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/pnfsd_lexp.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/pnfsd_lexp.c b/fs/nfsd/pnfsd_lexp.c
index 2d95913..bf2f403 100644
--- a/fs/nfsd/pnfsd_lexp.c
+++ b/fs/nfsd/pnfsd_lexp.c
@@ -31,7 +31,7 @@ size_t pnfs_lexp_addr_len;
 static int
 pnfsd_lexp_layout_type(struct super_block *sb)
 {
-	int ret = LAYOUT_NFSV4_FILES;
+	int ret = LAYOUT_NFSV4_1_FILES;
 	dprintk("<-- %s: return %d\n", __func__, ret);
 	return ret;
 }
@@ -43,7 +43,7 @@ pnfsd_lexp_get_device_iter(struct super_block *sb,
 {
 	dprintk("--> %s: sb=%p\n", __func__, sb);
 
-	BUG_ON(layout_type != LAYOUT_NFSV4_FILES);
+	BUG_ON(layout_type != LAYOUT_NFSV4_1_FILES);
 
 	res->gd_eof = 1;
 	if (res->gd_cookie)
@@ -72,7 +72,7 @@ pnfsd_lexp_get_device_info(struct super_block *sb,
 
 	dprintk("--> %s: sb=%p\n", __func__, sb);
 
-	BUG_ON(layout_type != LAYOUT_NFSV4_FILES);
+	BUG_ON(layout_type != LAYOUT_NFSV4_1_FILES);
 
 	memset(&fdev, '\0', sizeof(fdev));
 
@@ -138,7 +138,7 @@ pnfsd_lexp_layout_get(struct inode *inode,
 
 	dprintk("--> %s: inode=%p\n", __func__, inode);
 
-	res->lg_seg.layout_type = LAYOUT_NFSV4_FILES;
+	res->lg_seg.layout_type = LAYOUT_NFSV4_1_FILES;
 	res->lg_seg.offset = 0;
 	res->lg_seg.length = NFS4_MAX_UINT64;
 
@@ -149,7 +149,7 @@ pnfsd_lexp_layout_get(struct inode *inode,
 	}
 
 	/* Set file layout response args */
-	layout->lg_layout_type = LAYOUT_NFSV4_FILES;
+	layout->lg_layout_type = LAYOUT_NFSV4_1_FILES;
 	layout->lg_stripe_type = STRIPE_SPARSE;
 	layout->lg_commit_through_mds = true;
 	layout->lg_stripe_unit = get_stripe_unit(inode->i_sb->s_blocksize);
-- 
1.6.6.1

