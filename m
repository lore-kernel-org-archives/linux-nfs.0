Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793633322;
	b=NfWj1ExidirlGCiBSFf84E9aaGrYb6qoCFu23N68LQyUxJg8qvOgWj+/lUEsvV77Rswu
	 6WXjJiUkWQNwRqOnndhYWNvI9n8FTT6PiQYPmS2fCh6MURbJmRkeFGS/czzw1gvCZ2866
	 NKUEZO38kQFAuT6EdWDv63VE/8fo6M4XOqic/UAnSv6BxWFLPM6nl7SAPcMJH0hbDTDU9
	 KuK+czJkWZx99NLpE/ECX53s9O3bqNNBb3hr1Yt1gTTxRfKosdsbfjX33Gk786uFT3fAk
	 hpeJEZK8isamJT90k967LJw1QmVEuMv0LcY3U+L5rU99daKNIB92xf4tpYOWlVLO26A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793633322;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=toX2CmHD2NzUUtPxn+B9S++PSadbiUkEaQUUA5VZdL0=;
	b=oGN31SWxr1Qb7S6cTZjJe8HdVLoBq4jKQwlRcBt+8Xw4FAGp+Gjoa9d2NSSXsK3Q72Ad
	 fuTgYBNTrnz5eL+Rc92TxWe2kZhk/+9PeN3xQLr88QqkIezQ4O5RTZYdXk8u0j6t7ZTgM
	 6CicgxsMub1zK9cOWlEucrDtoV/r/C/yLEiEEb8rGzfAnv5zhH0+FHK+DILZ7eINYxlob
	 lakpjN2TYsgJcehPl76HhwlXrmQ9zT7wUH9RmcNyEINkarhNdodYnKb8i3vgYsP4saJXq
	 71Hd0Rnmx97BE/buxQwDHDtSoSSMXycDf3STA/07+yzC8GDrl3oC795pPghq8cctt/A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Qg2kQwEJ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B5BA460850A9;
	Mon,  2 Nov 2026 15:28:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Qg2kQwEJ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1DD6D1F00A16;
	Mon,  2 Nov 2026 15:28:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793633321;
	bh=toX2CmHD2NzUUtPxn+B9S++PSadbiUkEaQUUA5VZdL0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Qg2kQwEJzBBud2YUJ5gCy+8AwyrbfP0wjUoQmOVfGfnhhid1zR1YXGmw9lG63Cq5H
	 PnFT4z0kjd/vnLavLzmjV+cc1mZrSe7esUryOwNy8DlGgP0iR20nKduRu/kIzHHsrQ
	 gjv4+UrQipmVe0//KR6hmG2uBXfpQI7HpEbsZeXm0dGsbxjJywIm3X1O6YZKcRgI8R
	 fyDrbQhVDukMWPxLMGTE6xRuHe8cYGAyiRM5fIGe9b1AtfTA3oMoQ+m+woQvg5dZTm
	 aWP+sNADJwOPXcf78LIFpFrYKl//E/ARw2Rvrj2196gNLVEEXBWWB+0PsauKpZ5TfT
	 cXvrUnM7DQOgA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:34 +0100
Subject: [PATCH RFC 24/27] alloc_tag: let procfs copy the ioctl arguments
 of /proc/allocinfo
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
Message-Id: <20261102-work-procfs-fs-v1-24-d09a996317b3@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=5002; i=brauner@kernel.org;
 h=from:subject:message-id; bh=Df+mpuPO24WuA65Z3R+CqgWoIsjjCuc3kLgbPQbmkBc=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG7M+GnFOi/L79sZ/3nKHOl8OmlN0p/Mgq2y3fUHM
 zOWcK5f3VHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAnCT+RgZjmkkrJpwrImlTOP+
 7JSdp5pyDvu1zYz6ujT/tMhRJ7dTsYwMu1c1SXtoHp9uOvfWFiYRtj/J6WeC+vuWLjBUsk9nYHL
 iBgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Implement ->proc_ioctl_buf() so procfs copies the arguments in before
it pins the entry and back out after unpinning it. The commands encode
their arguments. procfs converts the pointers of 32-bit tasks, so
allocinfo_compat_ioctl() goes away.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 mm/alloc_tag.c | 47 +++++++++++++++++------------------------------
 1 file changed, 17 insertions(+), 30 deletions(-)

diff --git a/mm/alloc_tag.c b/mm/alloc_tag.c
index 788c9d7f7151..1734705e2990 100644
--- a/mm/alloc_tag.c
+++ b/mm/alloc_tag.c
@@ -6,7 +6,6 @@
 #include <linux/kallsyms.h>
 #include <linux/module.h>
 #include <linux/mutex.h>
-#include <linux/compat.h>
 #include <linux/page_ext.h>
 #include <linux/pgalloc_tag.h>
 #include <linux/proc_fs.h>
