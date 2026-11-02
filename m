Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793631041;
	b=iYvD9FDlaxTfqrzrDz70x5ez4bunA0SdEcWtWoXqjgW/f73+wqtw3IzLUOk0RWl/xcDr
	 YObVSPtZt9awdlY73DM/AyJfDEiZaNNzW4mLGEQWhLW7hFJMrH56eV5smXTuFl4XwtZR/
	 zKbVF5uTdvmFx1cSyk/vjtS32ZfKvR7L945cuNHUPyDlot3Mg5ZKZg5D0FueeF4woXBNt
	 OPMDQF5xgw4/Enpikb1yK2C/e2Gz4KuHWHbtGUMxNBbOlq0nMlDnyeLkzL9Qd0ZRfBg6h
	 Xc/5mJ0v0TV83idBwFyKJrqEuC0nKEYtvVcSJGUOqlModF+cYlwvGbOQeuhTs0/ZdjQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793631041;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer;
	bh=Y5WGF4nYEFlZEICsyJ9kBee66sAEV9dY/9UPORxJKAY=;
	b=tD9rxuoC+AMoWdYcSIGddYIB9oVCsJGqZgkbuwdVBlD0Ldxc5MXLGVA/LF9YsjF2E0Qx
	 ZP6xGejvrpHPsuVDZhU+yLe72GZGLyHSDB7ytJse2Lt3fV73O/pUR4BeG8WFXatidkola
	 aO0IOVsPDrXnRGRwNh4mKJvVJ+iuL11YvtDKbPRcGcLc69IZoRp0FKyrVsrrjshXaYxH8
	 AF8MTFWwyjShyoEuUtzPWDlmxrCGSUb2o10hT+Rs+6CrdaRCQ28d8FuuUOpjRKap7+hrj
	 jb64IjQ8AnMg/MUUVU3x5Wn5IARs64SpkhBS/Ga7gmtokBLJVRHZDilJWBtrSVv7phw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="E+Ez+r/w";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E02B7606B1DE;
	Mon,  2 Nov 2026 14:50:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=E+Ez+r/w
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5E72A1F00A1D;
	Mon,  2 Nov 2026 14:50:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793631040;
	bh=Y5WGF4nYEFlZEICsyJ9kBee66sAEV9dY/9UPORxJKAY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=E+Ez+r/wxzU2Gtcf5D8LdDilirwAFUov5C06lfDFwMgTzQVfbxMtt8fKYuGRsMRh4
	 Ckk9DN/UFiXuxu9YL3fuJE1EWmK9hRCH3J9jOkyAoKEzOflfONYsx3P9+qRLeFxGDS
	 /40M8mqyFHF8oYbXu1Q4J7JKbzxQEJ1GkgOZm6vz5wKg3rhpJPRpykA8y0NgnKZQ/l
	 mpendCXxg/qj9vJFA6Ul5z1piuGWhxjd1u4ugCdjQbkV4cRv9KN+exxYsD+XXDuRdm
	 smu4R2wbuW2Omoi0r7pRXtoIQkEdgbLO333wdPaf0nMrT2B0lmnYWO+uXkuGHKxxCT
	 tADO5izDMPJ4Q==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:48:45 +0100
Subject: [PATCH RFC 05/16] proc: let procfs own the seq_file of
 proc_create_seq() and friends
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
Message-Id: <20261102-work-procfs-core-v1-5-75df35e4f8b8@kernel.org>
References: <20261102-work-procfs-core-v1-0-75df35e4f8b8@kernel.org>
In-Reply-To: <20261102-work-procfs-core-v1-0-75df35e4f8b8@kernel.org>
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

proc_create_seq_private(), proc_create_single_data() and their network
namespace variants keep the seq_operations or the show function in the
entry already. Let procfs own the seq_file for all of them. For the
network namespace variants ->proc_open() and ->proc_release() keep
taking and dropping the reference to the network namespace.

