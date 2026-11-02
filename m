Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793629392;
	b=NxKfQ9lb6SaXb/XofOlaDplD5tN+QpsxmyJcIttBEw8X4L90pVVwHOxnP8TY9PWlcMcM
	 p/q550TDaGnuAgiMDCD8P+38lbSznFDLz+waMZrNqjWq2ziOdS3f1+HdKFFDsL5KhRgHG
	 1uYUWwkt1ccfWKsyt83Alu9qccFyqpHPMULJmaFEl/e2WMDEfuGSWsTXztNGJwNa/kCoR
	 SCa8Jd0hulAHqH6Tkp+8esqpXzbUHlva9i9Kq1sPpvW+41To9bs3HqEelsbIrJ8XrDUDD
	 IHvwowQldi6wwVxgz1V+E1tPwPZonglJ1c7lSWigWZmsfQcluCCv+XV0rQGF4U0jhjQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793629392;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=MVs7ALsfOLkn53l0kYUUme/SDUyhPHOVCY6QDFUmXzg=;
	b=KU6E5GJ+OjHqRRAZGa4APRK3qyYL+fgLIpIrVe4fbrtksijl8f+ufA3B/00S0P/QEb13
	 b//BtRZlZUYxa64ln3L9cD3qj25acbSVv1KnbVbN8bJ/LY1XT2W+NyZgxvN4uoMjyaoTb
	 nF24H5RuUCAPoshMCslv6p+xCF38vLBJCErbE56tbHapHoBpL5Gmjo54kYtWi9dOcdVMN
	 GothnBLTJXdlHlNdBfnCuXnbzI5QDLJ/fa9e0n3EbLnkY32cU3VFPiSt2j42diZAs6PKE
	 0v/uyqe+9Tk9I3y4zonP2Udc7ZbW3eibkEvJ4tofUMYIL1SAQnH26PYr/hz//4C3cJw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FLfR5DFe;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E8592606B1D9;
	Mon,  2 Nov 2026 14:23:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FLfR5DFe
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 38CDA1F00A16;
	Mon,  2 Nov 2026 14:22:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793629391;
	bh=MVs7ALsfOLkn53l0kYUUme/SDUyhPHOVCY6QDFUmXzg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=FLfR5DFeQsSly/cabaQC7e9iY2bQ9zaa9/+MREBD4BU88eN1Xx3KqTRtm3qYQYpfl
	 kCDavrMTvPYKs/rYn9gptjjElebcf4yPuRmKH7HVcqjqazHfqUR/Htiq7M6QYbzt4U
	 zWa4rzDSZK1q8pK7OQVMGrLrU+xIoyILoyQv+YpF94q5kGFQx5QO63A+aw0aYwigp7
	 8QwH/5quUO5K2fuIJpTTFlJf5GF8Ltsg0OQYaZW1HbdncmCkutEph8u81EsuVQiORQ
	 PSv2MLOMncLKFj4vxCZCl4sIAOggQ39Y2OGr1AHxp6406Vqv9fSst95zy3PsIJt0ea
	 Hqf1VPSexzNvw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:21:21 +0100
Subject: [PATCH RFC 06/38] xtensa: simdisk: don't read the file name
 without the lock
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
Message-Id: <20261102-work-procfs-bugfixes-v1-6-59422ed3e465@kernel.org>
References: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
In-Reply-To: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
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
 Chuck Lever <cel@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1811; i=brauner@kernel.org;
 h=from:subject:message-id; bh=VTDmn8Fj5UlymIH+0OFfDD9d3Id2xocQBgXcavnnib4=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9mJP1/VRcytoDLK0ufy3WLzr3+sXFE+dzGyTVYqofd
 O+7u3tWckcpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBEUkQZ/rs27hJY5+amu8Rq
 WoJCkbXlpumL4jqiOpe4HNF66TkndBkjwwvt4L3fvCaeXKnVx7hb7eIq/dqmQN78dydXJQe4lqT
 uZgEA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

proc_read_simdisk() looks at dev->filename without holding dev->lock. A
write to the same file detaches the disk and frees the name under the
lock, so a concurrent reader can copy out freed memory. Copy the name
with the lock held.

Fixes: b6c7e873daf7 ("xtensa: ISS: add host file-based simulated disk")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/xtensa/platforms/iss/simdisk.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/arch/xtensa/platforms/iss/simdisk.c b/arch/xtensa/platforms/iss/simdisk.c
index a2ddb49c269d..7b115e023de9 100644
--- a/arch/xtensa/platforms/iss/simdisk.c
+++ b/arch/xtensa/platforms/iss/simdisk.c
@@ -238,22 +238,21 @@ static ssize_t proc_read_simdisk(struct file *file, char __user *buf,
 			size_t size, loff_t *ppos)
 {
 	struct simdisk *dev = pde_data(file_inode(file));
-	const char *s = dev->filename;
-	if (s) {
-		ssize_t len = strlen(s);
-		char *temp = kmalloc(len + 2, GFP_KERNEL);
+	ssize_t len;
+	char *temp;
 
-		if (!temp)
-			return -ENOMEM;
+	/* a write sets at most a page, see proc_write_simdisk() */
+	temp = kmalloc(PAGE_SIZE + 2, GFP_KERNEL);
+	if (!temp)
+		return -ENOMEM;
 
-		len = scnprintf(temp, len + 2, "%s\n", s);
-		len = simple_read_from_buffer(buf, size, ppos,
-					      temp, len);
+	spin_lock(&dev->lock);
+	len = scnprintf(temp, PAGE_SIZE + 2, "%s\n", dev->filename ?: "");
+	spin_unlock(&dev->lock);
 
-		kfree(temp);
-		return len;
-	}
-	return simple_read_from_buffer(buf, size, ppos, "\n", 1);
+	len = simple_read_from_buffer(buf, size, ppos, temp, len);
+	kfree(temp);
+	return len;
 }
 
 static ssize_t proc_write_simdisk(struct file *file, const char __user *buf,

-- 
2.53.0

