Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793631897;
	b=AwmmcGiCCMW+lDaBOIu5X4dCdEp+z2f/oMCDJvOR69jyNfwP0lqD8uI0Nd6kehmO59R7
	 4h4A3lXVr4zrxgl5hWk6pXe8m0HzM4yVwLBDj64t1jReLJfQO4cYJuaGQoz9OFGy1bJAT
	 vvCf0OIa0gh0Rj+eYZ8p/lemadgYafGGKwdl3pVThqwg+VpeLW7XccSQZxd83Kf9j2zSV
	 wzvHZdtXzcjQKND8P8iBYvh/4ifhJ7OLc8kd8U11reC90yA4dzY2JO3vy5rjp9GfaS/Dc
	 zz9uvaDNFVam7sGZvQ4o16QPVAtksd3qK7aLXz7n3nRxth/qjmfF7EmC9LqFjROzyxw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793631897;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer;
	bh=7nrFZB8SEXLZU/mzbmWvrr/UMB/DFOM38jlkmOKcofA=;
	b=K6nhL6hiMCFs20Ijd2HPTYDalBmlFoIY8jX/olI9f18n9cOvqv3VuYEvTBOfIStB5s15
	 OU3LyqhW422yVov/rM8xEkZL1P9nWaQHDh8VLTEEXiH5BhSkWAdzr1uYwGP3IQA+yTiz5
	 6GAz4qC9ISjJBIMbgVROQ/lmGI6HctlNQqV5DPHA88U+Ghm473GBv1apzCb097Z7xCAuU
	 UGaRbzs7WKglYLk8CPHulWxyS37U703qVSf8JIbu9xfw5VPCNXpoLkBRnI/ZEKPqp5fgy
	 6viGwqsgHixfYE53sLA88ZRluGswIf5Q4yevaXWbnJDlnshhDirnAaFyok+ufvsS92g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="PWJB1/iB";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EAC9D609CDAF;
	Mon,  2 Nov 2026 15:04:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PWJB1/iB
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C841D1F00A16;
	Mon,  2 Nov 2026 15:04:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793631896;
	bh=7nrFZB8SEXLZU/mzbmWvrr/UMB/DFOM38jlkmOKcofA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=PWJB1/iBfhOBGJhYFAN08DibMR52AbswEVevpOPJlFFd/6YKCBFk0rjdPQlcIsJCu
	 M7wETxh7POrPS2R+Bxe8GmEN+ztbrfn17IFousp5Q45SpUKBKeMwCZa4HLCkdaAMTL
	 nGuwpeu7tYiAoCalRJnwkfTozxEROSln5Zntfv5jW4jL6w1IaglXpEtlA1N+4XsaUQ
	 ixKM+Nu24AeZWPtukuV1DIGkbYg3XlqbEgIkFveiguvX3I5APXV8ea+vTsUzrvxLhH
	 oQKy6vg2GUEAk0BT3S3W863rpi7gQfQhWY1o71BBu5E6HzUMTMlRLe2ZVsoDsvf6bw
	 X9nFDARzygnDg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:01:37 +0100
Subject: [PATCH RFC 10/22] sparc: led: let procfs copy in writes
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
Message-Id: <20261102-work-procfs-arch-v1-10-c9492ab08480@kernel.org>
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
/proc/led before it pins the entry, and parse the command from that
copy. Writes larger than PAGE_SIZE - 1 bytes fail with -EINVAL now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/sparc/kernel/led.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/arch/sparc/kernel/led.c b/arch/sparc/kernel/led.c
index 12400bb59ab8..01449b056cdd 100644
--- a/arch/sparc/kernel/led.c
+++ b/arch/sparc/kernel/led.c
@@ -60,17 +60,12 @@ static int led_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static ssize_t led_proc_write(struct file *file, const char __user *buffer,
+static ssize_t led_proc_write(struct file *file, char *buf,
 			      size_t count, loff_t *ppos)
 {
-	char *buf = NULL;
-
 	if (count > LED_MAX_LENGTH)
 		count = LED_MAX_LENGTH;
-
-	buf = memdup_user_nul(buffer, count);
-	if (IS_ERR(buf))
-		return PTR_ERR(buf);
+	buf[count] = '\0';
 
 	/* work around \n when echo'ing into proc */
 	if (count > 0 && buf[count - 1] == '\n')
@@ -95,14 +90,12 @@ static ssize_t led_proc_write(struct file *file, const char __user *buffer,
 		auxio_set_led(AUXIO_LED_OFF);
 	}
 
-	kfree(buf);
-
 	return count;
 }
 
 static const struct proc_ops led_proc_ops = {
 	.proc_show	= led_proc_show,
-	.proc_write	= led_proc_write,
+	.proc_write_buf	= led_proc_write,
 };
 #endif
 

-- 
2.53.0

