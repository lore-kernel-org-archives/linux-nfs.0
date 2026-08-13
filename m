Received: from mail-oi1-f179.google.com (mail-oi1-f179.google.com [209.85.167.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3C16E40F72F
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:43:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.179
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653810; cv=none; b=F/3K4/Le0RT0ZqpEOqFbJcGFiLLEKA30iNhNYtZjp04QPNAyDg3MPeE8hNySEnT248JPhjpW2ONk8HJ/SMQrdkxxE5Rjc1szzjPvzq7v7ZKDr8qHa/WqOtL8mU/DZNE3qxp6OucCpOhlrXItYZ2dv0hzWoYRCMPfk3hPcIBXHOA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653810; c=relaxed/simple;
	bh=BP2eoyU/CBozH2g72hkvO42pUisb6NCo8tpFZSJ1TJE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jAS72sSKK0Gsx5PXfFixgpOcPm8nl6QLMH1rb6j7auNvIX1BA1FNWG/k4RqdfCck7e2jC0PfrLcWOvfoW61rmSBZTqclfuQQi/hT1q8OT42DnzzT0zAlaP+vRdBxCTieaM1neEW8bJ/8FUE+J4fg7BXFjYuaoWxKx7xKArIi/XE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=PJOo9iVP; arc=none smtp.client-ip=209.85.167.179
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="PJOo9iVP"
Received: by mail-oi1-f179.google.com with SMTP id 5614622812f47-4b21f09ea42so131259b6e.2
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:43:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653807; x=1787258607; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=/IjsgxVH0ureHp/TctVxQaOSx7wuHSVol4ST6KojGjo=;
        b=PJOo9iVPZOjcQ315bKZovdzsER97QzeThr7rF/NpuqxY+6PgB6K89Vj87sEuATO+pV
         SylekaE0PDBfVyXRbYVuaOXlSiq+E0iO1Eu4MAuNhPsrjlbdmQF86fUdM+eLfUf6MLMQ
         VJ1Er+kM6HmU1BZlQgTDD4aqvPFvainpMcV9cjQ3CEfkqym2kY4w4iNLrOw/UQsrQ/UG
         Qh07dGjhqLDM2VYHmHV4UjnWQEtf53P95XZobcBcg/Lcmlzsbv2EMiQKHh2CYyPwzokk
         oxAQdLjBaTRwy12B+UpN2opNHwguIYsUeLNTQHWtINt7EXeGu+mRaucB3FWPUB+T5nrw
         PU9Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653807; x=1787258607;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=/IjsgxVH0ureHp/TctVxQaOSx7wuHSVol4ST6KojGjo=;
        b=EvL74YMBluwV02tTU7EJR8Qt23XPm6DwSfxaFn/CzQlXkO7hmMBL0uY8mXeLsfrReG
         3IkAX9WeahAuSx75ZeFo+5zoi9Nr+PlIYk7lJ3YQXuqVYcNhUZxgWkLLmG7eRB4mUL7n
         JU8dUDsmdV1MbPJjh0aCg/ZaRzrscTQ4RuEU1u/b0EQkDub2aa7jxD2rag39C+d0YQjB
         08HQDq68Xu8nZ7zJhuTbdLwJOCFSYcTlyw3x/Gme1tyrW/I/RcPDD63fGbE0gx6sqHLy
         A5I39V1N41G736NntYV0nd2Lrmc7hsGUfkyvQ9ojwd2Zn72ay7f/ir2Udfkz4GfkbTsX
         VcqA==
X-Gm-Message-State: AOJu0YxSgQ9hMflulG5r92Uy8ZQRRwGjuVi6fG/dcXvg0uc7Cwwds1aE
	8gKg58q/zNfRlAXGKHQFFUlkZ4ywZYeefzZCXiaN2NmSpxgIl8MlnrdDYFLxa19FsJg=
X-Gm-Gg: AR+sD124J9a0UrI4sqgaSo+nUc3DOL7jcjAjTYL/rX571w8eCRuZb8jFdZ2cGZoXRsz
	YWMKhW1UMWoZmG6/yoeecji1eYmJojUZOqGeARvoEQiM+tfd+IHHMyqexIAii0kpgu3zTsz60+D
	acz4UlyYT1sVblkQCK9WBzs35BazVZYkhHMKzAmxn6UhsVsZoycqoFWavJC6sufmZZfttlz/WoR
	YSc4aZJHDtnJlbePlTQnLLRfgF+Wxia4Pzk/3jxx49gnm5SuaotYzLr+zP+sSNjTNtEOZVxk1Iq
	Ra54Erfm0CUQ4FKg9npDrocHhX0MP06bT9pxNTzgLrw1TyTIbU7cr1KUfclSPuhz3AldkseGvAK
	drsjx3mOE9twdw8gHKVp8xaLnyqMVaZN8QDVLvNNg6nz4hBceuKJsNrHQy2SmUeChO4L1haCw+R
	rXdMFwk4jTO7NDRPtEtQMjqjw2He+oA3RRCY9QtcZBlK99JFR/qOl+77fnxtuBHDfkoiDDrxU6S
	2igRGd6t8Ftvz08sSOdK8rQ
X-Received: by 2002:a05:6808:1387:b0:485:48da:133d with SMTP id 5614622812f47-4b241ba147bmr801184b6e.10.1786653807087;
        Thu, 13 Aug 2026 13:43:27 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b22c8c09e4sm2484254b6e.0.2026.08.13.13.43.25
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:43:26 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 05/21] NFSv4/flexfiles: Reference the device node across DS setup
Date: Thu, 13 Aug 2026 16:43:01 -0400
Message-ID: <347fed6d627802ef28c9f7388a3e780f57c5589c.1786653063.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1786653063.git.bcodding@hammerspace.com>
References: <cover.1786653063.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The flexfiles I/O setup paths read the mirror's pinned per-stripe device
node (mirror->dss[dss_id].mirror_ds) repeatedly and locklessly, relying
on the mirror's lifetime pin.  To prepare for re-resolving that pointer
in place on CB_NOTIFY_DEVICEID CHANGE, readers must hold their own
reference on the node they are using rather than trusting the pin.

Replace ff_layout_init_mirror_ds() with ff_layout_get_mirror_ds(), which
resolves on first use as before but returns the node with its own
reference held.  Thread the referenced node through
nfs4_ff_layout_prepare_ds() and the DS selection helpers so each setup
path snapshots the node once, and drop the reference when setup is done.

No functional change: the pointer is still resolved once and pinned for
the life of the mirror.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    | 140 ++++++++++++++--------
 fs/nfs/flexfilelayout/flexfilelayout.h    |  16 ++-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  81 ++++++++-----
 3 files changed, 149 insertions(+), 88 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 692ad84047d4..2bdc74a9a3eb 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -875,7 +875,7 @@ ff_layout_mark_ds_reachable(struct pnfs_layout_segment *lseg, u32 idx, u32 dss_i
 		nfs4_mark_deviceid_available(devid);
 }
 
-static struct nfs4_pnfs_ds *
+static struct nfs4_ff_layout_ds *
 ff_layout_choose_ds_for_read(struct pnfs_layout_segment *lseg,
 			     u32 start_idx, u32 *best_idx,
 			     u64 offset, u32 *dss_id,
@@ -883,7 +883,9 @@ ff_layout_choose_ds_for_read(struct pnfs_layout_segment *lseg,
 {
 	struct nfs4_ff_layout_segment *fls = FF_LAYOUT_LSEG(lseg);
 	struct nfs4_ff_layout_mirror *mirror;
-	struct nfs4_pnfs_ds *ds = ERR_PTR(-EAGAIN);
+	struct nfs4_ff_layout_ds *mirror_ds;
+	struct nfs4_ff_layout_ds *ret = ERR_PTR(-EAGAIN);
+	struct nfs4_pnfs_ds *ds;
 	u32 idx;
 
 	/* mirrors are initially sorted by efficiency */
@@ -893,25 +895,32 @@ ff_layout_choose_ds_for_read(struct pnfs_layout_segment *lseg,
 			fls->stripe_unit,
 			fls->mirror_array[idx]->dss_count,
 			offset);
-		ds = nfs4_ff_layout_prepare_ds(lseg, mirror, *dss_id, false);
-		if (IS_ERR(ds))
+		mirror_ds = ff_layout_get_mirror_ds(lseg->pls_layout, mirror,
+						    *dss_id);
+		ds = nfs4_ff_layout_prepare_ds(lseg, mirror, mirror_ds,
+					       *dss_id, false);
+		if (IS_ERR(ds)) {
+			nfs4_ff_layout_put_deviceid(mirror_ds);
+			ret = ERR_CAST(ds);
 			continue;
+		}
 
 		if (check_device &&
-		    nfs4_test_deviceid_unavailable(&mirror->dss[*dss_id].mirror_ds->id_node)) {
+		    nfs4_test_deviceid_unavailable(&mirror_ds->id_node)) {
+			nfs4_ff_layout_put_deviceid(mirror_ds);
 			// reinitialize the error state in case if this is the last iteration
-			ds = ERR_PTR(-EINVAL);
+			ret = ERR_PTR(-EINVAL);
 			continue;
 		}
 
 		*best_idx = idx;
-		break;
+		return mirror_ds;
 	}
 
-	return ds;
+	return ret;
 }
 
-static struct nfs4_pnfs_ds *
+static struct nfs4_ff_layout_ds *
 ff_layout_choose_any_ds_for_read(struct pnfs_layout_segment *lseg,
 				 u32 start_idx, u32 *best_idx,
 				 u64 offset, u32 *dss_id)
@@ -920,7 +929,7 @@ ff_layout_choose_any_ds_for_read(struct pnfs_layout_segment *lseg,
 					    offset, dss_id, false);
 }
 
-static struct nfs4_pnfs_ds *
+static struct nfs4_ff_layout_ds *
 ff_layout_choose_valid_ds_for_read(struct pnfs_layout_segment *lseg,
 				   u32 start_idx, u32 *best_idx,
 				   u64 offset, u32 *dss_id)
@@ -929,34 +938,36 @@ ff_layout_choose_valid_ds_for_read(struct pnfs_layout_segment *lseg,
 					    offset, dss_id, true);
 }
 
