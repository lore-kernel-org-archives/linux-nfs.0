Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827255;
	b=RgRhp2BFe/221tr53/arlfm7NLfT8CXFc6idpspyWAqEBxvPu5OLpv959jC5OfsPZz5r
	 i0Nm/6vw0A6WgkuRxP+IZO2+bkCzieqIXAh+EFyC8dBVNSvYxSCluSSGwElqfMkZ0+TbN
	 Cetf5S4PQ6OjpyfBq/rNw7tsnr8PuHVCd3DueO5vca2eucUVbcKwo9zd4I5zYtauuaKXU
	 DMlLzuLCxMoV8FLWSFb6cD9UlLKvx0IVOPyNKIeG9LFdfzfooGf083dLDsFAj8zBM4oRa
	 fGCqLIGyTqKZ/myawk4e7mrSDGXz/3mtLrrKIsbOMJ2eSS3C9szrzEvxaIzbIWq6kaQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827255;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=unDyG99Rc2/QnFjGnYYD038yieUDExHdgCgrjykz2ZY=;
	b=CwE8T3h+ah9N6RLkJBSHuq/ZTOwicQclyufmyyuw1pSA4l0wCIcORjH7ig0wQR5J6TDL
	 z8bFvJEDQbPQmMd43IuRNVpsPahP0jvkUwhemjHUBXm3ZCqr5I85QBjv8r7nS8NdeHJq6
	 OsK1eUnfQVXGfl75Kru0+1lRSAGePY3zFEQZn/zuA7f8olRDMDmPXxnU83Asn1ZTC8MT4
	 8dW8t7Y9XD56xE0IbYLK110SVttT2Oy2Hte84aHbbOSmkr1oIaBrqFyq2C0O2d6Pu12+p
	 nIoYDYI5MtXQQ77rhp1IvugU7mF3WmjVQmZjpcEUGfA3jKe4g0aNJIBRHYThqSfXkrQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=i6Pqa6AK;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EBEF56073C53;
	Mon, 16 Nov 2026 11:07:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=i6Pqa6AK
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 22F1A1F000C6;
	Mon, 16 Nov 2026 11:07:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827254;
	bh=unDyG99Rc2/QnFjGnYYD038yieUDExHdgCgrjykz2ZY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=i6Pqa6AKqSvC4ebvXTzRd7oi7aJBBmSogD2MCZUz+Gnyciubja82o8kqkhXx7dmbJ
	 YZ3OFzxMqg5vhnUqEdYWnGqrDZ2761QlIJx4ugYu46+wc79S1rLXYRAojCd2F8EJPv
	 rWtXzwXgonLmkOAYpmxDxXhGHf+SRv06DZqPMXss0nKRguX50b8hr52CXLrvIrsQJb
	 R/MzhbgN9X3LeDn2FNzkkLWBu7qU92XxamIU3Wyj+KWteLIrApxDfwLHL4PnSlVBp4
	 4nMXDHWmRdwXEYpIJfXlUPY7gsKx2DcnOYAbzXZIfzq7R9duuuzTBHHeDujfTitnZh
	 SUS1JrRQ5cEaw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:45 +0100
Subject: [PATCH RFC v3 12/44] rust_binderfs: use fc_init_pseudo()
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
Message-Id: <20261116-work-loop-pseudo-v3-12-8cbbea1cf34f@kernel.org>
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
In-Reply-To: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1351; i=brauner@kernel.org;
 h=from:subject:message-id; bh=Se/hTFkDp0LtS3ScLeBDxadBnc0o/SVsPeEgiuoeVFc=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9epyT8M69m8XXMjpjcWzYNVUegbmXD+1dF+byklHpx
 K5cB/M7HaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABPpmcfwP+mi0U8hwxbvvU4l
 Hkm1cav/vpjiVt8euFTLYsOZ/GWeHxgZXjDYxa6vVr+1U1HGOv+SmujnxRGNLG7xKmG5Rrx2IlK
 MAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize binderfs as a pseudo filesystem instead of raising SB_I_NOEXEC
by hand. This adds SB_I_PSEUDO. binderfs_fill_super() keeps clearing
SB_I_NODEV for the binder device nodes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/android/binder/rust_binderfs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/android/binder/rust_binderfs.c b/drivers/android/binder/rust_binderfs.c
index 5f020226720db..04468c5b5c116 100644
--- a/drivers/android/binder/rust_binderfs.c
+++ b/drivers/android/binder/rust_binderfs.c
@@ -3,6 +3,7 @@
 #include <linux/compiler_types.h>
 #include <linux/errno.h>
 #include <linux/fs.h>
+#include <linux/pseudo_fs.h>
 #include <linux/fsnotify.h>
 #include <linux/gfp.h>
 #include <linux/idr.h>
@@ -667,7 +668,6 @@ static int binderfs_fill_super(struct super_block *sb, struct fs_context *fc)
 	 * necessary and safe.
 	 */
 	sb->s_iflags &= ~SB_I_NODEV;
-	sb->s_iflags |= SB_I_NOEXEC;
 	sb->s_magic = RUST_BINDERFS_SUPER_MAGIC;
 	sb->s_op = &binderfs_super_ops;
 	sb->s_time_gran = 1;
@@ -759,6 +759,7 @@ static int binderfs_init_fs_context(struct fs_context *fc)
 	ctx->stats_mode = binderfs_stats_mode_unset;
 
 	fc->fs_private = ctx;
+	fc_init_pseudo(fc);
 	fc->ops = &binderfs_fs_context_ops;
 
 	return 0;

-- 
2.53.0

