Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793630813;
	b=GPk34UsXHps8l4U1AN6ZcKeXGrFhZjxrwb9KPT1qpy8dnTj3kJm36m5kGUBvXDqtFzL4
	 pOMO1jhckaHtzBsjtIgv0hPgZBR2rbgg2lan0+HQfUTGNaDZlcIZhun8MTJAZKFBiXdc9
	 9Mzkv1jNRvJsio0tfJ0WD5a5IKKmbEgpcb4Xf754Rvw45gckXemV59HIsFgKWoQOmKReD
	 1ML9bd7+7r+hSzvxOBQxK7wr8Pg5RFm29c4Yrk67Ghf/eTI4DlzVYB8gKty0JJbdp3L53
	 e9WCELPdfTqifzzLUpdS4HhALnzmuSNH+91fIH1gF8oWhsFgjOgJ7yK2Db9ZdLV62fQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793630813;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer;
	bh=gGh9qQAToZE5wrWgcgjg72Buy8fnK2LgswQGjbfg87A=;
	b=VctTc1D0vKhE7Z+//kNMKTKXo9jCVmn+vgK+kMxJgwzXFpCMU+fjc7gfsENbhaCqfBlf
	 ZWufPfMblzProrp8YadU5J/SJohiW+36Iz+Ddxn2F85aBQEobmy8mVGSF8BfaHX2RyQfK
	 I4PU+JmcYgV99tBN82ztsx8zXMNuiSbLfI7m+TrhDMFy2KbLc4i1MEAeMEcDtg81ZHZB3
	 MorzoaK+Wx6OS2KDg9B9DKMefaTZIm1xRNhuTRGUUqd5GVtzEjJto+DRZJL7seTPaZO/g
	 CN/t3tRipumb0y9nONwpHhteOsJ161FWsPTe5JwOeanit3E8wtCiLDDlvEfW6t2tKmw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=k68ttWG6;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B65BD606A906;
	Mon,  2 Nov 2026 14:46:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=k68ttWG6
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C3FD21F00A1B;
	Mon,  2 Nov 2026 14:46:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793630812;
	bh=gGh9qQAToZE5wrWgcgjg72Buy8fnK2LgswQGjbfg87A=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=k68ttWG6wR2uYUNWQI+ECVf+fO/XJ0eqvyJRIGqlTdn3SeSK5FwYTdTBaVjsoBsYJ
	 kJXwecLDVVqkc0QtPna5nnmOaGhEH6lV2p3+n4SMeLLTjqLfMHRMfS6+IdU5FeP6Ex
	 EEbVMiiZNLXMTNclGmw6p8mC8yLNPYuUSTnCtn6ZR27qjgY9RaX2RJuHLWLPx9jmMt
	 9JJmAL/6SUvZypF7nop8NC5qp7LgJYP8eJFNNtNBvtdk7y2N5+2qF+LGhO9FlXYxla
	 LSU+v/oAHtst3btNP9gxZgyUrKBFNLcCwNm+jD4+mesxl+NmeCWqzBEWi80sNRNQ/1
	 Y+2ZOSQK06ITw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:43:28 +0100
Subject: [PATCH RFC 37/38] proc: don't pin a symlink's entry while
 readlink() copies it out
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
Message-Id: <20261102-work-procfs-bugfixes-v1-37-59422ed3e465@kernel.org>
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
 Chuck Lever <cel@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev

proc_get_link() pins the entry with use_pde() and the delayed call
unpins it. vfs_readlink() copies the link to userspace in between. So a
page fault in that copy holds up remove_proc_entry() just like the
copies of reads and writes do, and the callers hold locks while they
wait. /proc/asound/<id> is removed with snd_card_mutex and info_mutex
held when a card changes its id.

The pin doesn't keep anything alive. proc_symlink() copies the target
and pde_free() frees it with the entry, and the inode holds a reference
to the entry. What the pin does is keep a removed symlink from being
followed. So check ->in_use instead and drop the delayed call. That
also takes an atomic pair off every traversal of /proc/net and
/proc/mounts.

Fixes: 7e0e953bb0cf ("procfs: fix race between symlink removals and traversals")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/inode.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 9933f03ab9fb..2d65f3c8ec03 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -629,19 +629,19 @@ static const struct file_operations proc_iter_file_ops_compat = {
 };
 #endif
 
-static void proc_put_link(void *p)
-{
-	unuse_pde(p);
-}
-
 static const char *proc_get_link(struct dentry *dentry,
 				 struct inode *inode,
 				 struct delayed_call *done)
 {
 	struct proc_dir_entry *pde = PDE(inode);
-	if (!use_pde(pde))
+
+	/*
+	 * No pin. The link lives with the entry, which the inode holds, and a
+	 * reader could fault while vfs_readlink() copies it out. Just don't
+	 * follow a removed one.
+	 */
+	if (unlikely(atomic_read(&pde->in_use) < 0))
 		return ERR_PTR(-EINVAL);
-	set_delayed_call(done, proc_put_link, pde);
 	return pde->data;
 }
 

-- 
2.53.0

