Received: from mail-oi1-f170.google.com (mail-oi1-f170.google.com [209.85.167.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5168049364C
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329783; cv=none; b=BeL2Svs/+sy8iRDEKM4XoCUVFOirLhDLecwSRyfqDH5wRtuG8kT4jp2NJv/CTQZP8zCq33SSaEzGahIqYACmP9Nkeebduo2/60rziZbhgMIyWOV/DlyhFV4ny/c0ZUPrialYR4aaLcarnsV9i2XIMNke3sBbm7eXoja3w5cJASY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329783; c=relaxed/simple;
	bh=C//e1CVIGdyLgCe2two1dX5t4NeSh+cKnvsc7vS9HSQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=EFnpGah75w+DkfBYaIHfCys02o1RPi3j0uc2XzhKRI4zbUilu42/keEwAoQf/hszkaTtr+50bBPhoH2+xzIryyyk4Q8CN74+J4EwaneUpA7rtgVUGjFS3iQR65b15E0I5DarAcP5M+i+1uzeSgfgkdflxORIHpxZKx472EC0naA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=RM4f8ZFU; arc=none smtp.client-ip=209.85.167.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="RM4f8ZFU"
Received: by mail-oi1-f170.google.com with SMTP id 5614622812f47-4ab47c40e7eso890725b6e.3
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329780; x=1787934580; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=HRD3+TsG0+DtxQLLsNYQIaaEUlisq07OcW/DWRpR8xQ=;
        b=RM4f8ZFUcabC/XkOcF5MRnA/5axt1voGOTTMrMXPhlh83nNjQTM97u0p2nGMKNpUkw
         7ZcobYgcW1AEIF2gWnG76AaKPWWowp4bYuEJAkyv6skpiItBYha5VIFRnrPPp+I+FxzO
         c7kWajqc99C70F8F3rDBemoMaNaG+vukisNyMdevR9+px1jiDRWXSrX49J0a7t+RlRq6
         /NW+YVdptfJIY8/rRPGOZKL5toYD1wyg29ZFZ1bxdO7tYK0skFxWsxz2Oqc+Nq2xWlUw
         sGMhhUuJBs2j+nZdbqQ0m0Vbpdkzom1nNnlw2csenSG7I2xvedRPgAB1tfP+yXaKLyyP
         IWQQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329780; x=1787934580;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=HRD3+TsG0+DtxQLLsNYQIaaEUlisq07OcW/DWRpR8xQ=;
        b=Y8uKaQ4WujZIpn+f6zUu8nsHZ4w1K80iP1SSgfkZ4REDElTCd0PzIIEr8aWUO91N8D
         UszMnBzHtJnG+eqwpsrwEDQVwnnU+3J5CRjbdraNgXHY9dUKqwSlOO97aMQhY3z7HhjY
         44xMj9HITClbKLTucK9C8dFbMTm15wn+Ce5WiRqqGVXOlvnRart7YHi+qH/qxySe1VGw
         9Qig9xjxdCxUnnqG6RxMLs9p63rCoSgAuO42xHWjVaHkA437AQINGhkwwXnAHXQGdQ7n
         APi5gmG/GCyU+auP+OYQ3oLis66Dzdt61hcGk6Nybevv2FwQAjBjW22jhS1Cwvw+er9y
         rSuQ==
X-Gm-Message-State: AOJu0YzE7BPAUm1GeUhIwvsmj5REu8E7081aF2iplWZeHyrmCzi/lkC9
	Z0eywTEeS06gHf6MvZJqfWnPIJWg6JdfcWEfLo12ZAJLmvq9nnDuiY2oXPb0x/iTdcwZniARowx
	LVa3t
X-Gm-Gg: AR+sD13MKNOnion036/DlWVVT2dVUzxCH9SOJvx/lDDDzrkXUYfJAsSBPgXzsTOne2R
	5R6aCWE9o5LL+piPlgnJ6VYP89LuTmF4l52fFUrjW+JiUoi3xLamrtf8v5U7ELAsCKfoKO7iS95
	JX38SqqRxCqQBN3++P3Mqe6/UmCyuy5oWiXMMbVzWBk/rcfov4xo7bKAGannBMZ9QZZ3HNjDV21
	gJ2Vcu4WhseOAX18PiW3+eJKjKDMbDsQV2MccAa2naHr3KvgUUWIx4ZodVPdUJOLejs1uF8okqa
	0fVKzBbelWJfTYxANT+kUmBG4xCYbhfHqzfkzEkP4brCINLLi2nx8IDWfMDxXyeK0CKLanutX0S
	bFzfBvhtlPoJ+hVi1sw1d1rHNfJHnKpBMvAAgEg9EIRfH8x4FhXG5utSbnLDj9o89Yuyom23vfA
	Uuax6ol6kJdkK5ctugeCX6p/UJVHCEhBWvKu65vzR5JgZu96FNdrSYGUrH0Kgz385MIfOmDLWnJ
	cK7mpm7WAWiLtblMrj3dY9Z
X-Received: by 2002:a05:6808:198f:b0:495:f79d:b08e with SMTP id 5614622812f47-4b2ef584b2cmr7703967b6e.21.1787329780064;
        Fri, 21 Aug 2026 09:29:40 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.39
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:39 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 08/23] NFSv4/flexfiles: Carry the device node reference across each I/O
Date: Fri, 21 Aug 2026 12:29:12 -0400
Message-ID: <558f7cc36259c683fdab5defe9214bc8852c62ee.1787327939.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1787327939.git.bcodding@hammerspace.com>
References: <cover.1787327939.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Rather than dropping the device node reference when DS setup completes,
transfer it to the in-flight I/O: carry it on nfs_pgio_header and
nfs_commit_data as ds_dev, and release it when the header or commit
data is released, alongside the lseg reference.

Convert the completion paths to use the carried node instead of
re-reading the mirror's pinned pointer: DS error tracking, marking the
deviceid available/unavailable, and deleting the deviceid on connection
errors now act on the node the I/O was actually sent to.  Once a CHANGE
notification can re-point the pinned pointer mid-flight, this keeps
error attribution on the old device rather than its replacement (and
removes a NULL dereference had the pointer been reset to NULL).

FF_LAYOUT_DEVID_NODE() is now unused; remove it.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    | 82 ++++++++++-------------
 fs/nfs/flexfilelayout/flexfilelayout.h    | 15 +----
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 11 +--
 fs/nfs/pnfs.c                             |  2 +
 fs/nfs/pnfs.h                             |  8 +++
 fs/nfs/pnfs_nfs.c                         |  1 +
 include/linux/nfs_xdr.h                   |  2 +
 7 files changed, 58 insertions(+), 63 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 3626ffe68481..4a9a36af4223 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -860,24 +860,6 @@ nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
 	spin_unlock(&mirror->lock);
 }
 
