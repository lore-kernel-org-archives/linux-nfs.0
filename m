Received: from mail-oo1-f54.google.com (mail-oo1-f54.google.com [209.85.161.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5AA92390229
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 18:07:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.54
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786644444; cv=none; b=EUT8bLDTJR6tzRgVfMbjrMSgiBsf00MTmRNreYjGNFbUBuOxiCuhZC5opINQdZUwRUv47VuyNVlsvb+GjdHDV1eNaITq/eu8r8E3es/ZCJWwpWXl1rECZAP6po4xEtmJG8WTYlHiyX5i/4FtpyNHjOz6uKVJp4x7dOzLNr3FQAU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786644444; c=relaxed/simple;
	bh=qwrT19nN+HtNt0Ti4f5qOTSe8AC5hd9Ap2CI9BgjUEg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=U6jjvuH1t8+I8+UEcb1gsHjUlvVQ+8geyBJQnnZin7uDGAbEUtMtwn3IxDdcquOWv5JaGyIifL57J8IeTDKxYPs9U/DW3VFDZRNDMQUYkdxGPmj3NoQ2xzLI1TDhZ76v07TUgQ10E1K2T3ArX38wB4oxwye/LLYp99gOVpkh5VQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=WTnnawsT; arc=none smtp.client-ip=209.85.161.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="WTnnawsT"
Received: by mail-oo1-f54.google.com with SMTP id 006d021491bc7-6b0be561175so129538eaf.2
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 11:07:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786644440; x=1787249240; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=4cQya4hnniW3k74zcEuV/wZ6OxLy6ZrPCx12YVm7x58=;
        b=WTnnawsTMbhHk6y3mPk/53un0eHn3IN8YV9AHl5Mp2AKbsiwC1IW74LBlmOuHYHfkd
         OomIh7q8CTA/GZOTsVFDlNh+QKpWXQLtefh2VVTqWERkfrLFAOVfOhHjERBe0xSe/AXV
         2YSNsP7yHixvBLqUA5m1u5Ek+9UnC0iOXgrfIjKIu/s0bePG5PLEELtEQWmdPMjsHkGa
         I7RWHbig6OSy1YeTPC2g1WWoIZAbcGSkHTp68wxhy1B3fqrxNsNeu4x/ujLrU6Qkax0G
         29VEpnqDbciYJV3TpJCyoF9V6pq1Axh5l/NoPwoVT1RNyYA/ikjsocf29oy9MxU7QjYM
         t6sw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786644440; x=1787249240;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=4cQya4hnniW3k74zcEuV/wZ6OxLy6ZrPCx12YVm7x58=;
        b=B5mqtV3KiTHl8jpVxw3mHdF84HW6dSmoYRC4XdjNiKBJ3SAEUd4FufvwUkeE+AqXDc
         lENdZu7irDgK22h1gj5fYt5KpzHmkOwrbqzenNn6+wNluOAlynejCnM2YTGkMErfr+jp
         BlQYPaNQAqBvkTwDsYe0FhZwrJCDfsNxvURXOfr1A/kc93S4dD0faKS50Iv9DEmc8XDI
         +x8inJN8EM9fnK59GbRHX4exfDZBw7R9WjWrdzi6o6UtaeFl7INg1qOY0AFtOBLw2W3K
         CYA+0SXArVFG8p2iGK+reK63PnBnwhWC0bTOf18Y1xwPqdEWQyKeKooNHnCVmNmdFY1h
         wThQ==
X-Gm-Message-State: AOJu0YxnKygSNtUQXAEz7SB2c3yqwef3TL8RYMXfd0VVJyzqzyjTGAJi
	KEcHhDpSAWnwWr+a/PYB5OuAaToxdBcvjnGuhzv1ZYfTveTjLg2Hr0Prk/tfsJpgArw=
X-Gm-Gg: AR+sD13v4jF52JNs8iu9LNvybsPIIkm/IhnMPr5Jkrwktrbbzx5oy1XXKuxl8Zz5eOA
	/D3K579q+6QAYogHmZW1NOkaeTAF6uKNCdDbxuMBFGYZf9I8WFoySHYVtQ/Hfgd585rpii3+WYm
	9Pcl7nw2CqboP1uKqL2EuHl6IgtQqMBSVbdQoQKO0YFayftoUtpcoaP9IlWoMx8qqp2ont47xPy
	KKBWiwQ3hUrUWDrG8pFqn6Aw05ZK374YeS4qOUx/KXv5TGlwdI5LBLwGuAvqG4MMVOYIl9XkY7o
	VJECxKaaNl3/GcTl18d5Kp7LYc07cPfOuleZ1PK82+K2d+R1AqUs0UD85VB2uLdA4JLaecSKGmK
	rV8iUfLfVDsZ8BDg/giwgFtvufezo/z9JNqAY2fazLVSoRaShjp7+OrdjHte0F08259MjJcqYOA
	UsO3iqpHOm7wbgPeLQ+jENloKWLCi75NiV2jryhGx8dE+vEh9DXN9iuGSuekMr/TRJffsDlFcuY
	HOjUbCN1hzhZCBZYW2k76BS
X-Received: by 2002:a05:6820:f029:b0:6b0:4a08:17d9 with SMTP id 006d021491bc7-6b0d68f6815mr215747eaf.28.1786644440264;
        Thu, 13 Aug 2026 11:07:20 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-45e8f96010fsm211730fac.7.2026.08.13.11.07.19
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 11:07:19 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] pNFS: allow layout drivers to cancel I/O to a single device
Date: Thu, 13 Aug 2026 14:07:14 -0400
Message-ID: <5023287801090f26f1e1a519d16046208be5ce5f.1786636529.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1786636529.git.bcodding@hammerspace.com>
References: <cover.1786636529.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The ->cancel_io() layout operation cancels all in-flight I/O for a
layout segment that is being returned.  When the return is triggered
by the failure of a single mirror instance, cancelling I/O to the
healthy mirrors is both unnecessary and harmful: requests that were
already transmitted cannot be un-sent, and will complete on the data
servers after the layout has been returned.

Give ->cancel_io() a device ID argument identifying the failed device,
and thread it through pnfs_error_mark_layout_for_return() and
pnfs_mark_matching_lsegs_return().  The flexfiles implementation
compares it against the raw device ID from the layout, so that it can
identify the failed mirror instance even when its device ID node was
never instantiated.

A NULL device ID preserves the existing cancel-everything behavior,
and all callers pass NULL for now, so this patch makes no change in
behavior.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/blocklayout/blocklayout.c          |  6 +++--
 fs/nfs/callback_proc.c                    |  2 +-
 fs/nfs/filelayout/filelayout.c            |  4 +--
 fs/nfs/flexfilelayout/flexfilelayout.c    | 16 +++++++-----
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  2 +-
 fs/nfs/pnfs.c                             | 32 ++++++++++++++---------
 fs/nfs/pnfs.h                             | 14 ++++++----
 7 files changed, 46 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index d54a141a89b3..d86702e604f9 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -859,7 +859,8 @@ bl_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 
 	if (pgio->pg_lseg &&
 		test_bit(NFS_LSEG_UNAVAILABLE, &pgio->pg_lseg->pls_flags)) {
-		pnfs_error_mark_layout_for_return(pgio->pg_inode, pgio->pg_lseg);
+		pnfs_error_mark_layout_for_return(pgio->pg_inode, pgio->pg_lseg,
+						  NULL);
 		pnfs_set_lo_fail(pgio->pg_lseg);
 		nfs_pageio_reset_read_mds(pgio);
 	}
@@ -921,7 +922,8 @@ bl_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 	if (pgio->pg_lseg &&
 		test_bit(NFS_LSEG_UNAVAILABLE, &pgio->pg_lseg->pls_flags)) {
 
-		pnfs_error_mark_layout_for_return(pgio->pg_inode, pgio->pg_lseg);
+		pnfs_error_mark_layout_for_return(pgio->pg_inode, pgio->pg_lseg,
+						  NULL);
 		pnfs_set_lo_fail(pgio->pg_lseg);
 		nfs_pageio_reset_write_mds(pgio);
 	}
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 3fb10c8e4271..ddc8736100e1 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -292,7 +292,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	switch (pnfs_mark_matching_lsegs_return(lo, &free_me_list,
 				&args->cbl_range,
 				be32_to_cpu(args->cbl_stateid.seqid),
-				args->cbl_layoutchanged)) {
+				args->cbl_layoutchanged, NULL)) {
 	case 0:
 	case -EBUSY:
 		/* There are layout segments that need to be returned */
diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 72e20b56fbc7..96c0398b0b4c 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -186,7 +186,7 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		dprintk("%s DS connection error %d\n", __func__,
 			task->tk_status);
 		nfs4_mark_deviceid_unavailable(devid);
-		pnfs_error_mark_layout_for_return(inode, lseg);
+		pnfs_error_mark_layout_for_return(inode, lseg, NULL);
 		pnfs_set_lo_fail(lseg);
 		rpc_wake_up(&tbl->slot_tbl_waitq);
 		fallthrough;
@@ -856,7 +856,7 @@ fl_pnfs_update_layout(struct inode *ino,
 
 	status = filelayout_check_deviceid(lo, fl, gfp_flags);
 	if (status) {
-		pnfs_error_mark_layout_for_return(ino, lseg);
+		pnfs_error_mark_layout_for_return(ino, lseg, NULL);
 		pnfs_set_lo_fail(lseg);
 		pnfs_put_lseg(lseg);
 		lseg = NULL;
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 2c30e62881a1..b0c90e6cdccb 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1282,7 +1282,7 @@ static void ff_layout_resend_pnfs_read(struct nfs_pgio_header *hdr)
 	ds = ff_layout_choose_any_ds_for_read(hdr->lseg, idx, &new_idx,
 					      hdr->args.offset, &dss_id);
 	if (IS_ERR(ds))
-		pnfs_error_mark_layout_for_return(hdr->inode, hdr->lseg);
+		pnfs_error_mark_layout_for_return(hdr->inode, hdr->lseg, NULL);
 	else
 		ff_layout_send_layouterror(hdr->lseg);
 	pnfs_read_resend_pnfs(hdr, new_idx);
@@ -1293,7 +1293,7 @@ static void ff_layout_reset_read(struct nfs_pgio_header *hdr)
 	struct rpc_task *task = &hdr->task;
 
 	pnfs_layoutcommit_inode(hdr->inode, false);
-	pnfs_error_mark_layout_for_return(hdr->inode, hdr->lseg);
+	pnfs_error_mark_layout_for_return(hdr->inode, hdr->lseg, NULL);
 
 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
 		dprintk("%s Reset task %5u for i/o through MDS "
@@ -1590,7 +1590,7 @@ static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
 		fallthrough;
 	default:
 		pnfs_error_mark_layout_for_return(lseg->pls_layout->plh_inode,
-						  lseg);
+						  lseg, NULL);
 	}
 
 out:
@@ -2244,7 +2244,7 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 		 * FF_FLAGS_NO_IO_THRU_MDS: force fresh LAYOUTGET,
 		 * never fall through to MDS I/O.
 		 */
-		pnfs_error_mark_layout_for_return(hdr->inode, lseg);
+		pnfs_error_mark_layout_for_return(hdr->inode, lseg, NULL);
 		return PNFS_TRY_AGAIN;
 	}
 	trace_pnfs_mds_fallback_read_pagelist(hdr->inode,
@@ -2337,7 +2337,7 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 		 * FF_FLAGS_NO_IO_THRU_MDS: force fresh LAYOUTGET,
 		 * never fall through to MDS I/O.
 		 */
-		pnfs_error_mark_layout_for_return(hdr->inode, lseg);
+		pnfs_error_mark_layout_for_return(hdr->inode, lseg, NULL);
 		return PNFS_TRY_AGAIN;
 	}
 	trace_pnfs_mds_fallback_write_pagelist(hdr->inode,
@@ -2459,7 +2459,8 @@ static bool ff_layout_match_io(const struct rpc_task *task, const void *data)
 	return false;
 }
 
-static void ff_layout_cancel_io(struct pnfs_layout_segment *lseg)
+static void ff_layout_cancel_io(struct pnfs_layout_segment *lseg,
+				const struct nfs4_deviceid *devid)
 {
 	struct nfs4_ff_layout_segment *flseg = FF_LAYOUT_LSEG(lseg);
 	struct nfs4_ff_layout_mirror *mirror;
@@ -2472,6 +2473,9 @@ static void ff_layout_cancel_io(struct pnfs_layout_segment *lseg)
 	for (idx = 0; idx < flseg->mirror_array_cnt; idx++) {
 		mirror = flseg->mirror_array[idx];
 		for (dss_id = 0; dss_id < mirror->dss_count; dss_id++) {
+			if (devid && memcmp(&mirror->dss[dss_id].devid, devid,
+					    sizeof(*devid)) != 0)
+				continue;
 			mirror_ds = mirror->dss[dss_id].mirror_ds;
 			if (IS_ERR_OR_NULL(mirror_ds))
 				continue;
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 5920ba529a0b..33ee3ed1f546 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -428,7 +428,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 				 opnum, GFP_NOIO);
 	ff_layout_send_layouterror(lseg);
 	if (opnum != OP_READ || !ff_layout_has_available_ds(lseg))
-		pnfs_error_mark_layout_for_return(ino, lseg);
+		pnfs_error_mark_layout_for_return(ino, lseg, NULL);
 	ds = ERR_PTR(status);
 out:
 	return ds;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9a08fd076e0a..c4ea2ffd2f01 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -433,7 +433,7 @@ bool nfs4_layout_refresh_old_stateid(nfs4_stateid *dst,
 		}
 		/* Try to update the seqid to the most recent */
 		err = pnfs_mark_matching_lsegs_return(lo, &head, &range, 0,
-						      true);
+						      true, NULL);
 		if (err != -EBUSY) {
 			dst->seqid = lo->plh_stateid.seqid;
 			*dst_range = range;
@@ -487,7 +487,8 @@ static int pnfs_mark_layout_stateid_return(struct pnfs_layout_hdr *lo,
 		.length = NFS4_MAX_UINT64,
 	};
 
-	return pnfs_mark_matching_lsegs_return(lo, lseg_list, &range, seq, true);
+	return pnfs_mark_matching_lsegs_return(lo, lseg_list, &range, seq, true,
+					       NULL);
 }
 
 static int
@@ -525,7 +526,7 @@ pnfs_layout_io_set_failed(struct pnfs_layout_hdr *lo, u32 iomode)
 
 	spin_lock(&inode->i_lock);
 	pnfs_layout_set_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
-	pnfs_mark_matching_lsegs_return(lo, &head, &range, 0, true);
+	pnfs_mark_matching_lsegs_return(lo, &head, &range, 0, true, NULL);
 	spin_unlock(&inode->i_lock);
 	pnfs_free_lseg_list(&head);
 	dprintk("%s Setting layout IOMODE_%s fail bit\n", __func__,
@@ -740,7 +741,7 @@ pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 			if (mark_lseg_invalid(lseg, tmp_list))
 				continue;
 			remaining++;
-			pnfs_lseg_cancel_io(server, lseg);
+			pnfs_lseg_cancel_io(server, lseg, NULL);
 		}
 	dprintk("%s:Return %i\n", __func__, remaining);
 	return remaining;
@@ -1462,7 +1463,7 @@ _pnfs_return_layout(struct inode *ino)
 	}
 	valid_layout = pnfs_layout_is_valid(lo);
 	pnfs_clear_layoutcommit(ino, &tmp_list);
-	pnfs_mark_matching_lsegs_return(lo, &tmp_list, &range, 0, true);
+	pnfs_mark_matching_lsegs_return(lo, &tmp_list, &range, 0, true, NULL);
 
 
 	/* Don't send a LAYOUTRETURN if list was initially empty */
@@ -2616,7 +2617,8 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 			.iomode = IOMODE_ANY,
 			.length = NFS4_MAX_UINT64,
 		};
