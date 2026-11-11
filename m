Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794419043;
	b=ElOFJia/j6MQslPQ6uG2IHNOhNrHIbd1rp3zgpkAs236VRIrtxaS4xTOws2TtOHFTQCS
	 q1af6u49n7QjmRZXftozOIRqrplHqZ9lmvEYRDjB7v0j26AXwFyjGFQ3QiDckFIfxC/ln
	 xuBUBzEMJrV+9Hxy40FJCVIaWVWnfDHddsY47H5kd8rTzQLpZuV7XtrQjiYQ9tAHPIVog
	 H/ElndSs/y6ep20NT8ldUFdC0nqgXLXloT/BxzT4vV9tP6xnjne7fZRokakFxFTX0st0O
	 BLeiSVPaGmklMhzIRgUEolyE8uYE3LXM69Z1R2nTjcen9EkRc+IBupovSFlphoHpxVQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794419043;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=gNS5I/rie4042M5UY9WJCPraQ+KnaEjM0zUpStyXK+g=;
	b=jPzTmtjRE9NrJH7X+XiRu4dEI6aYLc0Qccsb+yqTcUIHyNKOKeJCOcraCwnmcDxcZ718
	 nWaPmEHJ7QGZFKfaRlXj0D4fFYHicKnF6IsHFeMOWSLxDeebRhJ/aHLwU8g5CW+ZFR+Vd
	 hJnVQAiAV8SBK1hrs5CzeYMvuhwLeHbsuegel8tpeW/aLbPkUEljMoJnAiVe9SaPi5rJ2
	 onSqNsTLqqwiDyWBHHqfmzw0JYkWSWKSzkdRDFnKk4kSEK2CLb9BQxBOWRvOKQplhf8r/
	 FufjaRmQsU877ovjcuh5PdemZUuvi0HW/44FLOcWk/LXnA9TCNvIn+OABLRUJA19qzw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="TH+z+g/F";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 03D46606A898
	for <linux-nfs@vger.kernel.org>; Wed, 11 Nov 2026 17:44:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TH+z+g/F
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CC3181F00A0E;
	Wed, 11 Nov 2026 17:44:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794419042;
	bh=gNS5I/rie4042M5UY9WJCPraQ+KnaEjM0zUpStyXK+g=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=TH+z+g/FeH3plujidgq0EUzsi5zuGpa1A9fUpbBbpNYoJW3znh7BR0++GiU9ntV7n
	 BDkvswFEd3nuwhlCM8b7CAjcsc/IXsvN+FtFMKCcpM+SlOoWxXlzzeS624aVjPYxmJ
	 lZtD3wCucI4NRZ50zLnangSJAA8vNEel0Dr/C/hi2Vb66Fq+MLeUuRhvAVt0Ulvx0A
	 VqEkpaLnCtNWeYiwQVrhaAzV/D4SVcEzxQ3V4KeDLVl6v0b6oJMARhtpDnHcPGs9NT
	 MxfVJtkxTJAUm5lti9wBDskUxBQuecY0gqlJmv7S8+X9RWoWCIveMDPhDR7VEG6Hps
	 H9vDZzhuf0ITQ==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 11 Nov 2026 12:43:44 -0500
Subject: [PATCH v2 4/7] NFSD: Report WRONGSEC from PUTFH when OPEN uses the
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
Message-Id: <20261111-verofess-2-v2-4-01596ca4d8b1@kernel.org>
References: <20261111-verofess-2-v2-0-01596ca4d8b1@kernel.org>
In-Reply-To: <20261111-verofess-2-v2-0-01596ca4d8b1@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2148; i=cel@kernel.org;
 h=from:subject:message-id; bh=zMGUZjsoCNGH02ERqkg6XIqDUrOABfM9+Tsm8QcWIJg=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9KlbQY4AVXGydGafqnR4o+8umxRPHBDAkz1Zg
 vpu6arb/xGJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavSpWwAKCRAzarMzb2Z/
 l2YAEACxOch/rd1g4An+thcQwhdIyvxBb++vZ9CJhSJgZV7OIXB83wM67hy3bQZYcEyD8+9ev+m
 J4MmWeT9dyJYpozPbf3Py8udBLAtP+MDbq/nNLjaxQge2cJ77QSlVcCpzVJCQEqpCsrV3aOPyzI
 P18ok8zvJrJXhpVhtaeJmaPAwweaPeMtioAjuIZfpyCsA9uBewyFE4+aq/VcgSL11A4FDEMry4o
 qCvueV+2Pe3YnziwiQZHcKJiGLb49XQAYNnbK4hq7P6zUur27JbjHV3ag9HBPtqA5DUSwWHqqzW
 lG2SDCsdyFdtlhseR69rApJmyfyiEzF7vDHrG1971h+rM8m2TB6gj8KnIk1hU+bkfv5oghyN2ly
 jTrGMdduWp2nMocKcem/UaigxMBl5MQ8pJxPzC1NTfcg9n8cSgaqOmASZjsraORmk7Jxs7fuEcH
 zlv6ZkfTOiorrmwKzuS0AdchIFVIJ/JxWL4LCC7BxOGgAGgVzXG7EM2lH/DSTVhC5y8GbQ59cSb
 ydcwJqWDvQ1tZ4zcIrFTwOJM4QDPDPA2HV59Kk7WnjI1zPoNI3iKwKPKcsjxtYzmYfpAaZfV3Mv
 LhNwgjkGTLS1zmTQYIPgv1+NyCXcv9bWCDogb1I2ZRNED0dL+86ubpy/xn8BhM+tNKjKrYpFgNe
 fe5O9fdT6wpFyeA==
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
index 0424a98afa33..10d3aeecea9b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -3275,6 +3275,25 @@ bool nfsd4_cache_this_op(struct nfsd4_op *op)
 	return OPDESC(op)->op_flags & OP_CACHEME;
 }
 
+/*
+ * RFC 8881 Section 2.6.3.1.1.7: only an OPEN by component name may
+ * report NFS4ERR_WRONGSEC itself.
+ */
+static bool open_handles_wrongsec(const struct nfsd4_op *op)
+{
+	/* After a failed decode, op_claim_type can read as CLAIM_NULL. */
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
@@ -3312,6 +3331,8 @@ static bool need_wrongsec_check(struct svc_rqst *rqstp)
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

