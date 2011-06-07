Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52801 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754665Ab1FGR0o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:26:44 -0400
Date: Tue, 7 Jun 2011 13:26:39 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 07/88] pnfs: HACK: modify write_end_cleanup
Message-ID: <e24262ce201248f967e5aaf7b1561011e90705cc.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

This needs to be changed, but will require a major rewrite
of the block layout's IO code.  Including it here so I can
get some current code into the tree.

Change write_end_cleanup API to allow block driver the ability to
handle server blocks larger than a page in size.  It needs to
initiate writes to adjacent pages, so pass in filp so that it
can call the appropriate aop functions.  A field is also added to
fsdata to hold the list of pages.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index cfa8ea6..ac536bc 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -56,6 +56,7 @@ enum pnfs_try_status {
 
 struct pnfs_fsdata {
 	struct pnfs_layout_segment *lseg;
+	void *private;
 };
 
 #ifdef CONFIG_NFS_V4_1
@@ -116,6 +117,8 @@ struct pnfs_layoutdriver_type {
 	int (*write_end)(struct inode *inode, struct page *page, loff_t pos,
 			 unsigned count, unsigned copied,
 			 struct pnfs_layout_segment *lseg);
+	void (*write_end_cleanup)(struct file *filp,
+				  struct pnfs_fsdata *fsdata);
 
 	void (*free_deviceid_node) (struct nfs4_deviceid_node *);
 
@@ -356,6 +359,8 @@ static inline void pnfs_write_end_cleanup(struct file *filp, void *fsdata)
 	struct nfs_server *nfss = NFS_SERVER(filp->f_dentry->d_inode);
 
 	if (fsdata && nfss->pnfs_curr_ld) {
+		if (nfss->pnfs_curr_ld->write_end_cleanup)
+			nfss->pnfs_curr_ld->write_end_cleanup(filp, fsdata);
 		if (nfss->pnfs_curr_ld->write_begin)
 			pnfs_free_fsdata(fsdata);
 	}
-- 
1.7.4.1

