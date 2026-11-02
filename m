Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793632893;
	b=zXsPfM7IoqpH7fm/hajJ/sp8/ifslP3GeXW7w/2IPhw2ojneaYKM4n8ggCD4AZm/5aT1
	 kSaWHkG5b8w0DIlCgHN9WqfIaTF/w3j9qIkJq/2XwPYLtYewyhBMPCEtIBKeiagf7Vio4
	 pzDOZ8tKg7K+NPVPPgKxthIXrcYmEy6VjGyoGXh1hpmdQ5cu2nS5UllysRjlhSbLULozv
	 dxppk4jGW21xgDkI2+ZVdU23jVBafmHUE2dgNWJaSveM57ohRlXwg/1M7JAkOHOGM4i4q
	 eEFqTwSuar0qmuq/xzglTAu0HoeQky6tHrKMoxMDzzpwesRp0UPXqwxzVu+ZjQm+O0Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793632893;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=u/RXCBD8nlX7BDzbpngWHwWfgPDQj7BVrPXrBF7wCv8=;
	b=VDz0panqkCE8yE/pw6CNae8fubK83sUD6SAUzgCePjBbps/8rPQF2bIdDGX1OFEbc2mf
	 RnykIQsNClto1onNDyAO3tXd12lRoT1DVb7MNOeIk2xv14Y80eW9QQjZnbqjA+pFmswcd
	 XttOMrsf7wWXQzwDuIP+HqNhpYlsc8GesThfp5fpjyxaRDVvqNVY8foRVQvsKcxTH7f3O
	 31Z4yZ6+C/l+M0kXu4pVqKZzW56waCjAo9ogbWneq3CHU1QHAcWEj45K2QitKFHepRXJK
	 v2PzAP9WA3e2TCpYkTBfHpjt5w3G4lrbtROm6tdfZMCbTUFuJIqiCAJ2hfdSXkwtEFg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lzeuR62X;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0BF026080484;
	Mon,  2 Nov 2026 15:21:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lzeuR62X
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E9FC41F00A16;
	Mon,  2 Nov 2026 15:21:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793632892;
	bh=u/RXCBD8nlX7BDzbpngWHwWfgPDQj7BVrPXrBF7wCv8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=lzeuR62XFqOGUep6G0u/OgAm/OWRPnnvn8erL4ZU4coYsOJSODUSp+a+2jQzM89Na
	 wls04y7KzCTFwf5dsKwoGQq4HsQJB+8Q/tyIUmNqi21phOIu62KpYImTlB0ls6aGae
	 miRfVbxr3JZPL8lWk8CynKdRTAwmaRBTeg+t7O77J1JsURjyW/dH2I6mYOgaUrqxwj
	 7KTrFfx3AkzJndWmhJ/H+my8YK+kelSQ4n+wOAuAD5nl7vHyDdtVgll57DDfY53FmE
	 lZ2Bqq8ccnEcF5eVt6EqwlmszCQGg+ZSpjDAYPYr+Ujd6ANt6wT/4OLvqxEhsJ83lT
	 c5mbm06d3Q7qw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:16 +0100
Subject: [PATCH RFC 06/27] nfsd: let procfs own the seq_file of
 /proc/fs/nfs/exports
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
Message-Id: <20261102-work-procfs-fs-v1-6-d09a996317b3@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1348; i=brauner@kernel.org;
 h=from:subject:message-id; bh=Og6i2j2RItYkKcPNuUOPBq0fveLG9Ax2TG7f5E6VSxk=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG7kVLY5MLm6OZ2xjUVJp9EoIqQs8Har0dvS4Du/G
 zkXh5h3lLIwiHExyIopsji0m4TLLeep2GyUqQEzh5UJZAgDF6cATCTOhZFh8mS2HN0Vqp439x5e
 2xeUd91V5e/Pzuqia7+Lj7wzdlPPYWTYZ8Q7MynkzsRjgb7VR/ifa84RfBwlO7dAjOFb++Stxc7
 8AA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Declare the seq_operations and let procfs open and free the seq_file.
->proc_open() and ->proc_release() only set up ->private and take and
drop the reference to the network namespace now. Reading the file then
no longer holds up its removal.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/nfsd/nfsctl.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index f8ce3c0fb077..5b2782f9dbbd 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1407,16 +1407,23 @@ MODULE_ALIAS_FS("nfsd");
 
 #ifdef CONFIG_PROC_FS
 
+/* procfs opens the seq_file */
 static int exports_proc_open(struct inode *inode, struct file *file)
 {
-	return exports_net_open(current->nsproxy->net_ns, file);
+	exports_net_init(current->nsproxy->net_ns, file->private_data);
+	return 0;
+}
+
+static int exports_proc_release(struct inode *inode, struct file *file)
+{
+	exports_net_put(file->private_data);
+	return 0;
 }
 
 static const struct proc_ops exports_proc_ops = {
+	.proc_seq_ops	= &nfs_exports_op,
 	.proc_open	= exports_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= exports_release,
+	.proc_release	= exports_proc_release,
 };
 
 static int create_proc_exports_entry(void)

-- 
2.53.0

