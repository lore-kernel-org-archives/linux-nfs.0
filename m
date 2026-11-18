Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.167.170
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795027020;
	b=TdlUUXBPV2GHoS+R1T2akqWzdgdZD/s9RRyGunUtwGdwTzcDKwQVjEZOD0J78DEZLluD
	 5hUKFxLSobhsBnKh75dMmmHhGznu18YVezPgVelINTkcvlq3EzVndhzmcom/6Vg5INggj
	 L/E3VIUVYeC00pbB5TePXDPiZl4qKKjA1kNRW+x6OqiY3wy8bhkkQCz8tguj4di5+11qT
	 GiMvKmyH9PYmkov2sgXVihbLOqaEMUbvm3FEBqRIAR2rqKwA8pcHS8Ug1RIM27YGfpHdL
	 zY+q9QWiFaeS+jZy1HGhyv91aX4Wis8SyF5ziL+RV33Bx/iCCCYmXQP+W7wqa9dYNQw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795027020;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=62Bn08gFIsQ2FGNQtz4CyNdvw8D+97guL+ujZGi3K88=;
	b=TSkacIjCBrw5WFty34JbJkQXEvXfJ6CXhSLz1GZMIMUE8theowjQIs1CBOzy7uD1wvV4
	 zSF5gOwsRtNG48x8nBVaebz/C5OpEwMUXduFOJsaV0MDgO0+zb0RUaO5XQ2zBD6ChaLTp
	 weLGLqSjfLxytME54ben3ObddvMbC3FmlfTUJ6MBmdeBooLrLoUesh8cMTZYmLiW+iiIU
	 qWVObLj5yPI2sba2hxzX28HOMa/u3y2uEOb7ZuLEEXksu8OeeoIGXVOf9CPkhjM5TtX9w
	 vu3S2NjCaAPadBOQkH6pTCCIWx3MCSBopiXhf3VuT+byVxkL4SaW+3ZDqCW1BNcfLGg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=bFjhoeuy;
	arc=none smtp.remote-ip=209.85.167.170
Received: from mail-oi1-f170.google.com (mail-oi1-f170.google.com [209.85.167.170])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 18779606A331
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 18:36:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 18779606A331
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=bFjhoeuy
Received: by mail-oi1-f170.google.com with SMTP id 5614622812f47-4a451915d8aso720745b6e.2
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 10:36:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795027019; x=1795631819; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=62Bn08gFIsQ2FGNQtz4CyNdvw8D+97guL+ujZGi3K88=;
        b=bFjhoeuyL2FA4+C63BUWA6A8WQ+OvURGMpR+qr9Uenz9vgcorOf0WrSUmdFnQ8eVxR
         IagEfRy1YrvGn4p5n4Oip/I/+anYpfR67PRvr+Zfzs/rYs4LgQHXXyQz6RdK2q7p7phM
         /ZmP+5Ujla6rVIVlxvivyG1Vd3cI1ysMibA9gJjBsu33891tVC5QasHgo7BqeiH97Fd1
         hNCn8plULudKdK6t7eaewHdcG3EafcRr0LfoCK+cbU2f6Fx+xz2upvEdVKn4Dk66/7dZ
         x3Cu4H1qbNm99YpvzokoIiq4RMNM+4RTOi/CFwGkRmcXkAtZYpCgl9Lhq7hMvPrEuUYI
         76RA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795027019; x=1795631819;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=62Bn08gFIsQ2FGNQtz4CyNdvw8D+97guL+ujZGi3K88=;
        b=vo49mlAf5fcA/o8K9diubdZn7lyHptGtJ0qjqHmg3vHtsKqhFYSunvfmFMIA3fX5PZ
         jRFapjlRI/VUCE6rXqK/jutVYzUupQAYvDrlsTxufiLezKOKfXt0OjH8QDS8oCgpDzgd
         IO2E80LUXVb0ty3xZsw3sfNa8gfv7cQ3CKSQr5DkjvkCdo6kaTA9WdxruVVWFR9NGWry
         NQ8z0Xtqq9G4Llh4WBLMIrI6If4xcgdup90Sg31Y5cpFtIGBO3syCvDVGZeCm3flKGhh
         VP0mtEzvCQsgaEPhT8o7H0VHYDRTRG2CVANgG0sGSD+fZwzj4il5s8ootnfGlMTjKU23
         p/OA==
