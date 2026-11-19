Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.54
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795120055;
	b=GkuBiZ1DB3iYn/8QDFt7rcLAawBKOMGGA5N1brcda/gJkE2uV5OlHfRUzLqDz6SXH2SM
	 hqrzsMGx3Uk3ZqD3lIwU14EXpXyxfgWyJE/RGfu7IXmpQoETegHOEqBw7gQlIjYTE8RHC
	 5F2+3bbWZgxYnAFxkpKAwsvI8bifm62ZBuIgsRXHeRZlrxxdgySeGk2mi1PCregGho8y3
	 1pouv2ZkzqwTsCm57zrwnMb2086qcH3odBRFWMLAaGpggReq/n5YzJ9zgWRKD7thIaSqH
	 BkdPE+UfUQmzOVGBVjBCKkVqgNQPoVVlPHNPCEC/fVWhWdtadLzNVOPnWwXWZiTgRcw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795120055;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=3c9CsPwj5IV/RwfV5y5n99AIxLViT7kUn6ribeIdDn0=;
	b=5TLW3U2/Ly+H5pxhgRlqsA34r4qpuXCmtUe+YAzTtaU8PrntwPLt9F/9eF4A37XHVrXi
	 cAg4PV9Ql6vFTnO0pH6UgIv8zjFOic+bIN0eATbXx4zTgFt/NqhAzZ0rRxWUH9KQ49hxc
	 ZwoLfagrqCndAr5l8gU27mUJqk7CIRViC4LSGZHVxOIiOBJjuakqLN8CPhh+CNIx3vNiO
	 IiiipWGiiTeTUFUofn6uuF/BiDiUa7uNu2LATdaElJRIKlXotIxHuXrW33USPHrRgQsw4
	 zLaoxpBD6zMgtZz7quCLHEvLNu+Ay529nZ2+N7luO0gGNvuZktBSv7gYKRQc9BWDC9g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=j19DOvVE;
	arc=none smtp.remote-ip=209.85.210.54
Received: from mail-ot1-f54.google.com (mail-ot1-f54.google.com [209.85.210.54])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A71CF60A2602
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 20:27:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A71CF60A2602
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=j19DOvVE
Received: by mail-ot1-f54.google.com with SMTP id 46e09a7af769-86288992de5so85212a34.1
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 12:27:34 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795120054; x=1795724854; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=3c9CsPwj5IV/RwfV5y5n99AIxLViT7kUn6ribeIdDn0=;
        b=j19DOvVEOoWl/oooOS97eQBdqxv+beBYUebrKVHEpOnMaRyDQBy40UH/5cdAQpCfHP
         CkZ/xWnCGhf7B75BXsJaB6/8FevEg+3WiWgYPjpL0Nynd6bODeHhpz8H89cua4oeQnuX
         7mfJBTNBU6/hJ8zzli1/3B5t54IQE4wkTkPWrH3nOZeuUooo4+GOMNreekf6dU97EeqB
         bI9lo1n2UF5DHHEwpUn/DRVeSWV5xhnUMsXsphrXs5OZ6g8AAlKJoSIklXSQ3ESuEWB/
         KDdEzKZW52q9xjJmrrknaIsCgVi7aOZwlBAgNSKlneD3U2iKKRhxXAo1LuMAHFT6rnyd
         BfzA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795120054; x=1795724854;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=3c9CsPwj5IV/RwfV5y5n99AIxLViT7kUn6ribeIdDn0=;
        b=hW2ll5VVNb5DTOjfEd8+kdbbLga+jkzNRGMIw+LDlhGUas5GTahNtXrNQ4wyejt7py
         n9YMv9AEv1zfM1CApw18OfkywSCp7AfKtSxyRNjBaHG12BFLO0x+2t845f175J4kHqOb
         3Th+8t6hF1YAL7Ai2B0CDF5JXHYK5Ea3P+SBkJ6IkTY5BIeo9pH21DoWupc/iAnR2G+q
         akBmXqQypiSdtlitXotyL5sJX5oCMV9h9Ubjsa3uimPu/ur4jH+De7C7MSXWXm6HehwA
         bV5dzyjaZUG3BCFFfoR9E/KFnjORI+jRDd+o2z1QvRxzJ6BZKoC3TaodeWPOmC7Wmjqp
         KfWw==