-static void
-ff_layout_mark_ds_unreachable(struct pnfs_layout_segment *lseg, u32 idx, u32 dss_id)
-{
-	struct nfs4_deviceid_node *devid = FF_LAYOUT_DEVID_NODE(lseg, idx, dss_id);
-
-	if (devid)
-		nfs4_mark_deviceid_unavailable(devid);
-}
-
-static void
-ff_layout_mark_ds_reachable(struct pnfs_layout_segment *lseg, u32 idx, u32 dss_id)
-{
-	struct nfs4_deviceid_node *devid = FF_LAYOUT_DEVID_NODE(lseg, idx, dss_id);
-
-	if (devid)
-		nfs4_mark_deviceid_available(devid);
-}
-
 static struct nfs4_ff_layout_ds *
 ff_layout_choose_ds_for_read(struct pnfs_layout_segment *lseg,
 			     u32 start_idx, u32 *best_idx,
@@ -1336,11 +1318,10 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
 					   struct nfs4_state *state,
 					   struct nfs_client *clp,
 					   struct pnfs_layout_segment *lseg,
-					   u32 idx, u32 dss_id)
+					   struct nfs4_deviceid_node *devid)
 {
 	struct pnfs_layout_hdr *lo = lseg->pls_layout;
 	struct inode *inode = lo->plh_inode;
-	struct nfs4_deviceid_node *devid = FF_LAYOUT_DEVID_NODE(lseg, idx, dss_id);
 	struct nfs4_slot_table *tbl = &clp->cl_session->fc_slot_table;
 
 	switch (op_status) {
@@ -1412,8 +1393,9 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
 	case -ENODEV:
 		dprintk("%s DS connection error %d\n", __func__,
 			task->tk_status);
-		nfs4_delete_deviceid(devid->ld, devid->nfs_client,
-				&devid->deviceid);
+		if (devid)
+			nfs4_delete_deviceid(devid->ld, devid->nfs_client,
+					&devid->deviceid);
 		rpc_wake_up(&tbl->slot_tbl_waitq);
 		break;
 	default:
@@ -1437,9 +1419,8 @@ static int ff_layout_async_handle_error_v3(struct rpc_task *task,
 					   u32 op_status,
 					   struct nfs_client *clp,
 					   struct pnfs_layout_segment *lseg,
-					   u32 idx, u32 dss_id)
+					   struct nfs4_deviceid_node *devid)
 {
-	struct nfs4_deviceid_node *devid = FF_LAYOUT_DEVID_NODE(lseg, idx, dss_id);
 
 	switch (op_status) {
 	case NFS_OK:
@@ -1485,8 +1466,9 @@ static int ff_layout_async_handle_error_v3(struct rpc_task *task,
 	default:
 		dprintk("%s DS connection error %d\n", __func__,
 			task->tk_status);
-		nfs4_delete_deviceid(devid->ld, devid->nfs_client,
-				&devid->deviceid);
+		if (devid)
+			nfs4_delete_deviceid(devid->ld, devid->nfs_client,
+					&devid->deviceid);
 	}
 out_reset_to_pnfs:
 	/* FIXME: Need to prevent infinite looping here. */
@@ -1503,12 +1485,13 @@ static int ff_layout_async_handle_error(struct rpc_task *task,
 					struct nfs4_state *state,
 					struct nfs_client *clp,
 					struct pnfs_layout_segment *lseg,
-					u32 idx, u32 dss_id)
+					struct nfs4_deviceid_node *devid)
 {
 	int vers = clp->cl_nfs_mod->rpc_vers->number;
 
 	if (task->tk_status >= 0) {
-		ff_layout_mark_ds_reachable(lseg, idx, dss_id);
+		if (devid)
+			nfs4_mark_deviceid_available(devid);
 		return 0;
 	}
 
@@ -1519,10 +1502,10 @@ static int ff_layout_async_handle_error(struct rpc_task *task,
 	switch (vers) {
 	case 3:
 		return ff_layout_async_handle_error_v3(task, op_status, clp,
-						       lseg, idx, dss_id);
+						       lseg, devid);
 	case 4:
 		return ff_layout_async_handle_error_v4(task, op_status, state,
-						       clp, lseg, idx, dss_id);
+						       clp, lseg, devid);
 	default:
 		/* should never happen */
 		WARN_ON_ONCE(1);
@@ -1531,6 +1514,7 @@ static int ff_layout_async_handle_error(struct rpc_task *task,
 }
 
 static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
+					struct nfs4_deviceid_node *devid,
 					u32 idx, u32 dss_id, u64 offset, u64 length,
 					u32 *op_status, int opnum, int error)
 {
@@ -1569,8 +1553,8 @@ static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
 
 	mirror = FF_LAYOUT_COMP(lseg, idx);
 	err = ff_layout_track_ds_error(FF_LAYOUT_FROM_HDR(lseg->pls_layout),
-				       mirror, dss_id, offset, length, status, opnum,
-				       nfs_io_gfp_mask());
+				       mirror, devid, dss_id, offset, length,
+				       status, opnum, nfs_io_gfp_mask());
 
 	switch (status) {
 	case NFS4ERR_DELAY:
@@ -1578,7 +1562,8 @@ static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
 	case NFS4ERR_PERM:
 		break;
 	case NFS4ERR_NXIO:
-		ff_layout_mark_ds_unreachable(lseg, idx, dss_id);
+		if (devid)
+			nfs4_mark_deviceid_unavailable(devid);
 		/*
 		 * Don't return the layout if this is a read and we still
 		 * have layouts to try
@@ -1606,7 +1591,7 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 	int err;
 
 	if (task->tk_status < 0) {
-		ff_layout_io_track_ds_error(hdr->lseg,
+		ff_layout_io_track_ds_error(hdr->lseg, hdr->ds_dev,
 					    hdr->pgio_mirror_idx, dss_id,
 					    hdr->args.offset, hdr->args.count,
 					    &hdr->res.op_status, OP_READ,
@@ -1617,8 +1602,7 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 	err = ff_layout_async_handle_error(task, hdr->res.op_status,
 					   hdr->args.context->state,
 					   hdr->ds_clp, hdr->lseg,
-					   hdr->pgio_mirror_idx,
-					   dss_id);
+					   hdr->ds_dev);
 
 	trace_nfs4_pnfs_read(hdr, err);
 	clear_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags);
@@ -1811,7 +1795,7 @@ static int ff_layout_write_done_cb(struct rpc_task *task,
 	int err;
 
 	if (task->tk_status < 0) {
-		ff_layout_io_track_ds_error(hdr->lseg,
+		ff_layout_io_track_ds_error(hdr->lseg, hdr->ds_dev,
 					    hdr->pgio_mirror_idx, dss_id,
 					    hdr->args.offset, hdr->args.count,
 					    &hdr->res.op_status, OP_WRITE,
@@ -1822,8 +1806,7 @@ static int ff_layout_write_done_cb(struct rpc_task *task,
 	err = ff_layout_async_handle_error(task, hdr->res.op_status,
 					   hdr->args.context->state,
 					   hdr->ds_clp, hdr->lseg,
-					   hdr->pgio_mirror_idx,
-					   dss_id);
+					   hdr->ds_dev);
 
 	trace_nfs4_pnfs_write(hdr, err);
 	clear_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags);
@@ -1865,7 +1848,7 @@ static int ff_layout_commit_done_cb(struct rpc_task *task,
 	u32 dss_id = calc_dss_id_from_commit(data->lseg, data->ds_commit_index);
 
 	if (task->tk_status < 0) {
-		ff_layout_io_track_ds_error(data->lseg, idx, dss_id,
+		ff_layout_io_track_ds_error(data->lseg, data->ds_dev, idx, dss_id,
 					    data->args.offset, data->args.count,
 					    &data->res.op_status, OP_COMMIT,
 					    task->tk_status);
@@ -1873,8 +1856,8 @@ static int ff_layout_commit_done_cb(struct rpc_task *task,
 	}
 
 	err = ff_layout_async_handle_error(task, data->res.op_status,
-					   NULL, data->ds_clp, data->lseg, idx,
-					   dss_id);
+					   NULL, data->ds_clp, data->lseg,
+					   data->ds_dev);
 
 	trace_nfs4_pnfs_commit_ds(data, err);
 	switch (err) {
@@ -2229,13 +2212,16 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 		ff_layout_read_record_layoutstats_start(&hdr->task, hdr);
 	}
 
+	/* Transfer the device node reference to the I/O; put on release */
+	pnfs_put_ds_dev(hdr->ds_dev);
+	hdr->ds_dev = &mirror_ds->id_node;
+
 	/* Perform an asynchronous read to ds */
 	nfs_initiate_pgio(ds_clnt, hdr, ds_cred, ds->ds_clp->rpc_ops,
 			  vers == 3 ? &ff_layout_read_call_ops_v3 :
 				      &ff_layout_read_call_ops_v4,
 			  0, RPC_TASK_SOFTCONN, localio);
 	put_cred(ds_cred);
-	nfs4_ff_layout_put_deviceid(mirror_ds);
 	return PNFS_ATTEMPTED;
 
 out_failed:
@@ -2328,13 +2314,16 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 		ff_layout_write_record_layoutstats_start(&hdr->task, hdr);
 	}
 
+	/* Transfer the device node reference to the I/O; put on release */
+	pnfs_put_ds_dev(hdr->ds_dev);
+	hdr->ds_dev = &mirror_ds->id_node;
+
 	/* Perform an asynchronous write */
 	nfs_initiate_pgio(ds_clnt, hdr, ds_cred, ds->ds_clp->rpc_ops,
 			  vers == 3 ? &ff_layout_write_call_ops_v3 :
 				      &ff_layout_write_call_ops_v4,
 			  sync, RPC_TASK_SOFTCONN, localio);
 	put_cred(ds_cred);
-	nfs4_ff_layout_put_deviceid(mirror_ds);
 	return PNFS_ATTEMPTED;
 
 out_failed:
@@ -2422,12 +2411,15 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
 		ff_layout_commit_record_layoutstats_start(&data->task, data);
 	}
 
+	/* Transfer the device node reference to the commit; put on release */
+	pnfs_put_ds_dev(data->ds_dev);
+	data->ds_dev = &mirror_ds->id_node;
+
 	ret = nfs_initiate_commit(ds_clnt, data, ds->ds_clp->rpc_ops,
 				   vers == 3 ? &ff_layout_commit_call_ops_v3 :
 					       &ff_layout_commit_call_ops_v4,
 				   how, RPC_TASK_SOFTCONN, localio);
 	put_cred(ds_cred);
-	nfs4_ff_layout_put_deviceid(mirror_ds);
 	return ret;
 out_err:
 	nfs4_ff_layout_put_deviceid(mirror_ds);
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index a65cdffe325b..ceed1a9dd697 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -162,20 +162,6 @@ FF_LAYOUT_COMP(struct pnfs_layout_segment *lseg, u32 idx)
 	return NULL;
 }
 
