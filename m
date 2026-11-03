Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793735579;
	b=trTeVB8QWPCofh0dyr9Vqviq7IkwEKxevGV8dBLKkI/FjmLUTSEevldt32IgY8XvLoAa
	 IDrZC3LhgWiqAoNW2wf15McIBpn/PqpMiJemyEOgrKuaxEOXobnFYczZewlhJjZad33JT
	 OYnKPvK0aX3LJKNNsIcT/oBvJCZ9mv1LlQfpsou9Hxjvwr0vbiKckaAWxnT/b1CtGvpkf
	 bggY+uDKYTAMLTL4SIkLZzWohkWK3QnUHFRW7eL5Yw2d2OIHSZ782EnIzSFYcq0nnbzHN
	 Xog1yMR2xyF8vUBcCtQCIJSwFVDUCAaMXuDyJ8sVEzL5KDYrRtxXnZVs4rMO94QBLBw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793735579;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=fQnMbPGAeOD+hohmVhWh2IGYCv30oDnP0ZygCcRvDjA=;
	b=NuQju45XhEVNmLQ5Gg50Lwy3CT7WnexXrtoPEXLVF8HgOYAfEYlHjvPR1ZhbF1Qssk6x
	 T9kK6xoC6+D3wD2M4OKXVoc9voz4w+QT1mt7ywvnaifcrc/CDB3jYk3unnKzqKvODsH7F
	 3qvLKEsM6KkDqV8AIQPvCi5zb3XeNBTFZGCUwd7CTREDpaz/QVdmBsboXI26B/YZFdL4s
	 kYdGwL7tP6Bhd7NEYMOFDIdm42QCc4AHSndTOpIB2rsBp0iPGmmeEDqJLKpQu2GJj0+AE
	 t3LB0moHmzdomIPYOn74Ii2mk1kgv1QbtzJ4TlHCyxPfKWc6WWLAMhATDbHHOlvTobQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ehWgT4RH;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 401F2606A336
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 19:52:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ehWgT4RH
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2E52A1F00A1C;
	Tue,  3 Nov 2026 19:52:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793735578;
	bh=fQnMbPGAeOD+hohmVhWh2IGYCv30oDnP0ZygCcRvDjA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ehWgT4RHIRxLXfB6wHTVa0idQQS6j2XiiVeLjUi4EB+/G1rZaW4kjzpbnTBeMS1pJ
	 fMS+O2pvWX5uoMK2angWvtjwG9sNVGbODqXIgNV/8v0lnaMY6+mbes6CD3Qu8TQj/R
	 MXMij13SMfWes6kW1Y6gXBInt4dy8PKKOcE9UmA0m48Msub+yfMryNfZ/f7/l0qU5U
	 OgjedIM+90cRMZZin8wVW2nS1t06wrhi982VOVY5cb2ldJm9Edm5sz9vLBMXyLLxsk
	 wBiN13KaZUfGmI+iSKu3OiyYj7GxfRWRqTniQdyGAuwaLkW6aeHyBAxB956yFoEvFs
	 cj/tRpqrlZruA==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 03 Nov 2026 14:52:38 -0500
