Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794254015;
	b=khDmMNeERkLYXBT4yWDUjIo336EVwwIObThOIYac5xuN0cOTCOIOOUEKApPI2gTlDlQS
	 qnuWCp1Cyu8ZUKfQYMNH+BhN0YK05nsG4FFKlg9M8U2yTo9n36zJN90zY0wyfginHok7h
	 lIcUOEg/git1y19GNtEri4Wc0JgKYvYysAD9OwPoXZiiMBI2zIXq32fsLppTaS5HvgELJ
	 4JGaOL4oIl5PQ9qQyInxJ3yGAGf4eSwUAQ1v3RR/6CzBzKljY0stUJkUl6KxDlBN4WWfL
	 lC+epaAoSlT/TZUsDFSSlT7iNCaGY13jvzPCekxiVBeoCNgnRHRQzDoDUBvBWBkzV9g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794254015;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=zzUqhv9mEQg09d8vpYlXvG3t1+QnSEIRRt7faYoHsjY=;
	b=aDhapQK/RLODdwDrXTHj6VPXKQpIqMveHnT5/V3zg9h/8LjKWOSmcLpe1tFQHErQJwVL
	 Y0BpoIuL3Qohccgr53SH+Q2csXrFgZAOdSVZzFAPG9pZ7rZT0hPgQBGg0MCRwvBmkx3sY
	 IKTx0933Yb87Dg5qZdDGh/QetXs6P0sVAGi+TLNM+DhsWNmhihDI60/bCGva0xaNjFMC4
	 6tRqif9GTDgRX0D5nbOfyh5yl6hH4M893CKKIofq8HLgcabBmvj30wkpmEcmBLVIeyzT5
	 dAB44CwvvGAoDiJ3eHzn999l6c85SisSQ5tn/Vuxxj35KwFO6btY4c+ehoFR1c8FcdQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=G38JrdzX;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 878C360A5BCC
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 19:53:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=G38JrdzX
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 962CA1F00907;
	Mon,  9 Nov 2026 19:53:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794254015;
	bh=zzUqhv9mEQg09d8vpYlXvG3t1+QnSEIRRt7faYoHsjY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=G38JrdzXABXX/3E8BU8XVl2M3rl0Tz4dStwr6wLFWUYU1Ss2+KTQNQnNwOaH8tfM6
	 O683HtrlrfYfCGABIF68imn/po5eDgkTavIOH+TsPSRkCJsZ8A9iluD77fb+g3tP0D
	 v32KMP1vQrCmWOYherXafoDMzRNx8sQfNjBqs8fzAAj5W7NPUbhILcwQr8K+F7jSxG
	 rXKL80piRRPAg6HeaomgVYaPe2S23l/Ieengj9VZfrej7tEVDY/gbMJuLnjvY5ixXa
	 HgD7DCvtLBLKGRl4PPOLjUNUZIAui/Ctb0eS4MuXzzsK5BYknxSw0gVAWRBQnAv9UJ
	 aNVmaOXrRDOUQ==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 09 Nov 2026 14:53:22 -0500
Subject: [PATCH 06/13] NFSD: Place a word-unaligned direct READ's XDR pad
 in the tail
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261109-xdr-page-base-v1-6-a4f4411d760d@kernel.org>
References: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
In-Reply-To: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Mike Snitzer <snitzer@kernel.org>, linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=7768; i=cel@kernel.org;
 h=from:subject:message-id; bh=v1glPXY/aLlrXR9ktQwONnhHaE4W+ZfHnig9UtE00oo=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq8iS41MU5LXNmbKPcATmKtZSMpJBo2xi5jgm6f
 x34gqio89WJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavIkuAAKCRAzarMzb2Z/
 l5enD/9rLxdktCD7mznQON/NhfFmdCUZGb9x77P/1TmYVtH/nJKVJ43BSLrL8Ujb5QViX3rpQcf
 Pss0gZiaSRNBdeDnwlqcMkulUayKDZt1sZSQViPBR8ssu4S0545bUiP7oEsivwexbCZKyRQre1Z
 sYNRZ1sRCvxfv4IXGqHlEt0cZpT8o5E157XM4qIx5d7I2EcCKJRkFvjuiqu/waBDuGFJSNPctTB
 J9gHig8ARPsAdFNhmDX7k7ansK6TW4eA+oW1P164+H8Q0gfUv4RwG4SzW9Ymt8o7hcSscNcCoVW
 ZMnmri39j6lbjHT2a6I3v6+s8AsV4bx7z0YUL2KzKXEDg3PPTnO0/txNbK28fJPrqlUyI5APqxs
 jBUxyuXj72ua5v9nmmy5kE0ycCoLETHqfvDGSi0u7Yl3Cavd2L4iVT0BLC8ZX9b8krcPnFj6kyr
 /vH+jV8Z4CHdiW27lKldg0JCnYWPva1sBBHGlITwSN/zlifPg6KqQeRYjN5bQWwasgi3mzR5LbI
 mXeyjRqDuQAXMQJwHIaSlMOdvHMF7F2HlCVSncvcJTjhvjEKeWgp7XZNMM2XbtQYGJnmBQhbM6D
 D6ssxDiBOwWH8mgCB6OL7XdLmm+4KJuaYYGgQbkXY/TJF3RiTJvxtaGBQwXnibQkJwc52hB8NHJ
 LkRN4wfU3a0tXvQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A direct READ rounds its start down to the DIO alignment and records