-static inline struct nfs4_deviceid_node *
-FF_LAYOUT_DEVID_NODE(struct pnfs_layout_segment *lseg, u32 idx, u32 dss_id)
-{
-	struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, idx);
-
-	if (mirror != NULL) {
-		struct nfs4_ff_layout_ds *mirror_ds = mirror->dss[dss_id].mirror_ds;
-
-		if (!IS_ERR_OR_NULL(mirror_ds))
-			return &mirror_ds->id_node;
-	}
-	return NULL;
-}
-
 static inline u32
 FF_LAYOUT_MIRROR_COUNT(struct pnfs_layout_segment *lseg)
 {
@@ -232,6 +218,7 @@ void nfs4_ff_layout_put_deviceid(struct nfs4_ff_layout_ds *mirror_ds);
 void nfs4_ff_layout_free_deviceid(struct nfs4_ff_layout_ds *mirror_ds);
 int ff_layout_track_ds_error(struct nfs4_flexfile_layout *flo,
 			     struct nfs4_ff_layout_mirror *mirror,
+			     const struct nfs4_deviceid_node *devid,
 			     u32 dss_id, u64 offset, u64 length, int status,
 			     enum nfs_opnum4 opnum, gfp_t gfp_flags);
 void ff_layout_send_layouterror(struct pnfs_layout_segment *lseg);
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 1058e250a23d..54349d9a89db 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -255,6 +255,7 @@ ff_layout_add_ds_error_locked(struct nfs4_flexfile_layout *flo,
 
 int ff_layout_track_ds_error(struct nfs4_flexfile_layout *flo,
 			     struct nfs4_ff_layout_mirror *mirror,
+			     const struct nfs4_deviceid_node *devid,
 			     u32 dss_id, u64 offset, u64 length, int status,
 			     enum nfs_opnum4 opnum, gfp_t gfp_flags)
 {
@@ -263,7 +264,7 @@ int ff_layout_track_ds_error(struct nfs4_flexfile_layout *flo,
 	if (status == 0)
 		return 0;
 
-	if (IS_ERR_OR_NULL(mirror->dss[dss_id].mirror_ds))
+	if (devid == NULL)
 		return -EINVAL;
 
 	dserr = kmalloc_obj(*dserr, gfp_flags);
@@ -276,8 +277,7 @@ int ff_layout_track_ds_error(struct nfs4_flexfile_layout *flo,
 	dserr->status = status;
 	dserr->opnum = opnum;
 	nfs4_stateid_copy(&dserr->stateid, &mirror->dss[dss_id].stateid);
-	memcpy(&dserr->deviceid, &mirror->dss[dss_id].mirror_ds->id_node.deviceid,
-	       NFS4_DEVICEID4_SIZE);
+	memcpy(&dserr->deviceid, &devid->deviceid, NFS4_DEVICEID4_SIZE);
 
 	spin_lock(&flo->generic_hdr.plh_inode->i_lock);
 	ff_layout_add_ds_error_locked(flo, dserr);
@@ -433,7 +433,10 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 	}
 noconnect:
 	ff_layout_track_ds_error(FF_LAYOUT_FROM_HDR(lseg->pls_layout),
-				 mirror, dss_id, lseg->pls_range.offset,
+				 mirror,
+				 IS_ERR_OR_NULL(mirror_ds) ?
+					NULL : &mirror_ds->id_node,
+				 dss_id, lseg->pls_range.offset,
 				 lseg->pls_range.length, NFS4ERR_NXIO,
 				 OP_ILLEGAL, GFP_NOIO);
 	ff_layout_send_layouterror(lseg);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7715e2bd5871..a21128321c0a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -3104,6 +3104,7 @@ pnfs_do_write(struct nfs_pageio_descriptor *desc,
 
 static void pnfs_writehdr_free(struct nfs_pgio_header *hdr)
 {
+	pnfs_put_ds_dev(hdr->ds_dev);
 	pnfs_put_lseg(hdr->lseg);
 	nfs_pgio_header_free(hdr);
 }
@@ -3249,6 +3250,7 @@ pnfs_do_read(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
 
 static void pnfs_readhdr_free(struct nfs_pgio_header *hdr)
 {
+	pnfs_put_ds_dev(hdr->ds_dev);
 	pnfs_put_lseg(hdr->lseg);
 	nfs_pgio_header_free(hdr);
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index eb39859c216c..bdce7f930c6a 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -384,6 +384,14 @@ void nfs4_init_deviceid_node(struct nfs4_deviceid_node *, struct nfs_server *,
 			     const struct nfs4_deviceid *);
 bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
 void nfs4_mark_deviceid_available(struct nfs4_deviceid_node *node);
+
+/* Put the device node reference carried by an in-flight I/O, if any */
+static inline void pnfs_put_ds_dev(struct nfs4_deviceid_node *dev)
+{
+	if (dev)
+		nfs4_put_deviceid_node(dev);
+}
+
 void nfs4_mark_deviceid_unavailable(struct nfs4_deviceid_node *node);
 bool nfs4_test_deviceid_unavailable(struct nfs4_deviceid_node *node);
 void nfs4_deviceid_purge_client(const struct nfs_client *);
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 648c95b78eea..f40368f839d0 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -55,6 +55,7 @@ void pnfs_generic_commit_release(void *calldata)
 	struct nfs_commit_data *data = calldata;
 
 	data->completion_ops->completion(data);
+	pnfs_put_ds_dev(data->ds_dev);
 	pnfs_put_lseg(data->lseg);
 	nfs_put_client(data->ds_clp);
 	nfs_commitdata_release(data);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 11c5b31cfc7d..aefb4715c809 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1687,6 +1687,7 @@ struct nfs_pgio_header {
 	struct nfs_client	*ds_clp;	/* pNFS data server */
 	u32			ds_commit_idx;	/* ds index if ds_clp is set */
 	u32			pgio_mirror_idx;/* mirror index in pgio layer */
+	struct nfs4_deviceid_node *ds_dev;	/* device node ref held across the I/O */
 };
 
 struct nfs_mds_commit_info {
@@ -1725,6 +1726,7 @@ struct nfs_commit_data {
 	struct nfs_open_context *context;
 	struct pnfs_layout_segment *lseg;
 	struct nfs_client	*ds_clp;	/* pNFS data server */
+	struct nfs4_deviceid_node *ds_dev;	/* device node ref held across the commit */
 	int			ds_commit_index;
 	loff_t			lwb;
 	const struct rpc_call_ops *mds_ops;
-- 
2.53.0

