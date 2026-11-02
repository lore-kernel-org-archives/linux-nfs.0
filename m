Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793633074;
	b=e/9n9vIFvZ4Tl8XTGoM1hIeDNIpr3CWxxf4twAgZyUxKc94hBbjKTdaHoK0fmhuYRl7h
	 4Hsgr0rVi9WSV5BsE42mKnPA/hW0uCCCAdltTQheXQwe4qAJITVhk+SXNZ0yocpjnBL5R
	 KBfx9SE16tcMsEkt8C/EJpac48HRcRazQmE+D199tE2FwPIbDJJgaaxnPf1rKJQwMF7Lf
	 QxpIzzLR/Zsa7uFMKRmSQeol8Ygzh4Vlk4ytA1oGpfASsD/XQdKadMwDLhNrgyRxdRvYT
	 ny2iVBRsqFsU5Wu4xS+FeOu1/SeiMjW4qdzJjzCD/Sld3G9LuokWAkPml9mTYU20gyw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793633074;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=oLmDMwPd5/E7rKj+sTJUI9YQ2nm5m+orCk4a0Hb3xdc=;
	b=e+oJGpYXue/inLjwN+k4oqr/vIh6zJgcWRyrSjbxtOKjOfadwVsjOhoBdGN0O6TFbcTe
	 UFVCILTdU/qI3ywLuoybniHoZxLDpJpfn8vFTp2XBP0X52ZgH8/Uigrf/ZeUxjm8tPF4m
	 qeEsn9geJm5i4TpqvZp8Wy6M+0FCeHu2IZ2e2t8CbS5gvMKMQ/rZWZcYyuHDLDK6jttlA
	 Hkm2cXs25X8zAc6F6vsVauuzAUjL2e130wqnQzgrk1PxijD2bR2C3JyGCz7ifW0bMxcP0
	 mR9bIUXzfAcPFoIO8hYtvNvn53OQjqtKtMEMa9uKDbkUrIJ+bgKmyFKnBuMNRx+M4Zg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=OegWozdU;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 79CFB60C959D;
	Mon,  2 Nov 2026 15:24:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=OegWozdU
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 012281F00A16;
	Mon,  2 Nov 2026 15:24:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793633074;
	bh=oLmDMwPd5/E7rKj+sTJUI9YQ2nm5m+orCk4a0Hb3xdc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=OegWozdUNrHGegNfTW2sm1HszSzrGzjh4ebMkWsD9u5gapIhy/O07QlRH3LV8M60J
	 //9uoOmD2XV9WnY62s/9qC5sYKTMOlS7YYqmfCV9USWy3TF92pR30R3sIC3bOI2cDl
	 eEYn+NqyCZgWe3RZrUPYTjFNI78jnhghKTiQ17RDj3pUBjadrdwq1A/MV0eG6aKps7
	 XvYJ1cpQlb/G4uhuL9+gJpBzSStLEg/xW7EREUkdqnqORUj3TCI9W+nv9Qji9Ee+7B
	 DnyLhoImoHxzQ28fH5V+87G43o48UQI/63qjJ9PF6kXAg+QKgEiJv0WhYMM43w1hXk
	 YkGa+9+0aqacQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:24 +0100
Subject: [PATCH RFC 14/27] profiling: let procfs copy in writes to
 /proc/profile
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
Message-Id: <20261102-work-procfs-fs-v1-14-d09a996317b3@kernel.org>
References: <20261102-work-procfs-fs-v1-0-d09a996317b3@kernel.org>
In-Reply-To: <20261102-work-procfs-fs-v1-0-d09a996317b3@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1504; i=brauner@kernel.org;
 h=from:subject:message-id; bh=ZtnZ7+j/OHZGj1nwL6jF9VPBdIcnJPmE5lAHJaT+bVk=;
 b=kA0DAAoWkcYbwGV43KIByyZiAGropzKjAwsxvRFdHBmiuO5usrlNmAf7XGR/a5n/gvJ3Bj8se
 oh1BAAWCgAdFiEEQIc0Vx6nDHizMmkokcYbwGV43KIFAmropzIACgkQkcYbwGV43KLjJQEA0hf3
 srBDq6EKvc+VG3c3zONfGz6/IVil9hzyZy3OB28A/RQHopfLUnFRNQfqy4yzV+dF++aZlDkaR57
 e/BjxgpoM
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Implement ->proc_write_buf() so procfs copies in what is written before
it pins the entry, and take the multiplier from that copy. Writes
larger than PAGE_SIZE - 1 bytes fail with -EINVAL now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 kernel/profile.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/kernel/profile.c b/kernel/profile.c
index e7defa90a34c..6e4b34f35e3b 100644
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

