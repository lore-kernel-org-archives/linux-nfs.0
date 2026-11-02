Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793629614;
	b=RWBsxOcNzzjtEKjw0ghkETiVVGqvHtQZ3JtrGi0oeVxnfgr0GI1UBCzDPMwyTtqIGomS
	 xOpLSdS9CUcBawRY2iAOTB0zj3hQ6AVWaKATm4Fpge6FHTaNwadOtbL7/YdfLy/sAfpiJ
	 MvY7POMEA2Bd7Qflt0rqEuyrWTfMmh4Duz6+ttRrkdktTrMMpyYx6OvhhzJFZm+cY9HVl
	 i62tR0lUnqHPzczgQA4vg1moBaUnzIl0LVZDKPzzLh1zyDUk0h8Jb6wi9+Lt2l5+jre9L
	 2HmBzaDPrKkxBW/o62Neso0bFgbOWh4Ay6HLYCzCjMF3fZ0gTUa50YdkoAZugcWTWgQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793629614;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=9aVyOXB46BuISsBUhN38Gy53ksJP5B0VIb3fhsBGGRA=;
	b=H9NKRHswJm8gwzoy8oZz9tMtXvv3CshCP5oc8bGDc3IXWDJm35SIwqxIQpXFnU8unmz+
	 6rRyHMPSoYMnY4PCVtG+3/ZHLqWa/Yjhv4z+FcuMXLKfEONgX/3OuZys/FfaQXjTBVnaQ
	 t3PBkAEK9c6CtbohJp4+eQz8Y7Qg3k1FsOR0YJqUQ9O2foBdrN5E4M7pPt88gJUAWLv9i
	 SqgvlWA4HHQm8kW7zb3deIDFw2XkOoBkr2Yq8QI68I33zxKyxU2tQPcK/Btbb42XALWrn
	 Wc2kv1NMUFaIqq5mRFsMlUiNeco3gyRVoO6QkxUXKRtkfXlTds1kZUA3iYkJTKBZsuw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kX8+D9NV;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7AD19606E010;
	Mon,  2 Nov 2026 14:26:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kX8+D9NV
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B7C131F00A16;
	Mon,  2 Nov 2026 14:26:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793629614;
	bh=9aVyOXB46BuISsBUhN38Gy53ksJP5B0VIb3fhsBGGRA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kX8+D9NVfqUSc8gdnE5o7Q3Oq/uGaLH3xjedKLYih9wdsnnjGcjcRNyhrZaxgnxxx
	 6mJPp78Dyw5jmgqKUNdlhpYQ/2Qf2LxAvvtdrBxj50iBxD11Dxk7n+iHGOSy2yxUdF
	 FBfa3aXoeS07kk/77nHtewMxpER9ltz8Mj/fE7xHULINbv3mdMS1KJ84n3AWWtBdk/
	 bya8kywSYeK0JZbU+HmtQD21/aGPUSusYBz+eyTQ4qL+4aq772xEp6pJWjXfU6i3HK
	 oQcjHkwy6Nkk9N/kAx/z/L8sk7X6Lk8bFh4mVxNn8C/PKjrqbaPSzJA45GkFv8YnRt
	 zK+G0svabDX1Q==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:21:37 +0100
Subject: [PATCH RFC 22/38] proc: warn about entries left in /proc/net of a
 dying namespace
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
Message-Id: <20261102-work-procfs-bugfixes-v1-22-59422ed3e465@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1461; i=brauner@kernel.org;
 h=from:subject:message-id; bh=VO4WYvqdbdInF0wrRh04dkmiJiaJmigcn5WsH5ed6c4=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9mJO9wixVJYzvlj178KfJTowVe+L0g7o9JBeHSb4ui
 OJO1MvqKGVhEONikBVTZHFoNwmXW85TsdkoUwNmDisTyBAGLk4BmMiaf4wMS+2vzm0vtpws3xjx
 Ms/u6ofZgus/vnESzThVVPxXfJGuFSPDjsrTjR0fyxMDjG7OlZnMcnPhiY11+Y35btcVvI932r1
 jBQA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

proc_net_ns_exit() runs after all the other pernet exits and frees
net->proc_net right after removing "stat" from it. An entry that some
pernet exit forgot to remove is left with a freed ->parent, and so
PDE_NET() hands seq_open_net() and single_open_net() a freed struct net
when the entry is opened through a file descriptor that someone kept.

There is no such entry in the tree that we know of, but nothing would
tell us about one either. So warn about it like remove_proc_entry()
does for a directory that isn't empty.

Reported-by: Chris Mason <mason@kernel.org>
Fixes: e9720acd728a ("[NET]: Make /proc/net a symlink on /proc/self/net (v3)")
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/proc_net.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index dbcf87a257e1..df5484813d5d 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -410,7 +410,13 @@ static __net_init int proc_net_ns_init(struct net *net)
 
 static __net_exit void proc_net_ns_exit(struct net *net)
 {
+	struct proc_dir_entry *left;
+
 	remove_proc_entry("stat", net->proc_net);
+	/* Whatever is left still points at net->proc_net and so at net. */
+	left = rb_entry_safe(rb_first(&net->proc_net->subdir),
+			     struct proc_dir_entry, subdir_node);
+	WARN(left, "/proc/net: leaking at least '%s'\n", left->name);
 	pde_free(net->proc_net);
 }
 

-- 
2.53.0