That's most of /proc/net, among them the files of xt_hashlimit and
/proc/net/dev_snmp6/<dev>. A reader that faults on its buffer no longer
holds up their removal.

Reported-by: Chris Mason <mason@kernel.org>
Fixes: 786d7e1612f0 ("Fix rmmod/read/write races in /proc entries")
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/generic.c  | 42 ++++--------------------------------------
 fs/proc/proc_net.c | 40 +++++++++++++---------------------------
 2 files changed, 17 insertions(+), 65 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index eff5c38e2219..6ed8bc313db0 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -694,30 +694,9 @@ struct proc_dir_entry *proc_create(const char *name, umode_t mode,
 }
 EXPORT_SYMBOL(proc_create);
 
-static int proc_seq_open(struct inode *inode, struct file *file)
-{
-	struct proc_dir_entry *de = PDE(inode);
-
-	if (de->state_size)
-		return seq_open_private(file, de->seq_ops, de->state_size);
-	return seq_open(file, de->seq_ops);
-}
-
-static int proc_seq_release(struct inode *inode, struct file *file)
-{
-	struct proc_dir_entry *de = PDE(inode);
-
-	if (de->state_size)
-		return seq_release_private(inode, file);
-	return seq_release(inode, file);
-}
-
+/* procfs owns the seq_file of these, see pde_seq_ops */
 static const struct proc_ops proc_seq_ops = {
 	/* not permanent -- can call into arbitrary seq_operations */
-	.proc_open	= proc_seq_open,
-	.proc_read_iter	= seq_read_iter,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= proc_seq_release,
 };
 
 struct proc_dir_entry *proc_create_seq_private(const char *name, umode_t mode,
@@ -732,25 +711,11 @@ struct proc_dir_entry *proc_create_seq_private(const char *name, umode_t mode,
 	p->proc_ops = &proc_seq_ops;
 	p->seq_ops = ops;
 	p->state_size = state_size;
+	p->flags |= PROC_ENTRY_proc_seq_ops;
 	return proc_register(parent, p);
 }
 EXPORT_SYMBOL(proc_create_seq_private);
 
-static int proc_single_open(struct inode *inode, struct file *file)
-{
-	struct proc_dir_entry *de = PDE(inode);
-
-	return single_open(file, de->single_show, de->data);
-}
-
-static const struct proc_ops proc_single_ops = {
-	/* not permanent -- can call into arbitrary ->single_show */
-	.proc_open	= proc_single_open,
-	.proc_read_iter = seq_read_iter,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
-};
-
 struct proc_dir_entry *proc_create_single_data(const char *name, umode_t mode,
 		struct proc_dir_entry *parent,
 		int (*show)(struct seq_file *, void *), void *data)
@@ -760,8 +725,9 @@ struct proc_dir_entry *proc_create_single_data(const char *name, umode_t mode,
 	p = proc_create_reg(name, mode, &parent, data);
 	if (!p)
 		return NULL;
-	p->proc_ops = &proc_single_ops;
+	p->proc_ops = &proc_seq_ops;
 	p->single_show = show;
+	p->flags |= PROC_ENTRY_proc_show;
 	return proc_register(parent, p);
 }
 EXPORT_SYMBOL(proc_create_single_data);
diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index df5484813d5d..fa485581d05e 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -37,13 +37,13 @@ static struct net *get_proc_net(const struct inode *inode)
 	return maybe_get_net(PDE_NET(PDE(inode)));
 }
 
