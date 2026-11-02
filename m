Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793633574;
	b=f4m/z7Lixh8dRPf6XP8cTdUifhH9aFtP9PEQ1qBcFQjMvAlWGwuvWL4dHBr4P9C18XBj
	 5gRho4iKXYusuM6bGPEzWZNIZrEga5UnBZpCSEd9DVb43BSe1Tm2m/rT67eZszZT8m7oi
	 +2TfUvY2ca+WnsEF5vEcVd3UCnr9DQltq3BD/Bpf286Bpzqs2esmVU9nkfci0wK7d2+1F
	 SdzLNWqKJsbp2BRYHTJvLEvjaZqpl3j6kbN2Eca+0RevjArdxMoik8TAtZvM03LHYyZVF
	 tpIU5spftdnxGzbUQGW8wJCtwan8lmt9JYU4ddRkMVdNeqgqJUPEyvFS4CxZzXOZJUQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793633574;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=xwE+gN56hE51AorwZpbrVa8dzdnGmSpFpcgiuf3dvqw=;
	b=Op51GBzF0Lx/p1mPozUwANmBPYp45VVDJ8X7NMmnFuxSIV+l0jaEiur7kC8fHIf+UTU3
	 LJLJDwANOaEKsgZj7DjB0yZzDv6a8WCRIw+978KuYN+frCj3TQbpRJD3RG04oHih0BfRP
	 8ue4bxGpivcKmSAK3pDCiv7ZB8qbWeQhYP9bqfxER01BlVdWamrGkszWjxNKn+BQtWV+A
	 RqrekFicnJDAelpU8iWoda4NbtLpf8p/VRGb8owohqdjWm2KAYiXHzKSUtzCN4kSHgQEt
	 t+nCjSOcq3Xw185uh24N6EBdNLz2zIM8SDA8XvLkmeMZUC04fUpdhY8eSB9PjBzE4qw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZkdIoUzZ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A78996072EC2;
	Mon,  2 Nov 2026 15:32:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZkdIoUzZ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B5BD51F00A16;
	Mon,  2 Nov 2026 15:32:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793633573;
	bh=xwE+gN56hE51AorwZpbrVa8dzdnGmSpFpcgiuf3dvqw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ZkdIoUzZRdQstvJJGwaGXuz34UXdVd9KnN9ZJc3nP27AG3GLe8vMenko9Tiu+l4yV
	 4/eK0kdxB9N+Iz0Yx6dr+YotVggYI8nlCZEvmDr9lO/WoWjHo18zAakL9FX2BCmjDx
	 mJmMK2I8BK4i3qt963tlhaBmXuV/d6nxajg5m4xkht+xWIGtqgCPx/5sAyRymy14bP
	 4KLL09VHA9etPNuG4Bi+X52PjSZJxfUN0TyZqVAjhyTJxpADAlMTaef79a51Inhh1f
	 KQvYYLJ04QvmjznL9iSrSnxSYVcd8eF+n1EAEbkOWhWDHBKQ0TlFa4oEqY4+mpy2bp
	 OjhbKNeE0RTjQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:20 +0100
Subject: [PATCH RFC 06/11] SUNRPC: let procfs own the seq_file of the cache
 content file
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
Message-Id: <20261102-work-procfs-net-v1-6-982104a4f592@kernel.org>
References: <20261102-work-procfs-net-v1-0-982104a4f592@kernel.org>
In-Reply-To: <20261102-work-procfs-net-v1-0-982104a4f592@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1589; i=brauner@kernel.org;
 h=from:subject:message-id; bh=8vuLt15HI84MkjiR5ofNiQbYBWJycXJMPW98KiaZ28g=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG6cvyvvXN+5FNeT984x/JZU3WJc97VU21Z5x4ejN
 wVit9i4dJSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEzEIo6R4b/ei60fuk86FUUz
 vt99O+xLZ+VMycIfR1z13il2v/5unsbwVz5pQbOt4GZXF4e/d+SV1t2v/7fDb/rx0gLLFQ95fd/
 GcwAA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Declare the seq_operations and let procfs open and free the seq_file of
/proc/net/rpc/<cache>/content. ->proc_open() and ->proc_release() only
take and drop the module reference and set up ->private now. The
rpc_pipefs file is unchanged. Reading the procfs file then no longer
holds up its removal when the network namespace goes away.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 net/sunrpc/cache.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 1ceaea7e01b9..007521e8a57f 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1606,24 +1606,28 @@ static const struct proc_ops cache_channel_proc_ops = {
 	.proc_release	= cache_release_procfs,
 };
 
+/* procfs opens the seq_file */
 static int content_open_procfs(struct inode *inode, struct file *filp)
 {
 	struct cache_detail *cd = pde_data(inode);
 
-	return content_open(inode, filp, cd);
+	if (!cd || !try_module_get(cd->owner))
+		return -EACCES;
+	((struct seq_file *)filp->private_data)->private = cd;
+	return 0;
 }
 
 static int content_release_procfs(struct inode *inode, struct file *filp)
 {
 	struct cache_detail *cd = pde_data(inode);
 
-	return content_release(inode, filp, cd);
+	module_put(cd->owner);
+	return 0;
 }
 
 static const struct proc_ops content_proc_ops = {
+	.proc_seq_ops	= &cache_content_op,
 	.proc_open	= content_open_procfs,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
 	.proc_release	= content_release_procfs,
 };
 

-- 
2.53.0

