Received: from mail-oo1-f42.google.com (mail-oo1-f42.google.com [209.85.161.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 384F735E549
	for <linux-nfs@vger.kernel.org>; Wed,  9 Sep 2026 17:11:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788973919; cv=none; b=qGWU2bsE0ummjqEbVYyjRpuvkuPIGOaHO7nDf0StnGvSGSGzqnEMkbVLFok7p5D8UpHQTx53z/15zAOI5qL2t90TwBec+pMiq4FtUL9K00qhJO59c/w8tQisgYNDHyoH+C5jM1PAO8hyIk+EbtZjKCuMo4Olo28aWZDS69YZNfY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788973919; c=relaxed/simple;
	bh=VrzCbbrIt07+/Uz0MARKTGDreCXPfdr1oh7lYPV8HPA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=oo2Y9C5Q5wnFTwi+vtSItZTnY+kgxWD5Jlj9GV6wPIpz44OBVMtKoWW4Aj2LLL79V3AldnV3puB2gMYQfT1qJyAnTn4YRAgso3+WauUQwZcn3TEwkpoks/5gja7uWwfW0eGYK7RnJiK+s1TnUmq4GQ9N5pRVY/G332q98vyRPZI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=FYy7zwOW; arc=none smtp.client-ip=209.85.161.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="FYy7zwOW"
Received: by mail-oo1-f42.google.com with SMTP id 006d021491bc7-6be1f18687bso650589eaf.2
        for <linux-nfs@vger.kernel.org>; Wed, 09 Sep 2026 10:11:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788973915; x=1789578715; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=wnoKObvfPTDKUzwjIu4stWoJ0ujbCmGqjfwWdqz0n9E=;
        b=FYy7zwOWd/iHFxJhjuF0v9swJLIiA1lOfhuoLYsJs3lLk2uqoXhZ85wbAGeHlW9En/
         5hHsL7x4BxSIUb2/AajE2bGWGTt38EMlapRGylpJjPQtGpjHKeqavej/zTjT0TiaJ+ON
         QRfMQjdrM2EDqw43vie7vxqREgZe4dwk26FxF+zYJbzBJfOftWtK7Ktyhl01fIMQ9al4
         x6HlVWJG3gUtY2d6cu2a0zPgqdB9OeCm6h7w1cVJHoX2i1yZTjMqyMaElQuAlHKOOy09
         S+DlWH65tVST3++SjHJ07mrXiMcVrdn+GVOK3agmNuEqjrbU6w7OY1QP4t5iga1DdfFf
         VjHQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788973915; x=1789578715;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=wnoKObvfPTDKUzwjIu4stWoJ0ujbCmGqjfwWdqz0n9E=;
        b=CAa3NQwJMRL/Ve8g0X1SH5bFs0qpvkhwzr/InWfiAqWmGTXPueF1QkjaqGGDVOBRkN
         xsPqTCmXKUONCis1eJk5cmW03LK3673CEHtBd0NQ5hvADSfYfH3Jj0WlARwvN4RfVibM
         VSXhOtYPzAJzC9D16Bq28Zq93UHQpXtzpQd3R1CfzvvQ5gDOjf+0/WJm0Hi1UwFQI+FI
         0zaYRRiR3eMZJOQ96jYfWo86ycefM1dCoR8d7oSqPM3ZBXuQlDvFkoBkEOFVT4Jjra1Z
         z8ylL26KA2QM9t4HiBRSZDNHwuKUR7euTbPZtm2F8/g4aQ23/HyzIPkKMgeV2hzUYG2W
         TBRg==
X-Gm-Message-State: AFuF++kvZwuYENz4ggFy+lvnxfoBwgs6y/OWXKzHC/SzEDg90e6PXSrv
	H+YHuIh5Fs51q4qx0+YZ7PlUGUETpDHWy17jRwljV2pi2YY7POCihxAGr6ptf9hA6JE=
X-Gm-Gg: AYBFou0aOpJrU0cK+DqtlIiN97Zj1sLqSCqNF+MCMPGHNPkOylAQun/KJzcyRH8Tdbl
	8zLM5xBLajGAHHRsre6F8Wuvxhyqz09VQxKVX17gi4Z9eWYDOx8AJOS0y8oxXeEHEbtQpIp/O70
	WcEzIG/+1cpBik/uQ5/yCRaRJldhVgct4i9l4kJtg7JHpl9AWwP1N4XJlaO/EB/j4RWudmYatzj
	jlL8vpyifZknxz43hmsk6OH0BF1nSyl2vpsBNfjJvREvKuU5SoRfJZ7bjKAvHVdbutB7+ydNbQ/
	n4TkEIl6FezuxoWlkWG5xT5zIcHpfD0fsYnP7mKt9wRryjjRnuXKo3G3fa+8JW/fk8hbaSnBFAD
	ldAJFJnOPDivjvMKsgnm2G/H7txXeubvwjqLbOn+B0eSFyu54M5/7F04sADtU+FKa4lPicQ44OS
	RpuREyrqsFJvMLzwS0NJMjrH02wVWs7dGH4NCsmzqEzv+LDqeR7MI+1xRvA/B33uqyTNurYSpsN
	UPAN5hwIRWMecCV17ybNmGA//fWtLCOr7KwlZtskHZKbw==
X-Received: by 2002:a05:6820:1890:b0:6b1:b31f:132e with SMTP id 006d021491bc7-6b6fabd2e99mr22017060eaf.6.1788973914699;
        Wed, 09 Sep 2026 10:11:54 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-6b6dd57198esm20616428eaf.11.2026.09.09.10.11.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 09 Sep 2026 10:11:54 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH v2 2/3] pNFS: allow layout drivers to cancel I/O to a single device
Date: Wed,  9 Sep 2026 13:11:48 -0400
Message-ID: <b503ffc1aedbc2cee7da6b83e9afac82e058d0ab.1788973535.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1788973535.git.bcodding@hammerspace.com>
References: <cover.1788973535.git.bcodding@hammerspace.com>
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
Reviewed-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
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
index c9b71dbae9ea..9d836cb72e78 100644
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
index 0d53277f972e..d1c08d529e02 100644
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
index 8b43d642969b..fb7222a04559 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1281,7 +1281,7 @@ static void ff_layout_resend_pnfs_read(struct nfs_pgio_header *hdr)
 	mirror_ds = ff_layout_choose_any_ds_for_read(hdr->lseg, idx, &new_idx,
 						     hdr->args.offset, &dss_id);
 	if (IS_ERR(mirror_ds)) {
-		pnfs_error_mark_layout_for_return(hdr->inode, hdr->lseg);
+		pnfs_error_mark_layout_for_return(hdr->inode, hdr->lseg, NULL);
 	} else {
 		nfs4_ff_layout_put_deviceid(mirror_ds);
 		ff_layout_send_layouterror(hdr->lseg);
@@ -1294,7 +1294,7 @@ static void ff_layout_reset_read(struct nfs_pgio_header *hdr)
 	struct rpc_task *task = &hdr->task;
 
 	pnfs_layoutcommit_inode(hdr->inode, false);
-	pnfs_error_mark_layout_for_return(hdr->inode, hdr->lseg);
+	pnfs_error_mark_layout_for_return(hdr->inode, hdr->lseg, NULL);
 
 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
 		dprintk("%s Reset task %5u for i/o through MDS "
@@ -1594,7 +1594,7 @@ static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
 		fallthrough;
 	default:
 		pnfs_error_mark_layout_for_return(lseg->pls_layout->plh_inode,
-						  lseg);
+						  lseg, NULL);
 	}
 
 out:
@@ -2256,7 +2256,7 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 		 * FF_FLAGS_NO_IO_THRU_MDS: force fresh LAYOUTGET,
 		 * never fall through to MDS I/O.
 		 */
-		pnfs_error_mark_layout_for_return(hdr->inode, lseg);
+		pnfs_error_mark_layout_for_return(hdr->inode, lseg, NULL);
 		return PNFS_TRY_AGAIN;
 	}
 	trace_pnfs_mds_fallback_read_pagelist(hdr->inode,
@@ -2359,7 +2359,7 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 		 * FF_FLAGS_NO_IO_THRU_MDS: force fresh LAYOUTGET,
 		 * never fall through to MDS I/O.
 		 */
-		pnfs_error_mark_layout_for_return(hdr->inode, lseg);
+		pnfs_error_mark_layout_for_return(hdr->inode, lseg, NULL);
 		return PNFS_TRY_AGAIN;
 	}
 	trace_pnfs_mds_fallback_write_pagelist(hdr->inode,
@@ -2490,7 +2490,8 @@ static bool ff_layout_match_io(const struct rpc_task *task, const void *data)
 	return false;
 }
 
