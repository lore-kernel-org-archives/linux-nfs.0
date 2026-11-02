Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793633052;
	b=wHjdsBIM1A6xgE/tcKVXpezblP5eHRhuzQOtW6ITFnizJhESPQInJZ097wOhw4ktXwp4
	 CdcJ6iS0QNL4YVFkLBBYm8qVuB+nNiigrw0MkYczrisAEtzL8eptls/6+KbpWngB7Omj0
	 FYLGGfixUJm6mY3p5tJJDS9lW8WpxI2am+htxesGgdMDwBtRvl1ryngTgiqVrVgUOTNZj
	 RtvHaM6CyaVlP+L2wtYNoZDr7UtiLSbu3AUTnG0vjoF0MVwIuQ/b6DBIzzt4Cv7m+dOow
	 /Qga9+QWlCKqgbr2cyLRH4wAXEJTk+4/7P5dB6XIOGRhAKNX/zNSz3aQjHR7GTjOHZg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793633052;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=0DA6RuBvRtTkFqswtNQb2uYlEiZpU59l9tIHU1Ga2j8=;
	b=xnr0d59GCbpg1Cj1gA6LxtkMTIUHiNkTQmQei5VqZMsulLzQyqRtm3y6dRHcVOr2ALlg
	 mfZbjS2yQvUQU14NkP1VcEoAh9qIzkGE7N6D6re9AA2+MyCg/D91T1ao+D1J7PSdstvar
	 iFwd4aO2Nmp/ygc3Fw12PgHJWknW4TUYGgbbDYg6uRj7OODNc2ejqMvt9O2WmsDlA7qFH
	 TuXde/BsT73PPLfr1Ma6ZwHADTO8JHgEkDbWLgAJfNdONKsu2+GvY7v6IWUOQxjOREWKq
	 J86vI2Xby8r1NWiNx71Y4z7LAfooq+c/2BvHC8ERTYsXmOsD1rOrP8fPpMI2bwEZidQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Wzv23e35;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 767466098149;
	Mon,  2 Nov 2026 15:24:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Wzv23e35
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 967341F00A16;
	Mon,  2 Nov 2026 15:23:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793633052;
	bh=0DA6RuBvRtTkFqswtNQb2uYlEiZpU59l9tIHU1Ga2j8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Wzv23e35LlF722Cfqg73FBGVnhxt+H5uTjMVTnB7asIIrTAol+UsSWODD3A9JMAWW
	 CHeJx+/sOCjLZSq1s4VoynRxvWm7XhKnNjGUb4tFL3st5AhwGX1X8EXNyiNSob8zfe
	 hPoA0Jwnc94AejcwzAl8mS34lOo0kwPJnFcg+lOSVQtUdf4OqaeMQYnXbxeWnmbXEb
	 AX7yo9n+oT0VV5xUQw7x3ALW+dHnEd/WKJEInzk6ceYQfrGKcinK0xZJkLZt2jHfOm
	 CKZoFbsH8Uf/vBc0GUbzhEZ6RBBP6OGx93Jv1yb/leud/4X919tLDeUZ9h/mDfqa8c
	 5djzkG/VTzWXw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:23 +0100
Subject: [PATCH RFC 13/27] locking/lockdep: let procfs copy in writes to
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
Message-Id: <20261102-work-procfs-fs-v1-13-d09a996317b3@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1505; i=brauner@kernel.org;
 h=from:subject:message-id; bh=8vcSfGoyDeqLJaquRqiN2D+SQsNeRK8HAS3H3FbecE8=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG6k0HtsppuIOtP74Igd108lcc3fGSuzcnJdKhtD4
 so7t2c0dZSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAExkkQEjQ+ONtmlOpu7yPdtO
 f6mefC2DpTVNKs/EavHuEoFe/ryYWEaGI5/jjbfc+3ttHUtbJafnBWsGE6vUrY4/vk118NKbYRj
 KAAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Implement ->proc_write_buf() so procfs copies in what is written before
it pins the entry, and look at the first character of that copy. Writes
larger than PAGE_SIZE - 1 bytes fail with -EINVAL now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 kernel/locking/lockdep_proc.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/kernel/locking/lockdep_proc.c b/kernel/locking/lockdep_proc.c
index 9b034b5b94bd..2a66ea09c2aa 100644
--- a/kernel/locking/lockdep_proc.c
+++ b/kernel/locking/lockdep_proc.c
@@ -669,18 +669,14 @@ static int lock_stat_open(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static ssize_t lock_stat_write(struct file *file, const char __user *buf,
-			       size_t count, loff_t *ppos)
+static ssize_t lock_stat_write(struct file *file, char *buf, size_t count,
+			       loff_t *ppos)
 {
 	struct lock_class *class;
 	unsigned long idx;
-	char c;
 
 	if (count) {
-		if (get_user(c, buf))
-			return -EFAULT;
-
-		if (c != '0')
+		if (buf[0] != '0')
 			return count;
 
 		iterate_lock_classes(idx, class) {
@@ -703,7 +699,7 @@ static int lock_stat_release(struct inode *inode, struct file *file)
 static const struct proc_ops lock_stat_proc_ops = {
 	.proc_seq_ops	= &lockstat_ops,
 	.proc_open	= lock_stat_open,
-	.proc_write	= lock_stat_write,
+	.proc_write_buf	= lock_stat_write,
 	.proc_release	= lock_stat_release,
 };
 #endif /* CONFIG_LOCK_STAT */

-- 
2.53.0

