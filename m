Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795120056;
	b=ZjAJksk7/nvRjPijjoSoQkPY1bGs/Svz7XT0mE386OuyMm3CzCWd90+1XYjcGIlgNTZJ
	 dLm6fRuajqp94drGMWw8p0a4yMUHqd+QlDPtCkVuJ5xujwUi/vVMhVIBOmdBU7fRh11SC
	 0qEDX351mNqxsDLzP8mR7NLYJhz7iCStd9eQIIWjdMJGuUkMH3ogk6vMTtmYk2BW9Tkf6
	 FMaKCTDpqSSDJ3u6eopydtboxFpca932CWypq8G1cSmUrzb6z6wJ0t9dTA6tMvHzkCy7R
	 +FdazBvlzGvLPhnz0B9NyBtHUHo/cOsNT5bzCiKs9Y6TEljfePK43LALM2yWq2Dr5qg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795120056;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=E2LetXhQvfbCCkGU3P0BXIRfFcIFGuDjezfVP4BBhvo=;
	b=gUUIX6raYZlJQHg4wlFYbFfeMODZp5oY0k/EcffcBbWqipOv6pqiodzoXb+x1iuykfFC
	 wo32k1gf7S7VqTVfOehdi0rb2H4+nai5/IHjzIVRD79mjXdCCfwcau4aVmEXXOrxm9JCQ
	 eBe4dO6TpFTFU2V6v/jQLC3blYR2wSDymRf9We3u1aPXbWWy8gPmKB8jQW7cwhnIi1hJO
	 W0r6VYJ+pG2nrx1S+qK05DX8Wr5YX7yNaRtVjMXUTF4M5SRZP3A7jCy7B+6Jy0KadoDbe
	 t5xxvCQbaVuC+v95IAvA13UfkVEJJKIQfpr1rMbhb2bSlfCOQfG8WNuQ6/6WyKBFBRw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=PNUKJvBb;
	arc=none smtp.remote-ip=209.85.210.47