@@ -235,16 +234,14 @@ static void allocinfo_to_params(struct codetag *ct,
  * Retrieves the unique content ID representing the current allocation tag module
  * layout, allowing userspace to detect if modules were loaded / unloaded.
  */
-static int allocinfo_ioctl_get_content_id(struct seq_file *m, void __user *arg)
+static int allocinfo_ioctl_get_content_id(struct seq_file *m, void *arg)
 {
 	struct allocinfo_content_id params;
 
 	codetag_lock_module_list(alloc_tag_cttype);
 	params.id = codetag_get_content_id(alloc_tag_cttype);
 	codetag_unlock_module_list(alloc_tag_cttype);
-	if (copy_to_user(arg, &params, sizeof(params)))
-		return -EFAULT;
-
+	memcpy(arg, &params, sizeof(params));
 	return 0;
 }
 
@@ -309,7 +306,7 @@ static bool matches_filter(struct codetag *ct, struct allocinfo_filter *filter,
  * Seeks the ioctl iterator to the specified 0-indexed tag position, reads its
  * profiling data and returns it to userspace.
  */
-static int allocinfo_ioctl_get_at(struct seq_file *m, void __user *arg)
+static int allocinfo_ioctl_get_at(struct seq_file *m, void *arg)
 {
 	struct allocinfo_private *priv;
 	struct codetag *ct;
@@ -318,8 +315,7 @@ static int allocinfo_ioctl_get_at(struct seq_file *m, void __user *arg)
 	struct alloc_tag_counters counters;
 	bool fetched_counters;
 
-	if (copy_from_user(&params, arg, sizeof(params)))
-		return -EFAULT;
+	memcpy(&params, arg, sizeof(params));
 
 	if (params.filter.mask & ~ALLOCINFO_FILTER_MASKS)
 		return -EINVAL;
@@ -374,9 +370,7 @@ static int allocinfo_ioctl_get_at(struct seq_file *m, void __user *arg)
 	if (!ct)
 		return -ENOENT;
 
-	if (copy_to_user(arg, &params, sizeof(params)))
-		return -EFAULT;
-
+	memcpy(arg, &params, sizeof(params));
 	return 0;
 }
 
@@ -384,7 +378,7 @@ static int allocinfo_ioctl_get_at(struct seq_file *m, void __user *arg)
  * Advances the ioctl iterator to the next allocation tag in the sequence and
  * returns its profiling data to userspace.
  */
-static int allocinfo_ioctl_get_next(struct seq_file *m, void __user *arg)
+static int allocinfo_ioctl_get_next(struct seq_file *m, void *arg)
 {
 	struct allocinfo_private *priv;
 	struct codetag *ct;
@@ -424,10 +418,8 @@ static int allocinfo_ioctl_get_next(struct seq_file *m, void __user *arg)
 	codetag_unlock_module_list(alloc_tag_cttype);
 	mutex_unlock(&priv->ioctl_lock);
 
-	if (ret == 0) {
-		if (copy_to_user(arg, &params, sizeof(params)))
-			return -EFAULT;
-	}
+	if (ret == 0)
+		memcpy(arg, &params, sizeof(params));
 	return ret;
 }
 
@@ -435,10 +427,8 @@ static int allocinfo_ioctl_get_next(struct seq_file *m, void __user *arg)
  * Entry point ioctl function for /proc/allocinfo routing requests to fetch the
  * layout content ID, seek to a specific tag, or read sequential tags.
  */
-static long allocinfo_ioctl(struct file *file, unsigned int cmd,
-			    unsigned long __arg)
+static long allocinfo_ioctl(struct file *file, unsigned int cmd, void *arg)
 {
-	void __user *arg = (void __user *)__arg;
 	int ret;
 
 	switch (cmd) {
@@ -459,23 +449,20 @@ static long allocinfo_ioctl(struct file *file, unsigned int cmd,
 	return ret;
 }
 
-#ifdef CONFIG_COMPAT
-static long allocinfo_compat_ioctl(struct file *file, unsigned int cmd,
-				   unsigned long arg)
-{
-	return allocinfo_ioctl(file, cmd, (unsigned long)compat_ptr(arg));
-}
-#endif
+static const struct proc_ioctl_arg allocinfo_ioctl_args[] = {
+	PROC_IOCTL_IOC(ALLOCINFO_IOC_CONTENT_ID),
+	PROC_IOCTL_IOC(ALLOCINFO_IOC_GET_AT),
+	PROC_IOCTL_IOC(ALLOCINFO_IOC_GET_NEXT),
+};
 
 static const struct proc_ops allocinfo_proc_ops = {
 	.proc_seq_ops		= &allocinfo_seq_op,
 	.proc_state_size	= sizeof(struct allocinfo_private),
 	.proc_open		= allocinfo_open,
 	.proc_release		= allocinfo_release,
-	.proc_ioctl		= allocinfo_ioctl,
-#ifdef CONFIG_COMPAT
-	.proc_compat_ioctl	= allocinfo_compat_ioctl,
-#endif
+	.proc_ioctl_buf		= allocinfo_ioctl,
+	.proc_ioctl_args	= allocinfo_ioctl_args,
+	.proc_nr_ioctl_args	= ARRAY_SIZE(allocinfo_ioctl_args),
 };
 
 size_t alloc_tag_top_users(struct codetag_bytes *tags, size_t count, bool can_sleep)

-- 
2.53.0

