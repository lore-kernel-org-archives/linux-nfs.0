Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821174;
	b=f52SLtn4sOTGw1y/fdNOqxtUmOPkA9ipPpuP+DSRyD1m+bMcI0ohnova4mqWI3xDvZzi
	 ucl4yrcBtiYXUVoE4eTJxMNVItCMfSDOYC5dUuA3itWvd0iX0T4OUJZgAiLBJjAAqDPRP
	 DXXrL42Pn618EVzQfa6mBjvAGlAmMYpsXveaEONctYgFGCe/9I5Qu3bRqebMfZPatw1Z7
	 6rL0R/RfutLWEHirmTgF6bpvM1meonDH9nuh2lxcQD5nOnKnL39XRTIHDnKrO3toFgNb7
	 HrO5d6cYp8DKNqO6JJL30LbM4dZiQkyr4AmN1OGy4yS58ydIuJrMz9SbthPN8FgppOQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821174;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=OLir7M9bUqyYwhZJ8zktlBEIF8q4TgFqxNnhzWbUGpI=;
	b=VrrlTauqM2Dfxi/rzVT31sJX2iBEpO39MgH2E/GEtWAnX4rzq07esg6EbZQAOaNsn2m3
	 rErXooy+VP0pfY0VCf+XPTBOLmmKGGil+GFx3DIuMslHqTJ8b9KVsG3Hyr3L0vnA0tskH
	 y+qc9uLX7JlxYYnUzJiSHWE7xpfw/LO2b+/xJ5l09ANq4k9T8YMWCc9Lf8x2carKb52l8
	 nSGqSM7EEwck1UIu9pXNWT4wcNKypHrHRUtApDo3TgNy7n9bYAOOxsLZzq6uOelcRt6nO
	 EXwPiqJKlC1IqolJ3MAiuKioWeRGTIIsVifF/uRpYqiD1GL+V1EQaZkgGIHRxNZ8NEg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BGoQWKYK;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3951560A6F53;
	Wed,  4 Nov 2026 19:39:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BGoQWKYK
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8A1E51F000C1;
	Wed,  4 Nov 2026 19:39:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821173;
	bh=OLir7M9bUqyYwhZJ8zktlBEIF8q4TgFqxNnhzWbUGpI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=BGoQWKYKlGRHqH707lt8XPTrvhILrDN2CTBKW6sy4z5pHja4DdtN3raBG+NHLj92g
	 lT3j0AXWk+7UPpWWF1UqKr0teEMq0y/evuKx3wT6DI1igbFRETKr9nHjbLI1nR+NjU
	 nEQrgLu5V7p8Qbs7lNxg7pYdY0OS3AJ/InKacvNpa8Yy6bqqt2ucHdsOEUVuRjnglA
	 2neUJAv7gx7ca66gWQEIWKVKaKhIVOkX6ditAtUOyn0NGQtQzqUmcl3a3hd5YUr0He
	 y/DG+4nLiOv9JHOQGcWwzY6YiJ6Wsg6U5djleaHL/yx5FfWJcZpIQT5B9uaN3JkFIL
	 szVI5opji+ZoQ==
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
Subject: [PATCH RESEND v2 15/23] x86/mtrr: let procfs copy the ioctl arguments of /proc/mtrr
Date: Wed,  4 Nov 2026 20:39:19 +0100
Message-ID: <20261104-work-procfs-arch-v2-15-2aeb952c9597@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=5220; i=brauner@kernel.org; h=from:subject:message-id; bh=t9lK4yPSWnjPiNqpcmr+36rhqvijTQ7A+lZHV62u0/o=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97vj/uHT//LsHnab9aFnoUuZU1fZb4kuq29bvwVZqM xnei7cs7yhlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZjIbxlGhonnGEILvndsKS85 4PR6CvPGms8/XAXntzvM/P7oi4Bb8TJGhpu+z1R/eV2YMPmXmkv3oae5PxjPCl3dUPM/5vMn56O LV3IAAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_ioctl_buf() so procfs copies the arguments in before
it pins the entry and back out after unpinning it. The native and the
32-bit commands encode their arguments and share one table.
mtrr_ioctl() reads and fills procfs' copy, also in the 32-bit layouts.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/x86/kernel/cpu/mtrr/if.c | 79 +++++++++++++++++++++++++------------------
 1 file changed, 46 insertions(+), 33 deletions(-)

