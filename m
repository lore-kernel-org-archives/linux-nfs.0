Received: from mail-wm1-f98.google.com (mail-wm1-f98.google.com [209.85.128.98])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 535A04772B0
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:58:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.98
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786629521; cv=none; b=X5iw51VpacZvNvWIY1rUAbtwXV27AnM4ys7Q9MWHXXeq/BX1Xx1OeRx1cdAPrIiQhpx5hDLF4ItOv8Vk+fRK348+OViode0jThNbZVpwx/C1lgjptYHuFw38C4+60BI1wdt5v+v++B+bc2s4dPlSKelt136WPJ0ZlWZopB3bljM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786629521; c=relaxed/simple;
	bh=InMdX+pdiDloclCPV/zVlqIYNtiNdrfnmA7sVFiIrcI=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=e313u1Ul1l2UKe1Gn2klhIwJVv+SNFVmDiVGbFqqDPlbTGA9O9iA9SY5hYsa9tkZrrbz2EQ+P61OiiTDMJp476v5RHu0oZ+EpmBuYyniP/28+U6u1g2MhUprjolzjdmNoHDHfiqJsRK/Bl6afGrfNXqlVWpBH4Va/3Pi/R5bZrQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=purestorage.com; spf=pass smtp.mailfrom=purestorage.com; dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.b=SE2h3KT0; arc=none smtp.client-ip=209.85.128.98
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=purestorage.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=purestorage.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.b="SE2h3KT0"
Received: by mail-wm1-f98.google.com with SMTP id 5b1f17b1804b1-4953de5be0aso15556455e9.0
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 06:58:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=purestorage.com; s=google2022; t=1786629518; x=1787234318; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=1y55hehoVssabJRQyQs56fbqkSj+SkZHKxYRNj9+z/c=;
        b=SE2h3KT0c+mQiD2kFkBdK0wfk3IqXx83TCjYMmV+5emoz14Rg9AGj0diRBn/EVH77B
         GUFpNja0MJ9OO61O6JtxS1f+031i/qhtrGicMNMpaNchR7eUGK2GwMTEwM+Vnqz0sJee
         M3YvaJIQg1NLAxQPBYQaHdSQ6Bq5GPHOA/BUTzp1xpq+6M9eJ5UVOgzhYIHTGhFxBtnr
         oKMKfk5u09qhQ7YiCgBjYH+Oe+NEumq5t+6FL+DMTNex4itLvdXAAbIDzH8xR8Dr9ovD
         Gj58u4lfUKDRHDAmgnKZlAt3UVEEE4vQi87v8yf4Qwyn1sQWfEF3PzYhYuO74Qeqt3Ik
         2VWA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786629518; x=1787234318;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=1y55hehoVssabJRQyQs56fbqkSj+SkZHKxYRNj9+z/c=;
        b=eejq4LWaFLcfIYNiGDkoVTMmrIe6tCKHS7tIbpnoZiWHsEHPmzZDIrSGs+0WfpP8/U
         NGnfLHDg+HPcKMrwX9VbHDN8wSe4xkdvuM36aAkPvOeRfqIfRlZq3ta96RHWo2/9B6ko
         ea+JlAWX/68zj6WBfyYZZtD/wEUwwIpSC+ARyY3WvtbwqccR9MNY4KYhWp+4wIl8pquk
         2i2TUZH+P2y5V6weyHrp5ChSGYXHE4BVOOEZSDRzldtBNrhaX9KIWG5PVRu8+ba/2r2r
         OvzMolSS9qQ9q5sPvpRpXh+zXPx/yb5+iWyj6dpZBqSRDBuXa3JEgKfXwvfpjXgwVeFD
         jPRg==
X-Gm-Message-State: AOJu0YwDuZDHPuHlGNOWCVnxH7RZpGToMsgLt6Zok4sI1asIEVfWB93W
	bB/DB/x0/E1eAdlEQj3IJZM3mOswPBr5fanjWR5IyIfOUngVL+Ph3NEhRgBAiwGtMBb/hbHMNxc
	yMyiQrT60+CgO6n0oFFCyN6fDCN5GUjZ2HRy3jQz27nzu1DrQH7WD
X-Gm-Gg: AR+sD13PyqqHHyFmWzBNTz1ZMBqUQrPo32Ltr6FmqUdIkXdJqDvizIOvvaKkRfz9Pxz
	UzjNstDD4tzkPWOLyJy+URFdpFo6ROBWJHJgOJv2aqBwIaM1UQ3Ul6eSv8rQ/Opm/QcUltokVnP
	4KmiDNAijHUhD1Mm0lkzLcDwvhUAFAMdWLNGylcX+WuaDQRbmvp2pNmLRXKi/w45eZ5yRT+xUAa
	7gFdyjDDLzCn9x+aaTdNhTGlirKriHvs+biFJw1Y233rnbJlnGCqv2Ligdp/5T4+pYgkUQ0iUoY
	pa4NIB9qNqxKyyoV4082c7xmcDlf561A9t3EWFdTkFRtWkvKsFBQ+Y6p5hbb1haZ58/HRI/Mn13
	S2as0riAXIfBDGgVJbs37NUq1UQpA
