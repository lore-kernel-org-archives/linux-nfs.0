Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661775;
	b=ibb00pIrD5PdsWTH/wsk/U9DCGsyRMm3tdj9rqTK2HxHKY2fEjpDQnYtGVhS+aa6woct
	 OcCBtHqcp5qXxaf03AUz7VDCrJHdgjY33x+L+FRRUnnh5Ix0KsqVgFvGcGbZr0bHp73zd
	 Ylkn2STqGxXZ+jmsas5EuWIP30x5slEXqqSm9UKt1ogVwyv2yiXPVFM8mzN8oqKpvDVRU
	 suKfr8Jc5hBy47bGVmZfeARljlFjSg0vx8cgD/1cLQsSjT8gGLGxpkTOV8nvSWM9NkQk+
	 eEahmfyxKaYyK4tKPhqtAMCp5y/tBp2XRA6cIl253xZ6xwVGQlAn1DXxURK2xFtJQPA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661775;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=VQQiNDOpqfhw0WpEQK13PFU/iv1KFQKHHI1yG9J6CXI=;
	b=1b+2OH2f0AbH5U+hSL6xgmR7f/LBiegU90xp3RlUFq+OYwjqUbt7zD2ZCkvBooFyMxJc
	 X/I/Cm1KF9Lrf6kkYc2QQfGjyt9pQNUrU1kgkrQ0A+0wPbZSgpe83g0NH5NZn3IKO1kUM
	 7cVfjdX+ugvqOEAFX3WV85trEnr56Z2WswzvYelBHlMVzoInv3TZNzyIIR3ZyUsBM8RQl
	 yybzb4Z9CZsT5gFmIUF2Vx0vsnfvw9w6bvAn7Nm4OnE8FhXzYct+M9BxKkLLBAZxKXqbS
	 lrqShDY0cgP0IseQu1cK4lP3XykbnxsxobdsShf86JptdWlYg7kGbJcGxJr19C+hk8g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hPdnrLSv;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 20CE9606E0F6;
	Sat, 14 Nov 2026 13:09:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hPdnrLSv
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BC6A41F000C4;
	Sat, 14 Nov 2026 13:09:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661774;
	bh=VQQiNDOpqfhw0WpEQK13PFU/iv1KFQKHHI1yG9J6CXI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hPdnrLSvIijKxqVhgZncYFJ1riM4IpNWYY8zX0cDtr3bj2nUfd/HZPMoRPQxIsnfF
	 DaMPjcjIj1YLJkAadaq+ac00V6lcALenldxa+ypuLeNF59j7yQq8JBxIVcGftAIK9J
	 oJLvgeew639qhyHDyTQ8PUuTOHup6ZjpZwoQIqUDLRHfDG4LKQSixZvz3hgHPHSGR5
	 dpwpfUmcZw7lZxrLuSwTR8JtVbvS7Bs/oHTFYy93RAxjeDeApGYYrfov3VLkt/xJWH
	 wPPbq8rtHc0wKic1Ypk+fQn/9tJOpCxIbX37BMGRzUaq2yGGKQGoSfgDtV3IYLZlfp
	 lF2hCNHNtssPw==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:15 +0100
Subject: [PATCH RFC v2 34/42] loop: refuse files on pseudo filesystems as
 backing files
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
Message-Id: <20261114-work-loop-pseudo-v2-34-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3745; i=brauner@kernel.org;
 h=from:subject:message-id; bh=uVejF7TG5lNB+KlVeH9oWZ72FFSLLOo68t1IwqUCfW8=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iOndk8naYnP82AqB3h1Fkd9lpt7fmfPG6ENPQqbjn
 V1vqjZu6yhlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZjIr2hGhkXahobeJrW7761Z
 /zvh90kpx6wb1uwvkt8V9fP/2Cg1PZGRYbmEVRl7+zPxbOvv/1bqvHQ4V9SW/+c46+dNT+7nXDu
 nzA0A
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Currently loop accepts any regular file that implements ->read_iter() as
a backing file and any that also implements ->write_iter() as a writable
one. That includes files on procfs, sysfs and other pseudo filesystems.
For example, /proc/kcore attaches read-only as a loop device the size of
the kernel's virtual address space, 64 PiB with 5-level paging. sysfs
attributes attach read-write as 4096 byte loop devices. Writing a block
to the loop device of /sys/kernel/mm/transparent_hugepage/enabled
changes the THP setting.

That's not just nonsensical, it can be abused. Loop calls ->read_iter()
and ->write_iter() of the backing file directly from its worker which
runs with kernel credentials. But pseudo files enforce part of their
access rules at read and write time against current. Dozens of sysfs
->show() and ->store() methods call capable(). Behind a loop device all
of these checks are done against the loop worker instead of the task
that opened the file. And setting up a loop device requires no
capabilities, only access to the device nodes. So on v7.4-rc1:

- uid 0 without any capabilities can't write to /sys/kernel/reboot/mode
  as mode_store() requires CAP_SYS_BOOT. Writing "warm" through a loop
  device works.

- uid 0 without any capabilities can't read the files in
  /sys/firmware/dmi/entries/*/ as dmi_sysfs_attr_show() requires
  CAP_SYS_ADMIN. Reading them through a loop device works.

- An unprivileged container that was handed a loop device can't change
  gro_flush_timeout of its own network devices as
  gro_flush_timeout_store() requires CAP_NET_ADMIN in the initial user
  namespace. Writing it through a loop device works.

The same goes for hard_offline_page, the md and sd attributes, rfkill
and others.

Refuse files on pseudo filesystems as loop backing files by switching to
file_check_backing(). Note that it looks through overlayfs so stacking
overlayfs on top of sysfs doesn't get around this.

The helper also does the file type, open mode and method checks that
loop did itself so far. The check for a regular file or a block device
now happens before the loop device is locked and it looks at the inode
of the file instead of the host of ->f_mapping. For regular files and
block devices both have the same type.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/block/loop.c | 17 ++++-------------
 1 file changed, 4 insertions(+), 13 deletions(-)

diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index c96e35c3ef423..776bd063f900c 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -492,7 +492,6 @@ static inline int is_loop_device(struct file *file)
 
 static int loop_validate_file(struct file *file, struct block_device *bdev)
 {
-	struct inode	*inode = file->f_mapping->host;
 	struct file	*f = file;
 
 	/* Avoid recursion */
@@ -510,8 +509,6 @@ static int loop_validate_file(struct file *file, struct block_device *bdev)
 		rmb();
 		f = l->lo_backing_file;
 	}
-	if (!S_ISREG(inode->i_mode) && !S_ISBLK(inode->i_mode))
-		return -EINVAL;
 	return 0;
 }
 
@@ -528,16 +525,10 @@ static void loop_assign_backing_file(struct loop_device *lo, struct file *file)
 
 static int loop_check_backing_file(struct file *file)
 {
-	if (!(file->f_mode & FMODE_READ))
-		return -EBADF;
-
-	if (!file->f_op->read_iter)
-		return -EINVAL;
-
-	if ((file->f_mode & FMODE_WRITE) && !file->f_op->write_iter)
-		return -EINVAL;
-
-	return 0;
+	/* A backing file that isn't open for writing gives a read-only device. */
+	return file_check_backing(file,
+				  FMODE_READ | (file->f_mode & FMODE_WRITE),
+				  S_IFBLK);
 }
 
 /* loop sysfs attributes */

-- 
2.53.0

