Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794410454;
	b=gVPApvJGyaO8UQZdbd+A1+Q6W6R94DerWmcrkNt3w1m0NWjNbhgMdoxQdTAzlchW6Szw
	 4h8JP9T72Pc+iiplaArcKIRSYhhhkaxTXETCXb6ydKLe70EUpWZahgM2GGtrYMGIJ2KmI
	 SqzuUU18dCnKSJqxyv+glcUd35sP9+NGY2//ZNKjkmx0/AFVgGpuxzwAq+4R2fbOoxQUQ
	 ObkKsxfUrztU/pCgVdejwgsdb6zpdqTDwlyFl7Uk98RFxdRJrD/cdTfderjvFAfe726kx
	 gd5t9vxBXB+f+nTcNym3XhUO8E2kNZ5riwSaExqYWpdFFOnXa4+Y3eVgtBwf8/Ia5mQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794410454;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=/2e4/hUq4SeSeae8q6Tc/nz5Wwz91Vz1J4AND14RFC8=;
	b=yHvm1DVfeXyfiR5z6wERbGcSs0olmT/AiDEF2TmNqYzcQd+BkERHmPcnAfdaMUmv/QFd
	 WZZBq3GpNeHona3/wvmr5fDJk44zoI/+8+QkwXjWr0E7+IDKBdk2VVKb+MprASRMh6m+x
	 gOCArnkrLtm5Ez5D4aWcXHzqha/unK1Yjb8y09qvsBiF0Tfy/0RmjqhdIfs1n0aKllDmO
	 pDQMm99m8se5ryJHK8gcAdxcT8rnqFdIJIlndPYoGJs8GWuc/s0BjxJmQX+XIYryWqxGD
	 w2OUsOs4Ho5X4d9Gw2dqVmTRKZVzliOd6gyBiBHsxmv2xzSDKGFXGwLEgxD+UKI9goA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PoFL3tDu;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 43A8C606A321
	for <linux-nfs@vger.kernel.org>; Wed, 11 Nov 2026 15:20:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PoFL3tDu
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1D0A11F00A05;
	Wed, 11 Nov 2026 15:20:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794410453;
	bh=/2e4/hUq4SeSeae8q6Tc/nz5Wwz91Vz1J4AND14RFC8=;
	h=From:To:Cc:Subject:Date;
	b=PoFL3tDuA0SaT6NlzWYvOjcPD1FkbByxrOVnCz25aHb/RnCNP0XbxI/CqS5lDhMEO
	 8WfGi6zKwoqD+plfKEJanXVWyizL9RzJY0ssyOwL/KIO4g/P5TRSCzliVpUL+fvAP5
	 io5GNq1gMWoEl+ckyeU4bDHtYomVjEDFZjAkAL+i9VCNjGeVjGcGLSTN9r07qYmGBz
	 lrpgjXaLrxUJ1nWVAAB0Rczuzx8bHQpNRWOUicC32Uh2ivEYbpuuOfZMXzfyNhN/sg
	 YnSRz3HbQkxWOd5fvItbaDW/N83CzNpC+nr7VcjuVR7QKRMnD1kLFlLjuUzpqjOWRF
	 0IoLVOvkZhFlw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Mike Snitzer <snitzer@kernel.org>
Cc: <linux-nfs@vger.kernel.org>,
	sashiko-bot <sashiko-bot@kernel.org>
Subject: [PATCH] NFSD: Refuse a direct READ whose aligned range exceeds the reply pages
Date: Wed, 11 Nov 2026 10:20:50 -0500
Message-ID: <20261111152050.172047-1-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
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

nfsd_direct_read() expands the READ's byte range to the file's direct
I/O alignment, then maps reply pages until the range is covered or
rq_page_end is reached. A block device whose logical block size
exceeds PAGE_SIZE reports an alignment larger than PAGE_SIZE. With
16KB blocks and 4KB pages, a maximum-size READ at an offset that is
not a multiple of 16KB needs one more page than the svc_rqst has.
The loop stops at rq_page_end and passes a truncated iterator to the
filesystem. iomap rejects the unaligned length with -EINVAL, and NFSD
returns NFSERR_SERVERFAULT for a READ that a buffered read would have
satisfied.

