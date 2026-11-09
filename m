Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794214195;
	b=TMXZMknhupjSOJI7eg0rSvT2oVp1NwicXSKhg0ZURu73LmDlG5H2viX1gdPvpOhQ+OJ2
	 sN9pVhX7/LnLrgM0MgeS69vjCiFfqWi6jWSrdTud6tUlZ9XwXPLMoNJ/H/5JPfCMYPLQ4
	 uQeLMKVh1VY2shFxqFAikHEFJmF2wImuGKLEXgomWizYtqnZ7Q8I50ka1CA6bVXxe+sXy
	 wmNg4IOjUEWF4HHImcPM56cg2zH1FZxs3PkNxj6fmGcE0Nn/SqjppDrcLiWxh38VNL9Ii
	 sn8LoVkv3tkOzq3FCqCiTP4rDmBxSaDtH28R6zFYwP/epoXPKtg8V8cnzT2mRdmLmow==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794214195;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:From:To:Cc:
	 Subject:Date:Message-Id:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=HQ35mHfqr5BP8Q6j3XzqWeTinQG71M7XJLfQgHXsqNk=;
	b=Wcsr7TXaXbG7tj5RutPL8MpIvbfbxO3fHKWjzSSqTZaeIS+86fivud4nuzn59x0iyWvs
	 mUvbK6/W/vEJvn+somH2vmpKZrsQShAUUMlIvzyZbs9mZtV2CqYuQXNzXv/6Dr6kT0LM1
	 TzcUh4f4I1CSHLa7o+PGF4W2ZtJ/F2fogLqz4YfJ+AW5t+dxkiqOzTOwvHPfjHcVK57Zh
	 O0gMTtToL5T0Ik1LSGsULbVuyHMTUqPj54FsUFueq9xDv+DP7jTR55bsu+tzVVMsHr0cC
	 4goj/60L/TJkVqNBQlTqSzeZLuFrwRJZkfZHjLG2u30RQ2PforE5FyTODt32MgHhASQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=uq8XmEk+;
	arc=none smtp.remote-ip=115.124.30.130
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com [115.124.30.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 924D8606D825;
	Mon,  9 Nov 2026 08:49:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 924D8606D825
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=uq8XmEk+
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1794214188; h=From:To:Subject:Date:Message-Id:MIME-Version;
	bh=HQ35mHfqr5BP8Q6j3XzqWeTinQG71M7XJLfQgHXsqNk=;
	b=uq8XmEk+daPltY+282MUkEKxL9N2QtaK9hJgNfT/ArHWTsQp89eAkLR50cjgNSZnmCEtSaqTBk6DMXeEvW6q+u/CFEdXEfiAcs8AP9m/CoqBGA1M+2cGyRUPkXi1zqP0JcNnqN9DLa2Y1W4fiDCl2yaepH0Gb/QXgPt8D+YtZUo=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R661e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033037033178;MF=joseph.qi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0XEMNcY3_1794214187;
Received: from localhost(mailfrom:joseph.qi@linux.alibaba.com fp:SMTPD_---0XEMNcY3_1794214187 cluster:ay36)
          by smtp.aliyun-inc.com;
          Mon, 09 Nov 2026 16:49:47 +0800
From: Joseph Qi <joseph.qi@linux.alibaba.com>
To: Sasha Levin <sashal@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: stable@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Joseph Qi <joseph.qi@linux.alibaba.com>
Subject: [PATCH 6.6.y] nfsd: fix NULL dereference in nfsd4_free_layout_stateid()
Date: Mon,  9 Nov 2026 16:49:32 +0800
Message-Id: <20261109084932.3861080-1-joseph.qi@linux.alibaba.com>
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

Commit d12af460df27 ("nfsd: fix BUG_ON in nfsd4_alloc_layout_stateid on
racing delegation revoke") replaced BUG_ON(!ls->ls_file) with a bail-out
that calls nfs4_put_stid() on the partially initialized layout stateid.

nfs4_alloc_stid() leaves sc_count at 1 and nothing takes another
reference before that bail-out, so the put runs sc_free, which is
nfsd4_free_layout_stateid().  That function uses ls->ls_file
unconditionally, both for vfs_setlease() and for nfsd_file_put(), and
nfsd_file_put() does not accept NULL either.  The new error path thus
turns the race it was meant to handle gracefully into a NULL pointer
dereference.  The nfsd4_layout_setlease() failure path that already
called nfs4_put_stid() was safe only because the BUG_ON guaranteed
ls_file was non-NULL.

Upstream does not have this problem because its destructor goes through
nfsd4_close_layout(), which tests the pointer before using it.  That
helper came in with the admin-revoke series, which is not in 6.6, so
just add the NULL test here.

Fixes: d12af460df27 ("nfsd: fix BUG_ON in nfsd4_alloc_layout_stateid on racing delegation revoke")
Signed-off-by: Joseph Qi <joseph.qi@linux.alibaba.com>
---
 fs/nfsd/nfs4layouts.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index bea7513a0de90..7c3f0948a610c 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -168,9 +168,13 @@ nfsd4_free_layout_stateid(struct nfs4_stid *stid)
 	list_del_init(&ls->ls_perfile);
 	spin_unlock(&fp->fi_lock);
 
-	if (!nfsd4_layout_ops[ls->ls_layout_type]->disable_recalls)
-		vfs_setlease(ls->ls_file->nf_file, F_UNLCK, NULL, (void **)&ls);
-	nfsd_file_put(ls->ls_file);
+	/* ls_file is NULL if nfsd4_alloc_layout_stateid() bailed out early */
+	if (ls->ls_file) {
+		if (!nfsd4_layout_ops[ls->ls_layout_type]->disable_recalls)
+			vfs_setlease(ls->ls_file->nf_file, F_UNLCK, NULL,
+				     (void **)&ls);
+		nfsd_file_put(ls->ls_file);
+	}
 
 	if (ls->ls_recalled)
 		atomic_dec(&ls->ls_stid.sc_file->fi_lo_recalls);
-- 
2.39.3

