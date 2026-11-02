Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793631828;
	b=ag+1HigokzRXVh4RS3Roo3Cn/rO9yVfO+4diodaqQVhmYvkXeipYR3t/ZuaYXriyiBvQ
	 xGSEIVQQXjhwtEohZ5STEQRWYbki+sPheadeVkNS7AM5TvcoJg6Y1IwWKbkDlHRO1w9yS
	 eiOjJEauO3uioAZxAgF5VFc9rxXlVeWi9Cq8gujn+d4s+K3AUrNGMIYB2gKsA/xWX2CcI
	 myNX02wSkvQDSTtjTw3iaP0o6iInMyq4GLkdMnHxPUDHu6craA0SMynqZz99zGy6fse3q
	 Xpbm1cvblX00IpOR6XlMs2f2QOfCmpzycC9y+2l1jDGMWyG4LB19lv81jifAEloZ+8Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793631828;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer;
	bh=glw1dCbJy4In8cXqUP53v95R3+j+o1Gb2tGtrZFmQOQ=;
	b=LuwbTzaqhZV3udQrI8ItOLemZNN9O9ZcExprz64BC1WjtoeTZFyso76CrwBSmzISvk7G
	 WnaAE92tD/GbGQ7fkxWFv1c/TEiYB1NItxyaort7JN+jXqyUMJd0kGMj7WdRsFaFoXSWz
	 fMKQc9gMg31gQec12ua6ArAP57HUt0oQgJFebrHRSUowtioYhurrMt6FgyNA0KEqjpc2Z
	 OOYKBJMUNOkLCPmfV5LwHYhfg3J7GF0SdFJDNTr5o9xDB6ZT9sRSr/k2fIr2RmIRpyoBX
	 Qf3epmdggf9r7g6bBnCXe64s4v0AYshvbhYNj+T3mqAzR0pCNXnyo0eTQAaTqPDcXoQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gH1uQceN;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 144B6609B583;
	Mon,  2 Nov 2026 15:03:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gH1uQceN
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8DB191F00A1A;
	Mon,  2 Nov 2026 15:03:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793631827;
	bh=glw1dCbJy4In8cXqUP53v95R3+j+o1Gb2tGtrZFmQOQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=gH1uQceNT0pe04RugL3tkndtCg/BNWtt8gjyfjkjxpxrv4DD5Kj/ry0K4iVOfTu0T
	 XyqCfm2AIZe63dMJyEouauqLimhfpL7Ahx9TJUWfLtSMlGm6wbGGbzqxmjJDCoGvoi
	 8bXwyOHcBtFikAWlZHrtqTOUm7T60Rc1rGMBhy6wte8Tc2C2WHnRkyW6FZfLwJcAlt
	 QIxSWGPq1Pt9aUCZFw5Fr8TfPzVXromMNqTo4BfW3zJS3GdVdZxJ1jiE4RlzKmMIbu
	 NMgDHlNBEuimzLNekTMW7U7s+08uLY2Cp7ql1hPbJQuDeycC8awPE3b+o47F+6OePW
	 BX1NU0ZbhTSrg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:01:34 +0100
Subject: [PATCH RFC 07/22] powerpc/pseries: let procfs copy in writes
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
Message-Id: <20261102-work-procfs-arch-v1-7-c9492ab08480@kernel.org>
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

Implement ->proc_write_buf() for lparcfg, ofdt and the vcpudispatch
files so procfs copies in what is written before it pins the entry, and
parse what was written from that copy. ofdt takes as much as
memdup_user_nul() could copy before since device tree updates can be
large.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/powerpc/platforms/pseries/lpar.c     | 14 ++++++--------
 arch/powerpc/platforms/pseries/lparcfg.c  |  7 +++----
 arch/powerpc/platforms/pseries/reconfig.c | 22 ++++++++--------------
 3 files changed, 17 insertions(+), 26 deletions(-)

diff --git a/arch/powerpc/platforms/pseries/lpar.c b/arch/powerpc/platforms/pseries/lpar.c
index 48fe0be71a89..dfd027cc9047 100644
--- a/arch/powerpc/platforms/pseries/lpar.c
+++ b/arch/powerpc/platforms/pseries/lpar.c
@@ -498,7 +498,7 @@ static void dtl_worker_disable(unsigned long *time_limit)
 	up_write(&dtl_access_lock);
 }
 
