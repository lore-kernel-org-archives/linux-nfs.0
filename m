Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793923987;
	b=umMjfho/sA2TIrK50WhGU1h5WdPzHEOIgPUotcXFY/+YMQcv6BICoqKmqDNjKbEBpmQg
	 o1RD+js9FQ8UmBa60RW3eHBl/5Dy85iSY153rz7wMimkFd/k3782MHXnUNqxq6ueXl/p1
	 p6H6TouRgsyIX55LsgoaMQf0DxRyWplExxLePLzRQGZt+YqbbXpeG1Y27kOCI+DD+TdJd
	 qzzUnyBM40pnZ/eH7k14qrajFbdzvrHquIopM072A+FUpHeTGznstTYaUBy+UZ7Pesfjc
	 BwFrUh41wbsBFe6TsCh9z2gByJlHPCItfDqf6mV6P3CRa/01aVm/9XQ4hOLRsB0BZQg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793923987;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=BZEJ+0g2iVXRKKVH3/qSemKvloVbgkTlIvM0MxjckLE=;
	b=ZGdKu+t55kxMH6j87H/haz6A0/JeKac39Pbkd47PLq4FnFgaNEG68/K7630TjcMXNBmY
	 U/Ks/5ucCHKluP6aekbK5sxwRwjS45qD3A5RLGwuo4O8kvVItC3RyOUZJLsGO17ULp+fV
	 KRGaTSoFOHZoEkbgrw67skmfDqAPWkW+m2+7JXVrFt3+nDeUgOeql8ipgtonVofV7veXe
	 ShN4k+skfBooyXU52vTgzlZ2cbqz3hzL1JJF7Uob3BchVfrrTqzjdRRaJkpL2BC//6OtS
	 Dk5Uh+MQ+/TMM0eAupLS/TCC+2uVvTXmXBsWzMEdfUGgyjLFfCt7U+ekEuU6GXcYU1g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=B3+tV642;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C64C5606A31B
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 00:13:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=B3+tV642
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 716CE1F008A3;
	Fri,  6 Nov 2026 00:13:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793923986;
	bh=BZEJ+0g2iVXRKKVH3/qSemKvloVbgkTlIvM0MxjckLE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=B3+tV6420taBrIArV5NqmjVmZobW57Pi6S7tNdXnlf8ofIG0XmU/Lfqk+qNth47Rn
	 RHZQXr1Wd73OMBHmsAL7MEA1C4Ez/gtYs/XUG2+UqI5NFXhhgBospVvuhnD/ypQIY2
	 bAWD0pfAEtyd8baLGMPHn8J74TGOBS2YgG2VaaX5EaH8Z1s3u2/X0+DD5YhhQVsGWP
	 B5tGcZZENIVo3bimoOAnbNbVdnBlp6tzc/CP0/UrwLU7bqDgGrf+5odvIRlpVKvP3Z
	 P1tYJTLuAeDQvn40FpZulaaP6eh7OMX+s3hGXPEbbo4LDaeXA6L54fVDpDB4SAkEej
	 sbXKZkEVaAWBg==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v2 03/12] NFSv4/flexfiles: cacheline align the per-stripe layoutstats
Date: Thu,  5 Nov 2026 19:12:40 -0500
Message-ID: <20261106001251.73472-4-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261106001251.73472-1-snitzer@kernel.org>
References: <20261106001251.73472-1-snitzer@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Mike Snitzer <snitzer@hammerspace.com>

With a lock per stripe, stripes no longer share a lock, but they still
share cachelines.  struct nfs4_ff_layout_ds_stripe is 296 bytes with
8-byte alignment.  So in mirror->dss[], each stripe starts 40 bytes
further into a cacheline than the one before.  Taking stripe i's lock
invalidates the line with stripe i+1's lock and counters.

Cacheline align the lock.  The guarded members then start on a line
boundary.  The struct's alignment of 64 also rounds sizeof() up to a
multiple of 64.  So each stripe in the array starts on its own line.

The stripe grows from 296 to 384 bytes, 2816 bytes for a 32-stripe
layout.  The array base is aligned too: kvmalloc() gets it from a
kmalloc bucket of 512 bytes or more, or from vmalloc().

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 8fa2d8851166a..2797f120a8324 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -14,6 +14,7 @@
 #define FF_FLAGS_NO_IO_THRU_MDS  2
 #define FF_FLAGS_NO_READ_IO      4
 
+#include <linux/cache.h>
 #include <linux/refcount.h>
 #include "../pnfs.h"
 
@@ -87,7 +88,7 @@ struct nfs4_ff_layout_ds_stripe {
 	const struct cred __rcu		*rw_cred;
 	struct nfs_file_localio		nfl;
 	/* Protects read_stat, write_stat and start_time below */
-	spinlock_t			lock;
+	spinlock_t			lock ____cacheline_aligned_in_smp;
 	struct nfs4_ff_layoutstat	read_stat;
 	struct nfs4_ff_layoutstat	write_stat;
 	ktime_t				start_time;
-- 
2.52.0

