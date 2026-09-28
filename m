Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 650284E0202
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 15:54:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790610875; cv=none; b=VoRRW/xhEIuB7Dr+jPZvmOSYXYMaw+7uOQ5pw9Yj4DT9lBLjJ4KVEa5JBYDQbbx70VYP7X0bz5L3aFCkeQSCblpqMgOjOZ7aPz9RbZLo0F8gg+aJVVi4R9vET0LUopNZ5XQ9UQvs8aIZz2688WNFT0DPHewMm+I9w2Z+3atK7tE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790610875; c=relaxed/simple;
	bh=ych2IJ45GPW1MNOnQoGotA9jRKBCmulAbxB52Lc8+kw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=q86leNvClSNEXSWSkbdrS0bJS9ZS7pu5qmeSJQELx+tS4PnFL3uxXQVCPqtBuOZpECZ4xuZaPXRVAlVY1mK5f5Yj3vZcitgc+Ge40y6jwA0nEf4zyRfsjeepC3r6ILnnjtxfTAUPSxyWt1pAg3GJEVoq91fpWNYiPLaIu+f8LI0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DKYb71Ub; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DKYb71Ub"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ED6351F000FF;
	Mon, 28 Sep 2026 15:54:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790610874;
	bh=yqICnuwyD/v25b6NLF/Xi7F9CtA4prIGQPANm0tKsa8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=DKYb71UbFmZK4bdr86P+0eiVo96Tp/SgT04UNfI6n8bsmOJPw4pQWx1EXcoirVYfw
	 QPL7sU0Vip4YZ/Ok8YFywaZxikau2e0WsUH29pc2Yp8zkicMc4tsQahXiALwnmk0/C
	 VuBDrhAHWJWH4fNDt5Z/BXRfEqx1ozRhxDIxSDDTMnQbSXt2llRZKTkxq4XrrnrCuE
	 AiM4P6iGa3YXMM9Wuin9gnzlveme3ZQ4dCowOJVeQ74nt2o+DREB7uHLOvcPRgJ2Cb
	 c1mr1xzLX20UYbM01m456lMLpNS8B76h2EMLAg+Alwud0ujtlv6httFBiyq9JaCm7L
	 nDA0YNSI2JO6A==
From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/6] NFS/localio: detect a short read or write before the iterator has moved
Date: Mon, 28 Sep 2026 11:54:26 -0400
Message-ID: <20260928155430.95985-3-snitzer@kernel.org>
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

nfs_local_call_read() and nfs_local_call_write() issue a misaligned
DIO as up to three segments and must stop at the first short one, or
the next segment lands at the wrong file offset.  They test for that
by comparing the bytes transferred against iov_iter_count() of the
segment, read after read_iter() or write_iter() has advanced the
iterator, when the count is the residual rather than the request:

    before the call:  count == expected
    after the call:   count == expected - status

The test is therefore status < expected - status, and it fires only
when less than half of the segment was transferred.  A short I/O that
covers between 50% and 99% of a segment slips through: the loop moves
on with ki_pos advanced by the short amount, the next segment is
issued at the wrong offset, and the header's byte count is
over-reported to the caller.  A write that slips through also never
sets NFS_CONTEXT_WRITE_SYNC, which is what makes the writes that
follow a short one synchronous.

Take the segment's count before issuing it and compare against that.

This is the same defect that commit 250ec14932d5 ("nfsd: fix
partial-write detection in nfsd_direct_write") fixed in NFSD's version
of this loop.

Fixes: c817248fc831 ("nfs/localio: add proper O_DIRECT support for READ and WRITE")
Fixes: d0497dd27452 ("nfs/localio: backfill missing partial read support for misaligned DIO")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-fable-5-1
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfs/localio.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/localio.c b/fs/nfs/localio.c
index 63c38dea50cce..9fcae2391b726 100644
--- a/fs/nfs/localio.c
+++ b/fs/nfs/localio.c
@@ -674,6 +674,8 @@ static void nfs_local_call_read(struct work_struct *work)
 
 	n_iters = atomic_read(&iocb->n_iters);
 	for (int i = 0; i < n_iters ; i++) {
+		size_t expected;
+
 		if (iocb->iter_is_dio_aligned[i]) {
 			iocb->kiocb.ki_flags |= IOCB_DIRECT;
 			/* Only use AIO completion if DIO-aligned segment is last */
@@ -684,6 +686,8 @@ static void nfs_local_call_read(struct work_struct *work)
 		} else
 			iocb->kiocb.ki_flags &= ~IOCB_DIRECT;
 
+		/* read_iter() advances the iterator: measure it beforehand */
+		expected = iov_iter_count(&iocb->iters[i]);
 		scoped_with_creds(filp->f_cred)
 			status = filp->f_op->read_iter(&iocb->kiocb, &iocb->iters[i]);
 
@@ -691,7 +695,7 @@ static void nfs_local_call_read(struct work_struct *work)
 			continue;
 		/* Break on completion, errors, or short reads */
 		if (nfs_local_pgio_done(iocb, status) || status < 0 ||
-		    (size_t)status < iov_iter_count(&iocb->iters[i])) {
+		    (size_t)status < expected) {
 			nfs_local_read_iocb_done(iocb);
 			break;
 		}
@@ -890,7 +894,7 @@ static void nfs_local_call_write(struct work_struct *work)
 	file_start_write(filp);
 	n_iters = atomic_read(&iocb->n_iters);
 	for (int i = 0; i < n_iters ; i++) {
-		size_t icount;
+		size_t expected;
 
 		if (iocb->iter_is_dio_aligned[i]) {
 			iocb->kiocb.ki_flags |= IOCB_DIRECT;
@@ -902,16 +906,17 @@ static void nfs_local_call_write(struct work_struct *work)
 		} else
 			iocb->kiocb.ki_flags &= ~IOCB_DIRECT;
 
+		/* write_iter() advances the iterator: measure it beforehand */
+		expected = iov_iter_count(&iocb->iters[i]);
 		scoped_with_creds(filp->f_cred)
 			status = filp->f_op->write_iter(&iocb->kiocb, &iocb->iters[i]);
 
 		if (status == -EIOCBQUEUED)
 			continue;
 		/* Break on completion, errors, or short writes */
-		icount = iov_iter_count(&iocb->iters[i]);
 		if (nfs_local_pgio_done(iocb, status) || status < 0 ||
-		    (size_t)status < icount) {
-			if ((size_t)status < icount) {
+		    (size_t)status < expected) {
+			if ((size_t)status < expected) {
 				struct nfs_lock_context *ctx =
 					iocb->hdr->req->wb_lock_context;
 
-- 
2.44.0

