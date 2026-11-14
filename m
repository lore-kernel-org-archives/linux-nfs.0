Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661600;
	b=prYJBHRN3VceFXmP6ziQsr3dwWNUcjvK7KBg8kYtH9dNYHuNPcM51g8QG5bl3fI6cyjl
	 dIn2awP3FcsmhcLuTz8H+PVzm6HYWqSSWDxX8A18Xg9bl51R7fxop1HU9FM9uffP0P2yL
	 In/HLZS3Yf5eAHDPSmnz72rR7xO4Po5Yn5a8RUHLR6lwD8gWssKbkEVQTvNtfgkQCK6Vq
	 ge9b2FttA9y2wygQVala66TsZrO4WbRPr/LjtNgc7q0PNwnIBGv6FGzQk1v9LW6OPuMLJ
	 BRLD9w3bgDQu6Q9itBAdnuXKAO9JbCVAvX54Dlnd7lx0EuyxUDQdz6tTvVr2sMxKdRw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661600;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Acb/Xrf5UEvLQ3qZblXZEvLF8dI3PWAoA3H4K2Drtr8=;
	b=Z9pCh+u+5jcbdEa8G9YImj3dJW9DCGiXDcKfWc+/yK8pJdnEd4gs0Ow66r28CvIDjFYW
	 m4SJOEgtTxU74AW/lUdwzi/X36GwGF3yM2h7i+4hBF7xGi28w6cGHQZ/wh2zJo/odXjuC
	 QdSnd5edr1iNwj/JMvvnBlqHvj2Kj3rK0YAkxezekj4uKRUzEvlwxziUNCR2QGICnDQQP
	 GKP5zaVvCashTCFcu8vQdik0yHQNR00VFgaoLqeBY1x7Ikp5kpdeXfB2L1QQlWkvNoHW5
	 JvAq7cp4KlzlofKceMDYm/QlIE+Fd3kYRnxw4Q1fIpyPZeNWpCC43rMCVB6N5prBG0g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KyNtY6FC;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 34D84606A8A4;
	Sat, 14 Nov 2026 13:06:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KyNtY6FC
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 646751F000C5;
	Sat, 14 Nov 2026 13:06:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661599;
	bh=Acb/Xrf5UEvLQ3qZblXZEvLF8dI3PWAoA3H4K2Drtr8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=KyNtY6FCF87BGL6Kw/0+nFiSNhII6bCQoi1XcgNkkdx5QnSLvOmFeUx+1Gzw6qx6W
	 8qfU1kxc4TxMYaN7FiDkUr2M3uz6BLbF+u3v/FDkuwPjs/jbG+c9zGvRkTjFJmEjiL
	 8JS1ZHT8JFf+5Nw1nJtiYKkLg72hoVlMsqVfMy3CtWoGP4sQd8ckfZhFir2N8shzIj
	 rbapZY7d9iip7viefelICnAUIpwFJjRrBSAisiXulqRLGKF7pcgO96Dpzy48VQDU+9
	 fXRynAzshbd784aJhyQ+BI+MHkoqrwcw09i4frlx5HrLz+z7BB29FpUtgvajAYU8kx
	 5ZLHrcpkiH2sQ==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:01:50 +0100
Subject: [PATCH RFC v2 09/42] bpf: use fc_init_pseudo() for bpffs
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
Message-Id: <20261114-work-loop-pseudo-v2-9-98639a2286fb@kernel.org>
References: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
In-Reply-To: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
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
 Alexander Mikhalitsyn <alex@amutable.com>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1306; i=brauner@kernel.org;
 h=from:subject:message-id; bh=RMw1xl23FNzYnwkWPo3aqKCop8QxJMPcn/mgOSyUY0w=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iMnP/Sqt8ZKlWW/DquWr7Q+27feurNp59XxZz58a9
 18b4yU7OkpZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACZyeTYjw/USkxUJXYnv5D+F
 7fy6Msz9i+c5yYvtTRpVx5rmBdWU3mP4n7mJ5axYzdeTT2Z2JT67oLhnXfTECV2TncN/ctca7o3
 3YAQA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize bpffs as a pseudo filesystem instead of raising
SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 kernel/bpf/inode.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/inode.c b/kernel/bpf/inode.c
index c6f328e4752e1..57cf3775c0766 100644
--- a/kernel/bpf/inode.c
+++ b/kernel/bpf/inode.c
@@ -15,6 +15,7 @@
 #include <linux/namei.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/fs_parser.h>
 #include <linux/kdev_t.h>
 #include <linux/filter.h>
@@ -1197,8 +1198,6 @@ static int bpf_fill_super(struct super_block *sb, struct fs_context *fc)
 	sb->s_magic = BPF_FS_MAGIC;
 	sb->s_op = &bpf_super_ops;
 	sb->s_xattr = bpf_fs_xattr_handlers;
-	sb->s_iflags |= SB_I_NOEXEC;
-	sb->s_iflags |= SB_I_NODEV;
 	sb->s_time_gran = 1;
 
 	inode = bpf_get_inode(sb, NULL, S_IFDIR | 0777);
@@ -1261,6 +1260,7 @@ static int bpf_init_fs_context(struct fs_context *fc)
 	opts->delegate_attachs = 0;
 
 	fc->s_fs_info = opts;
+	fc_init_pseudo(fc);
 	fc->ops = &bpf_context_ops;
 	return 0;
 }

-- 
2.53.0

