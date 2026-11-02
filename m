Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793631935;
	b=19v8rPw2rJUDSo+PSIdmM2HW0mErlwHQ/8l6whqljkEkpSCzbTs5Oir5Ft/CR30DDoPR
	 4fTXcayYr79z+jxsnwCFniNwPR/KB4ZiOAmz5IVmhyrudQlv6RUNhNgAm+Dg0fSzW6bDo
	 MnMYXUkDY0IjJKW+mFjhXiNkaerhZS+ip8xGiKWehkSrITD6LEWzVLm9gQz1570hf+ber
	 Qf748zm8o/Rg+A1Y2vZdvDRSLfpHOhQC1GpLKFGonssuFu7hfZC21N/Jv3WGQw6QgD6Ru
	 zOGOKYfCcICyTb8Bcqwbhd8NqYzfBBYBNCR8UZaULKd1QPLYuGC3DTLxeSVZzxDXJsw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793631935;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer;
	bh=2GaZul5nsAkiA2gFzaNhtmiz6cl7FK3FoYt1S3NMwg0=;
	b=5AhB56NQuFT1i/Q0XwYz9b2reHqKxhO3P5YYooXogdkgdOa54OGAKo+3n9AGoU8eVqrD
	 4uhaxqvd/zE3ScBmAC/vXRYspCE7Q98OWevZK/f3J6ZIyy3azAon8yer5I6jfjfL6UJ+g
	 Tfn2gDzfxBJNzph1hC1yW+Wcgah1uuE/W/xZrqMkZrXMFFz+I5Frf0Vlbm3mgqpeHHGFN
	 gOoEa+8AKMDNwGTnEngMDU4WtoW/9CKStPbTXTCLlQw1agZv0iiwONTPayXiEfXkROxbO
	 IlE9fYxvGznRmXQyK4zaihGG5xDegayr5JN+d7N91QBioricQMzLLVr/WChu6fRvCwQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gPYohCzD;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7D5BF6084434;
	Mon,  2 Nov 2026 15:05:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gPYohCzD
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BFC891F00A16;
	Mon,  2 Nov 2026 15:05:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793631935;
	bh=2GaZul5nsAkiA2gFzaNhtmiz6cl7FK3FoYt1S3NMwg0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=gPYohCzDqrsQn8T7TOjQzO9kH78swG2borvDZMC6jw8GKugG2jigIBNCmf3EfbRog
	 yxvhj7CSRV/sJqfNt6IzZWz7NbW/xuPFzaZzRxL8W9WId9cYqsYqwOpJnSNHd9Zx00
	 cVCWJlmHSPUqmOWftRxlfoYvxfeTa2bvDLbr+SmQTCQMClvPyfEa80ucz/9F7McAts
	 lpUGT6YWauh99d+fYUOnejKSIPRBXooAdLcFwky+UxQUTCrbGWHl0wHARoO6g8KLF4
	 jS4r3/hO+n7We6evEMM+LHhfwrC3xfWwpo3o7tQV451heeAi+52LI3LZMXaeoL+eQ8
	 lXFrvyo0JPSLQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:01:39 +0100
Subject: [PATCH RFC 12/22] x86/mtrr: let procfs own the seq_file of
 /proc/mtrr
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
Message-Id: <20261102-work-procfs-arch-v1-12-c9492ab08480@kernel.org>
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

Declare the show function and let procfs open and free the seq_file.
->proc_open() only does the checks now and ->proc_release() only drops
the MTRRs the file added.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/x86/kernel/cpu/mtrr/if.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/cpu/mtrr/if.c b/arch/x86/kernel/cpu/mtrr/if.c
index 4049235b1bfe..9510e01d5103 100644
--- a/arch/x86/kernel/cpu/mtrr/if.c
+++ b/arch/x86/kernel/cpu/mtrr/if.c
@@ -349,7 +349,7 @@ static int mtrr_close(struct inode *ino, struct file *file)
 		kfree(fcount);
 		FILE_FCOUNT(file) = NULL;
 	}
-	return single_release(ino, file);
+	return 0;
 }
 
 static int mtrr_seq_show(struct seq_file *seq, void *offset)
@@ -391,13 +391,12 @@ static int mtrr_open(struct inode *inode, struct file *file)
 		return -ENXIO;
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
-	return single_open(file, mtrr_seq_show, NULL);
+	return 0;
 }
 
 static const struct proc_ops mtrr_proc_ops = {
+	.proc_show		= mtrr_seq_show,
 	.proc_open		= mtrr_open,
-	.proc_read		= seq_read,
-	.proc_lseek		= seq_lseek,
 	.proc_write		= mtrr_write,
 	.proc_ioctl		= mtrr_ioctl,
 #ifdef CONFIG_COMPAT

-- 
2.53.0

