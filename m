Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821233;
	b=hz+mBAMiCbNGPGu8rTne7r7iGbxPeeuf7SU3Nf+7J/DpBNQY3uQTiP/EpbiOj3QUoCzD
	 oDsOvbaQ6Ers12C/PD2+Or7U+LvE9EUY9zg0ZoSu3AeQ5Q2u3pm+KUQD98/hfF5X9IgxU
	 QlvLF2CBxq1mtJljkcbReCYOPUYbTzGZb+lAFE2SSW4KIUp1hVvBsewbmbCWNjklbcGSn
	 LsnlgfDe5jxRmXoTI+i+TfxCjqrixaU3bxF6RQIQYr3bZyj3DVqR+427tkroqg6wJSG+d
	 +z9TeAfG9AImiKfPCtswqYYWLae5vrhvB6Zd0+plnWbLnhEyd7agA4PEyFY/oPH5Tyg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821233;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=lzi0v2Iw6r5Nf2GLOsMSQBwdPNX93e2TzGzGfD3oQvk=;
	b=Db44dKjGlRjpwQciQWCC0TYHcnILKrGSL8VSvORW0GozggDmsn7b7XdbpvA5rYtpPw6T
	 1XmmMOUrePp4hWC4FpegS3GqPQXGuN9NCDOXoipQVJcw6B1AJ+YaCy3+m5WxUHSUk3os4
	 PZXy2+G1j9JuoZj0SpmfpforM9hpZ6YpYpUz1qByNVzO75mr2EDwXzvsAui3YVsL0p+4t
	 0REbWbipZsN9OatWfgWGRMI3FbKPqab+xpPua/dW6ksWQlT+CeSZnNRhGHhQXnGVgVhkZ
	 uM9iBfyk1zQs1/eaNEIuzG7LED66ltD3rHv/eLK+oRCgzvrprxtuBFTFZ62Gn8dTtGw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Kq+FKfxG;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7AD806080787;
	Wed,  4 Nov 2026 19:40:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Kq+FKfxG
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D0DEB1F0093A;
	Wed,  4 Nov 2026 19:40:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821233;
	bh=lzi0v2Iw6r5Nf2GLOsMSQBwdPNX93e2TzGzGfD3oQvk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Kq+FKfxGol1yZkTvQK7XOf4MJYg3n2wT++qWRo+QnGi9jvJMQIfuuwXxBQd6HrxO9
	 DzaQAB8BU2qMveOWYqXQf8uiF3jI1+TMalzy94+Rcd9plW4bEe5kD06s2YR2pJWce9
	 B6hFJWwiorAIE62RUnEWt3yo5nQlNa9h0jz+aofQy/98+6YVivsZ0C7K1SwAby0aHP
	 7T5oXbKe+XnQQnQPrW8rV5dPeOZRh0+N4R8p2Y7AHvXwgCCSGo3lTHp1Qs3mmTBfkR
	 oBUp+SJ51x7+DV6W8OrsLZe3q3dTzc8ph41dFrQv8E2WNRYsf3TxqVqdtFkK0eHuLm
	 os2hfJBqXQfoA==
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
Subject: [PATCH RESEND v2 19/23] macintosh/via-pmu: let procfs copy in writes to the options file
Date: Wed,  4 Nov 2026 20:40:18 +0100
Message-ID: <20261104-work-procfs-arch-v2-19-2aeb952c9597@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1397; i=brauner@kernel.org; h=from:subject:message-id; bh=agoZq1LJSKBxY7yRmppNE5tnXNWd/ezen+xLPyCzOnY=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97mReIrzh9cx53/g23f7T5yBxj/3Wz2cX8wsWTF3AP 1t597qLVR2lLAxiXAyyYoosDu0m4XLLeSo2G2VqwMxhZQIZwsDFKQAT2cTOyNC6JvPZMlEVDrlF 196Vxjt56Gn83yn6YN/2thy+Tlspl+0M/+xtty1ZFrFn7v65W/6uCr1fY7JaSuT8qnn7/y2e7Ma Rt5IfAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_write_buf() so procfs copies in what is written before
it pins the entry, and parse the option from that copy. Writes larger
than PAGE_SIZE - 1 bytes fail with -EINVAL now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/macintosh/via-pmu.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/macintosh/via-pmu.c b/drivers/macintosh/via-pmu.c
index 49f929ae10e4..079c085be5d2 100644
--- a/drivers/macintosh/via-pmu.c
+++ b/drivers/macintosh/via-pmu.c
@@ -913,7 +913,7 @@ static int pmu_options_proc_show(struct seq_file *m, void *v)
 }
 
 static ssize_t pmu_options_proc_write(struct file *file,
-		const char __user *buffer, size_t count, loff_t *pos)
+		char *buffer, size_t count, loff_t *pos)
 {
 	char tmp[33];
 	char *label, *val;
@@ -923,8 +923,7 @@ static ssize_t pmu_options_proc_write(struct file *file,
 		return -EINVAL;
 	if (count > 32)
 		count = 32;
-	if (copy_from_user(tmp, buffer, count))
-		return -EFAULT;
+	memcpy(tmp, buffer, count);
 	tmp[count] = 0;
 
 	label = tmp;
@@ -958,7 +957,7 @@ static ssize_t pmu_options_proc_write(struct file *file,
 
 static const struct proc_ops pmu_options_proc_ops = {
 	.proc_show	= pmu_options_proc_show,
-	.proc_write	= pmu_options_proc_write,
+	.proc_write_buf	= pmu_options_proc_write,
 };
 #endif
 

-- 
2.53.0

