Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 483094779B2
	for <linux-nfs@vger.kernel.org>; Sun,  4 Oct 2026 19:40:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791142833; cv=none; b=PHh+u15rbrgqsLc7fRZaOK2oGfZy0cScTPJF4ao5hIcvjELb/7aVjYPNmdy0HpOgV3JB/gj6L/JauNFuuIQMf0s6aG4vRh5Ba3YFY2yij/dqRRoQTx+X6ycF6RUbSrOY6EMfZTG7mlGLiFFdepKwY/+N5pUxVJ6K446l25weF2s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791142833; c=relaxed/simple;
	bh=uZgUMbbgU1jRbxf3XTiBMOR1Rnzdn+ZiGQjZ96MdA6Q=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=p75B50ZlXiEc5MNhra6Y3SAW9ZAfk9Wu9kEOxu00kCtLbaXQh3UWz68KbVcXON/jOxfs6Q45EPdCgzUAl1j+iiVfRJEr7VNM3Wh2TS04o/9XmoK5EOeIgdiWcV4j+AymWRtabB4Me7b7FZZQMkA2QsXntoy8zRS7jH+vQ0jNfBk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=WTQheSSo; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="WTQheSSo"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8E8991F00898;
	Sun,  4 Oct 2026 19:40:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791142832;
	bh=yFEoFRQ479X8pUlM/VTiQKCxV3yZMz3gbX5S0X0Sirg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=WTQheSSoiMVN6WhGjQGJr/+qom1NVe09+G5O2AEU/azhtTx5x5TLAxPd7W2v5L2Mr
	 c5Q2Vq8Gl+zUXh5j55dIXP2BoBpt3oxBy0kUNBrQ+lGz84dfb91cBYKW2q+ugOCCR+
	 peQAsuBEIKA+OMGYswyzz8KXNc/hDyas7kCFBvwdUPxO3WuO9TfUSQfMHrRXEDU8Wj
	 rCZRiNG8NoIRr2rS4d2kt0CqPlT0lsV7GmtGxGzEmenL6UEbGyV43HjL14kgKRujg7
	 iLzwn6KzGTfeeaLIE3xoHXAjZCdJdAMT5W9sX5EyP2SFtGnmzeXJxlMygtGrTrDr+M
	 T+mVShZN/S44A==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 1/7] nfsd: use direct I/O only for the last operation in a COMPOUND
Date: Sun,  4 Oct 2026 15:40:23 -0400
Message-ID: <20261004194029.10714-2-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261004194029.10714-1-cel@kernel.org>
References: <20261004194029.10714-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A direct read widens the requested byte range to the file system's
alignment and leaves the payload at a nonzero rq_res.page_base. The
xdr_stream encoder does not account for page_base:
xdr_reserve_space_vec() sizes each chunk from page_len alone, and
xdr_get_next_encode_buffer() opens each new page at its first byte.
The stream's position lags the end of the payload by page_base
bytes.

An NFSv4 operation encoded after such a READ overwrites the tail of
the payload, and the transport sends alignment padding in place of
that operation's result. The client sees corrupted file data
followed by an undecodable reply. NFSv2 and NFSv3 are unaffected:
their READ encoders pass page_base explicitly, and nothing is
encoded into the pages after the payload.

Fall back to buffered or DONTCACHE I/O when the READ is not the last
operation in its COMPOUND, as nfsd4_read() already does for splice
reads.

Fixes: d686e64e931c ("NFSD: Implement NFSD_IO_DIRECT for NFS READ")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/vfs.c | 22 ++++++++++++++++++++--
 1 file changed, 20 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 4584d5b94fee..e052b9163692 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -37,6 +37,7 @@
 #ifdef CONFIG_NFSD_V4
 #include "acl.h"
 #include "idmap.h"
+#include "xdr4.h"
 #endif /* CONFIG_NFSD_V4 */
 
 #include "nfsd.h"
@@ -1164,6 +1165,24 @@ nfsd_direct_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				eof, host_err);
 }
 
+static bool nfsd_direct_read_ok(struct svc_rqst *rqstp, struct nfsd_file *nf)
+{
+	/* When dio_read_offset_align is zero, dio is not supported */
+	if (!nf->nf_dio_read_offset_align)
+		return false;
+	if (rqstp->rq_res.page_len)
+		return false;
+#ifdef CONFIG_NFSD_V4
+	/*
+	 * The xdr_stream encoder ignores rq_res.page_base, so an operation
+	 * encoded after a direct read would overwrite the payload's tail.
+	 */
+	if (rqstp->rq_vers == 4 && !nfsd4_last_compound_op(rqstp))
+		return false;
+#endif
+	return true;
+}
+
 /**
  * nfsd_iter_read - Perform a VFS read using an iterator
  * @rqstp: RPC transaction context
@@ -1197,8 +1216,7 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	case NFSD_IO_BUFFERED:
 		break;
 	case NFSD_IO_DIRECT:
-		/* When dio_read_offset_align is zero, dio is not supported */
-		if (nf->nf_dio_read_offset_align && !rqstp->rq_res.page_len)
+		if (nfsd_direct_read_ok(rqstp, nf))
 			return nfsd_direct_read(rqstp, fhp, nf, offset,
 						count, eof);
 		fallthrough;
-- 
2.55.0

