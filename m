Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794962539;
	b=M05nfG05jyS3xpB1fB5Y7RU//OylHvmr+4PPmRs5UTNKWCIgf2sfH0wfhBbpXZ3r90iP
	 An46104HH4Cl2783i1VAqfqYrzVCOCOtXwSh21zid36I97dqpArskgIoaKB36GS2yi6ur
	 7uwU9uZSvUTN/jjMCM4JLMvqCSp929os3Et3+tIHKeA3bFL19505+rLa69Vgwp7rc8/fu
	 rSRrJqbpIc5Spf/2dH3xN9vS6ZgBIFlxDAjFYThUQjMlG610SS7ixeL68dGgmKjVNt2Sb
	 o/TsSItPzL1mxtqFbZ5UkYT3wWiQEhpzu5GtmU8YcU6g6JfCLbqI2G5Wh2BvGvv3Xug==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794962539;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=LlxyQ/bW2BtGpUZE3SQUA2o47XUL0McCJTDfZNfPwqQ=;
	b=cvwHO318+fexHyZ9Yl0P7RcfSZpBC+AnnbCe6LnxJor7wSBCwtI5Dnk+f0sTU6iOQNdr
	 Sld1TV4cn2luT7TIagZt0hH3qOE9Y/joQvJS72Ib8kuxM0QAto6jW8fnaCb3kLOvNoryW
	 e4g2kZOVil8jcwpln6M/SVe5pYOGk9LC4WqcOHXWWl2RX6FvLV9bQfHB9HpS0NgZE8d7h
	 OMtseOHs2nQuIEPBL59P3AYDtMMdNR3d228R5lreEfFwMo32jjpQhY0YfI0/TxCY1jk10
	 /8itdLDqVcN9WEOhuaHW7Y/aBV96WECAEhqAQLULotsWPsW0f7RAJha0lks/NBJO2KQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HKacLhzp;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6B227606A888
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 00:42:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HKacLhzp
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0B58C1F000C7;
	Wed, 18 Nov 2026 00:42:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794962539;
	bh=LlxyQ/bW2BtGpUZE3SQUA2o47XUL0McCJTDfZNfPwqQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=HKacLhzpO3+METOSz92HjAiE4wzsiq5X32R35xJhj6ky3e8i6HL+CbA3l3/hEYJ93
	 ONrp2utM3rIlEVlYUOpPxApzLBemzfl3IB4SYLo+HfaACoXPQCDEbWfOurUcjaX4Rp
	 YugM5R0dnVl5kotW9rxD8iO9FO6OCI/cueCW5c48znIsBx4CvT7p2JncilEdHDJYw7
	 B7tWDEytvkfFaksrsEgovavipJ7X0Wpa96Cy8rV5x54d+KahTMurzc5aC1W6TuxGxO
	 S87ttl217B1318M/yrfLiYnWFPVKVuDex9L4tDGQ3AJXbKHI/hCf50DoWj8R9Qhh7p
	 B/fqCl+OGtUHw==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 17 Nov 2026 19:42:09 -0500
