Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EF3604D9914;
	Tue,  9 Jun 2026 17:47:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781027272; cv=none; b=Fy2rBavOcF80OGC7zHHW1EoDB3nRGEEWAGkEFl43lPaprU4W75YMKN09YBZRyeqE2k9sge9YqyHjttDv2H24aLSyWMkWkBw/VA4ra7M8BflMTJXfRFDqGngKHl1W/Puz94yWUYLZDTtXxGM2FBG/ZtXomP/Yn/cnROj4VeivN2o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781027272; c=relaxed/simple;
	bh=CcG6OUziAhXqUtWJhTOO5mRk4TUJphs0RXifnfi5mtM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=isZ3hIlED4onCSxYrbsdfo1vmylg+A6XqJOJg3YyCAvpoEf2oChXvAUC5irDL4UYgncYWeuvkvVduQt/phhB/QpcmypRd5cjjQXaGPfH2xIYKBs7JatkuYzQHcRVrlnrz8+Eu9h2Tt1n/CKs1k0VFJ8p9Krk4PNaSRcGuWx2/OA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hR2teKm2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hR2teKm2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B03EB1F00893;
	Tue,  9 Jun 2026 17:47:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781027270;
	bh=mAEqiA37affUSLRyClOuNhJ6p7CdJTTrjpVPa02VrCg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hR2teKm2pfU2sI/cZ3IpUj1odAOCe9FIRJKDyccr0SeB6WmSHyOPB0/xKU3hAY2Sa
	 CsQOdr6eKOKCHeFOIlRcod9+RYrAlq8DaUPJ4hq++xOAtdKKUi7NSV8oLuqlEbxrpN
	 twxU72fbJ8UYB/UD/HGQjmIzYjQA56QC1sJJlcYjVWmmIj1CuUM4uLbNPYD0ngY65F
	 LEhen2EkxEqQY6dhT5uwpos1y7A4FMh2PLnGCfd6IjxdyBirQfsOrkUxe9xDXxfQ0V
	 VYEh6UY2MwpQR9hP6elALPhNeHIhtJS5YUdAWwXQRWGGO/zXUahpLrDTfAFLB4XXzE
	 H5UmwOIRsMuGA==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 09 Jun 2026 13:47:24 -0400
Subject: [PATCH 03/19] nfsd: add missing read barrier to rpc_status_get
 dumpit seqcount retry
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260609-nfsd-testing-v1-3-e83acead2ae8@kernel.org>
References: <20260609-nfsd-testing-v1-0-e83acead2ae8@kernel.org>
In-Reply-To: <20260609-nfsd-testing-v1-0-e83acead2ae8@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 Christian Brauner <brauner@kernel.org>, 
 Benjamin Coddington <bcodding@redhat.com>, 
 Donald Hunter <donald.hunter@gmail.com>, 
 Lorenzo Bianconi <lorenzo@kernel.org>, Qi Zheng <qi.zheng@linux.dev>, 
 Andrew Morton <akpm@linux-foundation.org>, 
 Muchun Song <muchun.song@linux.dev>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 netdev@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1600; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=CcG6OUziAhXqUtWJhTOO5mRk4TUJphs0RXifnfi5mtM=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqKFG6QE+VYKL4s8C728nVerRFRvjf/XqSIhhAu
 CvkO102XSaJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaihRugAKCRAADmhBGVaC
 FavpD/442jb8bVS1WV4SHduy51TU3TcrzHpcwGuFby9Diy3kYWl34S6vu0M8Uha22JkdQ+0KpIw
 QcgTSztMK8f72ZZPTK4waR/HOCcH7QlMZJMgfAcWfhjE1+u/2ugv0A3SW1DkAHWv0LoyLnLQYy5
 4ZozHX4fvcRj7XVCYu59OFT2GiMJv/c/jBlxNGtDmWS2N4h+1xNPL7kA1Q9NJSokpewtUXkiQDm
 jr+Y8Zl74KWea6nbRZZl/AD0ABrCrFOPwIwtuAB8wLmzfrUl+wZp+aGyPHkzHl6vXcEiKyb07cs
 VPeCD7FsrJsg9lf1aBK26CUf1xWYdhnqoNBBHwVQYqK1SNkLuqkNUxEP+Wmax7pkQRyC7jmrw6i
 xzg4iKHf29WF0UXT1kIrubnh1aGTsso0h8/IXrQkQ0yy6KE7RJTOQo3ofz9h/xofKj3krAlQmgc
 oeR3fHMWIUzMCBhUwIBfe/iFCNMoKwfscKSfNSlGqY3wX3utU3Fs+ADCl0JJNcvZeH3AhsO8Vcd
 EjjHMi2rX9E/60at+wl/aQL8D8ribdFARVTqY/c2oWnG3M6Cg3DZfiyhheMJa3q5Qa++NKO+Xt3
 qdjEbjjP/y9GfNEcoyJ/SnAoeGqrgNlcvPOiNEtlwCpGH/PsZ6D0M9YeI6UahfYwQyNzrEfMDaF
 Uou4Yz++zaCabWw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The hand-rolled seqcount-like protocol in nfsd_nl_rpc_status_get_dumpit()
is missing a read memory barrier (smp_rmb) before its second counter
check.  The standard kernel read_seqcount_retry() includes smp_rmb()
to ensure that all data reads complete before the counter is re-checked.

Without this barrier, on weakly-ordered architectures (ARM, POWER),
the CPU may reorder field reads past the second counter check, making
the retry logic ineffective: it could observe a consistent counter pair
while reading fields that have been concurrently modified by the writer.

Add smp_rmb() before the second smp_load_acquire() to match the
barrier semantics of the standard seqcount read-side.

Fixes: ac18892ea3f7 ("NFSD: add rpc_status netlink support")
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfsctl.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index c06d25c06f06..a4b5b1467fe2 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1576,9 +1576,11 @@ int nfsd_nl_rpc_status_get_dumpit(struct sk_buff *skb,
 #endif /* CONFIG_NFSD_V4 */
 
 			/*
-			 * Acquire rq_status_counter before reporting the rqst
-			 * fields to the user.
+			 * Ensure all field reads complete before re-checking
+			 * the status counter. Pairs with the smp_store_release
+			 * in nfsd_dispatch to form a seq-lock like protocol.
 			 */
+			smp_rmb();
 			if (smp_load_acquire(&rqstp->rq_status_counter) !=
 			    status_counter)
 				continue;

-- 
2.54.0

