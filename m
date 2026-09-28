Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 74CB64E9C05
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 15:54:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790610882; cv=none; b=pEMrq7Ku3nqlE0qWS6cmlnJhvgBKVXbM2miV3wrIrLAFfRPOGEiz86APAgaaIdSlT9De3BrvKMJ5qsf6xRa3F6arzKzeOnCaEqqM6K54dNmdqwuEPsQ6XbQwGOTMV+wd+UdVRU1c9UAbbM3wbJCbP8MjITIrf3dxCn9sfNz2JJU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790610882; c=relaxed/simple;
	bh=bqVD1ysbMkIJCzotdaPp8u9lM2pMb4V3BG6EY/y9HDs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=IKTFRh+rrAYDQVLvUImrudQf4NIQLsGL4+osUvDBfGQlydxp/OvuJqPNY+9ApsY0hYwIbBb8qhjtswL7Ip9lslpseqDznqtrT1Jr/Gv1W18KiVA85KSOZTEeHMm1Hz6yH/svmQt7x/RwnixZCW28/PZteyraNaUDiWgDct2xk9s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NYykvw0G; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NYykvw0G"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EA9211F0089A;
	Mon, 28 Sep 2026 15:54:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790610879;
	bh=p/8EWXcdqIWPYpcyQpjNUcPTad+KPRqDTsgdg8t22p8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=NYykvw0G3GJVKT0ZZxEbseUdQPqso/LazikjgtDxI9oZaqWnE2s0TYj4En0cB2b0k
	 W2+TIMRHM/qz5OWc7imJSmFPPdrodRbcH2+ibd4UTiXnybDZWL+ltlHHix57G5UNQ5
	 sfxNapPc+ysAayzWMV5D7RBJoLT+ixcu85y4WpTYLdlU5lRrTnwowLS3yziRgv4F+p
	 j/7OcKUppgQmJ9AXHOk0JI4yKwRsICPRueASl5BhCiWg23kFVCgVxoqOSeOB25frF4
	 rzMnKOFYaXeFc3nXuBqftL7pe15RV9rOyCGkq4eUg1Bc6hDBqLmL0z7J9NQOllgnMj
	 yqfOc3o8Ikwxg==
From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 6/6] pNFS/flexfiles: don't reset to MDS for v4 error when previous layout forbid it
Date: Mon, 28 Sep 2026 11:54:30 -0400
Message-ID: <20260928155430.95985-7-snitzer@kernel.org>
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

ff_layout_async_handle_error_v4() ends in -NFS4ERR_RESET_TO_MDS, which
makes ff_layout_read_release() / ff_layout_write_release() call
ff_layout_reset_read() or ff_layout_reset_write(hdr, false), and those
call pnfs_read_done_resend_to_mds() / pnfs_write_done_resend_to_mds().
Those build a page I/O descriptor with force_mds set, so the flexfiles
->pg_init() never runs and no layout is consulted anywhere on the way:
the READ or WRITE goes to the metadata server unconditionally.  For a
layout carrying FF_FLAGS_NO_IO_THRU_MDS that is exactly what the server
forbade.

The fall-through into reset: is already safe, because
ff_layout_avoid_mds_available_ds() returns true for a segment with the
flag and so answers -NFS4ERR_RESET_TO_PNFS first.  What is not safe is
the goto: the invalid-layout errors (NFS4ERR_PNFS_NO_LAYOUT, STALE,
BADHANDLE, ISDIR, FHEXPIRED, WRONG_TYPE) call pnfs_destroy_layout() and
jump straight to reset:, over that check.  That is the case where the
file had a perfectly good layout, something forced it to be given back,
and the client answers by writing to the MDS behind the server's back.

Test at reset: itself, so it covers the goto and any future one, and ask
the inode (NFS_INO_NO_IO_THRU_MDS): the callers that jump here have just
destroyed the layout hdr, so the hdr-level flag is no longer reachable,
while the inode-level one is set for the life of the in-core inode.

-NFS4ERR_RESET_TO_PNFS is the right answer rather than an error.  It is
what the fall-through already returns for the same flag, and the
resends it drives - ff_layout_resend_pnfs_read() and
ff_layout_reset_write(hdr, true) - re-enter the pgio path with force_mds
clear, so a fresh LAYOUTGET is taken, which is precisely what a
destroyed layout needs.  A LAYOUTGET that fails fatally makes
pnfs_update_layout() return an error, which ->pg_init() reports; a
non-fatal refusal (NFS4ERR_LAYOUTUNAVAILABLE, NFS4ERR_TOOSMALL) returns
no segment instead, and the client keeps retrying through pNFS rather
than falling back.

ff_layout_async_handle_error_v3() needs no such change: it returns only
-NFS4ERR_RESET_TO_PNFS or -EAGAIN.

Fixes: 260074cd8413 ("pNFS/flexfiles: Add support for FF_FLAGS_NO_IO_THRU_MDS")
Assisted-by: Claude:claude-opus-5[1m]
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 84d22f715653d..d4f2b57e9d5b2 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1423,6 +1423,23 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
 	if (ff_layout_avoid_mds_available_ds(lseg))
 		return -NFS4ERR_RESET_TO_PNFS;
 reset:
+	/*
+	 * FF_FLAGS_NO_IO_THRU_MDS: never resend through the MDS.  The
+	 * caller would do so with force_mds set (ff_layout_reset_read(),
+	 * ff_layout_reset_write(hdr, false) -> pnfs_*_done_resend_to_mds()),
+	 * which builds a descriptor out of the plain MDS page ops and so
+	 * consults no layout at all -- this is the last point at which the
+	 * policy can still be applied.  Retry through pNFS instead, which
+	 * takes a fresh LAYOUTGET; that is also the right answer for the
+	 * invalid-layout cases that jump here, since they have just called
+	 * pnfs_destroy_layout().  Having done so they can no longer ask the
+	 * layout hdr about the flag, hence the inode.
+	 */
+	if (nfs_no_io_thru_mds(inode)) {
+		dprintk("%s Retry through pNFS, no MDS fallback. Error %d\n",
+			__func__, task->tk_status);
+		return -NFS4ERR_RESET_TO_PNFS;
+	}
 	dprintk("%s Retry through MDS. Error %d\n", __func__,
 		task->tk_status);
 	return -NFS4ERR_RESET_TO_MDS;
-- 
2.44.0

