Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793629601;
	b=CTgomip1yfz4yo3Umb3XbXBZ/Ca/KRlQmNqVJyDzeSpShzD1HAlb3PwAcfJ0uBMv91kB
	 d9H7wXOs0m04xqrogUS7bC9tIaZrrAgT1UHjCR5HjdzvudCrbGMsLRNkeEfChnMdO73jR
	 MxtwabKkjAoaKbav0xXpwmoazokV+XXXIfyUO5g/D3H//LS0HR+ErB+05h6ucAWTpXtsl
	 JDJewmqbt/pnpz9g6hmR+yzjww2FdNIzaq6fJkb+DOS0fPEKBsBIT6AbqOH+C2g0rPJ1/
	 fFGXXZkWF1IhjjOHJLEHLTAGe8auesSLFUPFw29iSRhZpT5jakPrivgMpA2ne3iuYNQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793629601;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=XyS11ffq54Sp7hLIWVW3dn1ZYIS4v3sn4XvdfnHyHBY=;
	b=L5h8SRmo3vuQ+iHL19dY6TlTdzRZQGUeNH6HLDemNbI3ZndrYtfmZ7kFdQuVIjSglIqw
	 VdJMfvAxIjiCMmraclXcPUKYxlTpQzxapMtqf0RTZg754JLqUJX612jIBAa2IFZAkyQyR
	 45ECPjqEPuy85/1uTddzPeubMCczPksqgsFQfj/dhCkjskXzmqx8AuTkc4/nk8qoaP/hc
	 Qq7F1OBZUyB2ogbgV3GW9Qh5cSGEs0w7PMGoSSROTbyESaMKz8OlTl420UA9k0NaTj6LQ
	 opgVu2WLS54oxiZLJPEUwvElG6uQxlvJHA7FUsB1VJCE2Rr2JPaBLFKtK9DqdaQG9og==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oOTHfPnj;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 91EF2606D821;
	Mon,  2 Nov 2026 14:26:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oOTHfPnj
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C35591F00A18;
	Mon,  2 Nov 2026 14:26:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793629601;
	bh=XyS11ffq54Sp7hLIWVW3dn1ZYIS4v3sn4XvdfnHyHBY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=oOTHfPnjZImvmmRPM2MTN/E/IIH+K1Xm8QDVrH8Oqlt/AJsi4waiHv9CftkJy/6ni
	 6EIRp0HbnhNfXHCXc4K9VojrITUlGyR3GhezVAOLc4o/UIMtBv2UXRIoUyNcRoDRfl
	 hwij2c23hqVe3wrkk0JhAPavUcN3D/QHGIgP+swQEOLquf8jyQsTyTqg2D9L7WX2yM
	 2YVUuBtbVOY3/D4t49N5Yy+FRqPEDXIaeGHoQTT7h7Tt3ELLZfedzkDX06MymVZHGo
	 gZ83lZ/ZcoL9USNS1bfrcS7dOsq69wrvT9Qy2snDigPKgQfSdgsNGiZ+ZmulPoiK7N
	 lLvjE7UUh2gCA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:21:36 +0100
Subject: [PATCH RFC 21/38] proc: let proc_remove() remove the entry it was
 given
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
Message-Id: <20261102-work-procfs-bugfixes-v1-21-59422ed3e465@kernel.org>
References: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
In-Reply-To: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=4142; i=brauner@kernel.org;
 h=from:subject:message-id; bh=adm/sQF7056an061Kf+c19uk6i/tg5VeFqy/1HsVnNo=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9mJO94Vf79rbgFkGjg/dWX74aWPnxgZ3nnePVE5vOV
 HF8N+le01HKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjAR6Q+MDM3FETYHc1qe353c
 9GCX1JmypW9EjzP2Bgsk5O+InsxuNJ3hn1riCsbHBiye0iWZCQbb/19b1Pias9fFyzP/0MYJD5e
 u4AAA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

proc_remove() looks the entry up by its name in its parent and removes
whatever it finds there:

  remove_proc_subtree(de->name, de->parent);

If the entry was removed already, say along with its parent, that is
either nothing or a different entry that got the same name in the
meantime, and de->parent may well be gone. Two removals of the same
entry are a bug in the caller, but going by the name turns it into
removing an entry that belongs to somebody else.

