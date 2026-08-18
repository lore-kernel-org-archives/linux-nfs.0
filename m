Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7C8F123E35F
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 01:08:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787015330; cv=none; b=NT0/9Mc7NM6ek1QPRfC0oMx2Bif2Hnl5C+K6RoH3h1BcZTixBsmUcsPVy1uQO0i3bNgOb83DZAxMi3SMQzzXPhB2pyyRBRIqgeW9DMJfDVi0CL+t3GfObMgY4cRJViTD2x4RdqWuSLwW5kcmeW1TzZGXfMn6r1ItIKmoik+M3OI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787015330; c=relaxed/simple;
	bh=LVFo0dgr0PsMTit4r1bW0nHxnL4Z/Y5dPafvTw/8Jao=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=tmmk20MrswqjP17KWusEUchYHCgtyZ7XKC2zs/yIUUeJ0FLrToPYQGMI5zegM8DKWFOaBVZnlyEquCwRd+Z9B2juRplzaZWtFXcl16ZsRs0rmPkpQaQd0qXtOXRuHMdVLKlyGkaYW8+lQjjkmPgrACNjkOhncBx3EWvLmkx/cvQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RQ1AN664; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RQ1AN664"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 85C4D1F00A3D;
	Tue, 18 Aug 2026 01:08:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787015329;
	bh=pcItPad2dyun7lLLE02/pQm9plt3EKV/qNrJRNj/bZc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=RQ1AN664qW8n6Ot9Ir8xfJt84L+D4surBL7VmmtBRfQ1jwuiqZCRhKK1+3pVKujDn
	 HsUZMtpv3i82eRywG1EJpPRooE237aUpQLZc2nPnCDtx+ouy0FPPUoXDxAxAnfxIgZ
	 gU7KDr9cAKfUUnlUzxAgWnkC+kw2Uwskd3RPQZsAEs6PVbuB29nB15ho9TOkoWgmfj
	 MyzpFz+j+DyOfSv1rJAN3ZNCmCoWLTNWxoenlDAbvmG3D2bN0MrCp1luDeCI1dwbAn
	 F6VE/LYkGvLtZTMDBqMjY5KVS6bBvpeGmja5Y+rzE3pRiR4I1dPZXZkKgaJ0c5r9CL
	 atQftQbi7bSMg==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 17 Aug 2026 21:08:38 -0400
Subject: [PATCH v5 3/8] NFSD: Name directory delegations in the
 CB_RECALL_ANY type mask
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260817-recall-any-keep-count-v5-3-3b2cffce701e@kernel.org>
References: <20260817-recall-any-keep-count-v5-0-3b2cffce701e@kernel.org>
In-Reply-To: <20260817-recall-any-keep-count-v5-0-3b2cffce701e@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1456; i=cel@kernel.org;
 h=from:subject:message-id; bh=LVFo0dgr0PsMTit4r1bW0nHxnL4Z/Y5dPafvTw/8Jao=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqg7CdUjUNWIcOynoFNOdi0akS+5XjqTh2GnHlt
 ne3xubWJbqJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoOwnQAKCRAzarMzb2Z/
 l7auD/4/RodRCe8P+6tTGegURbI1Ni2VePj32zmZheJeso8G0B9uECounlEf1c633SsFzR4ZQfb
 i3sCbrU2fV/lVXZpSuWD0HwI2GlMmeLOEGj3MU4IAPWR4thZdhZKqs/LZZlxLy7QUC/1S8KpmnB
 PCxm56em9UgDh0k7Td8lvQ7z+bOQM4ANqgbvI26MrzHManPXMw+HJtd2YUgWrgpSGXAOp+cAflc
 pRLQuxW2mV4W0f6DBvhaUQKJzBO1Uyrpv4B40AdWlhML7mBkUi34Siq+BZjmQU0HRwMfd0aeN+i
 T17RgQMOp0xWWyTGa7kVj5TlU0pwOf0IGsnXECnicivs/UxMfTJ6soQtgUQOfHRZemB9ruREnZ2
 Ui5A8V2wF96FXHwVan9htVPrrH8oNaTw8XgdHUZFXr3QGDjUcCkxEw5jfZnA6RhWGIbeEKw/6Oz
 456ONMbKVZADvba4Qn/bYO9IK4ZqgBlc6HdXXrjiiGHu20jUe9zoG92eZNncYyTvZnDwgCtXc6o
 ICr4ED/uoP6Ab5Z5FdeWBMZWZRfbNMZNfWJtmnQYrwM6gSBbhetuWkNE7fdqwb3sDhSordvuYlJ
 gVdXWGeHgJFOhqYRn05Yac8z7xbcD3BAAbRTxBQ1tfr8VF/ir1WiwGhoXftv7Lz9o0/yBKZePjA
 qWGUsfzdTg8XtLQ==
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

