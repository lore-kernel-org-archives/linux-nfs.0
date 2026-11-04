Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793822333;
	b=pnvJIgiy6y6wXnoyZEiNkguivB9Ay4wX2G1s/3yzYsOtJWTuTl6S/RXCntYutdhtbTiZ
	 p3drBi8jsEcYHBAbeSQv31eiAjzue+kRH1B+chIeBNB0ov5tDQitqCe4mo9iiz1w6BjaI
	 sgLt3pqhhOYsM8/tf9qmXN7lLgpgY2ktzA1qW1dNKHgl3T+w7qD2RbL4eOMjOlFHBTN73
	 bOhKfvKkNVhGt5qfaVDhNTMPYk4qNeONZGN27tiAwY4L1WxdoUSl/4ed60R6eUkoNT3ew
	 D9dT4i5yb4zWb8aygKyEIfcNZksLIgbaNVbBADPciqWokjSQLrrEne7mz8TEEycljfw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793822333;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=ffDqq2EmH3dLLxjgj5UCr7XG2Z9kHARzT7WYJIH1M8I=;
	b=DXz6lziXTfb1L0ZUGYeI9CsQ7W7CeDVZGVeB8DViqXAH8sev2untp+DAN3/yyv8MCzNo
	 ZwEKblXAQEUHZ6MblcMKJGuVw1oBV0VLChN86xnwRqDSQqYQgTNpJJigdPQGx5FaTBba0
	 JQpSHO7IcfjyiXmQkgzr8g3wpRT0O8v6XjUmWwFTjZwpOh6BpuMCX49EsxbaHq65swL8h
	 opgF9r5WEK/07mZ1b2nufTEUjD4P4DHh5cMfiGPsyMbHFkOOFQkKAZmLL70Xu2siQcNRn
	 /vLoPBuauahlZLfJnxCTP7Z7/jr2toO1NhyO3G4hZEnsFvQwMjtMC0/eJoZERZIUJ9w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="Va7zsSD/";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE7D7606F297;
	Wed,  4 Nov 2026 19:58:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Va7zsSD/
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 475061F000C1;
	Wed,  4 Nov 2026 19:58:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793822332;
	bh=ffDqq2EmH3dLLxjgj5UCr7XG2Z9kHARzT7WYJIH1M8I=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Va7zsSD/2UsqzeDK17UtGbxk8tZ8VFuDtrgV28CQXE3r+pUU3KAQ9HdqwNtJCrgiV
	 ER/DimX74CNEXlu3IVPIXGbqc5CE12lAQ7b50a7KHKJ/AN/yvURbL8BJKzY3tevFtZ
	 4hUGceV6oWXok2hp5oPMRcHlxbZdVLWyfg0KIahRV4dCHE2oE+Til1RUebK1MkIrRI
	 /sZV1JWTnpcc7uIQut/dpI2nvKSohpgIa1uCWZRw2Ljq27C9lceWDK43vqJZV6NQiW
	 fweTl9sYyzuDv6zPxbywF1J1VTwPH00pLECF3z2ro2vkAz/tU/vmL4m25vP2A1j8av
	 it6DkfL/lb1/A==
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
Subject: [PATCH RESEND v2 04/13] netfilter: xt_recent: let procfs own the seq_file
Date: Wed,  4 Nov 2026 20:58:38 +0100
Message-ID: <20261104-work-procfs-net-v2-4-221e2437fed1@kernel.org>
In-Reply-To: <20261104-work-procfs-net-v2-0-221e2437fed1@kernel.org>
References: <20261104-work-procfs-net-v2-0-221e2437fed1@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1502; i=brauner@kernel.org; h=from:subject:message-id; bh=BFI4awwUWJFzxPnNllIUF4mTxSJuUKU00IOFrC3aQoI=; b=kA0DAAoWkcYbwGV43KIByyZiAGrrjiej6rmB1rbnTFWCev28j3SQbNVWhEo9oG7+1WnoRYXHo Ih1BAAWCgAdFiEEQIc0Vx6nDHizMmkokcYbwGV43KIFAmrrjicACgkQkcYbwGV43KL/sgEAvxrm KME07jPCmATQhxOPX+CkeymKJwNpyy2JVbz+TS4A/1C5qF1LfL94UG1aRkd9j3hJLBQu75wvUei vrFWvAtMP
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Declare the seq_operations and the size of the iterator state and let
procfs open and free the seq_file. ->proc_open() only fills in the table
now. Reading /proc/net/xt_recent/<table> then no longer holds up the
removal of the table.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 net/netfilter/xt_recent.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 55f1f2d89952..a43fff5308da 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -546,11 +546,7 @@ static const struct seq_operations recent_seq_ops = {
 
 static int recent_seq_open(struct inode *inode, struct file *file)
 {
-	struct recent_iter_state *st;
-
-	st = __seq_open_private(file, &recent_seq_ops, sizeof(*st));
-	if (st == NULL)
-		return -ENOMEM;
+	struct recent_iter_state *st = ((struct seq_file *)file->private_data)->private;
 
 	st->table    = pde_data(inode);
 	return 0;
@@ -626,11 +622,10 @@ recent_mt_proc_write(struct file *file, const char __user *input,
 }
 
 static const struct proc_ops recent_mt_proc_ops = {
+	.proc_seq_ops	= &recent_seq_ops,
+	.proc_state_size = sizeof(struct recent_iter_state),
 	.proc_open	= recent_seq_open,
-	.proc_read	= seq_read,
 	.proc_write	= recent_mt_proc_write,
-	.proc_release	= seq_release_private,
-	.proc_lseek	= seq_lseek,
 };
 
 static int __net_init recent_proc_net_init(struct net *net)

-- 
2.53.0