Subject: [PATCH 3/5] NFSD: Report WRONGSEC from PUTFH when OPEN uses the
 current filehandle
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
Message-Id: <20261103-verofess-2-v1-3-9e6568221beb@kernel.org>
References: <20261103-verofess-2-v1-0-9e6568221beb@kernel.org>
In-Reply-To: <20261103-verofess-2-v1-0-9e6568221beb@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2131; i=cel@kernel.org;
 h=from:subject:message-id; bh=jPn859bbpkD1nY7GYeYuwZRIVhwnKKUPz4A8ni/dhJA=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6juWru7b4kZVWUHrxtSzNP8xPHVdI9CcDIAgl
 G5mYB29L36JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauo7lgAKCRAzarMzb2Z/
 l10cD/4neK725xtohxwtcR3l4VpjBsjuu9V87NAHVdCQOpAkD4cYy/8bzHccAtTUfZ22/7noyQg
 onesrrsp+O0AmqJ8ORjHOBfwfF/cVVn2lpXOBJBdGblK6N8DMexM7MXmBP11MymTuIpkRmbOBb4
 oSkJZzPp60i5mClcaRb7nnZ2Pp3ep9TCb5YLyXEaz49/lgQHUCD1SLE9KvHcn8EWnj1A2QGWtFF
 ARLepNiD3bMpcX4Nw0QsgORHmenkZlvnvmaqHouIOfdM6RAI24IXUDljyxMnM/aTMYXIhLTCewG
 n+6ET9R3RDffVJD2sNVQtkGX9SkyKn5e1YVIyWBOKVWoXj1EaVkGSSWmUffiV8AgAIuCgsomTx0
 Ee3wK1H3Jr708V6IQkM/9esfWXacKa6TAxq9TqmFKTP6BfivVYElp0xyqQVM96uqWCpYC905anb
 9siK3YZ9tmFIVcsW8XwKCgD8eR4ComL0etOOhOm3O/ErHBXn7qHrBMzQLk+f6PUQ0RP8l3YStX/
 Q03n7DWGt+YZLdG8VzRfIRBGyBXAEidEd/v52vcQ9xAvR7reD8LsJEt+6PYdSoiNwkJjyrTlnXV
 4BydS7alwhTZwKjQyTCWhcDSOxgV5gzeHdLPniOWtDN5SSCQ+yk7Fmwn3Q3PRNq78RtkKSGysAU
 pu2gr9ppfBYOUVA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

need_wrongsec_check() leaves the deferred security check to any
following OPEN, because OPEN carries OP_HANDLES_WRONGSEC. That is
right for an OPEN by component name, which verifies the parent
directory during its lookup. An OPEN that uses the current filehandle
(CLAIM_PREVIOUS, CLAIM_FH, CLAIM_DELEG_CUR_FH, or CLAIM_DELEG_PREV_FH)
instead reports the denial from its own fh_verify() call. RFC 8881
Section 2.6.3.1.1.7 requires the put-filehandle operation to return
NFS4ERR_WRONGSEC in that case and forbids NFS4ERR_WRONGSEC from an
OPEN by filehandle.

Treat an OPEN that uses the current filehandle like any other
consumer of the filehandle, so PUTFH reports the denial.

Fixes: 68d93184352f ("nfsd4: fix wrongsec handling for PUTFH + op cases")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index faed08eb1b98..9762a56d30ad 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -3259,6 +3259,25 @@ bool nfsd4_cache_this_op(struct nfsd4_op *op)
 	return OPDESC(op)->op_flags & OP_CACHEME;
 }
 
+/*
+ * RFC 8881 Section 2.6.3.1.1.7: only an OPEN by component name may
+ * report NFS4ERR_WRONGSEC itself.
+ */
+static bool open_handles_wrongsec(const struct nfsd4_op *op)
+{
+	/* A failed decode leaves op_claim_type unset. */
+	if (op->status != nfs_ok)
+		return false;
+	switch (op->u.open.op_claim_type) {
+	case NFS4_OPEN_CLAIM_NULL:
+	case NFS4_OPEN_CLAIM_DELEGATE_CUR:
+	case NFS4_OPEN_CLAIM_DELEGATE_PREV:
+		return true;
+	default:
+		return false;
+	}
+}
+
 static bool need_wrongsec_check(struct svc_rqst *rqstp)
 {
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
@@ -3296,6 +3315,8 @@ static bool need_wrongsec_check(struct svc_rqst *rqstp)
 	 */
 	if (resp->cstate.minorversion == 0 && next->opnum == OP_SECINFO)
 		return true;
+	if (next->opnum == OP_OPEN)
+		return !open_handles_wrongsec(next);
 	nextd = OPDESC(next);
 	/*
 	 * RFC 8881 Section 2.6.3.1.1.2: a later put-filehandle operation

-- 
2.56.0

