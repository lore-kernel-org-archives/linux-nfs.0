Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793989271;
	b=ORvI7svtnWU2i3AqDbxj2uEORQamMRpjnwtrA/FgAEA/6L521Vx8CX2TnkhaLJ4zHfZu
	 1QkvnRLlh1l13KmFUJVQcF5fTycm0Ov13+LKxUBAvptdluN7t5A1T40lpk8UB88G+5Meh
	 iFcnl/9yIEmZkRH8d0JzVXou+PjgpeVNBsWP6mV0iGvGGmMgaVi6CPmwYr7gAswMfXAr7
	 HtQvfQEnsniiL9OSjORiIgCPjJ+mfCcp5O476jBx/ubWqnBqKUJHkswHgr7WbnP2lktXh
	 thuuGw6H4j1IUY8E65inQerSOyVsYoNtTPz+rgD8UKf5OlWSw91jQep35QG9kGhMaog==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793989271;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=IsXnZ1MXVzfLWspghA+5iaTXafuT2NhbQMWE9mfFUIA=;
	b=zpSeA8An0jydW6W+6qbCVroRXI3nFIeXBPEjfETm12XW5uOYbzUf/5tPCEQLEtzhG2Fb
	 GBnsBfnOviabMKh2zOImRx/4E2PaF7FA3LsD7UheyPSrAIZJ/Yl2gH/GELZ9GRd1HOVSb
	 a45Q04twFdEm/d29B8G1Do+BE+GG5KK21Ac9tiVprYMWFVln6E8TnwtSQ7JVH3QsNWb3w
	 85UnE4Ru2hgqffNox4Pwr3Hq23fQNmrn3jdoeGuc4+cGgZJQOS+tpep1JrT+0d2zbGDz7
	 2dH88flib3fj11NlgrsM9OQi8cqfBMx96f7VREsHkD+u7WRPeaqYSX3jQz5a0Mtu4og==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZJ5PQlzi;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F178E606A32C
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 18:21:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZJ5PQlzi
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 66B6B1F008A5;
	Fri,  6 Nov 2026 18:21:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793989270;
	bh=IsXnZ1MXVzfLWspghA+5iaTXafuT2NhbQMWE9mfFUIA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ZJ5PQlzi74oqe8uTLjShUMRTJE1Esk7v6i+d2j6P8de4Y2hHpLBvDKqQ1bqnGPZAq
	 qV8gUnq9f3cYg7QfwmXLYtNIOvWzMhIr1XKpFVbXzgBXyxYYw3psFtoRJ7tBUyRHOa
	 0T3rMh1zh2tcSCoTm7eqfNnQzhFC7ig5QjGmELX7N4pmVFhXH8HbL/SaFIfN+riIZz
	 c3A36X4eJVrvFRiRnLxcggbVMQE2mIpxSgvXFlL999NlW1t1yx3VdM0iLn897L0bkP
	 BW492+p/o7G63OEasJbbkafGxwHwwv1ALurxby2EgSH2wjlsS+uuM8f+x/E4WVyYjB
	 3Yli5kP3PN/eg==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Jonathan Flynn <jonathan.flynn@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Mike Snitzer <snitzer@hammerspace.com>
Subject: [PATCH v3 02/12] NFSv4/flexfiles: drop the now-unused per-mirror lock
Date: Fri,  6 Nov 2026 13:20:50 -0500
Message-ID: <20261106182105.78611-3-snitzer@kernel.org>
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

From: Jonathan Flynn <jonathan.flynn@hammerspace.com>

After the previous patch, nothing takes mirror->lock.  Remove it.

Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 1 -
 fs/nfs/flexfilelayout/flexfilelayout.h | 1 -
 2 files changed, 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 7bd88f596e888..57cd8b5d6d71d 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -280,7 +280,6 @@ static struct nfs4_ff_layout_mirror *ff_layout_alloc_mirror(u32 dss_count,
 	if (mirror == NULL)
 		return NULL;
 
-	spin_lock_init(&mirror->lock);
 	refcount_set(&mirror->ref, 1);
 	INIT_LIST_HEAD(&mirror->mirrors);
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 3f94a08c30305..0e94bc289746c 100644
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

