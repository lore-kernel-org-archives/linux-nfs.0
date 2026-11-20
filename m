Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.49
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795191004;
	b=n6m640pwPT6WiuDlu+/OJ+SUL5nJ1FGtjujVqGVO2usWJKm35nf0NYubwhk+8L6d0P+/
	 dFnh8+6msBw3fYveGO9+xikdv9uzG9Im7yd/pVqyJefTTOtMB2S+EFX6ZYLdxv/A5rPjW
	 5h7oOgLWMSceW8oAApewxteB8jL0vZJgNP5gq1D5eJsUTKvydValVdyBu/YOTQRQfGVO7
	 WYLrbe0mK5wGFsCkt8xKLM3gc8ikKAW4jVKwLnKPKYE0UU7HJ45/+/HJYtdpSj7RprA67
	 gSNWLHEJZRoeqpXYI5tUZdGOkXMP1Hm9ALEMDSH8kVDbZlqjvv9fLLd5fzrAsSsAiUg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795191004;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=xhV84SEBdhaXFRVtrnLJdsBElK9JaFW3sc9tIo/J17c=;
	b=Zv8NKPRpn/g6Fkx+sYX8vG9GBW3rRC8aNnaUJ+Jv+IPZ6LnVlj3XkUJdpg9P/otYF7cB
	 9tMdV7bD50q2fwa7pJ5nZEp4ioPqVNiaZlvYgLtJP/7ECysrkp4feBob5otAO6sY2VkBt
	 wRbLSpPtW/CT2Y9j1qwffu7wqlKSOg0Ja0MN9OTxbIfWXbdUs36ufJcBtk0SREBtwOfPm
	 7pnO/XHc1c9FWzqtq29Za0TxhcANzHt9cIqEZ6zBuVVWF9dGWjw19jie0BWDb/Fjt+3Tk
	 lxjTzNNIBk0HIpQFPXMv8tV07dxLmLxyrlVI7qRZSDALv0O4XadAvJp9m7hSITjQMVg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=TJNwic+h;
	arc=none smtp.remote-ip=209.85.161.49
Received: from mail-oo1-f49.google.com (mail-oo1-f49.google.com [209.85.161.49])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 84A8C606A332
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 16:10:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 84A8C606A332
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=TJNwic+h
Received: by mail-oo1-f49.google.com with SMTP id 006d021491bc7-70b875f6f1fso858604eaf.2
        for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 08:10:03 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795191002; x=1795795802; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=xhV84SEBdhaXFRVtrnLJdsBElK9JaFW3sc9tIo/J17c=;
        b=TJNwic+heTaXL1dh0JQtSYTCq0DxQ80kNvx+cf1Kd0OwVtF+wfQvc+Z3LtfwIOOiNt
         CRlw/gj0WQZsDXQl75lAUd3d7uO/t7w30SVfjo+5FcGsrSU1Im3eeFAvYgfRmHthmKCF
         en4r96WVqrzqIl4AnyNxYVlP2aC9HfijwGeDvU8XpsHTN//bbIVztDZBjGmkx+5DXK3c
         jeW3CvwZjKqAJxBgQmCfrUdJe0fZtcmcZTF0oZFvleA88S6b/9Kp7XhNYuMN664BsrYp
         iEXFMYaA9oG5zSybo/GhiuqGYzXGcB5lXOYW6izLA4sPrdmzpzrkP+SyzRREvcNjUHJa
         2EBw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795191002; x=1795795802;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=xhV84SEBdhaXFRVtrnLJdsBElK9JaFW3sc9tIo/J17c=;
        b=ZmVyv39qePQhuOCUBg52j7ywBh2oVzfE/3Wb96BmulDvT1ShAhcj78bNysKtRE06mR
         1Mcm7qBRwIHMaptNcYskaqJ/ROlgJ2TRthwUae8DLSKoCqsBtYnOb1crwCLRheBjTBdz
         8lneuc8A04hY/mOWoTU0yuUpC2y+LlZqhpInUNqghFLRmiregylnF+eFCxLcYEE+rwMK
         /nzYbWBgaTFBF2P0Tm6KIX4Y5Tq8FIu9dTmR62BvJBGhO9rgYQfSQqCcIjwILGyPyyqn
         /7jTtf5ZXIPUQS9jWsZgdKX4+kzI3VwNRrES0FurlA4c9zkFdBstg59dAMN57H2NWLyR
         uRDA==
