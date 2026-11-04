Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821159;
	b=V+BceG3Zy46nVlae9Q2zBiOH+gtblTZl2WEGI9EFsNP+QxEbbcAMPi9Nv3+pu7DrhLJF
	 b4TZDCkZHZMZ3+PkS4XDS4+GJDQl9+QAV9j/IRkYdG3SJJHAj3WqG9gtgG6pHdH7QVf+U
	 BME9ZjkB3JCX6/AUQ3Z4OIFHIsGQ8iHa4tld/JuCeP4v4Ko4uRVCJLeumzM2R6EQeb/A6
	 s4vfDmwqfZKuRySSCWfPATGNWi5DPit66H/QXF2Mc96FqS82E5H+FlsECLWqF8JxHptLe
	 Hq2KqOH9z5qspUR6fldOPXvKRSWPagq0DLX6901cZ1UDhGgqlnKeI6leAbfcz2WPyAA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821159;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=08oqN1TE6XF/zda2aaIy/jJ7rzXSJoF5jY3Jq8EQn3I=;
	b=tjZ9yXAOM/ic0q+ifwfFkmAQpbf9i+zl4qyw0pO5CoiJrnJ1h7XNhPIoCOlSHAOxE6KF
	 rO8DusOEuh/9zg4CrDQoq11Nz7wSxoMVPIr8LcPPNs6hnYcznHTddcIWIJt1rWJhQie7I
	 eia6fcY8he2O1VBBNLONFFMtOQJ41+TK7NzNh9vBJEWFG2ivlFewYb/FgX0lbr9vZr6s2
	 rTqhUdfPg6mYn7ex4Ix+9DCyHz/eWZWUyFg8ntETEWeAgqrkkpB22U4NbhB0rSO+Dxb/b
	 SnKVRjt85V+oVxUnBFLZj3zaJMhW/BY8ARJP3n+RA138sYt0Kz+Fk22HViUcCvrKOoQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EaJvHiAM;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 64DCF6070F24;
	Wed,  4 Nov 2026 19:39:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EaJvHiAM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C8DC61F000C1;
	Wed,  4 Nov 2026 19:39:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821158;
	bh=08oqN1TE6XF/zda2aaIy/jJ7rzXSJoF5jY3Jq8EQn3I=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=EaJvHiAMOM44mJ4AYyNn4VsI9tCdPZkXSAVa50U3NrOibefU8zFHhtlwKggezxc6f
	 wnraA02g8NJXIrS3SZrOw/ckLDW5FYvi7jxpCw0K00BYbn5RYhILqubA1RmFr09QV/
	 k8Ctg/JVPDQToSJB15j4p4jKQY0itLX/D67pNlmoINjEoJlweC93iKdvLzgAObEB/x
	 Em9ifBMZxzKnjasz1lK0O58rkh4J6xzSeJOqNNv+26qOtx9ntPbRT5XujsHFDMwoNN
	 HTnCPQ1IABzvSMZrUrPP3tBDAg5ZtkrqubTQztGluNNIqQgLtUfcYWfLXYTWYVi5vn
	 yQ86hX5tNJ3+g==
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
Subject: [PATCH RESEND v2 14/23] x86/mtrr: let procfs copy in writes to /proc/mtrr
Date: Wed,  4 Nov 2026 20:39:04 +0100
Message-ID: <20261104-work-procfs-arch-v2-14-2aeb952c9597@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1645; i=brauner@kernel.org; h=from:subject:message-id; bh=soK7T1bbUsg7MQd+qkvxTDp2+B/10GD8og0zR7/9Z5c=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97vgbYnk5w1TAv+cR/19mB87Hxr1yYY5rHB54MaZe7 z00yU+vo5SFQYyLQVZMkcWh3SRcbjlPxWajTA2YOaxMIEMYuDgFYCKfFzEyTOHm/S1/MZHxwIv8 7dtPVu6S3Lllwdu7ZYHrrz/Q+cjbY83IsGb+7VvZO/dOnXhuMvvjlQVn3RZfi/jDsjPicIm1t/+ HZBYA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_write_buf() so procfs copies in what is written before
it pins the entry, and parse the command from that copy. Writes larger
than PAGE_SIZE - 1 bytes fail with -EINVAL now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/x86/kernel/cpu/mtrr/if.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/arch/x86/kernel/cpu/mtrr/if.c b/arch/x86/kernel/cpu/mtrr/if.c
index 9510e01d5103..038e2dc38797 100644
--- a/arch/x86/kernel/cpu/mtrr/if.c
+++ b/arch/x86/kernel/cpu/mtrr/if.c
@@ -91,7 +91,7 @@ mtrr_file_del(unsigned long base, unsigned long size,
  *    "base=%Lx size=%Lx type=%s" or "disable=%d"
  */
 static ssize_t
-mtrr_write(struct file *file, const char __user *buf, size_t len, loff_t * ppos)
+mtrr_write(struct file *file, char *buf, size_t len, loff_t * ppos)
 {
 	int i, err;
 	unsigned long reg;
@@ -103,9 +103,8 @@ mtrr_write(struct file *file, const char __user *buf, size_t len, loff_t * ppos)
 	memset(line, 0, LINE_SIZE);
 
 	len = min_t(size_t, len, LINE_SIZE - 1);
-	length = strncpy_from_user(line, buf, len);
-	if (length < 0)
-		return length;
+	length = strnlen(buf, len);
+	memcpy(line, buf, length);
 
 	ptr = line + length - 1;
 	if (length && *ptr == '\n')
@@ -397,7 +396,7 @@ static int mtrr_open(struct inode *inode, struct file *file)
 static const struct proc_ops mtrr_proc_ops = {
 	.proc_show		= mtrr_seq_show,
 	.proc_open		= mtrr_open,
-	.proc_write		= mtrr_write,
+	.proc_write_buf		= mtrr_write,
 	.proc_ioctl		= mtrr_ioctl,
 #ifdef CONFIG_COMPAT
 	.proc_compat_ioctl	= mtrr_ioctl,

-- 
2.53.0

