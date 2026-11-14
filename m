Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661565;
	b=mASEY7iFENEZVDN0E7pBgJI8GDQ2PG3YXh2hy2yPdUovLKmiAQQQ/7FyG3AKwaS/vmNK
	 GYtOIPZPcoZYWGxBhaPnLrOH9lyvPERMY68zflfp99hMSjY1mpGCr7p8bF/U7XIA0PNwu
	 qNjBJ1mVfCcogMRv3ipMRg/EAKXO9+DhKc7xhnGtfmECzebotiidaITzhPJm64Xtgqi7q
	 YyATzhmBGpPVN6kipHb5Gj2Nx3rF4p33Y/9bK9u15MkTwD8bsMXzdStDMJiPdd55fX7cF
	 W1gRIzLyMG/Kb4CMQDaTwf5rIyvuJ8nmlU1eQP21o7CjD+biJYkn75sshGGQDDP7OKA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661565;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=XBMFsDX8jPf40Ops7fmXNGVPlFkxVQgzGux0hDAKlKk=;
	b=5JDDYB0KXUu4aXwx4I10k7iMvgdUanE0C+U01h8c8uP//qwW5xQwTY8HVOgRgOiXuYXY
	 E185pYrOxvbtYqK/M7fgqLHq02ulYm+l9KWH++7OI1nolV2H+8Oe2Evn6Bx/BHBdbA7/R
	 TFFoWZaQcpOTs32UdtBtqWmnyfQPVYK5uj902aEN756JPaXcs8g4f2W4q7hngZ2Pzk0C4
	 KKGoP0xD/4BkGT2WPusif0QnMJJJA9nrU3kBGBkBJHUSi0yK3cx+tYPv7t7sCNRpzteip
	 UIQgxWgwSq8nQlnQYQ/eh6afDkZ3ftGajO2vvfqZJhWycbNYdB/2LYGYtr6bo2WEtKQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RD5VsZN4;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 19770606A8B8;
	Sat, 14 Nov 2026 13:06:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RD5VsZN4
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1EFEC1F000C6;
	Sat, 14 Nov 2026 13:05:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661564;
	bh=XBMFsDX8jPf40Ops7fmXNGVPlFkxVQgzGux0hDAKlKk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=RD5VsZN4sq2RqmQsT5z5jrMvNyxT631psMzcncHkeuuOg4+buqvJIz9dkv3jYlcRR
	 V2pZL3WoNUnQEP51tR/BZ3mcEYArPXsdK2URRwWSRFhtvKx/JSyOxbx/SSxSZ03vHz
	 Lflt0K4kNkqkrNxJOQZaDKj0oL/iqRPc86/OPdzz5wXkK5HEebo/kdwARHBNP73YFr
	 tAG70yUnJ+/yOTbVOqVG01afbjhJSRs4hdUGrwmkNVaypvzLQCLkzUB2I7in22IT4R
	 nFR55mmB9LvTaJ1vKj64yR5+aC/v8xo6K6N+tsYNJVtxrK4ZLCG0N1UNDrdBjPf7bF
	 R7x3k02G1lVuA==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:01:45 +0100
Subject: [PATCH RFC v2 04/42] fs: add SB_I_PSEUDO
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
Message-Id: <20261114-work-loop-pseudo-v2-4-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3572; i=brauner@kernel.org;
 h=from:subject:message-id; bh=5JLKbJArUBEaIJcAIKA7+ivAi2N0PjM1HEiHb7NbADk=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iMlyW+O+wt51Bs/Rm+xntS/n7+nkLV168mrgXwOOm
 nPMrH2bO0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACby15qRYZ9AT0+/1KY3tab/
 N6s6/rWxyZ1wxuPSVJclEfO1Kp4YczEyXJBmutLyZ+8jg2D9Y+vLQtfqn2zhyZmgPuld0JlpJ8J
 lOAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Currently, there's no way to tell whether the files of a filesystem
store data or whether they are kernel interfaces. Files on pseudo
filesystems such as procfs or sysfs generate their contents when they're
read and writes to them are commands to the kernel.

But a few places in the kernel take an arbitrary file and use it as
storage: loop, zloop, the nvme target's file backend, the scsi target's
fileio backend, fuse passthrough, the usb mass storage gadget and erofs
file-backed mounts. At most they check the file type and whether the
file implements ->read_iter() and ->write_iter(). That's not enough.
kernfs provides both for every sysfs attribute for example.

Add SB_I_PSEUDO so a filesystem can state that its regular files are
kernel interfaces and must not be used as storage.

Pseudo filesystems also never hold executables or device nodes. But
currently each of them decides on its own whether to raise SB_I_NOEXEC
and SB_I_NODEV. Some do, most don't. Add fc_init_pseudo() as the common
initialization point for all pseudo filesystems that raises all three
flags and switch init_pseudo() over to it. The following patches
convert the mountable pseudo filesystems.

Nothing checks SB_I_PSEUDO yet so no functional changes.

Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/libfs.c                     |  2 +-
 include/linux/fs/super_types.h |  1 +
 include/linux/pseudo_fs.h      | 11 +++++++++++
 3 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/fs/libfs.c b/fs/libfs.c
index 96a6e9b1535fb..8c8789489fdf9 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -735,7 +735,7 @@ struct pseudo_fs_context *init_pseudo(struct fs_context *fc,
 		fc->fs_private = ctx;
 		fc->ops = &pseudo_fs_context_ops;
 		fc->sb_flags |= SB_NOUSER;
-		fc->s_iflags |= SB_I_NOEXEC | SB_I_NODEV;
+		fc_init_pseudo(fc);
 		fc->global = true;
 	}
 	return ctx;
diff --git a/include/linux/fs/super_types.h b/include/linux/fs/super_types.h
index 72f4288e16c52..472200bdf081a 100644
--- a/include/linux/fs/super_types.h
+++ b/include/linux/fs/super_types.h
@@ -359,5 +359,6 @@ struct super_block {
 #define SB_I_NOIDMAP	0x00002000	/* No idmapped mounts on this superblock */
 #define SB_I_ALLOW_HSM	0x00004000	/* Allow HSM events on this superblock */
 #define SB_I_NO_DATA_INTEGRITY	0x00008000 /* fs cannot guarantee data persistence on sync */
+#define SB_I_PSEUDO	0x00010000	/* regular files are kernel interfaces, not storage */
 
 #endif /* _LINUX_FS_SUPER_TYPES_H */
diff --git a/include/linux/pseudo_fs.h b/include/linux/pseudo_fs.h
index a651e60d94107..0ca408aa60aff 100644
--- a/include/linux/pseudo_fs.h
+++ b/include/linux/pseudo_fs.h
@@ -2,6 +2,7 @@
 #define __LINUX_PSEUDO_FS__
 
 #include <linux/fs_context.h>
+#include <linux/fs/super_types.h>
 
 struct pseudo_fs_context {
 	const struct super_operations *ops;
@@ -15,4 +16,14 @@ struct pseudo_fs_context {
 struct pseudo_fs_context *init_pseudo(struct fs_context *fc,
 				      unsigned long magic);
 
+/*
+ * Common initialization for all pseudo filesystems, mountable or not. Their
+ * regular files are kernel interfaces. They don't store data and pseudo
+ * filesystems never hold executables or device nodes.
+ */
+static inline void fc_init_pseudo(struct fs_context *fc)
+{
+	fc->s_iflags |= SB_I_PSEUDO | SB_I_NOEXEC | SB_I_NODEV;
+}
+
 #endif

-- 
2.53.0