-static ssize_t vcpudispatch_stats_write(struct file *file, const char __user *p,
+static ssize_t vcpudispatch_stats_write(struct file *file, char *p,
 		size_t count, loff_t *ppos)
 {
 	unsigned long time_limit = jiffies + HZ;
@@ -509,8 +509,7 @@ static ssize_t vcpudispatch_stats_write(struct file *file, const char __user *p,
 	if (count > 15)
 		return -EINVAL;
 
-	if (copy_from_user(buf, p, count))
-		return -EFAULT;
+	memcpy(buf, p, count);
 
 	buf[count] = 0;
 	rc = kstrtoint(buf, 0, &cmd);
@@ -586,11 +585,11 @@ static int vcpudispatch_stats_display(struct seq_file *p, void *v)
 
 static const struct proc_ops vcpudispatch_stats_proc_ops = {
 	.proc_show	= vcpudispatch_stats_display,
-	.proc_write	= vcpudispatch_stats_write,
+	.proc_write_buf	= vcpudispatch_stats_write,
 };
 
 static ssize_t vcpudispatch_stats_freq_write(struct file *file,
-		const char __user *p, size_t count, loff_t *ppos)
+		char *p, size_t count, loff_t *ppos)
 {
 	int rc, freq;
 	char buf[16];
@@ -598,8 +597,7 @@ static ssize_t vcpudispatch_stats_freq_write(struct file *file,
 	if (count > 15)
 		return -EINVAL;
 
-	if (copy_from_user(buf, p, count))
-		return -EFAULT;
+	memcpy(buf, p, count);
 
 	buf[count] = 0;
 	rc = kstrtoint(buf, 0, &freq);
@@ -622,7 +620,7 @@ static int vcpudispatch_stats_freq_display(struct seq_file *p, void *v)
 
 static const struct proc_ops vcpudispatch_stats_freq_proc_ops = {
 	.proc_show	= vcpudispatch_stats_freq_display,
-	.proc_write	= vcpudispatch_stats_freq_write,
+	.proc_write_buf	= vcpudispatch_stats_freq_write,
 };
 
 static int __init vcpudispatch_stats_procfs_init(void)
diff --git a/arch/powerpc/platforms/pseries/lparcfg.c b/arch/powerpc/platforms/pseries/lparcfg.c
index a6a137ce44ce..43af7f820fab 100644
--- a/arch/powerpc/platforms/pseries/lparcfg.c
+++ b/arch/powerpc/platforms/pseries/lparcfg.c
@@ -687,7 +687,7 @@ static ssize_t update_mpp(u64 *entitlement, u8 *weight)
  * This function should be invoked only on systems with
  * FW_FEATURE_SPLPAR.
  */
-static ssize_t lparcfg_write(struct file *file, const char __user * buf,
+static ssize_t lparcfg_write(struct file *file, char *buf,
 			     size_t count, loff_t * off)
 {
 	char kbuf[64];
@@ -702,8 +702,7 @@ static ssize_t lparcfg_write(struct file *file, const char __user * buf,
 	if (count == 0 || count > sizeof(kbuf))
 		return -EINVAL;
 
-	if (copy_from_user(kbuf, buf, count))
-		return -EFAULT;
+	memcpy(kbuf, buf, count);
 
 	kbuf[count - 1] = '\0';
 	tmp = strchr(kbuf, '=');
@@ -799,7 +798,7 @@ static int lparcfg_data(struct seq_file *m, void *v)
 }
 
 static const struct proc_ops lparcfg_proc_ops = {
-	.proc_write	= lparcfg_write,
+	.proc_write_buf	= lparcfg_write,
 	.proc_show	= lparcfg_data,
 };
 
diff --git a/arch/powerpc/platforms/pseries/reconfig.c b/arch/powerpc/platforms/pseries/reconfig.c
index b41c5db726c9..f406e826a03e 100644
--- a/arch/powerpc/platforms/pseries/reconfig.c
+++ b/arch/powerpc/platforms/pseries/reconfig.c
@@ -349,7 +349,7 @@ static int do_update_property(char *buf, size_t bufsize)
  * ofdt_write - perform operations on the Open Firmware device tree
  *
  * @file: not used
- * @buf: command and arguments
+ * @kbuf: command and arguments
  * @count: size of the command buffer
  * @off: not used
  *
@@ -357,26 +357,19 @@ static int do_update_property(char *buf, size_t bufsize)
  * whole nodes along with their properties.  Operations on individual
  * properties are not implemented (yet).
  */
-static ssize_t ofdt_write(struct file *file, const char __user *buf, size_t count,
+static ssize_t ofdt_write(struct file *file, char *kbuf, size_t count,
 			  loff_t *off)
 {
 	int rv;
-	char *kbuf;
 	char *tmp;
 
 	rv = security_locked_down(LOCKDOWN_DEVICE_TREE);
 	if (rv)
 		return rv;
 
-	kbuf = memdup_user_nul(buf, count);
-	if (IS_ERR(kbuf))
-		return PTR_ERR(kbuf);
-
 	tmp = strchr(kbuf, ' ');
-	if (!tmp) {
-		rv = -EINVAL;
-		goto out;
-	}
+	if (!tmp)
+		return -EINVAL;
 	*tmp = '\0';
 	tmp++;
 
@@ -392,13 +385,14 @@ static ssize_t ofdt_write(struct file *file, const char __user *buf, size_t coun
 		rv = do_update_property(tmp, count - (tmp - kbuf));
 	else
 		rv = -EINVAL;
-out:
-	kfree(kbuf);
+
 	return rv ? rv : count;
 }
 
 static const struct proc_ops ofdt_proc_ops = {
-	.proc_write	= ofdt_write,
+	.proc_write_buf	= ofdt_write,
+	/* what memdup_user_nul() could copy in */
+	.proc_write_size = KMALLOC_MAX_SIZE - 1,
 	.proc_lseek	= noop_llseek,
 };
 

-- 
2.53.0

