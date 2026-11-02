Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793633032;
	b=mUTN4CicIbGNYeD9QDzlKkc3K72N5xVKeioZ8VCSOdVfdqI6Zqc6NDHipPT+tVsWdMrp
	 +or2n4Z3LCuXfBRHZNZuiNEuTAkWLFCEfwUnTC8wjQxhSY/fhkTCBUD2hvjdXgKrZVu8S
	 ue7d9przlc2hhz9YmIOK91iQZLGatOMJKY/xAOteS7F8bFF71nbzNpjAj2Bpav60jI9EN
	 Vnp1BumkqmhBjYK9tcwadBLQ42aLpxmHUzQ/rFmGFY9rAhUdx4/dQKsVHRtR+PZGOozCA
	 Do1l5cVYx7sQyGpHwZbSqC3Z5/fBrYUqXaYEW0osNUTguTRJ8Rhw+rr4nqNjnt1YPRg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793633032;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=e6t+ZjLlcl2UBfeg6Fa8p1cvIAPOQLpJeTR6f8fh14w=;
	b=E6t6ED801NLs3O9y8Ap3LKmdn4lD+YXvhqfn2LSPyquRryk92a+Dr79egCClzQe4KA0n
	 hVXIpU7SiG8ZphF3ibEAUR4wm/ozvCRKCQp2YClfGpBHQrdODuQSmxsSXO78NmbceG9x+
	 M4rlR1dRCrCQQG8OL7veV1bVX9+rg3XE8Bp5Jwgt3seEMznSgy/ftGfReibRGwaBYocmI
	 wRsokXaBWVG46ubYcO8eN2HJ3D5FqEKIokL0O0UH+fANeC75lFdjiaay6ROKWF/ArOLl5
	 ifA8tvgS//9goCpyK594GiZrYnbqPAhqDo3xI9NnRQ8j8l+1GxC8UAjCTNjOZLlHWvQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Vyc0TIAk;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 066196070DB9;
	Mon,  2 Nov 2026 15:23:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Vyc0TIAk
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 31AFC1F00A17;
	Mon,  2 Nov 2026 15:23:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793633031;
	bh=e6t+ZjLlcl2UBfeg6Fa8p1cvIAPOQLpJeTR6f8fh14w=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Vyc0TIAkWtCaXuSIcqkzHLeKxyzrJXWfZdR7KJ6r92hFll9vSXVA6wBZRD3vYY+uB
	 3sZVdE2NFmTbgG2ddW0Dunqa+sx427e4/M6eCyX7YNulxzXA/Y7RrUt1CRtv0WV1c1
	 VnSdyrjZW1T7JnIrNFbHUTB5G0y2F7yNJ7aKsb2ZXNUPpTdBj7EAlKl0htLsJDFAU0
	 GwPSMja/JtXpY9i9oMZ1zVIV10/ZlPAajmqJjQDUDjAhADIX3yaC33ZI9nceLo+jVL
	 nntEU+f/qQxM5Cqc+RfMImzf9pBGn9CnD6PB9Mfk8jOBpiv3i5NqevVbA17WMV+SOd
	 Cvqc70uXuktPA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:22 +0100
Subject: [PATCH RFC 12/27] locking/lockdep: let procfs own the seq_file of
 /proc/lock_stat
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
Message-Id: <20261102-work-procfs-fs-v1-12-d09a996317b3@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2606; i=brauner@kernel.org;
 h=from:subject:message-id; bh=wBxYZkbuLq2vx9tHnE9HzeQESu+Hnu4x6fVoBaGOq2s=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG4U7TXpwSSf2Lct89uWhW6YtPjWvccbVb/PU9T+v
 vr4N3Ez/Y5SFgYxLgZZMUUWh3aTcLnlPBWbjTI1YOawMoEMYeDiFICJeLkzMrw79v+ffdeGm4Jz
 BNPPLvqwVv2j7OqCSNWSaz/OrW1U/T6D4X/epKx5u14mSBWsvqm6pl/ZYFGsw6souyT3eiYxK2W
 lbj4A
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

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