+/* procfs opened the seq_file and allocated its state, see pde_seq_ops */
 static int seq_open_net(struct inode *inode, struct file *file)
 {
-	unsigned int state_size = PDE(inode)->state_size;
-	struct seq_net_private *p;
+	struct seq_net_private *p = ((struct seq_file *)file->private_data)->private;
 	struct net *net;
 
-	WARN_ON_ONCE(state_size < sizeof(*p));
+	WARN_ON_ONCE(PDE(inode)->state_size < sizeof(*p));
 
 	if (file->f_mode & FMODE_WRITE && !PDE(inode)->write)
 		return -EACCES;
@@ -51,12 +51,6 @@ static int seq_open_net(struct inode *inode, struct file *file)
 	net = get_proc_net(inode);
 	if (!net)
 		return -ENXIO;
-
-	p = __seq_open_private(file, PDE(inode)->seq_ops, state_size);
-	if (!p) {
-		put_net(net);
-		return -ENOMEM;
-	}
 #ifdef CONFIG_NET_NS
 	p->net = net;
 	netns_tracker_alloc(net, &p->ns_tracker, GFP_KERNEL);
@@ -77,18 +71,13 @@ static void seq_file_net_put_net(struct seq_file *seq)
 
 static int seq_release_net(struct inode *ino, struct file *f)
 {
-	struct seq_file *seq = f->private_data;
-
-	seq_file_net_put_net(seq);
-	seq_release_private(ino, f);
+	seq_file_net_put_net(f->private_data);
 	return 0;
 }
 
 static const struct proc_ops proc_net_seq_ops = {
 	.proc_open	= seq_open_net,
-	.proc_read	= seq_read,
 	.proc_write	= proc_simple_write,
-	.proc_lseek	= seq_lseek,
 	.proc_release	= seq_release_net,
 };
 
@@ -125,6 +114,7 @@ struct proc_dir_entry *proc_create_net_data(const char *name, umode_t mode,
 	p->proc_ops = &proc_net_seq_ops;
 	p->seq_ops = ops;
 	p->state_size = state_size;
+	p->flags |= PROC_ENTRY_proc_seq_ops;
 	return proc_register(parent, p);
 }
 EXPORT_SYMBOL_GPL(proc_create_net_data);
@@ -170,6 +160,7 @@ struct proc_dir_entry *proc_create_net_data_write(const char *name, umode_t mode
 	p->proc_ops = &proc_net_seq_ops;
 	p->seq_ops = ops;
 	p->state_size = state_size;
+	p->flags |= PROC_ENTRY_proc_seq_ops;
 	p->write = write;
 	return proc_register(parent, p);
 }
@@ -177,32 +168,25 @@ EXPORT_SYMBOL_GPL(proc_create_net_data_write);
 
 static int single_open_net(struct inode *inode, struct file *file)
 {
-	struct proc_dir_entry *de = PDE(inode);
-	struct net *net;
-	int err;
+	struct net *net = get_proc_net(inode);
 
-	net = get_proc_net(inode);
 	if (!net)
 		return -ENXIO;
-
-	err = single_open(file, de->single_show, net);
-	if (err)
-		put_net(net);
-	return err;
+	((struct seq_file *)file->private_data)->private = net;
+	return 0;
 }
 
 static int single_release_net(struct inode *ino, struct file *f)
 {
 	struct seq_file *seq = f->private_data;
+
 	put_net(seq->private);
-	return single_release(ino, f);
+	return 0;
 }
 
 static const struct proc_ops proc_net_single_ops = {
 	.proc_open	= single_open_net,
-	.proc_read	= seq_read,
 	.proc_write	= proc_simple_write,
-	.proc_lseek	= seq_lseek,
 	.proc_release	= single_release_net,
 };
 
@@ -218,6 +202,7 @@ struct proc_dir_entry *proc_create_net_single(const char *name, umode_t mode,
 	pde_force_lookup(p);
 	p->proc_ops = &proc_net_single_ops;
 	p->single_show = show;
+	p->flags |= PROC_ENTRY_proc_show;
 	return proc_register(parent, p);
 }
 EXPORT_SYMBOL_GPL(proc_create_net_single);
@@ -261,6 +246,7 @@ struct proc_dir_entry *proc_create_net_single_write(const char *name, umode_t mo
 	pde_force_lookup(p);
 	p->proc_ops = &proc_net_single_ops;
 	p->single_show = show;
+	p->flags |= PROC_ENTRY_proc_show;
 	p->write = write;
 	return proc_register(parent, p);
 }

-- 
2.53.0

