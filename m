Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820464;
	b=BAZw6L7wJRfGb16UHqJg5G1bAwztw3+IyXD7b/3c5pggoyAQ9DrIazmD9GXB7bJiqq44
	 Gt6a0zrXec4i9urzgE+0gyN1o4cyY+uAxcvEHMYD9zl7RuzafVV8FouPG9eNdwxLZ02kf
	 tWJm6Ef+rN6LKuXhjfWpxxE2BiH4Nf43TT25YRZay1f3+VZohMlR1ezIXHNo8K69EUIOd
	 kaj4e5nVldke8sF4XWxFkUvoqKdjMvYlKSI3OsBjNRaEmTI8o91h1Zu/JE0fS0t/SdyL+
	 POUqbUkHWZikWOW+JXJhSB2G+qmIyrDBKmpkUB/0BhglvmD5MvhL+1fIFGr2ll5856g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820464;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=8vwIQDZABfbDXUA4Rhtj/FFiRIzet50vFXOLtBzgPyU=;
	b=ku09+zXQTh8i0ILDGXuUNXTcv+U5ev4dPOlrNIs0CpBsAusoX64y93HNUv2pV3TGgYrW
	 owpdRBGTjWDy+8J5xWmAyOnvO64p+zJtDHyo1dGfoVv/jpGHQPw27eQRbW6LNtrcjY90C
	 zsfRT9OaYbUe5955ZjYWKvuKkeUCumyuyCQPlNasBI0nDYv/GHITPyFU9r/dO5gPbRDST
	 tdINNolqCT9n8OTadD45gx+wPz6dOqHT6zpRnth6259c46Amb9tKdT75JZkvy442ov25w
	 q3LbUA4OgLInsLTuDE57Nc/p2Z+gSwB3Luy7+JGNid11Zxsq6CEztiLavpUZWPT/D1w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=K+qv0mwQ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AAB8F6070A97;
	Wed,  4 Nov 2026 19:27:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=K+qv0mwQ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9BA621F000C1;
	Wed,  4 Nov 2026 19:27:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820463;
	bh=8vwIQDZABfbDXUA4Rhtj/FFiRIzet50vFXOLtBzgPyU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=K+qv0mwQcjtL/qGdS6zLTIdv/G0RXM8xsdMjUnhgG0fNfAYk4b2pJX930sQZnPQep
	 +LPdNInthRhEsKuQKDBplBRNncD5RXDkf1MmvrNYXt/kezR7Og4AukJlDkC+uqQdvQ
	 3UcyZsZ5M2SCBuJu/oEitA7gekht06is34RQC+0SGBCyvPBf2/f+wRq4YKjtHH607t
	 u2wONuJ6/ShFerskIef6UB1DalfazMx1QVWxa/FYtYmDpi1QxRXXlAEaJ1aaOkdQFG
	 kAOIkXKB/WNg0BuIpmEdndNkSZIlkssgbriZFcnsRM4VXunhgfFvWP2W8uGj5+pKbF
	 w0V3MGDPqlrPQ==
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
Subject: [PATCH RESEND v2 47/51] proc: sysctl: look at the table under sysctl_lock when creating an inode
Date: Wed,  4 Nov 2026 20:27:29 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-47-021c84d852e0@kernel.org>
In-Reply-To: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
References: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2783; i=brauner@kernel.org; h=from:subject:message-id; bh=qNc6cmXDzjiIgH+LQmxRb8DpjTAU1o7z7wzEsOSW+y4=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bmJza0sIPDqr+OtjFeG4XR03HmoLr7n57Jt/hcxie 69L4b9dO0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACbi187wv2hWT/9l9+XPdiy4 Mvm7x6F5LA4Csrv4Z0ak9SrWM8XotDD8M7ASkA469SZgqbzuxov6f2ekegdpRrKw1vJ3ZETYaKT yAAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

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
index f5c9f04e8509..82024f1ea756 100644
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

