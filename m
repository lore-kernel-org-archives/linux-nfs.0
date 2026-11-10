Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302212;
	b=UX8+KchCsgabl7+WABiwjxmaPDWaVHMrG8qcUVzYL5KyNpomFBQ1yo3HqTugJzNaJhe9
	 4uarePjHE599ae/3x5C5qCU1z2IBJ4nnPIc7gRACCOArLgy2x+UWcbjFMoTtev2CYLXXp
	 qscnzIdDekY27D2RqCVo+RgHxs88ZzAODHz+z0N/XzhUo9duXZXfdzKOmhq4dt9VMvJ7/
	 3AU7kOoOEgI92+8G5UKPx+80YoeqjyH7clwVOeqvNo18V1WcmjsTMXnT576bkgwV0busr
	 NvlY+91U600016fL3jCBRhbbyPwgVsdQFMNItJJdTY+etAUHHxNymEhd3NFBAXpvTZw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302212;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=rTt9ZODnqMGXt2QPWO0j4LWRDHe8dvGNICyHTYt985E=;
	b=EjhNTgBl2JHOCtXred4uvCMfgww8sFiB7AArD/8Z/gEPGK+Sdfs7E0A49TclsaxSmuQl
	 ZcwnoPNk+U86OBWn879b+jQtGcdgmDWDzx55RM469kaAc0xZsGCPisg0sSBNnRGDUBauw
	 fyEkiP546RZgJh8vDjDAlDfZ+yZ/NlAwaNe5nzenQn6U6/rwOqQ8/+ZfmD3hK3x+LUsnr
	 apnjxktsLhGUca4JCPbSwztWmtU8+OseAvwZnOz1XrCtV300q95KkbKt2NoC5Vmt96jDZ
	 7ZZFO3OLU0TCF527AGYn9/vMoFqGJZ2aRXWfmcwkGePGM+IcloJ9dqrm30VXxRY/tCQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nXwsv5rT;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 96B23606A33C;
	Tue, 10 Nov 2026 09:16:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nXwsv5rT
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C49B51F0089F;
	Tue, 10 Nov 2026 09:16:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302212;
	bh=rTt9ZODnqMGXt2QPWO0j4LWRDHe8dvGNICyHTYt985E=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=nXwsv5rTzvrG122CXPiddOJ0ugXqcsoi/AaGfNNbu7zvGK8mvUz48SAGlBU/zLVkz
	 LooUWqRoN/4S8I3xcJYcAEFNAJv7CmbUQiM+ChF5ZHpfxf63bNo7Z0QdCAiOO59dr1
	 8fhU2KVqLBCjOH3X9bxaSSk/C75cMEo2HD2kESGJ6Y10yT4ZTrwrUuApzZmSmAZkyq
	 7KypYuKqM5Pjoxx7X2T/0YDQPSzhDhTa8yf55w0TWoYWrEVFZ6el7TpOiZWeC8kVq8
	 oCDfcYgrQZNoq58895X8dxus9Cy79YWYO/viOCOJpKnTNCeln3Zt2fAQjdrWaXV2Jd
	 BAdVF5Rtw3JRQ==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:24 +0100
Subject: [PATCH RFC 08/41] mqueue: use fc_init_pseudo()
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
Message-Id: <20261110-work-loop-pseudo-v1-8-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1198; i=brauner@kernel.org;
 h=from:subject:message-id; bh=McdhKaZYT4i07Xats25HT8jpBIeYReCKfIiqQkLDh7c=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9ejDXp05OOqNfiGfutU+mD244ZPwWu6w2Ner6mY67a
 1N9rz580VHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjCRz8EM/8zfXf24LmZt6Maf
 748F7bqwrvMdv95q947nnlLsuYdn/j3N8JvF0yvka11ts23/pvzN+To/re7tc+Vlrptwd4bj6ob
 /3vwA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize mqueue as a pseudo filesystem instead of raising
SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 ipc/mqueue.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index 322c3dd98c44..8bbe32d0881f 100644
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