-static struct nfs4_pnfs_ds *
+static struct nfs4_ff_layout_ds *
 ff_layout_choose_best_ds_for_read(struct pnfs_layout_segment *lseg,
 				  u32 start_idx, u32 *best_idx,
 				  u64 offset, u32 *dss_id)
 {
-	struct nfs4_pnfs_ds *ds;
+	struct nfs4_ff_layout_ds *mirror_ds;
 
-	ds = ff_layout_choose_valid_ds_for_read(lseg, start_idx, best_idx,
-						offset, dss_id);
-	if (!IS_ERR(ds))
-		return ds;
+	mirror_ds = ff_layout_choose_valid_ds_for_read(lseg, start_idx,
+							best_idx, offset,
+							dss_id);
+	if (!IS_ERR(mirror_ds))
+		return mirror_ds;
 	return ff_layout_choose_any_ds_for_read(lseg, start_idx, best_idx,
 						offset, dss_id);
 }
 
-static struct nfs4_pnfs_ds *
+static struct nfs4_ff_layout_ds *
 ff_layout_get_ds_for_read(struct nfs_pageio_descriptor *pgio,
 			  u32 *best_idx,
 			  u64 offset,
 			  u32 *dss_id)
 {
 	struct pnfs_layout_segment *lseg = pgio->pg_lseg;
-	struct nfs4_pnfs_ds *ds;
+	struct nfs4_ff_layout_ds *mirror_ds;
 
-	ds = ff_layout_choose_best_ds_for_read(lseg, pgio->pg_mirror_idx,
-					       best_idx, offset, dss_id);
-	if (!IS_ERR(ds) || !pgio->pg_mirror_idx)
-		return ds;
+	mirror_ds = ff_layout_choose_best_ds_for_read(lseg,
+						      pgio->pg_mirror_idx,
+						      best_idx, offset, dss_id);
+	if (!IS_ERR(mirror_ds) || !pgio->pg_mirror_idx)
+		return mirror_ds;
 	return ff_layout_choose_best_ds_for_read(lseg, 0, best_idx,
 						 offset, dss_id);
 }
