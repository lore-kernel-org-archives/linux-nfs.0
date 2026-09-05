Received: from m16.mail.163.com (m16.mail.163.com [117.135.210.4])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5BEBC37F32C;
	Sat,  5 Sep 2026 13:30:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=117.135.210.4
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788615076; cv=none; b=UWe+FCsIM8vS7pvjXimOPzVW0MLrzY2yjL+oB0hoDeQ+sBB2Xl04OAHQKJSxhTw6S1zph4aCi9CC35zV29b5hvvg0mCMUFyLHeoTDrHvFcF2t7McJqn7b8EMDqe7jtPdo38iZ1ST8FSGzv92ZiBj4kEw1diwUPhEA0asBC9vu3c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788615076; c=relaxed/simple;
	bh=TyaZnyY/ueZ21f+Uao2cG0EK7Chzq/fDjWdEebhl+AQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=YjRnhYuYY8TXcVI4ZBu0czYTByIfJ9x+nc1JSmPQs1hgvahHiLaRotepN19KdVpcZ2NaagazH/DD3nSRImMTVsZMo4fAroiLYvP2bIUSGuMVGZfHWdgEDtvhrsFMrQlQY+8oZ4qvzRz/gLFwhnhP4CKwl5InQaOgZ5ID+SV6lmM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=163.com; spf=pass smtp.mailfrom=163.com; dkim=pass (1024-bit key) header.d=163.com header.i=@163.com header.b=g9DTS0Me; arc=none smtp.client-ip=117.135.210.4
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=163.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=163.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=163.com header.i=@163.com header.b="g9DTS0Me"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=163.com;
	s=s110527; h=From:To:Subject:Date:Message-ID:MIME-Version; bh=3K
	eZgPT53Vj6jbWzVZV9sr6Em5nWk6EECHyu2Iq6y+4=; b=g9DTS0MerFwmyr4/8G
	7aM8mqVbMfCs3fwbP/I0zc4ZxT5rp48KuyigaYEZgea+twKST0OhGn7anpXqg9vo
	rbpY/E2jwtOcQWLBnuCJZ8JNG83lwbRI3vjc2Ncx7MB6FsGmnoT51M/pP8vNmBSH
	ST+OKwUveDJpJpV4Yb9zygJnU=
Received: from localhost.localdomain (unknown [])
	by gzsmtp4 (Coremail) with SMTP id PygvCgD3ySVzGZxqDZWdQA--.45953S2;
	Sat, 05 Sep 2026 21:30:28 +0800 (CST)
From: "hpp.iscas" <hppiscas@163.com>
To: Trond Myklebust <trondmy@kernel.org>
Cc: "hpp.iscas" <hppiscas@163.com>,
	Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] NFS: enable pNFS verifier clearing for modular NFSv4
Date: Sat,  5 Sep 2026 21:30:25 +0800
Message-ID: <20260905133025.63239-1-hppiscas@163.com>
X-Mailer: git-send-email 2.50.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-CM-TRANSID:PygvCgD3ySVzGZxqDZWdQA--.45953S2
X-Coremail-Antispam: 1Uf129KBjvdXoWruFWxKrWrXr4DWw47WFy5twb_yoWkCrg_uF
	48KF40gw4Utryvg3WfWa40vrykZ3yrGr1fW3yrtryYkrWDJF98Z34kXr18XrZ5Wr4j9FZ8
	Cas2qFyayryxKjkaLaAFLSUrUUUUjb8apTn2vfkv8UJUUUU8Yxn0WfASr-VFAUDa7-sFnT
	9fnUUvcSsGvfC2KfnxnUUI43ZEXa7IUbPku3UUUUU==
X-CM-SenderInfo: 5kssx2xfdvqiywtou0bp/xtbC7hQl7WqcGXRNgQAA3l

CONFIG_NFS_V4 is tristate. When it is set to m, CONFIG_NFS_V4_MODULE=0D
is defined instead of CONFIG_NFS_V4, so the current #ifdef selects the=0D
empty nfs_clear_pnfs_ds_commit_verifiers() implementation. Direct-write=0D
rescheduling then leaves the data-server commit verifiers unchanged.=0D
=0D
Use IS_ENABLED() so the clearing helper is compiled for both built-in and=0D
modular NFSv4 configurations.=0D
=0D
Fixes: 7537db24806f ("NFS: Merge CONFIG_NFS_V4_1 with CONFIG_NFS_V4")=0D
Signed-off-by: hpp.iscas <hppiscas@163.com>=0D
---=0D
 fs/nfs/internal.h | 2 +-=0D
 1 file changed, 1 insertion(+), 1 deletion(-)=0D
=0D
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h=0D
index abc81f5..11256dd 100644=0D
--- a/fs/nfs/internal.h=0D
+++ b/fs/nfs/internal.h=0D
@@ -643,7 +643,7 @@ void nfs_pageio_stop_mirroring(struct nfs_pageio_descri=
ptor *pgio);=0D
 int nfs_filemap_write_and_wait_range(struct address_space *mapping,=0D
 		loff_t lstart, loff_t lend);=0D
 =0D
-#ifdef CONFIG_NFS_V4=0D
+#if IS_ENABLED(CONFIG_NFS_V4)=0D
 static inline void=0D
 pnfs_bucket_clear_pnfs_ds_commit_verifiers(struct pnfs_commit_bucket *buck=
ets,=0D
 		unsigned int nbuckets)=0D

