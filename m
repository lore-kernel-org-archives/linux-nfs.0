Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4CFF74E80D1
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 15:54:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790610874; cv=none; b=kKSZsGy0C7LjuN1iz1NUuk2W/xng9bo+TRL4jzi5sgQ0LTO3WhbDf5SYu3Ft0a1NqbX8dhurt7H9BfbWd2h+KHNcJG6Cxb5tSmva+AkaXFsBqyeYXY8fK8K3w+nA5tFZwn2glrBn0DSmiZeTd99kpxsGCMcsCorONjO645mlGhc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790610874; c=relaxed/simple;
	bh=W9jwswsoFDLcqvW/P+gHefiC9gSfWww9AOSdWfBl/Ao=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=TMx23wtMfuIGV7DObk/sTvBBr3w7ITODrjDZgxdDtWYld3zsBcSrVIFIpeA5EXZrvOHIY8ykE3BsEixdLSRTargh34OZPUZA0jyJAcwNLb5qA39ahvUWFXp2OHtq2a8RcYp8pYVWYvIu7xA9sq2N30j7ABTMz1EfnzbY+7akiV0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Fzhoh9hE; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Fzhoh9hE"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B30741F00893;
	Mon, 28 Sep 2026 15:54:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790610872;
	bh=3zMZgiL7mBZnfitotpMkcYmksrnG4g+oOecqFwADhUc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Fzhoh9hE2hJgsWWYZ5xz8od2O2v1N7s0+DwYTUVWWVCEgfktTJqTR1Wiv3ixTrtD+
	 gzCIhfkdM3gqWX3DAwdHKj0o0KLGAyQzW0D4gPd2Ey+Y0gj3J1zoWBteIL7z+l0bnm
	 77+0b4SucuvGv74CcqtfUQCJOPKKfgrC2OZZ4tZdz9s6mdTj7ALADSKpCVcgyuAiqa
	 hZZbx0mESEeQh6QAlunT0/7/XyW3BmCsldsQB4eHgUYTXOVxhdeCbaDXnTpCJ6lGbO
	 eK/JqhiTTQ6hDQRdPNV3ZcWeH/XaSAGGNmtyV1dJCQhBFem5BHjBktUtVYvBIiaX9D
	 9UnSzb1rooVmA==
From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/6] NFS/localio: fix nfs_local_dio_misaligned tracepoint
Date: Mon, 28 Sep 2026 11:54:25 -0400
Message-ID: <20260928155430.95985-2-snitzer@kernel.org>
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

The intended focus of nfs_local_iters_setup_dio()'s call to
trace_nfs_local_dio_misaligned() is on the middle segment being
misaligned, yet the @offset passed in was local_dio->start_len.
It would appear this was a cut-n-paste bug from the preceding
nfs_local_iter_setup() call that passes local_dio->start_len.

Fix this by passing the @offset as local_dio->middle_offset and
calculate the start segment's offset rather than assume.

Example traces, before this fix:

   python3-32744   [006] .l... 132946.352360:
   nfs_local_dio_write: fileid=00:33:1286 fhandle=0xf1f7c10b
   offset=1048759 count=1048576 mem_align=4 offset_align=512
   start=1048759+329 middle=1049088+1048064 end=2097152+183

   python3-32744   [006] .l... 132946.352360:
   nfs_local_dio_misaligned: fileid=00:33:1286 fhandle=0xf1f7c10b
   offset=329 count=1048064 mem_align=4 offset_align=512
   start=329+329 middle=1049088+1048064 end=2097152+183

After this fix:

   python3-32744   [006] .l... 132946.352360:
   nfs_local_dio_write: fileid=00:33:1286 fhandle=0xf1f7c10b
   offset=1048759 count=1048576 mem_align=4 offset_align=512
   start=1048759+329 middle=1049088+1048064 end=2097152+183

   python3-32744   [006] .l... 132946.352360:
   nfs_local_dio_misaligned: fileid=00:33:1286 fhandle=0xf1f7c10b
   offset=1049088 count=1048064 mem_align=4 offset_align=512
   start=1048759+329 middle=1049088+1048064 end=2097152+183

Fixes: 6a218b9c3183e ("nfs/localio: do not issue misaligned DIO out-of-order")
Cc: stable@vger.kernel.org
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfs/localio.c  | 2 +-
 fs/nfs/nfstrace.h | 5 ++++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/localio.c b/fs/nfs/localio.c
index f42b6112a6139..63c38dea50cce 100644
--- a/fs/nfs/localio.c
+++ b/fs/nfs/localio.c
@@ -446,7 +446,7 @@ nfs_local_iters_setup_dio(struct nfs_local_kiocb *iocb, int rw,
 
 	if (unlikely(!iocb->iter_is_dio_aligned[n_iters])) {
 		trace_nfs_local_dio_misaligned(iocb->hdr->inode,
-			local_dio->start_len, local_dio->middle_len, local_dio);
+			local_dio->middle_offset, local_dio->middle_len, local_dio);
 		return 0; /* no DIO-aligned IO possible */
 	}
 	iocb->end_iter_index = n_iters;
diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index b15c1732c8692..a32c76df72db5 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -1772,7 +1772,10 @@ DECLARE_EVENT_CLASS(nfs_local_dio_class,
 		__entry->count = count;
 		__entry->mem_align = local_dio->mem_align;
 		__entry->offset_align = local_dio->offset_align;
-		__entry->start = offset;
+		if (local_dio->start_len)
+			__entry->start = local_dio->middle_offset - local_dio->start_len;
+		else
+			__entry->start = 0;
 		__entry->start_len = local_dio->start_len;
 		__entry->middle = local_dio->middle_offset;
 		__entry->middle_len = local_dio->middle_len;
-- 
2.44.0