@@ -1031,8 +1042,7 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 			struct nfs_page *req)
 {
 	struct nfs_pgio_mirror *pgm;
-	struct nfs4_ff_layout_mirror *mirror;
-	struct nfs4_pnfs_ds *ds;
+	struct nfs4_ff_layout_ds *mirror_ds;
 	u32 ds_idx, dss_id;
 
 	if (NFS_SERVER(pgio->pg_inode)->flags &
@@ -1054,9 +1064,9 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 	/* Reset wb_nio, since getting layout segment was successful */
 	req->wb_nio = 0;
 
-	ds = ff_layout_get_ds_for_read(pgio, &ds_idx,
-				       req_offset(req), &dss_id);
-	if (IS_ERR(ds)) {
+	mirror_ds = ff_layout_get_ds_for_read(pgio, &ds_idx,
+					      req_offset(req), &dss_id);
+	if (IS_ERR(mirror_ds)) {
 		if (!ff_layout_no_fallback_to_mds(pgio->pg_lseg))
 			goto out_mds;
 		pnfs_generic_pg_cleanup(pgio);
@@ -1065,9 +1075,9 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 		goto retry;
 	}
 
-	mirror = FF_LAYOUT_COMP(pgio->pg_lseg, ds_idx);
 	pgm = &pgio->pg_mirrors[0];
-	pgm->pg_bsize = mirror->dss[dss_id].mirror_ds->ds_versions[0].rsize;
+	pgm->pg_bsize = mirror_ds->ds_versions[0].rsize;
+	nfs4_ff_layout_put_deviceid(mirror_ds);
 
 	pgio->pg_mirror_idx = ds_idx;
 	return;
@@ -1102,6 +1112,7 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			struct nfs_page *req)
 {
 	struct nfs4_ff_layout_mirror *mirror;
+	struct nfs4_ff_layout_ds *mirror_ds;
 	struct nfs_pgio_mirror *pgm;
 	struct nfs4_pnfs_ds *ds;
 	u32 i, dss_id;
@@ -1133,9 +1144,12 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			FF_LAYOUT_LSEG(pgio->pg_lseg)->stripe_unit,
 			mirror->dss_count,
 			req_offset(req));
+		mirror_ds = ff_layout_get_mirror_ds(pgio->pg_lseg->pls_layout,
+						    mirror, dss_id);
 		ds = nfs4_ff_layout_prepare_ds(pgio->pg_lseg, mirror,
-					       dss_id, true);
+					       mirror_ds, dss_id, true);
 		if (IS_ERR(ds)) {
+			nfs4_ff_layout_put_deviceid(mirror_ds);
 			if (!ff_layout_no_fallback_to_mds(pgio->pg_lseg))
 				goto out_mds;
 			pnfs_generic_pg_cleanup(pgio);
@@ -1144,7 +1158,8 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			goto retry;
 		}
 		pgm = &pgio->pg_mirrors[i];
-		pgm->pg_bsize = mirror->dss[dss_id].mirror_ds->ds_versions[0].wsize;
+		pgm->pg_bsize = mirror_ds->ds_versions[0].wsize;
+		nfs4_ff_layout_put_deviceid(mirror_ds);
 	}
 
 	if (NFS_SERVER(pgio->pg_inode)->flags &
@@ -1276,14 +1291,16 @@ static void ff_layout_resend_pnfs_read(struct nfs_pgio_header *hdr)
 	u32 idx = hdr->pgio_mirror_idx + 1;
 	u32 new_idx = 0;
 	u32 dss_id = 0;
-	struct nfs4_pnfs_ds *ds;
+	struct nfs4_ff_layout_ds *mirror_ds;
 
-	ds = ff_layout_choose_any_ds_for_read(hdr->lseg, idx, &new_idx,
-					      hdr->args.offset, &dss_id);
-	if (IS_ERR(ds))
+	mirror_ds = ff_layout_choose_any_ds_for_read(hdr->lseg, idx, &new_idx,
+						     hdr->args.offset, &dss_id);
+	if (IS_ERR(mirror_ds)) {
 		pnfs_error_mark_layout_for_return(hdr->inode, hdr->lseg);
-	else
+	} else {
+		nfs4_ff_layout_put_deviceid(mirror_ds);
 		ff_layout_send_layouterror(hdr->lseg);
+	}
 	pnfs_read_resend_pnfs(hdr, new_idx);
 }
 
