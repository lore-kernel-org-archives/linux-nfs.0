Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:34610 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751839AbbHYBnJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Aug 2015 21:43:09 -0400
Received: by iodb91 with SMTP id b91so169540753iod.1
        for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2015 18:43:09 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] NFSv4.1/flexfiles: Add refcounting to struct nfs4_ff_layout_mirror
Date: Mon, 24 Aug 2015 21:43:03 -0400
Message-Id: <1440466986-36826-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We do want to share mirrors between layout segments, so add a refcount
to enable that.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 36 +++++++++++++++++++++++++---------
 fs/nfs/flexfilelayout/flexfilelayout.h |  1 +
 2 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index cc2c5f7f2bc1..62de0b8038c8 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -135,6 +135,31 @@ decode_name(struct xdr_stream *xdr, u32 *id)
 	return 0;
 }
 
+static struct nfs4_ff_layout_mirror *ff_layout_alloc_mirror(gfp_t gfp_flags)
+{
+	struct nfs4_ff_layout_mirror *mirror;
+
+	mirror = kzalloc(sizeof(*mirror), gfp_flags);
+	if (mirror != NULL) {
+		spin_lock_init(&mirror->lock);
+		atomic_set(&mirror->ref, 1);
+	}
+	return mirror;
+}
+
+static void ff_layout_free_mirror(struct nfs4_ff_layout_mirror *mirror)
+{
+	kfree(mirror->fh_versions);
+	nfs4_ff_layout_put_deviceid(mirror->mirror_ds);
+	kfree(mirror);
+}
+
+static void ff_layout_put_mirror(struct nfs4_ff_layout_mirror *mirror)
+{
+	if (mirror != NULL && atomic_dec_and_test(&mirror->ref))
+		ff_layout_free_mirror(mirror);
+}
+
 static void ff_layout_free_mirror_array(struct nfs4_ff_layout_segment *fls)
 {
 	int i;
@@ -144,11 +169,7 @@ static void ff_layout_free_mirror_array(struct nfs4_ff_layout_segment *fls)
 			/* normally mirror_ds is freed in
 			 * .free_deviceid_node but we still do it here
 			 * for .alloc_lseg error path */
-			if (fls->mirror_array[i]) {
-				kfree(fls->mirror_array[i]->fh_versions);
-				nfs4_ff_layout_put_deviceid(fls->mirror_array[i]->mirror_ds);
-				kfree(fls->mirror_array[i]);
-			}
+			ff_layout_put_mirror(fls->mirror_array[i]);
 		}
 		kfree(fls->mirror_array);
 		fls->mirror_array = NULL;
@@ -262,15 +283,12 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 		if (ds_count != 1)
 			goto out_err_free;
 
-		fls->mirror_array[i] =
-			kzalloc(sizeof(struct nfs4_ff_layout_mirror),
-				gfp_flags);
+		fls->mirror_array[i] = ff_layout_alloc_mirror(gfp_flags);
 		if (fls->mirror_array[i] == NULL) {
 			rc = -ENOMEM;
 			goto out_err_free;
 		}
 
-		spin_lock_init(&fls->mirror_array[i]->lock);
 		fls->mirror_array[i]->ds_count = ds_count;
 		fls->mirror_array[i]->lseg = &fls->generic_hdr;
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index f92f9a0a856b..26b8258e256f 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -77,6 +77,7 @@ struct nfs4_ff_layout_mirror {
 	u32				uid;
 	u32				gid;
 	struct rpc_cred			*cred;
+	atomic_t			ref;
 	spinlock_t			lock;
 	struct nfs4_ff_layoutstat	read_stat;
 	struct nfs4_ff_layoutstat	write_stat;
-- 
2.4.3

