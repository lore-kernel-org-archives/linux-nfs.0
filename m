Received: from mail-qk1-f182.google.com (mail-qk1-f182.google.com [209.85.222.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0219D50C2B4
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540816; cv=none; b=AZuDnV327N3hpUl6NvpONk9Ac/TlxIxyjBInf0HjKek16sjok079ayft8vrIpbxxpehC4H3rWCuCeedPNyOo6MSaJJUyDGvXk/uUVjaEgdv7JfjWGrRV8MBJ1AN0B059bSkY5uAhzUN9n74rl2y20PRVe4jnr+XaIn82sVWxlPA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540816; c=relaxed/simple;
	bh=hPiJd0oCoRB4/HTeaxQoFbOhLRtu1qeQUIHI+aydX64=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=HvvtudrIXz46E1mdaoQDaibPgA9/+ugph0aWvKw+xyW6mGITTftcO5IXZsWeeG3ew5eh2pXqlk0Ig/J1kn2iVNyVwg5xNz3hB73HErTycX+NmASjMm4zwJf8OsPcIJNe+3v+cwlK1yS4wIkFl44t7bygtHENbF9tzaAwuKNI4OU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=Ni8zTx37; arc=none smtp.client-ip=209.85.222.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Ni8zTx37"
Received: by mail-qk1-f182.google.com with SMTP id af79cd13be357-9391252b5caso83825185a.3
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540813; x=1789145613; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=5ORtG/W2eRy9XZk5O9UmCERmN77w7ArX/15uKSLXsbE=;
        b=Ni8zTx37do66D2iX44F7znZAOXHJy1upsdEH9x8DKPAWuEdprioc17OmVw+5Mb2AaK
         Hvkh0OosrdCIXh2sXpp8uJ8NzOZD0E6Ij4nnVvTf93B+SnYhOl5N2TyiLw4YYP2V81bB
         z/iPDcE1N2pZCLEbZUsUD5JBo2rejeWuMkZASea6DGJ0sDevt2lUruv/PTtNuEIigIRx
         mGjy5VP2fCT9hOYCICvlxIy7P4LjJ5wML2AMMdJitYQ5TTJhrqXIQE9My6/C9vsvYfnN
         lYX/FmEaqTkkoWIVxkHuy7aGje1bf3KnMJ/A77p968gK+QWMF5de0gsbFZQzDOv6josd
         VNvw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540813; x=1789145613;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=5ORtG/W2eRy9XZk5O9UmCERmN77w7ArX/15uKSLXsbE=;
        b=kWetMQSNYEGxcw1IEDb4aXrWNVNP/tFkosXFRtsIpnVylIuefvnnVwAe3LylTtsBAg
         0nWp9CRK75Rl0bAUKTxBOp3fkCf9y6Ai1+6oWzhUdL5NWU+3TMg2rHMHL8SkSpDJDWdP
         W1dfHAKmHlwLW/exa80mzgMqjRJNDi/MMG5ISsw3pNPSanQyjENQHGTBh2Dyxe1ePJpR
         KTkP8v/MIzNZTEUvDh3MGmj1uycdz+KT79QNr1WAazdP9xdWKnbXDa4ShIZCc6AW6BDe
         LXCZFTJTbSAYHG52vlXnvHWZAFB1bcvaQoBI9QmRKpjsD41x+9MEj2BPs38ljyteMrpF
         ECPw==
X-Gm-Message-State: AFuF++lT3/zggzAER1+CK0B5pILk+aiTjb0rDM9FuuAGKeJNB7S72zKt
	mVeYj7S1FhXaHBB16+bdSNBK2tPsX6dK5zARd6ppKtf52nXzPCShr6/ncpFkyb798Is=
X-Gm-Gg: AYBFou0SvmJXYcaJRYhaL8jVHKeZITAmVqM1RO2oZJYuukHPP5OzIbgLWm0ncwEEcpM
	RwWD799A+rUBzqn0GH8d6wWC/HAitRlc7/EbUvnX7082wHxhYKyqTkPBBHA6/0nRpPe+ZVnx+zJ
	QbDsebfvWXytNddiltkHI1eYuZO9W9uqnzilhs7hQ/MYBIT2IAHQ8qwOQhqRALVJ/PNuqn4If+q
	cOjVjZZI/m2DT3+IFam04uhbhfdEGbkSKx+3FSxMUhDDOWLzZuSscarFL69i/2lFlaEx+KKGPWg
	yclJNur33K+tP6PXldDuS+niyCNl9cRuacVFfkKIWI2H06fLUA+06sXnm8wNY6KuCv2NO1RgA67
	lvisK3flBVzMJyrfO5pm63IHgzdyMUtatK36gSkZYfLGykKJvrbwuRN/NbbopJRBvH15/Ww9A0t
	kmHCV/4Ebo3kbd5THoESZ40B9eMwRS3/YIlwbqRZYR9dQAstU+/hqlZP03gNlDmcnTgmAet0XLM
	Ygp4PNW2evDAWUQc2FnmfMH
X-Received: by 2002:a05:620a:394b:b0:939:1459:efb2 with SMTP id af79cd13be357-939804008ffmr720760285a.24.1788540812597;
        Fri, 04 Sep 2026 09:53:32 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:32 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 09/24] NFSv4/flexfiles: Carry the device node reference across each I/O
Date: Fri,  4 Sep 2026 12:53:08 -0400
Message-ID: <7361ab0e6fc3f0092a35cc5ed81ef75044522c29.1788530385.git.bcodding@hammerspace.com>
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
index 11fc27a062f6..d55f2759df98 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -857,24 +857,6 @@ nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
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
@@ -1333,11 +1315,10 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
 					   struct nfs4_state *state,
 					   struct nfs_client *clp,
 					   struct pnfs_layout_segment *lseg,
-					   u32 idx, u32 dss_id)
+					   struct nfs4_deviceid_node *devid)
 {
 	struct pnfs_layout_hdr *lo = lseg->pls_layout;
 	struct inode *inode = lo->plh_inode;
-	struct nfs4_deviceid_node *devid = FF_LAYOUT_DEVID_NODE(lseg, idx, dss_id);
 	struct nfs4_slot_table *tbl = nfs4_has_session(clp) ?
 		&clp->cl_session->fc_slot_table : clp->cl_slot_tbl;
 
@@ -1410,8 +1391,9 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
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
@@ -1435,9 +1417,8 @@ static int ff_layout_async_handle_error_v3(struct rpc_task *task,
 					   u32 op_status,
 					   struct nfs_client *clp,
 					   struct pnfs_layout_segment *lseg,
-					   u32 idx, u32 dss_id)
+					   struct nfs4_deviceid_node *devid)
 {
-	struct nfs4_deviceid_node *devid = FF_LAYOUT_DEVID_NODE(lseg, idx, dss_id);
 
 	switch (op_status) {
 	case NFS_OK:
@@ -1483,8 +1464,9 @@ static int ff_layout_async_handle_error_v3(struct rpc_task *task,
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
@@ -1501,12 +1483,13 @@ static int ff_layout_async_handle_error(struct rpc_task *task,
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
 
@@ -1517,10 +1500,10 @@ static int ff_layout_async_handle_error(struct rpc_task *task,
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
@@ -1529,6 +1512,7 @@ static int ff_layout_async_handle_error(struct rpc_task *task,
 }
 
 static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
+					struct nfs4_deviceid_node *devid,
 					u32 idx, u32 dss_id, u64 offset, u64 length,
 					u32 *op_status, int opnum, int error)
 {
@@ -1578,8 +1562,8 @@ static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
 
 	mirror = FF_LAYOUT_COMP(lseg, idx);
 	err = ff_layout_track_ds_error(FF_LAYOUT_FROM_HDR(lseg->pls_layout),
-				       mirror, dss_id, offset, length, status, opnum,
-				       nfs_io_gfp_mask());
+				       mirror, devid, dss_id, offset, length,
+				       status, opnum, nfs_io_gfp_mask());
 
 	/*
 	 * I/O we cancelled ourselves to return a recalled or revoked layout
@@ -1596,7 +1580,8 @@ static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
 	case NFS4ERR_PERM:
 		break;
 	case NFS4ERR_NXIO:
-		ff_layout_mark_ds_unreachable(lseg, idx, dss_id);
+		if (devid)
+			nfs4_mark_deviceid_unavailable(devid);
 		/*
 		 * Don't return the layout if this is a read and we still
 		 * have layouts to try
@@ -1625,7 +1610,7 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 	int err;
 
 	if (task->tk_status < 0) {
-		ff_layout_io_track_ds_error(hdr->lseg,
+		ff_layout_io_track_ds_error(hdr->lseg, hdr->ds_dev,
 					    hdr->pgio_mirror_idx, dss_id,
 					    hdr->args.offset, hdr->args.count,
 					    &hdr->res.op_status, OP_READ,
@@ -1636,8 +1621,7 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 	err = ff_layout_async_handle_error(task, hdr->res.op_status,
 					   hdr->args.context->state,
 					   hdr->ds_clp, hdr->lseg,
-					   hdr->pgio_mirror_idx,
-					   dss_id);
+					   hdr->ds_dev);
 
 	trace_nfs4_pnfs_read(hdr, err);
 	clear_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags);
@@ -1830,7 +1814,7 @@ static int ff_layout_write_done_cb(struct rpc_task *task,
 	int err;
 
 	if (task->tk_status < 0) {
-		ff_layout_io_track_ds_error(hdr->lseg,
+		ff_layout_io_track_ds_error(hdr->lseg, hdr->ds_dev,
 					    hdr->pgio_mirror_idx, dss_id,
 					    hdr->args.offset, hdr->args.count,
 					    &hdr->res.op_status, OP_WRITE,
@@ -1841,8 +1825,7 @@ static int ff_layout_write_done_cb(struct rpc_task *task,
 	err = ff_layout_async_handle_error(task, hdr->res.op_status,
 					   hdr->args.context->state,
 					   hdr->ds_clp, hdr->lseg,
-					   hdr->pgio_mirror_idx,
-					   dss_id);
+					   hdr->ds_dev);
 
 	trace_nfs4_pnfs_write(hdr, err);
 	clear_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags);
@@ -1884,7 +1867,7 @@ static int ff_layout_commit_done_cb(struct rpc_task *task,
 	u32 dss_id = calc_dss_id_from_commit(data->lseg, data->ds_commit_index);
 
 	if (task->tk_status < 0) {
-		ff_layout_io_track_ds_error(data->lseg, idx, dss_id,
+		ff_layout_io_track_ds_error(data->lseg, data->ds_dev, idx, dss_id,
 					    data->args.offset, data->args.count,
 					    &data->res.op_status, OP_COMMIT,
 					    task->tk_status);
@@ -1892,8 +1875,8 @@ static int ff_layout_commit_done_cb(struct rpc_task *task,
 	}
 
 	err = ff_layout_async_handle_error(task, data->res.op_status,
-					   NULL, data->ds_clp, data->lseg, idx,
-					   dss_id);
+					   NULL, data->ds_clp, data->lseg,
+					   data->ds_dev);
 
 	trace_nfs4_pnfs_commit_ds(data, err);
 	switch (err) {
@@ -2248,13 +2231,16 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
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
@@ -2347,13 +2333,16 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
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
@@ -2441,12 +2430,15 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
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
index f9e491a0347e..7eb47ce09442 100644
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
index 3712a47b20d0..ebcfba447879 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -243,6 +243,7 @@ ff_layout_add_ds_error_locked(struct nfs4_flexfile_layout *flo,
 
 int ff_layout_track_ds_error(struct nfs4_flexfile_layout *flo,
 			     struct nfs4_ff_layout_mirror *mirror,
+			     const struct nfs4_deviceid_node *devid,
 			     u32 dss_id, u64 offset, u64 length, int status,
 			     enum nfs_opnum4 opnum, gfp_t gfp_flags)
 {
@@ -251,7 +252,7 @@ int ff_layout_track_ds_error(struct nfs4_flexfile_layout *flo,
 	if (status == 0)
 		return 0;
 
-	if (IS_ERR_OR_NULL(mirror->dss[dss_id].mirror_ds))
+	if (devid == NULL)
 		return -EINVAL;
 
 	dserr = kmalloc_obj(*dserr, gfp_flags);
@@ -264,8 +265,7 @@ int ff_layout_track_ds_error(struct nfs4_flexfile_layout *flo,
 	dserr->status = status;
 	dserr->opnum = opnum;
 	nfs4_stateid_copy(&dserr->stateid, &mirror->dss[dss_id].stateid);
-	memcpy(&dserr->deviceid, &mirror->dss[dss_id].mirror_ds->id_node.deviceid,
-	       NFS4_DEVICEID4_SIZE);
+	memcpy(&dserr->deviceid, &devid->deviceid, NFS4_DEVICEID4_SIZE);
 
 	spin_lock(&flo->generic_hdr.plh_inode->i_lock);
 	ff_layout_add_ds_error_locked(flo, dserr);
@@ -422,7 +422,10 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
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
index 4f9c0f639014..b44274ab8b09 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -3103,6 +3103,7 @@ pnfs_do_write(struct nfs_pageio_descriptor *desc,
 
 static void pnfs_writehdr_free(struct nfs_pgio_header *hdr)
 {
+	pnfs_put_ds_dev(hdr->ds_dev);
 	pnfs_put_lseg(hdr->lseg);
 	nfs_pgio_header_free(hdr);
 }
@@ -3248,6 +3249,7 @@ pnfs_do_read(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
 
 static void pnfs_readhdr_free(struct nfs_pgio_header *hdr)
 {
+	pnfs_put_ds_dev(hdr->ds_dev);
 	pnfs_put_lseg(hdr->lseg);
 	nfs_pgio_header_free(hdr);
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 5725ea06efc2..a2c70573dda5 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -385,6 +385,14 @@ void nfs4_init_deviceid_node(struct nfs4_deviceid_node *, struct nfs_server *,
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
index 5bd014b981bf..e0e3fc7414e6 100644
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
index 7ed8fdb930d6..c0e29b4dfa62 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1693,6 +1693,7 @@ struct nfs_pgio_header {
 	struct nfs_client	*ds_clp;	/* pNFS data server */
 	u32			ds_commit_idx;	/* ds index if ds_clp is set */
 	u32			pgio_mirror_idx;/* mirror index in pgio layer */
+	struct nfs4_deviceid_node *ds_dev;	/* device node ref held across the I/O */
 };
 
 struct nfs_mds_commit_info {
@@ -1731,6 +1732,7 @@ struct nfs_commit_data {
 	struct nfs_open_context *context;
 	struct pnfs_layout_segment *lseg;
 	struct nfs_client	*ds_clp;	/* pNFS data server */
+	struct nfs4_deviceid_node *ds_dev;	/* device node ref held across the commit */
 	int			ds_commit_index;
 	loff_t			lwb;
 	const struct rpc_call_ops *mds_ops;
-- 
2.53.0

