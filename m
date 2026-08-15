Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 05A3542586E
	for <linux-nfs@vger.kernel.org>; Sat, 15 Aug 2026 16:39:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786811943; cv=none; b=r4xe13n4IDEr+fN0/5JGPHykTmskXfPz7y1tH80tpVREjB9pZLGJ2v+upFTIPwB0Y+34hV2yF/Kh4QEt1T84cqhnfsh312aYFvCSacejR1Ic6Ae0W0OGjV39y4KvdLPsCZoqYUIooDK8MppkoI3uu6K/iXWBbSf6og0ztoO5+SU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786811943; c=relaxed/simple;
	bh=LVFo0dgr0PsMTit4r1bW0nHxnL4Z/Y5dPafvTw/8Jao=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=TviteyiPilnmVovaI30At/dKnY9cyFnzmYMy5gL7ekOS4a0SAHy/1CEp/dnkSDYIsTLCvCu0Twrw49M5ofVwJFhlqTXxbV55IjzQHhpD8TpBWnRmksxZsuEm1F5AJEiBE65dGX1/gWr0MeY1Okg/Tulzu4sioXfQDxH28rncUFY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=odRHsyLI; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="odRHsyLI"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D20331F00A3D;
	Sat, 15 Aug 2026 16:39:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786811941;
	bh=pcItPad2dyun7lLLE02/pQm9plt3EKV/qNrJRNj/bZc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=odRHsyLI0ipA1nR3yf+IQfxaUjs4RxNP8klf+9fSrzLVjX5zRnVkzn8TYyPNC9pCF
	 Ym0RYwdnj+nY1aONii7l3YSy0K4tuuRZO9967I+vDR5dTCLQwZdJ1Xjqunc8NBtZFh
	 X6B8TvYAmj/BSq4fYnIrzHbayMoZEb4/+1n2LgecNXmAO3vLRiLLb5IpSiBfrlTb4v
	 avNrCTDRNwL6PfqTR9vT+K2rtdSB+TBhhwsJLP8m3TPd7fqRcy8Yu3s36ZZ7PkRHdX
	 mQaLW/2dp+erSiWu3ZDIrV2+nWnrHn4wgcl7nylzga2J2Cb+RilKR/CEwWml2cKbmv
	 Kl2CnoGr5l5Rw==
From: Chuck Lever <cel@kernel.org>
Date: Sat, 15 Aug 2026 12:38:51 -0400
Subject: [PATCH v4 3/8] NFSD: Name directory delegations in the
 CB_RECALL_ANY type mask
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260815-recall-any-keep-count-v4-3-bfb5b83d6cb1@kernel.org>
References: <20260815-recall-any-keep-count-v4-0-bfb5b83d6cb1@kernel.org>
In-Reply-To: <20260815-recall-any-keep-count-v4-0-bfb5b83d6cb1@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1456; i=cel@kernel.org;
 h=from:subject:message-id; bh=LVFo0dgr0PsMTit4r1bW0nHxnL4Z/Y5dPafvTw/8Jao=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqgJYh6NSfyte6o9/shTlpP2Y4AXsAW+YjwUcow
 lTaqU5f4n+JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoCWIQAKCRAzarMzb2Z/
 l6pCD/9LgWpvp5g1s1+Sm5FhwD4A4Yus6B8ReuGuJrdvYqKzyovti92fYEcU1N0D8PzXv4ivBwc
 gUxLVdCAjvaFlKhjzi/+BzSbpmr+Y6qR9ngiOP4qyliuv34sVsXzeJKtlYpwyq8b3uWROpNc7Pb
 S9YcAJngU/+lrtUpqKbkMocO9FeClL83fTS4txwiW3kaXCJrhDlOfmSxpSf9giLXBS0Pih2BXmI
 6l/tGgqWtWX4F/xkBWqBPeqTSCor5iupom8ydEZmY29mCUc2aqQ/kGNktIsswWrgqEco9yDiM5r
 NOR4bEUJlFHj11xonVrbVi+zvBjJBSYAbOOxfCND/zR+dg6GeCOdRiR2Afc98l4j9D+/kUGtKEF
 UxSUPZxG2kAjFjki55aApZLo83IOB5szP/Ynpz1OF9oraEqEud4XKzz4RmSZjCmulMANZokuGPy
 bGg2eeRlKPyl7BYmbDGR6nBsR9JkHvkwEVtP9VBpll3mkHvtLUO8RskpalisHun0Jjv2YUZJ6Yo
 tNQBoBImZFPiWQnZ68ijif9pHIMQVaTbL5q6mjTWRjECHXFtOgAFxzP+dtul6ABjHf8uUvrO9Dz
 6jOe8AAoP+l0U9Vd5u61JjcP+b7IqBh8+VscrE20lXxZq9+6G1BsMbv+f03DEEex7cUMdYEPKf6
 iXBpYHFNBs8mCbg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

RFC 8881 Section 20.6.3 distinguishes an NFSv4.1 server
implementation that shares one pool among all classes of recallable
objects from one that keeps separate pools per class. NFSD falls
in the former category.

The CB_RECALL_ANY operation's craa_type_mask argument names the
types of objects in the recallable resource pool, but NFSD's
implementation does not name directory delegations, even though
they are allocated through __alloc_init_deleg(), they are counted
against the max_delegations budget, and the state shrinker reclaims
them.

Add RCA4_TYPE_MASK_DIR_DLG to craa_type_mask so clients that
implement directory delegations consider them when choosing which
delegations to return.

Signed-off-by: Chuck Lever <cel@kernel.org>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fbe073ee5225..2214b4d60c7e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7967,7 +7967,8 @@ deleg_reaper(struct nfsd_net *nn)
 		clp->cl_ra_time = ktime_get_boottime_seconds();
 		clp->cl_ra->ra_keep = 0;
 		clp->cl_ra->ra_bmval[0] = BIT(RCA4_TYPE_MASK_RDATA_DLG) |
-						BIT(RCA4_TYPE_MASK_WDATA_DLG);
+						BIT(RCA4_TYPE_MASK_WDATA_DLG) |
+						BIT(RCA4_TYPE_MASK_DIR_DLG);
 		trace_nfsd_cb_recall_any(clp->cl_ra);
 		nfsd4_run_cb(&clp->cl_ra->ra_cb);
 	}

-- 
2.54.0

