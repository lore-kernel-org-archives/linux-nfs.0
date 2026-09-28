Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB16E4E80BA
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 15:54:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790610880; cv=none; b=bLDadSvuaEJQwfh2tquLl9WILmyhyFQGpViE/fmcHMhPRdTdwGtV5z9xjKgupFazM1UrH7LcCBla3d/2bmexGJOmf9jfo/Q9BdaBDbFc/1AshngXbBemi5ZYT4syTlmrxjEY2JEkhKFPr35p90mhHoAW+3aUBdlpu0IZTExvEfs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790610880; c=relaxed/simple;
	bh=6f1VY69IIeJcR3dSI6GicUrWzqKnTl4Yl3jhEpl6QVc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=poXuf9xlsOgBHS0D8sUtCZEN6hDN7EGR1fp4+Gtu/RZaA/knY8UOQ9SOUBK+bo+Fz/tDTh/j1pvSgHNaJX3H+vEhECuxZKUQ0K4hGkUQvCErWcurwi5QDkrtSPJsKZWDA/NhhDT0bo0LftYEIAz5b/84dq8b9enw/bRm3W9LzlE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZCi425mb; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZCi425mb"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 369891F00893;
	Mon, 28 Sep 2026 15:54:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790610875;
	bh=9UMwFO21kSWBsgXA/tcKPljCXIkZ2E+AD+/HL5Cz35g=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ZCi425mb/iEfu31qtm/8K0ckolVvK/nXePAR4HOMH3zifJmfOSD+bnbvWrYpVRBW0
	 K++XZrhhmH9jHh/UukU42tV1KfbXo/ZwsIXwzZKaJ7938ulgVu0IBEMG85LDV+9s8q
	 28GjsQyJEf6RnBcjwYPzeRHV4Q9nF06l5HSAClhyodHAC5kH6qcAtNj5VV2Iv2lVoy
	 Q6yeruceL+9Vjsf0iyKhBwlNlMLxBlMy7B0f2j0tMVdOBV8iOcIAVV7W8aHoQ8LLrT
	 CMtz/kp7kvzESX6LRJgLQL3Zhpm3G+61Eyp7RNu12N4yrqrdNtCF35/pN+9+ZXr8x1
	 yi8AlirdUVKzg==
From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/6] NFS/localio: report the stability a DIO WRITE actually has
Date: Mon, 28 Sep 2026 11:54:27 -0400
Message-ID: <20260928155430.95985-4-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260928155430.95985-1-snitzer@kernel.org>
References: <20260928155430.95985-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Since commit d32ddfeb5593 ("nfs/localio: Ensure DIO WRITE's IO on
stable storage upon completion") a DIO WRITE issued through LOCALIO
is persisted before it completes: nfs_local_iters_init() sets
IOCB_DSYNC|IOCB_SYNC on it despite whatever the caller asked for, so
that the buffered head and tail and the O_DIRECT middle of a
misaligned write cannot complete out of order.  The reply still
reported the stability that was asked for, so an UNSTABLE write came
back UNSTABLE, the client kept its pages on the commit list, and the
COMMIT that followed ran an fsync for data that is already on stable
storage.

Report the stability the kiocb actually carries instead: FILE_SYNC
when IOCB_SYNC is set, DATA_SYNC when only IOCB_DSYNC is.  A write
told FILE_SYNC has no reason to COMMIT and sends none.  Buffered
writes, and any write that asked for at least what it got, are
unchanged.

Fixes: d32ddfeb5593 ("nfs/localio: Ensure DIO WRITE's IO on stable storage upon completion")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-fable-5-1
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfs/localio.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/localio.c b/fs/nfs/localio.c
index 9fcae2391b726..db7aed7254380 100644
--- a/fs/nfs/localio.c
+++ b/fs/nfs/localio.c
@@ -936,6 +936,7 @@ static void nfs_local_do_write(struct nfs_local_kiocb *iocb,
 			       const struct rpc_call_ops *call_ops)
 {
 	struct nfs_pgio_header *hdr = iocb->hdr;
+	enum nfs3_stable_how committed = hdr->args.stable;
 
 	dprintk("%s: vfs_write count=%u pos=%llu %s\n",
 		__func__, hdr->args.count, hdr->args.offset,
@@ -954,9 +955,20 @@ static void nfs_local_do_write(struct nfs_local_kiocb *iocb,
 		iocb->kiocb.ki_flags |= IOCB_DSYNC|IOCB_SYNC;
 	}
 
+	/*
+	 * Report the stability the write will actually have.  A DIO WRITE
+	 * is persisted before it completes whatever was asked for, see
+	 * nfs_local_iters_init(), and a caller told so has no reason to
+	 * COMMIT data that is already on stable storage.
+	 */
+	if (iocb->kiocb.ki_flags & IOCB_SYNC)
+		committed = NFS_FILE_SYNC;
+	else if (iocb->kiocb.ki_flags & IOCB_DSYNC)
+		committed = NFS_DATA_SYNC;
+
 	nfs_local_pgio_init(hdr, call_ops);
 
-	nfs_set_local_verifier(hdr->inode, hdr->res.verf, hdr->args.stable);
+	nfs_set_local_verifier(hdr->inode, hdr->res.verf, committed);
 
 	INIT_WORK(&iocb->work, nfs_local_call_write);
 	if (nfs_local_defer_io())
-- 
2.44.0

