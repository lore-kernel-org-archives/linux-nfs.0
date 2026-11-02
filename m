Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793632972;
	b=P+MuSxlqSEJ+5iSFxeOf+Dhq181FlkQtuAjycyHAzBF0got+6UHMBAr5m1fm+uQm/Q94
	 4BeGbkG/WheYfdvU1OAPyz4szGemWdTl+kw4NEmIlmCLLsKiRGSOtFLkG6zeZUa2nGFQ9
	 zx/a13TL5q+weHyV3Z3XjSOkqVKa4yyqoM6s3lJjfv7OgxiCf1LeLleP0d+rfLfMPr2kt
	 GZSt+/yaPVcEMcbLEL6Ttwzs9NYnh8HvKRZffag8OEQaGKX3qJUrpOxsNk5mu7Nu972fl
	 qylDmWg87GMKdlw3Yuf5d8MBpAQkFuP/V+ft2YHGoHPj6z1j3p70U1n4Acre2HIi39Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793632972;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=nlVd2d+i8P+1hcARtfAVoMomzYlKlzmY39R4NNuEpHM=;
	b=1mG0mP7hfB4Vvbf2KqSTkii573U8KadJ8Qu18TzllTrlFls5YFAGpm/Io/GgiGBnJHU1
	 0TwkfmHBMTmVThHtF/ywXemWSY8d7AbaZTQmFX81ePL7PNxBzB3q3d1QzJmE1/wC+1Qy1
	 ASepoIo7rxWZQLreztcmOv5bAQiWB+oJnGO7j1yjPr5TqAiARUgr2Un8CaHpZAbaI5Kv0
	 Tj+vD6NYDkX54tnNIjFfcbZtR4mzgv0PBLEQK/BlWAzeEzT07QqLwQ8qzOxAwPWKEZh7/
	 pO7Lw+zsp4gbNPbZc09wVzUi9ONM/MBDYdE8mEgswm0B+tuxqRhEpQh7c47nJ81zEGA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=N7s7Rr4t;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7FACC60822AA;
	Mon,  2 Nov 2026 15:22:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=N7s7Rr4t
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B8A341F00A16;
	Mon,  2 Nov 2026 15:22:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793632972;
	bh=nlVd2d+i8P+1hcARtfAVoMomzYlKlzmY39R4NNuEpHM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=N7s7Rr4tn3noqVfU8ebbTIIEWsKpdqgT+vIEG2HnGddiV3nggMKyYoGDj/dhoH8Vq
	 ykGauAPuLUU5xa/vSRC3ueradsxUXOZ+CU5fhTRxKMkYeniVJSxxh+7XnsbQo9GOIo
	 kl5er4X6Zyfc19tK58DDmyE3rvqIlJMd5P+NnIHIYCW7eJ0nVIc3reeuMF9tI3shvO
	 dJHH4mpYslPnfwvIjH5M1oVmYQ9fp/68TG4Lki2zdADEB+MxmTuGZLfFaIacVgOCTw
	 EkE5kA3ueLSgfhcq7xnVt0sk26H7smSSBt3/KD8tcF0DWKT0j/NGB2fjO6tk/NHJav
	 t2zQbmoM3V44w==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:19 +0100
Subject: [PATCH RFC 09/27] smb: client: let procfs copy in writes
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
Message-Id: <20261102-work-procfs-fs-v1-9-d09a996317b3@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=8830; i=brauner@kernel.org;
 h=from:subject:message-id; bh=FT7LQYM7T+jx4y6th5QoquEbwgmi4EXWnyiLf7yiyR0=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG6UE1Kj2JasoSuw1cLeTY1F/vT+AL6dHQYRE+L/m
 /85fbWto5SFQYyLQVZMkcWh3SRcbjlPxWajTA2YOaxMIEMYuDgFYCK5iowMt/4Zrlyed+nx1PoX
 bZ8ueD2fvy8usejek35PnjnPrnG58jH8061VYfu2bPIkF7FFodNvdS9Wbv9bOE/KzDIo3I9hxR8
 udgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Implement ->proc_write_buf() for the files in /proc/fs/cifs so procfs
copies in what is written before it pins the entry, and parse what was
written from that copy. Writes larger than PAGE_SIZE - 1 bytes fail with
-EINVAL now, SecurityFlags never took more than 11 bytes. Empty writes
to cifsFYI and dfscache fail with -EINVAL too, they looked at a byte
that wasn't written before. kstrtoint_from_user() looked at the first
34 bytes of a write to cifs_debug_dirs and the smbdirect files, now the
whole write is parsed.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/smb/client/cifs_debug.c | 62 +++++++++++++++++++---------------------------
 fs/smb/client/dfs_cache.c  | 13 +++-------
 2 files changed, 29 insertions(+), 46 deletions(-)

