Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:50194 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753423Ab1G3GaV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jul 2011 02:30:21 -0400
Message-ID: <4E33A4DB.6030206@panasas.com>
Date: Fri, 29 Jul 2011 23:29:47 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>, Jim Rees <rees@umich.edu>,
        Peng Tao <bergwolf@gmail.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/6] pnfs: save layoutcommit lwb at layout header
References: <4E33A288.80403@panasas.com>
In-Reply-To: <4E33A288.80403@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

No need to save it for every lseg.

[Needed in v3.0]
CC: Stable Tree <stable@kernel.org>
Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/nfs4filelayout.c |    2 +-
 fs/nfs/pnfs.c           |   10 ++++++----
 fs/nfs/pnfs.h           |    2 +-
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index f9d03ab..614c4d2 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -170,7 +170,7 @@ filelayout_set_layoutcommit(struct nfs_write_data *wdata)
 
 	pnfs_set_layoutcommit(wdata);
 	dprintk("%s ionde %lu pls_end_pos %lu\n", __func__, wdata->inode->i_ino,
-		(unsigned long) wdata->lseg->pls_end_pos);
+		(unsigned long) NFS_I(wdata->inode)->layout->plh_lwb);
 }
 
 /*
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 29c0ca7..fb1bcf1 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1224,9 +1224,11 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 		dprintk("%s: Set layoutcommit for inode %lu ",
 			__func__, wdata->inode->i_ino);
 	}
-	if (end_pos > wdata->lseg->pls_end_pos)
-		wdata->lseg->pls_end_pos = end_pos;
+	if (end_pos > nfsi->layout->plh_lwb)
+		nfsi->layout->plh_lwb = end_pos;
 	spin_unlock(&nfsi->vfs_inode.i_lock);
+	dprintk("%s: lseg %p end_pos %llu\n",
+		__func__, wdata->lseg, nfsi->layout->plh_lwb);
 
 	/* if pnfs_layoutcommit_inode() runs between inode locks, the next one
 	 * will be a noop because NFS_INO_LAYOUTCOMMIT will not be set */
@@ -1278,9 +1280,9 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	 */
 	lseg = pnfs_list_write_lseg(inode);
 
-	end_pos = lseg->pls_end_pos;
+	end_pos = nfsi->layout->plh_lwb;
 	cred = lseg->pls_lc_cred;
-	lseg->pls_end_pos = 0;
+	nfsi->layout->plh_lwb = 0;
 	lseg->pls_lc_cred = NULL;
 
 	memcpy(&data->args.stateid.data, nfsi->layout->plh_stateid.data,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 96bf4e6..77e1b24 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -45,7 +45,6 @@ struct pnfs_layout_segment {
 	unsigned long pls_flags;
 	struct pnfs_layout_hdr *pls_layout;
 	struct rpc_cred	*pls_lc_cred; /* LAYOUTCOMMIT credential */
-	loff_t pls_end_pos; /* LAYOUTCOMMIT write end */
 };
 
 enum pnfs_try_status {
@@ -124,6 +123,7 @@ struct pnfs_layout_hdr {
 	unsigned long		plh_block_lgets; /* block LAYOUTGET if >0 */
 	u32			plh_barrier; /* ignore lower seqids */
 	unsigned long		plh_flags;
+	loff_t			plh_lwb; /* last write byte for layoutcommit */
 	struct inode		*plh_inode;
 };
 
-- 
1.7.6


