Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794872658;
	b=r8ulyJqDBgOICMSwa45si01iH37VGs40FHRoBYQElHWHI/5vgOJadiBjoNyYGvAn1w0e
	 Up1zHiAI2hd2Vikxh2w/lFQ5BzqBbBx03QcQ4xxUDckJr9ztlIC0Qp3iQ5gra4+T4vMz0
	 zZGtaHUzhwUvqnPABO0eRxETBdrMGATaENU3iPz97K5q0+QfLDRG0T0YhJuuGqkH7K3Uq
	 jzZXjGku56WDZYG+EVpvnR/8pdJgdU0RFtQSYyGf5/gxwwA6ckQIgMaHzlQ04Dy3o2AR6
	 ULPlFFZeCkNMYU8tXn8Zn7j6VKCyz6mJWoO4clRJTGTSP3QrdwY1epfeuRdIvLWGPlA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794872658;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Aggzbc/LDeDi/8wY+h3Ugfkp2/fhwef+r9pOJ1uXswA=;
	b=rxHq9/O0gne7jIUnON5V+Wx3w6e152fnnC0/Q3EjGvbS+ALaf2HxDA1H6XV40xI4B4aC
	 pUdQvwBDf8Xy6lTS7RwquIE74sT4gDQEZvaW1PMP+nPXjbjMa9jWEsJWVneuuQUsaC0Ux
	 LbstGdKTsVOZr4/ALHWeTgTNmSzBKqK0DGcM1cAPwztM4ReKXKDsYk39fj7JozaIpXSEY
	 dyFQbrFSHDlpDeb56t610Pg3NDNj/5DCdYNNxBA8B9uEBe0rMUx9wC52Deq2EmSqrHKRg
	 agtMHKTi7D9vsOp9xrnVQPNmWyreexnLPHtLNV72ul+uwZDOT+L9mlrDq+UynBdMMRw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FKPMyM4O;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C40D8606A334
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 23:44:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FKPMyM4O
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 81CE81F000C4;
	Mon, 16 Nov 2026 23:44:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794872658;
	bh=Aggzbc/LDeDi/8wY+h3Ugfkp2/fhwef+r9pOJ1uXswA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=FKPMyM4OU35yns4VWl8XX263r2Riv8vZLFhzuq4sLZ7xBym/1MYgpOe043LpFoDSO
	 Dqsc3YZR6Gt0ORmAYCvu5b6DrEuFMxmzwKP8vSkxf+wt/zgyvT2kxdpsTQK00BmBL/
	 G8u2VfKfKnnyj0Iuh4F8PSRstAE5uiv/3ENbYydyZ8Xv+K5fZNsCE5uzX2zppKM8Oq
	 dhnLeCePOnivW0rcKSktsofISmnHkmecLex5HsgOG2CovXN2DnvMBYd+9akCucLSlJ
	 nm4SXaKYCrYyUb3dGS9jDBp8F9VQK4E2id7JH0Xb3E8VZlFLULVUeZeBpiMf0sq2/s
	 Pep0TObK9LrIQ==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 16 Nov 2026 18:44:11 -0500
