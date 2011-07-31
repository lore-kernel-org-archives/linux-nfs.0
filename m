Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:38041 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904Ab1GaAxE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jul 2011 20:53:04 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v7 01/26] pnfs: save layoutcommit lwb at layout header
Date: Sat, 30 Jul 2011 20:52:31 -0400
Message-Id: <1312073576-11024-2-git-send-email-rees@umich.edu>
In-Reply-To: <1312073576-11024-1-git-send-email-rees@umich.edu>
References: <1312073576-11024-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

No need to save it for every lseg.

[Needed in v3.0]
CC: Stable Tree <stable@kernel.org>
Signed-off-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Jim Rees <rees@umich.edu>
---
 fs/nfs/nfs4filelayout.c |    2 +-
 fs/nfs/pnfs.c           |   10 ++++++----
 fs/nfs/pnfs.h           |    2 +-
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index be93a62..e8915d4 100644
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
index 38e5508..7a948ab 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1379,9 +1379,11 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
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
@@ -1433,9 +1435,9 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
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
index 078670d..1eb2c04 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -45,7 +45,6 @@ struct pnfs_layout_segment {
 	unsigned long pls_flags;
 	struct pnfs_layout_hdr *pls_layout;
 	struct rpc_cred	*pls_lc_cred; /* LAYOUTCOMMIT credential */
-	loff_t pls_end_pos; /* LAYOUTCOMMIT write end */
 };
 
 enum pnfs_try_status {
@@ -125,6 +124,7 @@ struct pnfs_layout_hdr {
 	unsigned long		plh_block_lgets; /* block LAYOUTGET if >0 */
 	u32			plh_barrier; /* ignore lower seqids */
 	unsigned long		plh_flags;
+	loff_t			plh_lwb; /* last write byte for layoutcommit */
 	struct inode		*plh_inode;
 };
 
-- 
1.7.4.1

