Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302185;
	b=ySWRpzU/tofj4cHKvPG9+x9cqgHZTu2rEbBw9N21Ih8qVdDC8G2dl/qGYOQ1kZVfBoJJ
	 izBuMW+ebQwktowcYesoH4Ygj/d6Chb2ZhgOvZI6VS2Psjy9ifUtksEfGGk6YCTWFWKQx
	 Atq0PVeQ34Ha0Q3d/Q+XIzAaz9LwhzVdOAmMbu79cLInl4obvDb0+Ictfw4RutBoaB1DE
	 OeY7QOY+/5t2Km1Rl9fu/vXK5y2CsQKQHrKOFGTEQR6nIwqNKkX01Z/UBAdME3B5SG5zb
	 C7r0nMul38SA2R9HcWHkbPnXdn+VZC9n7YOZnacA8w2UNjOzfdiY4Ay9EsTlonXqySA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302185;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=+PlyOtqsg4uvOLuXQ3/FL9HLYIT+WYfLjjBDzOseC4E=;
	b=cq55pJQ5Kx5ORL2uE0aY9VU51AsIxonCDqQ0YSzGFWivBtRx4eqiw5s6QbBLRZ5Duu4Y
	 AweuQpScQpAjOQAA3fGSSTSKovW0MawdhIIG/4+DjBnkMmu1AB+0Xgy8BSSZ5nuWzEnIm
	 aoZNP8De/pP+N8nj5UBBWhOvoy4sFuny3hxoEQf7YtO7IosN7JK+0ovInu2c2LrCkzDGf
	 NoF6m/On6XelYma8E7heap97URWIi72hXxCDoiQMTb6Zt03eUjo5ivATBw0R58LYuIeTw
	 WG7GlVNI3zsWOTOrtIYIFxlvptVNe+zom7vKsGibKCNafGwuSIyaNo+Tv/6q4tAJPLg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JDSV52m4;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6B574606A33C;
	Tue, 10 Nov 2026 09:16:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JDSV52m4
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C370A1F008BE;
	Tue, 10 Nov 2026 09:16:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302185;
	bh=+PlyOtqsg4uvOLuXQ3/FL9HLYIT+WYfLjjBDzOseC4E=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=JDSV52m4OfCcyst3hFku2YCPCNxNeOvikciB89hDYJCR1LbwEEt/lYeTuQQD7/iUW
	 H5tRIQ9v6jXMgiZgkJiF4GqOivkKtZZw7NCQaQ+f1NR7twZvTqcjqI+/c/IH9v/Jxy
	 EoKQxUfmWpqjCJS9oAmdJNyKK7FKdWto+bebjhA+fYE+FkEqbaHlH+Oa9uQsiCi9GB
	 3VXoXUr7iZu5zDIGq4U4YgT3MCBnLcxw8LrsjsTPugWIr6zcD/ibPJDTK7P1rf/Nm/
	 FeXmWLksNQuP1ST2JEb6k4O48XmygmJ7cLGcrIfDn6Eu2LG0Vr4DLcJUZZqj6ewXS2
	 2mhb3DLeE7TVQ==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:20 +0100
Subject: [PATCH RFC 04/41] fs: add SB_I_PSEUDO
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
Message-Id: <20261110-work-loop-pseudo-v1-4-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3427; i=brauner@kernel.org;
 h=from:subject:message-id; bh=k3b1S5Aks24kDoWnRvLqsdiiPcKIlG2bf4Gt1cYJbvU=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9ejDjkUK2x5tSpSe3sln+v7tvX2kk8yFWmKv/wMXyl
 fsivk7i6ShlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZjIgXSGn4zTcuXEC9Zcm34h
 e6vptpmiC3asPh6Q0BteemFfbSaHeDDDP+uZ7aUJ00OdGBbc/56893hNWHZRbjDHr99CTduPlCV
 M4wIA
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

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/libfs.c                     |  2 +-
 include/linux/fs/super_types.h |  1 +
 include/linux/pseudo_fs.h      | 11 +++++++++++
 3 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/fs/libfs.c b/fs/libfs.c
index 96a6e9b1535f..8c8789489fdf 100644
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
index 72f4288e16c5..472200bdf081 100644
--- a/include/linux/fs/super_types.h
+++ b/include/linux/fs/super_types.h
@@ -359,5 +359,6 @@ struct super_block {
 #define SB_I_NOIDMAP	0x00002000	/* No idmapped mounts on this superblock */
 #define SB_I_ALLOW_HSM	0x00004000	/* Allow HSM events on this superblock */
 #define SB_I_NO_DATA_INTEGRITY	0x00008000 /* fs cannot guarantee data persistence on sync */
+#define SB_I_PSEUDO	0x00010000	/* regular files are kernel interfaces, not storage */
 
 #endif /* _LINUX_FS_SUPER_TYPES_H */
diff --git a/include/linux/pseudo_fs.h b/include/linux/pseudo_fs.h
index a651e60d9410..0ca408aa60af 100644
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