Received: from mail-ot1-f47.google.com (mail-ot1-f47.google.com [209.85.210.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 81D1C606A333
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 20:27:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 81D1C606A333
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=PNUKJvBb
Received: by mail-ot1-f47.google.com with SMTP id 46e09a7af769-86156cf8a7eso1017490a34.1
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 12:27:36 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795120055; x=1795724855; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=E2LetXhQvfbCCkGU3P0BXIRfFcIFGuDjezfVP4BBhvo=;
        b=PNUKJvBb+GRt+1f8M8iBI0WGCojSsZ5BcRhybCTC4y2Xa0lPZCKSgeiJFUBHcMA+8Z
         52LuC7qZPh2aJhRjyiI4Of201p/gLvP+EGiHGfei0mFyCOYkKZ31tFW2A1tquzo99i7+
         MVJM/HVnen5HOev+fyxE9zWsNG7VKWkecU1WyCTDa4jWbsWwCBT5nkuXn5zK63bfjAmu
         JoEcE+LVKidPQ2YmNUdAK2+9wbPwXgF4DRhsnxQgsga6OQCrhrnCL1yP+ssuMfXgSQ2+
         Win4NDSg3Bj6vful4MvBWofeVY2+bWFarnzXIVM+5m/QhtM+/yTy6XaD1xj16CbFolke
         3VZQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795120055; x=1795724855;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=E2LetXhQvfbCCkGU3P0BXIRfFcIFGuDjezfVP4BBhvo=;
        b=XM3SzZHFVxRCbrHRyT8uJGh78/SuVIpNo7zZxaOWu9gV8ZnF/eTtpnwYHsGm8qpbxU
         Bcew/lRWi/ufgY9iSJDKT/xuzJMcKdJNdFFUUXLdx/9ouLENQXbjEp+uxxTKY6LGKXLl
         nxqAv+H70KefPE3q8mIeudAlwhdTFwkqVmHPauAd/ZP2KWNIeU+xiv1j5khpIsllQFM2
         cYf/SwhArOe4xM6imqDjx5Uor3lKnyK3xI0ISWwixP/C8MDXxEdsLogNtZhTRLACLJzw
         70GWXIHaE0fPy/XIda+/y63EnCt87WQI/dcICBA1VQIonTGB/PmvfdsIlSxwRZddnKFG
         9lOQ==
X-Gm-Message-State: APuU4Z+XNY0dNU4arZ+N5SmtpFNwbKaliDtRaw4HT1fojs08h+ZzSk+t
	jrSJOdIoIFwvghoD//5GD+m/LYdAiQpPhXW3D6yjJyLhfaOsBn0HBTApVN476bF7/j4=
X-Gm-Gg: AYBFou3JocVSBKUEwbsRNX/K7snxPf+lkM2ApzVUcI0PA9AoLaRSQ9CnSK+CCdkJZ7x
	pa7IzDXgug//k0s6GD6yIVjy9j7a/Ha13KVzHnr+7DDuAds5We7alAkTIcEEz5x6mysiXQlO/a8
	WnC/Wt74Iy3QyAC0B8aC6cXHssYbMC3jhccxXwM88wXNpyCbW5+G7SoT/1XVLTjyY1VxcNkSjZp
	24RUAeyxd/CtjdLAwrVvBD35kfV7Z+HSGg0AqJctlK96VXT3Z3EVqh67NdwLZniMvULrI0quZfX
	S53PejOiOZCB7tmdAe7vrhHgoLz0doQ0Sk2KTBtLzZjWVOi2Y8kC25k3qqH46YWcPMTNl0scQXe
	ST8SA9VEWx2j8qzipwEBA6kqsROQ9kSH7uxc6Y/0gY01nt/V1c6P1RilKdNiRquExtYEpFETzHy
	M3TMTVhXsd8jfbr4Z437dEUMl6XAXhcsGxhYalf5XDXBlQyl+YJ04CeseAGZtt5C1rh8Me8LnDO
	asCMIqFcweIKNkF17Vea+eujYWsYD2h1+D1jrbDr54pp+x6AgQdfCkF3crBsgNpyAyhUBuUouGR
	NADqjSZOXs9XWuJSFVKT2HlnLdYgTauAWg/wNMKHsMKrOlGqaij5/ghiZlEVhTTeipJnBjrfnLL
	5
X-Received: by 2002:a05:6830:914:b0:862:bc91:d23d with SMTP id 46e09a7af769-863092af562mr2068586a34.30.1795120055284;
        Thu, 19 Nov 2026 12:27:35 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-863168dde05sm506933a34.13.2026.11.19.12.27.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 12:27:35 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 5/5] pNFS/flexfiles: use the MDS when the server has no layout to give
Date: Thu, 19 Nov 2026 15:27:28 -0500
Message-ID: <352a4bb64288e5ec624b6c06692f5de009f8cda8.1795117974.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1795117974.git.bcodding@hammerspace.com>
References: <cover.1795117974.git.bcodding@hammerspace.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

When LAYOUTGET fails with NFS4ERR_LAYOUTUNAVAILABLE, or with
NFS4ERR_TOOSMALL after the retry at the session's maximum reply size,
pnfs_update_layout() sets the layout's fail bit for that iomode and
returns no layout without sending another LAYOUTGET for the next 120
seconds.  If the file's layouts carried FF_FLAGS_NO_IO_THRU_MDS, reads
and writes wait for a layout the whole time, and then send a LAYOUTGET
that can fail the same way.  On a hard mount that repeats for as long
as the server keeps answering that way.

RFC 8435 says that after NFS4ERR_LAYOUTUNAVAILABLE "the I/O is to go to
the metadata server" (section 5.1.1), and that FF_FLAGS_NO_IO_THRU_MDS
is a hint (section 5.1.2).  Send the I/O through the MDS while the fail
bit is set, in ff_layout_inode_no_fallback_to_mds(), which reads,
writes and the resend after a data server error share.  This also lets
a server deal with a data server the client can't use: the client
reports the failure with LAYOUTERROR (or in LAYOUTRETURN) and returns
the layout, and the server can answer the next LAYOUTGET with
NFS4ERR_LAYOUTUNAVAILABLE.

Fixes: 2f007ba074ad ("pNFS/flexfiles: don't read through MDS when previous layout forbid it")
Fixes: 1d62e659c0bf ("NFSv4/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS in pg_get_mirror_count_write")
Fixes: ec906cf7bee6 ("pNFS/flexfiles: don't reset to MDS for v4 error when previous layout forbid it")
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 40 +++++++++++++++-----------
 fs/nfs/internal.h                      |  6 ++--
 fs/nfs/pnfs.c                          | 22 ++++++++++++++
 fs/nfs/pnfs.h                          |  1 +
 4 files changed, 50 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 784070cd5a84..85ee1b8aac3f 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -980,10 +980,14 @@ static bool ff_layout_pg_retry_wait(struct nfs_pageio_descriptor *pgio)
 
 /*
  * Returns true if the inode's layouts forbid I/O through the MDS.
+ * FF_FLAGS_NO_IO_THRU_MDS is a hint (RFC 8435, section 5.1.2), so set it
+ * aside while a failed LAYOUTGET for @iomode (NFS4ERR_LAYOUTUNAVAILABLE or
+ * NFS4ERR_TOOSMALL) keeps pnfs_update_layout() from sending another.
  */
 static bool ff_layout_inode_no_fallback_to_mds(struct inode *inode, u32 iomode)
 {
-	return nfs_no_io_thru_mds(inode);
+	return nfs_no_io_thru_mds(inode) &&
+	       !pnfs_layout_get_failed(inode, iomode);
 }
 
 /*
@@ -1141,13 +1145,12 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 	}
 	/*
 	 * No segment, and no error to report either: pnfs_update_layout()
-	 * simply has nothing to give (NFS_LAYOUT_BULK_RECALL, a failed
-	 * pnfs_layout_io_test, blocked LAYOUTGETs, a layout being
-	 * returned).  If the server forbids reading this file through the
-	 * MDS there is no fallback to take, so wait for a layout on the
-	 * same terms as the -EAGAIN above.  The layout hdr that carried
-	 * FF_FLAGS_NO_IO_THRU_MDS may itself be gone by now, which is why
-	 * the flag is kept on the inode.
+	 * simply has nothing to give (NFS_LAYOUT_BULK_RECALL, blocked
+	 * LAYOUTGETs, a layout being returned).  If the server forbids
+	 * reading this file through the MDS there is no fallback to take,
+	 * so wait for a layout on the same terms as the -EAGAIN above.  The
+	 * layout hdr that carried FF_FLAGS_NO_IO_THRU_MDS may itself be
+	 * gone by now, which is why the flag is kept on the inode.
 	 */
 	if (!ff_layout_inode_no_fallback_to_mds(pgio->pg_inode, IOMODE_READ))
 		goto out_mds;
@@ -1412,7 +1415,8 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
 					   struct nfs4_state *state,
 					   struct nfs_client *clp,
 					   struct pnfs_layout_segment *lseg,
-					   struct nfs4_deviceid_node *devid)
+					   struct nfs4_deviceid_node *devid,
+					   u32 iomode)
 {
 	struct pnfs_layout_hdr *lo = lseg->pls_layout;
 	struct inode *inode = lo->plh_inode;
@@ -1501,8 +1505,9 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
 		return -NFS4ERR_RESET_TO_PNFS;
 reset:
 	/*
-	 * FF_FLAGS_NO_IO_THRU_MDS: never resend through the MDS.  The
-	 * caller would do so with force_mds set (ff_layout_reset_read(),
+	 * FF_FLAGS_NO_IO_THRU_MDS: don't resend through the MDS (see
+	 * ff_layout_inode_no_fallback_to_mds()).  The caller would do so
+	 * with force_mds set (ff_layout_reset_read(),
 	 * ff_layout_reset_write(hdr, false) -> pnfs_*_done_resend_to_mds()),
 	 * which builds a descriptor out of the plain MDS page ops and so
 	 * consults no layout at all -- this is the last point at which the
@@ -1512,7 +1517,7 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
 	 * pnfs_destroy_layout().  Having done so they can no longer ask the
 	 * layout hdr about the flag, hence the inode.
 	 */
-	if (nfs_no_io_thru_mds(inode)) {
+	if (ff_layout_inode_no_fallback_to_mds(inode, iomode)) {
 		dprintk("%s Retry through pNFS, no MDS fallback. Error %d\n",
 			__func__, task->tk_status);
 		return -NFS4ERR_RESET_TO_PNFS;
@@ -1597,7 +1602,8 @@ static int ff_layout_async_handle_error(struct rpc_task *task,
 					struct nfs4_state *state,
 					struct nfs_client *clp,
 					struct pnfs_layout_segment *lseg,
-					struct nfs4_deviceid_node *devid)
+					struct nfs4_deviceid_node *devid,
+					u32 iomode)
 {
 	int vers = clp->cl_nfs_mod->rpc_vers->number;
 
@@ -1617,7 +1623,7 @@ static int ff_layout_async_handle_error(struct rpc_task *task,
 						       lseg, devid);
 	case 4:
 		return ff_layout_async_handle_error_v4(task, op_status, state,
-						       clp, lseg, devid);
+						       clp, lseg, devid, iomode);
 	default:
 		/* should never happen */
 		WARN_ON_ONCE(1);
@@ -1751,7 +1757,7 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 	err = ff_layout_async_handle_error(task, hdr->res.op_status,
 					   hdr->args.context->state,
 					   hdr->ds_clp, hdr->lseg,
-					   hdr->ds_dev);
+					   hdr->ds_dev, IOMODE_READ);
 
 	trace_nfs4_pnfs_read(hdr, err);
 	clear_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags);
