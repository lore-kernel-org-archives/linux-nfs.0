Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820981;
	b=gA4fe7h+tq840jIdX0PHTNJYgOSdUkHFi05GBcu9Ln0RMAFFDNxLmBzhwLHnpZ+xgIcf
	 M8I4ZY8TQkvClULHyXAEwZjZgk0yYgna9Ra2DjdeO4tQP5OwwoTpcMmAwK2OATC5BwdeT
	 1dd4kMgJH29st9INjrVsDfT4Do1C0u3+1vMm7nXujOM/cznLM80I4OeJU5MCAcmHrZWS2
	 YSJYuuA4PbL7jEeSiP6iLDJCPXKJIhR+Y8bUyUNlrNpkcChscHn6I86QZro+Z5m9b2PMa
	 XfivMt//hjnopeduAymFchA5yImEUVaa3qOKmPpQq8NrS3AYYZtL7I4kjREzhPZI8ag==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820981;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=qVgyj+FYQ9g7uHqmkN/6kOivRqdCDmjAyQM7m79vY9A=;
	b=f2BcunWSxT6mwj18miYzkptC2WLgi7x0wU/SI+I8ePcfYgbqBazN98cQtoGCCFoL5ivl
	 66+XXue887EBeGEj0lOX+hZzLvet6FgGDrHgnLSpm/Mf7nRiaaG7w5t31i3hODNYJI/oZ
	 HOSyf1T0XKFqpCd4Kpg9YfOvA1oQn+rlCUxA6Z9ovrtavSJh2NhAJ1yeCk5ki3HffGHIO
	 Lv5O5+BuMy7TZeIZwa9hX8aJ9t49RlfghR3vExpTRGjnlH3YhVGNpV0apwdf+k4gxCC6F
	 pF6bltenkHFQGXBlBe1cOTTKQ14xsSo1YqH3VU/g75qHSPTkJhoGZhtSEXbLN8p+d8g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=g53FbUkZ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5F8AC606FAD8;
	Wed,  4 Nov 2026 19:36:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=g53FbUkZ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3312C1F00A17;
	Wed,  4 Nov 2026 19:36:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820981;
	bh=qVgyj+FYQ9g7uHqmkN/6kOivRqdCDmjAyQM7m79vY9A=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=g53FbUkZCSWNwnfejXhy6s2nelprEnvO5Q4YohPFBJHS+h/+Bis4YhN2/N/AQPc6j
	 fzYwibXDmXurtiMkWQn5u+VqbndlNGJtHCg2mWpnoK5k3yXNh3AEwdUXjS/Wn8YgAp
	 DsbkdUjLTcZjtiVPGmJw8p0/O2ZWUM6qG/u1JQ1LS7FQsul73LZQiypnKRi3hmBJNn
	 pWa+EONoOhGPwjSkAXUgj9sc5Wf8Ushz0fe45yGX+M0rWNNO/OogEaHlzCPeH+AsK7
	 UOZddBvu39FXQ3nOy8HZZvj2XFYHPYSGv2QlAmtdpAP6TIhnKozmF8NTYKArJ9/gig
	 pdBxHcmOh0+mA==
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
Subject: [PATCH RESEND v2 02/23] ARM: alignment: let procfs copy in writes
Date: Wed,  4 Nov 2026 20:36:07 +0100
Message-ID: <20261104-work-procfs-arch-v2-2-2aeb952c9597@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1378; i=brauner@kernel.org; h=from:subject:message-id; bh=zhi1nqFEpiSFVRrnQoKgWCc9KudbEGTZB0sdbQtmzK0=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97njXfbbxoNI5d7tgS3+dmRcrGv6d2Z0Tv6xkukLGh 2eO1xfe6ihlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZiITgLDX+mF5S+vT7n7/+IW 5t66y78vbZh5fg+zoqqy103BXpsgljCGf/rni1NaxQ39Co13b8868UXRoW/v43tTZjz4Lhnc/Iu pmREA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_write_buf() so procfs copies in what is written to
/proc/cpu/alignment before it pins the entry, and take the mode from
that copy. Writes larger than PAGE_SIZE - 1 bytes fail with -EINVAL now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/arm/mm/alignment.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/arch/arm/mm/alignment.c b/arch/arm/mm/alignment.c
index 3e5e30968634..11ceefdfa388 100644
--- a/arch/arm/mm/alignment.c
+++ b/arch/arm/mm/alignment.c
@@ -144,14 +144,13 @@ static int alignment_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static ssize_t alignment_proc_write(struct file *file, const char __user *buffer,
+static ssize_t alignment_proc_write(struct file *file, char *buffer,
 				    size_t count, loff_t *pos)
 {
 	char mode;
 
 	if (count > 0) {
-		if (get_user(mode, buffer))
-			return -EFAULT;
+		mode = buffer[0];
 		if (mode >= '0' && mode <= '5')
 			ai_usermode = safe_usermode(mode - '0', true);
 	}
@@ -160,7 +159,7 @@ static ssize_t alignment_proc_write(struct file *file, const char __user *buffer
 
 static const struct proc_ops alignment_proc_ops = {
 	.proc_show	= alignment_proc_show,
-	.proc_write	= alignment_proc_write,
+	.proc_write_buf	= alignment_proc_write,
 };
 #endif /* CONFIG_PROC_FS */
 

-- 
2.53.0

