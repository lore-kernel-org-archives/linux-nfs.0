Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 488D3514757
	for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 17:21:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789752097; cv=none; b=lpFvCLge3qb6pxXjLRLx55F1/swKrORNloHKcX42gfE5EwV1G1sLrsD/+N4DqQqnfqlCRYXxjlDyHJIcMyHwpe7GZUYV70MuzaQoSKbvO5alXrsH/0603AgSI6/lQEUfZsTMn480/hxiyBEPOBQEGnhE637PJ8t0HCALK06bm1E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789752097; c=relaxed/simple;
	bh=ySIf1/7AykdeNRQG7t0CTohr456klAYZvzxo31/yRk8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=PcbBq0EMlNecAv7s5NyxQGsDg/7plv5mmPTsHkkFLV4svV9w6RAjw2ZJTaCL6nXG6GWl9QZW+T2aZs3dwp4XeKY73JOhu3Sy2KuP+sMk0YYjP5ItJZ4vdT+2LkPa9FmIhFg7O+J2Kt4IX74hbwSbTM9wun3Pu4qSlQ3Vp6+grsM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=b1Jzn/uf; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="b1Jzn/uf"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6BC021F00899;
	Fri, 18 Sep 2026 17:21:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789752091;
	bh=RLr+wk4GpWFgYmd5QOVlXYtbGjAP2S1zxvGfQ5uPKZ0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=b1Jzn/ufHQ+h+RxUGbtYRHAnbnNAxP9d7igCiIRaMS9x7m3AZkbYdJ8eBLzpRv52N
	 +4TGpEe4n0RBv3s9Zc1r/U86NUXO+Vv6jjq2TVCDm9HQYElWotvy3xNLY/8PJjMPJk
	 ewjn4ILrcE8neRnz4nOtVrTB7rxndL/AmAOqx9xNEZm0dS0EiXPEK8LnipF03Kn1l8
	 BIjY3xG+LF0T2Z+AiRFCSWQM/ch+x1Hk+E1klbRdwFc3NQ/ROB1BCfwh/LpgC3RlyH
	 bU71WdQWrw+qqqTdopxK1V5dNUHYlovEfd63vnDZgqM9ZVHZh3gli4gLA1kwEQksWO
	 MhSYmXxr+ajzg==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 18 Sep 2026 13:21:16 -0400
Subject: [PATCH v5 04/11] NFSD: Prepare bucket pruning for additional
 eviction reasons
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260918-duplicate-reply-cache-v5-4-b6aba9ebf2f4@kernel.org>
References: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
In-Reply-To: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1339; i=cel@kernel.org;
 h=from:subject:message-id; bh=ySIf1/7AykdeNRQG7t0CTohr456klAYZvzxo31/yRk8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqrXMWCxPradJ/LivPYyXg5OP/8KZYyhpvJ1Sae
 gCFz11RiGSJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaq1zFgAKCRAzarMzb2Z/
 l8qzEACptNdS2zQqeIfKMabiBfFbE1h6ZwdhH7vZfjslHV4J1WwFS9ud5hesVuUR4oIAIdfeUgl
 mmN9RjNhphZQ+eNz1NdChbRnWF+ZO1MXuupzsnszbGarhtbO+TtSWN0qhzTmlmwFnbEx+kYzh3M
 Czt4ynpydBcA+Xj8TqzCbk4wfn2jhTgDNhmNTH5Xz9KI1ElNO8vYCH8AkatQPrVKYiZiCT/DVWS
 yFrrK8IKiwgDLCbLi960jOZwoEXRC+ldo9VtFg9ekNwOU0CBtCFOke6UPrV7+vTLp7IA3PKKhc3
 vMGbR5ZEUDCSw64hVn4n9Vafn89L3D/X5RfmnZyUAPyY1YeKqtQYjYA/1TdThmvrD1awSavgpDG
 j9nHy/nCy4diLNiIgNQTv7ZNXBnhvwyxsapBGMpYTc7GkyH+wi7pk8d8KulQnGHeve2Zkq0khkw
 HMku7X8qwSFY1hxAB69fePrh8N6cYwybDTsq53VZo1g1ouPKYGz9gU0sDmA2cyJfxrTVecADcSn
 vJXdPlQ6/sQakjIAnaK2fToeT/taPtRQ7Xuajn5KoDRdMf5Agexhvj4fYqzVianyDGk91jShRug
 BTtzKWHm4mJSim0KoYPR/l5E/jmVrZC52X2KcTfkF39oRUpMhe7GiZuvuxPeaAitY5SOi2wfh0+
 eEemBttinKDnFhg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_prune_bucket_locked() combines its two eviction reasons,
memory pressure and RC_EXPIRE, in a single test and stops the walk
at the first entry the test does not evict. A reason that needs
its own handling, a tracepoint per reason or a test that must run
ahead of the stop, has nowhere to go.

Test each reason on its own and jump to a shared eviction label.
The walk still stops at the first entry no reason applies to.

Assisted-by: LLM
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 474bfeecde9e..be0b27af8ff0 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -275,10 +275,13 @@ nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
 
 	/* The bucket LRU is ordered oldest-first. */
 	list_for_each_entry_safe(rp, tmp, &b->lru_head, c_lru) {
-		if (atomic_read(&nn->num_drc_entries) <= nn->max_drc_entries &&
-		    time_before(expiry, rp->c_timestamp))
-			break;
+		if (atomic_read(&nn->num_drc_entries) > nn->max_drc_entries)
+			goto evict;
+		if (time_before_eq(rp->c_timestamp, expiry))
+			goto evict;
+		break;
 
+evict:
 		nfsd_cacherep_unlink_locked(nn, b, rp);
 		list_add(&rp->c_lru, dispose);
 

-- 
2.55.0