diff --git a/fs/smb/client/cifs_debug.c b/fs/smb/client/cifs_debug.c
index 664072ab3342..fb1323bf44c7 100644
--- a/fs/smb/client/cifs_debug.c
+++ b/fs/smb/client/cifs_debug.c
@@ -359,12 +359,12 @@ static int cifs_debug_dirs_proc_show(struct seq_file *m, void *v)
 #ifdef CONFIG_CIFS_DEBUG
 
 /* Drop all cached directory entries across all CIFS mounts. */
-static ssize_t cifs_debug_dirs_proc_write(struct file *file, const char __user *buffer,
+static ssize_t cifs_debug_dirs_proc_write(struct file *file, char *buffer,
 					  size_t count, loff_t *ppos)
 {
 	int rc, v;
 
-	rc = kstrtoint_from_user(buffer, count, 10, &v);
+	rc = kstrtoint(buffer, 10, &v);
 	if (rc)
 		return rc;
 
@@ -390,7 +390,7 @@ static ssize_t cifs_debug_dirs_proc_write(struct file *file, const char __user *
 
 static const struct proc_ops cifs_debug_dirs_proc_ops = {
 	.proc_show	= cifs_debug_dirs_proc_show,
-	.proc_write	= cifs_debug_dirs_proc_write,
+	.proc_write_buf	= cifs_debug_dirs_proc_write,
 };
 #endif /* CONFIG_CIFS_DEBUG */
 
@@ -713,8 +713,8 @@ static int cifs_debug_data_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static ssize_t cifs_stats_proc_write(struct file *file,
-		const char __user *buffer, size_t count, loff_t *ppos)
+static ssize_t cifs_stats_proc_write(struct file *file, char *buffer,
+		size_t count, loff_t *ppos)
 {
 	bool bv;
 	int rc;
@@ -722,7 +722,7 @@ static ssize_t cifs_stats_proc_write(struct file *file,
 	struct cifs_ses *ses;
 	struct cifs_tcon *tcon;
 
-	rc = kstrtobool_from_user(buffer, count, &bv);
+	rc = kstrtobool(buffer, &bv);
 	if (rc == 0) {
 #ifdef CONFIG_CIFS_STATS2
 		int i;
@@ -854,16 +854,16 @@ static int cifs_stats_proc_show(struct seq_file *m, void *v)
 
 static const struct proc_ops cifs_stats_proc_ops = {
 	.proc_show	= cifs_stats_proc_show,
-	.proc_write	= cifs_stats_proc_write,
+	.proc_write_buf	= cifs_stats_proc_write,
 };
 
 #ifdef CONFIG_CIFS_SMB_DIRECT
 #define PROC_FILE_DEFINE(name) \
-static ssize_t name##_write(struct file *file, const char __user *buffer, \
+static ssize_t name##_write(struct file *file, char *buffer, \
 	size_t count, loff_t *ppos) \
 { \
 	int rc; \
-	rc = kstrtoint_from_user(buffer, count, 10, &name); \
+	rc = kstrtoint(buffer, 10, &name); \
 	if (rc) \
 		return rc; \
 	return count; \
@@ -876,7 +876,7 @@ static int name##_proc_show(struct seq_file *m, void *v) \
 \
 static const struct proc_ops cifs_##name##_proc_fops = { \
 	.proc_show	= name##_proc_show, \
-	.proc_write	= name##_write, \
+	.proc_write_buf	= name##_write, \
 }
 
 PROC_FILE_DEFINE(rdma_readwrite_threshold);
@@ -990,16 +990,12 @@ static int cifsFYI_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static ssize_t cifsFYI_proc_write(struct file *file, const char __user *buffer,
+static ssize_t cifsFYI_proc_write(struct file *file, char *buffer,
 		size_t count, loff_t *ppos)
 {
-	char c[2] = { '\0' };
+	char c[2] = { buffer[0] };
 	bool bv;
-	int rc;
 
-	rc = get_user(c[0], buffer);
-	if (rc)
-		return rc;
 	if (kstrtobool(c, &bv) == 0)
 		cifsFYI = bv;
 	else if ((c[0] > '1') && (c[0] <= '9'))
@@ -1012,7 +1008,7 @@ static ssize_t cifsFYI_proc_write(struct file *file, const char __user *buffer,
 
 static const struct proc_ops cifsFYI_proc_ops = {
 	.proc_show	= cifsFYI_proc_show,
-	.proc_write	= cifsFYI_proc_write,
+	.proc_write_buf	= cifsFYI_proc_write,
 };
 
 static int cifs_linux_ext_proc_show(struct seq_file *m, void *v)
@@ -1021,12 +1017,12 @@ static int cifs_linux_ext_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static ssize_t cifs_linux_ext_proc_write(struct file *file,
-		const char __user *buffer, size_t count, loff_t *ppos)
+static ssize_t cifs_linux_ext_proc_write(struct file *file, char *buffer,
+		size_t count, loff_t *ppos)
 {
 	int rc;
 
-	rc = kstrtobool_from_user(buffer, count, &linuxExtEnabled);
+	rc = kstrtobool(buffer, &linuxExtEnabled);
 	if (rc)
 		return rc;
 
@@ -1035,7 +1031,7 @@ static ssize_t cifs_linux_ext_proc_write(struct file *file,
 
 static const struct proc_ops cifs_linux_ext_proc_ops = {
 	.proc_show	= cifs_linux_ext_proc_show,
-	.proc_write	= cifs_linux_ext_proc_write,
+	.proc_write_buf	= cifs_linux_ext_proc_write,
 };
 
 static int cifs_lookup_cache_proc_show(struct seq_file *m, void *v)
@@ -1044,12 +1040,12 @@ static int cifs_lookup_cache_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static ssize_t cifs_lookup_cache_proc_write(struct file *file,
-		const char __user *buffer, size_t count, loff_t *ppos)
+static ssize_t cifs_lookup_cache_proc_write(struct file *file, char *buffer,
+		size_t count, loff_t *ppos)
 {
 	int rc;
 
-	rc = kstrtobool_from_user(buffer, count, &lookupCacheEnabled);
+	rc = kstrtobool(buffer, &lookupCacheEnabled);
 	if (rc)
 		return rc;
 
@@ -1058,7 +1054,7 @@ static ssize_t cifs_lookup_cache_proc_write(struct file *file,
 
 static const struct proc_ops cifs_lookup_cache_proc_ops = {
 	.proc_show	= cifs_lookup_cache_proc_show,
-	.proc_write	= cifs_lookup_cache_proc_write,
+	.proc_write_buf	= cifs_lookup_cache_proc_write,
 };
 
 static int traceSMB_proc_show(struct seq_file *m, void *v)
@@ -1067,12 +1063,12 @@ static int traceSMB_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static ssize_t traceSMB_proc_write(struct file *file, const char __user *buffer,
+static ssize_t traceSMB_proc_write(struct file *file, char *buffer,
 		size_t count, loff_t *ppos)
 {
 	int rc;
 
-	rc = kstrtobool_from_user(buffer, count, &traceSMB);
+	rc = kstrtobool(buffer, &traceSMB);
 	if (rc)
 		return rc;
 
@@ -1081,7 +1077,7 @@ static ssize_t traceSMB_proc_write(struct file *file, const char __user *buffer,
 
 static const struct proc_ops traceSMB_proc_ops = {
 	.proc_show	= traceSMB_proc_show,
-	.proc_write	= traceSMB_proc_write,
+	.proc_write_buf	= traceSMB_proc_write,
 };
 
 static int cifs_security_flags_proc_show(struct seq_file *m, void *v)
@@ -1111,21 +1107,15 @@ cifs_security_flags_handle_must_flags(unsigned int *flags)
 }
 
 static ssize_t cifs_security_flags_proc_write(struct file *file,
-		const char __user *buffer, size_t count, loff_t *ppos)
+		char *flags_string, size_t count, loff_t *ppos)
 {
 	int rc;
 	unsigned int flags;
-	char flags_string[12];
 	bool bv;
 
 	if ((count < 1) || (count > 11))
 		return -EINVAL;
 
-	memset(flags_string, 0, sizeof(flags_string));
-
-	if (copy_from_user(flags_string, buffer, count))
-		return -EFAULT;
-
 	if (count < 3) {
 		/* single char or single char followed by null */
 		if (kstrtobool(flags_string, &bv) == 0) {
@@ -1176,7 +1166,7 @@ static ssize_t cifs_security_flags_proc_write(struct file *file,
 
 static const struct proc_ops cifs_security_flags_proc_ops = {
 	.proc_show	= cifs_security_flags_proc_show,
-	.proc_write	= cifs_security_flags_proc_write,
+	.proc_write_buf	= cifs_security_flags_proc_write,
 };
 
 /* To make it easier to debug, can help to show mount params */
diff --git a/fs/smb/client/dfs_cache.c b/fs/smb/client/dfs_cache.c
index 58f16cf83d36..a6aa05430b15 100644
--- a/fs/smb/client/dfs_cache.c
+++ b/fs/smb/client/dfs_cache.c
@@ -191,17 +191,10 @@ static int dfscache_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static ssize_t dfscache_proc_write(struct file *file, const char __user *buffer,
+static ssize_t dfscache_proc_write(struct file *file, char *buffer,
 				   size_t count, loff_t *ppos)
 {
-	char c;
-	int rc;
-
-	rc = get_user(c, buffer);
-	if (rc)
-		return rc;
-
-	if (c != '0')
+	if (buffer[0] != '0')
 		return -EINVAL;
 
 	cifs_dbg(FYI, "clearing dfs cache\n");
@@ -215,7 +208,7 @@ static ssize_t dfscache_proc_write(struct file *file, const char __user *buffer,
 
 const struct proc_ops dfscache_proc_ops = {
 	.proc_show	= dfscache_proc_show,
-	.proc_write	= dfscache_proc_write,
+	.proc_write_buf	= dfscache_proc_write,
 };
 
 #ifdef CONFIG_CIFS_DEBUG2

-- 
2.53.0

