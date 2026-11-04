Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821248;
	b=wjTYA/BFerLikYV2AqZatlkDESU/8Ga+7SW2wzDNUu+5MPNSfwiNpf0dcssJoceYjX7Z
	 X/njJX+8UlqB45//cwqVRhcB+z07HM/Gn7Z/51J5kRsSk9h0JNDO4oYq/Ku/kzkt3C5Lu
	 Rc7esj3Xut/tIoX494l7Ky/w83K07mhswbaErpL+6lMchmMzsG9PH4PkHxmq+wU+NQ+IJ
	 MkfrhWf95Py1SZvF9lKTQ48cW+sTKCueYdtw0YRb1DeOn8WgoBFLBNNW1GTwwwbm45WEs
	 WUrI0uM1cnDPstxSRe2VQm0EWbXLdwzsDuL/DVqyRizCG68KWLzgwLJCYRZdv/BqPgw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821248;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=ljglEsXifce2qfRBf9KQz9o848Hwgwzekl8g5JPLaig=;
	b=oxpMo+4K+GOqTFTUe3tku8uVY3YEvWcN6VawhTiU6GQQx7pymfM1OnD+pI9SH9b07sYM
	 FiQ8XCRsT1oZ+fYg6NNGazhuAWcHvmYrpUI8r6FhlVR/tvwa1mDdliLy372qfsNhsjdDj
	 Ubsq4Pn+Rlva4VilQlcj/8A56YDwn7CkoBvhlOBWCNwuFAlj75gC96gPLOEydFqJwudjr
	 XVAAkeyXrNMmR0znBOkuHVQI9zQ5wZYhiyV05Aya5jubJHrTL1qXpxKDtyeMtzGCU2ibV
	 Q2w8PGEPmhPYAZfmou1PJ/XmNHJyxNMkuciCR+rHGJB9aWhqmE1fce7TEEn6TIvcxGA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Wy0boZ5z;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 448136071A0E;
	Wed,  4 Nov 2026 19:40:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Wy0boZ5z
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9FC2E1F0093A;
	Wed,  4 Nov 2026 19:40:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821247;
	bh=ljglEsXifce2qfRBf9KQz9o848Hwgwzekl8g5JPLaig=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Wy0boZ5zanG430YNSID9PvLo8Hz+/29VvJoJ9WySCgaVz1GS+M9Ng0mKTlmCR6Sp3
	 Wy6SgMb3/VqyekYQ/1cR/jjtPSaurM/Udr3bvNEYMuoz7g7KxSi3hffidsqtPL6rT+
	 kNwUs9q+tNP6NBKx59NYF9AsYxVfTGuDi6XKbhHh4hcUsnEviZrGiHrP56E4+mGRvY
	 JVVBJqh6UNVAz2b97ZBb5pcE8f/kvEg6BQoxsArkq6nlESYRlG+raNwuWLjBL5Fegx
	 ogU0jkHe5zezEzx7v8f9ltgbWRNKY/tsEAVwKI2tVEh2fNgrnaN9ng+jA/EICHiT9S
	 CNdt1XlVegAtA==
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
Subject: [PATCH RESEND v2 20/23] platform/x86: thinkpad_acpi: let procfs copy in writes
Date: Wed,  4 Nov 2026 20:40:33 +0100
Message-ID: <20261104-work-procfs-arch-v2-20-2aeb952c9597@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1670; i=brauner@kernel.org; h=from:subject:message-id; bh=B1JM/SyKlO95qrS7p0kfKzr/VxkM25eIJbDMnht8OJo=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97mSx1F3VulFfxXnpV5EtBz+raF7cItzSzr37e8o/J X1NniM3O0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACZydikjw5J2aZXovIq/n3/0 ZQtu+2Fn9/PUc5+zb7fMOXwlwMPtzzxGhsertpXcs3gT5Xh92pP36mKWQvHOiqu49M5OudX+dnL TCTYA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_write_buf() so procfs copies in what is written to
/proc/acpi/ibm/* before it pins the entry, and hand that copy to
->write(). procfs already rejects writes larger than PAGE_SIZE - 1
bytes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/platform/x86/lenovo/thinkpad_acpi.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/platform/x86/lenovo/thinkpad_acpi.c b/drivers/platform/x86/lenovo/thinkpad_acpi.c
index 2ee208c82801..8287b36bd90d 100644
--- a/drivers/platform/x86/lenovo/thinkpad_acpi.c
+++ b/drivers/platform/x86/lenovo/thinkpad_acpi.c
@@ -882,7 +882,7 @@ static int dispatch_proc_show(struct seq_file *m, void *v)
 }
 
 static ssize_t dispatch_proc_write(struct file *file,
-			const char __user *userbuf,
+			char *buf,
 			size_t count, loff_t *pos)
 {
 	struct ibm_struct *ibm = pde_data(file_inode(file));
@@ -890,14 +890,8 @@ static ssize_t dispatch_proc_write(struct file *file,
 
 	if (!ibm || !ibm->write)
 		return -EINVAL;
-	if (count > PAGE_SIZE - 1)
-		return -EINVAL;
-
-	char *kernbuf __free(kfree) = memdup_user_nul(userbuf, count);
-	if (IS_ERR(kernbuf))
-		return PTR_ERR(kernbuf);
 
-	ret = ibm->write(kernbuf);
+	ret = ibm->write(buf);
 	if (ret)
 		return ret;
 
@@ -906,7 +900,7 @@ static ssize_t dispatch_proc_write(struct file *file,
 
 static const struct proc_ops dispatch_proc_ops = {
 	.proc_show	= dispatch_proc_show,
-	.proc_write	= dispatch_proc_write,
+	.proc_write_buf	= dispatch_proc_write,
 };
 
 /****************************************************************************

-- 
2.53.0

