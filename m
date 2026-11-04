Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820996;
	b=0T5hipBjQi3ECyCuPwcb9Y94pGE3BFECp8myay3bcp9dlwI2AzweaDRf6OLQL6voi0uC
	 wAUSIkbnbKDohpG/D1HPt5emkS6NdHab9Oe4nFLdDn0SVbM1fFZabr92sedTkOgaACOe2
	 V9xnBJ8Aapik7s3nD0tnn8asFk36uJCl5vsAm+IlS5uQRpVvfq6vCtpdx2qRwaa/G9by0
	 +sxCoA7S0rXFYp2nv/8iE5Kdd8oVWKKX43rWW8T7sVUsCTf/8d18uuAWrPGJmV2PvBqWd
	 7zjx326z+cWHhiQ175038/TkZexVAK2RQOXQdpz93yD/6Wza19FfeLUtpkOp/iP9b6A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820996;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=pQQ1Vs9Ggdq4tGJpsZZ2KAKh5WKICEOKhSgV+25xKrE=;
	b=feQAgtShSC5rspWkqxK3peKCN3dqUouO4CCbm61+5+NsTw8E7FTFp488c2s+hAu0lNtS
	 8wE8vRHRezy/exHTPPrkTWTJamh8ifBSWC2FK4pgYH7tNd146CQEo8HzUTewAVMRATmr9
	 pBf8FM7SYBHnYdLjpSC3QwoPr1WoVL1SiBxRRWyGoGfNHc6foDFRV2GhgnlQjANDCaitt
	 dMd4GT226PZsJ3PQIAnZVItTyURhTqtG+VGeemDhuTrMAQsFSszP+ZhE+hm98S+IoI3yO
	 bVemH7gpfN2qgBz+bals5kMseq/WfffC5izfus8XPLXcTEKlrFM/Zu+WZFqD9gMoCNw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LE2xhvlf;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C68E1606D83B;
	Wed,  4 Nov 2026 19:36:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LE2xhvlf
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DC6AC1F00A17;
	Wed,  4 Nov 2026 19:36:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820995;
	bh=pQQ1Vs9Ggdq4tGJpsZZ2KAKh5WKICEOKhSgV+25xKrE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=LE2xhvlfg0ggjtQBi7k/yBWe0FPcdQ+k5fjG+wAjpCj+7mLg+pQWGjB8uBtCBJNXU
	 1hm3hiNz0BzNx64SJ+0v+umYt/gvnmwmjNeM7eZmZjkMKK3r7ZsY2rCE/cB6Vuoyyh
	 hIm4cNe2e5X+iWpnmRoQvIMbMtlTbV9ryhFiKp2B2qAh/B+heLylm9TXu09jUtvetc
	 89Djht6RVz/zMTf2pNKVsSpvsCd9UrC3EC7He4FCRXcjO86xQhz9K0fnAZaQmRvf1V
	 LQvwsJ7brRbuX4lwrdJ3+wt3Lk3D3kEIgaBKvZYk9sv9eiUC/NwIjt9LAfL6Wez6nR
	 7HlhFAAkWGJPA==
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
Subject: [PATCH RESEND v2 03/23] ARM: atags: let procfs copy out reads of /proc/atags
Date: Wed,  4 Nov 2026 20:36:21 +0100
Message-ID: <20261104-work-procfs-arch-v2-3-2aeb952c9597@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1063; i=brauner@kernel.org; h=from:subject:message-id; bh=T/gtJK8LVC1DZFUM73wYroC67tSKwFUXW93lvLyJ5ro=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97vgw51B0y7b3epsi2Y5kbPn1fPGCaewfFUu+1k53Z JidtfhtX0cpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBEOMsY/odG5F5OSDr8hjPk wnRp9d45CfqTm+89/PDpwqGEq92fBBoYGf4+yNE6FyxcodQt3qaa4nQ2ZtEpUeWA3P6OmgtKL/Z zswMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_read_buf() so procfs copies what is read to userspace
after it unpinned the entry.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/arm/kernel/atags_proc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/arm/kernel/atags_proc.c b/arch/arm/kernel/atags_proc.c
index 8411fbfbcb8b..ff28bf24dd30 100644
--- a/arch/arm/kernel/atags_proc.c
+++ b/arch/arm/kernel/atags_proc.c
@@ -10,15 +10,15 @@ struct buffer {
 	char data[] __counted_by(size);
 };
 
-static ssize_t atags_read(struct file *file, char __user *buf,
+static ssize_t atags_read(struct file *file, char *buf,
 			  size_t count, loff_t *ppos)
 {
 	struct buffer *b = pde_data(file_inode(file));
-	return simple_read_from_buffer(buf, count, ppos, b->data, b->size);
+	return memory_read_from_buffer(buf, count, ppos, b->data, b->size);
 }
 
 static const struct proc_ops atags_proc_ops = {
-	.proc_read	= atags_read,
+	.proc_read_buf	= atags_read,
 	.proc_lseek	= default_llseek,
 };
 

-- 
2.53.0

