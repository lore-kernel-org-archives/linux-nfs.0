Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4A1773E1231
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 23:33:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792107198; cv=none; b=PAy4lgcq83X83YgeKC3xkJFOBQmRMHyi3Qs/RXh/NeF1iGTuXD+Z9OEDIrQpwtjPl0iSs1MhN4Q1BSJvOaX6MGIECjSx3eTSXcx4WcelcZptn062trzG2j10nv3GQ+kuCF9DR1qDlvixRPiNC3RT/JnENS3DXxJzZMv0oiGy/ok=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792107198; c=relaxed/simple;
	bh=DVCnGzcTEFsYujEKSHQnUefjcNzj8YB3es06CqIBXfM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Yv/kgDuF8KkkgsGnOXfOc9W5K5oIIZPRKp83nuYRuA6UrVpxbI5M3jXmeNrCMwKTOEmH9U9RjRzPFHM4DeoyHib2UO52MZx/9MkWQgOrqJhJa2vrFOo9D9yY6SZcnj4CqtViOfTfeDODG2Zhbux4h6+SApKw6CNyayqQ5MuMbJQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MHTk+M3E; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MHTk+M3E"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D58361F000C5;
	Thu, 15 Oct 2026 23:33:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792107197;
	bh=/aAWxJL1CcUB2j7lD6lXLnALpckGsLDOXNnExtYI2O8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=MHTk+M3EVwUrKpBXxJvSHYX+M9wTAey7UijMzcDES+I5biYb3XkCPE/ZdzkkjTiOl
	 v64XRhs2xzTRNF8c98Tkt3iOkfRc4a1LKmKsj8F+6pD2QSs+/jTb8O0yJOL5WipwEo
	 j3oPFJ7UAeEmMcGEFr3/YGHE2U14LM9iJW+YJK/w2KcWob2P6nynSW1ZZWM6KY+JLS
	 NkZ73TpJSzlfe0vtMEU/P0AebahN6OvnRaf+VatOH4BpwpxdCp0Ce7HaGTLl+WgAK4
	 2EAYzXypzdiftroYv3iC11SWEQJ4HDF7khgXxxv7E6BejRzbLp+j0yZi1nvy5+N5q9
	 14BF9SkOL8TyQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <axboe@kernel.dk>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org
Subject: [PATCH v4 05/10] NFSD: do not use direct I/O for a READ smaller than its alignment
Date: Thu, 15 Oct 2026 19:33:04 -0400
Message-ID: <20261015233309.42999-6-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261015233309.42999-1-snitzer@kernel.org>
References: <20261015233309.42999-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd_direct_read() expands a misaligned READ out to DIO-aligned
boundaries: it reads from round_down(offset, dio_read_offset_align) to
round_up(offset + count, dio_read_offset_align) and returns only the
requested bytes from within that window.  When the READ is smaller than
the alignment, that window is always at least one full alignment unit,
and two when the READ straddles a boundary, so a few hundred bytes of
payload can cost a 4K or 64K device read.

Decline direct I/O for those.  A READ smaller than
dio_read_offset_align now falls through to the DONTCACHE path, which
issues DONTCACHE buffered I/O when the file system supports
FOP_DONTCACHE and normal buffered I/O otherwise.  This mirrors the
WRITE side, which already declines direct I/O for a WRITE smaller than
the larger of its offset and memory alignments.

Only dio_read_offset_align is consulted: nfsd_direct_read() lands the
data in whole rq_pages pages at offset zero, so dio_mem_align is always
satisfied and only the file offset and length can be misaligned.  The
threshold only bites when the file system advertises a large alignment;
where it reports 512 almost no READ is excluded.

Document it in the "Misaligned READ" section of nfsd-io-modes.rst.

Assisted-by: LLM
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 Documentation/filesystems/nfs/nfsd-io-modes.rst |  5 +++++
 fs/nfsd/vfs.c                                   | 11 +++++++++--
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 2679d85152dfc..90bf1038453cc 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -121,6 +121,11 @@ Misaligned READ:
     verified to have proper offset/len (logical_block_size) and
     dma_alignment checking.
 
+    A READ smaller than dio_read_offset_align is not expanded: it would
+    read one or two whole alignment units to return less than one unit
+    of data. It is issued as DONTCACHE buffered IO instead (normal
+    buffered IO if the filesystem lacks FOP_DONTCACHE).
+
 Misaligned WRITE:
     If NFSD_IO_DIRECT is used, split any misaligned WRITE into a start,
     middle and end as needed. The large middle segment is DIO-aligned
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index b596bd61f8cb7..7e65328de7c86 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1166,11 +1166,18 @@ nfsd_direct_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				eof, host_err);
 }
 
-static bool nfsd_direct_read_ok(struct svc_rqst *rqstp, struct nfsd_file *nf)
+static bool nfsd_direct_read_ok(struct svc_rqst *rqstp, struct nfsd_file *nf,
+				unsigned long count)
 {
 	/* When dio_read_offset_align is zero, dio is not supported */
 	if (!nf->nf_dio_read_offset_align)
 		return false;
+	/*
+	 * A READ smaller than that alignment is not worth expanding to one
+	 * or two whole alignment units.
+	 */
+	if (count < nf->nf_dio_read_offset_align)
+		return false;
 	if (rqstp->rq_res.page_len)
 		return false;
 #ifdef CONFIG_NFSD_V4
@@ -1222,7 +1229,7 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	case NFSD_IO_BUFFERED:
 		break;
 	case NFSD_IO_DIRECT:
-		if (nfsd_direct_read_ok(rqstp, nf))
+		if (nfsd_direct_read_ok(rqstp, nf, *count))
 			return nfsd_direct_read(rqstp, fhp, nf, offset,
 						count, page, eof);
 		fallthrough;
-- 
2.52.0