X-Received: by 2002:a05:600c:1385:b0:495:5fdf:2075 with SMTP id 5b1f17b1804b1-49982109cc1mr75225985e9.0.1786629517600;
        Thu, 13 Aug 2026 06:58:37 -0700 (PDT)
Received: from c14-smtp-2023.dev.purestorage.com ([2620:125:9008:8012:36:131:5:0])
        by smtp-relay.gmail.com with ESMTPS id 5b1f17b1804b1-49981b16dd0sm9042585e9.7.2026.08.13.06.58.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 06:58:37 -0700 (PDT)
X-Relaying-Domain: purestorage.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 3A43634029C;
	Thu, 13 Aug 2026 06:58:36 -0700 (PDT)
From: tmenninger@purestorage.com
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Tim Menninger <tmenninger@purestorage.com>,
	stable@vger.kernel.org
Subject: [PATCH] pNFS: Check lseg validity before marking a layout for return
Date: Thu, 13 Aug 2026 13:58:34 +0000
Message-Id: <20260813135834.22278-1-tmenninger@purestorage.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Tim Menninger <tmenninger@purestorage.com>

pnfs_error_mark_layout_for_return() receives the lseg associated with
the failed I/O but previously used only its I/O mode, operating on the
inode's current layout header regardless of whether the lseg itself was
still valid.

A layout stateid can be invalidated while RPCs still hold references to
its lsegs. pnfs_mark_layout_stateid_invalid() clears NFS_LSEG_VALID on
those lsegs through pnfs_clear_lseg_state(). A subsequent LAYOUTGET can
install a replacement stateid in the same pnfs_layout_hdr. If an RPC
using one of the old lsegs later reports an error, the current code can
therefore mark the replacement layout for return.

Once NFS_LSEG_VALID has been cleared, the lseg is no longer eligible for
selection for new I/O and must not initiate another error-driven return
of the inode's current layout. Fold pnfs_mark_layout_for_return() into
pnfs_error_mark_layout_for_return() and check pnfs_is_valid_lseg()
alongside pnfs_layout_is_valid() before setting return info, so a stale
lseg cannot drive an error return of the current layout.

This was reproduced by restarting a FlexFiles data server during a
high-throughput read workload. Stale lsegs repeatedly caused the
replacement layout to be marked for return, triggering I/O cancellation,
RPC/RDMA transport reconnects, and sustained contention on
inode->i_lock. The client did not recover on its own and consumed about
94 CPU cores on a 96-CPU system. With this change, I/O recovered within
about 20 seconds and recovery load peaked at about 15 CPU cores.

Cc: stable@vger.kernel.org
Signed-off-by: Tim Menninger <tmenninger@purestorage.com>
---
 fs/nfs/pnfs.c | 28 ++++++++++------------------
 1 file changed, 10 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7715e2bd5871..9f32dd7c4c63 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2708,26 +2708,30 @@ pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 	return -ENOENT;
 }
 
-static void
-pnfs_mark_layout_for_return(struct inode *inode,
-			    const struct pnfs_layout_range *range)
+void pnfs_error_mark_layout_for_return(struct inode *inode,
+				       struct pnfs_layout_segment *lseg)
 {
 	struct pnfs_layout_hdr *lo;
 	bool return_now = false;
+	struct pnfs_layout_range range = {
+		.iomode = lseg->pls_range.iomode,
+		.offset = 0,
+		.length = NFS4_MAX_UINT64,
+	};
 
 	spin_lock(&inode->i_lock);
 	lo = NFS_I(inode)->layout;
-	if (!pnfs_layout_is_valid(lo)) {
+	if (!pnfs_layout_is_valid(lo) || !pnfs_is_valid_lseg(lseg)) {
 		spin_unlock(&inode->i_lock);
 		return;
 	}
-	pnfs_set_plh_return_info(lo, range->iomode, 0);
+	pnfs_set_plh_return_info(lo, range.iomode, 0);
 	/*
 	 * mark all matching lsegs so that we are sure to have no live
 	 * segments at hand when sending layoutreturn. See pnfs_put_lseg()
 	 * for how it works.
 	 */
-	if (pnfs_mark_matching_lsegs_return(lo, &lo->plh_return_segs, range, 0) != -EBUSY) {
+	if (pnfs_mark_matching_lsegs_return(lo, &lo->plh_return_segs, &range, 0) != -EBUSY) {
 		const struct cred *cred;
 		nfs4_stateid stateid;
 		enum pnfs_iomode iomode;
@@ -2742,18 +2746,6 @@ pnfs_mark_layout_for_return(struct inode *inode,
 		nfs_commit_inode(inode, 0);
 	}
 }
-
-void pnfs_error_mark_layout_for_return(struct inode *inode,
-				       struct pnfs_layout_segment *lseg)
-{
-	struct pnfs_layout_range range = {
-		.iomode = lseg->pls_range.iomode,
-		.offset = 0,
-		.length = NFS4_MAX_UINT64,
-	};
-
-	pnfs_mark_layout_for_return(inode, &range);
-}
 EXPORT_SYMBOL_GPL(pnfs_error_mark_layout_for_return);
 
 static bool
-- 
2.34.1

