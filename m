Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793631864;
	b=WQBmiHPQW6qaDyK6/ADRsX78H4hiH8KMriZ2v+WmzjPPLG33QNuwVDCD3RVF7QHKPKOg
	 Qk6PT3wkEmm6fDJCDIfO7Q8fkH9Mn3R5mCCBcI/YwWrInRa+6joCJp8X5jCyCY37cMKFP
	 24pYhtW2k6IHO5/4zp9ubytOsf5OwjPPvCqcD0o9/7STZdmu/HM+0bIcrVwvIgRTEYqsL
	 3Op4xjeJVCZd8BBmvsf1jeYa6JSJ9gqSxxcjud19BhPbJqUTutGB6QdJeRfm0E8HNP0DQ
	 3MCed09ZiwL/Ro17pkiQPeMHSN4gYucYUppV7GjeCrNCP6VIRZc7OmiKBF6Nf25nJFg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793631864;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer;
	bh=K/nPdp0KTrkO/JWfX0DeaffmMq6r1stKUZ+oHzzOxP0=;
	b=ABaC6ksKwE7ptXGqtjP+WrBWmuz9g+Bgeqt7nPg7NvgqzLW2fox+t/RO2JhyRw/BIilr
	 Qyevkutrpj/XMHzgeuZHigETtpY/OvZjPqI7z8Dt14asDwuFxG+jAevbYMG5bo9gNUAa3
	 DQrC2Z131jmEafQRTDrY4M8IJrPn2B25g5zKqYGJ5e1w3nUk2YYN+M1eWSRGi1qTFBjYp
	 UZiJQTYQHPX7DioK8dyMrYZSt0KmV44j84bQRwSd5s3bxpOJh1C2061OYgh5Bphg1mHNa
	 CUZbfBLbYwqdKM8MxISEyK+H/K2FkcynC2ZDlPO0jU5tJsLpSQDUIy+rQETJAC9rPpQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hg5z4oUZ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EB15D60716D3;
	Mon,  2 Nov 2026 15:04:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hg5z4oUZ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 50CD51F00A18;
	Mon,  2 Nov 2026 15:04:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793631863;
	bh=K/nPdp0KTrkO/JWfX0DeaffmMq6r1stKUZ+oHzzOxP0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hg5z4oUZuRz8N20Z5C+Q8yL18Y5yCw7qLkDhvSa3q8JNmsjPQwjzQ+mMuPQCiWUbZ
	 Y7Lf4C3jcwYkPZM9FYjlQwVMt+IVrZBJileSjZkYaIPS9b5zUXk14WIw+JVn7EsOU4
	 X4PnMaia2Uw5JRPK0Y/IeoZ5Ktq3pARrGiaVdYugzvHIRDhsmeS/p/quiqvdz+vWfE
	 AUGhD3c15oSYVACYkUFkJnNm0xAkDzUFjRuKB9ZEAXO17dJeJqcdRtoI5OGF1GhbZ7
	 YQIqxbvutG2Qq9CRYrtQhXVKgITYMloJ1QVm1bR6wQ8dUbiyrra8iSth/icVuFpZ8E
	 UfEtn5MBXe+5g==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:01:35 +0100
Subject: [PATCH RFC 08/22] powerpc/procfs: let procfs copy out reads of
 /proc/powerpc/systemcfg
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
Message-Id: <20261102-work-procfs-arch-v1-8-c9492ab08480@kernel.org>
References: <20261102-work-procfs-arch-v1-0-c9492ab08480@kernel.org>
In-Reply-To: <20261102-work-procfs-arch-v1-0-c9492ab08480@kernel.org>
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
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev

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

