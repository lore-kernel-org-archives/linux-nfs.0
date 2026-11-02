Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793632850;
	b=Fdauo30XBovHVT8goLkBBAVDh/Iwo1uLQjGkMPOPRBkTk5d2Ac6Q4tpFESr/quryZEXj
	 83dfIlep/15kto/wLk4CgL45Gw1FlAi7UNMkTu66t5Xtf3t7jhIbSGZy1BeqwgpY7DFEL
	 p9XOUbkIkD32h6D5imbfweDaU6yU05yMlC8+8e073BBsJeJUJHMS8PExAfgN0ZgzNBhuI
	 421eOn49Id+ourFIrQHORLh4eiXoQmM4jbNT3hNqK4igqcRUrvDpEa2sq8vXh9NYVcPsc
	 vlDvKgvZ5Aq2VbSKNJvNjIy2pDBnvkf0R2GEaJlSkxoUl+Zp8bKxcJ0P2PRSusrYEfg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793632850;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=vVBne5gselOZS7qaEMuXaEvBAuXwNF+VXq/xDlGRpv8=;
	b=SwMbqrHwrXP5qfJH9jZMbSCsKYHHmZcFZP0yKH8k2HGRbIOjgv3FnGsbNd6sKPSg9V2g
	 Ey11O2HU4jKZxKEX0OxSJw+xo08slfQ1CKAqH3qoWSbfKZCLsYnagn5YxksqK5FTaikC5
	 hwlPpzs0MUXlBGSiVf8U7osVi1GMGPiYD2u49Who2XhYMSk3RkKsPqTzc8S50kNy8UjbU
	 M++nhPOGKPS4xxyEMUU4QZqq4fHvoXDE0JKgdemgznGbWCj+zaOpep68umMX34EsNrPxe
	 8JWKy8suT6nYsbrqSSSml1d1SCEcyJVL4hNgE6hPRjkw3QHOgqIdNzV2UmtWu+8bWjg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="gr5d/R5Q";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5331E607F10E;
	Mon,  2 Nov 2026 15:20:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gr5d/R5Q
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 74D411F00A16;
	Mon,  2 Nov 2026 15:20:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793632849;
	bh=vVBne5gselOZS7qaEMuXaEvBAuXwNF+VXq/xDlGRpv8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=gr5d/R5QulyTLxLD3/MAYMmLMYbT35xK6aId1t52Eow8QSEABCm8rzX4k2Z5I8Uv+
	 UD3L6bdcCyDENgjDUaRYaIjBpv9KifSo7KdKtRyWAroMom4KY5WF+Ln9EUR/OU8bIw
	 cfIbJFU0gkdeaQcslP0HV9lJfr+zxpqlFkl/tfWZ6xjZPkExH482FMNrcXoifnZDpb
	 BBMpFNPyNBOQcsBD+Cr7KjsIhvpuH/wA12Pa4HnVFFk/4VUZAo7SAy5riWBb7UiSlV
	 k2iUhU3k2r67F3NXxANMDiQuT8gkSLpR87qwXkRQSfThiB+qYgkMJbi1jVvEbOj1vw
	 BbGpsyobrAFbw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:14 +0100
Subject: [PATCH RFC 04/27] lockd: let procfs copy out reads of
 nlm_end_grace
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
Message-Id: <20261102-work-procfs-fs-v1-4-d09a996317b3@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1257; i=brauner@kernel.org;
 h=from:subject:message-id; bh=eZ2kMMEIgx0JCcy46KFAm+0lqPvZbTWW97pZVUITElw=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG74O2799hNsR6IfK5pKSQjHJsw/YPHc0p7/jSlHm
 OeZhvliHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABPZ/ImR4eZSzSvCL/kZRC1V
 N2gkpD259yrLxz9novylvNjbUvvXtzEyLO2o59UOLix8XXD14rToR6HSd+5s+1rF8C/DcQqPudp
 iTgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Implement ->proc_read_buf() so procfs copies what is read to userspace
after it unpinned the entry.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/lockd/procfs.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/procfs.c b/fs/lockd/procfs.c
index 47949bec7a09..34a7c3705bb6 100644
--- a/fs/lockd/procfs.c
+++ b/fs/lockd/procfs.c
@@ -40,7 +40,7 @@ nlm_end_grace_write(struct file *file, char *buf, size_t size, loff_t *pos)
 }
 
 static ssize_t
-nlm_end_grace_read(struct file *file, char __user *buf, size_t size,
+nlm_end_grace_read(struct file *file, char *buf, size_t size,
 		   loff_t *pos)
 {
 	struct lockd_net *ln = net_generic(current->nsproxy->net_ns,
@@ -51,12 +51,12 @@ nlm_end_grace_read(struct file *file, char __user *buf, size_t size,
 	resp[1] = '\n';
 	resp[2] = '\0';
 
-	return simple_read_from_buffer(buf, size, pos, resp, sizeof(resp));
+	return memory_read_from_buffer(buf, size, pos, resp, sizeof(resp));
 }
 
 static const struct proc_ops lockd_end_grace_proc_ops = {
 	.proc_write_buf	= nlm_end_grace_write,
-	.proc_read	= nlm_end_grace_read,
+	.proc_read_buf	= nlm_end_grace_read,
 	.proc_lseek	= default_llseek,
 };
 

-- 
2.53.0

