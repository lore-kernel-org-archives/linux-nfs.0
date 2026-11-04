Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821896;
	b=TzXxoq9E/toFrojTF04ob6vmu2bCtjmGCMEiIAVDg8Qdm/Of5G2VUSFyfIFlV+jjqxct
	 H5NmDD2/hKeb5WcMXj3oJwvDOrTS1yv4nkmtRWMQP1BsOLdkk8+64xnrfnXdokMXaXSki
	 4msi5m4tnc7CWLS0YkGPJuy0izp4FNwEAoBmv9oR8/XSjUjnxd+Ga0oM1B3/VplvYjNIX
	 VUjTIsQvLafIqvRnYZO4RU2fcpgu4XLt/bE8xhHIOtPh5KfpKgQxtPdudrREGFvCMVh5e
	 x582WI646Khg/JWtQjCE1CotmCYfCDoPBWWWU6OL4JKmCI1O8ZUP+QSPLxxPLGyF6JQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821896;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=X/yvfG66BfgMeEDkk3c56eCZsjSg3r6CFhJDsqYaHrc=;
	b=kjfGocJuVGwOdXyPH+i9j0Ag2NqkPQEh6isxIKNi0kMMKuyvANpqhumQUa10fAZJExXj
	 eOUnjjD6/eCigdCF/ty4uUSNtaFbemDPMZf0gGsSeJxE2T/0GAu3xs+usy/11LZyIjaez
	 VKG3bbgNp29V1dP27EGNN9THszFjT9AtGRpweo230RNdeQMAArMUUOrpcllm6tTWRBGnf
	 duao7lQZ7ovivesYVmYyxvT6FsZlIT/jrQO0HJAg/kbVPqO4cHjVFH5qFtffw68FcG6Ly
	 qTMbB2CzkyGsep6tPNcGOsLjwyh7119P2fvOKa6A6Eehqmo6MhlOZlU9A6QfLdZX3Cg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cwHr8orF;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BF683606C448;
	Wed,  4 Nov 2026 19:51:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cwHr8orF
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1974F1F000C1;
	Wed,  4 Nov 2026 19:51:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821895;
	bh=X/yvfG66BfgMeEDkk3c56eCZsjSg3r6CFhJDsqYaHrc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=cwHr8orFnp4x7J2Xe1KsHSEJ1eg0u79nGPLRIUIwbAP0zUf7QsBysosf1FqR5ZX0Q
	 HoxOVOzOEv9f8ZgsLKaGizKxckb+8NmWDvznCxT9hyz6XDje23Fu/BV/7vYfSBlRBo
	 29q96vKA3sg+WRQgH3Xu5HAtJzyAV0C0X5mRTfioCWgSP85kQ3OB+8joip1pGF4lz6
	 O/KafZ2Qaez9U/HbkLZAPk5WcEVfLztKFegfM9NGRKV58MPrNpX3BlH061wFYzdEC1
	 0F3/Xa+OzEI16gZNDCtefEhvwseJTbeAB5Ppvs0OtDpq+EK5pYG3BV1CYUNRgxGUPi
	 Ziv71uisF0tng==
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
Subject: [PATCH RESEND v2 07/30] ntfs3: let procfs copy in writes to the label file
Date: Wed,  4 Nov 2026 20:51:20 +0100
Message-ID: <20261104-work-procfs-fs-v2-7-319e0f9a8aae@kernel.org>
In-Reply-To: <20261104-work-procfs-fs-v2-0-319e0f9a8aae@kernel.org>
References: <20261104-work-procfs-fs-v2-0-319e0f9a8aae@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2130; i=brauner@kernel.org; h=from:subject:message-id; bh=kxB3eQnJXJ28LS46eI6OZqVe3PV4LPZGCXrTLaq4dFQ=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97jH+72CqrHDmzhLOGyVf5VS7p01fvUvn0De7C5+m2 C7Q/px3v6OUhUGMi0FWTJHFod0kXG45T8Vmo0wNmDmsTCBDGLg4BWAiHx4yMpy3rZ0/Vbh5+gyZ wzeePF8kfWTR38C3305W5Fd5HDHp+GLF8E8x2XK+7nLuldutNvMse8PlwX1u7efe4OOL3l+evkZ A7hkjAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_write_buf() so procfs copies in what is written before
it pins the entry, and set the label from that copy. Writes larger than
PAGE_SIZE - 1 bytes fail with -EINVAL from procfs now. A write that
large only ever worked when most of it was trailing newlines or came
after a NUL, ntfs_set_label() refused a label that long with
-ENAMETOOLONG or -EFBIG.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/ntfs3/super.c | 27 +++++++++------------------
 1 file changed, 9 insertions(+), 18 deletions(-)

diff --git a/fs/ntfs3/super.c b/fs/ntfs3/super.c
index cd47839872b0..cdeccbe506e8 100644
--- a/fs/ntfs3/super.c
+++ b/fs/ntfs3/super.c
@@ -560,37 +560,28 @@ static int ntfs3_label_show(struct seq_file *m, void *o)
 }
 
 /* write /proc/fs/ntfs3/<dev>/label */
-static ssize_t ntfs3_label_write(struct file *file, const char __user *buffer,
-				 size_t count, loff_t *ppos)
+static ssize_t ntfs3_label_write(struct file *file, char *buf, size_t count,
+				 loff_t *ppos)
 {
 	int err;
 	struct super_block *sb = pde_data(file_inode(file));
-	ssize_t ret = count;
-	u8 *label;
+	size_t len = count;
 
 	if (sb_rdonly(sb))
 		return -EROFS;
 
-	label = memdup_user(buffer, count);
-	if (IS_ERR(label))
-		return PTR_ERR(label);
+	while (len > 0 && buf[len - 1] == '\n')
+		len -= 1;
 
-	while (ret > 0 && label[ret - 1] == '\n')
-		ret -= 1;
-
-	err = ntfs_set_label(sb->s_fs_info, label, ret);
+	err = ntfs_set_label(sb->s_fs_info, (u8 *)buf, len);
 
 	if (err < 0) {
 		ntfs_err(sb, "failed (%d) to write label", err);
-		ret = err;
-		goto out;
+		return err;
 	}
 
 	*ppos += count;
-	ret = count;
-out:
-	kfree(label);
-	return ret;
+	return count;
 }
 
 static const struct proc_ops ntfs3_volinfo_fops = {
@@ -599,7 +590,7 @@ static const struct proc_ops ntfs3_volinfo_fops = {
 
 static const struct proc_ops ntfs3_label_fops = {
 	.proc_show = ntfs3_label_show,
-	.proc_write = ntfs3_label_write,
+	.proc_write_buf = ntfs3_label_write,
 };
 
 static void ntfs_create_procdir(struct super_block *sb)

-- 
2.53.0

