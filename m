Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821987;
	b=3DQ/4dswnA3YbQM6qsZAbITnyhLSKdCVqUqV0v4NxX8smMyKlLEpUCAJott0fn+D2GgZ
	 ULBdds40u9M0slSloPBkFY1faHg0m5dDr+JL3MfOxe9RwCXpHsA5EeFLfMFd9X1jM2+Ty
	 vkDh1tTchi60QptcO4SvdeL20YDYi9pXgHUrmPOxx4U24OMcqhUDjhdYtB/1LiiOu4Lkw
	 ZctPeWjDPWqMy4MDbw9usDVH6QanWGGDkPirpyGU4saHgqfiD0YDNKa3CPhxMGx294UmJ
	 IiDTPjQ/chfAD2uDvg4EjTgd1kongqP3/EyweAYqoPmcdr+k1Dg3jjGTqUkCk2bJIyw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821987;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=0DA6RuBvRtTkFqswtNQb2uYlEiZpU59l9tIHU1Ga2j8=;
	b=uiyCH7TFJXKccqVeZTQrkWeamgR5sfYDlm9WwDoUV29NcomWtDJagXGonhWbUcJxx8KX
	 ih9xSAfJTRbbF5ULLU85PeaKvUx7enkyCbL78GFYfYtxXW8JNrqFl11WTl2ZZg+1L3wfZ
	 7DiFBIE79jj2cpm7yrEe43zeGpc4oPmbEHGO4nJ0uMmjdxmmdEXcml7E24VvQ0hRylK0t
	 ObTH5AN4vfrmxCuEtbyOSOHauq8wOwNm9VG0RQOfuE0Fu464bYNtdr7FIlMrSsuOk2lZe
	 H1wejov76C4rAq0tyzNJTnoP0g6XE9OsaxUr2opCODbGt/Ohzzy4RwKmpE0vsVdn7qQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SRuzWbzB;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D5CD16096BE9;
	Wed,  4 Nov 2026 19:53:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SRuzWbzB
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 630E91F000C1;
	Wed,  4 Nov 2026 19:52:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821986;
	bh=0DA6RuBvRtTkFqswtNQb2uYlEiZpU59l9tIHU1Ga2j8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=SRuzWbzBA/Ayk18PSyfBxT/OLXbTcYla80E66c/JAUTNKWwvu8J+iV96HiiS6uEcH
	 QHS7YxPFtx6Ioglu8rsGqiQzEoeQ8bEbGSKEx4XN8omB6KX5mlTYTqW0Wk6eUgmEQB
	 B+z770ZN0h6sM7vDGdXR9zfXGIS1XJndXGgje4DTMOIYeLURXu2T1GmuCPMzPMxK7S
	 nurIEXlnG0ZIr4a8/L+heetwhEB8F1E5hs5NCWlfyBW+GWY4C/S4AmxGoDaGeMs9Vs
	 f5F7cAhX60Ts55MnyTtdNSbrqHrZaPAO/QFQ6TbKEkPr3xHro9JRcDthamnh6QpgBO
	 gt08JD3Kfhntg==
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
Subject: [PATCH RESEND v2 13/30] locking/lockdep: let procfs copy in writes to /proc/lock_stat
Date: Wed,  4 Nov 2026 20:52:51 +0100
Message-ID: <20261104-work-procfs-fs-v2-13-319e0f9a8aae@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1505; i=brauner@kernel.org; h=from:subject:message-id; bh=8vcSfGoyDeqLJaquRqiN2D+SQsNeRK8HAS3H3FbecE8=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97rEyKlv/n0U+Ncf4zZ0z/k8rXxQFN5xqvbLjdI24b /iyrX7bOkpZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACZSJsLIsDDpMX+EXH+FfOlz /4uiJpUibR6mKrvnlKufSe+7ojVxOyPDsftVl+Qu1LCnTp70o3zhxgUrJCWyJ/n6XbbhU5x210y eCQA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_write_buf() so procfs copies in what is written before
it pins the entry, and look at the first character of that copy. Writes
larger than PAGE_SIZE - 1 bytes fail with -EINVAL now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 kernel/locking/lockdep_proc.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/kernel/locking/lockdep_proc.c b/kernel/locking/lockdep_proc.c
index 9b034b5b94bd..2a66ea09c2aa 100644
--- a/kernel/locking/lockdep_proc.c
+++ b/kernel/locking/lockdep_proc.c
@@ -669,18 +669,14 @@ static int lock_stat_open(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static ssize_t lock_stat_write(struct file *file, const char __user *buf,
-			       size_t count, loff_t *ppos)
+static ssize_t lock_stat_write(struct file *file, char *buf, size_t count,
+			       loff_t *ppos)
 {
 	struct lock_class *class;
 	unsigned long idx;
-	char c;
 
 	if (count) {
-		if (get_user(c, buf))
-			return -EFAULT;
-
-		if (c != '0')
+		if (buf[0] != '0')
 			return count;
 
 		iterate_lock_classes(idx, class) {
@@ -703,7 +699,7 @@ static int lock_stat_release(struct inode *inode, struct file *file)
 static const struct proc_ops lock_stat_proc_ops = {
 	.proc_seq_ops	= &lockstat_ops,
 	.proc_open	= lock_stat_open,
-	.proc_write	= lock_stat_write,
+	.proc_write_buf	= lock_stat_write,
 	.proc_release	= lock_stat_release,
 };
 #endif /* CONFIG_LOCK_STAT */

-- 
2.53.0

