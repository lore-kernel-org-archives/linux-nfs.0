Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793629560;
	b=tu1fOOY/J3D/RTAd6GM9ykq6EQNYW53TJMlZ0b2NsCAi6alBmat7+j6V6P2QT8jr3IAL
	 wjYgoXJI2qj5KRhmbkG/O0Anc/jCq2RJcggn0ZZUB67LF8vw70GJ0X4YdZo5KCTMMk6GW
	 3ME/p80Jndz4wOl6Zu6yplR8y8WC6T51hMd1LaqUK8QCQ1p5CHXRw5pwv733Qm8UpILVF
	 XO0PfsEzoVkBCIEy8qc1InvNW9miBRka9H/9O8PUSXfMpGBBgcGEhaClQGv/ST1V9hLbi
	 ERn1Nj6nTtqMKIbFtBqIw4eQVjqYEqHdaWkt/uAGjBJHvcGJqe5iGfj2c3nM/3Pl8JA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793629560;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=qYcECRdDX1PrLgMJOdiUzXJ2kaKILzuHrLaM8GQSRjg=;
	b=kqLRl/lRHBVb97ikAjYnLJp2OsUQ8uN8XXXP/TLES5pbIMmBYZC/4qVTKHPTAC3G68oX
	 jppp/u8vuQNmMmLc4IYuMTF2YmW2u0aJ/3q4V0rryHub04+wIL0eeHHzeCR0LRoQzGeq5
	 lllWwj2jjm3tdRHw/7CBxX9ENlY1sO0lY1fu1QXuJ+NCgTmIJ30HwsCAJnTqvFcmQGj24
	 pFVL6VNFdqKq1vNPjt8YTswfDxxOxko9wpsX/s2jVueEjYWOM5Um6ez+nZjN6Ux+J61wC
	 HnU1aFrq5jnnINNB3alh3rkzy1X2r+jNKNYWatAG/b2kIVqhbK6/FqXgKvHEL+gsUsw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=S9KQjE5w;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 49F72606B931;
	Mon,  2 Nov 2026 14:26:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=S9KQjE5w
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 139161F00A17;
	Mon,  2 Nov 2026 14:25:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793629560;
	bh=qYcECRdDX1PrLgMJOdiUzXJ2kaKILzuHrLaM8GQSRjg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=S9KQjE5wRZaW8pMK48TuAEmOLD748GqwlgZgKrfSco97/731a7MDcvtdowW3T/B3m
	 NvPqfIKQwOF2sxhuKNeKw2glbD9GcUTLKErI1N8MeSY2feI0MfU6hQ0PDqhrSxlAax
	 ysx6+msJ3hHzjq6HRREY3YeW3DHo+bXrboL45uA1tUVTth9lHX0m7ISaar/jKS0zMf
	 IYZHmi5qTiRrg7GVbV4rddIoHh/fUlFGqHzxDtnW0GBToUrP55eD+22JF1NKxgOElA
	 EhFTmchNaS1rz8TR2eJwc5sdtCFgjqMQFTOhS+e8PSQ5scuItmZ72v036nNEZPi/4u
	 grk/S5BPt88Hg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:21:33 +0100
Subject: [PATCH RFC 18/38] proc: don't WARN about a name that is already
 registered
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
Message-Id: <20261102-work-procfs-bugfixes-v1-18-59422ed3e465@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2415; i=brauner@kernel.org;
 h=from:subject:message-id; bh=aKtCMuJhN5pC0AyNIxMzKE8+AJEG5eL6v+vagw86wsU=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9mJMtrTidr2u/hEYo58Xov6ysMy+tyPQIcGfZ/8nw1
 F7R28+edZSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEyE3YeR4YrY7evvwlZMuvjO
 T2W501ZR+/rFjmErd1jlrvaS/Heoz5nhn/Z+UxH3og0pqhNqZy+2Y5tgn39oqvmlQwLG8Uf9Zic
 oMgAA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

proc_register() WARNs when the directory already has an entry of the
same name and fails the registration. Callers that pick their names
themselves should never get there but some take names from userspace.
pktgen creates a file for each device a writer of "add_device" adds,
named after the device. A device can have any name, including "pgctrl"
or "kpktgend_0", the names of pktgen's own files:

  ip link set lo name pgctrl
  ip link set pgctrl up
  echo "add_device pgctrl" > /proc/net/pktgen/kpktgend_0

  proc_dir_entry 'pktgen/pgctrl' already registered
  WARNING: fs/proc/generic.c:404 at proc_register+0x555/0x8b0, CPU#0: bash/241
  Call Trace:
   proc_create_data+0x9f/0xf0
   pktgen_thread_write+0xd9b/0x1780
   proc_reg_write+0x1c2/0x3c0
   vfs_write+0x1cd/0xfa0

The files of a network namespace belong to the root of its user
namespace and none of this requires a capability. So once pktgen is
loaded an unprivileged user can taint the kernel, or crash it with
panic_on_warn, from namespaces of its own. pktgen itself copes with
the failed registration just fine.

So go back to what proc_register() did before commit 6c2f91e077f1
("proc: use WARN() rather than printk+backtrace") and what
sysfs_warn_dup() does for sysfs: report the name with pr_warn() and
dump the stack. While at it, do that after dropping proc_subdir_lock
instead of printing a backtrace while holding the lock that every
lookup and readdir in procfs needs.

Reported-by: Chris Mason <mason@kernel.org>
Fixes: 6c2f91e077f1 ("proc: use WARN() rather than printk+backtrace")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/generic.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index c560c96a64eb..ef804cd3ec45 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -401,9 +401,10 @@ struct proc_dir_entry *proc_register(struct proc_dir_entry *dir,
 	write_lock(&proc_subdir_lock);
 	dp->parent = dir;
 	if (pde_subdir_insert(dir, dp) == false) {
-		WARN(1, "proc_dir_entry '%s/%s' already registered\n",
-		     dir->name, dp->name);
 		write_unlock(&proc_subdir_lock);
+		pr_warn("proc_dir_entry '%s/%s' already registered\n",
+			dir->name, dp->name);
+		dump_stack();
 		goto out_free_inum;
 	}
 	write_unlock(&proc_subdir_lock);

-- 
2.53.0

