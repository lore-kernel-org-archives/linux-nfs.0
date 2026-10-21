Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552605;
	b=m0bPAe1ZTGzXSaS8rn8zjsWaPee40g1SATdEsbip1OlPq93go3l4CNRttskb23AfPfUu
	 ea4CclGdPR84DtUNjZ7zvgQeV8pmU2OXv2lNAGF+RRD96p9FJkxBQpFvubAIQOn9Sgag+
	 KZy5lKk7/4LIqBtiOoc4gswkGHTJWQ/vZQRyywXSGYKmZnA8PP9MOAn3D2NHcaWkzXP1F
	 GZ+ilIEbReCeSQk3r4zUb2cZfGkR8ved8xO8wLwvx1n1xHY8qgAtYye+sJGss+FECUJzy
	 n6UIQ4dZOoRZSO7SkdI1NFqHXaD0B13MdgKvB7A2ADn/HxpwNHfqiBEP5JJISkwfKfg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552605;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=b/cbiQJQzWXLaVB0xBpgY5Fvm7PNJan0+Yv/Hncy3sc=;
	b=nLnxRlT79KojHHe3AhQG/z/ffTi881q+TPI2i5MmM/ymXaQtHkjykOmLWrPt2PG6HTLj
	 GeYyVX9DtN0jyDusJM40fGD8gOy8k7GQui5VDi7jlcDwny8Fd1T4e+YSH5B2y2b5S92nu
	 qxY9tgT5GQRBx1Q9vUTXt0PQ4Z57NYv2QG5ABCuP1qbaN7qhfkcVulh6cTer7RH4gJj/C
	 OEowR28ecXzsKPB2t7yZu3FfwcEBUPEmX6AvI1n2JGzHUp88E7UZFSOsxVQacEUAbR3cc
	 XZrbvyDfsB8NfwBLHsQwGLiV5xspArCnCDRPTWhJxfmTCncIVROQWXXKWqypHEpFx0A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=YU1z9jn0;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F00D8606FBB9;
	Wed, 21 Oct 2026 03:16:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org F00D8606FBB9
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=YU1z9jn0
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552603; bh=ZpB72hOxo13AVN60LCQh2zwdsFnGm2EEA7sXgnOHfcE=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=YU1z9jn0q27TAI0GPSx+LGY5/GXeiEE9rxO9LzF/EzFl63eTZMiAgUGzLnQkd84uY
	 VbHWrftx6+pLCMm9hHtlOMF/8kGV77Eyp8919Uv3f7HV4G1ErXuyH64ZINuNu1Srjs
	 DMwBUaLDiYk1hYBLB8Iut66kaeo4f71Xh4W3HXULlgJ7e3g2tPlHddFQ1c6ldpqabP
	 cX78GmQm69VlrxTcpM3bk4EjUA8PS+v0cbz4B8E84J/sQtuugsosxZLIGkvL8eWFeI
	 jxxikAw8Xwjo1wTlgyacHmlMafaGpJOxbHTA0VC+VJzbk9Qt7FVpeYSCXN5WPbB9dT
	 SZ0CK6SyEfUuQ==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 7ABF68A08F6;
	Wed, 21 Oct 2026 05:16:42 +0200 (CEST)
Message-ID: <262bea3af5bc330d6ffa07fa1c6feb76a1a52609.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 24/41] shmem, ramfs: allow UUID and GUID owners
To: Christian Brauner <brauner@kernel.org>,
    Alexander Viro <viro@zeniv.linux.org.uk>,
    "Serge E. Hallyn" <serge@hallyn.com>
Cc: Jan Kara <jack@suse.cz>,
    "Theodore Y. Ts'o" <tytso@mit.edu>,
    Paul Moore <paul@paul-moore.com>,
    Arnd Bergmann <arnd@arndb.de>,
    linux-fsdevel@vger.kernel.org,
    linux-api@vger.kernel.org,
    linux-security-module@vger.kernel.org,
    linux-arch@vger.kernel.org,
    linux-ext4@vger.kernel.org,
    linux-nfs@vger.kernel.org,
    linux-cifs@vger.kernel.org,
    netdev@vger.kernel.org,
    audit@vger.kernel.org,
    keyrings@vger.kernel.org,
    linux-kernel@vger.kernel.org
Date: Wed, 21 Oct 2026 05:15:44 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

Both keep inode owners in memory only, so they can hold any kuid_t.
Set SB_I_UID_R. Quotas of tmpfs don't account such owners.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 fs/ramfs/inode.c | 1 +
 mm/shmem.c       | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/fs/ramfs/inode.c b/fs/ramfs/inode.c
index 0a88ede48e..510dc2a78f 100644
--- a/fs/ramfs/inode.c
+++ b/fs/ramfs/inode.c
@@ -269,6 +269,7 @@ static int ramfs_fill_super(struct super_block *sb, struct fs_context *fc)
 	sb->s_op		= &ramfs_ops;
 	sb->s_d_flags		= DCACHE_DONTCACHE;
 	sb->s_time_gran		= 1;
+	sb->s_iflags		|= SB_I_UID_R;
 
 	inode = ramfs_get_inode(sb, NULL, S_IFDIR | fsi->mount_opts.mode, 0);
 	sb->s_root = d_make_root(inode);
diff --git a/mm/shmem.c b/mm/shmem.c
index 848316eaa7..b54775e0c3 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -4988,6 +4988,8 @@ static int shmem_fill_super(struct super_block *sb, struct fs_context *fc)
 	}
 	sb->s_export_op = &shmem_export_ops;
 	sb->s_flags |= SB_NOSEC;
+	/* owners live in the inode only: UUIDs and GUIDs need no format */
+	sb->s_iflags |= SB_I_UID_R;
 
 #if IS_ENABLED(CONFIG_UNICODE)
 	if (!ctx->encoding && ctx->strict_encoding) {
-- 
2.56.0

