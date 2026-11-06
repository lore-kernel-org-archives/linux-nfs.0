Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793989272;
	b=mRDZ7XLjdRihO1psc+p3NuHM4W0cYrfIz5mFvzgLVlxQhd3aSUGiI8LOL93j4BPC/jxh
	 Nc/kmeAgD3hEZIm3qSq6otf5Jnow9U2EwWCQqrL0hBlBD9HvD3hKiJREoyMgg2wsUW5TX
	 K8DnfzhUzLQEzYzf7vENn+ltmG4+KrOlZ704jjJ9qX4QZuS7/F6USVjZRmKvP+xdXi/OQ
	 UmGo4QOWDMMaoA1BtXEPbYllLcGEhER3wfcl6L/Cm951m7PZeuEBbrKEaU5IuLtk6LzkX
	 3xBqI5ql71DnF74ejRJphrEsv6LkLfYJS/T/XqLuhEPgdXbB9FfylM1o/43dp6fD6pg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793989272;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=ObXserv6wK0CP8wT5BlMaXZtcyvdz4dAegxnXRrJDGY=;
	b=HIp6bQkSj9xsiAXuRHNZAIqzyerTPYivvATinuBP/nvchX4smWAFlDJZLJfOr2mpSmzb
	 twks0eezZcTMNBUnqxWFY8S64+7o1FC+6/Y6IT8n0flBaVFANyXBBgGRP+86wsKlZJRaC
	 80fD5v76JjJaEnI3im0Dic19YZqefSjc2YA6eXRbEx1Jd/NSV3MNJB6uRGYn/JbdKY5fL
	 If4KuLdCQQXn/q60d4O4CsSC95y51KPe4rc/cEq3fTuZ5S6EIEfK12Fo56a4Xp2zwrMB8
	 1OstEwK9T+SMbN2oZXOS+jS70/l8Sv7opA/TzTlyLi8h00PWzZejYJn7ROkpl65XAFw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=AcLih41h;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 004C6606A32C
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 18:21:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=AcLih41h
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9F17B1F008A7;
	Fri,  6 Nov 2026 18:21:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793989271;
	bh=ObXserv6wK0CP8wT5BlMaXZtcyvdz4dAegxnXRrJDGY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=AcLih41h8AvpUp9G8O48i32M/OwnQ3PUtOedX9RFVoNfzIBZMnAtQo5zHY6i3Rxwz
	 yiYW04qNGkUqXj2R1GXW7iu9jOB/GV/nRyons0DzyMaUSv2n2eCEPoPzBL3UmGdyAy
	 /BbkoHOq/UfkNbj280oFgl8McY9ltr8ES7pmeZYBFpR02jC6XNMZuMIFl5YaGIiLKy
	 BC85R2g8NwEsR6jR+qWbg4FiUaAJsusMywstocsf/ltNJA2o9bvyIc4THucVniN8So
	 na1j/eOa/0kdLKC9uVGAWJusaDrVlGzx34+mq9eAR/lfTLR6ykz5SclWMnkg89eHT5
	 o1rHnzx7ZLlkA==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v3 03/12] NFSv4/flexfiles: cacheline align the per-stripe layoutstats
Date: Fri,  6 Nov 2026 13:20:51 -0500
Message-ID: <20261106182105.78611-4-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261106182105.78611-1-snitzer@kernel.org>
References: <20261106182105.78611-1-snitzer@kernel.org>
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
index 0e94bc289746c..9ce09e02f1ad9 100644
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

