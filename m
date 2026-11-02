Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793631730;
	b=LkBaxhXRbO39H4zxvOqZskBLxqwkhxmAzze3J9UCPg7ZLZR6VXczf6c42FmgB3NNkPU+
	 MixOGFAHs5PnNonrUG5CqZ5BQLXV6QT72uEgAi41TSWYi3qQyvGQbGHEWIk+I0u5/e564
	 PzPskIHstXbvQ4l+R1xOo2+pGQBwzzpQsJuL4HIKVtzz4Rzd5hTG3u8f4rM83NyGOEHhK
	 VPUbKj1HJFBQsnJ5sc2mqggTLQkd8UC+2bhhmW9TWyosZa82OuhUcZu74J5Vw/CsnG8Lg
	 zM/fdrgxgTwSGNwfTeZf4d6laS71kcTVWHNqe3zOxtjmgsNcoN2VFo/jrS0DSsBM1Vg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793631730;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer;
	bh=RCWYzTdROaZ//Ublq96X/PsjFPNs26aKqDomYMjplOg=;
	b=lckN9cAUGC5kZRx4Y8UZdC9MgNauYSjrVpnZQ214OkOdltOBR0sQ93bWwZjCRYhOeIol
	 x5jWAu12B+WngZ80MI0SDaSuNlVFXnVjC2+wmkeHq4+czuxskLZ45FY4PAxqw3leKeuyp
	 7byY3TTth0uiO8LavAxdOtd1trUDwdUeHpK4mA+4kdJlsT1JvUtBLssptuSqECgDnmahL
	 qhJXYTcxwS2eW5Y71yI7Ok2pMtUAKND96IPJzjcxVXP2zWqwQjUI4XrKZEUbYqjSju3z6
	 I3wFZNaYH8L5iG0ExSGVfrWjs47xrxo0AyvHcwEDVLHCKc17s0AMntSer8YMSPHrezw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=g7GASIyP;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E95966080585;
	Mon,  2 Nov 2026 15:02:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=g7GASIyP
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CAB381F00A1C;
	Mon,  2 Nov 2026 15:01:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793631729;
	bh=RCWYzTdROaZ//Ublq96X/PsjFPNs26aKqDomYMjplOg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=g7GASIyP66iaHneT0IXLyxGE3Gv8uk+u36p3s2m270MYuKSf/lxqLAMSRJOW/mN5b
	 cqw43daYhwXjGaH+bT+uzWlv1RtJgVmK1pKNWgKadSoQ4YP7xysJZZNazw538Ya2w8
	 aQyWb7PBw6LuxEkCbQCuHEsb1KvYSgmQDTGlChVmndzt2sLknpmWaqisu0NyUvlM/y
	 hG208gvk6GSsXAzvoi3yhFcxnrvr/4f9iVDAGppDZvhr/8T+2kNPcVMo4GJLXJAgLG
	 J6pV+INZeS4SdtLtP2ZjONMRNNmVsgjQI6Fx9jjazJ3kAgIbreGUlE2x6BQYTDKlDz
	 uF54rLOl1jq1A==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:01:28 +0100
Subject: [PATCH RFC 01/22] alpha: srm_env: let procfs copy in writes
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
Message-Id: <20261102-work-procfs-arch-v1-1-c9492ab08480@kernel.org>
References: <20261102-work-procfs-arch-v1-0-c9492ab08480@kernel.org>
In-Reply-To: <20261102-work-procfs-arch-v1-0-c9492ab08480@kernel.org>
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

