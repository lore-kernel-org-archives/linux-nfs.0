Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820080;
	b=qZR466aMeh4QgRe5q5AXuI8ea9c1oOkWYMscCF1tGopmUnANe4yb97i7yfQain7BE0TZ
	 AZlCLGTncM2jGlvJKEER++dYD+A28OfJ3qriXmWoAPJpbaAfO1OMb/jdg1JFJgalanolP
	 yP8WVrAffqnqWvc8qMA8i+RSAS7g1vVQwmYFioMcwxT4zqMk33zXP1aRr9hAPF8wtVKo+
	 zeDt0yoXAXltTIvIhseW0Fp7upfOoLX0RgE4oVlInbxZKUl0IihMEyp2Z9J88FhZ3zO4T
	 G9JZyQrTnXiCv0Hlp4K/1jy2WYSJdDnaHKUICOA09zO2RrPX4Rbh7BYRH0guw77u22g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820080;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=p9+kMzHwjVYuWJQ2+obB/IGMwn7xV7y09JcSQ7GHv6w=;
	b=v7KZ1fVRfZO0NSMi3LFU+6KOpuSSJE3JUnEjTIuDakkP8rgVQSQlKIR+LEpoUtYRnsu3
	 iJRtj3flSKcQpyGhFcK9SFVkoHKPZ4UeuMv9K7e2PcDBaOflGzzwyusd1RVx8ytAmaKA6
	 n/wSp8jkd9eBqGqhBv45TsAjVFDUKGz/xVDMRzk1SyLFxeG6n9h5CaYBIep/GfRGfsiUe
	 WPG6ZT8WvNpbh9jqCplYHyVdLlvPGdS9KaaKv/Ti1+Eg/5rd04cxEZaQ5Fz7qIf2/8rNQ
	 deDXdC+FAN3t12UsopZXxOoNLnDTZG0Y/48XIieJaD+XOZBXizSKjFgHXvjntTkH5Vg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Da9qhDAh;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86050606A855;
	Wed,  4 Nov 2026 19:21:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Da9qhDAh
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4AB7D1F000C1;
	Wed,  4 Nov 2026 19:21:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820080;
	bh=p9+kMzHwjVYuWJQ2+obB/IGMwn7xV7y09JcSQ7GHv6w=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Da9qhDAhe1gMlC4H3sEx9s8bGAWOfqOAYoq5Ueb9q8Ynl2389Maztmcp2QYHP5RUa
	 OZi38NVuKARinV0XCKJY4csd2ZWdhTyFIQtFYAj0HTzWZSV2i1vKEm7P7/Pts5FZCn
	 QcJTzEeOU9QU1jpuc0CN9kj/jSPx/znq777Ooa0/kAzqFdLCFoQLN31MunMZ6V42ul
	 zYUXtsChACfm6Z+hTrPGrAKTMgQ5FfXYR+IE5qTYw8gsFIqpDD7UrTt1lKIhy24azZ
	 jz8zin7Ffk74C14OK7JkiGN0Jj9FrbP13tt/L09oeijZ2cBW9SHXjgz22CRX5WoLnO
	 SiIObxm9KtSIA==
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
	Chuck Lever <cel@kernel.org>,
	stable@vger.kernel.org
Subject: [PATCH RESEND v2 21/51] powerpc/rtasd: zero the error log buffer
Date: Wed,  4 Nov 2026 20:21:06 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-21-021c84d852e0@kernel.org>
In-Reply-To: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
References: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1050; i=brauner@kernel.org; h=from:subject:message-id; bh=mkSbMC6ZDV5f4P2v+qDezcMlza9tkw/MXVPMWZSeje8=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bnx60+3VpD19ZT+7SySmfPjO+TBTt49lvc0+93eF3 4WPq6Z96ChlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZjIlBCGv0LG0fo2q8pr72Sl RxoY7Psg/0D2YuivaZvXryurm/TnzyVGhuV3JU9sXMk96YvRxJhvUz9Ozgtes07tY8uDXTNaVxx jf8kGAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

rtas_log_read() hands out a whole slot of the error log but
pSeries_log_error() only fills in the sequence number and the event,
which is usually a lot shorter. The rest of the slot is whatever
vmalloc() left there. Use vzalloc().

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/powerpc/kernel/rtasd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/powerpc/kernel/rtasd.c b/arch/powerpc/kernel/rtasd.c
index fd40864bdb70..dd0df5e164a3 100644
--- a/arch/powerpc/kernel/rtasd.c
+++ b/arch/powerpc/kernel/rtasd.c
@@ -523,7 +523,7 @@ static int __init rtas_event_scan_init(void)
 	rtas_error_log_max = rtas_get_error_log_max();
 	rtas_error_log_buffer_max = rtas_error_log_max + sizeof(int);
 
-	rtas_log_buf = vmalloc(array_size(LOG_NUMBER,
+	rtas_log_buf = vzalloc(array_size(LOG_NUMBER,
 					  rtas_error_log_buffer_max));
 	if (!rtas_log_buf) {
 		printk(KERN_ERR "rtasd: no memory\n");

-- 
2.53.0

