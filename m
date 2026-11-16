Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827225;
	b=Mi1CQDGTGQ048qMttMBLLTVKH1CqEgz4DFlSt6MNPQIZc6UYnbKNtE5wc+n/8myZmMTI
	 qlyE93enOLCJNBOylHCaFmdBtGcMV8rEePRySvEsRzbYxBXktfV99jKSZskQqt84EFGfB
	 qhZrSN6qV/MeH7Zt9rsHsqpNkDGhZMsx2wv9CAwqi4Soa1XnSCTWxXHu/pvYcDOsBYFjI
	 lljN6Zn1Oaz0OnzSTGrVS2ThUcWYj4Fvhfyxfvoqsu3/YmY6uf+/R7fIxvSuzLu5rba3g
	 ciexU/am6bxk0V8simheE8NlzYKn3BP/K3r4sYvmMTtz4FcXpFspfShGBn2+yNV6ylA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827225;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=ZjUZ/LbyySofwJKchunYgmcW+hv6mWM9r+0t30zrAC4=;
	b=JVZZrd4KFUAmo4fQTP+Y7uq3JtW7bol8o2jazH40NGyI4qBPa1MvCBzBdrHE9Jfft7w6
	 CUeaHM6yG1JwyiuDAZrn3L/01wHsit/Dg9gBnXMzMLR6I2fRmMFCxHew//Kqrv/CbG5MQ
	 hTh8gqeNHtCfAPFVrpEpwpjWi+2y/V6KEDAt+VVH622uhLnKF/NF6YlTj2tx5ZK0PUH6f
	 3ubt6o5mIhLlyRHxO4suLA5iBIBSUSWC5y/rzEWsmmLJ2xaTRGr/K58+wq+6jAM+mX5vD
	 TchO2/xiTtoSpHEWw4a9XBK4ryIOJQWMVlW0Di1EOjD+g7sVPN9Lt/NrJW7iyZ1UV4A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="jk/FjUy0";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7EB63606A891;
	Mon, 16 Nov 2026 11:07:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=jk/FjUy0
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 59EBE1F000CC;
	Mon, 16 Nov 2026 11:06:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827225;
	bh=ZjUZ/LbyySofwJKchunYgmcW+hv6mWM9r+0t30zrAC4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=jk/FjUy0cS6GgqVt9SsPloY8k3i4CqrkgFOMuEfM9XpfG/P/xdaYstLnK6As2uWUx
	 DEasrHPORlAiJurUDvkuRuudCdX4+089Oc2tRistqib9WEwQ5lBrReoBhl8MhZJbHr
	 l6aBHu8foX0BKN0F6xwxKuR1wHN/HENZS+AdFP226DO8djRCuCN7EcShhykNWGeUfv
	 2qReXmfM4j5HwLrmWLj8INf6brOXbWCkQPlzkcCvyFZ79G4NtpxPZuc+Bt5iZoOrkI
	 QVXW8/XVnBthjiWRTNhaVer+CxRfjJN9ob0t6JGwEOzJgRSBms1wlYdaktJYkpCcpN
	 a/EAYoQOnhFDQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:41 +0100
Subject: [PATCH RFC v3 08/44] mqueue: use fc_init_pseudo()
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
Message-Id: <20261116-work-loop-pseudo-v3-8-8cbbea1cf34f@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1349; i=brauner@kernel.org;
 h=from:subject:message-id; bh=eUpb/5VRc6uGUB6tbJ3+67OknD2n3CMn6o+Ub0d1Knw=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9epzhGiew20J0pdn/rc+br7ncYiy+qrz264M7t5VXX
 HtelL34bkcpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBESi0YGV5Vvm5S2zypdNU1
 0asTlm32TIpeYct0smnHH95QyWeSPuEM/x1bNttw/OG9Ib/orjXbnP81Nr9VO1SydlbPvJgivPC
 LNT8A
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize mqueue as a pseudo filesystem instead of raising
SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Reviewed-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 ipc/mqueue.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index 322c3dd98c447..8bbe32d0881f2 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -18,6 +18,7 @@
 #include <linux/file.h>
 #include <linux/mount.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/namei.h>
 #include <linux/sysctl.h>
 #include <linux/poll.h>
@@ -405,7 +406,6 @@ static int mqueue_fill_super(struct super_block *sb, struct fs_context *fc)
 	struct inode *inode;
 	struct ipc_namespace *ns = sb->s_fs_info;
 
-	sb->s_iflags |= SB_I_NOEXEC | SB_I_NODEV;
 	sb->s_blocksize = PAGE_SIZE;
 	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = MQUEUE_MAGIC;
@@ -457,6 +457,7 @@ static int mqueue_init_fs_context(struct fs_context *fc)
 	put_user_ns(fc->user_ns);
 	fc->user_ns = get_user_ns(ctx->ipc_ns->user_ns);
 	fc->fs_private = ctx;
+	fc_init_pseudo(fc);
 	fc->ops = &mqueue_fs_context_ops;
 	return 0;
 }

-- 
2.53.0

