Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793686624;
	b=1WIJPjDkkNIBm0SNIUG9lVrULQSWI/DO070CnMeaE6keehB5DPtMQ0vkUvdu9RZfGKHV
	 R33CWvMA2m04KfhuEOUpH1nzKt5yJll6yYJfAQgj4K/NHmFreWLud6Ty1cFKTuMN8prA2
	 OZFH3MaAJFmZwXnIDilqYn4LlMIZrXLHb0pusQyJlFTJAEwRYgfRhxajV5o2qxmyIzTpq
	 m65PFvfO42JgEazPeGS+FKpNpvSlyjzdyTt1eaASzjgrrNCqmglu8vJ9tVOWkJWnHC7No
	 ssZneCmlB+jtYwJzOVH8PnE8C8fEVmndbOuJWOS8/nF6GcRudAQyPjnNNh+hYpTtFSw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793686624;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:From:To:Cc:
	 Subject:Date:Message-Id:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=AumhV/mE85glrOQoyQtkvOPCNN0t4IP4SAVM09UfDEQ=;
	b=1FrBvHT9VY5fyH2OYB9Eekdi4LJwrDF/QHjYd4amhH8AIo64m7ku4eAoLL4GTf8Q+qiZ
	 e78olVHR3sGgFvKzH+JvBFakQwKKzQJ1Nqri7G4Ua5UoKzqZi/AGIPMBp2HrFqdVAUJRs
	 b/UGUEVteIIjwunhtlcdMQZaKHB1VWnL9mItiIOf+MihE4o8MYcF1+cVR2d5BdsTVdQgL
	 32vo99UgvNmViK4sFsLagJJ/kfbm1701bfCM1yo5YNQvdyOSfwPsRz/O1M6T0rv+nANW/
	 EfzSlBk8sSn5nALi9TNk0+DHme4Xs9ZO6lW3KcahFdp3DHF29EpFreCPsdmUnEvllCg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=X2a5L9b8;
	arc=none smtp.remote-ip=115.124.30.130
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com [115.124.30.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 63960606A336;
	Tue,  3 Nov 2026 06:17:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 63960606A336
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=X2a5L9b8
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1793686615; h=From:To:Subject:Date:Message-Id:MIME-Version;
	bh=AumhV/mE85glrOQoyQtkvOPCNN0t4IP4SAVM09UfDEQ=;
	b=X2a5L9b8KueRVxnSaSeKmKNcYwH9sVyJsir1ViKzw2Ve7kiuF3UZGy9WT3i/P4q8BYH4yR4Uzh0QT7e5FP5pGdxmNib6IrDJ06nRKrOHeVSvdGu0jjS7ZTyC+xjbz20cuEoE3aE03zeINSAsLfxmiQoTHzufjcpJPclC5dSGHT8=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R161e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033045098064;MF=joseph.qi@linux.alibaba.com;NM=1;PH=DS;RN=4;SR=0;TI=SMTPD_---0XE1iYim_1793686614;
Received: from localhost(mailfrom:joseph.qi@linux.alibaba.com fp:SMTPD_---0XE1iYim_1793686614 cluster:ay36)
          by smtp.aliyun-inc.com;
          Tue, 03 Nov 2026 14:16:54 +0800
From: Joseph Qi <joseph.qi@linux.alibaba.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] NFS: don't raise i_size for DEALLOCATE in _nfs42_proc_fallocate()
Date: Tue,  3 Nov 2026 14:16:54 +0800
Message-Id: <20261103061654.2036827-1-joseph.qi@linux.alibaba.com>
X-Mailer: git-send-email 2.39.3
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

_nfs42_proc_fallocate() raises i_size to offset + len on success, so
that the cached size is not left stale when a delegation blocks the
post-op attribute refresh.  The helper is shared by all three
fallocate modes, but DEALLOCATE always carries FALLOC_FL_KEEP_SIZE
and never extends the file on the server, so punching a hole that
reaches past EOF now wrongly enlarges the cached i_size.

The post-op update would normally restore the size from the returned
attributes, but nfs_update_inode() applies a differing size only when
no delegation is held, and then only when no write is in flight or the
new size is larger:

	if (new_isize != cur_isize && !have_delegation) {
		if (!nfs_have_writebacks(inode) || new_isize > cur_isize)
			i_size_write(inode, new_isize);
	}

With a concurrent mmap writer (nrequests != 0) or any outstanding
delegation, the shrinking server size is therefore ignored and the
client keeps reporting a file larger than the server has, in violation
of KEEP_SIZE, until some later revalidation without writebacks happens
to fix it up.

Skip the i_size bump for the DEALLOCATE procedure.  ALLOCATE (mode 0)
and ZERO_RANGE (which nfs42_fallocate() accepts only without
FALLOC_FL_KEEP_SIZE) do extend the file when the range reaches past
EOF, so they keep the update.

Fixes: 35168eb947f2 ("NFS: fix eof updates after NFSv4.2 fallocate/zero-range")
Cc: stable@vger.kernel.org
Signed-off-by: Joseph Qi <joseph.qi@linux.alibaba.com>
---
 fs/nfs/nfs42proc.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index ab86246fc364f..914499d30d47e 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -84,7 +84,16 @@ static int _nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
 		loff_t newsize = offset + len;
 
 		spin_lock(&inode->i_lock);
-		if (newsize > i_size_read(inode))
+		/*
+		 * DEALLOCATE always carries FALLOC_FL_KEEP_SIZE and never
+		 * extends the file on the server, so only ALLOCATE and
+		 * ZERO_RANGE may raise i_size here.  A wrongly raised size
+		 * can persist: nfs_update_inode() ignores a shrinking
+		 * post-op size while writebacks are outstanding or a
+		 * delegation is held.
+		 */
+		if (msg->rpc_proc != &nfs4_procedures[NFSPROC4_CLNT_DEALLOCATE] &&
+		    newsize > i_size_read(inode))
 			i_size_write(inode, newsize);
 		nfs_set_cache_invalid(inode, NFS_INO_INVALID_BLOCKS);
 		if (nfs_should_remove_suid(inode))
-- 
2.39.3

