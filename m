Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793822104;
	b=EK0xEZIwgo7+CDSNhWs79kEUy1qJO2kBZdwpAxpKiG5p/0wSPESS/FLxbCwusTJNf/UV
	 GM9uGlr6BP7qJKfxbjQugt27UZn3ol2WrrhnwCozqIJkV6O7MbJLvYqHrJ3NnRQAPa9bu
	 BUQxPfo5U/SQHemqO4IZhF8mCqRQhcTAX/jt+iG+gTrRuj1YCvkZEZxwQnuew9GlQGNzn
	 fY7qEcMmuSBwQPsZudEV9kbwEyCH25+Z75O4rsYX/BU3JZV2J2xBX5YPTz44w8uZ5MIfN
	 uURtnFuruBscmigZX6BZh3UcbAYWJi9izC4wx7CfQconPyfx0Wjtn8mxwFb2FYqHyIw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793822104;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=R1VqjUGL5+J0t5hj5seZeRe1Maiv3S9hp7Jj5OG0/0s=;
	b=3SPSzTSKxaNaUtepQ25YNGO4bzPgM41gEfDCXxd9korwpqtcm81ui2qGd+GzrHNl+NRR
	 8Dna2gfayDe51ucia+5m0S/XK/7DYeEWyw0Eup/0/HXORN5K0WzP+u9UK7BbTrwnHLYMA
	 dTqxpSfo2+7yyBMUZQg4Ux3CsxsluEU8tvmTXd3bw8yJqVSiL2XH82ygjH2eWogOHXYhp
	 FpuJrQFvN7CmYgjpTZIt0pHeVXqaDO7MvYXSiy0TzH5rxvZvgO/mARejSnarnwISVS3Pi
	 s1Q0xo4grivYC4UdOqLQLXQ8ha/ZSmwWBzyxVJFaGMir8sx0xUOawasrV2DYlOjiV9w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JrdQsd6G;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 36D5D6098F70;
	Wed,  4 Nov 2026 19:55:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JrdQsd6G
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2BDF51F00A16;
	Wed,  4 Nov 2026 19:54:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793822104;
	bh=R1VqjUGL5+J0t5hj5seZeRe1Maiv3S9hp7Jj5OG0/0s=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=JrdQsd6GTay34FYuGXCa8EK220wd8dcVKmmCUL2H6AN8qybgYu3VWX8QWdUPAcmTQ
	 k7Hh4kIxo+HBWYfqIhyCM4t5TutFpDBfRkmXCuGDnrCDs2kRigWisxosjbx2JTilsl
	 pRLqKsHm9QtEr1md47IXW0nBzRwFYpbJ+AsEXB9Aw5/BASW5ehNYPMEN3WtGHRfiwA
	 OzbZlgAyMFwrKZD+fvajfs9VLVkX7k/jZfqjP/IWM7eHh8GU1TOBliTxs7YYEjoU7C
	 tTvFESzDRyM4Rii2YLzF38phnQomDRBM6gq5STKW4qtXTlnb0Rqa4901faLCQGhySy
	 mMgweD+fFjsdQ==
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
Subject: [PATCH RESEND v2 21/30] kallsyms: let procfs own the seq_file of /proc/kallsyms
Date: Wed,  4 Nov 2026 20:54:49 +0100
Message-ID: <20261104-work-procfs-fs-v2-21-319e0f9a8aae@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1331; i=brauner@kernel.org; h=from:subject:message-id; bh=X1hXUo+P6dAEkQI4HVxBka/iuP3neD063cymPGxvXEU=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97nH59Orc+7n3eLifScgo8Jj8qyzNWnT19Mol2qc4a 58vWjHboqOUhUGMi0FWTJHFod0kXG45T8Vmo0wNmDmsTCBDGLg4BWAiPWcZ/nCKtL2fd32F2F95 vx9SGZf0t36r5ma6o/N8y3elH9e2NU1l+F8fo55wKcT3fXtS7NoKxUWhugwWHOV/0+b/kah+n3N uBjcA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Declare the seq_operations and the size of the iterator and let procfs
open and free the seq_file. ->proc_open() only initializes the iterator
now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 kernel/kallsyms.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/kernel/kallsyms.c b/kernel/kallsyms.c
index aec2f06858af..2d309fcee730 100644
--- a/kernel/kallsyms.c
+++ b/kernel/kallsyms.c
@@ -888,10 +888,9 @@ static int kallsyms_open(struct inode *inode, struct file *file)
 	 * s_start from where we left off, so we avoid doing
 	 * using get_symbol_offset for every symbol.
 	 */
-	struct kallsym_iter *iter;
-	iter = __seq_open_private(file, &kallsyms_op, sizeof(*iter));
-	if (!iter)
-		return -ENOMEM;
+	struct seq_file *m = file->private_data;
+	struct kallsym_iter *iter = m->private;
+
 	reset_iter(iter, 0);
 
 	/*
@@ -923,10 +922,9 @@ const char *kdb_walk_kallsyms(loff_t *pos)
 #endif	/* CONFIG_KGDB_KDB */
 
 static const struct proc_ops kallsyms_proc_ops = {
+	.proc_seq_ops	= &kallsyms_op,
+	.proc_state_size = sizeof(struct kallsym_iter),
 	.proc_open	= kallsyms_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= seq_release_private,
 };
 
 static int __init kallsyms_init(void)

-- 
2.53.0