the difference, the pad, in rq_res.page_base. When the pad is not a
multiple of four, the encoder cannot continue word-aligned in the
pages after the payload. nfsd4_encode_readv() reserves the payload
through the stream anyway and writes the XDR pad at page_base +
count.

When pad + count fills the last page, the XDR pad lands in the next
page entry. If the read used the whole page array, that entry is the
NULL sentinel, and write_bytes_to_xdr_buf() stores through
page_address(NULL). Any client reading a read_io=direct export can
trigger the oops or memory corruption. Under krb5i, the MIC lands on
the payload and the READ fails an integrity check.

Put the XDR pad in the tail and move the stream there. The pad needs
a word of room in the head, so fall back to a buffered read when the
stream has left the head or the head has no room.

Fixes: d686e64e931c ("NFSD: Implement NFSD_IO_DIRECT for NFS READ")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/filesystems/nfs/nfsd-io-modes.rst |   4 +
 fs/nfsd/nfs4xdr.c                               | 100 +++++++++++++++++-------
 fs/nfsd/trace.h                                 |   1 +
 3 files changed, 76 insertions(+), 29 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index e6fd91cac9c7..3f3fde8be9ba 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -219,6 +219,10 @@ Tracing:
       nfsd_read_dio_pages_in_use  an earlier operation in the same
                                   COMPOUND already put data in the
                                   reply's pages
+      nfsd_read_dio_head_full     an NFSv4 READ whose offset is not a
+                                  multiple of four bytes, when the
+                                  reply's head has no room for the
+                                  payload's XDR pad
       nfsd_read_dio_not_last_op   an NFSv4 READ that is not the last
                                   operation of its COMPOUND
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index daa52bc5f582..bb8d7a2f2a22 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -5232,6 +5232,49 @@ nfsd4_encode_open_downgrade(struct nfsd4_compoundres *resp, __be32 nfserr,
 	return nfsd4_encode_stateid4(xdr, &od->od_stateid);
 }
 
+/* The stream is in the head with a word of room for an XDR pad */
+static bool nfsd4_pad_fits_in_head(const struct xdr_stream *xdr)
+{
+	return xdr->iov == xdr->buf->head && xdr->end - xdr->p >= 1;
+}
+
+/*
+ * Encode a page-resident READ payload and continue the stream in the tail. The
+ * caller checks nfsd4_pad_fits_in_head() first.
+ */
+static __be32 nfsd4_encode_page_payload(struct nfsd4_compoundres *resp,
+					unsigned long maxcount)
+{
+	struct xdr_stream *xdr = resp->xdr;
+	struct xdr_buf *buf = xdr->buf;
+	int space_left;
+
+	/*
+	 * Fail before the pages go in. Once they are in, xdr_truncate_encode()
+	 * in the caller warns when it drops an XDR pad from the tail.
+	 */
+	if (svc_encode_result_payload(resp->rqstp, buf->head[0].iov_len,
+				      maxcount))
+		return nfserr_io;
+	svcxdr_encode_opaque_pages(resp->rqstp, xdr, buf->pages,
+				   buf->page_base, maxcount);
+
+	/*
+	 * Bound the stream at the space left in the head page so a later
+	 * xdr_reserve_space() cannot write past it.
+	 *
+	 * xdr_truncate_encode() is not safe to use once the payload pages
+	 * are in place, so the following stream manipulations are
+	 * open-coded.
+	 */
+	space_left = min_t(int, (void *)xdr->end - (void *)xdr->p,
+			   buf->buflen - buf->len);
+	buf->buflen = buf->len + space_left;
+	xdr->end = (__be32 *)((void *)xdr->p + space_left);
+
+	return nfs_ok;
+}
+
 /*
  * The operation of this function assumes that this is the only
  * READ operation in the COMPOUND. If there are multiple READs,
@@ -5244,7 +5287,6 @@ static __be32 nfsd4_encode_splice_read(
 {
 	struct xdr_stream *xdr = resp->xdr;
 	struct xdr_buf *buf = xdr->buf;
-	int status, space_left;
 	__be32 nfserr;
 
 	/*
@@ -5261,7 +5303,7 @@ static __be32 nfsd4_encode_splice_read(
 	 * svcxdr_encode_opaque_pages() to create a tail buffer
 	 * to XDR-pad the payload.
 	 */