-static void ff_layout_cancel_io(struct pnfs_layout_segment *lseg)
+static void ff_layout_cancel_io(struct pnfs_layout_segment *lseg,
+				const struct nfs4_deviceid *devid)
 {
 	struct nfs4_ff_layout_segment *flseg = FF_LAYOUT_LSEG(lseg);
 	struct nfs4_ff_layout_mirror *mirror;
@@ -2503,6 +2504,9 @@ static void ff_layout_cancel_io(struct pnfs_layout_segment *lseg)
 	for (idx = 0; idx < flseg->mirror_array_cnt; idx++) {
 		mirror = flseg->mirror_array[idx];
 		for (dss_id = 0; dss_id < mirror->dss_count; dss_id++) {
+			if (devid && memcmp(&mirror->dss[dss_id].devid, devid,
+					    sizeof(*devid)) != 0)
+				continue;
 			rcu_read_lock();
 			mirror_ds = rcu_dereference(mirror->dss[dss_id].mirror_ds);
 			if (IS_ERR_OR_NULL(mirror_ds) ||
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index bc95628a811f..7bb0f2094e9d 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -453,7 +453,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 				 opnum, GFP_NOIO);
 	ff_layout_send_layouterror(lseg);
 	if (opnum != OP_READ || !ff_layout_has_available_ds(lseg))
-		pnfs_error_mark_layout_for_return(ino, lseg);
+		pnfs_error_mark_layout_for_return(ino, lseg, NULL);
 	ds = ERR_PTR(status);
 out:
 	return ds;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e577001b78f2..937c09c4c6f9 100644
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
@@ -2649,6 +2651,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
  * @return_range: describe layout segment ranges to be returned
  * @seq: stateid seqid to match
  * @cancel_io: signal io be cancelled
+ * @devid: only cancel io directed at this device (all devices if NULL)
  *
  * This function is mainly intended for use by layoutrecall. It attempts
  * to free the layout segment immediately, or else to mark it for return
@@ -2663,7 +2666,8 @@ int
 pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
 				const struct pnfs_layout_range *return_range,
-				u32 seq, bool cancel_io)
+				u32 seq, bool cancel_io,
+				const struct nfs4_deviceid *devid)
 {
 	struct pnfs_layout_segment *lseg, *next;
 	struct nfs_server *server = NFS_SERVER(lo->plh_inode);
@@ -2690,7 +2694,7 @@ pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 			remaining++;
 			set_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags);
 			if (cancel_io)
-				pnfs_lseg_cancel_io(server, lseg);
+				pnfs_lseg_cancel_io(server, lseg, devid);
 		}
 
 	if (remaining) {
@@ -2708,7 +2712,8 @@ pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 
 static void
 pnfs_mark_layout_for_return(struct inode *inode,
-			    const struct pnfs_layout_range *range)
+			    const struct pnfs_layout_range *range,
+			    const struct nfs4_deviceid *devid)
 {
 	struct pnfs_layout_hdr *lo;
 	bool return_now = false;
@@ -2726,7 +2731,7 @@ pnfs_mark_layout_for_return(struct inode *inode,
 	 * for how it works.
 	 */
 	if (pnfs_mark_matching_lsegs_return(lo, &lo->plh_return_segs, range, 0,
-					    true) != -EBUSY) {
+					    true, devid) != -EBUSY) {
 		const struct cred *cred;
 		nfs4_stateid stateid;
 		enum pnfs_iomode iomode;
@@ -2743,7 +2748,8 @@ pnfs_mark_layout_for_return(struct inode *inode,
 }
 
 void pnfs_error_mark_layout_for_return(struct inode *inode,
-				       struct pnfs_layout_segment *lseg)
+				       struct pnfs_layout_segment *lseg,
+				       const struct nfs4_deviceid *devid)
 {
 	struct pnfs_layout_range range = {
 		.iomode = lseg->pls_range.iomode,
@@ -2751,7 +2757,7 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 		.length = NFS4_MAX_UINT64,
 	};
 
-	pnfs_mark_layout_for_return(inode, &range);
+	pnfs_mark_layout_for_return(inode, &range, devid);
 }
 EXPORT_SYMBOL_GPL(pnfs_error_mark_layout_for_return);
 
@@ -2841,7 +2847,7 @@ static int pnfs_layout_return_unused_byserver(struct nfs_server *server,
 		pnfs_get_layout_hdr(lo);
 		pnfs_set_plh_return_info(lo, range->iomode, 0);
 		if (pnfs_mark_matching_lsegs_return(lo, &lo->plh_return_segs,
-						    range, 0, true) != 0 ||
+						    range, 0, true, NULL) != 0 ||
 		    !pnfs_prepare_layoutreturn(lo, &stateid, &cred, &iomode)) {
 			spin_unlock(&inode->i_lock);
 			rcu_read_unlock();
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 719657f3f4e1..9136ba64da94 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -197,7 +197,8 @@ struct pnfs_layoutdriver_type {
 	int (*prepare_layoutcommit) (struct nfs4_layoutcommit_args *args);
 	int (*prepare_layoutstats) (struct nfs42_layoutstat_args *args);
 
-	void (*cancel_io)(struct pnfs_layout_segment *lseg);
+	void (*cancel_io)(struct pnfs_layout_segment *lseg,
+			  const struct nfs4_deviceid *devid);
 };
 
 struct pnfs_commit_ops {
@@ -320,7 +321,8 @@ int pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 int pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
 				const struct pnfs_layout_range *recall_range,
-				u32 seq, bool cancel_io);
+				u32 seq, bool cancel_io,
+				const struct nfs4_deviceid *devid);
 int pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
 		struct list_head *lseg_list);
 bool pnfs_roc(struct inode *ino, struct nfs4_layoutreturn_args *args,
@@ -370,7 +372,8 @@ int pnfs_read_done_resend_to_mds(struct nfs_pgio_header *);
 int pnfs_write_done_resend_to_mds(struct nfs_pgio_header *);
 struct nfs4_threshold *pnfs_mdsthreshold_alloc(void);
 void pnfs_error_mark_layout_for_return(struct inode *inode,
-				       struct pnfs_layout_segment *lseg);
+				       struct pnfs_layout_segment *lseg,
+				       const struct nfs4_deviceid *devid);
 void pnfs_layout_return_unused_byclid(struct nfs_client *clp,
 				      enum pnfs_iomode iomode);
 void pnfs_layout_reresolve_deviceid_byclid(struct nfs_client *clp,
@@ -774,10 +777,11 @@ pnfs_lseg_request_intersecting(struct pnfs_layout_segment *lseg, struct nfs_page
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

