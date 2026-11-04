Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821376;
	b=HUAlik21N8TPO9UUDMEVO23m72AWqxBFthd881PlyvqCM1/FjG1n+ffi0mrNsamLsxnE
	 n+snk67OLYW0u7+BZYQizmxfkvbLouzyhhgfsqxd5mRmKi46InuizOVDqdfw9UCiuZ0cd
	 s6tXovcFSck2ZjctfoHERI9Wa6IHts+tbFzdbC+/OPlmA5hOpVGEYOvo5Zwa5JPlGzJbZ
	 nFSlDOYP5dR0vporaaCWHWGnUxN+u7AQULWaHhOY7hh9xzIFTtNXDs04eDBZvt6a3yxVK
	 Go+92rbCPhGd4TazwqdyDI8wHsqVk+CoJ6PesJ8My6JOGt4H4Nmmm0jG27a1InXQMfA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821376;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=rahx1hspTnUUAQKpjFRic8Zz7t4Brzv8z/TuH1t1gO8=;
	b=dmeOD7ftfyWo/RvKYFJeGm8VoKNU34p2TnkUIDEsYgHHND9+/7U9kZa9p0MXk8hb/5kP
	 LKoI51lMaSGuLWRRgnijkVM5y8Lsf0AZe+NH2cUoYZ6+TxhHC/jvtuSip2nkgYoZGTOvp
	 WNmh1rSEVB6Zjo/k5G7qVO5Gh2Z1P0bBQnLTkuAnHL/Ee7I3q9Bz2kaexx2X0UIZrTTlt
	 xTZGRj1CCoap+Co8XODVCmTUlW54prHvUpCEXrayB0o84pWJQm5UBAVPT5M68ovZhowAC
	 fnT9S687mz9GMBgB5vGeTQ+EOApCGkpPyneMGaz9GsJD5ewnQTQKxcYST7BINTAQ0aw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=L+v8MGUB;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8D9DB6072F88;
	Wed,  4 Nov 2026 19:42:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=L+v8MGUB
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EDECB1F00A1C;
	Wed,  4 Nov 2026 19:42:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821376;
	bh=rahx1hspTnUUAQKpjFRic8Zz7t4Brzv8z/TuH1t1gO8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=L+v8MGUBoH1X/DvXSD0FceOQi/7/9SNVN/Ty1A0Db3pP2tRHNvduiU+oluwXEpYIv
	 vBloEcY3uuuLcYM/xkh9Q3Ii2iBnjyZbDio64xuo+SFrAPccC7M1STU5AfhNZaWOa5
	 +nP2mu+sMxiVgQETEU4GnEEdQBOVRnqy1LIn5OIvtUx8y3NHNRNYHmSudIvZhlAsk3
	 OeFfLyoqwVLhzDi55Du9gghVSwsVXKB+q9IGj4gdTIup4tw4O6Yjot81gM8SBfXGlP
	 DerjiZ0JrNRX2zN8YxL3cqjnpijuu2TiisPtmqNQmMQzMS3akxk6dzKVcJZYEqbHRC
	 UCnxPV/KjlSKw==
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
Subject: [PATCH RESEND v2 02/26] zorro: let procfs copy out reads
Date: Wed,  4 Nov 2026 20:42:41 +0100
Message-ID: <20261104-work-procfs-drivers-v2-2-245e54e87116@kernel.org>
In-Reply-To: <20261104-work-procfs-drivers-v2-0-245e54e87116@kernel.org>
References: <20261104-work-procfs-drivers-v2-0-245e54e87116@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1540; i=brauner@kernel.org; h=from:subject:message-id; bh=dTcni+P8tIxBcivisIxgfSpNG7N2UBKEyjWqJewPrL0=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97iqNXrF3deYLX61HjldsFnR/fLzW4ucS7htqmRfnb lp9iV3QsKOUhUGMi0FWTJHFod0kXG45T8Vmo0wNmDmsTCBDGLg4BWAiHkkMfziO9O96MiXH7oKe 3ttd/GcsTDguvkv8x6Mk19PlFNXPtoiRYf6v1T5HznUdqLi4/U2FCv/VOxZvpb9rrKvZvX3xnf1 XX/ICAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_read_buf() so procfs copies what is read from
/proc/bus/zorro/<slot> to userspace after it unpinned the entry.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/zorro/proc.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/zorro/proc.c b/drivers/zorro/proc.c
index 4c6f8f1c4d71..99a8b478192d 100644
--- a/drivers/zorro/proc.c
+++ b/drivers/zorro/proc.c
@@ -28,7 +28,7 @@ proc_bus_zorro_lseek(struct file *file, loff_t off, int whence)
 }
 
 static ssize_t
-proc_bus_zorro_read(struct file *file, char __user *buf, size_t nbytes, loff_t *ppos)
+proc_bus_zorro_read(struct file *file, char *buf, size_t nbytes, loff_t *ppos)
 {
 	struct zorro_dev *z = pde_data(file_inode(file));
 	struct ConfigDev cd;
@@ -49,8 +49,7 @@ proc_bus_zorro_read(struct file *file, char __user *buf, size_t nbytes, loff_t *
 	cd.cd_BoardAddr = cpu_to_be32(zorro_resource_start(z));
 	cd.cd_BoardSize = cpu_to_be32(zorro_resource_len(z));
 
-	if (copy_to_user(buf, (void *)&cd + pos, nbytes))
-		return -EFAULT;
+	memcpy(buf, (void *)&cd + pos, nbytes);
 	*ppos += nbytes;
 
 	return nbytes;
@@ -58,7 +57,7 @@ proc_bus_zorro_read(struct file *file, char __user *buf, size_t nbytes, loff_t *
 
 static const struct proc_ops bus_zorro_proc_ops = {
 	.proc_lseek	= proc_bus_zorro_lseek,
-	.proc_read	= proc_bus_zorro_read,
+	.proc_read_buf	= proc_bus_zorro_read,
 };
 
 static void * zorro_seq_start(struct seq_file *m, loff_t *pos)

-- 
2.53.0

