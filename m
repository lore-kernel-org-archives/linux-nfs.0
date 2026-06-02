Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8A8F63672B1;
	Tue,  2 Jun 2026 16:23:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780417410; cv=none; b=spdEVcOGMc3c1vsHFx3h06C2YERiFT49fibzaI4mtSt/wr1HNDZ+5ufPoYeglTSohCqKP2LSa1zj3XLZF2MtRTK6YHHDWtnqU/k23IMVhEX7wbXC3JG7GOpCIjYw5Y40hSp8d/H2xFzAFC/d8yP2H14MtJDYvMgI56UrAIDHiFE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780417410; c=relaxed/simple;
	bh=8gmVfN3NJAp5KEcLS1LfYVQdzKCLVErpphQJ2oZvgRc=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=m8XI5sKXXAppUnT5u+c9tvLWYL6zwLPGmkeIYyo6+b3c1ECurmxWs2hiGFPUHlEBsYt3hvUss99YIxG+Lw95gVHWukYp4DpJ2Min08sIBaRGyAIehGXUT/dOrAzBvDJ+TzKjbW8fvKDufGvjdR+AUDmGtkap1Mb+zOlD/51W73Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Rk6rteS7; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Rk6rteS7"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D054E1F0089A;
	Tue,  2 Jun 2026 16:23:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780417409;
	bh=RL0SDFOGPEfr5cBoJJZ1vB2wDljK98S1sH8InkqDb60=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Rk6rteS7JEbcuZa6EiITg1q0KOSeNJrabLyCriRrAMrB44+i7DkyAX3gi75IyGJ1l
	 1gKifr7BSB3A5qv1sfByT4MAZzwpDb1KSxvzcnaqE4ek/hOA3uClaAUKBxrSiCQzNZ
	 tCr2aZGL0u5ton43ntbGP1pApRmiUnhmEdLKUmIve0aTpYQ5m+VUNjYAhpYt4zYavY
	 XuCr3OKYbc1TljqF32BdTmQM1oR4p55QhwrhsyeoHr43z6KxH9SNeHsFktXlL3JdxP
	 dcPyjVrB8TNYcwVWlt+jr3t72OBjfUIx0TmggEG3PYb8Yb8r9UFsfITMfhZifmTWdv
	 gPEP5RZVY1Bww==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 02 Jun 2026 12:23:13 -0400
Subject: [PATCH v2 1/9] nfsd: defer vfree of compound ops to fix rpc_status
 UAF
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20260602-nfsd-testing-v2-1-e4ea62e3cd5c@kernel.org>
References: <20260602-nfsd-testing-v2-0-e4ea62e3cd5c@kernel.org>
In-Reply-To: <20260602-nfsd-testing-v2-0-e4ea62e3cd5c@kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Lorenzo Bianconi <lorenzo@kernel.org>, 
 Anna Schumaker <anna.schumaker@oracle.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Mike Snitzer <snitzer@kernel.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@meta.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Trond Myklebust <trond.myklebust@hammerspace.com>, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1858; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=8gmVfN3NJAp5KEcLS1LfYVQdzKCLVErpphQJ2oZvgRc=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqHwN8myL5xm+TtumeR50TKFtNaKBYLMhTOgiNt
 hy2fj+OybeJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCah8DfAAKCRAADmhBGVaC
 FerAEAC1XGeX5v9BcT7lZaVu3i0b40fZdmmzM530cXn4RsKS0Q8X/sECpX4sIJpboTtLiq8NkVG
 TYlKKA5holp4fQvdIpfXDbyzRehZE/4K/mlbVMfaMngppWsFofzRlCxO++e71LE2carqD8W3ZTh
 1numu9CKqb63ShiiG0wtePyGNzr4mlaea4fWWxQeJNB/Kcnl+scdXVWEPKqeXDI4dha+UlgLVT2
 U3mh6rI2Ihm6eun96OFpIIwlNFcDbwoI2a0hMpkRYt0QdElFxeLmgdmXRbvUw0n37GP3BYFM7Vw
 wt8Rd4tIYZDeEX4AiUUO5WNyQmiEcFjpxYJc0U2oH+sbjJ6PzChJ6Xi6v8mYiNIPR2z+S58b+/o
 DEGt148y+e520cR4Wm+3K8Nkn2C4tssh2LicyeksRaIkRsEL2/DE5UNVi1LTCqOKuxwBd1runnH
 oNGywgMBvjzsDfW9By2hlO85XKPs6KWYxjxEWe2RQONeJlbaLHZFH5AF5/hxFiMfrexcerJpVn6
 27JbAvw/ob07idTxGMrzjLFyzixSyHRvpcuFxGxJBYhqTACly7qJIxOYNVvpSzeRRvDHcki0zYG
 YrcYSa71XPT/hD7GY+cNubGhzZZqJPK+hm/1aHdb2n4cExollNOqI1uwkEvcuvJB2BZljYcfqEQ
 1A3WOtq9UbPb9zA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The rpc_status netlink dumpit walks every in-flight svc_rqst under
rcu_read_lock and, for NFSv4 requests, reads opnums out of
args->ops[]. But args->ops is a separate vmalloc buffer freed
synchronously by vfree() in nfsd4_release_compoundargs() at the end
of every compound. The dumpit's rcu_read_lock pins the svc_rqst
struct itself (freed via kfree_rcu), but nothing defers the vfree
of the ops buffer across the RCU grace period. A concurrent compound
completion can therefore free the buffer while the dumpit is reading
it — a use-after-free on vmalloc memory.

The trailing seqcount recheck (smp_load_acquire of rq_status_counter)
cannot undo a load that already retired against freed memory.

Fix by replacing vfree(args->ops) with kvfree_rcu_mightsleep(), which
defers the free until after an RCU grace period. This makes the
existing rcu_read_lock in the dumpit sufficient to protect the read.
The tradeoff is that completed compound ops buffers (up to
200 * sizeof(struct nfsd4_op)) persist in memory slightly longer,
across one grace period, before being reclaimed.

Fixes: bd9d6a3efa97 ("NFSD: add rpc_status netlink support")
Assisted-by: Claude:claude-opus-4-6
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4xdr.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 487a1f62ce15..6680e9e1e5b4 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -6686,8 +6686,10 @@ void nfsd4_release_compoundargs(struct svc_rqst *rqstp)
 	struct nfsd4_compoundargs *args = rqstp->rq_argp;
 
 	if (args->ops != args->iops) {
-		vfree(args->ops);
+		void *old_ops = args->ops;
+
 		args->ops = args->iops;
+		kvfree_rcu_mightsleep(old_ops);
 	}
 	while (args->to_free) {
 		struct svcxdr_tmpbuf *tb = args->to_free;

-- 
2.54.0

