Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661768;
	b=Ht2i/99yz7UqCVEuX4tz5+45ReCDSA4fevekQGEO+kH0qkf9p/7mlSYkQB+Cd5GxruQL
	 6Y8t2HzElDcDJv/AkPB6LZwpMhPwdz2uZ5OL0L1FZuxuARVoJ6iVU52wuDcDRaIpoTaA6
	 nn+QTrPrsDzbWtM0xSS9cFI3X8mNOpV1zrcwutSwcitIkXA7IBEz/iNb67P/u6T6bxTwl
	 ArIJi2NTVlw7r8LUejNP7gOAAvCuF6reaL7RLC/COraubFY/xODR0lRTm6oPEBrRrrcvO
	 FNyyVWX0kz4AN4etl2XhLN9MU/oT6k6MaTcAhjCpKJhcV2JQgIRiTS3OoZ4BKtsig+Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661768;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=H3woHW5NuHalYxniipx06r8pldr4YceYTv1pn/rF5vE=;
	b=HhJNNgF/8eni2mg0r4xBeasvvKBXnLFwX1IgIdvZOiJsTFbNcI99TWX3zbDZ22gNcDt2
	 ovuiS84iqkkgjmAyIuEzsOqHulxMn9HyRazUnwY+5r/mu80hWQwl0eZGQwX3NLmJR931m
	 4I02VA7YkVHjzgwK0d82MTezfmHFsF+gmTsPNrOmshV6E5LKMr8FLiNCpwdEydT5MclB8
	 Wj3A73cQ4hHoD7MrKSBF4JMFV1nTvTLTlZQOoYbcwqojlSDpm67o7fqdMNyc12dbOW+zD
	 JFByAbV72+wOrrlel2EWWHOFBqUFQcKnR4Zq7Aeri+S68EDcm2A4K4fuIzdOCeF1Xuw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="UAg3s/Vf";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6EB516076649;
	Sat, 14 Nov 2026 13:09:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=UAg3s/Vf
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 494421F000C4;
	Sat, 14 Nov 2026 13:09:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661768;
	bh=H3woHW5NuHalYxniipx06r8pldr4YceYTv1pn/rF5vE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=UAg3s/VfqaxFZr4H3x+hoBgaYeR58NCwZLQGG146Mb/pBhr/WcRGZ7xb7M/thEkMD
	 PJlUKEdmCBwLw2fGmP07bSQQ9RnzN2mppJ3S4yzMBEInXYqU5b2zYclVyeVZXRYChW
	 20DI30qNtO7uGRC+D7ic8YqQVEfQ5u4NJcR2KWnrkO709Biw9Lp8DNuSRq0pC5chiH
	 vwleIe6pSr3ZgR0iu7ov+4jGyoHUhvjM9/10Nw7l/T9Aa7yHdKZtvBVuPQbCedcvZR
	 Bf1414fQ9ZOmDwhWQAS1CmBYmYejnUXu0vjs2mMLEcO6qOYxSnm1AgvHWgMj+X5l1S
	 AOnQHCwdL9VZA==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:14 +0100
Subject: [PATCH RFC v2 33/42] fs: add file_check_backing()
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
Message-Id: <20261114-work-loop-pseudo-v2-33-98639a2286fb@kernel.org>
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
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=5096; i=brauner@kernel.org;
 h=from:subject:message-id; bh=udmwrAi4jqUBDqxn9CQi3IZuwOmdQkanmcVhsi9fI/0=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iOmZyCSi3Nt50cbl+WtTZr6+x/W2TjHVZT3Xbdyzc
 x+n863uKGVhEONikBVTZHFoNwmXW85TsdkoUwNmDisTyBAGLk4BmEjgC0aGT2rLm55oe20wSrmQ
 M4nXdurS2cK72+fXmy0t+NOrp6q2geGvmHTig8czFrfm67GlVHNkKdSzCE+IFlWzeTFnz5QEgQw
 OAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Loop, zloop, the nvme target, the scsi target, fuse passthrough, the usb
mass storage gadget, erofs and acct all take a file from userspace and
use it as storage. Currently, each of them has its own idea of what to
check before using a file like that:

- loop and the gadget check for a regular file or a block device, the
  nvme target, the scsi target and zloop take any file type
- loop checks the open mode, the gadget checks FMODE_CAN_READ, the nvme
  target, the scsi target and zloop only check for ->read_iter() and
  ->write_iter()
- apart from acct which refuses procfs and sysfs files none of them
  cares whether the file is a kernel interface

