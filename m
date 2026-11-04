Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793813443;
	b=Th5xZuGLLeX64a9hKMF994ajblvrQV7PgRqrGrcn52fYGbB64Fgg8ItJLULZHY0Nptzl
	 ibyM6OgDzbiZB1YAHwh2NaP/RQv7nJa0Md4eGnrviEsHDMQjNyvjJFY2EDbdyoNzkDLIQ
	 UxiLiLkziZr671NvtB/fO9nvRufPSkvC9n9KRj8mihQ1GasxQyiZ6nCaq/ppZmXGuCcyG
	 Dc+ts+ll0mRcBB2r/zj/Qou4AKrwBnnzQzH8vjO5VIhBBfge+nngcZnMw8onVWwovWsg8
	 4FvtSwZmQk5cO/0NTPMNAeD0prBi58wgK36aqVBDfE7gGnBT8XXg6ePqECxYHJIc2lA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793813443;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=axjAzDMxe/T5Kt/VR9558Sdu9PB/HLdF+q053OKTtnM=;
	b=tkx9AHqYmwHt4gxAunJ6+y3j3zBUZa+tWlxAIryqOoaxkV5kt8f8KXplONjhnkp/pDZx
	 oMAtpd0NHRdnxUDdZYrceCKThKhGlgdEq6tIarnc3c1axl9BTHOe+rBzHWxIBdCedtlGi
	 Soun+sMaCQ7QrtF1ykQUY72y1M5XOoSPsxkSUOJMX3IavWzEz1JaeaEj5GIU8Dnl/Hsmx
	 ycaXEQPtcaNPUopzv9jp4TiWt5mgz65AEpE03o2DKGXHaYp/dDkQ1mG5G1mLdpzPl7d5Y
	 N0DQjajdn1xBmXT9DKCctgSjQHunXKrFv71oiw+wB+uxUYpgkKHPXuTRc87VMaVhY/w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BpyBwaL0;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 78C69608363D;
	Wed,  4 Nov 2026 17:30:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BpyBwaL0
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 318C11F0093A;
	Wed,  4 Nov 2026 17:30:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793813443;
	bh=axjAzDMxe/T5Kt/VR9558Sdu9PB/HLdF+q053OKTtnM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=BpyBwaL0/aYVXoHwq05IXwkJfbiN+sH/NMlrIciQjG65t4BqcyIJFg2nSk8XDCCkV
	 c7rAC5Gwt0eJ+/2lGcpbp0ALBTDjeOzJXNQqmnuVDle4iduB5dvN2rzhDckY+qtIzb
	 gs1CNuM6mGLr4omD5X5lb2yIJHjoEFVFY17i90YDIqHEiBZHsPoN/pZZJkVTJ0KPFp
	 EUeGwANAMrg4AicMXKhoLnEodEFkU0cutq7m4urrRAjYhUQUJ5q8o2+x5TkfWHjCPD
	 i91uDDI+3s3/ZTdD9a7P2TXIzuGYqpzF7L202zVk0SuzYL1uXQEo7tJ52MN1ssXopq
	 kuzwiBlPYX93w==
From: Christian Brauner <brauner@kernel.org>
Date: Wed, 04 Nov 2026 18:27:26 +0100
Subject: [PATCH v2 09/51] profiling: report it when /proc/profile can't be
 created
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
Message-Id: <20261104-work-procfs-bugfixes-v2-9-bbf7d5546809@kernel.org>
References: <20261104-work-procfs-bugfixes-v2-0-bbf7d5546809@kernel.org>
In-Reply-To: <20261104-work-procfs-bugfixes-v2-0-bbf7d5546809@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1225; i=brauner@kernel.org;
 h=from:subject:message-id; bh=tYIXM5EjsYRFpz3d9CdZ23LhMvzI2JA5U8qSrxldqzY=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9zmb5c+HYnPYns6fufFrw5b7Y3/kPP5ytKnep0a7Jn
 RU85ZS3VkcpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBEDoUzMjw1q1TdWGx2OGny
 nwfxD9yf9a1xbZhUXGz4leXXTAWLvycZ/tmE5T+0eFcqb8S9dXuWRJTqOn+e0/UWz2+d/yn/trX
 0PxsA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

create_proc_profile() returns 0 whether proc_create() worked or not, so
a write to /sys/kernel/profiling that turned profiling on but didn't
get the file reports success and there is no file to read the profile
from. Return -ENOMEM like the other failures of that write do.

Fixes: 22b8ce94708f ("profiling: dynamically enable readprofile at runtime")
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 kernel/profile.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/kernel/profile.c b/kernel/profile.c
index e7defa90a34c..820d5ec909d4 100644
--- a/kernel/profile.c
+++ b/kernel/profile.c
@@ -216,15 +216,15 @@ static const struct proc_ops profile_proc_ops = {
 int __ref create_proc_profile(void)
 {
 	struct proc_dir_entry *entry;
-	int err = 0;
 
 	if (!prof_on)
 		return 0;
 	entry = proc_create("profile", S_IWUSR | S_IRUGO,
 			    NULL, &profile_proc_ops);
-	if (entry)
-		proc_set_size(entry, (1 + prof_len) * sizeof(atomic_t));
-	return err;
+	if (!entry)
+		return -ENOMEM;
+	proc_set_size(entry, (1 + prof_len) * sizeof(atomic_t));
+	return 0;
 }
 subsys_initcall(create_proc_profile);
 #endif /* CONFIG_PROC_FS */

-- 
2.53.0

