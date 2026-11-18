Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.167.169
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795027023;
	b=fGo/J/6i6WPYRs2xSGSkK91VB66AsogFvakx2GYc+OderNlkvQ0pQM4SSb5xIiauphPN
	 kdy2upWCJaILmiMzWgWN6zUrD6QHwfiNKolYFgWlu+NyLpSYuQAZwiVrGzRQG3YZr/NS+
	 P9BmbjazhiQ1NGImZWhMykwfzPJopVWcxpTPSEjm0Kf8P4wPz+cPd/9WNT6uK70lRiHgw
	 z4o6GiC9K/ygVddFW55jtf8AIdbMi68kJ86+QhIjUf6MfoMgN7Izeghgpq6O6Yn7GHvju
	 zKL9zBq/Wfi5bj0hdLXPDakzckK+XFlB3wlY4nt5j1JaT/wBPGvoxu8qezpYgmAkTPQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795027023;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=oVl/i1Eq/qHsMLJvaZFUbFgDofYwby2e5LDisGOPZUI=;
	b=L4VJLIXIUMhIahRPeJ6PnMBCsy/Hc9UW5aHxfmjzxi0uCwbZsyS6sKuswzHCGgBmAzxC
	 OIeJrIKwENgUrbbHjU9cbxnA7ON7qGGvt67tZq6nd4ZeVcXCNVyyYDpMc/XwSzz9PPyTf
	 LhT5FVvtu7sAKRtH5kEyyw90hDWFFO9Y5AGU7DVJh6MGBGWGKCPF7gnkOFJVnJftqdOjW
	 Ysh5qHOQUj3ozPQmTrsiYWezcy2CYHC/F6svyRWuFRfDDiLS1HAsV+LLkKkD8EQLHedEh
	 lELBnrKZEkfDNeuOKMVBsbZzNgEPuhrkV2MlUJVeagOWq+vra6RksO6zsJRy7Fbalvw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=a1uPGViS;
	arc=none smtp.remote-ip=209.85.167.169
Received: from mail-oi1-f169.google.com (mail-oi1-f169.google.com [209.85.167.169])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 90DE5606A335
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 18:37:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 90DE5606A335
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=a1uPGViS
Received: by mail-oi1-f169.google.com with SMTP id 5614622812f47-4ed6d69bdfaso673780b6e.3
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 10:37:02 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795027021; x=1795631821; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=oVl/i1Eq/qHsMLJvaZFUbFgDofYwby2e5LDisGOPZUI=;
        b=a1uPGViSz71T5VinPfuhLCm7ivT27qM5QMfW7aRiPuKlATUVsVIWznpBGb7nwbYAaN
         kKdE7WBLz3RBy9vOqr+uX1xafFinT+Ju4vvB+f0N33hEPBo7uie4UK1YEMAS3Ev3sR51
         4EJPpLhrOl/SMEIg1N6I+NTeZDOpQKOTH7c5ZV55KMFhtCZigHBSaHxNSISRHVLH39TF
         cFDvUY6FqTXH4VeJI4+mgVmflFhp8/SkwZd1bW2euWRjXac0fErRSFeQrrj6Y/qYYtpn
         yj78SEq6GyUgvgKF7E7fzrspezAgjbc3uYKjSxrYSIpbdP3iKrBggXDuNoAfeoKXOxuO
         6Rrw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795027021; x=1795631821;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=oVl/i1Eq/qHsMLJvaZFUbFgDofYwby2e5LDisGOPZUI=;
        b=0eNgyEY65EyhCGPY0r6qHY5SuDH9LBJEaltIKuJxEq9FcKWAqakQogjy+3KvVpHzgo
         BiHx95PIFmYcTrbAn8obahfdtEfO/FHZmL/Sjl+5/gfX7FObL7aRMFB9tyrgzfEOaLeZ
         mAxhEYHZlt3PK3QsRyrF1C1xwouIRKcPVBu6tqNZgaDtTbJAkovsGFw8KJKmq+3QFwNG
         m3bNAtiHQzzJDOen4yLwHGw/5xdWQPWcQyN6+JXNARrdVPcKG6R++nWkfPmLPCcna0vL
         FzrjG/wmSk7IVlcnNbX8042M1munobIkzSY5P9i6zILFZiRvI7hKgslzXUQdl9tIylMa
         cqjg==
X-Gm-Message-State: APuU4Z/Lu6Pv0XObN3z23SE2XhGPmDmhrEm4z8lEBjaufmkZCwTx+I0v
	tn1XI5Dxqhk3raqOlTdPRRh/319I0nF1FoHNh6vCEsKJtKOYlVb14pPTExvyJ7FFtso=
