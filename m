Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793656343;
	b=CfZJgcLF495Scwb6I4ELe2QNzD0yuBMy17WCFd+JjvJCH9UYuB2NTbqb75Oo55RAIIxP
	 tcVxH23gcCxLZL1edlf7UtV1kkWGrLCj5wTn9o51cI9cr0y07jeHi1inBfY3IofKMmq67
	 vMaGYyUm3WvEqWtNlj6KDjf3dk5Ak6Zs0fc+hw+d+P4em50uFbQpVWUrhhO6JTTKpe+tZ
	 TQpmuaZgnuTxCvfqs6fwqkiqbLSpYNMLZT4bZ/5bThVTt1a242oRD0O1tOOOePrOFWq8A
	 VEkKITigAu3ogvhy/MTkruTqkTbPOavsTfbecLcZqE+RomDKBKppZo5Ux8IZjk9RCyg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793656343;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=Vn/FlglUbN0CH+nAh0JbV/5DlKgBP6ETXiB1JyXezH4=;
	b=vE8F/kbdbRN9t9euXejD3AhEG86B6Azdrw3VxwgR+ZsFkRI6EKi3ZSgAT43WG04Ybhn3
	 cDPu2YX6n0Y2318wKTwvL7k5lbMutuEgrCHQ8ayLlkuq23EpF58J1aAk+D3j0mmrQ3Y33
	 gfo28kLIZaU2sp0Bf2L9AUPy1Jxh7S0supXs1ePBQOheKaudIxYrM8NkurLmi3M9Eh+6U
	 /PTM6DlwoCpKaOcyuoBfHfzd81MJlJAs6oot20qP405zqyKLEq/4YDUFDdD8hqawal3gI
	 tkH2Bzwl36FhlAHqHV47sdVIXfERtl6VJ4+12PeJCJtqosGe/8S1YjeCAAnUfCEMg6g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TE00jDxI;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0DFBA606A324
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 21:52:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TE00jDxI
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 773E71F00A1C;
	Mon,  2 Nov 2026 21:52:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793656342;
	bh=Vn/FlglUbN0CH+nAh0JbV/5DlKgBP6ETXiB1JyXezH4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=TE00jDxInhCswhVY6lde4Ixu9K2p7Gp6FDG9emkE5WSAVDkAPzsj/YQEud/11xamN
	 Cn5JoIx7eFhRVYypvRJhlx73UznhbZPSi1yw0qYdq1ScJduHB2G0jMbuXfP0Zp9kqg
	 rYNAl4T2LxZZRQ7bo8ukpI1hOIUELXfkBuLDpsg26UO0xGwsaOgVJI8v9jYZ3o/PaF
	 Bo9Zph3AVpN5kF42+UfUSPB2+MnaVGizp+SHz2xI0kBfdeytO8aiR6j/XynevJ82bj
	 9Uq0RlEBw5q7SJOhNWDxtD+wnlx0iS4mdBS2+FStSLq18LlZB/CLy/BOO/ifkX4/yf
	 TzrHOqVOjtiyQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] NFS/localio: hold the client across an asynchronous LOCALIO probe
Date: Mon,  2 Nov 2026 16:52:18 -0500
Message-ID: <20261102215220.16055-2-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261102215220.16055-1-snitzer@kernel.org>
References: <20261102215220.16055-1-snitzer@kernel.org>
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

nfs_local_probe_async() queues the client's own cl_local_probe_work
without a reference on the client, and nfs_free_client() does not cancel
it.  The work takes a reference only once it runs.  If the last
nfs_put_client() comes first, for example at umount after an NFSv3 I/O
queued a throttled probe, the client is freed with its work queued, and
the work then runs on freed memory.

Take the reference when the work is queued, and drop it when the work
has run.  If the work is already queued, it already holds a reference,
and the one just taken is dropped.

Fixes: 76d4cb6345da ("nfs: probe for LOCALIO when v4 client reconnects to server")
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfs/localio.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/localio.c b/fs/nfs/localio.c
index cdada6cbb13bf..d5859e8c2a2a8 100644
--- a/fs/nfs/localio.c
+++ b/fs/nfs/localio.c
@@ -203,15 +203,22 @@ void nfs_local_probe_async_work(struct work_struct *work)
 	struct nfs_client *clp =
 		container_of(work, struct nfs_client, cl_local_probe_work);
 
-	if (!refcount_inc_not_zero(&clp->cl_count))
-		return;
 	nfs_local_probe(clp);
+	/* The reference nfs_local_probe_async() took for this work */
 	nfs_put_client(clp);
 }
 
+/*
+ * The work is part of the client, so it holds a reference on the client
+ * from when it is queued until it has run: the last nfs_put_client()
+ * cannot free the client under a queued probe.
+ */
 void nfs_local_probe_async(struct nfs_client *clp)
 {
-	queue_work(nfsiod_workqueue, &clp->cl_local_probe_work);
+	if (!refcount_inc_not_zero(&clp->cl_count))
+		return;
+	if (!queue_work(nfsiod_workqueue, &clp->cl_local_probe_work))
+		nfs_put_client(clp);	/* already queued, with its reference */
 }
 EXPORT_SYMBOL_GPL(nfs_local_probe_async);
 
-- 
2.52.0

