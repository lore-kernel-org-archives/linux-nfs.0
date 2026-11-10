Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302240;
	b=RQZGyuUUGMxugwnNK6vOpQ7E3wZxD1CNqeNWLe8WYWr/FpLGS2qHugwB/TFSN3wxRh6O
	 GA7svMLNrmf2mzZtqUt6m3Uh9SCqKU7KyBC2sxG1tCKrmtm4jpaGhriE/JRhJxrwte/2d
	 Eu91ueDmiuP9j7NL/LmWyI3o8qFLILeAvBCMs65zjmWSD95IXxERB/1PGTC8fVS/yhYbj
	 T2gyAQdClpZAL4hwhd639c2AD0CcgzCzAzd7lzovhugxCxUvZY/J1MXH1kXGv42ZteDDy
	 p2O3ymfJP1g7+kw1ufXYOdvRGIC/7awS5Gft04sGdvWN5w32hLpONlk0exOFoc8QJqg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302240;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=BDssZE8GnxXJphkJa/7u6Kmpiz0qYyZXv4DcRb36RZU=;
	b=IbjyGDPWRejUa60ukfGkiMp46sdTxA/QevUFwi646UkZBJGwGuVD8PtYEwNwnLcvg8uG
	 OXDjhR4c1CWgkSfZ5qzO6dSZV4IlXMsMpi3jMMBfNgEp4kcsVlxMbye9hpF1+tMzgsKGM
	 jvfkteUa1sMm6NQFY/5lV43xAfJCkreU4b8ZT2mSjt+suHGvRYYnykexAOxLxupAXSM/k
	 ZMkcIy1SJst/OTJqLQRcbXe3EJRKo3e4hT4JhzO3G4cbyesFTZqSkm0F0WFNPOt9lC0HH
	 /1OCaz8LRLJZNq7Bpz+TR4NRb6vywLFQl8PZGRx/2rHu/8Z0ixgezdBydQBiSLicXig==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HZwAEC7y;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4843460A260E;
	Tue, 10 Nov 2026 09:17:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HZwAEC7y
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5F81D1F008A1;
	Tue, 10 Nov 2026 09:17:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302239;
	bh=BDssZE8GnxXJphkJa/7u6Kmpiz0qYyZXv4DcRb36RZU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=HZwAEC7yTB7xRGKnMoMrQZ9sxFhShy/lcUuZ/x28dAQF2zKH4dms8JkefpvImrQ6x
	 XC17RCkuC5DS1kjza0TXcL7CFDfklhb43tkgjYep+m/Ktv9OM8WFbgu+n53zFr0v99
	 oA4dvldcm7IP98DtTd9OniKq7I49xL8jcVtYPn+hdsEuh9403uECXy9gbC3SQ3i3KX
	 69hVJ4ZtgMy9pBNrX3/NQCtI3QLLlYI9QKbR1ljiyee3SOwCPkfnPUCR39DKczXa41
	 B7rewxNEm+xa8FVjYKfML4jkp/JG7IHWJl4xIRYdJ5VcaUC/EIXdXrICC3YYuo9a0Q
	 vQiRwTkVcDJ/A==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:28 +0100
Subject: [PATCH RFC 12/41] rust_binderfs: use fc_init_pseudo()
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
Message-Id: <20261110-work-loop-pseudo-v1-12-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1349; i=brauner@kernel.org;
 h=from:subject:message-id; bh=ia59pqse5bfG3zsSypUZSF6rnakCYrHaj4vJVOgAczE=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erBwbu+MRZLWcXVeu3+t3xy2+WPblfNtxmUPzkxuZ
 kvRVVts01HKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjARzmhGhtUeaQcz2VY03m2x
 8X+zz3bz86e+3F0Sc0+/XnSvs/WJ/nKGfybCIVeWvGvzeXz9a3rPAre2kNeaOolzS/+H7js9+Wh
 DJgsA
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
index 5f020226720d..04468c5b5c11 100644
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

