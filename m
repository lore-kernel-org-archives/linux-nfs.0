Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821189;
	b=KbQ4A/coD6TJRrX1hxLi+mPEoQjmpzaeRWPZ0fKVc9GTVDLThxd3BV0Uj6Eb6ZbvOOQC
	 dTQg24KCtwZN8IWU7pK7Qzt77jikBKEg62wBuYuQxuN6AbRxqQHR9T1o88iQdX8EposcJ
	 TJCm99Su1IYz71UG4Oo4F9p7WgQnhhRMBUz0/24rzF7hyoU4JH2YdY89NKevLKoqjVLlQ
	 IcopMtLeQrkxNIk92iGlFLmPF/VxY1i1hSb1L4o9sg5mLxW8tg77AaBEZGf58PIiFt4k0
	 eJhhA3OJYG0l78vQDUgLD1c7f9tgsqaycdmlbYtONEa6PCNC9eeL74Anulree8PGgqw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821189;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=+6/VvbPNlgz2+gPXC5ytRZfMVcR9V1MzQDpcWQsb8Y0=;
	b=RXvC6wp3OTlQESK4lzpnwUay+6TKMS5T+SFdZ+LeeMWVru/SYU/WeeP9N+Pvi2XfYGxL
	 0Pq9OG5/ybr5TeQgDTAMSK9f9tf3sTUN3yqKwiirAgyi+QAkGGzJSNgdunsgGAYL9U9Ib
	 Buz227CQ8WfGlIkZqyv5aJrwjsxLfQ/d9yQktxSBBp+98PzrLDM77lXnHR/6l7XtMUosq
	 6rv92pd5DEuWxv1I2hn+UgTNI0MQ/bWjn70BqHYGlvHEBOOn8eAUpaPk1l9oTA41Ttihb
	 CDY9JpBuJCusLaz7uAfIgBFIytVrLcfbopmN+ykgwXORSkcls8HGUr2Uv4PJ2mKMOQg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mId0rHTF;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DE4E96071A00;
	Wed,  4 Nov 2026 19:39:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mId0rHTF
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7D6B01F000C1;
	Wed,  4 Nov 2026 19:39:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821188;
	bh=+6/VvbPNlgz2+gPXC5ytRZfMVcR9V1MzQDpcWQsb8Y0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=mId0rHTFGhaCS3sdYfAY6UrikABSq9514uoQ7GPPNOveDld4OAIzV+AP1cZ5+Ixn8
	 u7k6fo+fYf2fRgma3+s5wUNjWW3+eAUKQT5zf9pbgI2+BwxF5bFCL2tWyNW8KXBYBW
	 v4NzHbeNk5FZUX1OHygbkhxJYXzZJn+Y2YoHEOPW7SRj+yqGiqHwRElrmDCDAL/nhs
	 z7wZyWQuOB07rCVv/pujZRKQ5+vDxcpmumnJK/6BxNgfLAnpurmgFd/xiClBXHam+S
	 gz17fzUUfOxo8DS399IsxAuyLQ8HZywLsxKD4Yl0ICqZpYgzoxVKhiN/rxJyP/QGLA
	 jH2iDe3ufVuWg==
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
Subject: [PATCH RESEND v2 16/23] xtensa: simdisk: let procfs copy in writes
Date: Wed,  4 Nov 2026 20:39:34 +0100
Message-ID: <20261104-work-procfs-arch-v2-16-2aeb952c9597@kernel.org>
In-Reply-To: <20261104-work-procfs-arch-v2-0-2aeb952c9597@kernel.org>
References: <20261104-work-procfs-arch-v2-0-2aeb952c9597@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2191; i=brauner@kernel.org; h=from:subject:message-id; bh=CYWbl/ymSaa+aNKLZWQVP3B9Tfxpb2fN2gwcMDszgw8=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97mSwsF81Q+qzYrn2x3DTybM9wi12nvJmmnVCNNLjr 5Ey5wrnjlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgInse8nwP2drV3zO58/CxU67 rsubrYlJFcywLT3Csis1qG7hVNUP7Ax/xdm4jyrvPTzj5uuV2l3KAnG7rqWt63zAqn9rS3mOyGx 7fgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_write_buf() so procfs copies in what is written to the
simdisk files before it pins the entry, and take the file name from
that copy. The files took up to PAGE_SIZE bytes and keep doing that
through ->proc_write_size.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/xtensa/platforms/iss/simdisk.c | 26 ++++++++++----------------
 1 file changed, 10 insertions(+), 16 deletions(-)

diff --git a/arch/xtensa/platforms/iss/simdisk.c b/arch/xtensa/platforms/iss/simdisk.c
index 1248d960e5d3..26c2fa39a66e 100644
--- a/arch/xtensa/platforms/iss/simdisk.c
+++ b/arch/xtensa/platforms/iss/simdisk.c
@@ -241,7 +241,7 @@ static ssize_t proc_read_simdisk(struct file *file, char __user *buf,
 	ssize_t len;
 	char *temp;
 
-	/* a write sets at most a page, see proc_write_simdisk() */
+	/* a write sets at most a page, see simdisk_proc_ops */
 	temp = kmalloc(PAGE_SIZE + 2, GFP_KERNEL);
 	if (!temp)
 		return -ENOMEM;
@@ -255,40 +255,34 @@ static ssize_t proc_read_simdisk(struct file *file, char __user *buf,
 	return len;
 }
 
-static ssize_t proc_write_simdisk(struct file *file, const char __user *buf,
+static ssize_t proc_write_simdisk(struct file *file, char *buf,
 			size_t count, loff_t *ppos)
 {
-	char *tmp;
 	struct simdisk *dev = pde_data(file_inode(file));
 	int err;
 
-	if (count == 0 || count > PAGE_SIZE)
+	if (count == 0)
 		return -EINVAL;
 
-	tmp = memdup_user_nul(buf, count);
-	if (IS_ERR(tmp))
-		return PTR_ERR(tmp);
-
 	err = simdisk_detach(dev);
 	if (err != 0)
-		goto out_free;
+		return err;
 
-	if (count > 0 && tmp[count - 1] == '\n')
-		tmp[count - 1] = 0;
+	if (count > 0 && buf[count - 1] == '\n')
+		buf[count - 1] = 0;
 
-	if (tmp[0])
-		err = simdisk_attach(dev, tmp);
+	if (buf[0])
+		err = simdisk_attach(dev, buf);
 
 	if (err == 0)
 		err = count;
-out_free:
-	kfree(tmp);
 	return err;
 }
 
 static const struct proc_ops simdisk_proc_ops = {
 	.proc_read	= proc_read_simdisk,
-	.proc_write	= proc_write_simdisk,
+	.proc_write_buf	= proc_write_simdisk,
+	.proc_write_size = PAGE_SIZE,
 	.proc_lseek	= default_llseek,
 };
 

-- 
2.53.0

