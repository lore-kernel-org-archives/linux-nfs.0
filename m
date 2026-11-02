Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793629798;
	b=hnGvMs4YnO32yIqQwTk4AEwesXu81SvpATW3jyxGFZRDf6Ji/xSw+m+yb6RF0bMxsUcA
	 0Or8x9tEuyVlQl+McpSamgYg7mqCS2yhzhSJbbglg+ejyQUmT49NGkwIAZ0dzfgIWqNoH
	 oc5+GmxAqCzRtvGmVNNuW5p+xQtB06Xr7S542WJ5TP84ZsuyslExs5cYrjezbKRyTw3jy
	 i4kkMM2P1PjgdPazVe52sc9gKNQAqlqXm2SuXiRPYMaDaCuNi7mfUcKojG1ZWx8jFEGhH
	 qwbMc/Hpb6lAbtBdy4/D4MMvoCU+dddB5dSJM9Lcn+/YrD8mnnWA67NjBE6s6zXHicw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793629798;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=SA3lGiy6S79OdVacoNeeNA0LWGoA0p1Ppo9PoyQO2Ks=;
	b=C+qNapFFyF06FUvsw2+RCsBMnB2CycBpRn64S86PoaTg1hKBxGhO1PJGwNCQNVv/nn7W
	 xdhhk95Ub2R9AMG1xaQl7ZpdgUC2d99FhWvOYqv3qXpMlZ96OhOJ9mRITXgy5QwFJs44u
	 clUjhaoGKnfaBlPATgMymcUfsQ3/r2428kLMjaXlQYKPDJzuaqlCOegDnmMieCT9jLkaU
	 GnvGgTU6aLoou2Bh5PBWvKHOclW2DpvQko4Dsb5avYczlzmLEI1nxmRRW8+BJlaBkZgF4
	 fm1qe5Na+tydlp3SGi6FeJuySWX9ZvHiYeejD0/zsRcXvCH2IvZrU/k9VxUUiLEOinA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RW+vtAzi;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 64DD26070D98;
	Mon,  2 Nov 2026 14:29:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RW+vtAzi
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4E3171F00A17;
	Mon,  2 Nov 2026 14:29:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793629798;
	bh=SA3lGiy6S79OdVacoNeeNA0LWGoA0p1Ppo9PoyQO2Ks=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=RW+vtAzixHFdftAw+FFf7X1DqyjNjrm5rXJzLqMgENvUyh6lxSop0zLX2+vQS8q3U
	 qRZVYZNACtSOXvDQAbomlArmJKHhYUFIBB2YrfNds0mv1wfARpxrZIlRmEwlYwFopc
	 5VdZGPqAWRIGCJ/WjNt4zJr1epJ29nqoWmRFqTaIbIhCMRcObitFsIcVlAgJcZod0r
	 ACWF7EpwiUSzD42RWAztKJAwpw5HeZTLOr4cdHEhkz65HDjFGe1NQmquxEr2sddSYL
	 RwpzOOV7W3I2TVeiKdqC8qxeUtM4wH2oSQalOWqHC31war9q1hlS5ta/ceFelklXjl
	 B3xNbX+COlrjQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:21:49 +0100
Subject: [PATCH RFC 34/38] proc: sysctl: look at the table under
 sysctl_lock when creating an inode
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
Message-Id: <20261102-work-procfs-bugfixes-v1-34-59422ed3e465@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2783; i=brauner@kernel.org;
 h=from:subject:message-id; bh=C8EYtx2R+lYWtFHGeY0iXNf5hNAMg0s7P8pl3m1iKgk=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9mJOj8UzGeLUCc9+ZM2pvbvxebnnhmpE+g+SSXWobN
 Dosy223dJSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEzk5QVGhrYU5dR7fIy37FMe
 6+iy+10qiYvReZc66/8Z5ztf76fa+DEynFt/fqvi+l16ifbTVh5Z/+J12e1rnoUitwqfWIbW8FV
 OYgQA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

proc_sys_make_inode() checks under sysctl_lock that @head isn't being
unregistered, lets go of the lock, and then reads the mode of @table
and calls ->set_ownership() with @head. That's fine as long as the
caller holds @head in use, which keeps unregistering from getting past
that check. The next patch has a caller that only pins the memory of
@head. For that one the table, and whatever the owner of the header
keeps behind it, is only there for as long as nobody unregisters the
header, which happens under sysctl_lock. So read the mode and set the
ownership before letting go of the lock. The ->set_ownership()
callbacks only look up ids in a user namespace.

No functional changes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/proc_sysctl.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 2150cf842919..a1242247f492 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -500,6 +500,7 @@ static struct inode *proc_sys_make_inode(struct super_block *sb,
 	struct ctl_table_root *root = head->root;
 	struct inode *inode;
 	struct proc_inode *ei;
+	umode_t mode;
 
 	inode = new_inode(sb);
 	if (!inode)
@@ -509,12 +510,22 @@ static struct inode *proc_sys_make_inode(struct super_block *sb,
 
 	ei = PROC_I(inode);
 
+	inode->i_uid = GLOBAL_ROOT_UID;
+	inode->i_gid = GLOBAL_ROOT_GID;
 	spin_lock(&sysctl_lock);
 	if (unlikely(head->unregistering)) {
 		spin_unlock(&sysctl_lock);
 		iput(inode);
 		return ERR_PTR(-ENOENT);
 	}
+	/*
+	 * The table, and whatever the owner of the header keeps behind it,
+	 * is only there for as long as nobody unregisters the header, which
+	 * happens under sysctl_lock. So look at them before letting go of it.
+	 */
+	mode = table->mode;
+	if (root->set_ownership)
+		root->set_ownership(head, &inode->i_uid, &inode->i_gid);
 	ei->sysctl = head;
 	ei->sysctl_entry = table;
 	hlist_add_head_rcu(&ei->sibling_inodes, &head->inodes);
@@ -522,8 +533,8 @@ static struct inode *proc_sys_make_inode(struct super_block *sb,
 	spin_unlock(&sysctl_lock);
 
 	simple_inode_init_ts(inode);
-	inode->i_mode = table->mode;
-	if (!S_ISDIR(table->mode)) {
+	inode->i_mode = mode;
+	if (!S_ISDIR(mode)) {
 		inode->i_mode |= S_IFREG;
 		inode->i_op = &proc_sys_inode_operations;
 		inode->i_fop = &proc_sys_file_operations;
@@ -535,11 +546,6 @@ static struct inode *proc_sys_make_inode(struct super_block *sb,
 			make_empty_dir_inode(inode);
 	}
 
-	inode->i_uid = GLOBAL_ROOT_UID;
-	inode->i_gid = GLOBAL_ROOT_GID;
-	if (root->set_ownership)
-		root->set_ownership(head, &inode->i_uid, &inode->i_gid);
-
 	return inode;
 }
 

-- 
2.53.0