X-Gm-Gg: AYBFou08xld7C3KxV/FtN5zFy1JksA9BfdAZIqUID+11u1FQJmEQ0Ipi5gFQ2kIK7Lw
	Ux5/rd8FnjasE8MNBlOp8NV/DI4AJ865OtNo4bq/My7TdJw/fvL3QZywo9eSU4Byy5jUE77qPun
	STfwTS4AO3M5f1u3ZO7w8bEaR2ebG0FE9y8McaPHYhbaOIx4Q6cNgLs4fkzcStiRgPw1NIAgvWH
	U0A1futvpgqqqEkxB3cB/d6eJu5KeYZb9/X45BEQznSmBOt0GAeCRu3quxfpp6jN6944Pwr3dAY
	jfuLx2+zA0RUrNvzcnm4FVgjjvz1XcjBIPpsKdVfd6Jq8/gLcAMIxuELvajDzMT9tOPsfHfyO4x
	mA2MOIEUvnlWVFdgrkJlSdRE9Oxbxx/V8uTAf71jxja492ZdhSLbhJy1YF344A762n7wpSwdTun
	9DlFebRLJfMkxIzXdxBHHH4qx5BncadAJdkVPkIMPeN7UkXoTKXjGeHQpztYdjtq42PW7fk0f0m
	sR98WNBx8FEjWt56hk5vPWtlLPOgHMV8PZsAoXHVNLE9XMshP2ruk2+re8jipWII+mEV6vr+0zm
	3eD0NTopeBS/W1ndUw0Ok8k3sp42+gAUu6vC/QKfK91ZfJFieI6MreZqWWzU+H9fdHXkQJrYGMO
	E
X-Received: by 2002:a05:6808:1507:b0:577:28d8:2882 with SMTP id 5614622812f47-5774171cd3fmr3494414b6e.48.1795027021040;
        Wed, 18 Nov 2026 10:37:01 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5777a8a6af8sm2341713b6e.9.2026.11.18.10.37.00
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 18 Nov 2026 10:37:00 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] pNFS/flexfiles: use the MDS when the server has no layout to give
Date: Wed, 18 Nov 2026 13:36:54 -0500
Message-ID: <fc18ef8a2eb36c607fb547d962a0fbc704087f6c.1795024981.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1795024981.git.bcodding@hammerspace.com>
References: <cover.1795024981.git.bcodding@hammerspace.com>
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
index a522c3fe49e5..c4fae5408535 100644
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
@@ -1135,13 +1139,12 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
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
@@ -1395,7 +1398,8 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
 					   struct nfs4_state *state,
 					   struct nfs_client *clp,
 					   struct pnfs_layout_segment *lseg,
-					   struct nfs4_deviceid_node *devid)
+					   struct nfs4_deviceid_node *devid,
+					   u32 iomode)
 {
 	struct pnfs_layout_hdr *lo = lseg->pls_layout;
 	struct inode *inode = lo->plh_inode;
@@ -1484,8 +1488,9 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
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
@@ -1495,7 +1500,7 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
 	 * pnfs_destroy_layout().  Having done so they can no longer ask the
 	 * layout hdr about the flag, hence the inode.
 	 */
-	if (nfs_no_io_thru_mds(inode)) {
+	if (ff_layout_inode_no_fallback_to_mds(inode, iomode)) {
 		dprintk("%s Retry through pNFS, no MDS fallback. Error %d\n",
 			__func__, task->tk_status);
 		return -NFS4ERR_RESET_TO_PNFS;
@@ -1580,7 +1585,8 @@ static int ff_layout_async_handle_error(struct rpc_task *task,
 					struct nfs4_state *state,
 					struct nfs_client *clp,
 					struct pnfs_layout_segment *lseg,
-					struct nfs4_deviceid_node *devid)
+					struct nfs4_deviceid_node *devid,
+					u32 iomode)
 {
 	int vers = clp->cl_nfs_mod->rpc_vers->number;
 
@@ -1600,7 +1606,7 @@ static int ff_layout_async_handle_error(struct rpc_task *task,
 						       lseg, devid);
 	case 4:
 		return ff_layout_async_handle_error_v4(task, op_status, state,
-						       clp, lseg, devid);
+						       clp, lseg, devid, iomode);
 	default:
 		/* should never happen */
 		WARN_ON_ONCE(1);
@@ -1734,7 +1740,7 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 	err = ff_layout_async_handle_error(task, hdr->res.op_status,
 					   hdr->args.context->state,
 					   hdr->ds_clp, hdr->lseg,
-					   hdr->ds_dev);
+					   hdr->ds_dev, IOMODE_READ);
 
 	trace_nfs4_pnfs_read(hdr, err);
 	clear_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags);
@@ -1944,7 +1950,7 @@ static int ff_layout_write_done_cb(struct rpc_task *task,
 	err = ff_layout_async_handle_error(task, hdr->res.op_status,
 					   hdr->args.context->state,
 					   hdr->ds_clp, hdr->lseg,
-					   hdr->ds_dev);
+					   hdr->ds_dev, IOMODE_RW);
 
 	trace_nfs4_pnfs_write(hdr, err);
 	clear_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags);
@@ -1995,7 +2001,7 @@ static int ff_layout_commit_done_cb(struct rpc_task *task,
 
 	err = ff_layout_async_handle_error(task, data->res.op_status,
 					   NULL, data->ds_clp, data->lseg,
-					   data->ds_dev);
+					   data->ds_dev, IOMODE_RW);
 
 	trace_nfs4_pnfs_commit_ds(data, err);
 	switch (err) {
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 5b40364fc38f..fc2a27b5126a 100644
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

