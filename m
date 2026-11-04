Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820967;
	b=nbHoNWgi8eshoTZG33uuCx4QyveBPxuF1qpiCpPUvXLY1sK8R1fHzaKeLZmydE9Av0/b
	 mxVTN5j/8l/FcUkzZGFumFzayvwaFjoQuhT/dduSFU9hI/95JdEG18eUPVRjQn3MM88NG
	 Ov+dHwLE6qFtNjdQShz3r8JFW+c4z4Kzt/zoy6nfazpGGUqzU2U9UICiFq4FXxsLZxmou
	 LW1oOxAmxBtF89lKXAklIGQ6ad6Vz5gEaqfG9rRCKXpz5ZQTdehk5+nGGgi408G708tDa
	 ZDuSRDXDJKAk5WR1tFkjNA5ZwuxyNUdIBXFvum0oz/Go4gHXP1x8Mer3Xc56RHBSeNg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820967;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=RCWYzTdROaZ//Ublq96X/PsjFPNs26aKqDomYMjplOg=;
	b=tFAKMHa4gu2r2D+XwtMTixxXGmmMTtXWsiaoKcJeYEBgLhUey+3byxc4r/lrsoxl/B+1
	 fgR5zBiHuCpjFvv+InMdR6SgTG5uHDWpWPU84csPWiSuEEAu6rpqUIRgEmBpV2PKol/rd
	 xrh3MZkzkd7vb2hiUAIti17vB4DXm1qzCY4NvynqGkcAxf1kDqdnj4x3jo62DhFawa2NC
	 vy6IcQXAQMKouwpJg4o3WYkLjJHo24NzzdJ8i+ckxkU0X7hqdms06U1uqCGkGEWLgFuwQ
	 OeAIV9PoLcBD3z1gpgRVl9x5JgbqTQ/Ose3wsTcwzxkhfjjZ7FyTm7ebhZyqDl88Nbg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="ME/FJRfX";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C075D606FAC9;
	Wed,  4 Nov 2026 19:36:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ME/FJRfX
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 95AA31F000C1;
	Wed,  4 Nov 2026 19:35:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820966;
	bh=RCWYzTdROaZ//Ublq96X/PsjFPNs26aKqDomYMjplOg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ME/FJRfXHJFiJdRPuFY8HbJeu+GJeM1uYMSHhRXC3OyCBFoBbHe/D+KeCbkSHUcc+
	 kLRnw4KPAQXBd/Lm2rxl+osnRqATeVzThclIJcTYxyw83fwPKWjsdttrzz2MJEJ/6F
	 npCV8gjOwaHDC61e0ru1NTfEA8b0b9x7dSf/HzSrhuivx0LurSS5jZoyjtt0F/X5HF
	 VXCm5Gcq8bWGfXJvVTfcnPDEXQVmN0yImiDrAgCIzYQ7ciRBherm+QOR9W6FvpFf9V
	 +E2b6pif2bObHvbMb8emuD8Je5Z+LHQE+m9YVr5ffRfEUXrIRpnoiS5t/MTpZE9nue
	 yYDTpnmmsO8rw==
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
Subject: [PATCH RESEND v2 01/23] alpha: srm_env: let procfs copy in writes
Date: Wed,  4 Nov 2026 20:35:52 +0100
Message-ID: <20261104-work-procfs-arch-v2-1-2aeb952c9597@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1631; i=brauner@kernel.org; h=from:subject:message-id; bh=ud6jo66qun6GxlQdhdvRvLMRIAP9XF8+raIGbqJmJWQ=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97ngrnBxmYyak9tmw1FJNeJLkRYtVzupn21htlqi1O tScYHfuKGVhEONikBVTZHFoNwmXW85TsdkoUwNmDisTyBAGLk4BmMjpJkaGRUtzVix3XJqTVWf1 dU6h87OwGM+PZ2ve597KXb144TfGWIZ/ZoovQk90zVv4S5HDJPnSp5RpZyfb5iyb8PbjaTdr44T nLAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_write_buf() so procfs copies in what is written to
/proc/srm_environment/* before it pins the entry, and hand that copy to
the console callback through the page it used before.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/alpha/kernel/srm_env.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/arch/alpha/kernel/srm_env.c b/arch/alpha/kernel/srm_env.c
index faafc2df7886..6a1742b09a82 100644
--- a/arch/alpha/kernel/srm_env.c
+++ b/arch/alpha/kernel/srm_env.c
@@ -81,7 +81,7 @@ static int srm_env_proc_show(struct seq_file *m, void *v)
 	return ret;
 }
 
-static ssize_t srm_env_proc_write(struct file *file, const char __user *buffer,
+static ssize_t srm_env_proc_write(struct file *file, char *buffer,
 				  size_t count, loff_t *pos)
 {
 	int res;
@@ -92,13 +92,8 @@ static ssize_t srm_env_proc_write(struct file *file, const char __user *buffer,
 	if (!buf)
 		return -ENOMEM;
 
-	res = -EINVAL;
-	if (count >= PAGE_SIZE)
-		goto out;
-
 	res = -EFAULT;
-	if (copy_from_user(buf, buffer, count))
-		goto out;
+	memcpy(buf, buffer, count);
 	buf[count] = '\0';
 
 	ret1 = callback_setenv(id, buf, count);
@@ -109,14 +104,13 @@ static ssize_t srm_env_proc_write(struct file *file, const char __user *buffer,
 		res = (int) ret1;
 	}
 
- out:
 	free_page((unsigned long)buf);
 	return res;
 }
 
 static const struct proc_ops srm_env_proc_ops = {
 	.proc_show	= srm_env_proc_show,
-	.proc_write	= srm_env_proc_write,
+	.proc_write_buf	= srm_env_proc_write,
 };
 
 static int __init

-- 
2.53.0

