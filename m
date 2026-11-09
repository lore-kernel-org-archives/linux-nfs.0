Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794254021;
	b=NaR56ZTz9+uwKmfBfHhujQRG7tuVH4PFRJK2dwzZS+qekzQCA65mRfLWjFlxttq02+Ar
	 1HhbkjS23nxWlz3F9oZ0rMJ+fo0nNSdWlvj8SL/RjUlTF87R72GXIMpSjhjO8BVdKTTy9
	 E/Q/yMbI4Efltmshpqw9Az2pph+/eqo7Z7aUIvHIeoTSAbDFOKFPCenjeFnK/uAONDxm3
	 2H52V9iPGHcM8wbDh8pgtJPvmx7vrcWfMUkw7hGk+a8VsSIdMEpQD5FiihVaT/C+Azhlk
	 rMJqaxKoKXZLfNh9GFgcu1LGDjXFBul4rVUbyEPzm8WVFfNWbTXWVwKZhnaUZwOzqYQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794254021;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=l65AfVenJpNwpqbYPLp0GptgKn7gQoYYkmjGxFI+1Ls=;
	b=2S6N0psO2U1n++V9pd/XoSltKOnZank4d+lxGZjWKfP62BLBZHv8xOCWeh+/T03bFDuD
	 I1ReTu/HqvtLl4d0o2hat29zPxTeKwFPskoOYgXoaxGxqAyUWHew86IGOeedVeSU76Ogo
	 clP4v9kl1HMQ7qIFES0F+LQl/iXT9SE+HX+m0GdcYAM1QLIz4nwhiqH80tMWIxQLqsAkK
	 Ck0fnRHuJmqYaKC/CqxeCELeJkvQwPTotmXMZakoTYEORiX/sa8yT585InsGbAekAck5F
	 EfuFNrP0LWDGrSNJjUgcs3ue+GCAWwaDIWj/1gzqcLzwNWapZNivZJOKUakffi9xGug==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZaLo9gGf;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5B9C060A260C
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 19:53:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZaLo9gGf
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8C63C1F01560;
	Mon,  9 Nov 2026 19:53:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794254021;
	bh=l65AfVenJpNwpqbYPLp0GptgKn7gQoYYkmjGxFI+1Ls=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ZaLo9gGfvBc91H7IWFE8Nao//ErabggqUJMWRbnr14OoRGemKd8YOI7GlVa36o0FS
	 V3YsQTs7HPXJwJh/KZql+I37HOUTZFO5QRX0UntaROKBz8HyPRMpMsWajzGfBFQenj
	 D6npsw/wlXUB6BtCvy+BzMV+Hk+ZHVYyJHRtZEYdGuvtgT2RdJ5l0sTKZgm5LRZ+1h
	 fGg8LfwPWIM65FQiZJW1ORpoaoaX/XtNefNb5LpeZ+RefbgB2uxBL6V5nvx0ZxgJbC
	 AvlDWPqVgf5PXKbuAZgsQfplAHbu9NU+mKgBw+psVsv5v5lBLEiVArHY6qsnnxQE41
	 AVo8wZn/NkYPw==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 09 Nov 2026 14:53:29 -0500
Subject: [PATCH 13/13] NFSD: Do not truncate an operation that reported an
 out-of-space error
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
Message-Id: <20261109-xdr-page-base-v1-13-a4f4411d760d@kernel.org>
References: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
In-Reply-To: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Mike Snitzer <snitzer@kernel.org>, linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=3398; i=cel@kernel.org;
 h=from:subject:message-id; bh=1RqSlo2DWay9dW8LhPjNdCiWiJsbS4g9BZxEqKTMrvQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq8iS4TF4G3X42nGmDAQT8jKlOzimUKtcE7Qwe/
 9wh+xwARgiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavIkuAAKCRAzarMzb2Z/
 l61LD/9pjFvn3Yd/PM+Eh0eLgLde5CmcSUvw94XS/3iR6BK8TYcDIZ7hEEzuH/FriqQ3fb4Qb/1
 TJy8GV0+ASpSWWfEtJbHLYd3jEgNS3ScK2qqir2amrd6WgRXCMPPXXznrMVZA8dL1uhTOPY2aCY
 01nYNXZ04BBAwPUftZMUAmivI+OlmrCitPp8nj7K5bIpNM/izYG4EayyMIjioK+fFvY69N1JGvi
 TkMj4qJjwWvH0oBtbcrPyLDg/IL3D+ZE6qhm/XWiqLeIQs8i2aO68OLwOTjxGBFbuj0oN8Y6Dfd
 BU3kL/cjM+ebRbCI1Ki0YCLTCZe8Hz5ePPN770+ER29DRXXymPep7y6y8EdRLVBAV7nkUBiswuD
 qDPcZOAocoTeSobXlrTueawOWZtDPilFuU4AifqWuYONZA0Enh4ZTVyXGyRpnr6IBH6DBKy9srG
 /8PxXDvLTIPqJs6kjmrVEI3CEgmvtxEe832Kn1MXby0YAxlKfeyv79RlwciJE+YFHo9sUMjoVG7
 l0juLWRk1M0wiwyMitwma7jT5ld9FbH9yV5XGxRCIqyZrhj6qtCgpCmtFZMIg7DfMdQZJGS9E87
 7EoqySG8S2SOx5RavS6ELwFxUKMI2IhEM5Z3Wr3hpGO3niF165WCIeU3QqV2r4DGLSIf8r3UHD7
 6kgCRX5/e/wKgYw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd4_proc_compound() sets NFS4ERR_RESOURCE or NFS4ERR_REP_TOO_BIG
