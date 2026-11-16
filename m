Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827262;
	b=i+ISD818VUiknuHuN2pnDQvnUhrnj7pCSf0TsaVuCErXhX0bSGKotCmfJG5Xh6qox60L
	 xBsjRAxitReyT5o5CfQ4cGaZG9sznUNaq7rLJI+MRRWNOByN4bUSKG86EyTvn4xfL1Iya
	 OelSAtIFAAdjZSeO0b/RQuuMnWODn3VOldv2SaT4isZtl3g2fcAUrnnhNWJKpYf9dNDL7
	 y5z0bHenKH/s2DXgzkl1cNk/f9Jh+kiQJ2vYEaqYUcDWW7NTozzTDtbdQIBTgfHMmXHt8
	 fNft8goExAzgopHZPL5A+ZCHEyvQ0U9+xY7lQptlpXkkF/xFUNWKGgrq+J6KNKF60/A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827262;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=bRo8rafT0SI0ZYIjwSP5s8nuDkHhspwSH2/U5D4Vwdo=;
	b=dFGxC1cmZnSO4n1GemI58omecnIfkK+fSNYgY+ReOQvpdi0Nxw4hbMaTTJXvsHNThiP3
	 AUlYXmlexyCvcTbRjWsxzJnBCWy+xMC4bJ/HRZz3uuw9p26Wo3fEdZcK8wwkZO2Rrvv9t
	 ujvkGli5d5HJ5tpkK+s0ND2ydrMyw0n8hjV43ERq9fL+pJHDbxLIO6j8Ee7U9KwWIFFym
	 1VJkYdNlXGDDVMrZLd8yHVrkIgv2HS27UmNAvEtFFIJw7WnPro9krlsYnxACBvs0/VgEn
	 Jk24JxVkolj3pEN0vuHVDnO7R+5usp4A4KVWlClNj9vjoOivRIosRr3MGt8uwY3iHDg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SYR9TaGr;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D13C0606A8AA;
	Mon, 16 Nov 2026 11:07:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SYR9TaGr
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 22E231F000C8;
	Mon, 16 Nov 2026 11:07:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827262;
	bh=bRo8rafT0SI0ZYIjwSP5s8nuDkHhspwSH2/U5D4Vwdo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=SYR9TaGrdGbZIarQmb7FZiAh3aYqeET1aKxpQildzBF54+XkCs3w2hwe012i9YDNn
	 KwplWWfrUqSG6YeiB4M+R0HFxuvky3aQ6H/xSTFl3YsGJUXt6YKVqEho4Ze+G1tUXj
	 1LBnFF1Tjb5B8Wq8WvTQUAgcpvPTABUb9ZbFJurPQxuPY16ScwtILZqX1vzDRAK0zF
	 WYGfVFRgoNgVMFqCXJGrivTUJE7Uqv9I3Kjf3hFqKNQ0l1/yg7xjQvZGT4y6D6g3Hu
	 GlJP4jytTeb5jsL1OPfVY2sB4N+I4DKQZdsAQ/ckyHlMUVC8NaHv6jRpgn76WWmzBp
	 MIF24A6RZBJQg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:46 +0100
Subject: [PATCH RFC v3 13/44] devpts: use fc_init_pseudo()
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
Message-Id: <20261116-work-loop-pseudo-v3-13-8cbbea1cf34f@kernel.org>
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
 "Christian Brauner (Amutable)" <brauner@kernel.org>, 
 Alexander Mikhalitsyn <alex@amutable.com>, 
 Chris Down <chris@chrisdown.name>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1022; i=brauner@kernel.org;
 h=from:subject:message-id; bh=bmgpF+T0PjaM4BszluBOeRyncWOMZk/p8QFUkfXrwyU=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9epwbMLfmqPHCfTn5hRfrWbZIf8s8rLk06bC0camwg
 mzGq1XBHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABOpFWRkOPz/xJLoOzVBuYb7
 +QSlfCOaZ5lzMH+rzjNdtcfly5aJtxj+552pNBCM1J7apuA9/7a7a/D7lgk6wf0+3lyc19/OLmz
 iAAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize devpts as a pseudo filesystem. This raises SB_I_PSEUDO and
SB_I_NOEXEC. devpts never holds executables. devpts_fill_super() keeps
clearing SB_I_NODEV for the pty device nodes.

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Reviewed-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/devpts/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index bd1e8eb26edb7..47ef12241d92d 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -13,6 +13,7 @@
 #include <linux/init.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/fs_parser.h>
 #include <linux/sched.h>
 #include <linux/namei.h>
@@ -438,6 +439,7 @@ static int devpts_init_fs_context(struct fs_context *fc)
 		fsi->mount_opts.reserve = true;
 
 	fc->s_fs_info = fsi;
+	fc_init_pseudo(fc);
 	fc->ops = &devpts_context_ops;
 	return 0;
 }

-- 
2.53.0

