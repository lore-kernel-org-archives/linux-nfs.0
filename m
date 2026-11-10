Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302329;
	b=3K0FRImGfQKR/EhHjgEdwbZXn+v/5bidSSHrAzzSZpKU14vpASrmH1hPw9clDcgjUkwZ
	 gRMwuqBXo2Mg/wUgx638g4BwBnIk+UX5lXzbv8U3s8XSdpR2M4WG79F/uY+zCrwfMjYux
	 Sy2ysRw6RIdrKx5P3+B7DZts5n66ixA3ZlykRSeNXVjjBtXu8zTkOWHYX1Axem5Ky82Kg
	 LsH0/1VOYrhGbitox6b5uWUs4sRIV6WkpxUznmA5Vp2oUsaDK1I4cfBgTB2QLVUy08sTS
	 aj6R6HNZTSmCfAJqc1G0eRpiRpvVHPc8ymeyWUA+uZ1/QJHQZBSpEjJlOafoRhtXJAw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302329;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=gl42dR2sxHaP3ITJS3b/B04ib5WpCUL9VRtP4KLsRoM=;
	b=mjcUcUYTJkPHWi3k2gYyeklF0pC9W8nKmfLlIGI1mWZeFErqDIgEsFwWcmyvoh8hoiI0
	 hC15Jk8VY9FzjvFv1BBHQ7siwrCPuDUr4Xbsse8GJeljOkxLGVEDHdBs09l6mCny5isT9
	 tMjFICHzQaFM6CgbXYb267iZJ0yDQcmQY0ty5euS7aZl3I8AWCVSay5nZ3URyUYJIvjoI
	 a4JDm1vUClDGI9ungqpFJtEj7mOH4B99g0V1YCg8JiNH712GKgjvYnv1XclnNZKij5shk
	 J28uNe0PJcK7oYHh71JVQ0w8qTMDu3paMmQU5g/cKEn3Zc2dRtGlsKAuwfdmt3uHuXA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kTLpHzIi;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B5B826075028;
	Tue, 10 Nov 2026 09:18:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kTLpHzIi
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 44CC51F008A1;
	Tue, 10 Nov 2026 09:18:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302328;
	bh=gl42dR2sxHaP3ITJS3b/B04ib5WpCUL9VRtP4KLsRoM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kTLpHzIiEoHD/GMs6J5o0BY79JvOwuUY76u4r4LtuPpprEn+sEXP1gtvybcHlSLtT
	 CmJYU8iAHI/ofaZXWihJ5XxShjsnWfKREnaREBGEhVpJuVA8UxIujLE4opfHxMa4l2
	 4bvvQUPUjvQ2EsFdGM14Zv2VXWcqMXokoHGLWd7/ZTwsxC4J9iKJbm5nnnjuBRICkU
	 3Q/oQzewdcDhdx+fyfkGitRE0raCCijhxDU/xYg/eIt2ZjWUYaKm5ljV/gc4aZMDUG
	 Xo7ddzkxLrqw+Yw44oZ3PVfS7jJUGpuyM3cYrfutFlXsGLkg0INiBaZLGiYPLlJfeW
	 ZQQCq/yJeXwMA==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:41 +0100
Subject: [PATCH RFC 25/41] pstore: use fc_init_pseudo()
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261110-work-loop-pseudo-v1-25-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
In-Reply-To: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Jann Horn <jannh@google.com>, Chris Mason <mason@kernel.org>, 
 Josef Bacik <josef@toxicpanda.com>, Christoph Hellwig <hch@lst.de>, 
 linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, 
 target-devel@vger.kernel.org, driver-core@lists.linux.dev, 
 linux-mm@kvack.org, bpf@vger.kernel.org, 
 linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
 apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, fuse-devel@lists.linux.dev, 
 linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, 
 ocfs2-devel@lists.linux.dev, linux-s390@vger.kernel.org, 
 linuxppc-dev@lists.ozlabs.org, linux-usb@vger.kernel.org, 
 Amir Goldstein <amir73il@gmail.com>, linux-erofs@lists.ozlabs.org, 
 linux-kselftest@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=882; i=brauner@kernel.org;
 h=from:subject:message-id; bh=JyexvfbQ5pzTQXeLd6YfvhDNydDQY3kHD9zcB9wbg2k=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erAx2J15TcWtFdu9W+eIHjgye9faLyYyW74GeK1Uu
 /LQcab9to5SFgYxLgZZMUUWh3aTcLnlPBWbjTI1YOawMoEMYeDiFICJ9Nxl+M0aJKtZkDT715G8
 vUqnmxUTdvZHiW417mNNuXFzkjPT9FuMDEfPTDuhOseiqbXY1vy/93S+RZWzPGUXneAoPhv++bH
 pOWYA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize pstore as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. pstore never holds executables or
device nodes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/pstore/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/pstore/inode.c b/fs/pstore/inode.c
index cf499ba72702..4658561cf90b 100644
--- a/fs/pstore/inode.c
+++ b/fs/pstore/inode.c
@@ -18,6 +18,7 @@
 #include <linux/ramfs.h>
 #include <linux/fs_parser.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/sched.h>
 #include <linux/magic.h>
 #include <linux/pstore.h>
@@ -491,6 +492,7 @@ static int pstore_init_fs_context(struct fs_context *fc)
 	ctx->kmsg_bytes = kmsg_bytes;
 
 	fc->fs_private = ctx;
+	fc_init_pseudo(fc);
 	fc->ops = &pstore_context_ops;
 
 	return 0;

-- 
2.53.0

