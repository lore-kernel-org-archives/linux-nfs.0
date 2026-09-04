Received: from mail-qk1-f174.google.com (mail-qk1-f174.google.com [209.85.222.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 868A8503BD8
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.174
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540816; cv=none; b=SkYRh5Z4m1U4a5MTRr1/euU9XlhaU4MnKJQppESwVYmVkX0wXTKiVSfKvWTOowU+Kx2WZixLCycPCS3441OHs8520gktaknEyrIZQTP1XZSMXeBo1aLZiNpMWciNCzWDIZYByvATjtShMiRva+uhLZBwc1ayVSu+SL85IkRj3JE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540816; c=relaxed/simple;
	bh=HuLE2jf2ZM9Dh23lNMrip/mEwkCJrRxHnDXuTreJP68=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=h5BhCpMLgyBpNRfKAd14jftutXG6G3Y1Un/zTaU+tr7mniv5n3W4KFvkJR+mLLi5I1E4YrRGysxG8OaLLt9BsEQm13sF05vsKS2nvN+VgUr+s4gSFM0tZZTHx/B65PPqNRNcDgz58XPYIeRApaxuQ5KEKkyqGOeOgthCGFvIiT0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=kzkTUNEI; arc=none smtp.client-ip=209.85.222.174
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="kzkTUNEI"
Received: by mail-qk1-f174.google.com with SMTP id af79cd13be357-936cda0e3fbso136680285a.3
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540812; x=1789145612; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=8xqhjhmKYYbwUWHlRXsjlGwqYS5BXo8H6jho7RXND6A=;
        b=kzkTUNEI+sWVexavscX26VyPLpQyE4kIWsJ/1DoFxrMp1q5FUCS78rIALohmRpci7P
         vBH1MgnzNqCHviyrzauyzKRtdKgoCo5CYtzyecr1MrW9vvf7yNXV5BideInlEgTxpcR2
         +OQ29MpjiBGnERBZ7ETsPdCdA6YoCkpaMV/bdn1wN0svQ6ygwGDJToDKrFKv1Mes0clK
         DblmU65sux6gZFOyOO+9tZTslm8bEcLQRuv0M7oWcH+9slY5ZDfvSg0NOFsIZzXxmO4f
         S5hQnPLxN4yafieLngZgrdJTw7PfXH/UtNyElvXCNBfdq/YPVtXNuPrVI8mnIgU4WZaF
         vvYg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540812; x=1789145612;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=8xqhjhmKYYbwUWHlRXsjlGwqYS5BXo8H6jho7RXND6A=;
        b=hCQo8FFdcBWTIN1+K3pboE7i1S3rdOq6jnhCzfAr4nYtx6Qkkifbf+cfnEMwxVZcHd
         RQ+7PkpYGLuQy7gT2jN9gGWiW0ht1M7jYAMPQ5s4WYfMcerswL+Zn8Wn2F9HsetJalss
         0WfECB6kwF8z0dg95u/ey+Ivsanz+aTVcbJv2V4xgweWnR3JRSOZht7xi/s1iTsK80M4
         xNa4/yQXIKHjs0c5vAXNnbw9DPWShcGXZdN5QBZaRDTKnCUMwv5styTvvWcd91gSoJj+
         S5nK1mM3fv6gY504NtrAmlzUXW/11sNxfBReZZaK5Dhhv5hHOqsZTwabgRWtmEgwSk62
         e+zg==
X-Gm-Message-State: AFuF++lR6IBHJyHS9M879i6vKVknoGRcSZGkda2WLz7lfdYhmcrelpxQ
	OHU4luBi3l2/iT1UzbtizxB4Lja+0G93kjeq5JoYF6KyNT+FTaEFCu4PHCLgVxrX718ArAlNppF
	yL0Fb
X-Gm-Gg: AYBFou1dPyLY452CWXaf/dbEPA6K+wr5vEpJzV+WKfKp3ZsFhZRctAeUmjAJrq66cX0
	M48uWxaVqcVgNhSykudDZ690c2AstwFjhvePx5CQrZTIQ8r1mDeGUXxUFyUdRlt+Iv2keSTkGqw
	6L2xpr2XICwHT+6fUDSOTd/iiJXVskymv9rA5K2/4/HYYQ8BlX/GvKq6EAvXaX4prT+cBd2u+Il
	q1iDuUkl2X/NaF2KUFKYzYXsmPdwq/XMZdaaFQa9YDEF86D6BfY+XA4WHtm1LglxiUZucIHY90y
	OX+b88wqBgnzlMTWJ2Th1O+i6h7dtbsvBUiCsl5yuV9EBwtA+TLhIID2MleXZuysruVJOsB4X8Z
	s+oHjNVoJbIUR1FmkfX/wtbnu5PMz3YbBtChnajyy44HdcSrKpAbsG4+MfwxE0IE51UG/TnlqnH
	Nr8OHDuxIbVantWC+2CUmfgKiQ+fX0W34blWbPxa/cZVZbKIieO10riWFP1qWRAI3eUevwDiFWZ
	PDv/bbb1jxP2OelvfXrz9/X
X-Received: by 2002:a05:620a:1a06:b0:932:fcb4:4d0b with SMTP id af79cd13be357-939806da006mr677581685a.24.1788540811748;
        Fri, 04 Sep 2026 09:53:31 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:31 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 08/24] NFSv4/flexfiles: Reference the device node across DS setup
Date: Fri,  4 Sep 2026 12:53:07 -0400
Message-ID: <cc1c6f4b5fd7ea4cc8fc24ca3103db6a8a98d760.1788530385.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1788530385.git.bcodding@hammerspace.com>
References: <cover.1788530385.git.bcodding@hammerspace.com>
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
the life of the mirror.  Each reference this adds is released on every
exit from the path that took it, error paths included.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    | 140 ++++++++++++++--------
 fs/nfs/flexfilelayout/flexfilelayout.h    |  16 ++-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  74 +++++++-----
 3 files changed, 141 insertions(+), 89 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 2d254e5e5b94..11fc27a062f6 100644
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
 
@@ -2166,6 +2183,7 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 	struct rpc_clnt *ds_clnt;
 	struct nfsd_file *localio;
 	struct nfs4_ff_layout_mirror *mirror;
+	struct nfs4_ff_layout_ds *mirror_ds;
 	const struct cred *ds_cred;
 	loff_t offset = hdr->args.offset;
 	u32 idx = hdr->pgio_mirror_idx;
@@ -2183,22 +2201,24 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
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
@@ -2210,7 +2230,8 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 	if (fh)
 		hdr->args.fh = fh;
 
-	nfs4_ff_layout_select_ds_stateid(mirror, dss_id, &hdr->args.stateid);
+	nfs4_ff_layout_select_ds_stateid(mirror, mirror_ds, dss_id,
+					 &hdr->args.stateid);
 
 	/*
 	 * Note that if we ever decide to split across DSes,
@@ -2233,9 +2254,11 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
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
@@ -2261,6 +2284,7 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 	struct rpc_clnt *ds_clnt;
 	struct nfsd_file *localio;
 	struct nfs4_ff_layout_mirror *mirror;
+	struct nfs4_ff_layout_ds *mirror_ds;
 	const struct cred *ds_cred;
 	loff_t offset = hdr->args.offset;
 	int vers;
@@ -2274,22 +2298,24 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
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
@@ -2304,7 +2330,8 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 	if (fh)
 		hdr->args.fh = fh;
 
-	nfs4_ff_layout_select_ds_stateid(mirror, dss_id, &hdr->args.stateid);
+	nfs4_ff_layout_select_ds_stateid(mirror, mirror_ds, dss_id,
+					 &hdr->args.stateid);
 
 	/*
 	 * Note that if we ever decide to split across DSes,
@@ -2326,9 +2353,11 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
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
@@ -2363,6 +2392,7 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
 	struct rpc_clnt *ds_clnt;
 	struct nfsd_file *localio;
 	struct nfs4_ff_layout_mirror *mirror;
+	struct nfs4_ff_layout_ds *mirror_ds = NULL;
 	const struct cred *ds_cred;
 	u32 idx, dss_id;
 	int vers, ret;
@@ -2375,20 +2405,22 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
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
@@ -2414,8 +2446,10 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
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
index ec69cd1c3ae9..f9e491a0347e 100644
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
index 6cd3859d4a24..3712a47b20d0 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -304,24 +304,33 @@ nfs4_ff_layout_select_ds_fh(struct nfs4_ff_layout_mirror *mirror, u32 dss_id)
 
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
+/*
+ * Resolve the stripe's deviceid on first use and pin the node on the
+ * mirror.  Returns a node the caller must put, or an ERR_PTR.
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
@@ -332,20 +341,23 @@ ff_layout_init_mirror_ds(struct pnfs_layout_hdr *lo,
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
@@ -363,6 +375,7 @@ ff_layout_init_mirror_ds(struct pnfs_layout_hdr *lo,
 struct nfs4_pnfs_ds *
 nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 			  struct nfs4_ff_layout_mirror *mirror,
+			  struct nfs4_ff_layout_ds *mirror_ds,
 			  u32 dss_id,
 			  bool fail_return)
 {
@@ -372,10 +385,10 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
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
@@ -384,11 +397,11 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 	/* FIXME: For now we assume the server sent only one version of NFS
 	 * to use for the DS.
 	 */
-	status = nfs4_pnfs_ds_connect(s, ds, &mirror->dss[dss_id].mirror_ds->id_node,
+	status = nfs4_pnfs_ds_connect(s, ds, &mirror_ds->id_node,
 			     dataserver_timeo, dataserver_retrans,
-			     mirror->dss[dss_id].mirror_ds->ds_versions[0].version,
-			     mirror->dss[dss_id].mirror_ds->ds_versions[0].minor_version,
-			     mirror->dss[dss_id].mirror_ds->ds_versions[0].tightly_coupled);
+			     mirror_ds->ds_versions[0].version,
+			     mirror_ds->ds_versions[0].minor_version,
+			     mirror_ds->ds_versions[0].tightly_coupled);
 
 	/* connect success, check rsize/wsize limit */
 	if (!status) {
@@ -401,10 +414,10 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
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
@@ -424,11 +437,12 @@ const struct cred *
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
@@ -440,20 +454,18 @@ ff_layout_get_ds_cred(struct nfs4_ff_layout_mirror *mirror,
 
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

