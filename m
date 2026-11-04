Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821204;
	b=kTRDbx/nifpGBH9TRtVSowGz/xoxPSnsHi6acNUrmLXzoPJfHeZbA44kdiMqdo6cJM9P
	 XJFPaYni8zjKgDDM18mdfzT2b2wlEQcpBxieFEEGnnjOMccqqBlFtYRUZbYkYs45118aP
	 Xc9Syhu9ww0aG8nNsO+FlQKMAFQ9O6iqw2pPm8jZuHf/TzkzHCyXclBh8jx6z9rdfddrQ
	 OdumWeJIhxsrPVlt7NRSEUV1Hm57SJ2Wi+TsLcyQq4hWeDZyL7TesjAmSZ7kOMCyV5o3g
	 /sx0NRLa3fpWgbKIXtPCYeQpMJTYkAtpKt1vHQaPrNmCIopuj1zBLP38CGyvpmKplzQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821204;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=I1miZOwU+uS7OyZJ+vljGqgplXbL3g+w9Z/kHpw+0Ic=;
	b=BZIkSyvSlBgLxoksPDUZEhH95Ip1/C3w3/qpNCU3zjxWssI5tNPBgOyDfNzUsZPdfVoc
	 kafM+gUBMf0LhfpuoXcYhKTecQ9O5G61tGVjpBvummJhPE0g3eWO/+nHRSC0MvL0WnrlW
	 9H6Nw2pBo90dt4KBOPATabQ1NXpQvgwh0P1xI7/6XqVtyPQ3qq73I72qTmgDdDaaypp+G
	 5lAwVLgh8QHBKkH1Cl9uzER0L1r2KfXuIa9hNiLYYMSBPCOKJMv9o8n1e4zAFg13M3Pbl
	 XsmtqrW6L+m0Csbjj99lvZnsss73aNhKK4l2zKeXcS7mZByOG5RlI6vi9yU1GsA3zYg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iWisENYU;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CC72B6070F21;
	Wed,  4 Nov 2026 19:40:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iWisENYU
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 400AF1F000C1;
	Wed,  4 Nov 2026 19:39:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821203;
	bh=I1miZOwU+uS7OyZJ+vljGqgplXbL3g+w9Z/kHpw+0Ic=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=iWisENYUjAJsAzBSE3lGImGvChgp+BG03nV/9zJNmEmVEQqMUuspDJmWqJOL8vdCY
	 oHV2GpTw7nzhZ8YSayGsDUlJzGRv0ThytArIl/pXnKxEHGqUREbYMyptK2QRO4tWb+
	 0MJ2nNe6OsnVhX9kRXAgGrur5t53VezJ+BwOWZY1lK1M/S2AcooFeGbuJTcHh6MMK5
	 Q0olsGHFDarOPT5Tg5XxJr8bNViO7g5QRvPbnb/bbKcsghMepoAlwc9fQuisDpBdNj
	 xEFmyHVac3X4qFr6hW2l+JvJkyvtiVxI0WdyYW/zK53nj9PA2sh6Z3KYMrD0GYvMbO
	 MorJYVNGc2nSQ==
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
Subject: [PATCH RESEND v2 17/23] xtensa: simdisk: let procfs copy out reads
Date: Wed,  4 Nov 2026 20:39:48 +0100
Message-ID: <20261104-work-procfs-arch-v2-17-2aeb952c9597@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1498; i=brauner@kernel.org; h=from:subject:message-id; bh=lmVHOivhxd1ieO/qCxQCbfFgZys6nsQ8zrRpqRkdZ/o=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97mTUYCmvn7tj1bZ3nRPePsj/znEsO+Ut/5eb7fKhN Rlbli062VHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjAR3UKG/45fU9K/nja5HyLM 7nljky3/puSce6cM0zZzlOzMKnx6ch0jQ/vS7+rz7ONa9NtY1Yu1H+1jtI6Tci9wC2pP5fa2eZP IAwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_read_buf() so procfs copies what is read to userspace
after it unpinned the entry.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/xtensa/platforms/iss/simdisk.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/xtensa/platforms/iss/simdisk.c b/arch/xtensa/platforms/iss/simdisk.c
index 26c2fa39a66e..cfddfcd06be7 100644
--- a/arch/xtensa/platforms/iss/simdisk.c
+++ b/arch/xtensa/platforms/iss/simdisk.c
@@ -234,7 +234,7 @@ static int simdisk_detach(struct simdisk *dev)
 	return err;
 }
 
-static ssize_t proc_read_simdisk(struct file *file, char __user *buf,
+static ssize_t proc_read_simdisk(struct file *file, char *buf,
 			size_t size, loff_t *ppos)
 {
 	struct simdisk *dev = pde_data(file_inode(file));
@@ -250,7 +250,7 @@ static ssize_t proc_read_simdisk(struct file *file, char __user *buf,
 	len = scnprintf(temp, PAGE_SIZE + 2, "%s\n", dev->filename ?: "");
 	spin_unlock(&dev->lock);
 
-	len = simple_read_from_buffer(buf, size, ppos, temp, len);
+	len = memory_read_from_buffer(buf, size, ppos, temp, len);
 	kfree(temp);
 	return len;
 }
@@ -280,7 +280,7 @@ static ssize_t proc_write_simdisk(struct file *file, char *buf,
 }
 
 static const struct proc_ops simdisk_proc_ops = {
-	.proc_read	= proc_read_simdisk,
+	.proc_read_buf	= proc_read_simdisk,
 	.proc_write_buf	= proc_write_simdisk,
 	.proc_write_size = PAGE_SIZE,
 	.proc_lseek	= default_llseek,

-- 
2.53.0

