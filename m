Received: from out-184.mta0.migadu.com (out-184.mta0.migadu.com [91.218.175.184])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9241A30C141
	for <linux-nfs@vger.kernel.org>; Fri,  3 Jul 2026 06:55:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.218.175.184
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783061751; cv=none; b=JjF+kQ0QooBPJesURB0HOpFaTIEh7RnyNYLU8loLyKQH9DLdhDqL9VjjlnZ+ah31Vsy2Lt910TzIRuB+TxPZHbPYqN+j+Ua1zNnbjhxJLpbmnr7AV5sNvDwX3vOl0RtYaZMVv60ImoiR9z+F84Q8NYTYul1eFXEhbik3anWvWMo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783061751; c=relaxed/simple;
	bh=uzjRBJnAEhuw8XoqI0dy6E42dxTwpn4qnUhAJwve0oI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=CmUri+JSof1ZSbwyrVY/UNM66Hbq/26xR1g/IbT2K5LQaD5csZedVAmcSpnOqEKY9Wa1cdg2y0CqP4774GYMSO6p4BZYRWDz7VAP7hkeS2o4Psm3YYIvzIHyh6dWcby1s+4Lqj0a7TERalMZkcvCBMv1MgkEJbHBFfbtmSMCRlg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev; spf=pass smtp.mailfrom=linux.dev; dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b=i4x1sP4a; arc=none smtp.client-ip=91.218.175.184
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b="i4x1sP4a"
X-Report-Abuse: Please report any abuse attempt to abuse@migadu.com and include these headers.
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linux.dev; s=key1;
	t=1783061747;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=B6lnRtW660sE99Z4H+dJnuRkFvuFoekLxVYU1hHJ6vw=;
	b=i4x1sP4alVeDiO/eKw0xx5bZvi5WrVRsDlRhSJuLy3ULde/+Q6liHQYSDVrC2BuYnOzrPS
	hA0VScNtMCReWdz8GYJu+l62J1Y6PU5xKiVG9m7yxIQ/1h9EqUo2hk78q6yReookjokLI0
	GQIFOq26FpkP82phaWraq3cozofeMmE=
From: zhang.guodong@linux.dev
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	ZhangGuoDong <zhangguodong@kylinos.cn>,
	Jackie Liu <liuyun01@kylinos.cn>
Subject: [PATCH] NFS: Verify symlink inode before caching target
Date: Fri,  3 Jul 2026 14:54:48 +0800
Message-ID: <20260703065448.210255-1-zhang.guodong@linux.dev>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Migadu-Flow: FLOW_OUT

From: ZhangGuoDong <zhangguodong@kylinos.cn>

nfs_symlink() copies the symlink target into a folio before issuing the
SYMLINK RPC.  After a successful reply, it caches that folio in the
instantiated inode mapping and assumes that the dentry now names a
symlink.

If the dentry is instantiated with a non-symlink inode, the raw symlink
target folio can be inserted into the wrong mapping.  When that inode is
a directory, reclaim or unmount later calls nfs_readdir_clear_array()
through nfs_dir_aops and interprets the symlink target as a readdir
cache array, which can lead to invalid kfree() calls.

A vmcore from a 4.19-based kernel showed the crash when reclaiming a
directory mapping on unmount:

  Stack trace:
   nfs_readdir_clear_array+0x4d/0x70 [nfs]
   page_cache_free_page.isra.35+0x1a/0x90
   delete_from_page_cache_batch+0x1cf/0x2c0
   truncate_inode_pages_range+0x24d/0x910
   [...]
   nfs_evict_inode+0x15/0x30 [nfs]
   evict+0x115/0x2b0
   dispose_list+0x48/0x60
   evict_inodes+0x16c/0x1b0
   generic_shutdown_super+0x3f/0x120
   nfs_kill_super+0x1b/0x40 [nfs]
   deactivate_locked_super+0x3f/0x70
   cleanup_mnt+0x3b/0x80

The current code still has the same unchecked cache insertion pattern,
so it may be susceptible to the same failure mode.

Verify that the instantiated inode is a symlink before caching the
target folio.  If the type is wrong, drop the suspect dentry and skip
the cache insertion while preserving the successful SYMLINK result.

Co-developed-by: Jackie Liu <liuyun01@kylinos.cn>
Signed-off-by: Jackie Liu <liuyun01@kylinos.cn>
Signed-off-by: ZhangGuoDong <zhangguodong@kylinos.cn>
---
 fs/nfs/dir.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2f5f26f93238..d10f060b0b94 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2669,6 +2669,12 @@ int nfs_symlink(struct mnt_idmap *idmap, struct inode *dir,
 		return error;
 	}
 
+	if (unlikely(!d_is_symlink(dentry))) {
+		d_drop(dentry);
+		folio_put(folio);
+		return 0;
+	}
+
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 
 	/*
-- 
2.43.0