X-Gm-Message-State: APuU4Z+elQaMLATKy6ogLRyJ1YH7Ahq9usLPQ6YTeoCaVfboBF/YqgzR
	O2fA5A6vzgfcm755A1xE74kbU/dD7i9n16R7Qsyu6xlrZqgcYuMSS+nDjHHNQJmNZas5Z0cYnwy
	WV0Ox
X-Gm-Gg: AYBFou3Y4mIlEVPjr4go/uR0iF91uJQCqa5yU+Fsf7pTrCyXnQHhMm4lmjLue3qAt1T
	zfDSog+cxzf3MeC5819tu/3Ck9U6c7uiK39t4xw/ilE9EXGmbdlgTwcW7jKY0lqfJI3LGeTiAux
	e1sHeJi21P1IFSKRYLxkzdjGRTqlLzpjKj0TqtNJoKrNYLqeLLH5OlkSERwmrdUNyp5KtLDnI6S
	YerSntkVv8pJyPcjyeDtKE6UMxyw/8C1kTr02eov3mo1mobtWLyMNddFg43yGCyWBuhmzM07Ow7
	8S3vfFf0KXr1S4BFzdEdUIt4Hs9qmBkduEM3tKutP++YGTYR2LWPq+Nwv5eckFJuI09qDTY0YgP
	Vr/NhH6TbAfSdjExWkqYrDU/6xDSGlpuveSNgRWX72wqH2nDIWpoEIf1WtKOup0PEbxeuLQlJEU
	SlF3PLn9pbFqY+T649FwKETivFCBQo64kgiDxGgbCfRBacKtcY6GqEIbqyrBJdz9TARBL4qkbYp
	DuJEhYPNBdNTa25ySZqNGB3z5bObNDjXjIs77n1FbaqPoaLNguvqpDdbg0FFCAnoCbR7OIBegXP
	XBecdCK3SW9NRU7+iYwtkPuYkrnECakl22tHgI7FwV/+kfGMeA2p1wyHPoFIoEEM+K4JYc07q4p
	jygt5gBNHO3Bqdvtp8ruLZHSSpgs+wHw=
X-Received: by 2002:a05:6820:822:b0:71a:6171:83ca with SMTP id 006d021491bc7-71b3944f2a4mr3232284eaf.33.1795191002191;
        Fri, 20 Nov 2026 08:10:02 -0800 (PST)
Received: from bcodding.csb.hammerspace.com (196.sub-174-201-28.myvzw.com. [174.201.28.196])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-71b37ea8472sm2147928eaf.2.2026.11.20.08.10.01
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 20 Nov 2026 08:10:01 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 3/5] pNFS/flexfiles: pace writes that have no layout and can't use the MDS
Date: Fri, 20 Nov 2026 11:09:54 -0500
Message-ID: <ff344f9a50e23f4a1723792f83888811c137d58c.1795122900.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1795122899.git.bcodding@hammerspace.com>
References: <cover.1795122899.git.bcodding@hammerspace.com>
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
task sending the write is killed or exiting, and on soft mounts give up
once the next pass would exceed io_maxretrans.  Mark a refusal with a
new pg_nolayout descriptor bit.  After the pass that was refused has
unlocked its folios and requests, data-integrity nfs_writepages() waits
a second before it resends, and a fatal signal ends the wait.  Other
writeback stops there and leaves the refused folios dirty, instead of
waiting a second for each one.  The O_DIRECT path queues its reschedule
a second later instead of resending at once, both from
nfs_direct_write_schedule_iovec() and from
nfs_direct_write_reschedule().  That pass runs on nfsiod rather than in
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
 fs/nfs/direct.c                        |  7 +-
 fs/nfs/flexfilelayout/flexfilelayout.c | 91 ++++++++++++++++++--------
 fs/nfs/internal.h                      |  1 +
 fs/nfs/nfs4trace.c                     |  1 +
 fs/nfs/nfs4trace.h                     |  1 +
 fs/nfs/pagelist.c                      |  1 +
 fs/nfs/write.c                         | 11 ++++
 include/linux/nfs_page.h               |  1 +
 8 files changed, 87 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 9ef8031a68ad..2f355f7c8fc7 100644
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
@@ -928,6 +931,8 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 			nfs_init_cinfo_from_dreq(&cinfo, dreq);
 			spin_lock(&dreq->lock);
 			dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
+			if (desc.pg_nolayout)
+				dreq->work_delay = HZ;
 			spin_unlock(&dreq->lock);
 			nfs_unlock_request(req);
 			nfs_mark_request_commit(req, NULL, &cinfo, 0);
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 56527054d87b..ef8715de6474 100644
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
+	    io_maxretrans && req->wb_nio >= io_maxretrans) {
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

