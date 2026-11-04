Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821055;
	b=Dk5XZCsekEUoxsUiZG7dX+PkVnfaL+nkXErm5bhKvCffcqmUG4uYgZcpMyOyX+I6sAo0
	 Z7aZ1f2UGpPKEjEg/8rIzoIp8EAX39NIpJ6vO+oCzMkWJVQ/HI8/WTKw/8pSla35AgMiX
	 uyRQktS3Nw3+DsJ3g56FcZP8y+pHPZhF1k3B85MfCJhpDAnyXy7ZyQfOdeLNvWLxmjoG3
	 EVhs8q1JjpJF+jS9P01oEK0ZsCjdfPJI5NAzCewiQQyLReFqFxByAaf5RBHjZc4zEzrzM
	 51ADHfrI7TXTG66j4/9ylFPqzIsiUFZjQVyhIrHYCLTZTfEWQg5touOQ9p/4yWG6v5w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821055;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=FBXs+Ai9hCvv2gTN7UF7ctcncQyXKpM3GPgKiB4YAT8=;
	b=gBz6dmOubyjO1hiRoWxjF4scqgxXSCqBzHjURBY86Ju+dBDKmHrkePJX84rReSlFXmsl
	 4mI+akJY79sLhPAN12P7e89+baqE+oaOOquG6O62NreYo5IL4Vi8TanozQi3AH4H1sujo
	 o2hrKH5ugBob/SsFu+cuw+BindHAZpplNPMtsvJ1+0FzuQnkD/EpD/KDqOdiMmy0k4FSG
	 rxFKx81V7yg6aB34/MyEVYzvwjU3QVrazczBVhKwpH4ZWK3qPKMiRhdXWtdqwAB3l/ufY
	 jLKKB3FOvO1jsHl+x00Jel9B8RBchmTcnlVHtxJO63QPHjsSZiY4clvnJPa84OiKSwA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oZGa4uxN;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 65EA9607E738;
	Wed,  4 Nov 2026 19:37:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oZGa4uxN
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D8DB91F00919;
	Wed,  4 Nov 2026 19:37:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821055;
	bh=FBXs+Ai9hCvv2gTN7UF7ctcncQyXKpM3GPgKiB4YAT8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=oZGa4uxNa4f8lPnKCnZcOshs5bIS38FNrm9Me6KMthFTmP+MOwFabIXkXu/wyKAZr
	 eMuwJ+f88gJjEcbCjCfZt9K+REs55uNNlIGT+aTII7ZPio3yO+n12ryLYxF/Wa4AGF
	 RTs/sXBBLK+HuDFmMw4GQx8DcZDiGoyEhXa9KRIJsWTr/ApICfUXhkzLdIecTTSsZM
	 nHz+oFP0Qjh5+4b8BIeAsHx40sCyakErwgtYM1ptBy94JFV23RAvKVaGe6b4yCL5Fu
	 zKdbeftWi3Cfr5diHQHdPhNunK20Crp1slFjQ4GoZOScF/vgZqztop91HodBl1uB/4
	 9Lcb7Om7gZE0g==
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
Subject: [PATCH RESEND v2 07/23] powerpc/rtasd: let procfs own the wait queue of the rtas error log
Date: Wed,  4 Nov 2026 20:37:20 +0100
Message-ID: <20261104-work-procfs-arch-v2-7-2aeb952c9597@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1920; i=brauner@kernel.org; h=from:subject:message-id; bh=URY8OmvUYSj7cGs0MgqVpOcYmOKyD/AnlDpC5EfxAis=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97vhysuHhtP2XD0+QvcrjIThN4YyziduaSa0B5Ze45 bccDt8i3VHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjCRdXcYGf47m6tcV9TUtJW6 6rN1+ac5lkXuOyKb82c41N9Z+KfrawEjw4GOwjOGH8J1JW9/u80gYm/VabKvXdx4/nGt/Pjujku VLAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

rtas_log_poll() sleeps the poller on rtas_log_wait, which the blocking
read sleeps on as well. procfs owns the queue poll() uses now, so leave
the poll_wait() to it and wake its pollers along with the readers.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/powerpc/kernel/rtasd.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/arch/powerpc/kernel/rtasd.c b/arch/powerpc/kernel/rtasd.c
index 360ed2e30fd5..fa9574131f40 100644
--- a/arch/powerpc/kernel/rtasd.c
+++ b/arch/powerpc/kernel/rtasd.c
@@ -33,6 +33,7 @@
 static DEFINE_SPINLOCK(rtasd_log_lock);
 
 static DECLARE_WAIT_QUEUE_HEAD(rtas_log_wait);
+static struct proc_dir_entry *rtas_log_entry;
 
 static char *rtas_log_buf;
 static unsigned long rtas_log_start;
@@ -259,6 +260,7 @@ void pSeries_log_error(char *buf, unsigned int err_type, int fatal)
 		WARN_ON_ONCE(!irqs_disabled()); /* @@@ DEBUG @@@ */
 		spin_unlock_irqrestore(&rtasd_log_lock, s);
 		wake_up_interruptible(&rtas_log_wait);
+		proc_poll_notify(rtas_log_entry);
 		break;
 	case ERR_TYPE_KERNEL_PANIC:
 	default:
@@ -343,7 +345,6 @@ out:
 
 static __poll_t rtas_log_poll(struct file *file, poll_table * wait)
 {
-	poll_wait(file, &rtas_log_wait, wait);
 	if (rtas_log_size)
 		return EPOLLIN | EPOLLRDNORM;
 	return 0;
@@ -529,17 +530,15 @@ arch_initcall(rtas_event_scan_init);
 
 static int __init rtas_init(void)
 {
-	struct proc_dir_entry *entry;
-
 	if (!machine_is(pseries) && !machine_is(chrp))
 		return 0;
 
 	if (!rtas_log_buf)
 		return -ENODEV;
 
-	entry = proc_create("powerpc/rtas/error_log", 0400, NULL,
-			    &rtas_log_proc_ops);
-	if (!entry)
+	rtas_log_entry = proc_create("powerpc/rtas/error_log", 0400, NULL,
+				     &rtas_log_proc_ops);
+	if (!rtas_log_entry)
 		printk(KERN_ERR "Failed to create error_log proc entry\n");
 
 	return 0;

-- 
2.53.0