X-Gm-Message-State: APuU4Z+hU7CvHn0racGmJxCC5bKLWl7IKmS/Tu+f6/r3EKNak6iDZ79h
	Je41cXj6AKMP85Pr4ZhZkf07EI63HF5RctLituCWQiYoQarWpuSY+P96cfBpl2KpN9M=
X-Gm-Gg: AYBFou0wpe2aUZ2mw/DcJKDEhSa1ou12aGc/UTdQHmoEPeqexWUDy7YaUCH2YlIGNny
	Bpsks697QU2fnVyTLi0lKpLqqQY0mzGFagw7cfJ7QdVTmz4Y5uV8qDPezrAuosKTWT6r+ksJmaF
	pOzYMDpIJ+wb9b2JDPbF78dIWnXsHWBeCO2Vc3zYrBrkdmfx4p0fQWGB7H44aIBUYISQXFd3RiE
	avRQcLBimcHBUg2z+rZ56aF2fBUfqzstfhWwPSZxWBaf+XoMgr0idGMqBpfDGW49O6BrgzewwOk
	XJOdvmIx0/D72kanSuX4oFVEXG1oVcg4s7cis0wchmPjPH9g5WTf1wHsM6hoMdE8dQ/x5/48FHP
	0LHVJuVJDXLpGSMvWC4toMTw/WUsjZDjLL8+gj4abnHfDWQWzPrVBSRQun3YvsUk2ohZtkOYZuu
	6zImAOGPubguS3IMko7F4X2tS3DsVupNsaFaGHbvN2lDkr9OP6otXJ1O3GabvTMjhkcBc56iVBP
	hG7R7Z25ddZ7/bHX3TwURn0M0XxcVbDrPNpO9BpZHJ0KchCco9E6dyLMfX2VsuRio3pRyxn7bYN
	Ohoqa7RJsjo/zmKFJTDyBnaOTVhRoi+Er+lv8sIiB4VhcnNtDMNjdGGbgYtRXpDOWYjoBZdBHmQ
	MNNI2zXvG29poU245yXsJ5Q==
X-Received: by 2002:a05:6830:a25a:10b0:861:f4f6:1f92 with SMTP id 46e09a7af769-8631549a8fcmr732976a34.4.1795120053463;
        Thu, 19 Nov 2026 12:27:33 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-863168dde05sm506933a34.13.2026.11.19.12.27.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 12:27:33 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/5] pNFS/flexfiles: pace writes that have no layout and can't use the MDS
Date: Thu, 19 Nov 2026 15:27:26 -0500
Message-ID: <58030e4d2e3473d51c20ffc9b79edeb5a5348629.1795117974.git.bcodding@hammerspace.com>
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

When a write has no layout segment and its file's layouts carry
FF_FLAGS_NO_IO_THRU_MDS, ff_layout_pg_get_mirror_count_write() returns
-EAGAIN.  nfs_writepages() and the O_DIRECT reschedule path resend it at
once, so writers spin for as long as pnfs_update_layout() has no layout
to give: while NFS_LAYOUT_BULK_RECALL is set, while LAYOUTGETs are
blocked, and for the 120 seconds after NFS4ERR_LAYOUTUNAVAILABLE.

The check also tests a bit on the layout header.  Once that header has
been freed, a new one starts without the bit and the write goes through
the MDS.  ff_layout_pg_init_write() has no check at all: when
pnfs_generic_pg_check_layout() drops an invalidated segment, the rest of
the descriptor's writes go through the MDS.

Handle both places the way ff_layout_pg_init_read() handles reads: test
the inode's NFS_INO_NO_IO_THRU_MDS bit, return -ERESTARTSYS when the
task sending the write is killed or exiting, and honour io_maxretrans on
soft mounts.  Mark a refusal with a new pg_nolayout descriptor bit.
After the pass that was refused has unlocked its folios and requests,
data-integrity nfs_writepages() waits a second before it resends, and a
fatal signal ends the wait.  Other writeback stops there and leaves the
refused folios dirty, instead of waiting a second for each one.
nfs_direct_write_reschedule() queues its next pass a second later
instead of resending at once.  That pass runs on nfsiod rather than in
the writer, so a fatal signal to the writer does not end its retries;
io_maxretrans on soft mounts does.  Writes marked pg_allow_mds by
nfs_writepage_locked() still go through the MDS.

