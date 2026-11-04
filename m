Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821480;
	b=ZfnS9YIpIxM6ZPFSnJjQxYcm4WUvQf9r2MkjJxECn1vtw2jv6nTz4i8LYd4jglxDDTGI
	 rFOxh9sDhqrnFjTv+hpcs0uVge2Uy+jHBPI/lxHwmUsUE4QPQsdFEIbhjLGIPzn/O2fjf
	 1wEHIGP/lj2JWFovCHXPOekCSyjUJZUQUsNDYx89GkxO4Elk7yFUeWfQtjdn08ddYrlg/
	 ak62LKq8Go7BW21KVPYHTXhytZA+qAmFOM58wRdPCWqMk9zmOZWmnFbHjmZQUuJHHI5bA
	 69eFt5yCNWeGUqt4rfSNHChl3tqvz3U9785Ag37ejm/GEvHcuI2JIZ17QLekKh1OSHw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821480;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=0F908CJPgWsUmGeEXwOdb+LqVbJ68uHDJ1pDvsTQFww=;
	b=rdIWhOA9GpTDEzkcEISkANv0VUSndDVgzNaMkM2+LPJR0f3Z8XWiujdNbUieAUUlwcmX
	 a6AKzqAg7FRXidDk+8xjmg039S8UrmajMkzVRC+zujgHs8RNJ4oV50kk1qkwQFO4Ay9XO
	 iCZ6qAuImML1bHceRa8P5ZZzGG7YLTXSmsqkICCiAYyIwAIQ4Ly05aty6wdDPpNUEbeYn
	 H0wWIq//WKCm4deekU5tyoeGaw5XiA+gbuaY18ChywDSsvefu4w4IJX0HRHzL9z69JaQd
	 ZmtcNHFBvJaHPp9glnFGakm/jKLvxfxCl3B4LACUDO46yN0CSbpraGZYtpWzuvO8vUA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nBYfqhzO;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1A482607031F;
	Wed,  4 Nov 2026 19:44:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nBYfqhzO
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 72EC61F00A17;
	Wed,  4 Nov 2026 19:44:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821479;
	bh=0F908CJPgWsUmGeEXwOdb+LqVbJ68uHDJ1pDvsTQFww=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=nBYfqhzOfWIGHsy8c53G5+e95/eOlSF+s0+PYDPiLShDcgF0zVxjVzadNTSbzeGPS
	 Gev4jrZfOjt5GDc4cXiN0YSRT4TEvVxeJ2FuLYhPV1dedrvI3+Pu2yeGrj82/WNN7U
	 zCQG6VqNrlF0Qr0UfEw+wC6aUxsz8RLux0n+F+FKqEtWOUz0g4EnG8ntHPfCxNd+jn
	 UZguQOMxrmrHjsx8VQXG8JjtzywqCzawniFug93OojMezHRM7T0Hoqz+lfYQibeFF9
	 cZni/cwUgquBfE2XXxNA/dGO3y/WvuRn97YHSCiffyy1RTxslKI+LzMpvfOv8McSjk
	 yCxQsEs373mbw==
From: Christian Brauner <brauner@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jann Horn <jannh@google.com>,
	Josef Bacik <josef@toxicpanda.com>,
	Chris Mason <mason@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Eric Dumazet <edumazet@kernel.org>,
	Thomas Gleixner <tglx@kernel.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Christoph Hellwig <hch@lst.de>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Joel Granados <joel.granados@kernel.org>,
	Kees Cook <kees@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Jan Kara <jack@suse.com>,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	linux-um@lists.infradead.org,
	linux-wireless@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org,
	ntfs3@lists.linux.dev,
	platform-driver-x86@vger.kernel.org,
	coreteam@netfilter.org,
	kexec@lists.infradead.org,
	linux-pci@vger.kernel.org,
	linux-sound@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	ibm-acpi-devel@lists.sourceforge.net,
	jfs-discussion@lists.sourceforge.net,
	linux-alpha@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-hwmon@vger.kernel.org,
	linux-mm@kvack.org,
	linux-sh@vger.kernel.org,
	linux-usb@vger.kernel.org,
	samba-technical@lists.samba.org,
	sparclinux@vger.kernel.org,
	linux-m68k@lists.linux-m68k.org,
	linux-doc@vger.kernel.org,
	linux-serial@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	Takashi Iwai <tiwai@suse.de>,
	linux-input@vger.kernel.org,
	linux-raid@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-modules@vger.kernel.org,
	linux-debuggers@vger.kernel.org,
	"Christian Brauner (Amutable)" <brauner@kernel.org>,
	Chuck Lever <cel@kernel.org>
