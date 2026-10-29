Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297183;
	b=zPJOdTgRyv8mApIThsgN8CLML9IhJRlEqm8hl6uMjFH4Ty++mzmR07Yk+n9o65ZL96wO
	 212H1yQqICXOO3XFnzoyRWdd0h6ri3tszpx4FiLZn98TZYecMYOt1enmtGRlCIJPjay+V
	 TjaqX3cgSghImAmKH2Q23aEl9jC8vwu12XkNe2ePay4PnNeAPVAPWpbQoXk49b6VO2+g4
	 DUglWV5iNaEbxo7UAQoFh78kxWPbLgUAcBCc5PKzUT2iviBRj+ERkJlF/u7DKXQLI8kCQ
	 EHBrOxNFldGseOw+6JZ8052zhv7ahil716Uhfffry1t/oljGR4BXbNpLUv6/RPLncSQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297183;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=LIM1PWO7q5cuwC7cO7Y6aYPZzRA6rK/8Dp3kAsbCSzc=;
	b=XOlnLbFfe02TOK4YKwZDjgRjL0ZRka6ZYqT8GX6pIJVgSElMRFJbGjhCyTnYOa2gQwv5
	 FoWYZEBQbmee56Wgx3pgYZYezWdUvgqOkmHYabHPmVuaclUO5rOnybY6nqEn49IHfVRiF
	 HC60XSTX0SfBvJ4m4CR7cWuQ4dDuB/G8aXeUp9GK9kBVnvAWEiG0xL+kMEVMGMvCIV4xw
	 T32Z3QhgEnXNo+VbYCyaqqvNRXeWXUxAWzIXZGz9P21CGTvEAQCPFimT2hrrgh4YT1Ph+
	 XHF3UmnO1XpYDS7e9f9/tR316U+5Au/pR1PIVMnbgKtt8DiHEu1cce2dVq4BP85GgyA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=jEhyWJPb;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 69B0A606A31F
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:06:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=jEhyWJPb
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6FF7E1F01824;
	Thu, 29 Oct 2026 18:06:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793297183;
	bh=LIM1PWO7q5cuwC7cO7Y6aYPZzRA6rK/8Dp3kAsbCSzc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=jEhyWJPbuKnCiDrXvNY8ClZqxa7L8k3rJuIsGfs2QI0NdXqi6hZhZDJUwQ2iGgH3c
	 kLalOlt8k6+KSujq4Ou7KGyzmWT7FLhgWN0LMGfwCS/5sh+j4/f6cHg2pT/q5YaAwp
	 dxnNPVgmew2lKAftWJ4sqjgX2szQHSOwwxqVaIT45qv55u7aXwXhnk4SxH1KcyyWQR
	 mcHjmBQujMsMUKZIA+XwZ6wJLrlfODJpLtTJed2hgMu5qcW+yLl26dcEbpa/S0/FAm
	 YnRP0OM8pMOYkxDSB12AeePLJ77YxB3pKdYAzaBjMUupwuofAVZX8XfK3o3ooIoUbs
	 0HLHrS1nA5cQQ==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 29 Oct 2026 14:06:07 -0400
Subject: [PATCH v7 01/13] NFSD: Make the DRC size limit independent of page
 size
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
Message-Id: <20261029-duplicate-reply-cache-v7-1-f3b0f3cf5bc7@kernel.org>
References: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
In-Reply-To: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1491; i=cel@kernel.org;
 h=from:subject:message-id; bh=COgGg9i1XBm5Uu8T4x3im/AHRL0LXao1dtUbQzdmV0s=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq44scu1XUAM2up/Qcaj+aOzFfnlmFnNrUb7vkr
 LCppeIV1uCJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauOLHAAKCRAzarMzb2Z/
 l9dSD/sHtyZnuQJfGPjTaZSgDXmvscu1AIXUoupq8YLLyDNPuBIQ4Zs4thYBnxBzNOT6AaO9eN9
 JMlyDkfstSopPIX52h1/XknwkH5Jvukg6UV8rfG9NqRZH4LQcLkvaudb6OwTxja/PIJn4uipuOx
 YAsFpb7SI81uzLKUQdFhc8bztRgEnqoXbUBXiydI0SV2WaPzELLWt05TA0/R6ZIg1PbyFqI+xFa
 UUfRPz5VgjAeVkdh9tF0xS96LDZr4LNjUlfZRvuSHSB6dWdLtdovDNakNQHpzbwSxvfE0jB/W/Y
 zGISMXtFDKgZwj/4fp+tI+MN64331Wgh77aalB64EYZ00LT/we3c0HQnmUMp7Dg4bU3FOh6gInl
 MCMuIXCcOE+vAlpIxBgk2ayzdzcko4z1SV3tdqtJMnv7d1hgVvDMODgN75FE3dwqskp5uAAYj1k
 RRXNBfquEtK8EvwHzH3cO0Woqgqvm46tPkX32lOiGumRn0hikmgnE/504/Aw8/qmQJEP9GpeEdg
 XegEANO/qqQ5VadtHemCWxwzar+ovcnspuKGwEzdLjanzwUkN25iGpqb/PD+3CVm3b5KfAj6xra
 h6bDIjw4W1GJVwUWeLQ9XM+bC2cfWnSshy1M41qbU50qtgej0E5+OdGzbevuxPZxNXN2pFXJ2m9
 /CPWy/EAZf3kuEQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_cache_size_limit() takes the square root of the low-memory page
count and then shifts the result by the page size in KB. The shift
belongs under the root. A host with 64 KB pages has a page count 16
times smaller than a 4 KB host with the same memory, so its root is
4 times smaller and its shift 16 times larger, and the limit comes
out 4 times larger. With 8 GB of low memory the limit is 92672
entries on 4 KB pages and 370688 on 64 KB pages.

Take the root of the byte count instead. The result matches the
table above the function on every page size. Low memory on a 32-bit
host is under 1 GB, so the byte count fits in an unsigned long.

Fixes: 0338dd157282 ("nfsd: dynamically allocate DRC entries")
Suggested-by: NeilBrown <neil@brown.name>
Reviewed-by: NeilBrown <neil@brown.name>
Link: https://patch.msgid.link/20260921-duplicate-reply-cache-v6-1-db5e13fd9944@kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 80364b91331a..b43b276a92b3 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -73,7 +73,7 @@ nfsd_cache_size_limit(void)
 	unsigned int limit;
 	unsigned long low_pages = totalram_pages() - totalhigh_pages();
 
-	limit = (16 * int_sqrt(low_pages)) << (PAGE_SHIFT-10);
+	limit = int_sqrt(low_pages << PAGE_SHIFT);
 	return min_t(unsigned int, limit, 256*1024);
 }
 

-- 
2.56.0