@@ -1961,7 +1967,7 @@ static int ff_layout_write_done_cb(struct rpc_task *task,
 	err = ff_layout_async_handle_error(task, hdr->res.op_status,
 					   hdr->args.context->state,
 					   hdr->ds_clp, hdr->lseg,
-					   hdr->ds_dev);
+					   hdr->ds_dev, IOMODE_RW);
 
 	trace_nfs4_pnfs_write(hdr, err);
 	clear_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags);
@@ -2013,7 +2019,7 @@ static int ff_layout_commit_done_cb(struct rpc_task *task,
 
 	err = ff_layout_async_handle_error(task, data->res.op_status,
 					   NULL, data->ds_clp, data->lseg,
-					   data->ds_dev);
+					   data->ds_dev, IOMODE_RW);
 
 	trace_nfs4_pnfs_commit_ds(data, err);
 	switch (err) {
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9819c4db3d85..bcbb5996c55c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -558,8 +558,10 @@ static inline bool nfs_file_io_is_buffered(struct nfs_inode *nfsi)
  * thing pnfs_within_mdsthreshold() can ask for is the one thing the
  * layout forbids.  Flexfiles also retries reads and writes that have no
  * layout segment instead of sending them through the MDS, except
- * writeback of a single locked folio (pg_allow_mds).  Servers are
- * assumed to be consistent in their no-fallback policy per file.
+ * writeback of a single locked folio (pg_allow_mds), and unless a
+ * LAYOUTGET for that iomode has failed with NFS4ERR_LAYOUTUNAVAILABLE or
+ * NFS4ERR_TOOSMALL.  Servers are assumed to be consistent in their
+ * no-fallback policy per file.
  */
 #define NFS_INO_NO_IO_THRU_MDS	(30)
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 14f4a4b12ffd..582fe81fc2d1 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -551,6 +551,28 @@ pnfs_layout_io_test_failed(struct pnfs_layout_hdr *lo, u32 iomode)
 	return true;
 }
 
