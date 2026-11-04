Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793822002;
	b=ECuKG9HJ8gW2JjDJkubf4neGKb6WwQJfOZRuzRAKDupmrREc3sfNUCZzP+p/Isddiaiv
	 g9YN93iF2douLixEmxtLx3TDBb3vh/OqQRqgw6NYBsjkeySzcxUXg6RESmW86CGdfXqk7
	 XHA/BriDZ731eCWi1f8/oIwkg9OLI+ThIcGntgkoMpdcQYG5V0Y9A1NgAeiO6ydiGx3p6
	 xSwYj5zZS9XpbvHAvwie36zI4JCGvJq408pc3E1DTKsLiZSp/nv+FJciEd+oFWZkIU7fC
	 7KzXqK3UtVAng6WihomI3kj/0/eBixpAAln58KRNAJhKHCZG2sCCxGnfkRWMI4elvtg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793822002;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=4FMH8RRbXwyOGE4j1ACekL014/FVLGRJa3NjwiBwv4k=;
	b=JNBAmi0sONZBtWaEDcB8QgzjptMG+xE0AmdIQDA9RaR6h9UXHlHDZ1a3MjBZWdViHUV4
	 eEibfLOVv+xUfrzDoPJCl9tiaYHX9mHh5+Lbd5u56teHdfAxoJ3Vm4ITlZ9Ho+hoqDDWM
	 b7m8ht7zVuCuIiv5Nw4VY5U3G5Zkdjun+PZCVnDt3712xhx8ufv06fyOZdsD068u9nHk7
	 FrNdpPojZjxPjJyKtOehCyQ0dW31nP8w1ozce9DWK9BEKcW/RVAv/OrNlzjIeu4l6Khh8
	 ef3YpLqGtUhj+xTKO5tMei3BVq+joFQ0YI2IjysakxuOyt8RYk9c544ZSeawHhKO6NA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gqnu7WCa;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E17E2609693B;
	Wed,  4 Nov 2026 19:53:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gqnu7WCa
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1749F1F00919;
	Wed,  4 Nov 2026 19:53:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793822001;
	bh=4FMH8RRbXwyOGE4j1ACekL014/FVLGRJa3NjwiBwv4k=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=gqnu7WCank0HPKzxIIuR0c+Y7qFDIfOx4OhXQRsH+bwXeorJsZ7tfbWZNyh3GbhMt
	 NxTOPufkaHrp11YLfNa93/yXQ6n5h0z6fpBeg6Ly2XOx7LhglEYilynsq/HFu5e5m3
	 ATdWLZ7uW1x0Y8xMKxBVUpJaU7+YU0ZruYzah//QhnYRcr/O7neJgjfCiw3cbGeL0f
	 /scHMQ7wD59wgQWjLWITDYTvE8W4dpcfUNiJQWmwj5fEXCsq8JXV17jYeqe34cF0gX
	 jLq6ATZZOpXLQz2og6LqAuxsn4M17sNhw8oW2RQKUyiL2Rz59/u2T2Au+Zeqcz04DQ
	 gpufF/LrdsChg==
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
Subject: [PATCH RESEND v2 14/30] profiling: let procfs copy in writes to /proc/profile
Date: Wed,  4 Nov 2026 20:53:06 +0100
Message-ID: <20261104-work-procfs-fs-v2-14-319e0f9a8aae@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1504; i=brauner@kernel.org; h=from:subject:message-id; bh=acPYXqQQVYOg2sB+M+GQAGt+iBO20XAT2Sfl3M0drAc=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97rHOf25YKDbxbO9Bg6IFQW80Jrk2dVu9Wx+89J/Uj +nLeu/rdpSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEykIZiRYcq1Of62b8t3Tr08 3yy0w/fMvbrULi7+T2u03cst/b77X2BkOMOyo3gzb8Wco9XFOhk9DzgWqprLqslOEzaU3DZxl4A KIwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_write_buf() so procfs copies in what is written before
it pins the entry, and take the multiplier from that copy. Writes
larger than PAGE_SIZE - 1 bytes fail with -EINVAL now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 kernel/profile.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/kernel/profile.c b/kernel/profile.c
index 820d5ec909d4..dc2db66a77d2 100644
--- a/kernel/profile.c
+++ b/kernel/profile.c
@@ -189,16 +189,14 @@ int __weak setup_profiling_timer(unsigned mult)
  * Writing a 'profiling multiplier' value into it also re-sets the profiling
  * interrupt frequency, on architectures that support this.
  */
-static ssize_t write_profile(struct file *file, const char __user *buf,
-			     size_t count, loff_t *ppos)
+static ssize_t write_profile(struct file *file, char *buf, size_t count,
+			     loff_t *ppos)
 {
 #ifdef CONFIG_SMP
 	if (count == sizeof(int)) {
 		unsigned int multiplier;
 
-		if (copy_from_user(&multiplier, buf, sizeof(int)))
-			return -EFAULT;
-
+		memcpy(&multiplier, buf, sizeof(int));
 		if (setup_profiling_timer(multiplier))
 			return -EINVAL;
 	}
@@ -209,7 +207,7 @@ static ssize_t write_profile(struct file *file, const char __user *buf,
 
 static const struct proc_ops profile_proc_ops = {
 	.proc_read	= read_profile,
-	.proc_write	= write_profile,
+	.proc_write_buf	= write_profile,
 	.proc_lseek	= default_llseek,
 };
 

-- 
2.53.0

