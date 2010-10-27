Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og113.obsmtp.com ([64.18.0.26]:39101 "HELO
	exprod5og113.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754638Ab0J0SX6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Oct 2010 14:23:58 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] pnfs: do not change layout stateid when dropping layouts.
Date: Wed, 27 Oct 2010 20:23:52 +0200
Message-Id: <1288203832-26840-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CC86D96.8020803@panasas.com>
References: <4CC86D96.8020803@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

On voluntary "forgets", where the client drops the layout on its own
the inode's layotu stateid must not change.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c        |    1 +
 fs/nfs/pnfs.c           |    6 ++++--
 include/linux/nfs_xdr.h |    1 +
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 6d86633..31ccacf 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5243,6 +5243,7 @@ static int decode_layoutreturn(struct xdr_stream *xdr,
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
+	res->valid = true;
 	res->lrs_present = be32_to_cpup(p);
 	if (res->lrs_present)
 		status = decode_stateid(xdr, &res->stateid);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ff1749a..8fa4887 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -593,9 +593,11 @@ pnfs_layoutreturn_release(struct nfs4_layoutreturn *lrp)
 		return;
 	spin_lock(&lrp->args.inode->i_lock);
 	pnfs_clear_lseg_list(lo, &tmp_list, &lrp->args.range);
-	if (!lrp->res.lrs_present)
+	if (!lrp->res.valid)
+		;	/* forgetful model internal release */
+	else if (!lrp->res.lrs_present)
 		pnfs_invalidate_layout_stateid(lo);
-	else
+	else 
 		pnfs_set_layout_stateid(lo, &lrp->res.stateid);
 	put_layout_hdr_locked(lo); /* Matched in _pnfs_return_layout */
 	spin_unlock(&lrp->args.inode->i_lock);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 80e6a36..37ff78a 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -269,6 +269,7 @@ struct nfs4_layoutreturn_args {
 
 struct nfs4_layoutreturn_res {
 	struct nfs4_sequence_res seq_res;
+	bool valid;	/* internal, true if received reply */
 	u32 lrs_present;
 	nfs4_stateid stateid;
 };
-- 
1.7.2.3