+/*
+ * Returns true if a LAYOUTGET for @iomode failed with an error, such as
+ * NFS4ERR_LAYOUTUNAVAILABLE, in the last PNFS_LAYOUTGET_RETRY_TIMEOUT.
+ * pnfs_layout_io_test_failed() clears an expired fail bit only when
+ * pnfs_update_layout() gets that far, so check the time here too.
+ */
+bool pnfs_layout_get_failed(struct inode *inode, u32 iomode)
+{
+	struct pnfs_layout_hdr *lo;
+	unsigned long now = jiffies;
+	bool ret = false;
+
+	spin_lock(&inode->i_lock);
+	lo = NFS_I(inode)->layout;
+	if (lo && test_bit(pnfs_iomode_to_fail_bit(iomode), &lo->plh_flags))
+		ret = time_in_range(lo->plh_retry_timestamp,
+				    now - PNFS_LAYOUTGET_RETRY_TIMEOUT, now);
+	spin_unlock(&inode->i_lock);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(pnfs_layout_get_failed);
+
 static void
 pnfs_init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg,
 		const struct pnfs_layout_range *range,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 2774d4adf4c3..0007a4ca3da9 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -296,6 +296,7 @@ int pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc);
 size_t pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio,
 			    struct nfs_page *prev, struct nfs_page *req);
 void pnfs_set_lo_fail(struct pnfs_layout_segment *lseg);
+bool pnfs_layout_get_failed(struct inode *inode, u32 iomode);
 struct pnfs_layout_segment *pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_layoutget_free(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
-- 
2.53.0