X-Gm-Message-State: APuU4Z+ArpIrlQODACWejTNnwwTGqla3SZ7rI7orWFL+Uxsy1x24mFTQ
	e3T+CScUI4IJxvJnGC8NCt9KDKBHM4HmLUx5WcgusOMeTWVX2+Cb5wIXfSz1Clr0ShY=
X-Gm-Gg: AYBFou0Kym2ghZS9OSBILRNK9B/cX/xygU2hGdafwz1p+23sOhU8KGs4vBlP9b7yjcC
	pUSXQTmKucmdB0bSWEehLhach07KcZDJ48D0sFNlPOCi9s81sMTcEP9FAPQabSfxChqZMVmn+qt
	BWRQwW+TKt9KkErD+BAhK8LGiHHw7ZOa+MnhRksLzwgYKEHuA8m4pLqWWZK3DeG33JcrWoRcMZZ
	3hxAnoAWzxvq6YgzG89fGrubArkPPIEFiyaXgI5USwUZiLE/QT7bVuUAQ9gtMyVO3wTwUxjWpN0
	EAGLP69R5wmGZZ/vShTLyx+tw5Jh3dvliD5f76RANy5lAMqDUaVuMgCsw+ucb+2bRyEiEWKzuz9
	aRCrxqp1bB7qNPn+MnKGqkp9+MiSl4EpC69Wz66tu3VDp6uvNpxHPDMM4c0ej0IGfypmRclUNEP
	nO5gWdnl76ypwV4UFYrXtc1aT+EXOE9YYboyycBgKdljOPGy6upcwoS4n1ImiJPMXcYw2xFngXW
	le5QoNQiazuje4G4FYMG1mt455Q2BBPZWxkU6ApofzF+ALuVwBxb/OEwpFKRWuaiJ6mW+Nr0v3c
	r6gAbeNHQEKpiG53U0fIl0bAZqa86Le8I2PKlMZUbpuAYi9Wz6+po/ltxDwOXdjuTywpQK8tqZh
	9pQ==
X-Received: by 2002:a05:6808:1522:b0:55b:f88d:919f with SMTP id 5614622812f47-5773ff63ad2mr3848525b6e.53.1795027018748;
        Wed, 18 Nov 2026 10:36:58 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5777a8a6af8sm2341713b6e.9.2026.11.18.10.36.57
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 18 Nov 2026 10:36:58 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] pNFS/flexfiles: pace writes that have no layout and can't use the MDS
Date: Wed, 18 Nov 2026 13:36:52 -0500
Message-ID: <d416d82b18df69d694484ca649c43e8ef5066ef7.1795024981.git.bcodding@hammerspace.com>
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
the inode's NFS_INO_NO_IO_THRU_MDS bit, return -ERESTARTSYS to a killed
or exiting task, and honour io_maxretrans on soft mounts.  Mark a
refusal with a new pg_nolayout descriptor bit, and have nfs_writepages()
and nfs_direct_write_reschedule() wait a second before they resend,
after the pass that was refused has unlocked its folios and requests.
Writes marked pg_allow_mds by nfs_writepage_locked() still go through
the MDS.

The test is ff_layout_inode_no_fallback_to_mds(), which
ff_layout_pg_init_read() now uses too, and the refusal is
ff_layout_pg_refuse_write().  Emit the MDS-fallback tracepoint only
when the write does go through the MDS, and a new
pnfs_mds_fallback_write_refused tracepoint when it is refused.

Fixes: 1d62e659c0bf ("NFSv4/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS in pg_get_mirror_count_write")
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/direct.c                        |  2 +
 fs/nfs/flexfilelayout/flexfilelayout.c | 66 ++++++++++++++++++++------
 fs/nfs/nfs4trace.c                     |  1 +
 fs/nfs/nfs4trace.h                     |  1 +
 fs/nfs/pagelist.c                      |  1 +
 fs/nfs/write.c                         |  2 +
 include/linux/nfs_page.h               |  5 ++
 7 files changed, 64 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index a3c6e8f4ea06..e6a2c6436b44 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -626,6 +626,8 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 		}
 	}
 
