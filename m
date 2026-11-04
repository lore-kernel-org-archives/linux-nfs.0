Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821972;
	b=Eax3E8rEx1Qrs1QW1tF+SIRjX/wdigJ5QQod4hR0xJvU1n3oXtTlGBkZtn1htYNo40IW
	 q+3XlBdJNAWTQ1O/gAPLer9MsNAtWUHYBBleVLrasGsp+hNIilOWvcKFoOnBslA/tuTLB
	 oBBxm0cVXcrNGw9zIKnwph5PYienGTuQ6doaaYLf6GLdF7p0Q/qTwQuhRyjM2cJlYK8ID
	 2XUvypLD/3tegHmUTuFmCWboPwty/NyS+ZHgE6eNzBE73dIsR76szAjDypjG+bKn+i8sy
	 9lVNwyuKpvYQS4k9utCaZhEWrAXxUQxavMsrkMivArfImOgDjmJ9hBOiHAsbx7Szy+A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821972;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=e6t+ZjLlcl2UBfeg6Fa8p1cvIAPOQLpJeTR6f8fh14w=;
	b=q70/YQhFU/ANR0072OorpHnGMGDHk82q7bSld3rv/FKh78qieuCUduTGOh+bwJ/TSUHx
	 SW0qD9BJzk2rsctxVLtkP0eCiAdE5Z0tlcinx7yeI1Wz9u3n07ConL9696ooNwaz9fyVV
	 9loiFcSX8/tzj9q5lifgE3trsdHBYw8vVV5IMXepjyE/7qCOlXQiB7rhYJJR6qvN72dB7
	 2+L++8oi/f5FK0Cpxn7s7hY2ChGzPIB4QxK4lEc+HfblqbpbTH6nEYSLCCioFHNJF1ZQn
	 3CyeAKhANEM5SBD65eqaJL8zWM7j9MDX8/kiYsX6MmfoNV6KPVQkoeAIEQg6/tMhHAg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="KLjIE+/Q";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AE3E4606C5B8;
	Wed,  4 Nov 2026 19:52:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KLjIE+/Q
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E41F61F000C1;
	Wed,  4 Nov 2026 19:52:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821971;
	bh=e6t+ZjLlcl2UBfeg6Fa8p1cvIAPOQLpJeTR6f8fh14w=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=KLjIE+/QNPHQxRMuCW8dNWrCESqWYvISK46/mUNfKpIgCeoSJrgdmk8SkA+ATO7fz
	 FQ35566DIX+9ELnqg3Z9GTJZVRHI0Yud/AS1kcEPVIP4YYuS1YcVbpva0834j+U661
	 zMbjWJhPBVN/B6AggdgAVcfnGjd0hy36FXoA4988MkNbj3t9KGlQbCTtGn7Lq2oNiZ
	 gGsYSEMs37D5ZgHR4oyjLALRPtfTPAqhoQzZUV4znTfOb3VdD3io2MsyW92keql0Yw
	 gt21nsu4wFZgpw+3R20mXpoc8hVC/Rl4c9wnw34AaHdv6yMO/CIYavsN1nHMGTso6j
	 wpMlLdPvqyidA==
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
Subject: [PATCH RESEND v2 12/30] locking/lockdep: let procfs own the seq_file of /proc/lock_stat
Date: Wed,  4 Nov 2026 20:52:36 +0100
Message-ID: <20261104-work-procfs-fs-v2-12-319e0f9a8aae@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2606; i=brauner@kernel.org; h=from:subject:message-id; bh=wBxYZkbuLq2vx9tHnE9HzeQESu+Hnu4x6fVoBaGOq2s=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97rHsKW7c7qUfM/PTyqkXDu+wq5XQEdy7ZO/qHSlN8 2c3iPGIdZSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEzk6X+GfxavvpfVCmqsYy1b snqPxz3N8Ixjy2XenP/qsrrNPb/9wHyG/8WvPvNeb/4aOLFJQX7j5++rlv/axfqsyHddVbdZebv ZIzYA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Declare the seq_operations and let procfs open and free the seq_file.
->proc_open() only takes the snapshot of the statistics now and
->proc_release() frees it.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 kernel/locking/lockdep_proc.c | 48 +++++++++++++++++++------------------------
 1 file changed, 21 insertions(+), 27 deletions(-)

diff --git a/kernel/locking/lockdep_proc.c b/kernel/locking/lockdep_proc.c
index 1916db9aa46b..9b034b5b94bd 100644
--- a/kernel/locking/lockdep_proc.c
+++ b/kernel/locking/lockdep_proc.c
@@ -638,40 +638,35 @@ static const struct seq_operations lockstat_ops = {
 	.show	= ls_show,
 };
 
+/* procfs opens the seq_file */
 static int lock_stat_open(struct inode *inode, struct file *file)
 {
-	int res;
-	struct lock_class *class;
 	struct lock_stat_seq *data = vmalloc(sizeof(struct lock_stat_seq));
+	struct lock_stat_data *iter;
+	struct seq_file *m = file->private_data;
+	struct lock_class *class;
+	unsigned long idx;
 
 	if (!data)
 		return -ENOMEM;
 
-	res = seq_open(file, &lockstat_ops);
-	if (!res) {
-		struct lock_stat_data *iter = data->stats;
-		struct seq_file *m = file->private_data;
-		unsigned long idx;
-
-		iterate_lock_classes(idx, class) {
-			if (!test_bit(idx, lock_classes_in_use))
-				continue;
-			iter->class = class;
-			lock_stats(class, &iter->stats);
-			iter++;
-		}
-
-		data->iter_end = iter;
+	iter = data->stats;
+	iterate_lock_classes(idx, class) {
+		if (!test_bit(idx, lock_classes_in_use))
+			continue;
+		iter->class = class;
+		lock_stats(class, &iter->stats);
+		iter++;
+	}
 
-		sort(data->stats, data->iter_end - data->stats,
-				sizeof(struct lock_stat_data),
-				lock_stat_cmp, NULL);
+	data->iter_end = iter;
 
-		m->private = data;
-	} else
-		vfree(data);
+	sort(data->stats, data->iter_end - data->stats,
+			sizeof(struct lock_stat_data),
+			lock_stat_cmp, NULL);
 
-	return res;
+	m->private = data;
+	return 0;
 }
 
 static ssize_t lock_stat_write(struct file *file, const char __user *buf,
@@ -702,14 +697,13 @@ static int lock_stat_release(struct inode *inode, struct file *file)
 	struct seq_file *seq = file->private_data;
 
 	vfree(seq->private);
-	return seq_release(inode, file);
+	return 0;
 }
 
 static const struct proc_ops lock_stat_proc_ops = {
+	.proc_seq_ops	= &lockstat_ops,
 	.proc_open	= lock_stat_open,
 	.proc_write	= lock_stat_write,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
 	.proc_release	= lock_stat_release,
 };
 #endif /* CONFIG_LOCK_STAT */

-- 
2.53.0