Subject: [PATCH RESEND v2 09/26] s390/cio: let procfs copy in writes
Date: Wed,  4 Nov 2026 20:44:25 +0100
Message-ID: <20261104-work-procfs-drivers-v2-9-245e54e87116@kernel.org>
In-Reply-To: <20261104-work-procfs-drivers-v2-0-245e54e87116@kernel.org>
References: <20261104-work-procfs-drivers-v2-0-245e54e87116@kernel.org>
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
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=3388; i=brauner@kernel.org; h=from:subject:message-id; bh=lEA79OgzD1RbbuI3leV0mq7RtW4au2plI+2F9ffJvH8=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97qo1Prvbv2jWnmkmH6pDufs/6rfzTKnoEu5evTnGy 2WLm6V9RykLgxgXg6yYIotDu0m43HKeis1GmRowc1iZQIYwcHEKwERk/zIybEjl+VB/KeuDnbef yim235O4L5f4ub8sDT0fcZyRo2NjBCPDPrXc7kQ1lzbL+Yvap+65J7Y7TdL2ycNNJx9pnjvSsWU KKwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_write_buf() for cio_ignore and cio_settle so procfs
copies in what is written before it pins the entry. cio_ignore parses
the list from that copy, up to the first NUL like strncpy_from_user()
handed it to it before. Writes larger than 64k still come up short, now
through PROC_ENTRY_SHORT_WRITES. Writes to cio_settle larger than
PAGE_SIZE - 1 bytes fail with -EINVAL now, it never looked at what was
written.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/s390/cio/blacklist.c | 33 ++++++++++-----------------------
 drivers/s390/cio/css.c       |  4 ++--
 2 files changed, 12 insertions(+), 25 deletions(-)

diff --git a/drivers/s390/cio/blacklist.c b/drivers/s390/cio/blacklist.c
index 4e02f78f6102..1ec7915be6b3 100644
--- a/drivers/s390/cio/blacklist.c
+++ b/drivers/s390/cio/blacklist.c
@@ -12,7 +12,7 @@
 
 #include <linux/hex.h>
 #include <linux/init.h>
-#include <linux/vmalloc.h>
+#include <linux/sizes.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/ctype.h>
@@ -355,39 +355,24 @@ cio_ignore_proc_seq_show(struct seq_file *s, void *it)
 }
 
 static ssize_t
-cio_ignore_write(struct file *file, const char __user *user_buf,
+cio_ignore_write(struct file *file, char *buf,
 		 size_t user_len, loff_t *offset)
 {
-	char *buf;
-	ssize_t rc, ret, i;
+	ssize_t ret, i;
 
 	if (*offset)
 		return -EINVAL;
-	if (user_len > 65536)
-		user_len = 65536;
-	buf = vzalloc(user_len + 1); /* maybe better use the stack? */
-	if (buf == NULL)
-		return -ENOMEM;
 
-	if (strncpy_from_user (buf, user_buf, user_len) < 0) {
-		rc = -EFAULT;
-		goto out_free;
-	}
-
-	i = user_len - 1;
+	/* the parser never saw what follows a NUL */
+	i = strnlen(buf, user_len) - 1;
 	while ((i >= 0) && (isspace(buf[i]) || (buf[i] == 0))) {
 		buf[i] = '\0';
 		i--;
 	}
 	ret = blacklist_parse_proc_parameters(buf);
 	if (ret)
-		rc = ret;
-	else
-		rc = user_len;
-
-out_free:
-	vfree (buf);
-	return rc;
+		return ret;
+	return user_len;
 }
 
 static const struct seq_operations cio_ignore_proc_seq_ops = {
@@ -398,9 +383,11 @@ static const struct seq_operations cio_ignore_proc_seq_ops = {
 };
 
 static const struct proc_ops cio_ignore_proc_ops = {
+	.proc_flags	= PROC_ENTRY_SHORT_WRITES,
 	.proc_seq_ops	= &cio_ignore_proc_seq_ops,
 	.proc_state_size = sizeof(struct ccwdev_iter),
-	.proc_write	= cio_ignore_write,
+	.proc_write_buf	= cio_ignore_write,
+	.proc_write_size = SZ_64K,
 };
 
 static int
diff --git a/drivers/s390/cio/css.c b/drivers/s390/cio/css.c
index 54b8b8639694..efd3df3e90ba 100644
--- a/drivers/s390/cio/css.c
+++ b/drivers/s390/cio/css.c
@@ -1278,7 +1278,7 @@ static int __init channel_subsystem_init_sync(void)
 subsys_initcall_sync(channel_subsystem_init_sync);
 
 #ifdef CONFIG_PROC_FS
-static ssize_t cio_settle_write(struct file *file, const char __user *buf,
+static ssize_t cio_settle_write(struct file *file, char *buf,
 				size_t count, loff_t *ppos)
 {
 	int ret;
@@ -1292,7 +1292,7 @@ static ssize_t cio_settle_write(struct file *file, const char __user *buf,
 
 static const struct proc_ops cio_settle_proc_ops = {
 	.proc_open	= nonseekable_open,
-	.proc_write	= cio_settle_write,
+	.proc_write_buf	= cio_settle_write,
 };
 
 static int __init cio_settle_init(void)

-- 
2.53.0