+	if (desc.pg_error == -EAGAIN && desc.pg_nolayout)
+		ssleep(1);
 	if (put_dreq(dreq))
 		nfs_direct_write_complete(dreq);
 }
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 2b0a0af469fb..4eb12bbb7838 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -982,6 +982,45 @@ static bool ff_layout_pg_retry_wait(struct nfs_pageio_descriptor *pgio)
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
+	struct nfs_server *server = NFS_SERVER(pgio->pg_inode);
+
+	trace_pnfs_mds_fallback_write_refused(pgio->pg_inode, req_offset(req),
+					      req->wb_bytes, IOMODE_RW,
+					      NFS_I(pgio->pg_inode)->layout,
+					      NULL);
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
@@ -1108,7 +1147,7 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 	 * FF_FLAGS_NO_IO_THRU_MDS may itself be gone by now, which is why
 	 * this asks the inode and not the hdr.
 	 */
-	if (!nfs_no_io_thru_mds(pgio->pg_inode))
+	if (!ff_layout_inode_no_fallback_to_mds(pgio->pg_inode, IOMODE_READ))
 		goto out_mds;
 retry_nolseg:
 	/* Retry getting layout segment if lower layer returned -EAGAIN */
@@ -1156,9 +1195,13 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
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
@@ -1225,21 +1268,16 @@ ff_layout_pg_get_mirror_count_write(struct nfs_pageio_descriptor *pgio,
 	}
 	if (pgio->pg_lseg)
 		return FF_LAYOUT_MIRROR_COUNT(pgio->pg_lseg);
+	if (!pgio->pg_allow_mds &&
+	    ff_layout_inode_no_fallback_to_mds(pgio->pg_inode, IOMODE_RW)) {
+		ff_layout_pg_refuse_write(pgio, req);
+		goto out;
+	}
 
 	trace_pnfs_mds_fallback_pg_get_mirror_count(pgio->pg_inode,
 			0, NFS4_MAX_UINT64, IOMODE_RW,
 			NFS_I(pgio->pg_inode)->layout,
 			pgio->pg_lseg);
-	if (!pgio->pg_allow_mds && NFS_I(pgio->pg_inode)->layout &&
-	    ff_layout_hdr_no_fallback_to_mds(NFS_I(pgio->pg_inode)->layout)) {
-		/*
-		 * FF_FLAGS_NO_IO_THRU_MDS: no current lseg but the server's
-		 * policy forbids MDS fallback.  Surface -EAGAIN so writeback
-		 * retries rather than silently issuing the WRITE via MDS.
-		 */
-		pgio->pg_error = -EAGAIN;
-		goto out;
-	}
 	/* no lseg means that pnfs is not in use, so no mirroring here */
 	nfs_pageio_reset_write_mds(pgio);
 out:
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
index ec6b771b8dbe..005d4b795b80 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -693,6 +693,8 @@ int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 		nfs_pageio_complete(&pgio);
 		if (err == -EAGAIN && mntflags & NFS_MOUNT_SOFTERR)
 			break;
+		if (err == -EAGAIN && pgio.pg_nolayout)
+			ssleep(1);
 	} while (err < 0 && !nfs_error_is_fatal(err));
 	nfs_io_completion_put(ioc);
 
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index d64332afc374..f9b22b990de7 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -125,6 +125,11 @@ struct nfs_pageio_descriptor {
 	 * layout: the write goes through the MDS instead of waiting for one.
 	 */
 	unsigned char		pg_allow_mds : 1;
+	/*
+	 * Set by a layout driver that refused a write with -EAGAIN for lack
+	 * of a layout, so that a caller that resends waits first.
+	 */
+	unsigned char		pg_nolayout : 1;
 };
 
 /* arbitrarily selected limit to number of mirrors */
-- 
2.53.0

