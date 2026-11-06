Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793923986;
	b=sbSnGOK7l5CulQYwZxwA3lRyjarpkoQgMtdgO4vAPGuhkZgwuoVjETl/v5fEPm7zoq8v
	 eNI1czVEs/tX54jFzEvlnWjc65yF3NIpVXLfSZ47Bfz/P2rdrLSkLvgI9vmuhwnpVn42q
	 Bs0XTNlDnBt8rKQXwMAdfitnbRzgMh7YUnmMNN2tIFQjkTItcncnXpxphIIQJldSoCrUw
	 sCvvbF4RecalZgDCBWv++cr29JGzWjQhphVn22OYSUa01KxQqjc5AwZP8dmsBHI31BXDW
	 H3lPPQ0yZTU4Id1A3LehuDRTpji+rGgSvrHLZ/loCwWd7PxgQB6f/W3V+w1duCmkxYA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793923986;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=jDZSohVCjWXM8MChF19+B8xB49yUg42lHhz0183SlcM=;
	b=RresSfwKF09gX0HFceIZQAYlxCMhPN+llv2gFz0EXzGem4CQVkRoInxem3qeDnt2C2Ts
	 O94RTVXzsF+KGA2+cZOcZov4DDzQ3Pe4huXA4x29aQs3j1BN8MwkAUl+UcfGAov3oppXY
	 TcSngZagd1Ijr136GrBKmeHkRnejx8IFCRzfpNMwyM7AWLED1am9aM/+oTjCcZ5iU4q+p
	 UCeXqxA4kNwwzTEfN+PZJDMEleB/+TJEy7vVCHved+ZOod139dJ1nnXZvlXY3SaWEKxoi
	 HHhUQONM/ivIfmM11czSztaTKvCiI17Ub5kr7U8cHBvV6QFEzT01dsMzU/Xy6SYyRVw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mWJKZ8Ch;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C62FD606A31B
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 00:13:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mWJKZ8Ch
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3DA991F0089F;
	Fri,  6 Nov 2026 00:13:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793923985;
	bh=jDZSohVCjWXM8MChF19+B8xB49yUg42lHhz0183SlcM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=mWJKZ8ChmSv6/rHGP77N/tpQ1JAXzt0gG6CSNAoVT9Zj6QGy+2grx97XsGc4mmjDA
	 /BtvsM3fKMafJe71a3ClWtznjtLYuf3DiKYnfPF8ivCiv8lMDhrAKh3D+b3z+VV+SG
	 HA/zmPChiiNJ3nwZtKP4IpcxMpDrA08zjXVukUga5Yis+lOB2SJZGUUmOp3ch9NCQf
	 w+WFjRux1j2y/u83Aea2QvEUyLFiHnOfR4Z17WwKsnjhnMQhah5nLwcr+dP/kvQs20
	 mWSJQ+7ahxPJchPztFZvjVYSzOzuUPNVG6T0Lpw0NIBV/b7FZ3wv1GL2o00rM3svWK
	 WuKDJbPW6iyOQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Jonathan Flynn <jonathan.flynn@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Mike Snitzer <snitzer@hammerspace.com>
Subject: [PATCH v2 02/12] NFSv4/flexfiles: drop the now-unused per-mirror lock
Date: Thu,  5 Nov 2026 19:12:39 -0500
Message-ID: <20261106001251.73472-3-snitzer@kernel.org>
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

From: Jonathan Flynn <jonathan.flynn@hammerspace.com>

After the previous patch, nothing takes mirror->lock.  Remove it.

Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 1 -
 fs/nfs/flexfilelayout/flexfilelayout.h | 1 -
 2 files changed, 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 7b0e6bdf758fb..3ca37e94dd053 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -280,7 +280,6 @@ static struct nfs4_ff_layout_mirror *ff_layout_alloc_mirror(u32 dss_count,
 	if (mirror == NULL)
 		return NULL;
 
-	spin_lock_init(&mirror->lock);
 	refcount_set(&mirror->ref, 1);
 	INIT_LIST_HEAD(&mirror->mirrors);
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 54aa492bc0bac..8fa2d8851166a 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -99,7 +99,6 @@ struct nfs4_ff_layout_mirror {
 	u32				dss_count;
 	struct nfs4_ff_layout_ds_stripe *dss;
 	refcount_t			ref;
-	spinlock_t			lock;
 	unsigned long			flags;
 	u32				report_interval;
 };
-- 
2.52.0