The test is ff_layout_inode_no_fallback_to_mds(), which
ff_layout_pg_init_read() now uses too, and the refusal is
ff_layout_pg_refuse_write().  Emit the MDS-fallback tracepoint only when
the write does go through the MDS, and a new
pnfs_mds_fallback_write_refused tracepoint when it is refused.  No lseg
pins the layout header that either tracepoint reads, so emit them under
i_lock.

Fixes: 1d62e659c0bf ("NFSv4/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS in pg_get_mirror_count_write")
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/direct.c                        |  5 +-
 fs/nfs/flexfilelayout/flexfilelayout.c | 91 ++++++++++++++++++--------
 fs/nfs/internal.h                      |  1 +
 fs/nfs/nfs4trace.c                     |  1 +
 fs/nfs/nfs4trace.h                     |  1 +
 fs/nfs/pagelist.c                      |  1 +
 fs/nfs/write.c                         | 11 ++++
 include/linux/nfs_page.h               |  1 +
 8 files changed, 85 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 9ef8031a68ad..bc665d5c79ab 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -626,6 +626,8 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 		}
 	}
 
+	if (desc.pg_error == -EAGAIN && desc.pg_nolayout)
+		dreq->work_delay = HZ;
 	if (put_dreq(dreq))
 		nfs_direct_write_complete(dreq);
 }
@@ -744,6 +746,7 @@ static void nfs_direct_write_schedule_work(struct work_struct *work)
 	int flags = dreq->flags;
 
 	dreq->flags = 0;
+	dreq->work_delay = 0;
 	switch (flags) {
 		case NFS_ODIRECT_DO_COMMIT:
 			nfs_direct_commit_schedule(dreq);
@@ -762,7 +765,7 @@ static void nfs_direct_write_complete(struct nfs_direct_req *dreq)
 {
 	trace_nfs_direct_write_complete(dreq);
 	/* Calls nfs_direct_write_schedule_work */
-	queue_delayed_work(nfsiod_workqueue, &dreq->work, 0);
+	queue_delayed_work(nfsiod_workqueue, &dreq->work, dreq->work_delay);
 }
 
 static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 56527054d87b..e29e5d8b5299 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -982,6 +982,51 @@ static bool ff_layout_pg_retry_wait(struct nfs_pageio_descriptor *pgio)
 	return true;
 }
 
+/*
+ * Returns true if the inode's layouts forbid I/O through the MDS.
+ */
+static bool ff_layout_inode_no_fallback_to_mds(struct inode *inode, u32 iomode)
+{
+	return nfs_no_io_thru_mds(inode);
+}
+
+/*
+ * Refuse a write that has no layout segment and can't go through the MDS:
+ * -EAGAIN so that the caller resends it, or a hard error when the caller
+ * should give up.  pg_nolayout tells a caller that resends at once to
+ * wait first, once it has dropped its locks.
+ */
+static void ff_layout_pg_refuse_write(struct nfs_pageio_descriptor *pgio,
+				      struct nfs_page *req)
+{
+	struct inode *inode = pgio->pg_inode;
+	struct nfs_server *server = NFS_SERVER(inode);
+
+	/* No lseg pins the layout hdr, and it is detached under i_lock */
+	if (trace_pnfs_mds_fallback_write_refused_enabled()) {
+		spin_lock(&inode->i_lock);
+		trace_pnfs_mds_fallback_write_refused(inode, req_offset(req),
+						      req->wb_bytes, IOMODE_RW,
+						      NFS_I(inode)->layout,
+						      NULL);
+		spin_unlock(&inode->i_lock);
+	}
+	if (server->flags & (NFS_MOUNT_SOFT | NFS_MOUNT_SOFTERR) &&
+	    io_maxretrans && req->wb_nio > io_maxretrans) {
+		if (server->flags & NFS_MOUNT_SOFTERR)
+			pgio->pg_error = -ETIMEDOUT;
+		else
+			pgio->pg_error = -EIO;
+		return;
+	}
+	if (fatal_signal_pending(current) || nfs_current_task_exiting()) {
+		pgio->pg_error = -ERESTARTSYS;
+		return;
+	}
+	pgio->pg_nolayout = 1;
+	pgio->pg_error = -EAGAIN;
+}
+
 static void
 ff_layout_pg_get_read(struct nfs_pageio_descriptor *pgio,
 		      struct nfs_page *req,
@@ -1108,7 +1153,7 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 	 * FF_FLAGS_NO_IO_THRU_MDS may itself be gone by now, which is why
 	 * this asks the inode and not the hdr.
 	 */
-	if (!nfs_no_io_thru_mds(pgio->pg_inode))
+	if (!ff_layout_inode_no_fallback_to_mds(pgio->pg_inode, IOMODE_READ))
 		goto out_mds;
 retry_nolseg:
 	/* Retry getting layout segment if lower layer returned -EAGAIN */
@@ -1156,9 +1201,13 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			return;
 		}
 	}