Add a helper that does all of it in one place. It only accepts regular
files and, if the caller passes S_IFBLK, block devices. It refuses files
on pseudo filesystems. And it checks that the file is open for what the
caller is going to do with it and implements ->read_iter() for reading
and ->write_iter() for writing.

O_PATH files are refused unless the caller passes FMODE_PATH. That is
for callers that only need the path of the file. fuse passthrough is
one of them and has accepted O_PATH file descriptors since commit
efad7153bf93 ("fuse: allow O_PATH fd for FUSE_DEV_IOC_BACKING_OPEN").

Block devices are fine even though bdevfs is a pseudo filesystem. A
block device that userspace hands in is a device node on devtmpfs or
some other filesystem. Files on bdevfs only come from
bdev_file_open_by_*() and never end up here.

The pseudo filesystem check looks at the inode that actually provides
the data via d_real_inode(). overlayfs accepts sysfs, cgroup2, debugfs,
tracefs, configfs and securityfs as lower layers and reads of such an
overlayfs file are served by the file on the pseudo filesystem. Checking
the overlayfs inode would miss that.

Note that the file type is taken from the inode of the file and not from
the host of ->f_mapping like loop and the gadget do it. A driver can
point ->f_mapping somewhere else in ->open(). It makes no difference for
block devices as both inodes are block devices.

No functional changes. Nothing calls the helper yet.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/read_write.c    | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/fs.h |  2 ++
 2 files changed, 50 insertions(+)

diff --git a/fs/read_write.c b/fs/read_write.c
index 6767283108991..cedbe654add65 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -866,6 +866,54 @@ static ssize_t do_loop_readv_writev(struct file *filp, struct iov_iter *iter,
 	return ret;
 }
 
+/**
+ * file_check_backing - check that the kernel can use a file as storage
+ * @file: file that userspace handed in
+ * @mode: FMODE_READ and/or FMODE_WRITE the kernel will do I/O with, or
+ *        FMODE_PATH if only the path of @file is used
+ * @type: S_IFBLK if a block device is fine as well, 0 otherwise
+ *
+ * Call this where a file from userspace is taken as a backing file. Only
+ * regular files and, if @type is S_IFBLK, block devices are storage. Files
+ * on pseudo filesystems are kernel interfaces and are refused. The file
+ * must be open for @mode and implement ->read_iter() for reading and
+ * ->write_iter() for writing. O_PATH files are only fine with FMODE_PATH.
+ *
+ * Return: 0 on success, -EBADF if @file isn't open for @mode, -EINVAL if it
+ * can't be used as storage.
+ */
+int file_check_backing(const struct file *file, fmode_t mode, umode_t type)
+{
+	fmode_t io = mode & (FMODE_READ | FMODE_WRITE);
+	/* Drivers may point ->f_mapping at something else. */
+	umode_t fmt = file_inode(file)->i_mode & S_IFMT;
+
+	/* O_PATH files are only fine for callers that just use the path. */
+	if ((file->f_mode & FMODE_PATH) && !(mode & FMODE_PATH))
+		return -EBADF;
+
+	if ((file->f_mode & io) != io)
+		return -EBADF;
+
+	if (fmt != S_IFREG && !(type == S_IFBLK && fmt == S_IFBLK))
+		return -EINVAL;
+
+	/* Look through stacking filesystems at the inode with the data. */
+	if (d_real_inode(file->f_path.dentry)->i_sb->s_iflags & SB_I_PSEUDO)
+		return -EINVAL;
+
+	if ((mode & FMODE_READ) &&
+	    (!(file->f_mode & FMODE_CAN_READ) || !file->f_op->read_iter))
+		return -EINVAL;
+
+	if ((mode & FMODE_WRITE) &&
+	    (!(file->f_mode & FMODE_CAN_WRITE) || !file->f_op->write_iter))
+		return -EINVAL;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(file_check_backing);
+
 ssize_t vfs_iocb_iter_read(struct file *file, struct kiocb *iocb,
 			   struct iov_iter *iter)
 {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 99caef43ff3c4..b1c7ebafbadbe 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2553,6 +2553,8 @@ static inline const struct inode *file_user_inode(const struct file *f)
 	return file_inode(f);
 }
 
+int file_check_backing(const struct file *file, fmode_t mode, umode_t type);
+
 static inline struct file *file_clone_open(struct file *file)
 {
 	return dentry_open(&file->f_path, file->f_flags, file->f_cred);

-- 
2.53.0