@@ -2144,6 +2161,7 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 	struct rpc_clnt *ds_clnt;
 	struct nfsd_file *localio;
 	struct nfs4_ff_layout_mirror *mirror;
+	struct nfs4_ff_layout_ds *mirror_ds;
 	const struct cred *ds_cred;
 	loff_t offset = hdr->args.offset;
 	u32 idx = hdr->pgio_mirror_idx;
@@ -2161,22 +2179,24 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 		FF_LAYOUT_LSEG(lseg)->stripe_unit,
 		mirror->dss_count,
 		offset);
-	ds = nfs4_ff_layout_prepare_ds(lseg, mirror, dss_id, false);
+	mirror_ds = ff_layout_get_mirror_ds(lseg->pls_layout, mirror, dss_id);
+	ds = nfs4_ff_layout_prepare_ds(lseg, mirror, mirror_ds, dss_id, false);
 	if (IS_ERR(ds)) {
 		ds_fatal_error = nfs_error_is_fatal(PTR_ERR(ds));
 		goto out_failed;
 	}
 
-	ds_clnt = nfs4_ff_find_or_create_ds_client(mirror, ds->ds_clp,
-						   hdr->inode, dss_id);
+	ds_clnt = nfs4_ff_find_or_create_ds_client(mirror_ds, ds->ds_clp,
+						   hdr->inode);
 	if (IS_ERR(ds_clnt))
 		goto out_failed;
 