Check the aligned range against the reply pages in
nfsd_direct_read_ok(), and fall back to a buffered read when the
range does not fit.

Reported-by: sashiko-bot <sashiko-bot@kernel.org>
Closes: https://sashiko.dev/#/patchset/20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org?part=11
Fixes: d686e64e931c ("NFSD: Implement NFSD_IO_DIRECT for NFS READ")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/filesystems/nfs/nfsd-io-modes.rst |  7 +++++++
 fs/nfsd/nfs4xdr.c                               |  5 -----
 fs/nfsd/trace.h                                 |  1 +
 fs/nfsd/vfs.c                                   | 14 ++++++++++++--
 4 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index d57b7916f6c2..28235eceb0c7 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -219,6 +219,13 @@ Tracing:
       nfsd_read_dio_pages_in_use  an earlier operation in the same
                                   COMPOUND already put data in the
                                   reply's pages
+      nfsd_read_dio_range_too_large
+                                  the DIO read offset alignment exceeds
+                                  the page size and the READ, expanded
+                                  to that alignment, needs more pages
+                                  than the reply has. An NFSv4 READ
+                                  that also meets one of the conditions
+                                  below reports that condition instead.
       nfsd_read_dio_head_full     an NFSv4 READ whose offset is not a
                                   multiple of four bytes, when the XDR
                                   stream has left the reply's head or
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 0b3d77bb9941..950c67362566 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -5327,11 +5327,6 @@ static __be32 nfsd4_encode_splice_read(
 	return nfserr;
 }
 
-/*
- * Reply-buffer checks that nfsd_direct_read_ok() cannot make: the
- * payload's placement depends on the alignment pad, and the pad on the
- * READ offset.
- */
 static bool nfsd4_direct_read_fits(struct nfsd4_compoundres *resp,
 				   struct nfsd4_read *read,
 				   unsigned long count)
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 11a6d7d66f6f..45a5db9def39 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -662,6 +662,7 @@ DEFINE_EVENT(nfsd_read_dio_class, nfsd_read_dio_##name,		\
 DEFINE_NFSD_READ_DIO_EVENT(no_alignment);
 DEFINE_NFSD_READ_DIO_EVENT(too_small);
 DEFINE_NFSD_READ_DIO_EVENT(pages_in_use);
+DEFINE_NFSD_READ_DIO_EVENT(range_too_large);
 DEFINE_NFSD_READ_DIO_EVENT(head_full);
 DEFINE_NFSD_READ_DIO_EVENT(reply_full);
 DEFINE_NFSD_READ_DIO_EVENT(not_last_op);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 10ea334cfdab..123c38f3bd88 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1250,9 +1250,11 @@ nfsd_direct_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 static bool nfsd_direct_read_ok(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				struct nfsd_file *nf, loff_t offset,
-				unsigned long count, bool dio_ok)
+				unsigned long count, struct page **page,
+				bool dio_ok)
 {
 	u32 offset_align = nf->nf_dio_read_offset_align;
+	u64 dio_len;
 
 	/* When dio_read_offset_align is zero, dio is not supported */
 	if (!offset_align) {
@@ -1273,6 +1275,14 @@ static bool nfsd_direct_read_ok(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	}
 	if (!dio_ok)
 		return false;
+	/* An alignment above PAGE_SIZE can round the range past rq_page_end */
+	dio_len = round_up((u64)offset + count, offset_align) -
+		  round_down(offset, offset_align);
+	if ((s64)dio_len > (s64)PAGE_SIZE * (rqstp->rq_page_end - page)) {
+		trace_nfsd_read_dio_range_too_large(rqstp, fhp, offset, count,
+						    offset_align);
+		return false;
+	}
 	return true;
 }
 
@@ -1356,7 +1366,7 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		break;
 	case NFSD_IO_DIRECT:
 		if (nfsd_direct_read_ok(rqstp, fhp, nf, offset, *count,
-					dio_ok))
+					page, dio_ok))
 			return nfsd_direct_read(rqstp, fhp, nf, offset,
 						count, page, eof,
 						storage_start);
-- 
2.56.0

