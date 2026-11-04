Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793822178;
	b=vSHNld2cfNd7P300Y/A0CexWz3yJB5qyBvJDSmND3+RCQSxx/thgx9r8ouuVdrPtcklU
	 WURN7ekhNr5kzims67jvCP/vM4NDzttNFwcfjcRI0Zc1p/I/a2EBSizmxUXDX0MKM71/6
	 BHL2zRp6WupaCtAo7b3MKUTCOo/ua3jT0Oc/ku3H3zzcIriNfXlXEN8Wr0za3e0iVpC1B
	 I9jWlJjlkHPX6n8q530XGF8D+XkuiD6IQVgKxltIF4Om2Jlr/QDPJunXdaKic0wSl1wPB
	 Y/XMCfgjAqcrHKe/FQfOVROffUcmZ7MBCh5mj5rWCfClAze/LFP5cqq74wX3l+6EnkQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793822178;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=dVjHuUMxxd8FqQa8K43Wpa6+M00cK9gADu+rBdGhG5Q=;
	b=XIOdViPkFGM/xakoa1rdT0vBd4tmkrNvKmPRh1kGLNCwkd3pLOPUKW0Dq/iF/28+zymm
	 rfjr0rOnvKAQqFHTmsQsp429bSIqXrVV9wrwdeH6vpXyLd+b2U/+5CDyZdZ8af2kxgsSG
	 qwTgK/SpvmZXrHSgeIZJe1c/5WcUSsmXZJM+TkCkaPcNrnNLOSk0Z2a6u/kmlyTOnif6W
	 fPJWLAlsaZKT6TVh57HKrMsTbKgnALv4CXo4oy/Pern4nM/09nxx8TWGNEAxDpzeizUNT
	 jSCgpIOdNMAbV+EETsurGZdIZrMzor1BAzWO9nFbcAp3qiILzQZZocGWycrbY7guKPA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WciFxQke;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 315866078941;
	Wed,  4 Nov 2026 19:56:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WciFxQke
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 842BD1F000C1;
	Wed,  4 Nov 2026 19:56:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793822177;
	bh=dVjHuUMxxd8FqQa8K43Wpa6+M00cK9gADu+rBdGhG5Q=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=WciFxQke7WU+TqGOiLHJFFvz51sxAv/rXDuJ65d7uc/uzhqt05C4NlVN6GEsTUCUu
	 31fkRA/xip2bhOq8TqDrQhDe5z0BPJYsvkSt1ZtjXi0UWf4TITY4A9UV1Jj74iUycG
	 lDsCZ5Dv6DN9dQs5WHRrbLlWLWWmKs07ZIwnLQxTmPhOa7InPJfbe0D8IVp3OjClGc
	 ZmGH+yeDVq+4v+cg8g4xIPmzrh+E3sC00xuiXzIgXt8btDsGhRR0CoJ8fDZPxoEm+E
	 OBg77f3DkM4ZaSWy1R28T5gZm41vTK6+WYOPbNiJOEt0Tph54u6+2Ht87F0UbPAKoU
	 ENh1KteE9DOew==
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
Subject: [PATCH RESEND v2 26/30] alloc_tag: let procfs copy the ioctl arguments of /proc/allocinfo
Date: Wed,  4 Nov 2026 20:56:03 +0100
Message-ID: <20261104-work-procfs-fs-v2-26-319e0f9a8aae@kernel.org>
In-Reply-To: <20261104-work-procfs-fs-v2-0-319e0f9a8aae@kernel.org>
References: <20261104-work-procfs-fs-v2-0-319e0f9a8aae@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=5002; i=brauner@kernel.org; h=from:subject:message-id; bh=qvFStIPYOo+XQCz7NGrfedfPC5AiqcBr63oE+4d+7KE=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97vE65vl9w02l+nm/3k8td487Mlf95K8LO9Yw6x35z bF1Qqund0cpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBE6roZ/sfzLc1cc19g8UpG p9ScMA2ZG2mxxusMN/5mfHVJ4JFJ0UmGvxIPbppe0fTgXiEh//pB3cedQhve/fx4peeqfYB+jj/ rQzYA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_ioctl_buf() so procfs copies the arguments in before
it pins the entry and back out after unpinning it. The commands encode
their arguments. procfs converts the pointers of 32-bit tasks, so
allocinfo_compat_ioctl() goes away.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 mm/alloc_tag.c | 47 +++++++++++++++++------------------------------
 1 file changed, 17 insertions(+), 30 deletions(-)

diff --git a/mm/alloc_tag.c b/mm/alloc_tag.c
index 697e44468ebc..b17457c8fb02 100644
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
@@ -236,16 +235,14 @@ static void allocinfo_to_params(struct codetag *ct,
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
 
@@ -310,7 +307,7 @@ static bool matches_filter(struct codetag *ct, struct allocinfo_filter *filter,
  * Seeks the ioctl iterator to the specified 0-indexed tag position, reads its
  * profiling data and returns it to userspace.
  */
-static int allocinfo_ioctl_get_at(struct seq_file *m, void __user *arg)
+static int allocinfo_ioctl_get_at(struct seq_file *m, void *arg)
 {
 	struct allocinfo_private *priv;
 	struct codetag *ct;
@@ -319,8 +316,7 @@ static int allocinfo_ioctl_get_at(struct seq_file *m, void __user *arg)
 	struct alloc_tag_counters counters;
 	bool fetched_counters;
 
-	if (copy_from_user(&params, arg, sizeof(params)))
-		return -EFAULT;
+	memcpy(&params, arg, sizeof(params));
 
 	if (params.filter.mask & ~ALLOCINFO_FILTER_MASKS)
 		return -EINVAL;
@@ -375,9 +371,7 @@ static int allocinfo_ioctl_get_at(struct seq_file *m, void __user *arg)
 	if (!ct)
 		return -ENOENT;
 
-	if (copy_to_user(arg, &params, sizeof(params)))
-		return -EFAULT;
-
+	memcpy(arg, &params, sizeof(params));
 	return 0;
 }
 
@@ -385,7 +379,7 @@ static int allocinfo_ioctl_get_at(struct seq_file *m, void __user *arg)
  * Advances the ioctl iterator to the next allocation tag in the sequence and
  * returns its profiling data to userspace.
  */
-static int allocinfo_ioctl_get_next(struct seq_file *m, void __user *arg)
+static int allocinfo_ioctl_get_next(struct seq_file *m, void *arg)
 {
 	struct allocinfo_private *priv;
 	struct codetag *ct;
@@ -425,10 +419,8 @@ static int allocinfo_ioctl_get_next(struct seq_file *m, void __user *arg)
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
 
@@ -436,10 +428,8 @@ static int allocinfo_ioctl_get_next(struct seq_file *m, void __user *arg)
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
@@ -460,23 +450,20 @@ static long allocinfo_ioctl(struct file *file, unsigned int cmd,
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

