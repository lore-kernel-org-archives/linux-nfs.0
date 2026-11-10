Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302192;
	b=O5v5l9fiYYSAahvVTriZnovUEhbQwZuB1YcO3fh2EUMombrZsgDNatH+8q7btV6RSZCQ
	 kMs5n87G4/X1hCGpggKBmE2Ely7sR6dKnzOdtFdkm9Jb2lNlx7Ez+fS8YWRF7C5QN/vNk
	 mSAz6X0yJ173vBkvx8wgyBrwOEZkryisdfZV+HM+kU9KOH6fnDbZXjx/qKk8tDO4F6z2k
	 KpoF2xdO6RepSwq1v+mRnyPFsKDv6kwDMkreGkM4BtpMpXIPonWDPA3qmDuL8n+q0J0YH
	 OqJHCtrZaWX2SPTziQtEREPOrDQurs04+rmEDrqsHGJx0LtIIxqsnHlxZ8gJZR2E+IA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302192;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=eGG9W0yWfKzRivIQZoE53ERZFH3qHATHiSAlm/rfViI=;
	b=NMbOlSXECiHXQDZsfb4n+hLapM2xhdpHv6upVwy4xzPpZrwFsPSkbq7yRlxBw1X6K/lv
	 77RF/qFd18L5il/8akaswLoBccbKjBBIqRDl4kEx78BuGXN/qTzBK0ESznT3RADK2PHht
	 KJlS020feEOMckJkS2r2W1w8ErGRKphq1kKIJhw6PO3DZfG2vligZ+oVj2LEduGM/ybLt
	 wuL542qUbh7KTSfgQDmZjqupG9y4LwTpIjsJT6Xu8uyy+GBLKLzetOYfGReonXN074mNE
	 BcEaitVoScli4C+DvaHwCkbcmFu0+a3CKLLZs7YxbTvEzwVmj86x2a8Feiz/0+3hSaQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CjYzYxSG;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3DCA9606A334;
	Tue, 10 Nov 2026 09:16:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CjYzYxSG
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8126C1F00902;
	Tue, 10 Nov 2026 09:16:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302191;
	bh=eGG9W0yWfKzRivIQZoE53ERZFH3qHATHiSAlm/rfViI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=CjYzYxSG4MF/PYOuhfPotw8YsrgHpqEMmvVsealc1nZYA5sYB8ePEA/BT0law6L4c
	 H4DwOy7PJ6PWOuylSpgYpzMq2zQGYiIT8+FEalpf9CzWwtAbdti5C3COkrTAoZVyOC
	 98zYnncAcJul/uKitX7mc2xPlqIIYPds4N05d66Wgi6oSv9azb1TV2yyF+MJgyG+uT
	 +q4Aq0251HvqT0ZVS0wHPkEhV8CPEhOZQuBNIukUVbH00aNshGt3HqKek36mnvJebH
	 4omkN8WkJOC0ohRp48kohw45G0TEI0wyMWnb2yC/I1jgI5cFhMlDgFavrTXU4YWzSj
	 7d78+YdkJ4mOA==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:21 +0100
Subject: [PATCH RFC 05/41] kernfs: use fc_init_pseudo()
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
Message-Id: <20261110-work-loop-pseudo-v1-5-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1308; i=brauner@kernel.org;
 h=from:subject:message-id; bh=oxvnYqP+iDvCdTKHYHpfovNIFRCjsigYBDc/6gG4KoE=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9ejDzzd/Z9nGXbsVbBqjycnSqNVW8nKT5dary583xR
 9dNDt3g2VHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjCRjaGMDOv3/hK7rKMoLKFw
 cJvq3Wdf7eI+x+zYPCvtnPsBx+pD2VMYGd6l2F1wrJl6IHntnnLtfb/v/1wpEWL5tkZ74nuPD8z
 fDFkB
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize all kernfs based filesystems as pseudo filesystems in
kernfs_get_tree() instead of raising SB_I_NOEXEC and SB_I_NODEV by hand
in kernfs_fill_super(). This adds SB_I_PSEUDO for sysfs, cgroupfs and
resctrl.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/kernfs/mount.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/kernfs/mount.c b/fs/kernfs/mount.c
index a0be784bfb06..6b60d212b003 100644
--- a/fs/kernfs/mount.c
+++ b/fs/kernfs/mount.c
@@ -8,6 +8,7 @@
  */
 
 #include <linux/fs.h>
+#include <linux/pseudo_fs.h>
 #include <linux/mount.h>
 #include <linux/init.h>
 #include <linux/magic.h>
@@ -298,8 +299,6 @@ static int kernfs_fill_super(struct super_block *sb, struct kernfs_fs_context *k
 	struct dentry *root;
 
 	info->sb = sb;
-	/* Userspace would break if executables or devices appear on sysfs */
-	sb->s_iflags |= SB_I_NOEXEC | SB_I_NODEV;
 	sb->s_blocksize = PAGE_SIZE;
 	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = kfc->magic;
@@ -388,6 +387,7 @@ int kernfs_get_tree(struct fs_context *fc)
 	info->ns = kfc->ns_tag;
 	INIT_LIST_HEAD(&info->node);
 
+	fc_init_pseudo(fc);
 	fc->s_fs_info = info;
 	sb = sget_fc(fc, kernfs_test_super, kernfs_set_super);
 	if (IS_ERR(sb))

-- 
2.53.0

