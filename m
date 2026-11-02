Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793631609;
	b=1MYgR9x1VnSj6Nhvo7D+3rlSIGOfPLio5XG40vaV+78HSjJJ2kz6JvTsQPTf7wAJYylb
	 yxWYojwpsHuo0YBLi5GK4XG3+7+LaJjlO0X7dp+xZ+L6ZVFjXcDrdIz8RBnAcM0FfNRzI
	 hZYXjdm29bDQNgjzSkI3YVVTRcO800LsQ3CyO8zCQ2ogk9yg7jYYLpsIaZXErw+/RxOy6
	 tlOQBxLV4PnmDXy6gotMeHdenaouOihv30OSXJxjbKt6hLgVQWt4I6wHoTTb7Olzqz9SV
	 Gmf2unh1rt7jL1/DEkxMKOKkRBjryiXMD5SAy7sRZyrsg+/0L9Spm78r3VmasoaDn6Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793631609;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer;
	bh=DA4U0m1CHtqk19BjQpd8o6fqolui3N68b+LzMS0kHTM=;
	b=wafcBgrgIx4If4F7Fe2zvcThncvS9+sFecm/lXjEHD29fLo7h6qi6rJ3vT5rYwfB4DK2
	 DanhvSWT1opqXU8qpESE4B4owU0vsMeUH7HtLjxWpsl5XymhiC28S79C/fjUQWllwvYQy
	 TFJ6wvP3U8+KVNfEBdg2H7kbeHN7bbDY28MSV6LFcz0jA9cEcZwo032Q1HSL7NBgY+QyC
	 qYPnPjPa14OUqdNt9DZFDxDlSMhi61IlfPhPo/j2ct3iTQzw4OXPyttyN84gyv2oagxvD
	 2+zp22INlkNji1eOJ8bwGqEdN2+aQda4yNBm6cRMwJHGGGQdyxoazyMsnFawAYBc8OA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kIejajPL;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2F214606C55A;
	Mon,  2 Nov 2026 15:00:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kIejajPL
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 71C201F00A16;
	Mon,  2 Nov 2026 14:59:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793631608;
	bh=DA4U0m1CHtqk19BjQpd8o6fqolui3N68b+LzMS0kHTM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kIejajPLDhBhNAF+5qAkd+IjamKUOnO1hhgOl6ob3NywfSYo1UCCZClj+UVXxg6hN
	 8GZuczs7QvhEz8GqB31Q0v4Sfe6zaLku1E8g4bV1Nm7S11GUdX9udG3+A+XpQmpG4w
	 SKp3yZE5RKwGE6D9RxNOhr665KUXvrAf7U9EgM6t8GMzBMTN1Hyi8S9DzqCn2e/KFT
	 qYkBu+IipshrjT/yGx4WL5OycQQAysKT17bx+VTU/wQ//N1IctW6952TFgl4pmjQUh
	 Zgj0NC/jh4zpBceIV8H3jC5zH7xmHBcraK25zYbCARrQ8e4MvgCvvVFdA3MjVOm0bI
	 x3pJnolxi8+9Q==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:48:54 +0100
