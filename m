Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821881;
	b=e3cKa77ZjtUPHX4HLGp3OoWnUnt/VMA2IehUWAskJ7xYSef3tU1VogQ9kZX7Qg45peq0
	 nN9GPM/l/NkUknsWG1a0pdkoSIdf/iB3P6grM6mnqzayr6c1GS8+MMArHbcK49hV2cTKs
	 XxROlWy2koBm1Z5n7vgvdR4SCk/Wll9zK6aV0L9eLrOC8HXk59QfAKpNba8laXEifMwsA
	 GAdYNiPhzEAjtIU9FB0W5ojPi/SvRf/r8EusZ6oI1kdy13xWAS1UQR3GTGqo6hb2NMmZi
	 ruRaLFWbP60F1BKe4DFITUXj1r0KwBF6gdZcmdNx/1mu8J+4VzNuhgHc1LRJ7njZnsQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821881;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=LP8R0bNSKS2QH/Zql1k1p4KE760gSx77oAIYdTk5FHQ=;
	b=O8ojp4G3ZTqQtCnQ9vqxf1BpdjMlCA/CUxVHfNufrej4eulCXTH6FUoWlg7dNnbSN5K7
	 OYVNlkLzmFqm07jPjzc+faGUqAQvzU6B36Ls3N9O2ldFxo6TqNQr8h3n2YFJEzjD4ntTa
	 eCsW3dUcCWzILMZtbaoayovXmIweOcck+eJ+nh2p8TqwPj+9mUhprm4gEL7iH203JrsHl
	 S2B6vc3PEVIT0WIxEZCLOSL1t7xbJwR+71Eqzn8pX+lKadi85c7dBcYv80t1RshBmYcCx
	 XBQV6H87G5/zAUO72n5XaGuDI8JiX95nvNlTl722tv1SnJeO6eH3VE+vUiMj230Qlkw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RsXLh3XH;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E86D3606AC3D;
	Wed,  4 Nov 2026 19:51:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RsXLh3XH
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6873B1F000C1;
	Wed,  4 Nov 2026 19:51:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821880;
	bh=LP8R0bNSKS2QH/Zql1k1p4KE760gSx77oAIYdTk5FHQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=RsXLh3XHwh9i9KYLzGYCXUR/3jz6hvJBiKTUXoJMpIyHBIQckhaIML2AcsaatHJA1
	 0eBgijXzBWphawzWAAAliBSKwy94Zq0H8fcdbx7zd77a8zoJ0Ue7FRHLvIZ7LfaCRL
	 NWsF0xR2vHzqH47EGJ+b1zhQAPz56CBGLrP9V51eK/aUOfQX+ePGLsZp0VZGcq3umB
	 NDozx0Pud3lqomDaEsA6NBp0dWh/oMo1BEzvyC9LXCvrcoisYiWT1saIA5w7Ryz3SA
	 YyQib6eqTR5sEMMLmZee9CeR7k9yWAYrkLQ/ZLwHgmz6BrgXZZ6ltNiDOnrSr0ulvD
	 XM4slagBXfM8w==
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
Subject: [PATCH RESEND v2 06/30] nfsd: let procfs own the seq_file of /proc/fs/nfs/exports
Date: Wed,  4 Nov 2026 20:51:06 +0100
Message-ID: <20261104-work-procfs-fs-v2-6-319e0f9a8aae@kernel.org>
In-Reply-To: <20261104-work-procfs-fs-v2-0-319e0f9a8aae@kernel.org>
References: <20261104-work-procfs-fs-v2-0-319e0f9a8aae@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1388; i=brauner@kernel.org; h=from:subject:message-id; bh=zWLMsIr05BMF/tXliLgjdHfvlEWh2osbn3SGLQ8SJYE=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97jGs4JaPtH3mH5ykZTabedr3t9eLXxuUWtVOVPA6f zVLaV15RykLgxgXg6yYIotDu0m43HKeis1GmRowc1iZQIYwcHEKwEQOxTEy7LkV8VeozHTu0b5W PgXDRpfpiWc3tHXbzdur9fTJDgPvGob/HiLTPjd/X3HGOa2I9VGcSnVnmAirzPkpT6wvTMpmfzi TEwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Declare the seq_operations and let procfs open and free the seq_file.
->proc_open() and ->proc_release() only set up ->private and take and
drop the reference to the network namespace now. Reading the file then
no longer holds up its removal.

Acked-by: Chuck Lever <cel@kernel.org>
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

