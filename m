Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827196;
	b=nj7skqsSIYDpK1TVxprMcAABIUixhBJlNCF3sGM7KS8ChaZGgVba2v69yi8NoIdIbh+T
	 jguvL9dtIYeWfwDBa3Fi9UM7zGo/p6JE65sOWd2QdKAhVFuu0w+ENi0DUUBCNFfTX20Bq
	 v7chGwqYWaYGwCQpQz57fNgwdtzgpQsWa9CnzD630wEsRk3vbaTo//2mcpa0dWAGDIZRe
	 CnhlysbRLjHt2UJyKbOJKs3w0mpzuK/hL1rHhQfY5QIP5B3RKdFTddC7hl1IrXq1B+5Nh
	 o1SPgsy7H9y1Q0Uuc/3p2jyY3OigK9Wqm5eQ6JILNKLfU74XgBXL7Y20TDYWwIztCJA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827196;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=V82ztJBNlPhaz+Wx849jUF1Fth1Va6laWHBuR1fHMH0=;
	b=0SsycTT8yz36t1dJ945LD/tFJfnLFTDjxaDztgtEnzZDQDKHlDuZvYlEZrEXwbHDEf2i
	 i/1Z+irQwHatn7e63JoPpGB1qC+D2vjPHBw6tUKz6todqLnCcx+ctXxW4rlkNP2Ah9NU/
	 1o1GBhduHh9yhSZWZG7Sbo4x0DHqhN44UUQxfxIZqMdSHKLx1Qyd0/8RhnWTompGqXdhp
	 t1a4ziG4m+eDmNh/Av0/bSaHZJh1izn8cJPvmhvthpRtDxgUgs/vP0U1+9KvAPxfXPab+
	 3foqK1WacovjvwhBGdCxKVmNznsb0nN4Upgw0ifXL6ORLQ9mmdG9sdGqrV/QXk4SzYA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kwDqbPlI;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EBFE3606C125;
	Mon, 16 Nov 2026 11:06:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kwDqbPlI
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 849FD1F000C7;
	Mon, 16 Nov 2026 11:06:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827195;
	bh=V82ztJBNlPhaz+Wx849jUF1Fth1Va6laWHBuR1fHMH0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kwDqbPlIEVin342bCV66mFc7w5TjDAG4QWgv0QPZ1iPybKt1uBx3pT88iGIZJjfxj
	 zXKtX4RwjRqJ1feSvaMW10OvKhkIbyo50QUFDvmHyOrEfSMH4I4ZB6qtqDGyn4lrKu
	 raphSXyqDO2TqDVRMJIz3uphpPuYJBCGYPN58KBOkNRA7wFcbm8ORc1aO05+VttQZO
	 CRCwtXmY1UhCDsMTy8/O3N0kW3QRUk+0ETDpA11tc+X/KUcXy3jKuDwqNRzTIxNSzv
	 t2YFmGchSCuI3EOQzBUg3DdY+vE7hPRWitKH5GBmz+8uIr8TqLiBn/YfGeAmNho9ae
	 96VtBlXWqQRPA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:37 +0100
Subject: [PATCH RFC v3 04/44] fs: add SB_I_PSEUDO
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
Message-Id: <20261116-work-loop-pseudo-v3-4-8cbbea1cf34f@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3846; i=brauner@kernel.org;
 h=from:subject:message-id; bh=KiwRkIO1lHh7OMwJFZf89sR/oYY0Mvh//bvL8i/DzWw=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9epx8W8b22xob5YkpkSfFQ9x32eSGl0ndW62pdumBt
 n5cffzkjlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgImIv2X4p3qnbDP/ubu7pL6y
 n/zaxdfx7Llzz4/KFw8nsVl3n9ynYs7wV9b9vP/cte8eZhW6Fns0bNgW98dW3zP+DKuS3oTs7uQ
 YDgA=
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

Pseudo filesystems also never hold executables and most of them don't
hold device nodes either. But currently each of them decides on its own
whether to raise SB_I_NOEXEC and SB_I_NODEV. Some do, most don't. Add
fc_init_pseudo() as the common initialization point for all pseudo
filesystems that raises all three flags and switch init_pseudo() over
to it. The few pseudo filesystems that do hold device nodes clear
SB_I_NODEV again when they fill in their superblock. The following
patches convert the mountable pseudo filesystems.

Nothing checks SB_I_PSEUDO yet so no functional changes.

Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Reviewed-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/libfs.c                     |  2 +-
 include/linux/fs/super_types.h |  1 +
 include/linux/pseudo_fs.h      | 12 ++++++++++++
 3 files changed, 14 insertions(+), 1 deletion(-)

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
index a651e60d94107..e8fb99600d564 100644
--- a/include/linux/pseudo_fs.h
+++ b/include/linux/pseudo_fs.h
@@ -2,6 +2,7 @@
 #define __LINUX_PSEUDO_FS__
 
 #include <linux/fs_context.h>
+#include <linux/fs/super_types.h>
 
 struct pseudo_fs_context {
 	const struct super_operations *ops;
@@ -15,4 +16,15 @@ struct pseudo_fs_context {
 struct pseudo_fs_context *init_pseudo(struct fs_context *fc,
 				      unsigned long magic);
 
+/*
+ * Common initialization for all pseudo filesystems, mountable or not. Their
+ * regular files are kernel interfaces. They don't store data and pseudo
+ * filesystems never hold executables. The few that hold device nodes clear
+ * SB_I_NODEV again when they fill in their superblock.
+ */
+static inline void fc_init_pseudo(struct fs_context *fc)
+{
+	fc->s_iflags |= SB_I_PSEUDO | SB_I_NOEXEC | SB_I_NODEV;
+}
+
 #endif

-- 
2.53.0

