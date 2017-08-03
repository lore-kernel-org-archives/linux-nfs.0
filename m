Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34665 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751942AbdHCNqG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 09:46:06 -0400
Received: by mail-it0-f65.google.com with SMTP id t78so1321338ita.1
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 06:46:05 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 25/28] NFSv4/pnfs: Replace pnfs_put_lseg_locked() with pnfs_put_lseg()
Date: Thu,  3 Aug 2017 09:45:20 -0400
Message-Id: <20170803134523.4922-26-trond.myklebust@primarydata.com>
In-Reply-To: <20170803134523.4922-25-trond.myklebust@primarydata.com>
References: <20170803134523.4922-1-trond.myklebust@primarydata.com>
 <20170803134523.4922-2-trond.myklebust@primarydata.com>
 <20170803134523.4922-3-trond.myklebust@primarydata.com>
 <20170803134523.4922-4-trond.myklebust@primarydata.com>
 <20170803134523.4922-5-trond.myklebust@primarydata.com>
 <20170803134523.4922-6-trond.myklebust@primarydata.com>
 <20170803134523.4922-7-trond.myklebust@primarydata.com>
 <20170803134523.4922-8-trond.myklebust@primarydata.com>
 <20170803134523.4922-9-trond.myklebust@primarydata.com>
 <20170803134523.4922-10-trond.myklebust@primarydata.com>
 <20170803134523.4922-11-trond.myklebust@primarydata.com>
 <20170803134523.4922-12-trond.myklebust@primarydata.com>
 <20170803134523.4922-13-trond.myklebust@primarydata.com>
 <20170803134523.4922-14-trond.myklebust@primarydata.com>
 <20170803134523.4922-15-trond.myklebust@primarydata.com>
 <20170803134523.4922-16-trond.myklebust@primarydata.com>
 <20170803134523.4922-17-trond.myklebust@primarydata.com>
 <20170803134523.4922-18-trond.myklebust@primarydata.com>
 <20170803134523.4922-19-trond.myklebust@primarydata.com>
 <20170803134523.4922-20-trond.myklebust@primarydata.com>
 <20170803134523.4922-21-trond.myklebust@primarydata.com>
 <20170803134523.4922-22-trond.myklebust@primarydata.com>
 <20170803134523.4922-23-trond.myklebust@primarydata.com>
 <20170803134523.4922-24-trond.myklebust@primarydata.com>
 <20170803134523.4922-25-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we no longer hold the inode->i_lock when manipulating the
commit lists, it is safe to call pnfs_put_lseg() again.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c     | 41 -----------------------------------------
 fs/nfs/pnfs.h     |  2 --
 fs/nfs/pnfs_nfs.c |  4 ++--
 3 files changed, 2 insertions(+), 45 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c383d0913b54..3125a9d7b237 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -529,47 +529,6 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 }
 EXPORT_SYMBOL_GPL(pnfs_put_lseg);
 
-static void pnfs_free_lseg_async_work(struct work_struct *work)
-{
-	struct pnfs_layout_segment *lseg;
-	struct pnfs_layout_hdr *lo;
-
-	lseg = container_of(work, struct pnfs_layout_segment, pls_work);
-	lo = lseg->pls_layout;
-
-	pnfs_free_lseg(lseg);
-	pnfs_put_layout_hdr(lo);
-}
-
-static void pnfs_free_lseg_async(struct pnfs_layout_segment *lseg)
-{
-	INIT_WORK(&lseg->pls_work, pnfs_free_lseg_async_work);
-	schedule_work(&lseg->pls_work);
-}
-
-void
-pnfs_put_lseg_locked(struct pnfs_layout_segment *lseg)
-{
-	if (!lseg)
-		return;
-
-	assert_spin_locked(&lseg->pls_layout->plh_inode->i_lock);
-
-	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
-		atomic_read(&lseg->pls_refcount),
-		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
-	if (atomic_dec_and_test(&lseg->pls_refcount)) {
-		struct pnfs_layout_hdr *lo = lseg->pls_layout;
-		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags))
-			return;
-		pnfs_layout_remove_lseg(lo, lseg);
-		if (!pnfs_cache_lseg_for_layoutreturn(lo, lseg)) {
-			pnfs_get_layout_hdr(lo);
-			pnfs_free_lseg_async(lseg);
-		}
-	}
-}
-
 /*
  * is l2 fully contained in l1?
  *   start1                             end1
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 99731e3e332f..87f144f14d1e 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -67,7 +67,6 @@ struct pnfs_layout_segment {
 	u32 pls_seq;
 	unsigned long pls_flags;
 	struct pnfs_layout_hdr *pls_layout;
-	struct work_struct pls_work;
 };
 
 enum pnfs_try_status {
@@ -230,7 +229,6 @@ extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool sync);
 /* pnfs.c */
 void pnfs_get_layout_hdr(struct pnfs_layout_hdr *lo);
 void pnfs_put_lseg(struct pnfs_layout_segment *lseg);
-void pnfs_put_lseg_locked(struct pnfs_layout_segment *lseg);
 
 void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, struct nfs_fsinfo *);
 void unset_pnfs_layoutdriver(struct nfs_server *);
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 2cdee8ce2094..4b0a809653d1 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -83,7 +83,7 @@ pnfs_generic_clear_request_commit(struct nfs_page *req,
 	}
 out:
 	nfs_request_remove_commit_list(req, cinfo);
-	pnfs_put_lseg_locked(freeme);
+	pnfs_put_lseg(freeme);
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_clear_request_commit);
 
@@ -126,7 +126,7 @@ pnfs_generic_scan_ds_commit_list(struct pnfs_commit_bucket *bucket,
 		if (bucket->clseg == NULL)
 			bucket->clseg = pnfs_get_lseg(bucket->wlseg);
 		if (list_empty(src)) {
-			pnfs_put_lseg_locked(bucket->wlseg);
+			pnfs_put_lseg(bucket->wlseg);
 			bucket->wlseg = NULL;
 		}
 	}
-- 
2.13.3