-	ds_cred = ff_layout_get_ds_cred(mirror, &lseg->pls_range, hdr->cred, dss_id);
+	ds_cred = ff_layout_get_ds_cred(mirror, &lseg->pls_range, hdr->cred,
+					mirror_ds, dss_id);
 	if (!ds_cred)
 		goto out_failed;
 
-	vers = nfs4_ff_layout_ds_version(mirror, dss_id);
+	vers = nfs4_ff_layout_ds_version(mirror_ds);
 
 	dprintk("%s USE DS: %s cl_count %d vers %d\n", __func__,
 		ds->ds_remotestr, refcount_read(&ds->ds_clp->cl_count), vers);
@@ -2188,7 +2208,8 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 	if (fh)
 		hdr->args.fh = fh;
 
-	nfs4_ff_layout_select_ds_stateid(mirror, dss_id, &hdr->args.stateid);
+	nfs4_ff_layout_select_ds_stateid(mirror, mirror_ds, dss_id,
+					 &hdr->args.stateid);
 
 	/*
 	 * Note that if we ever decide to split across DSes,
@@ -2211,9 +2232,11 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 				      &ff_layout_read_call_ops_v4,
 			  0, RPC_TASK_SOFTCONN, localio);
 	put_cred(ds_cred);
+	nfs4_ff_layout_put_deviceid(mirror_ds);
 	return PNFS_ATTEMPTED;
 
 out_failed:
+	nfs4_ff_layout_put_deviceid(mirror_ds);
 	if (ff_layout_avoid_mds_available_ds(lseg) && !ds_fatal_error)
 		return PNFS_TRY_AGAIN;
 	if (ff_layout_no_fallback_to_mds(lseg)) {
@@ -2239,6 +2262,7 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 	struct rpc_clnt *ds_clnt;
 	struct nfsd_file *localio;
 	struct nfs4_ff_layout_mirror *mirror;
+	struct nfs4_ff_layout_ds *mirror_ds;
 	const struct cred *ds_cred;
 	loff_t offset = hdr->args.offset;
 	int vers;
@@ -2252,22 +2276,24 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 		FF_LAYOUT_LSEG(lseg)->stripe_unit,
 		mirror->dss_count,
 		offset);
-	ds = nfs4_ff_layout_prepare_ds(lseg, mirror, dss_id, true);
+	mirror_ds = ff_layout_get_mirror_ds(lseg->pls_layout, mirror, dss_id);
+	ds = nfs4_ff_layout_prepare_ds(lseg, mirror, mirror_ds, dss_id, true);
 	if (IS_ERR(ds)) {
 		ds_fatal_error = nfs_error_is_fatal(PTR_ERR(ds));
 		goto out_failed;
 	}
 
-	ds_clnt = nfs4_ff_find_or_create_ds_client(mirror, ds->ds_clp,
-						   hdr->inode, dss_id);
+	ds_clnt = nfs4_ff_find_or_create_ds_client(mirror_ds, ds->ds_clp,
+						   hdr->inode);
 	if (IS_ERR(ds_clnt))
 		goto out_failed;
 
-	ds_cred = ff_layout_get_ds_cred(mirror, &lseg->pls_range, hdr->cred, dss_id);
+	ds_cred = ff_layout_get_ds_cred(mirror, &lseg->pls_range, hdr->cred,
+					mirror_ds, dss_id);
 	if (!ds_cred)
 		goto out_failed;
 
-	vers = nfs4_ff_layout_ds_version(mirror, dss_id);
+	vers = nfs4_ff_layout_ds_version(mirror_ds);
 
 	dprintk("%s ino %llu sync %d req %zu@%llu DS: %s cl_count %d vers %d\n",
 		__func__, hdr->inode->i_ino, sync, (size_t) hdr->args.count,
@@ -2282,7 +2308,8 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 	if (fh)
 		hdr->args.fh = fh;
 
-	nfs4_ff_layout_select_ds_stateid(mirror, dss_id, &hdr->args.stateid);
+	nfs4_ff_layout_select_ds_stateid(mirror, mirror_ds, dss_id,
+					 &hdr->args.stateid);
 
 	/*
 	 * Note that if we ever decide to split across DSes,
@@ -2304,9 +2331,11 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 				      &ff_layout_write_call_ops_v4,
 			  sync, RPC_TASK_SOFTCONN, localio);
 	put_cred(ds_cred);
+	nfs4_ff_layout_put_deviceid(mirror_ds);
 	return PNFS_ATTEMPTED;
 
 out_failed:
+	nfs4_ff_layout_put_deviceid(mirror_ds);
 	if (ff_layout_avoid_mds_available_ds(lseg) && !ds_fatal_error)
 		return PNFS_TRY_AGAIN;
 	if (ff_layout_no_fallback_to_mds(lseg)) {
@@ -2341,6 +2370,7 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
 	struct rpc_clnt *ds_clnt;
 	struct nfsd_file *localio;
 	struct nfs4_ff_layout_mirror *mirror;
+	struct nfs4_ff_layout_ds *mirror_ds = NULL;
 	const struct cred *ds_cred;
 	u32 idx, dss_id;
 	int vers, ret;
@@ -2353,20 +2383,22 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
 	idx = calc_mirror_idx_from_commit(lseg, data->ds_commit_index);
 	mirror = FF_LAYOUT_COMP(lseg, idx);
 	dss_id = calc_dss_id_from_commit(lseg, data->ds_commit_index);
-	ds = nfs4_ff_layout_prepare_ds(lseg, mirror, dss_id, true);
+	mirror_ds = ff_layout_get_mirror_ds(lseg->pls_layout, mirror, dss_id);
+	ds = nfs4_ff_layout_prepare_ds(lseg, mirror, mirror_ds, dss_id, true);
 	if (IS_ERR(ds))
 		goto out_err;
 
-	ds_clnt = nfs4_ff_find_or_create_ds_client(mirror, ds->ds_clp,
-						   data->inode, dss_id);
+	ds_clnt = nfs4_ff_find_or_create_ds_client(mirror_ds, ds->ds_clp,
+						   data->inode);
 	if (IS_ERR(ds_clnt))
 		goto out_err;
 
-	ds_cred = ff_layout_get_ds_cred(mirror, &lseg->pls_range, data->cred, dss_id);
+	ds_cred = ff_layout_get_ds_cred(mirror, &lseg->pls_range, data->cred,
+					mirror_ds, dss_id);
 	if (!ds_cred)
 		goto out_err;
 
-	vers = nfs4_ff_layout_ds_version(mirror, dss_id);
+	vers = nfs4_ff_layout_ds_version(mirror_ds);
 
 	dprintk("%s ino %llu, how %d cl_count %d vers %d\n", __func__,
 		data->inode->i_ino, how, refcount_read(&ds->ds_clp->cl_count),
@@ -2392,8 +2424,10 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
 					       &ff_layout_commit_call_ops_v4,
 				   how, RPC_TASK_SOFTCONN, localio);
 	put_cred(ds_cred);
+	nfs4_ff_layout_put_deviceid(mirror_ds);
 	return ret;
 out_err:
+	nfs4_ff_layout_put_deviceid(mirror_ds);
 	pnfs_generic_prepare_to_resend_writes(data);
 	pnfs_generic_commit_release(data);
 	return -EAGAIN;
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index a5bd00f69e82..a65cdffe325b 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -207,9 +207,9 @@ ff_layout_no_read_on_rw(struct pnfs_layout_segment *lseg)
 }
 
 static inline int
-nfs4_ff_layout_ds_version(const struct nfs4_ff_layout_mirror *mirror, u32 dss_id)
+nfs4_ff_layout_ds_version(const struct nfs4_ff_layout_ds *mirror_ds)
 {
-	return mirror->dss[dss_id].mirror_ds->ds_versions[0].version;
+	return mirror_ds->ds_versions[0].version;
 }
 
 static inline u32
@@ -245,23 +245,29 @@ struct nfs_fh *
 nfs4_ff_layout_select_ds_fh(struct nfs4_ff_layout_mirror *mirror, u32 dss_id);
 void
 nfs4_ff_layout_select_ds_stateid(const struct nfs4_ff_layout_mirror *mirror,
+				 const struct nfs4_ff_layout_ds *mirror_ds,
 				 u32 dss_id,
 				 nfs4_stateid *stateid);
 
+struct nfs4_ff_layout_ds *
+ff_layout_get_mirror_ds(struct pnfs_layout_hdr *lo,
+			struct nfs4_ff_layout_mirror *mirror,
+			u32 dss_id);
 struct nfs4_pnfs_ds *
 nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 			  struct nfs4_ff_layout_mirror *mirror,
+			  struct nfs4_ff_layout_ds *mirror_ds,
 			  u32 dss_id,
 			  bool fail_return);
 
 struct rpc_clnt *
-nfs4_ff_find_or_create_ds_client(struct nfs4_ff_layout_mirror *mirror,
+nfs4_ff_find_or_create_ds_client(const struct nfs4_ff_layout_ds *mirror_ds,
 				 struct nfs_client *ds_clp,
-				 struct inode *inode,
-				 u32 dss_id);
+				 struct inode *inode);
 const struct cred *ff_layout_get_ds_cred(struct nfs4_ff_layout_mirror *mirror,
 					 const struct pnfs_layout_range *range,
 					 const struct cred *mdscred,
+					 const struct nfs4_ff_layout_ds *mirror_ds,
 					 u32 dss_id);
 bool ff_layout_avoid_mds_available_ds(struct pnfs_layout_segment *lseg);
 bool ff_layout_avoid_read_on_rw(struct pnfs_layout_segment *lseg);
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 1109462a9699..b44281406011 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -316,24 +316,42 @@ nfs4_ff_layout_select_ds_fh(struct nfs4_ff_layout_mirror *mirror, u32 dss_id)
 
 void
 nfs4_ff_layout_select_ds_stateid(const struct nfs4_ff_layout_mirror *mirror,
+				 const struct nfs4_ff_layout_ds *mirror_ds,
 				 u32 dss_id,
 				 nfs4_stateid *stateid)
 {
-	if (nfs4_ff_layout_ds_version(mirror, dss_id) == 4)
+	if (nfs4_ff_layout_ds_version(mirror_ds) == 4)
 		nfs4_stateid_copy(stateid, &mirror->dss[dss_id].stateid);
 }
 
-static bool
-ff_layout_init_mirror_ds(struct pnfs_layout_hdr *lo,
-			 struct nfs4_ff_layout_mirror *mirror,
-			 u32 dss_id)
+/**
+ * ff_layout_get_mirror_ds - get a reference to a stripe's device node
+ * @lo: the layout header
+ * @mirror: layout mirror
+ * @dss_id: DS stripe id within the mirror
+ *
+ * Resolve the stripe's deviceid on first use and pin the resulting node
+ * on the mirror; every caller additionally gets its own reference so the
+ * node stays valid for as long as the caller uses it, independent of the
+ * mirror's pin.
+ *
+ * Returns a referenced device node on success, an ERR_PTR otherwise.
+ */
+struct nfs4_ff_layout_ds *
+ff_layout_get_mirror_ds(struct pnfs_layout_hdr *lo,
+			struct nfs4_ff_layout_mirror *mirror,
+			u32 dss_id)
 {
+	struct nfs4_ff_layout_ds *mirror_ds;
+
 	if (mirror == NULL)
-		goto outerr;
-	if (mirror->dss[dss_id].mirror_ds == NULL) {
+		return ERR_PTR(-ENODEV);
+
+	mirror_ds = mirror->dss[dss_id].mirror_ds;
+	if (mirror_ds == NULL) {
 		struct nfs4_deviceid_node *node;
-		struct nfs4_ff_layout_ds *mirror_ds = ERR_PTR(-ENODEV);
 
+		mirror_ds = ERR_PTR(-ENODEV);
 		node = nfs4_find_get_deviceid(NFS_SERVER(lo->plh_inode),
 				&mirror->dss[dss_id].devid, lo->plh_lc_cred,
 				GFP_KERNEL);
@@ -344,20 +362,23 @@ ff_layout_init_mirror_ds(struct pnfs_layout_hdr *lo,
 		if (cmpxchg(&mirror->dss[dss_id].mirror_ds, NULL, mirror_ds) &&
 		    mirror_ds != ERR_PTR(-ENODEV))
 			nfs4_put_deviceid_node(node);
-	}
 
-	if (IS_ERR(mirror->dss[dss_id].mirror_ds))
-		goto outerr;
+		mirror_ds = mirror->dss[dss_id].mirror_ds;
+	}
 
-	return true;
-outerr:
-	return false;
+	if (IS_ERR(mirror_ds))
+		return mirror_ds;
+	if (!atomic_inc_not_zero(&mirror_ds->id_node.ref))
+		return ERR_PTR(-ENODEV);
+	return mirror_ds;
 }
 
 /**
  * nfs4_ff_layout_prepare_ds - prepare a DS connection for an RPC call
  * @lseg: the layout segment we're operating on
  * @mirror: layout mirror describing the DS to use
+ * @mirror_ds: referenced device node for the stripe, from
+ *	ff_layout_get_mirror_ds() (may be an ERR_PTR)
  * @dss_id: DS stripe id to select stripe to use
  * @fail_return: return layout on connect failure?
  *
@@ -375,6 +396,7 @@ ff_layout_init_mirror_ds(struct pnfs_layout_hdr *lo,
 struct nfs4_pnfs_ds *
 nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 			  struct nfs4_ff_layout_mirror *mirror,
+			  struct nfs4_ff_layout_ds *mirror_ds,
 			  u32 dss_id,
 			  bool fail_return)
 {
@@ -384,10 +406,10 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 	unsigned int max_payload;
 	int status = -EAGAIN;
 
-	if (!ff_layout_init_mirror_ds(lseg->pls_layout, mirror, dss_id))
+	if (IS_ERR_OR_NULL(mirror_ds))
 		goto noconnect;
 
-	ds = mirror->dss[dss_id].mirror_ds->ds;
+	ds = mirror_ds->ds;
 	if (READ_ONCE(ds->ds_clp))
 		goto out;
 	/* matching smp_wmb() in _nfs4_pnfs_v3/4_ds_connect */
@@ -396,10 +418,10 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 	/* FIXME: For now we assume the server sent only one version of NFS
 	 * to use for the DS.
 	 */
-	status = nfs4_pnfs_ds_connect(s, ds, &mirror->dss[dss_id].mirror_ds->id_node,
+	status = nfs4_pnfs_ds_connect(s, ds, &mirror_ds->id_node,
 			     dataserver_timeo, dataserver_retrans,
-			     mirror->dss[dss_id].mirror_ds->ds_versions[0].version,
-			     mirror->dss[dss_id].mirror_ds->ds_versions[0].minor_version);
+			     mirror_ds->ds_versions[0].version,
+			     mirror_ds->ds_versions[0].minor_version);
 
 	/* connect success, check rsize/wsize limit */
 	if (!status) {
@@ -412,10 +434,10 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 		max_payload =
 			nfs_block_size(rpc_max_payload(ds->ds_clp->cl_rpcclient),
 				       NULL);
-		if (mirror->dss[dss_id].mirror_ds->ds_versions[0].rsize > max_payload)
-			mirror->dss[dss_id].mirror_ds->ds_versions[0].rsize = max_payload;
-		if (mirror->dss[dss_id].mirror_ds->ds_versions[0].wsize > max_payload)
-			mirror->dss[dss_id].mirror_ds->ds_versions[0].wsize = max_payload;
+		if (mirror_ds->ds_versions[0].rsize > max_payload)
+			mirror_ds->ds_versions[0].rsize = max_payload;
+		if (mirror_ds->ds_versions[0].wsize > max_payload)
+			mirror_ds->ds_versions[0].wsize = max_payload;
 		goto out;
 	}
 noconnect:
@@ -435,11 +457,12 @@ const struct cred *
 ff_layout_get_ds_cred(struct nfs4_ff_layout_mirror *mirror,
 		      const struct pnfs_layout_range *range,
 		      const struct cred *mdscred,
+		      const struct nfs4_ff_layout_ds *mirror_ds,
 		      u32 dss_id)
 {
 	const struct cred *cred;
 
-	if (mirror && !mirror->dss[dss_id].mirror_ds->ds_versions[0].tightly_coupled) {
+	if (mirror && !mirror_ds->ds_versions[0].tightly_coupled) {
 		cred = ff_layout_get_mirror_cred(mirror, range->iomode, dss_id);
 		if (!cred)
 			cred = get_cred(mdscred);
@@ -451,20 +474,18 @@ ff_layout_get_ds_cred(struct nfs4_ff_layout_mirror *mirror,
 
 /**
  * nfs4_ff_find_or_create_ds_client - Find or create a DS rpc client
- * @mirror: pointer to the mirror
+ * @mirror_ds: device node for the stripe
  * @ds_clp: nfs_client for the DS
  * @inode: pointer to inode
- * @dss_id: DS stripe id
  *
  * Find or create a DS rpc client with th MDS server rpc client auth flavor
  * in the nfs_client cl_ds_clients list.
  */
 struct rpc_clnt *
-nfs4_ff_find_or_create_ds_client(struct nfs4_ff_layout_mirror *mirror,
-				 struct nfs_client *ds_clp, struct inode *inode,
-				 u32 dss_id)
+nfs4_ff_find_or_create_ds_client(const struct nfs4_ff_layout_ds *mirror_ds,
+				 struct nfs_client *ds_clp, struct inode *inode)
 {
-	switch (mirror->dss[dss_id].mirror_ds->ds_versions[0].version) {
+	switch (mirror_ds->ds_versions[0].version) {
 	case 3:
 		/* For NFSv3 DS, flavor is set when creating DS connections */
 		return ds_clp->cl_rpcclient;
-- 
2.53.0