-	if (xdr->iov != xdr->buf->head || xdr->end - xdr->p < 1)
+	if (!nfsd4_pad_fits_in_head(xdr))
 		return nfserr_resource;
 
 	nfserr = nfsd_splice_read(read->rd_rqstp, read->rd_fhp,
@@ -5270,33 +5312,9 @@ static __be32 nfsd4_encode_splice_read(
 	read->rd_length = maxcount;
 	if (nfserr)
 		goto out_err;
-
-	/*
-	 * Fail before the pages go in: xdr_truncate_encode() in the
-	 * caller warns when it has to drop an XDR pad from the tail.
-	 */
-	status = svc_encode_result_payload(read->rd_rqstp,
-					   buf->head[0].iov_len, maxcount);
-	if (status) {
-		nfserr = nfserr_io;
+	nfserr = nfsd4_encode_page_payload(resp, maxcount);
+	if (nfserr)
 		goto out_err;
-	}
-	svcxdr_encode_opaque_pages(read->rd_rqstp, xdr, buf->pages,
-				   buf->page_base, maxcount);
-
-	/*
-	 * Bound the stream at the space left in the head page so a later
-	 * xdr_reserve_space() cannot write past it.
-	 *
-	 * xdr_truncate_encode() is not safe to use after a successful
-	 * splice read has been done, so the following stream
-	 * manipulations are open-coded.
-	 */
-	space_left = min_t(int, (void *)xdr->end - (void *)xdr->p,
-				buf->buflen - buf->len);
-	buf->buflen = buf->len + space_left;
-	xdr->end = (__be32 *)((void *)xdr->p + space_left);
-
 	return nfs_ok;
 
 out_err:
@@ -5315,16 +5333,40 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 {
 	struct xdr_stream *xdr = resp->xdr;
 	unsigned int starting_len = xdr->buf->len;
+	bool dio_ok = read->rd_dio_ok;
 	__be32 zero = xdr_zero;
 	__be32 nfserr;
 
+	/*
+	 * A direct read at an offset that is not a multiple of XDR_UNIT puts
+	 * its XDR pad in the tail. Moving the stream there takes a word of
+	 * room in the head. nfsd_direct_read_ok() traces the other reasons
+	 * a direct read is refused, so test only what it cannot see.
+	 */
+	if (dio_ok && (read->rd_offset & (XDR_UNIT - 1)) &&
+	    nfsd_read_io_mode(read->rd_fhp->fh_export) == NFSD_IO_DIRECT &&
+	    !xdr->buf->page_len && !nfsd4_pad_fits_in_head(xdr)) {
+		trace_nfsd_read_dio_head_full(resp->rqstp, read->rd_fhp,
+					      read->rd_offset, maxcount,
+					      read->rd_nf->nf_dio_read_offset_align);
+		dio_ok = false;
+	}
+
 	nfserr = nfsd_iter_read(resp->rqstp, read->rd_fhp, read->rd_nf,
 				read->rd_offset, &maxcount, &read->rd_eof,
-				read->rd_dio_ok);
+				dio_ok);
 	read->rd_length = maxcount;
 	if (nfserr)
 		return nfserr;
 
+	/*
+	 * When page_base is not a multiple of XDR_UNIT, no word-aligned stream
+	 * position in the pages is an aligned address, so the stream continues
+	 * in the tail instead.
+	 */
+	if (xdr->buf->page_base & (XDR_UNIT - 1))
+		return nfsd4_encode_page_payload(resp, maxcount);
+
 	/*
 	 * svcxdr_encode_opaque_pages() is not used here because
 	 * we don't want to encode subsequent results in this
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 89b1c575f6af..b20d45c7124c 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -662,6 +662,7 @@ DEFINE_EVENT(nfsd_read_dio_class, nfsd_read_dio_##name,		\
 DEFINE_NFSD_READ_DIO_EVENT(no_alignment);
 DEFINE_NFSD_READ_DIO_EVENT(too_small);
 DEFINE_NFSD_READ_DIO_EVENT(pages_in_use);
+DEFINE_NFSD_READ_DIO_EVENT(head_full);
 DEFINE_NFSD_READ_DIO_EVENT(not_last_op);
 
 DECLARE_EVENT_CLASS(nfsd_err_class,

-- 
2.56.0