Subject: [PATCH 1/2] NFSD: Check for a COMPOUND before reading
 nfsd4_compound_state
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
Message-Id: <20261117-nfsd-spo-must-allow-v1-1-ac351b60d1a3@kernel.org>
References: <20261117-nfsd-spo-must-allow-v1-0-ac351b60d1a3@kernel.org>
In-Reply-To: <20261117-nfsd-spo-must-allow-v1-0-ac351b60d1a3@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Andrew Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2193; i=cel@kernel.org;
 h=from:subject:message-id; bh=Y3b1G/Jha0KY1mzMIWiuaVkp+qbFBRBU5ZnFziiLeyM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq/PRqjmDZsMTzcmBbTn/LinXqlYMdLEmW9QKeg
 //ZTyyXxHWJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavz0agAKCRAzarMzb2Z/
 lyESD/4mQYDfz7zcPU8bigcpA/ijC7kSs1HLeGamjg6onyi6izPvCSt1Ia5EY4HrYWbuvgPMv01
 wYyul07MjEC2fwPnG6rip8dep0nP8AMViI6irW1LcvztAKG2rq19eb+eiQhQxDBYzjwUGZkbskM
 vCKNfBBSDF/kZUPiwbR4AKLJpW9E9gPSY/lx6lPwrFO5Bvf2alGVafIgNK7QNC5mQUd+FeOfMHe
 r2N+reJzpSx6bBAroTNoT1cmWm6JIYL7Kb1U4cCEBO2uX6nZ7eh6ItQ5jGWchdUnvhlEPpq69bt
 XXZtpc/WSwBTpgNPaNGfs/mFIWj8bvP6b0AMxC+yNXJkhXll8lh3G9V4DpUwD1SDE22j6Kwcvaw
 QUxgEs42oJZ9XbJYLU1t+0rLiOAtsiNKKqqXyAEdATDB6ZCzvUNE8U4RVxuxkqlTHXILMkSfh0l
 Y6n2Rm0y5xj7B6yl9OMIvxlXayBaclnbkTFZyD+X0hLRufjh+mYZeCmtpCPdwyca0DTo5Oq4nFQ
 OufhVOiesoTBor01zwS2nfrPFVUNWN1/Q3+hGVHMrP3LXrzXSkxTWQugIYUZeWqWOKpJkI/NL/S
 7q83rH6SSp1GLozz8sTiSKHjsDORal8KRl9J4BDj5mzPYu35/LJhasQnV8WRewd7wBvxjawBkgN
 pLVuyciWOcFgXfA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

check_security_flavor() calls nfsd4_spo_must_allow() for any request
that fails the export's flavor checks, including NFSv2, NFSv3, and NLM
requests. nfsd4_spo_must_allow() returns false unless rq_procinfo is
the NFSv4 COMPOUND procedure, but an initializer above the rq_procinfo
check has already loaded cstate->clp from rq_resp. For an NLM request,
rq_resp is lockd's result buffer, which is smaller than struct
nfsd4_compoundres:

  BUG: KASAN: slab-out-of-bounds in nfsd4_spo_must_allow+0x9a/0x410 [nfsd]
  Read of size 8 at addr ffff888135b5f370 by task lockd/1202
  Call Trace:
   nfsd4_spo_must_allow+0x9a/0x410 [nfsd]
   check_security_flavor+0x172/0x2e0 [nfsd]
   __fh_verify+0x505/0x1690 [nfsd]
   fh_verify+0xe4/0x100 [nfsd]
   nfsd_open+0x3b/0x320 [nfsd]
   nlm_fopen+0xb2/0x130 [nfsd]
   nlm_do_fopen+0x219/0x370 [lockd]
   nlm_lookup_file+0x68c/0x1140 [lockd]
   nlm4svc_lookup_file+0x3ed/0x820 [lockd]
   nlm4svc_proc_test+0x189/0x5c0 [lockd]

  The buggy address is located 360 bytes to the right of
   allocated 520-byte region [ffff888135b5f000, ffff888135b5f208)

Load cstate->clp after the rq_procinfo check.

Fixes: ed94164398c9 ("nfsd: implement machine credential support for some operations")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 9fba2b67cce2..bd08f7b5181d 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -4420,7 +4420,7 @@ bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
 	struct nfsd4_compoundargs *argp = rqstp->rq_argp;
 	struct nfsd4_op *this;
 	struct nfsd4_compound_state *cstate = &resp->cstate;
-	struct nfs4_op_map *allow = &cstate->clp->cl_spo_must_allow;
+	struct nfs4_op_map *allow;
 	u32 opiter;
 
 	if (rqstp->rq_procinfo != &nfsd_version4.vs_proc[NFSPROC4_COMPOUND] ||
@@ -4430,6 +4430,7 @@ bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
 	if (cstate->spo_must_allowed)
 		return true;
 
+	allow = &cstate->clp->cl_spo_must_allow;
 	opiter = resp->opcnt;
 	while (opiter < argp->opcnt) {
 		this = &argp->ops[opiter++];

-- 
2.56.0