Subject: [PATCH 3/7] NFS: Return NFS4ERR_BADXDR for a callback with
 truncated arguments
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
Message-Id: <20261116-quinn-v1-3-f05258cab8e4@kernel.org>
References: <20261116-quinn-v1-0-f05258cab8e4@kernel.org>
In-Reply-To: <20261116-quinn-v1-0-f05258cab8e4@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=5039; i=cel@kernel.org;
 h=from:subject:message-id; bh=UcR22+maEiRWE0c7VJjEQ7BWfKDbxx+kKRCPgMR+GS0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq+5VRwlLy3HXp4N8UfytI+K5mLQl/HFjJ6sRFf
 eF8AOtIKkSJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavuVUQAKCRAzarMzb2Z/
 l3b1EACiq3FarnCm9E51Fj5uXVufng4RtDhMgig1V6bVeI8RZESZsKuQtZhtI/PGIQT2iy5gpzC
 f0rYUMBuxvHkWHxtF4viXt2KE2qYfEp+lYRy8jtfzsj8kagfGWMCFftJVGFRlNQUjUXhgCwWztn
 mnZ7Mp0gKz6psEe8nMaoE11reVP70vHlmeWSp/luxrH7VJR4MM2ibiYVXC4GqSWP0rNiD+zTpjx
 yVcJUPjx2Ne86tCrCk68FHx8HUSZyrghHJ87t40c9UKXAiFVojPSbbGhNYWD6khg3XhGMebnyco
 VIFJi9wnnd5yqcCXR+mgdRb9Q3onHq52FuyH7lJ81vHc9ziVzcpCQUM+wS32vFO8MCBQYyOHC7h
 E7pwvIcTtPSGZve8/tBDdO5K2sdUbJQkHifwKsNHMUA4SXgTY0pFlmYf745pRLXODBTdQtT3P+8
 3NhIbIYnmwDcUkqM39wlaBRKoHycp0PusKcZVYdVFpzWLF45nOUH5M4YFDolMQWEi0CxSrL3S8Y
 8LWZzDz8hX3OoPFhJOH1LMtMGK6H7qj3phE7CYHI8RUBEnrPCVy+SfYFjaVs6swzZfUaw2DGNDn
 789cg8uiKL245D1nzUvtYURSApNiTzme4yA3/lRjmxZ3jLtlrDftw7n1EDFaoA3UGvx0g1QeEJO
 wUTgsbYb+z+i0hw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

When the arguments of a callback operation end early, the argument
decoders return NFS4ERR_RESOURCE, and process_op() puts that status in
the operation result and in the CB_COMPOUND status. RFC 7530 and RFC
8881 both define NFS4ERR_BADXDR for a request that ends before all of
its arguments have been seen. RFC 8881 does not define NFS4ERR_RESOURCE.

Return NFS4ERR_BADXDR from the argument decoders in every minor
version. decode_compound_hdr_arg() now returns the same status for a
malformed compound header, so test for NFS4ERR_BADXDR where
nfs4_callback_compound() rejects that header with GARBAGE_ARGS.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/callback_xdr.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 64ce903918ec..3dd2181e51f6 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -79,7 +79,7 @@ static __be32 decode_string(struct xdr_stream *xdr, unsigned int *len,
 
 	err = xdr_stream_decode_opaque_inline(xdr, (void **)str, maxlen);
 	if (err < 0)
-		return cpu_to_be32(NFS4ERR_RESOURCE);
+		return cpu_to_be32(NFS4ERR_BADXDR);
 	*len = err;
 	return 0;
 }
@@ -90,13 +90,13 @@ static __be32 decode_fh(struct xdr_stream *xdr, struct nfs_fh *fh)
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
-		return htonl(NFS4ERR_RESOURCE);
+		return htonl(NFS4ERR_BADXDR);
 	fh->size = ntohl(*p);
 	if (fh->size > NFS4_FHSIZE)
 		return htonl(NFS4ERR_BADHANDLE);
 	p = xdr_inline_decode(xdr, fh->size);
 	if (unlikely(p == NULL))
-		return htonl(NFS4ERR_RESOURCE);
+		return htonl(NFS4ERR_BADXDR);
 	memcpy_and_pad(fh->data, sizeof(fh->data), p, fh->size, 0);
 	return 0;
 }
@@ -108,11 +108,11 @@ static __be32 decode_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
-		return htonl(NFS4ERR_RESOURCE);
+		return htonl(NFS4ERR_BADXDR);
 	attrlen = ntohl(*p);
 	p = xdr_inline_decode(xdr, attrlen << 2);
 	if (unlikely(p == NULL))