Since commit 895b4c0c79b0 ("fs/proc: fix uaf in proc_readdir_de()")
an entry that was unlinked has an empty rb node. So check for that
under proc_subdir_lock and otherwise remove the entry itself, with the
loop of remove_proc_subtree() moved into a helper both of them use.
Nothing can help a caller that passes an entry that has been freed
already.

Reported-by: Chris Mason <mason@kernel.org>
Fixes: a8ca16ea7b0a ("proc: Supply a function to remove a proc entry by PDE")
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/generic.c | 78 ++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 51 insertions(+), 27 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 47830d6af255..23fc026d7bbb 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -817,33 +817,14 @@ void remove_proc_entry(const char *name, struct proc_dir_entry *parent)
 }
 EXPORT_SYMBOL(remove_proc_entry);
 
-int remove_proc_subtree(const char *name, struct proc_dir_entry *parent)
+/*
+ * Remove @root, already erased from its parent, and everything below it.
+ * Called with proc_subdir_lock held for writing, returns with it dropped.
+ */
+static int __remove_proc_subtree(struct proc_dir_entry *root)
 {
-	struct proc_dir_entry *root = NULL, *de, *next;
-	const char *fn = name;
-	unsigned int len;
-
-	write_lock(&proc_subdir_lock);
-	if (__xlate_proc_name(name, &parent, &fn) != 0) {
-		write_unlock(&proc_subdir_lock);
-		return -ENOENT;
-	}
-	len = strlen(fn);
+	struct proc_dir_entry *de = root, *next;
 
-	root = pde_subdir_find(parent, fn, len);
-	if (!root) {
-		write_unlock(&proc_subdir_lock);
-		return -ENOENT;
-	}
-	if (unlikely(pde_is_permanent(root))) {
-		write_unlock(&proc_subdir_lock);
-		WARN(1, "removing permanent /proc entry '%s/%s'",
-			root->parent->name, root->name);
-		return -EINVAL;
-	}
-	pde_erase(root, parent);
-
-	de = root;
 	while (1) {
 		next = pde_subdir_first(de);
 		if (next) {
@@ -871,6 +852,34 @@ int remove_proc_subtree(const char *name, struct proc_dir_entry *parent)
 	pde_put(root);
 	return 0;
 }
+
+int remove_proc_subtree(const char *name, struct proc_dir_entry *parent)
+{
+	struct proc_dir_entry *root = NULL;
+	const char *fn = name;
+	unsigned int len;
+
+	write_lock(&proc_subdir_lock);
+	if (__xlate_proc_name(name, &parent, &fn) != 0) {
+		write_unlock(&proc_subdir_lock);
+		return -ENOENT;
+	}
+	len = strlen(fn);
+
+	root = pde_subdir_find(parent, fn, len);
+	if (!root) {
+		write_unlock(&proc_subdir_lock);
+		return -ENOENT;
+	}
+	if (unlikely(pde_is_permanent(root))) {
+		write_unlock(&proc_subdir_lock);
+		WARN(1, "removing permanent /proc entry '%s/%s'",
+			root->parent->name, root->name);
+		return -EINVAL;
+	}
+	pde_erase(root, parent);
+	return __remove_proc_subtree(root);
+}
 EXPORT_SYMBOL(remove_proc_subtree);
 
 void *proc_get_parent_data(const struct inode *inode)
@@ -882,8 +891,23 @@ EXPORT_SYMBOL_GPL(proc_get_parent_data);
 
 void proc_remove(struct proc_dir_entry *de)
 {
-	if (de)
-		remove_proc_subtree(de->name, de->parent);
+	if (!de)
+		return;
+
+	write_lock(&proc_subdir_lock);
+	/* Removed already, maybe along with its parent. */
+	if (RB_EMPTY_NODE(&de->subdir_node)) {
+		write_unlock(&proc_subdir_lock);
+		return;
+	}
+	if (unlikely(pde_is_permanent(de))) {
+		write_unlock(&proc_subdir_lock);
+		WARN(1, "removing permanent /proc entry '%s/%s'",
+		     de->parent->name, de->name);
+		return;
+	}
+	pde_erase(de, de->parent);
+	__remove_proc_subtree(de);
 }
 EXPORT_SYMBOL(proc_remove);
 

-- 
2.53.0

