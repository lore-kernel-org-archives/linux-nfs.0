Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:43328 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815Ab1G2Pyv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 11:54:51 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v5 04/27] pnfs: save layoutcommit cred at layout header
Date: Fri, 29 Jul 2011 11:54:29 -0400
Message-Id: <1311954892-22038-5-git-send-email-rees@umich.edu>
In-Reply-To: <1311954892-22038-1-git-send-email-rees@umich.edu>
References: <1311954892-22038-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

No need to save it for every lseg.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/pnfs.c |    6 +++---
 fs/nfs/pnfs.h |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3e0989d..201165e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1384,7 +1384,7 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 	if (!test_and_set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
 		/* references matched in nfs4_layoutcommit_release */
 		get_lseg(wdata->lseg);
-		wdata->lseg->pls_lc_cred =
+		nfsi->layout->plh_lc_cred =
 			get_rpccred(wdata->args.context->state->owner->so_cred);
 		mark_as_dirty = true;
 		dprintk("%s: Set layoutcommit for inode %lu ",
@@ -1447,9 +1447,9 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	lseg = pnfs_list_write_lseg(inode);
 
 	end_pos = nfsi->layout->plh_lwb;
-	cred = lseg->pls_lc_cred;
+	cred = nfsi->layout->plh_lc_cred;
 	nfsi->layout->plh_lwb = 0;
-	lseg->pls_lc_cred = NULL;
+	nfsi->layout->plh_lc_cred = NULL;
 
 	memcpy(&data->args.stateid.data, nfsi->layout->plh_stateid.data,
 		sizeof(nfsi->layout->plh_stateid.data));
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 044cb3e..ac86c36 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -44,7 +44,6 @@ struct pnfs_layout_segment {
 	atomic_t pls_refcount;
 	unsigned long pls_flags;
 	struct pnfs_layout_hdr *pls_layout;
-	struct rpc_cred	*pls_lc_cred; /* LAYOUTCOMMIT credential */
 };
 
 enum pnfs_try_status {
@@ -128,6 +127,7 @@ struct pnfs_layout_hdr {
 	u32			plh_barrier; /* ignore lower seqids */
 	unsigned long		plh_flags;
 	loff_t			plh_lwb; /* last write byte for layoutcommit */
+	struct rpc_cred		*plh_lc_cred; /* layoutcommit cred */
 	struct inode		*plh_inode;
 };
 
-- 
1.7.4.1

