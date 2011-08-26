Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:52538 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014Ab1HZARQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Aug 2011 20:17:16 -0400
Message-ID: <4E56E5D5.2070701@panasas.com>
Date: Thu, 25 Aug 2011 17:16:21 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: Peng Tao <bergwolf@gmail.com>, "Isaman, Fred" <Fred.Isaman@netapp.com>,
        Andy Adamson <andros@netapp.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@tonian.com>, <linux-nfs@vger.kernel.org>,
        Peng Tao <peng_tao@emc.com>
Subject: Re: [PATCH] pnfsblock: init pg_bsize properly
References: <1313197450-4595-1-git-send-email-bergwolf@gmail.com> <4E4ADBA1.1000005@panasas.com> <4E4B6A81.2010204@tonian.com> <CA+a=Yy6BSmEWurZuFN-8axTS0gfeXaguw5tcayeVjJmcFAztOQ@mail.gmail.com> <4E52EBAC.8070908@panasas.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AC9DF79@SACMVEXC2-PRD.hq.netapp.com> <CA+a=Yy4gm3789v0w-dGpZO1w9RrpC7ELgeM9=qNsf4tYigdw2A@mail.gmail.com> <4E541945.6@panasas.com> <20110825201523.GA6901@merit.edu>
In-Reply-To: <20110825201523.GA6901@merit.edu>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/25/2011 01:15 PM, Jim Rees wrote:
> 
> We discussed this on the call today.  Boaz is going to write a brief
> description of how to fix this in the generic layer, then I'm going to
> implement it.

For blocks and objects we need something like the below [1].
(Done only for reads)

But I suspect I now broke files-LD. For files-LD what it actually
needs, (As I understood from trond) Is the same code like today
but with a similar patch as Peng's but for files-LD that sets
pg_bsize to the minimum of w/rsize and stripe_unit.

This is mainly because it needs that nfs_readpage_result/release_partial
which waits for all RPCs before it actually calls nfs_end_page_writeback
(PageUpTodate for reads) on that page that was shared between multiple
requests.

So I guess we need to do [2] option below (Only done for writes). 
+ With added code to set this bit_flag in objects and blocks.
  (Just like PNFS_LAYOUTRET_ON_SETATTR)
+ files-LD code to override pnfs_generic_pg_init_read/write and
  set pg_bsize to min(pg_bsize, stripe_unit). (Can be its own patch)
+ Define empty pnfs_ld_ignore_rwsize() for !CONFIG_NFS_V4_1

---------------------------------------------------------------
[1] (only reads)

   Do not use nfs_pagein_multi() for the pNFS case ...

-----
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index ab12913..a4d0191 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -296,7 +296,7 @@ extern int nfs_access_cache_shrinker(struct shrinker *shrink,
 extern int nfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
 			     const struct rpc_call_ops *call_ops);
 extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
-extern int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
+extern int nfs_pagein_one(struct nfs_pageio_descriptor *desc,
 		struct list_head *head);
 
 extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e550e88..b7e3e41 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1356,7 +1356,7 @@ struct pnfs_layout_segment *
 	LIST_HEAD(head);
 	int ret;
 
-	ret = nfs_generic_pagein(desc, &head);
+	ret = nfs_pagein_one(desc, &head);
 	if (ret != 0) {
 		put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 2171c04..ce5982a 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -336,7 +336,7 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc, struct list_head
 	return -ENOMEM;
 }
 
-static int nfs_pagein_one(struct nfs_pageio_descriptor *desc, struct list_head *res)
+int nfs_pagein_one(struct nfs_pageio_descriptor *desc, struct list_head *res)
 {
 	struct nfs_page		*req;
 	struct page		**pages;
@@ -369,19 +369,15 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc, struct list_head *
 	return ret;
 }
 
-int nfs_generic_pagein(struct nfs_pageio_descriptor *desc, struct list_head *head)
-{
-	if (desc->pg_bsize < PAGE_CACHE_SIZE)
-		return nfs_pagein_multi(desc, head);
-	return nfs_pagein_one(desc, head);
-}
-
 static int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 {
 	LIST_HEAD(head);
 	int ret;
 
-	ret = nfs_generic_pagein(desc, &head);
+	if (desc->pg_bsize < PAGE_CACHE_SIZE)
+		ret = nfs_pagein_multi(desc, &head);
+	else
+		ret = nfs_pagein_one(desc, &head);
 	if (ret == 0)
 		ret = nfs_do_multiple_reads(&head, desc->pg_rpc_callops);
 	return ret;

---------------------------------------------------------------
[2] (only writes)
  
     Do not use nfs_pagein_multi() for layout drivers that
     must not use it. (Objects and Blocks) ...

-------
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 01cbfd5..d32538a 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -68,6 +68,8 @@ enum {
 enum layoutdriver_policy_flags {
 	/* Should the pNFS client commit and return the layout upon a setattr */
 	PNFS_LAYOUTRET_ON_SETATTR	= 1 << 0,
+	/* Do not use nfs_xxx_partial_ops */
+	PNFS_IGNOR_RWSIZE		= 2 << 0,
 };
 
 struct nfs4_deviceid_node;
@@ -315,6 +317,15 @@ static inline void pnfs_clear_request_commit(struct nfs_page *req)
 		PNFS_LAYOUTRET_ON_SETATTR;
 }
 
+static inline bool
+pnfs_ld_ignore_rwsize(struct inode *inode)
+{
+	if (!pnfs_enabled_sb(NFS_SERVER(inode)))
+		return false;
+	return NFS_SERVER(inode)->pnfs_curr_ld->flags &
+		PNFS_IGNOR_RWSIZE;
+}
+
 static inline int pnfs_return_layout(struct inode *ino)
 {
 	struct nfs_inode *nfsi = NFS_I(ino);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index b39b37f..6b25073 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1029,7 +1029,8 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc, struct list_head *r
 
 int nfs_generic_flush(struct nfs_pageio_descriptor *desc, struct list_head *head)
 {
-	if (desc->pg_bsize < PAGE_CACHE_SIZE)
+	if (!pnfs_ld_ignore_rwsize(desc->pg_inode) &&
+	    desc->pg_bsize < PAGE_CACHE_SIZE)
 		return nfs_flush_multi(desc, head);
 	return nfs_flush_one(desc, head);
 }
