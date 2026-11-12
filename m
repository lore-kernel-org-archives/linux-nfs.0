Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794516198;
	b=biJ8Zxu+8IRc6u+euRXTkp5Uq+/MiTKlbTWRQW0PI2SPaDPcT48y5HEhjOo3WZw3CI4T
	 UTA75X1jsPneNfsRBbOkKP13cNwKorXuxEJeSZqTrC8FF9mDe12dTSNQm8VgXThl9Zg1a
	 Fba0CDqsF8An6OJZ3O89QY/aOkkH2iNWPcfMYzIjDAini/gU1kXYTpD4RCRldYE+4D8xC
	 vDPr0vKTD1j039wX7V+98d/l6aIpH1aWRPJuh58AEQ/RbOkH3cEHFJHeFAGQek0NsQadq
	 S3MyKwZmjpJ0jdVCAj5pL1g48bYAMVzQcdbCHwvdPwRB3v/Ku9ChXitZHcTC8zSRTxw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794516198;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=v9mhTCbK6BkwPXF6/LSAMPc6ulCQtU0yY/ggy+OVsK0=;
	b=D1ayjs0/m8emrRBkj5V0loVEL3WkaWQUUX/Dk5ecSdk7izWXNRZCoTG96uTOobS+Kbl0
	 dVhS+Eo8MLzcDHWZZYdLJLm9DBiBHQPTIkZXg49tQNJcQc6WLpaS7eZ1RfVzjYFMeN9pu
	 eSVISK8lYY/Kwxns1K6s9gKk/wMNfXaslbHvHR5mAozwitrLkhX9j/bL0OBnxiaJw2003
	 9I40ZvL6o3ODb/g9AIF5XMWW9cKLtMeqQXNw5OHRXbrQgEXpbICg+F9VBQNOK5/KE47a1
	 zIE5/Io2vdea4gttkz7R2IRTNsDc5QRjmAYO5O+xCfvHU9yJ90lw4jhtMp/K0qmBYOA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SXPjJQo1;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 23C8E606A321
	for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 20:43:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SXPjJQo1
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0354D1F000CC;
	Thu, 12 Nov 2026 20:43:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794516198;
	bh=v9mhTCbK6BkwPXF6/LSAMPc6ulCQtU0yY/ggy+OVsK0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=SXPjJQo1wSQDGbi0Vb+d0IviiLj/9I3wg0DrC3joFiJao+oRu0oAugcCK0McV/dTC
	 JB2KxHDX0A9yPzdAtKmSt1C9Cnbe1irffE5yvtoLla2nMvPcW0LTrLQunn3CEFvmW9
	 9++3BrooB0Kwy1Q+F/ASoF1NxhIqtn7LCFqcvUSXsKPUmpUQ8MRnUMFD7mCKjnwGWr
	 h4pIgJEa/1rMyGB7MsD+AlXCsDXVK5nEo7v/c0cmMP3JPaCMoVm8exF8DaRIfhuFVA
	 0JvAz8t5a+yMI5yBdupdEfFlGAb6BZ4vQyojiw5fPC6zuYbDQVimz4nDQ2DP81s39C
	 8eOWUSJfO+rDA==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 12 Nov 2026 15:43:04 -0500
Subject: [PATCH v3 4/7] NFSD: Report WRONGSEC from PUTFH when OPEN uses the
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
Message-Id: <20261112-verofess-2-v3-4-487532e4d7ca@kernel.org>
References: <20261112-verofess-2-v3-0-487532e4d7ca@kernel.org>
In-Reply-To: <20261112-verofess-2-v3-0-487532e4d7ca@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2638; i=cel@kernel.org;
 h=from:subject:message-id; bh=PJXG7Rbm3LBDFsAQNy/ejEW6qAGP7noJs+csgVzKM/E=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9iTe1ASDUDKq132mu2DMS5G0nmkTosfifuHXq
 /aqKRZEj+GJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavYk3gAKCRAzarMzb2Z/
 l9SAEACh+Uoke6eyeVzYgOvcM69FcCNg0lhTeif43ed8q7mEfoO8EgJV0S/SMfbpn5GSvfWc61S
 rnzMV1NNdCxhz2brL+4H3fRInUO0g0WWQXr7BGUHEbQDB4RvivLt73AGMw8FP6dsEm82c+fEy8R
 BJcZWGnb4hK6hlbXuBiJ6BW2sBTDN/a0qo4tdd0A6ByrzHq/qYCFX5LB8JoJnNxP14p0lADs2in
 ArOoeW6TH5+ADejR3SUiPH6NAoxPFj0xdod91mmBCgYPp2GCpZ3J9gvkSJyiChHakxJYyLfy0pZ
 YRnZe317PNbSVzVlBZGKio3ZZ/BciURRrQrriADLIxAZCbed+tjKZFqo78qLX4EfGH1D6l+YZaz
 63bhbRpq/Txx3WZgM7vi+4el6DijXcy9F4hQQDFz9SMm+RUqolu6uC+qdAcOHfv+Jprl+a9kg85
 oLAKQMiApQ8AZIIhnpj8wa8JG8cTDMmd3bGmc3lDrIt/AR233V0PtqwduTDCiw/dWYMh6LSBH2u
 mzKcmA5SfwKBjVUk6QaH8YYxxRrSgvNfOEBZtf7QzZ2hhYurfNkpg0pKXAi7se4Nk2oKgQTO8Rm
 zUMAZ8ZM8zAmL7RQdBn0EDZYVHF7J2ALMMA9UQaIGQRDF9Qt+yhkyl+JtwPvBAw0V70gl+QEpcf
 FztUddoe+pvvJkQ==
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
consumer of the filehandle, so PUTFH reports the denial. Clear
OP_HANDLES_WRONGSEC on OPEN, because need_wrongsec_check() now decides
by claim type and no longer reads the flag for OPEN.

Fixes: 68d93184352f ("nfsd4: fix wrongsec handling for PUTFH + op cases")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 39d648c34ae7..85bbb0073874 100644
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
@@ -4023,7 +4044,7 @@ static const struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_OPEN] = {
 		.op_func = nfsd4_open,
-		.op_flags = OP_HANDLES_WRONGSEC | OP_MODIFIES_SOMETHING,
+		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_OPEN",
 		.op_rsize_bop = nfsd4_open_rsize,
 		.op_set_currentstateid = nfsd4_set_openstateid,

-- 
2.56.0

