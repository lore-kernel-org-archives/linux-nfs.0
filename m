Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9E31E7081F
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 00:12:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784247156; cv=none; b=aFKiG9LQ36Jj33Iht9KwdyhCeMTMrfCSCtTpvtM/i4ukruJr5XC6axkFFU2WVXEI7NhZS9sdsU9GdzesmhOixL/bWyLcQ4KNzl81LyXfLmh210aJJUhs/McPhoulmE0ddUcCsFHAdkyEx/Enlciu6OevbYaiYnedIgOLq+D5dz4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784247156; c=relaxed/simple;
	bh=RBJdXuTuXjdvohWM9X/ymeaHn9vlkGS8eLJZIPxXQKI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=TJZUZ7V+8tgrdlDXy2c6nivOEniX2SB0Mah0pFNBDZ3bpDhMC0cTrxfZo16FI20nWwij+sfE8m3tQGhfMkxYKfajVel2dFRWXEt7ktrBnIneUSzGlnHjTTaiFYRT/tRt0gtagMMS+P0cloPMZLOzBMTeOuWDEd4zdgivAbWJkWQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=c5ztei/m; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="c5ztei/m"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D11DF1F00A3D;
	Fri, 17 Jul 2026 00:12:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784247155;
	bh=5a54EW5UMCpyhk5jWAiDwQn7Saq362W16eFiZbwOLBk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=c5ztei/mPTvxZ3aqtGYCwVVXqiacjazsEQTU0jTFtsUfDlbpk6x5jEr+45d21EM7A
	 DY8NGt1jGvQh1YYhzVm0O/1HKCPs68EYoKpZT6xWMGUuCrc1hQHCRLF2nZdx5FpGGP
	 S5Mfhi0yvm0Fop4rLxKji7WFs0aRniYnsUuWZzIFnS1ONgZGGzjh+VqFvRCoyBXN07
	 mvkOEe5RZdGESot9CK4Vbc1UNxxp5xx4REx6+KkpADp+KGtx5FZJToSciIU1gSRQ4S
	 defgVCN5Qgo6axy+e9gr+nVWI5yqkKNFUe8vtsWg1gkIromyRrM7mriycX4uWjYDW7
	 GuUO0zycc1+Qg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/5] NFSD: Fix off-by-one in DRC bucket pruning limit
Date: Thu, 16 Jul 2026 20:12:28 -0400
Message-ID: <20260717001232.438792-2-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260717001232.438792-1-cel@kernel.org>
References: <20260717001232.438792-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd_prune_bucket_locked() evicts an entry before checking
the freed count against @max. The check uses "++freed > max",
which does not break until freed exceeds max, resulting in
max + 1 evictions. Use ">=" so the limit stated in the
function comment is honored.

Fixes: a9507f6af145 ("NFSD: Replace nfsd_prune_bucket()")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 07a53a5b3d37..c7db532c8523 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -277,7 +277,7 @@ nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
 		nfsd_cacherep_unlink_locked(nn, b, rp);
 		list_add(&rp->c_lru, dispose);
 
-		if (max && ++freed > max)
+		if (max && ++freed >= max)
 			break;
 	}
 }
-- 
2.54.0

