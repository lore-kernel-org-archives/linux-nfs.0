Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821911;
	b=zda1mzE+qFDN7At/H2Vsy3HxtjpgaDyaNS3f931hPzuG0ZkHdNQDKDGaDgk7s1idCIwE
	 ubh3jsL0cHSnp04yMgd/7I4CG+jgViye/u3/bzGQBiDI5lMJaRLKqPTxAj+yUcUbmlCqG
	 O6Ms8S+vpouEC1VVv+M/5Wz/Lx9/5asp+5Ix/oVgmHrNVtBGSAAAuS+NIw2Xi7osPycOw
	 WwOutybnmq+OnVfY/pKFKAYbaOqFPMimA1eV03EPGtSkimDVq2v4wC6tresp5Sv/vgTNE
	 PQ+aEtnj8nbKFKsbbguEj64IcfWIwL4TQ+jRhOWCvlXgf5wEtPaoAGVc4SkQb3DmSZA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821911;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=lzw2p1lwQVTXGjOVK+O2fRllw6EWFGiyVpP4wwnyOh0=;
	b=qDYoSIOxocN5AxdfVKvWW8Z8pzS6IHJu80jMsvk+jL4U2YaJRkHQI7K16D0G64moNf9Q
	 yu6RXrFr0yZZqxUe5r9A09PGEZS9oHoub7MITEEdnmSTTZmCTxBNhGVHcjviRMdI+pBa7
	 iMMmjdLimyLNdpWWhEnroBKkcxuyaxmH0IaZ27AQeCgn+VLXLkCPqOoqgocNJsOM+3W4K
	 5zGcCshL3idye6MsOh98BZBXgLcyGqm2d33GKcN2kUMEQH8NRZka4sJYSI055sg9/h3bX
	 MvB7WayvkV2Tapax0oRqpcha0UUtQVBKtpGdWWgEx/OEl93Mq0QfTtxKG7bk+HrDuXQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QAJQ3+WL;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C84EC606BA36;
	Wed,  4 Nov 2026 19:51:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QAJQ3+WL
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 515511F0093A;
	Wed,  4 Nov 2026 19:51:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821910;
	bh=lzw2p1lwQVTXGjOVK+O2fRllw6EWFGiyVpP4wwnyOh0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=QAJQ3+WLDUkYLImp3HYyJ9xNQzT5ktofk3vTOb5CY1yyjGgMiMLV84eXcv7Ngn9pO
	 0R1aIfFok0raVnzXU9Vxsqv/+8svHg8UrA6VN+qDutbG0MoaDiCzmWdmWTuVYeXa/I
	 N2GChnCG6weK3daO3o2GHaFO3/dOVqhIMLzDjlCpOjj7c7+2YrdYYhUy9NCshP6wdl
	 Lk+TkGZGwLWFEFiLx/wufa/ZxQYuvNY4PHonWIRM9HX3gymQ16OIyPKKYKRaJNOE5j
	 ooOiwYlFZWYxO07ewx8hUYCero4307WQRVTKLVnFylG/X2Vx0yOkMhn63aRL8xUxMW
	 sonQvq7YDKhvw==
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
Subject: [PATCH RESEND v2 08/30] smb: client: let procfs own the seq_file of the smbdirect files
Date: Wed,  4 Nov 2026 20:51:35 +0100
Message-ID: <20261104-work-procfs-fs-v2-8-319e0f9a8aae@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1034; i=brauner@kernel.org; h=from:subject:message-id; bh=RIZYcDqYt7NhFvt2L4C6pTMn3DylkXBLCyRwuGHjm7I=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97jG5tPWrw/cVrCsb765In/OBvcn09R7LsHQ9/q6+O V1HHE9ndpSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAExkz01Ghl3rSlga96Rmhvie 3JVu2vHMZ1KgvNQ2f7ZfM06avi3c5s3wv8ZDfv2t3meZR3nKlGZN/Jj7Lukpr3r48QVnD/23mvz tIT8A
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Declare the show function in PROC_FILE_DEFINE() and let procfs open and
free the seq_file. That makes the open functions unnecessary.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/smb/client/cifs_debug.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/fs/smb/client/cifs_debug.c b/fs/smb/client/cifs_debug.c
index dfcd2cdbb2a8..664072ab3342 100644
--- a/fs/smb/client/cifs_debug.c
+++ b/fs/smb/client/cifs_debug.c
@@ -873,16 +873,9 @@ static int name##_proc_show(struct seq_file *m, void *v) \
 	seq_printf(m, "%d\n", name); \
 	return 0; \
 } \
-static int name##_open(struct inode *inode, struct file *file) \
-{ \
-	return single_open(file, name##_proc_show, NULL); \
-} \
 \
 static const struct proc_ops cifs_##name##_proc_fops = { \
-	.proc_open	= name##_open, \
-	.proc_read	= seq_read, \
-	.proc_lseek	= seq_lseek, \
-	.proc_release	= single_release, \
+	.proc_show	= name##_proc_show, \
 	.proc_write	= name##_write, \
 }
 

-- 
2.53.0