-	/* If no lseg, fall back to write through mds */
-	if (pgio->pg_lseg == NULL)
-		goto out_mds;
+	if (!pgio->pg_lseg) {
+		if (pgio->pg_allow_mds ||
+		    !ff_layout_inode_no_fallback_to_mds(pgio->pg_inode, IOMODE_RW))
+			goto out_mds;
+		ff_layout_pg_refuse_write(pgio, req);
+		return;
+	}
 
 	/* Use a direct mapping of ds_idx to pgio mirror_idx */
 	if (pgio->pg_mirror_count != FF_LAYOUT_MIRROR_COUNT(pgio->pg_lseg))
@@ -1212,10 +1261,6 @@ static unsigned int
 ff_layout_pg_get_mirror_count_write(struct nfs_pageio_descriptor *pgio,
 				    struct nfs_page *req)
 {
-	struct inode *inode = pgio->pg_inode;
-	struct pnfs_layout_hdr *lo;
-	bool no_fallback;
-
 	if (!pgio->pg_lseg) {
 		pgio->pg_lseg =
 			pnfs_update_layout(pgio->pg_inode, nfs_req_openctx(req),
@@ -1229,26 +1274,20 @@ ff_layout_pg_get_mirror_count_write(struct nfs_pageio_descriptor *pgio,
 	}
 	if (pgio->pg_lseg)
 		return FF_LAYOUT_MIRROR_COUNT(pgio->pg_lseg);
-
-	trace_pnfs_mds_fallback_pg_get_mirror_count(pgio->pg_inode,
-			0, NFS4_MAX_UINT64, IOMODE_RW,
-			NFS_I(pgio->pg_inode)->layout,
-			pgio->pg_lseg);
-
-	/* No lseg pins the layout hdr, and it is detached under i_lock */
-	spin_lock(&inode->i_lock);
-	lo = NFS_I(inode)->layout;
-	no_fallback = lo && ff_layout_hdr_no_fallback_to_mds(lo);
-	spin_unlock(&inode->i_lock);
-	if (!pgio->pg_allow_mds && no_fallback) {
-		/*
-		 * FF_FLAGS_NO_IO_THRU_MDS: no current lseg but the server's
-		 * policy forbids MDS fallback.  Surface -EAGAIN so writeback
-		 * retries rather than silently issuing the WRITE via MDS.
-		 */
-		pgio->pg_error = -EAGAIN;
+	if (!pgio->pg_allow_mds &&
+	    ff_layout_inode_no_fallback_to_mds(pgio->pg_inode, IOMODE_RW)) {
+		ff_layout_pg_refuse_write(pgio, req);
 		goto out;
 	}
+
+	if (trace_pnfs_mds_fallback_pg_get_mirror_count_enabled()) {
+		spin_lock(&pgio->pg_inode->i_lock);
+		trace_pnfs_mds_fallback_pg_get_mirror_count(pgio->pg_inode,
+				0, NFS4_MAX_UINT64, IOMODE_RW,
+				NFS_I(pgio->pg_inode)->layout,
+				pgio->pg_lseg);
+		spin_unlock(&pgio->pg_inode->i_lock);
+	}
 	/* no lseg means that pnfs is not in use, so no mirroring here */
 	nfs_pageio_reset_write_mds(pgio);
 out:
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 8f1361397f8f..831f0e80206a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -1036,6 +1036,7 @@ struct nfs_direct_req {
 	struct nfs_mds_commit_info mds_cinfo;	/* Storage for cinfo */
 	struct pnfs_ds_commit_info ds_cinfo;	/* Storage for cinfo */
 	struct delayed_work	work;
+	unsigned long		work_delay;	/* jiffies */
 	int			flags;
 	/* for write */
 #define NFS_ODIRECT_DO_COMMIT		(1)	/* an unstable reply was received */
diff --git a/fs/nfs/nfs4trace.c b/fs/nfs/nfs4trace.c
index 3fdc013f56d8..93a84f546de8 100644
--- a/fs/nfs/nfs4trace.c
+++ b/fs/nfs/nfs4trace.c
@@ -25,6 +25,7 @@ EXPORT_TRACEPOINT_SYMBOL_GPL(pnfs_mds_fallback_read_done);
 EXPORT_TRACEPOINT_SYMBOL_GPL(pnfs_mds_fallback_write_done);
 EXPORT_TRACEPOINT_SYMBOL_GPL(pnfs_mds_fallback_read_pagelist);
 EXPORT_TRACEPOINT_SYMBOL_GPL(pnfs_mds_fallback_write_pagelist);
+EXPORT_TRACEPOINT_SYMBOL_GPL(pnfs_mds_fallback_write_refused);
 EXPORT_TRACEPOINT_SYMBOL_GPL(pnfs_ds_connect);
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(ff_layout_read_error);
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index b5c89eeef2bc..94ed6b833a28 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -2115,6 +2115,7 @@ DEFINE_PNFS_LAYOUT_EVENT(pnfs_mds_fallback_read_done);
 DEFINE_PNFS_LAYOUT_EVENT(pnfs_mds_fallback_write_done);
 DEFINE_PNFS_LAYOUT_EVENT(pnfs_mds_fallback_read_pagelist);
 DEFINE_PNFS_LAYOUT_EVENT(pnfs_mds_fallback_write_pagelist);
+DEFINE_PNFS_LAYOUT_EVENT(pnfs_mds_fallback_write_refused);
 
 DECLARE_EVENT_CLASS(nfs4_deviceid_event,
 		TP_PROTO(
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index aa6d7b658d79..9a8731de6f5b 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -872,6 +872,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 {
 	desc->pg_moreio = 0;
 	desc->pg_allow_mds = 0;
+	desc->pg_nolayout = 0;
 	desc->pg_inode = inode;
 	desc->pg_ops = pg_ops;
 	desc->pg_completion_ops = compl_ops;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0b2b262b0dde..fbb7df3320de 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -693,6 +693,17 @@ int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 		nfs_pageio_complete(&pgio);
 		if (err == -EAGAIN && mntflags & NFS_MOUNT_SOFTERR)
 			break;
+		if (err == -EAGAIN && pgio.pg_nolayout) {
+			if (wbc->sync_mode != WB_SYNC_ALL) {
+				err = 0;
+				break;
+			}
+			if (schedule_timeout_killable(HZ) &&
+			    fatal_signal_pending(current)) {
+				err = -ERESTARTSYS;
+				break;
+			}
+		}
 	} while (err < 0 && !nfs_error_is_fatal(err));
 	nfs_io_completion_put(ioc);
 
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index d79bea9d4f90..10b45434c335 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -121,6 +121,7 @@ struct nfs_pageio_descriptor {
 	unsigned short		pg_maxretrans;
 	unsigned char		pg_moreio : 1;
 	unsigned char		pg_allow_mds : 1;	/* MDS if no layout */
+	unsigned char		pg_nolayout : 1;	/* refused, no layout */
 };
 
 /* arbitrarily selected limit to number of mirrors */
-- 
2.53.0

