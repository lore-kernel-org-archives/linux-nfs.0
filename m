Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:35052 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175Ab1G2DQo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jul 2011 23:16:44 -0400
Date: Thu, 28 Jul 2011 23:16:50 -0400
From: Jim Rees <rees@umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v4 09/27] pnfs: cleanup_layoutcommit
Message-ID: <20110729031650.GA19579@merit.edu>
References: <1311874276-1386-1-git-send-email-rees@umich.edu>
 <1311874276-1386-10-git-send-email-rees@umich.edu>
 <4E31A9F3.9090205@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E31A9F3.9090205@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Boaz Harrosh wrote:

  On 07/28/2011 10:30 AM, Jim Rees wrote:
  > From: Andy Adamson <andros@netapp.com>
  > 
  > This gives layout driver a chance to cleanup structures they put in at
  > encode_layoutcommit.
  > 
  > Signed-off-by: Andy Adamson <andros@netapp.com>
  > [fixup layout header pointer for layoutcommit]
  > Signed-off-by: Benny Halevy <bhalevy@panasas.com>
  > Signed-off-by: Benny Halevy <bhalevy@tonian.com>
  > ---
  >  fs/nfs/nfs4proc.c       |    1 +
  >  fs/nfs/nfs4xdr.c        |    1 +
  >  fs/nfs/pnfs.c           |   10 ++++++++++
  >  fs/nfs/pnfs.h           |    5 +++++
  >  include/linux/nfs_xdr.h |    1 +
  >  5 files changed, 18 insertions(+), 0 deletions(-)
  > 
  > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
  > index e86de79..6cb84b4 100644
  > --- a/fs/nfs/nfs4proc.c
  > +++ b/fs/nfs/nfs4proc.c
  > @@ -5963,6 +5963,7 @@ static void nfs4_layoutcommit_release(void *calldata)
  >  	struct nfs4_layoutcommit_data *data = calldata;
  >  	struct pnfs_layout_segment *lseg, *tmp;
  >  
  > +	pnfs_cleanup_layoutcommit(data->args.inode, data);
  
  If inode is part of @data, which is also passed as argument then we can simplify
  the API by just passing @data

Thanks, I've applied the following patch, which will be squashed and
included in the next version of the patch set.  Which I will probably send
tomorrow.

>From b757a45f208f31f8eff5ec499f1e99895713a17c Mon Sep 17 00:00:00 2001
From: Jim Rees <rees@umich.edu>
Date: Thu, 28 Jul 2011 15:26:49 -0400
Subject: [PATCH] SQUASHME: rm inode and pnfs_layout_hdr args from cleanup_layoutcommit()

Signed-off-by: Jim Rees <rees@umich.edu>
---
 fs/nfs/blocklayout/blocklayout.c |    5 +++--
 fs/nfs/nfs4proc.c                |    2 +-
 fs/nfs/pnfs.c                    |    8 +++-----
 fs/nfs/pnfs.h                    |    6 ++----
 4 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 81efa05..7450309 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -771,9 +771,10 @@ bl_encode_layoutcommit(struct pnfs_layout_hdr *lo, struct xdr_stream *xdr,
 }
 
 static void
-bl_cleanup_layoutcommit(struct pnfs_layout_hdr *lo,
-			struct nfs4_layoutcommit_data *lcdata)
+bl_cleanup_layoutcommit(struct nfs4_layoutcommit_data *lcdata)
 {
+	struct pnfs_layout_hdr *lo = NFS_I(lcdata->args.inode)->layout;
+
 	dprintk("%s enter\n", __func__);
 	clean_pnfs_block_layoutupdate(BLK_LO2EXT(lo), &lcdata->args, lcdata->res.status);
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6cb84b4..8c77039 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5963,7 +5963,7 @@ static void nfs4_layoutcommit_release(void *calldata)
 	struct nfs4_layoutcommit_data *data = calldata;
 	struct pnfs_layout_segment *lseg, *tmp;
 
-	pnfs_cleanup_layoutcommit(data->args.inode, data);
+	pnfs_cleanup_layoutcommit(data);
 	/* Matched by references in pnfs_set_layoutcommit */
 	list_for_each_entry_safe(lseg, tmp, &data->lseg_list, pls_lc_list) {
 		list_del_init(&lseg->pls_lc_list);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c1cc216..e550e88 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1411,14 +1411,12 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 }
 EXPORT_SYMBOL_GPL(pnfs_set_layoutcommit);
 
-void pnfs_cleanup_layoutcommit(struct inode *inode,
-			       struct nfs4_layoutcommit_data *data)
+void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data)
 {
-	struct nfs_server *nfss = NFS_SERVER(inode);
+	struct nfs_server *nfss = NFS_SERVER(data->args.inode);
 
 	if (nfss->pnfs_curr_ld->cleanup_layoutcommit)
-		nfss->pnfs_curr_ld->cleanup_layoutcommit(NFS_I(inode)->layout,
-							 data);
+		nfss->pnfs_curr_ld->cleanup_layoutcommit(data);
 }
 
 /*
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 82dde37..e0b5d80 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -113,8 +113,7 @@ struct pnfs_layoutdriver_type {
 				     struct xdr_stream *xdr,
 				     const struct nfs4_layoutreturn_args *args);
 
-	void (*cleanup_layoutcommit) (struct pnfs_layout_hdr *layoutid,
-				      struct nfs4_layoutcommit_data *data);
+	void (*cleanup_layoutcommit) (struct nfs4_layoutcommit_data *data);
 
 	void (*encode_layoutcommit) (struct pnfs_layout_hdr *layoutid,
 				     struct xdr_stream *xdr,
@@ -198,8 +197,7 @@ void pnfs_roc_release(struct inode *ino);
 void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
 bool pnfs_roc_drain(struct inode *ino, u32 *barrier);
 void pnfs_set_layoutcommit(struct nfs_write_data *wdata);
-void pnfs_cleanup_layoutcommit(struct inode *inode,
-			       struct nfs4_layoutcommit_data *data);
+void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data);
 int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
 int _pnfs_return_layout(struct inode *);
 int pnfs_ld_write_done(struct nfs_write_data *);
-- 
1.7.4.1

