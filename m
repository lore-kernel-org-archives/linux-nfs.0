Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CB7AB27F759
	for <linux-nfs@vger.kernel.org>; Sat,  3 Jan 2026 17:15:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1767460503; cv=none; b=uPNPcqVwFUXyJQQtcqlArbv2gOMCia0vWhaqc3qZ+g4rsBOH1UDEvRQB1CcSyQyopBleTT9ixjuaFLMIs/a0xDVr3Zzn18gYay4JVRnp4SjDmxb0togk+1F10GHCsB1wwp3aCDoje9U3qgbBOdY77FFzdK0J8/VwUOnaxv30Fv8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1767460503; c=relaxed/simple;
	bh=0kJ3z4AM5+K6nIHZ0R546iASLkgasdhNs5HxZcO8O0w=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=sRsJxVL13nBQ5iPIPc52kTIoRp4mZVWTvj+0Fty1GZSIFZhB+dqXZV614MgCxk7bkERCBD0Q+6q/A7peh6Fk1Y87PGKwrV8TwYITgw/awil/gagPZzFqnrNtCafB8XQtuox9hhHg9Nxu9kUyZJsVWtW5CWoqSzdgi/HJ9FyZ6K8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SYcdUssk; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SYcdUssk"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 570A4C19422;
	Sat,  3 Jan 2026 17:15:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1767460503;
	bh=0kJ3z4AM5+K6nIHZ0R546iASLkgasdhNs5HxZcO8O0w=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=SYcdUsskLbFqCXE7JowIqnudF+LW5bfzoeNGMsl3c+gGCS5sqKYvke/+soFi78ycO
	 k/rBypX5+qptMYewcN2Jsh2BLrFP5Pi4Ta/T1zhmLgLOd+lmdiBj8vTIQq8SV+GDFM
	 9uWslycA4J5tchTL//ofR5WDxMzd9rhM9PDnkLf/yXpgnfP2cL/sxPZXftZiVr8yQq
	 YmRPzxIaMOI+aqn9goDDF0JrTPQQyhf9830lXc6MfhXO2Exa9tW3r6rpfrsDdowEny
	 JVh6zIvuY1LWfd7c1zC6vc7Eyr2o563m1ZDzYSCIrsXTOcX+EpudnIKFs7C1TdM7Pq
	 31i6A3QrEffvw==
From: Trond Myklebust <trondmy@kernel.org>
To: Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] NFS/localio: Deal with page bases that are > PAGE_SIZE
Date: Sat,  3 Jan 2026 12:14:58 -0500
Message-ID: <f7d976f25972708d6b79b48d411e6b3273354c00.1767459435.git.trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.52.0
In-Reply-To: <cover.1767459435.git.trond.myklebust@hammerspace.com>
References: <cover.1767459435.git.trond.myklebust@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Trond Myklebust <trond.myklebust@hammerspace.com>

When resending requests, etc, the page base can quickly grow larger than
the page size.

Fixes: 091bdcfcece0 ("nfs/localio: refactor iocb and iov_iter_bvec initialization")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/localio.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/localio.c b/fs/nfs/localio.c
index 611088ec5a99..c5f975bb5a64 100644
--- a/fs/nfs/localio.c
+++ b/fs/nfs/localio.c
@@ -461,6 +461,8 @@ nfs_local_iters_init(struct nfs_local_kiocb *iocb, int rw)
 	v = 0;
 	total = hdr->args.count;
 	base = hdr->args.pgbase;
+	pagevec += base >> PAGE_SHIFT;
+	base &= ~PAGE_MASK;
 	while (total && v < hdr->page_array.npages) {
 		len = min_t(size_t, total, PAGE_SIZE - base);
 		bvec_set_page(&iocb->bvec[v], *pagevec, len, base);
-- 
2.52.0

