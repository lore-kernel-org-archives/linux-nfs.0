Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793633258;
	b=2ikhWgWj3a3ofi8Gm580Lc0GLqmooslI+osd9+3+qJeac85BM7szs5dVjBWL/8YpMTJm
	 SM5F/9SLkRuLSmzfbQmTdpX+ZRdwZPslhYM36GZzr0hDegqqQzLeKUcGzUdOLuaiuW+JF
	 E2t7cB+DXkQ3GUIMcb+lXQoCCH6CSwZwKql67nMWFGEkEeWsI5n2FhKyMk8RPbF7/qRO0
	 fypy8Ph5dt2UCORAVJ4GD5x+5cCNbRnZPeRTOZdsSr+Y1ua/kFHiC1RrLpFuszpqJVbsl
	 Vuijx108H0sFZGuAc1fU/8b94x9teYaEtT4GCQstyZN4gd8D+qB1f35OSV2FiU+tbDw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793633258;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=fVQTaeb1oaPXPKdbaoAayfOvKvQGNQ+1mlgyJVhAprY=;
	b=eJhZeZ68I3/8qZEXPXKXaxNSJEhKnEL0G0QHYGOrNFixyqvEUDR+akOi0DHgUOUa+C0C
	 d+x7ql3pndqGkAs+fWq5MAVODYvUutvL9TkscJUIE9imXSo0FYHUyzKmG3pzt/XzCpRZl
	 kW8hVzie8k3SeBmJ3YvpwIrByQq+w6IFS51CqiLjpC1pN8RlbAzXeaY/RizLF9OWhOlBi
	 s5OgCcksTxcKptYGYLnR1uScvjUQ8i1XucoZPsQzQ1+Hw0WMgCS7rY3w1b4R4dX9zwdyP
	 vrbRKLIddB+VzPQW+say0cwmzULYe8oF6wiuRZrPoCvMNZsnilYTmt1dIciB9+tDZ/Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Fbfunu5l;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 11150606AB8F;
	Mon,  2 Nov 2026 15:27:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Fbfunu5l
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 970571F00A18;
	Mon,  2 Nov 2026 15:27:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793633257;
	bh=fVQTaeb1oaPXPKdbaoAayfOvKvQGNQ+1mlgyJVhAprY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Fbfunu5lnfSJErLeOUCsE8vip2ARFZN807qf74412UenKoepZwcVGYe+g3+TBcESM
	 D1QwhFq6yCQFcA4O6bdiGxqgbUre+0RZ1J5auCotD4DKJJgxUPjFUcOalq5vmaPOF7
	 r6K6N8o4y3fh9RsWfWA0H81XfT5u78die7geNeFBQSxWRGm/v2Zmi9RgIIPxgQXR+A
	 0P2Coe1ocgqK6nbiBmEOjXtV6u2GvDvXXJrRu43HenABBgQi8+GrUdDlctWVDUHIoA
	 N+wBbyncTDkFadiWb6329xq83Ar8JXpLh9NYV7HpnGSZ+ZP8CPs2xOKlBHbLeO+TYL
	 LjxldllqCyblg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:32 +0100
Subject: [PATCH RFC 22/27] ipc: let procfs own the seq_file of the sysvipc
 files
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
Message-Id: <20261102-work-procfs-fs-v1-22-d09a996317b3@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1686; i=brauner@kernel.org;
 h=from:subject:message-id; bh=X6b7xxVI9/mXpsMyNcc27ZCzqI3OxIvLBKPC0zeU++I=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG6spcaqk/ik+Gn7rm/T2r/bxt6IFtUv/OG2907HJ
 IYrlm67OkpZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACaisIPhr4w9w7Ls1452xknl
 lgnt1kyG/EnKSVzp91b3nmSOzwjxZ/hfOCP6r1dRmdzzU13p7xgu/7jmd2iNKp+nYxzP4e9P69R
 5AA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Declare the seq_operations and the size of the iterator and let procfs
open and free the seq_file of /proc/sysvipc/*. ->proc_open() only fills
in the iterator now and ->proc_release() drops the references it holds.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 ipc/util.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/ipc/util.c b/ipc/util.c
index 1737d776bc08..8ec3bc328657 100644
--- a/ipc/util.c
+++ b/ipc/util.c
@@ -894,13 +894,11 @@ static const struct seq_operations sysvipc_proc_seqops = {
 	.show  = sysvipc_proc_show,
 };
 
+/* procfs opened the seq_file and allocated @iter */
 static int sysvipc_proc_open(struct inode *inode, struct file *file)
 {
-	struct ipc_proc_iter *iter;
-
-	iter = __seq_open_private(file, &sysvipc_proc_seqops, sizeof(*iter));
-	if (!iter)
-		return -ENOMEM;
+	struct seq_file *m = file->private_data;
+	struct ipc_proc_iter *iter = m->private;
 
 	iter->iface = pde_data(inode);
 	iter->ns    = get_ipc_ns(current->nsproxy->ipc_ns);
@@ -915,14 +913,14 @@ static int sysvipc_proc_release(struct inode *inode, struct file *file)
 	struct ipc_proc_iter *iter = seq->private;
 	put_ipc_ns(iter->ns);
 	put_pid_ns(iter->pid_ns);
-	return seq_release_private(inode, file);
+	return 0;
 }
 
 static const struct proc_ops sysvipc_proc_ops = {
 	.proc_flags	= PROC_ENTRY_PERMANENT,
+	.proc_seq_ops	= &sysvipc_proc_seqops,
+	.proc_state_size = sizeof(struct ipc_proc_iter),
 	.proc_open	= sysvipc_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
 	.proc_release	= sysvipc_proc_release,
 };
 #endif /* CONFIG_PROC_FS */

-- 
2.53.0