on a non-idempotent operation whose result might not fit in the
reply, without running it. nfsd4_encode_operation() cannot tell
that status from one the encoder produced on running out of space,
and truncates the result back to the status word either way.
SETATTR4res carries a bitmap4 in its error form, so when a
session's maxresponsesize leaves between 16 and 23 bytes after the
READ in PUTFH;READ;SETATTR, the client gets a SETATTR result
missing its bitmap and NFSD logs "unable to encode reply to
nonidempotent op 34 (OP_SETATTR)".

Truncate only when the encoder or the post-encode size check
changed the status.

Fixes: 07d1f8020738 ("nfsd4: fix encoding of out-of-space replies")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4xdr.c | 24 +++++++++++++++---------
 1 file changed, 15 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a55cb8857a54..0b3d77bb9941 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -6823,6 +6823,8 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	unsigned int op_status_offset;
 	struct page **next_page;
 	nfsd4_enc encoder;
+	__be32 nfserr;
+	bool overflow;
 
 	/*
 	 * nfsd4_proc_compound() stops the COMPOUND early only
@@ -6847,7 +6849,8 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	BUG_ON(op->opnum >= ARRAY_SIZE(nfsd4_enc_ops) ||
 	       !nfsd4_enc_ops[op->opnum]);
 	encoder = nfsd4_enc_ops[op->opnum];
-	op->status = encoder(resp, op->status, &op->u);
+	nfserr = op->status;
+	op->status = encoder(resp, nfserr, &op->u);
 	if (op->status)
 		trace_nfsd_compound_encode_err(rqstp, op->opnum, op->status);
 	xdr_commit_encode(xdr);
@@ -6859,6 +6862,7 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 			space_needed = COMPOUND_ERR_SLACK_SPACE;
 		op->status = nfsd4_check_resp_size(resp, space_needed);
 	}
+	overflow = op->status != nfserr;
 	if (op->status == nfserr_resource && nfsd4_has_session(&resp->cstate)) {
 		struct nfsd4_slot *slot = resp->cstate.slot;
 
@@ -6867,15 +6871,17 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 		else
 			op->status = nfserr_rep_too_big;
 	}
-	if (op->status == nfserr_resource ||
-	    op->status == nfserr_rep_too_big ||
-	    op->status == nfserr_rep_too_big_to_cache) {
+	if (overflow &&
+	    (op->status == nfserr_resource ||
+	     op->status == nfserr_rep_too_big ||
+	     op->status == nfserr_rep_too_big_to_cache)) {
 		/*
-		 * The operation may have already been encoded or
-		 * partially encoded.  No op returns anything additional
-		 * in the case of one of these three errors, so we can
-		 * just truncate back to after the status.  But it's a
-		 * bug if we had to do this on a non-idempotent op:
+		 * The encoder ran out of reply space, so nothing past the
+		 * status word is valid. Truncate back to after the status. An
+		 * operation that returned one of these errors itself is not
+		 * truncated: its error form can carry a body (SETATTR's
+		 * bitmap) and is already encoded in full. Truncating a
+		 * non-idempotent op is a bug:
 		 */
 		warn_on_nonidempotent_op(op);
 		xdr_truncate_encode(xdr, op_status_offset + XDR_UNIT);

-- 
2.56.0