diff --git a/arch/x86/kernel/cpu/mtrr/if.c b/arch/x86/kernel/cpu/mtrr/if.c
index 038e2dc38797..9c33c0428dfe 100644
--- a/arch/x86/kernel/cpu/mtrr/if.c
+++ b/arch/x86/kernel/cpu/mtrr/if.c
@@ -149,7 +149,7 @@ mtrr_write(struct file *file, char *buf, size_t len, loff_t * ppos)
 }
 
 static long
-mtrr_ioctl(struct file *file, unsigned int cmd, unsigned long __arg)
+mtrr_ioctl(struct file *file, unsigned int cmd, void *arg)
 {
 	int err = 0;
 	mtrr_type type;
@@ -157,7 +157,6 @@ mtrr_ioctl(struct file *file, unsigned int cmd, unsigned long __arg)
 	unsigned long size;
 	struct mtrr_sentry sentry;
 	struct mtrr_gentry gentry;
-	void __user *arg = (void __user *) __arg;
 
 	memset(&gentry, 0, sizeof(gentry));
 
@@ -170,13 +169,11 @@ mtrr_ioctl(struct file *file, unsigned int cmd, unsigned long __arg)
 	case MTRRIOC_SET_PAGE_ENTRY:
 	case MTRRIOC_DEL_PAGE_ENTRY:
 	case MTRRIOC_KILL_PAGE_ENTRY:
-		if (copy_from_user(&sentry, arg, sizeof(sentry)))
-			return -EFAULT;
+		memcpy(&sentry, arg, sizeof(sentry));
 		break;
 	case MTRRIOC_GET_ENTRY:
 	case MTRRIOC_GET_PAGE_ENTRY:
-		if (copy_from_user(&gentry, arg, sizeof(gentry)))
-			return -EFAULT;
+		memcpy(&gentry, arg, sizeof(gentry));
 		break;
 #ifdef CONFIG_COMPAT
 	case MTRRIOC32_ADD_ENTRY:
@@ -187,27 +184,21 @@ mtrr_ioctl(struct file *file, unsigned int cmd, unsigned long __arg)
 	case MTRRIOC32_SET_PAGE_ENTRY:
 	case MTRRIOC32_DEL_PAGE_ENTRY:
 	case MTRRIOC32_KILL_PAGE_ENTRY: {
-		struct mtrr_sentry32 __user *s32;
+		struct mtrr_sentry32 *s32 = arg;
 
-		s32 = (struct mtrr_sentry32 __user *)__arg;
-		err = get_user(sentry.base, &s32->base);
-		err |= get_user(sentry.size, &s32->size);
-		err |= get_user(sentry.type, &s32->type);
-		if (err)
-			return err;
+		sentry.base = s32->base;
+		sentry.size = s32->size;
+		sentry.type = s32->type;
 		break;
 	}
 	case MTRRIOC32_GET_ENTRY:
 	case MTRRIOC32_GET_PAGE_ENTRY: {
-		struct mtrr_gentry32 __user *g32;
+		struct mtrr_gentry32 *g32 = arg;
 
-		g32 = (struct mtrr_gentry32 __user *)__arg;
-		err = get_user(gentry.regnum, &g32->regnum);
-		err |= get_user(gentry.base, &g32->base);
-		err |= get_user(gentry.size, &g32->size);
-		err |= get_user(gentry.type, &g32->type);
-		if (err)
-			return err;
+		gentry.regnum = g32->regnum;
+		gentry.base = g32->base;
+		gentry.size = g32->size;
+		gentry.type = g32->type;
 		break;
 	}
 #endif
@@ -312,19 +303,17 @@ mtrr_ioctl(struct file *file, unsigned int cmd, unsigned long __arg)
 	switch (cmd) {
 	case MTRRIOC_GET_ENTRY:
 	case MTRRIOC_GET_PAGE_ENTRY:
-		if (copy_to_user(arg, &gentry, sizeof(gentry)))
-			err = -EFAULT;
+		memcpy(arg, &gentry, sizeof(gentry));
 		break;
 #ifdef CONFIG_COMPAT
 	case MTRRIOC32_GET_ENTRY:
 	case MTRRIOC32_GET_PAGE_ENTRY: {
-		struct mtrr_gentry32 __user *g32;
+		struct mtrr_gentry32 *g32 = arg;
 
-		g32 = (struct mtrr_gentry32 __user *)__arg;
-		err = put_user(gentry.base, &g32->base);
-		err |= put_user(gentry.size, &g32->size);
-		err |= put_user(gentry.regnum, &g32->regnum);
-		err |= put_user(gentry.type, &g32->type);
+		g32->base = gentry.base;
+		g32->size = gentry.size;
+		g32->regnum = gentry.regnum;
+		g32->type = gentry.type;
 		break;
 	}
 #endif
@@ -393,14 +382,38 @@ static int mtrr_open(struct inode *inode, struct file *file)
 	return 0;
 }
 
+static const struct proc_ioctl_arg mtrr_ioctl_args[] = {
+	PROC_IOCTL_IOC(MTRRIOC_ADD_ENTRY),
+	PROC_IOCTL_IOC(MTRRIOC_SET_ENTRY),
+	PROC_IOCTL_IOC(MTRRIOC_DEL_ENTRY),
+	PROC_IOCTL_IOC(MTRRIOC_GET_ENTRY),
+	PROC_IOCTL_IOC(MTRRIOC_KILL_ENTRY),
+	PROC_IOCTL_IOC(MTRRIOC_ADD_PAGE_ENTRY),
+	PROC_IOCTL_IOC(MTRRIOC_SET_PAGE_ENTRY),
+	PROC_IOCTL_IOC(MTRRIOC_DEL_PAGE_ENTRY),
+	PROC_IOCTL_IOC(MTRRIOC_GET_PAGE_ENTRY),
+	PROC_IOCTL_IOC(MTRRIOC_KILL_PAGE_ENTRY),
+#ifdef CONFIG_COMPAT
+	PROC_IOCTL_IOC(MTRRIOC32_ADD_ENTRY),
+	PROC_IOCTL_IOC(MTRRIOC32_SET_ENTRY),
+	PROC_IOCTL_IOC(MTRRIOC32_DEL_ENTRY),
+	PROC_IOCTL_IOC(MTRRIOC32_GET_ENTRY),
+	PROC_IOCTL_IOC(MTRRIOC32_KILL_ENTRY),
+	PROC_IOCTL_IOC(MTRRIOC32_ADD_PAGE_ENTRY),
+	PROC_IOCTL_IOC(MTRRIOC32_SET_PAGE_ENTRY),
+	PROC_IOCTL_IOC(MTRRIOC32_DEL_PAGE_ENTRY),
+	PROC_IOCTL_IOC(MTRRIOC32_GET_PAGE_ENTRY),
+	PROC_IOCTL_IOC(MTRRIOC32_KILL_PAGE_ENTRY),
+#endif
+};
+
 static const struct proc_ops mtrr_proc_ops = {
 	.proc_show		= mtrr_seq_show,
 	.proc_open		= mtrr_open,
 	.proc_write_buf		= mtrr_write,
-	.proc_ioctl		= mtrr_ioctl,
-#ifdef CONFIG_COMPAT
-	.proc_compat_ioctl	= mtrr_ioctl,
-#endif
+	.proc_ioctl_buf		= mtrr_ioctl,
+	.proc_ioctl_args	= mtrr_ioctl_args,
+	.proc_nr_ioctl_args	= ARRAY_SIZE(mtrr_ioctl_args),
 	.proc_release		= mtrr_close,
 };
 

-- 
2.53.0

