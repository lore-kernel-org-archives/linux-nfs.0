Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794872659;
	b=De6EJGe1w4fRP2loYBS/bWvw1sQyCdIkC+QOTO53DZT9GGDu1p+6DA0A9YcFaoA0EfF8
	 2/j1ShSKAfm1smuYsAXI1OvCa8unbbdJd2D8CKZMo4YQtWdNCF8FTtHUPoFThG7v+yGA+
	 TtWhWVT/6oKTOWgWRHQFdtldA9SMwjrZV20vHrV6eFPF3zUEpXuKvMSk5NoCx7OU+x6Gw
	 6h2PjmPmoKsqhskPqsS4dKb27JCcshYXi5G4J5mTI8ew7jXija9zjyhOsd30x4exmAKch
	 a8+L+lHpvpLi7HZxPgfXE7H+2JFd0wJ7pXgPWKOXO/MhcVLD5XeGg9fVR96Z8sfSKLw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794872659;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=oq04MjNhELpGuF0k+tLwpv13GqhFrq1vFkt03giRItc=;
	b=lIPcgF598dSKpYE79NcZux1KzBgOzTi1F7+Zb8Go8e2klPRO8Gr4ZfndmmuvIdYIQbsz
	 Elh+LekIxTgKL87n1YjI37avCN8LJoOMnj08cHksakWZMxlifPqli0ZUM4hqU9c13efk3
	 JZ8Wo09etUOROhW0ol86k4EErqIH0Wiu35IuT8dgZc6eCn3uSmBr0QLnSRguXRmMeq852
	 kqOhMZ5JkIEzCtpZQhSWq6yQS45tb/4hZogsq57HJsPnITWWOSepE+Wv+Ywph3dTWIEPK
	 OYhnoez/osjVbV0QVGcTYuLAOAfs6hTajZg2x3O90hJNmNeUoK52aK5ktc2tcbgi8bA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LhWoQjL+;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8EDDB606A334
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 23:44:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LhWoQjL+
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 142361F000C6;
	Mon, 16 Nov 2026 23:44:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794872659;
	bh=oq04MjNhELpGuF0k+tLwpv13GqhFrq1vFkt03giRItc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=LhWoQjL+qBmwev8C9INbIsyegG3cIR40c2AgAhxR/BJ84E1eeQDjNL5S11sWBGnj2
	 slD1mqKRA727AD2kzoLF6hdKZbcnEnJa/ZqHSaWYAQqWvF/fQViJWm5VYWXRmzSpmt
	 suZM/LeJdMD7CE4VCi963d8bESNZA5AAUMZlMIjHTav722S5x+mip11QzDemOOoSIH
	 X1viHqAK95rROkiI0DtD8sziM90BGJBubur24LlvPCcR7g3wTgtLkb+ZMX6buR8lv+
	 CxbQJTxrGhichjneMzj2cxx4yE4uZfWlLhaehIesp2MENbgsSn9IYMDSoJHJTtPVm2
	 /L1WELAQ32PmQ==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 16 Nov 2026 18:44:13 -0500
Subject: [PATCH 5/7] NFS: Discard a partial callback result when encoding
 fails
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
Message-Id: <20261116-quinn-v1-5-f05258cab8e4@kernel.org>
References: <20261116-quinn-v1-0-f05258cab8e4@kernel.org>
In-Reply-To: <20261116-quinn-v1-0-f05258cab8e4@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2258; i=cel@kernel.org;
 h=from:subject:message-id; bh=4lzV89ZMkr78TnubpEWsk0nHKYhcBG4jJoeTgDQLeu0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq+5VRBV8SQm45bSLaADuX118A5TzzL9JRRGN8T
 RPH3IacvhuJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavuVUQAKCRAzarMzb2Z/
 l4bjEAC2XGqiOh6EBkV4G40kc0C6xx8kMfuzPcBO/ZIIL9Bo31D9Yd76hoJqRxRgK9XQ6lZt8Rw
 cLZTt2PV3UB8R3YD4+2gs3s6VkmZXJYOC8FNf5uxUcs6ovSL4/2udfP5t/fX04VFXz9idc32bN0
 LEC3WITGDDQzsqTmy0ePi6A15CzzQra5EMlxqbT00RyrA+ykZ7RhymjQgFs4NIESwEEhZhRFnJj
 +wmjRvPEX8NOngabe0r4jfEht/fegfAmxYIFp0GTwiRC5DcOl0q6VbDvCBwP8Xswiayf+K5SG48
 YpptEIHkG8ovsudj/vikcysKHDLXSaCADP5wyvjpSeOzErm376kVErhVpg3zCMdgHjHgwOkDmsK
 2xI7e486VJfYHCPeeRNA0KKuoVripliRlebxhXBHgvqpINQf/wbyONIlib0I/9P/YxmjcLhVXIY
 q8IjtSyL+dAz9mrWZa+b6R4201Q9e3nF7jB5IYdcWv7UkKR5d3Zi5Uxx5uc9Y/xAdAmMmUpmQ2U
 LXVXY/+tYLQviOR7lQLPGdFLNTqfFGH/pQ85TrS97lP21vDzRX/H8gm5vVMXFmY4sLooXWAiiyF
 sMokWa2TdLgcmc9ycY1T4We1DT3mU/99Z+MVrbLRBHNfBaR+Gp9agK5IYqyM6TKwyV1YPUgq+n4
 7yUeWFQ035jLEgQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

process_op() encodes an operation's result header, with status
NFS4_OK, before it calls the operation's encode_res method. When
encode_res fails partway, the partial result stays in the reply. The
operation reports NFS4_OK with a truncated body, while the compound
status reports the error. For CB_GETATTR the partial result also
carries stale bytes. encode_getattr_res() reserves the attribute
length word before it encodes the attributes and fills the word in
only after the last attribute fits. A failure in between sends
whatever four bytes the reused backchannel reply buffer held.

The encode_res methods do not fail in the backchannel today because
the reply stream does not stop at the end of the transport's buffer.
Once the stream stops there, a server can reach the failure with a run
of CB_GETATTR operations.

When encode_res fails, truncate the reply to the start of the
operation's result header and encode the header again with the error
status.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/callback_xdr.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 5a77487f9481..8d6f5d65e7fc 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -898,7 +898,7 @@ static __be32 process_op(int nop, struct svc_rqst *rqstp,
 {
 	struct xdr_stream *xdr_out = &rqstp->rq_res_stream;
 	struct callback_op *op = &callback_ops[0];
-	unsigned int op_nr;
+	unsigned int op_nr, hdr_start;
 	__be32 status;
 	long maxlen;
 	__be32 res;
@@ -942,13 +942,18 @@ static __be32 process_op(int nop, struct svc_rqst *rqstp,
 		status = cb_reply_too_big(cps);
 
 encode_hdr:
+	hdr_start = xdr_out->buf->len;
 	res = encode_op_hdr(xdr_out, op_nr, status);
 	if (unlikely(res))
 		return res;
 	if (op->encode_res != NULL && status == 0) {
 		status = op->encode_res(rqstp, xdr_out, rqstp->rq_resp);
-		if (unlikely(status))
+		if (unlikely(status)) {
 			status = cb_reply_too_big(cps);
+			/* A partial result can hold unwritten words */
+			xdr_truncate_encode(xdr_out, hdr_start);
+			encode_op_hdr(xdr_out, op_nr, status);
+		}
 	}
 	return status;
 }

-- 
2.56.0