Subject: [PATCH RFC 14/16] fs/proc/vmcore: let procfs copy out reads
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
Message-Id: <20261102-work-procfs-core-v1-14-75df35e4f8b8@kernel.org>
References: <20261102-work-procfs-core-v1-0-75df35e4f8b8@kernel.org>
In-Reply-To: <20261102-work-procfs-core-v1-0-75df35e4f8b8@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, 
 Jann Horn <jannh@google.com>, Josef Bacik <josef@toxicpanda.com>, 
 Chris Mason <mason@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Eric Dumazet <edumazet@kernel.org>, 
 Thomas Gleixner <tglx@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, 
 Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@lst.de>, 
 Greg Kroah-Hartman <gregkh@suse.de>, 
 Joel Granados <joel.granados@kernel.org>, Kees Cook <kees@kernel.org>, 
 Jan Kara <jack@suse.cz>, Jan Kara <jack@suse.com>, 
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 linux-acpi@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org, 
 linux-um@lists.infradead.org, linux-wireless@vger.kernel.org, 
 linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, 
 ntfs3@lists.linux.dev, platform-driver-x86@vger.kernel.org, 
 coreteam@netfilter.org, kexec@lists.infradead.org, 
 linux-pci@vger.kernel.org, linux-sound@vger.kernel.org, 
 netfilter-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, 
 ibm-acpi-devel@lists.sourceforge.net, jfs-discussion@lists.sourceforge.net, 
 linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, 
 linux-cifs@vger.kernel.org, linux-fbdev@vger.kernel.org, 
 linux-hwmon@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, 
 linux-usb@vger.kernel.org, samba-technical@lists.samba.org, 
 sparclinux@vger.kernel.org, linux-m68k@lists.linux-m68k.org, 
 linux-doc@vger.kernel.org, linux-serial@vger.kernel.org, 
 linux-atm-general@lists.sourceforge.net, Takashi Iwai <tiwai@suse.de>, 
 linux-input@vger.kernel.org, linux-raid@vger.kernel.org, 
 linux-ext4@vger.kernel.org, linux-modules@vger.kernel.org, 
 linux-debuggers@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev

Implement ->proc_read_buf() so procfs copies what is read to userspace
after it unpinned the entry. __read_vmcore() fills procfs' buffer
through a kvec iov_iter. So a read goes through that buffer now instead
of straight from the old memory into the reader's, which is what
splice() did already. mmap() isn't affected. On ppc64 a machine check
while reading the old memory used to be recovered through the exception
table of copy_to_user(), by accident. copy_oldmem_page() copies with
_copy_mc_to_iter() now, so a read through procfs' buffer recovers from
it as well.

The buffer is 128k, which keeps the entry pinned for one such piece at
a time, and /proc/vmcore asks for PROC_ENTRY_FULL_READS so that a
larger read is filled in pieces. kexec-tools treats a short read of it
as fatal. A read that faults on its buffer in a later piece returns the
pieces before it now instead of failing with -EFAULT. fadump removes
/proc/vmcore when its memory is released and that no longer waits for a
reader that faults on its buffer.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/vmcore.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
index ccb795b85509..1c1e71231f4e 100644
--- a/fs/proc/vmcore.c
+++ b/fs/proc/vmcore.c
@@ -27,6 +27,7 @@
 #include <linux/mutex.h>
 #include <linux/vmalloc.h>
 #include <linux/pagemap.h>
+#include <linux/sizes.h>
 #include <linux/uio.h>
 #include <linux/cc_platform.h>
 #include <asm/io.h>
@@ -427,9 +428,14 @@ static ssize_t __read_vmcore(struct iov_iter *iter, loff_t *fpos)
 	return acc;
 }
 
-static ssize_t read_vmcore(struct kiocb *iocb, struct iov_iter *iter)
+static ssize_t read_vmcore(struct file *file, char *buf, size_t count,
+			   loff_t *ppos)
 {
-	return __read_vmcore(iter, &iocb->ki_pos);
+	struct kvec kvec = { .iov_base = buf, .iov_len = count };
+	struct iov_iter iter;
+
+	iov_iter_kvec(&iter, ITER_DEST, &kvec, 1, count);
+	return __read_vmcore(&iter, ppos);
 }
 
 /**
@@ -709,9 +715,11 @@ static int mmap_vmcore(struct file *file, struct vm_area_struct *vma)
 #endif
 
 static const struct proc_ops vmcore_proc_ops = {
+	.proc_flags	= PROC_ENTRY_FULL_READS,
 	.proc_open	= open_vmcore,
 	.proc_release	= release_vmcore,
-	.proc_read_iter	= read_vmcore,
+	.proc_read_buf	= read_vmcore,
+	.proc_read_size	= SZ_128K,
 	.proc_lseek	= default_llseek,
 	.proc_mmap	= mmap_vmcore,
 };

-- 
2.53.0

