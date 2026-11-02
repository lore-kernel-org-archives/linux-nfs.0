Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793632344;
	b=0NEIMvvIYrpRFJ18AKkvpMH/H3fU5PkEN31lZY9tRtoTMdLfw3Gk51SE5JUnePQ3bABn
	 j2qfeX1buAtGck6QFLVmOJ3HIj6+64EuH8POBy4uNRqZFT3otSftImUplovsSAElwpFm1
	 p9Hylei3YnE4PTYwpDQAo3afjw/7DJBBlGUgxAMCba2Qxflvc8pU6GUMbt/bU9AuSOyLG
	 Zf0KRHTyWQogowJskm7NCLVbpvd3IDppktABA1DuXaqOAvxYT6E6LtpUE0yvJlqcCL4U8
	 lXUswRuyieel0pnIrLzUr+ZNymI0ry7M7C52RPGN83U8zl9bHYSJsW80x9/H9auiVyw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793632344;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=RGxB3CLuL3hdMOFW6c8rETuQc0/Gu93ks+OA3zHK0Kk=;
	b=37NohKSHcw+foYbAvmZRwPSBHw1IMzpv09BkgPu+jWlyY/wVcX2hqXggDPY7FSLvixUZ
	 h5UYw8+oOUksJJ0tS1yn1kkQ6j6nqsdp6L4GzMWZUxl5Hze9KZINjnjPeMfH/Ai4ujSc5
	 CGrdsM7KoN5z1R6MQUi1lVuOg8Qbl9GH3tcT1FC4QLeTrYuGNiZtR0tXZD8HimNTCNmdB
	 Ak6kVH1S6ArXfVLRJsaz5Xp0DcJryl8EjIRu6U4OOxc8vyqmb9MJ8Cnh9QrbFNxV7as4J
	 +KSE1xj8ZrW2sydVhmQ6OI0a+UXU08B5z9SnA0qDXQdi6hMdWS/p1JflAV1isUDAfjw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=edn0AYPt;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AE858606DEBF;
	Mon,  2 Nov 2026 15:12:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=edn0AYPt
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D82CE1F00A16;
	Mon,  2 Nov 2026 15:12:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793632343;
	bh=RGxB3CLuL3hdMOFW6c8rETuQc0/Gu93ks+OA3zHK0Kk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=edn0AYPt5jRwhzogids3xv0SIWD2ZJhmY0NQPvBljECs8aa0X00ejVbwi8wkj25C/
	 2U5H4P82mtq9mk7Gq7o6e3/c1q4G3kbagk9jpohANeLaXrMVCD+eHlCpevZFWYYYSS
	 zfdTR6xsYkavU1Yyn93mOd5uM9GVA/ziiwPly/tLPD8EKmEgx8k3MJ6ijWmLm10fQ5
	 aAJwWIQlFfdnqETK+vq3WSm6gSr6XKfcJMe7u/+KEhkto92jBEq1FJaT413U5aWoNC
	 fX2qVLNTgmiFU3l4keyd4RISYlleq5zE0TOEd/g/8NAtAr7PPLpG0OuAXPXHvgwwGx
	 A5koDE6WAQthg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:14 +0100
Subject: [PATCH RFC 07/23] s390/dasd: let procfs copy in writes to
 /proc/dasd/statistics
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
Message-Id: <20261102-work-procfs-drivers-v1-7-a994bd4d3b1a@kernel.org>
References: <20261102-work-procfs-drivers-v1-0-a994bd4d3b1a@kernel.org>
In-Reply-To: <20261102-work-procfs-drivers-v1-0-a994bd4d3b1a@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2121; i=brauner@kernel.org;
 h=from:subject:message-id; bh=tPoM7KW2jugAI3HBgjDAkvMMKrMKVevq5gq8BMZsIqc=;
 b=kA0DAAoWkcYbwGV43KIByyZiAGropzCjfwupU8fn9+VxtZv2ThSIu2nz9SfrAQKMYBoRl89VB
 Ih1BAAWCgAdFiEEQIc0Vx6nDHizMmkokcYbwGV43KIFAmropzAACgkQkcYbwGV43KL3vwEA7DgZ
 qwKtRcRruUUjfm5rBcGQ2NDy+57vyMOGubX9wNEBAPGDTMKrc7NwpMTdmoTSB/UBaD6PA7NAvur
 lg4LjKr4D
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Implement ->proc_write_buf() so procfs copies in what is written before
it pins the entry, and parse the command from that copy. Commands longer
than PAGE_SIZE - 1 bytes are rejected now instead of cut at 64k.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/s390/block/dasd_proc.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/s390/block/dasd_proc.c b/drivers/s390/block/dasd_proc.c
index 86399427f01d..6c3bbb7dfe85 100644
--- a/drivers/s390/block/dasd_proc.c
+++ b/drivers/s390/block/dasd_proc.c
@@ -15,7 +15,6 @@
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/seq_file.h>
-#include <linux/vmalloc.h>
 #include <linux/proc_fs.h>
 
 #include <asm/debug.h>
@@ -247,17 +246,15 @@ static int dasd_stats_proc_show(struct seq_file *m, void *v)
 }
 
 static ssize_t dasd_stats_proc_write(struct file *file,
-		const char __user *user_buf, size_t user_len, loff_t *pos)
+		char *buffer, size_t user_len, loff_t *pos)
 {
 #ifdef CONFIG_DASD_PROFILE
-	char *buffer, *str;
+	char *str;
 	int rc;
 
-	if (user_len > 65536)
-		user_len = 65536;
-	buffer = dasd_get_user_string(user_buf, user_len);
-	if (IS_ERR(buffer))
-		return PTR_ERR(buffer);
+	/* strip linefeed */
+	if (user_len && buffer[user_len - 1] == '\n')
+		buffer[user_len - 1] = 0;
 
 	/* check for valid verbs */
 	str = skip_spaces(buffer);
@@ -296,13 +293,11 @@ static ssize_t dasd_stats_proc_write(struct file *file,
 		pr_info("The statistics have been reset\n");
 	} else
 		goto out_parse_error;
-	vfree(buffer);
 	return user_len;
 out_parse_error:
 	rc = -EINVAL;
 	pr_warn("%s is not a supported value for /proc/dasd/statistics\n", str);
 out_error:
-	vfree(buffer);
 	return rc;
 #else
 	pr_warn("/proc/dasd/statistics: is not activated in this kernel\n");
@@ -312,7 +307,7 @@ out_error:
 
 static const struct proc_ops dasd_stats_proc_ops = {
 	.proc_show	= dasd_stats_proc_show,
-	.proc_write	= dasd_stats_proc_write,
+	.proc_write_buf	= dasd_stats_proc_write,
 };
 
 /*

-- 
2.53.0

