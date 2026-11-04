Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821085;
	b=VkYEn9Pp6DqoqGMSVqyH4RPF+DX5AI06TnhlmPjEB73Y4NaTekd5lpJl20esrdLm8pyj
	 RxIFE5xPUmNWjq6aO8/1Hrtpu5UMWprDTkyUq0l1GbO/81gTn7Z8RGEx6V82POsDWc1GH
	 iNpgpVrRUJ299+Vo3Cl2BJXBdZkuyCMxHA+kgzy8Yic9gqdUVC1vkAS002eCKriqVpgP3
	 GJKNTpzhKHgrIMq3nzCvMejoFVy0XomnUwKPWgZ1vYy4gFYNNLeOQnNFwBGtFCfTk/oXP
	 hG+q3XCcaPd7u8W1AupVC8Rfx3q+AT4ZWxF13Vvxy/50eBFlWL9KDT+ODm1kAQedGNg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821085;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=K/nPdp0KTrkO/JWfX0DeaffmMq6r1stKUZ+oHzzOxP0=;
	b=3hHPyPBVw3qi03YyN6wHq6ZMeShAJkUbWJJfD2pOjDCvZfy7KXOqy+F9wy9WELrEd0CE
	 EpMqS7c3ro9MWZl5aT88Sv1aWsyOKAvhSg6fd7vgGgSqs5LFvHsHtrCz1Z+3vbmvrFqgS
	 2OtNGKcRgWbzP5kOQ1249oK3aSq5WntOC5IDdce/rPwdc3OqYXUhozc48SOM++AXxPF3B
	 liX2QeUA3xTMwLqZiQ2o1ENtdm8AjVq1X316JJlLmVhWQIW84XtLpuO2ZLVTvTZdmyK9+
	 HVAQzMtH3KxJgaKiGCA3IO1aFLFG8qf0b63YLQz13LSSxoB7Y+28JbOZ9jg5jYwLU8Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oLDqIOTw;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 10161607F96C;
	Wed,  4 Nov 2026 19:38:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oLDqIOTw
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8D9BF1F00A1B;
	Wed,  4 Nov 2026 19:37:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821084;
	bh=K/nPdp0KTrkO/JWfX0DeaffmMq6r1stKUZ+oHzzOxP0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=oLDqIOTwTl44qDXUKo0I6FzsXq0+ba0WjB4YCiCZU9JLqh15F/mdEZNy1ACYE+I0B
	 qPq4Ssz+iK/J+eJu6nff/NkdfEp6rYdZwfCVKcczyKz5fHXjpvVlG/Qm/dEw9ZL0xG
	 8PXHN37KmNVPmN5T23ck2GcUncr5vJ52nd5OFcXFUE5Goto+9up/68B7m4SIC6mV83
	 dUnBRd6UMVtOXc059f+OnYX0WXgqO/Uzy4tsZ8wr2OaUSvl2vGEki/eN5mj7meJO8a
	 M72qqDynVfbDFqAmqr+C62uIaJhArxnrmC/9rNVTKL6uBLhc9SJ6BYF+yeJf+SxLKs
	 ki60VRKb9D3jg==
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
Subject: [PATCH RESEND v2 09/23] powerpc/procfs: let procfs copy out reads of /proc/powerpc/systemcfg
Date: Wed,  4 Nov 2026 20:37:50 +0100
Message-ID: <20261104-work-procfs-arch-v2-9-2aeb952c9597@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1293; i=brauner@kernel.org; h=from:subject:message-id; bh=BKyq5EW+jipwXgvVj6hm7sFkYOn+uIZEAZe7arc6MQo=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97vjOI7W5OU2Ecf0JRpsD2T2N0rxx3fUCk8WEDn860 LbzeX1YRykLgxgXg6yYIotDu0m43HKeis1GmRowc1iZQIYwcHEKwERWv2T4Z/np554211z5HPtN Ea8e5coKrXxtW8d48eZXNxb/m5d+8jD8T260OtJsUDiLw3pdFscpPeXZpb3vZ9Y1ll1xmP9kwnc DJgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_read_buf() so procfs copies what is read to userspace
after it unpinned the entry.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/powerpc/kernel/proc_powerpc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/kernel/proc_powerpc.c b/arch/powerpc/kernel/proc_powerpc.c
index d083b4517065..46bc914d74b9 100644
--- a/arch/powerpc/kernel/proc_powerpc.c
+++ b/arch/powerpc/kernel/proc_powerpc.c
@@ -24,10 +24,10 @@ static loff_t page_map_seek(struct file *file, loff_t off, int whence)
 	return fixed_size_llseek(file, off, whence, PAGE_SIZE);
 }
 
-static ssize_t page_map_read( struct file *file, char __user *buf, size_t nbytes,
+static ssize_t page_map_read( struct file *file, char *buf, size_t nbytes,
 			      loff_t *ppos)
 {
-	return simple_read_from_buffer(buf, nbytes, ppos,
+	return memory_read_from_buffer(buf, nbytes, ppos,
 			pde_data(file_inode(file)), PAGE_SIZE);
 }
 
@@ -43,7 +43,7 @@ static int page_map_mmap( struct file *file, struct vm_area_struct *vma )
 
 static const struct proc_ops page_map_proc_ops = {
 	.proc_lseek	= page_map_seek,
-	.proc_read	= page_map_read,
+	.proc_read_buf	= page_map_read,
 	.proc_mmap	= page_map_mmap,
 };
 

-- 
2.53.0