-		pnfs_mark_matching_lsegs_return(lo, &free_me, &range, 0, true);
+		pnfs_mark_matching_lsegs_return(lo, &free_me, &range, 0, true,
+						NULL);
 		goto out_forget;
 	} else {
 		/* We have a completely new layout */
@@ -2648,6 +2650,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
  * @return_range: describe layout segment ranges to be returned
  * @seq: stateid seqid to match
  * @cancel_io: signal io be cancelled
+ * @devid: only cancel io directed at this device (all devices if NULL)
  *
  * This function is mainly intended for use by layoutrecall. It attempts
  * to free the layout segment immediately, or else to mark it for return
@@ -2662,7 +2665,8 @@ int
 pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
 				const struct pnfs_layout_range *return_range,
-				u32 seq, bool cancel_io)
+				u32 seq, bool cancel_io,
+				const struct nfs4_deviceid *devid)
 {
 	struct pnfs_layout_segment *lseg, *next;
 	struct nfs_server *server = NFS_SERVER(lo->plh_inode);
@@ -2689,7 +2693,7 @@ pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 			remaining++;
 			set_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags);
 			if (cancel_io)
-				pnfs_lseg_cancel_io(server, lseg);
+				pnfs_lseg_cancel_io(server, lseg, devid);
 		}
 
 	if (remaining) {
@@ -2707,7 +2711,8 @@ pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 
 static void
 pnfs_mark_layout_for_return(struct inode *inode,
-			    const struct pnfs_layout_range *range)
+			    const struct pnfs_layout_range *range,
+			    const struct nfs4_deviceid *devid)
 {
 	struct pnfs_layout_hdr *lo;
 	bool return_now = false;
@@ -2725,7 +2730,7 @@ pnfs_mark_layout_for_return(struct inode *inode,
 	 * for how it works.
 	 */
 	if (pnfs_mark_matching_lsegs_return(lo, &lo->plh_return_segs, range, 0,
-					    true) != -EBUSY) {
+					    true, devid) != -EBUSY) {
 		const struct cred *cred;
 		nfs4_stateid stateid;
 		enum pnfs_iomode iomode;
@@ -2742,7 +2747,8 @@ pnfs_mark_layout_for_return(struct inode *inode,
 }
 
 void pnfs_error_mark_layout_for_return(struct inode *inode,
-				       struct pnfs_layout_segment *lseg)
+				       struct pnfs_layout_segment *lseg,
+				       const struct nfs4_deviceid *devid)
 {
 	struct pnfs_layout_range range = {
 		.iomode = lseg->pls_range.iomode,
@@ -2750,7 +2756,7 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 		.length = NFS4_MAX_UINT64,
 	};
 
-	pnfs_mark_layout_for_return(inode, &range);
+	pnfs_mark_layout_for_return(inode, &range, devid);
 }
 EXPORT_SYMBOL_GPL(pnfs_error_mark_layout_for_return);
 
@@ -2840,7 +2846,7 @@ static int pnfs_layout_return_unused_byserver(struct nfs_server *server,
 		pnfs_get_layout_hdr(lo);
 		pnfs_set_plh_return_info(lo, range->iomode, 0);
 		if (pnfs_mark_matching_lsegs_return(lo, &lo->plh_return_segs,
-						    range, 0, true) != 0 ||
+						    range, 0, true, NULL) != 0 ||
 		    !pnfs_prepare_layoutreturn(lo, &stateid, &cred, &iomode)) {
 			spin_unlock(&inode->i_lock);
 			rcu_read_unlock();
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index bab81f769636..ccc65ad0e9af 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -177,7 +177,8 @@ struct pnfs_layoutdriver_type {
 	int (*prepare_layoutcommit) (struct nfs4_layoutcommit_args *args);
 	int (*prepare_layoutstats) (struct nfs42_layoutstat_args *args);
 
-	void (*cancel_io)(struct pnfs_layout_segment *lseg);
+	void (*cancel_io)(struct pnfs_layout_segment *lseg,
+			  const struct nfs4_deviceid *devid);
 };
 
 struct pnfs_commit_ops {
@@ -300,7 +301,8 @@ int pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 int pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
 				const struct pnfs_layout_range *recall_range,
-				u32 seq, bool cancel_io);
+				u32 seq, bool cancel_io,
+				const struct nfs4_deviceid *devid);
 int pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
 		struct list_head *lseg_list);
 bool pnfs_roc(struct inode *ino, struct nfs4_layoutreturn_args *args,
@@ -350,7 +352,8 @@ int pnfs_read_done_resend_to_mds(struct nfs_pgio_header *);
 int pnfs_write_done_resend_to_mds(struct nfs_pgio_header *);
 struct nfs4_threshold *pnfs_mdsthreshold_alloc(void);
 void pnfs_error_mark_layout_for_return(struct inode *inode,
-				       struct pnfs_layout_segment *lseg);
+				       struct pnfs_layout_segment *lseg,
+				       const struct nfs4_deviceid *devid);
 void pnfs_layout_return_unused_byclid(struct nfs_client *clp,
 				      enum pnfs_iomode iomode);
 int pnfs_layout_handle_reboot(struct nfs_client *clp);
@@ -689,10 +692,11 @@ pnfs_lseg_request_intersecting(struct pnfs_layout_segment *lseg, struct nfs_page
 }
 
 static inline void pnfs_lseg_cancel_io(struct nfs_server *server,
-				       struct pnfs_layout_segment *lseg)
+				       struct pnfs_layout_segment *lseg,
+				       const struct nfs4_deviceid *devid)
 {
 	if (server->pnfs_curr_ld->cancel_io)
-		server->pnfs_curr_ld->cancel_io(lseg);
+		server->pnfs_curr_ld->cancel_io(lseg, devid);
 }
 
 extern unsigned int layoutstats_timer;
-- 
2.53.0