-		return htonl(NFS4ERR_RESOURCE);
+		return htonl(NFS4ERR_BADXDR);
 	if (likely(attrlen > 0))
 		bitmap[0] = ntohl(*p++);
 	if (attrlen > 1)
@@ -128,7 +128,7 @@ static __be32 decode_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
 
 	p = xdr_inline_decode(xdr, NFS4_STATEID_SIZE);
 	if (unlikely(p == NULL))
-		return htonl(NFS4ERR_RESOURCE);
+		return htonl(NFS4ERR_BADXDR);
 	memcpy(stateid->data, p, NFS4_STATEID_SIZE);
 	return 0;
 }
@@ -149,7 +149,7 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
 		return status;
 	p = xdr_inline_decode(xdr, 12);
 	if (unlikely(p == NULL))
-		return htonl(NFS4ERR_RESOURCE);
+		return htonl(NFS4ERR_BADXDR);
 	hdr->minorversion = ntohl(*p++);
 	/* Check for minor version support */
 	if (hdr->minorversion <= NFS4_MAX_MINOR_VERSION) {
@@ -198,7 +198,7 @@ static __be32 decode_recall_args(struct svc_rqst *rqstp,
 		return status;
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
-		return htonl(NFS4ERR_RESOURCE);
+		return htonl(NFS4ERR_BADXDR);
 	args->truncate = ntohl(*p);
 	return decode_fh(xdr, &args->fh);
 }
@@ -355,7 +355,7 @@ static __be32 decode_sessionid(struct xdr_stream *xdr,
 
 	p = xdr_inline_decode(xdr, NFS4_MAX_SESSIONID_LEN);
 	if (unlikely(p == NULL))
-		return htonl(NFS4ERR_RESOURCE);
+		return htonl(NFS4ERR_BADXDR);
 
 	memcpy(sid->data, p, NFS4_MAX_SESSIONID_LEN);
 	return 0;
@@ -372,7 +372,7 @@ static __be32 decode_rc_list(struct xdr_stream *xdr,
 	if (status)
 		goto out;
 
-	status = htonl(NFS4ERR_RESOURCE);
+	status = htonl(NFS4ERR_BADXDR);
 	p = xdr_inline_decode(xdr, sizeof(uint32_t));
 	if (unlikely(p == NULL))
 		goto out;
@@ -417,7 +417,7 @@ static __be32 decode_cb_sequence_args(struct svc_rqst *rqstp,
 
 	p = xdr_inline_decode(xdr, 5 * sizeof(uint32_t));
 	if (unlikely(p == NULL))
-		return htonl(NFS4ERR_RESOURCE);
+		return htonl(NFS4ERR_BADXDR);
 
 	args->csa_addr = svc_addr(rqstp);
 	args->csa_sequenceid = ntohl(*p++);
@@ -550,7 +550,7 @@ static __be32 decode_write_response(struct xdr_stream *xdr,
 		return 0;
 	}
 out:
-	return htonl(NFS4ERR_RESOURCE);
+	return htonl(NFS4ERR_BADXDR);
 }
 
 static __be32 decode_offload_args(struct svc_rqst *rqstp,
@@ -588,7 +588,7 @@ static __be32 decode_offload_args(struct svc_rqst *rqstp,
 	}
 	return 0;
 out:
-	return htonl(NFS4ERR_RESOURCE);
+	return htonl(NFS4ERR_BADXDR);
 }
 #endif /* CONFIG_NFS_V4_2 */
 static __be32 encode_string(struct xdr_stream *xdr, unsigned int len, const char *str)
@@ -958,7 +958,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp)
 	__be32 status;
 
 	status = decode_compound_hdr_arg(&rqstp->rq_arg_stream, &hdr_arg);
-	if (status == htonl(NFS4ERR_RESOURCE))
+	if (status == htonl(NFS4ERR_BADXDR))
 		return rpc_garbage_args;
 
 	if (hdr_arg.minorversion == 0) {

-- 
2.56.0

