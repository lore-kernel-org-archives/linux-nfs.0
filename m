Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793822193;
	b=CLgwOQ2I54MJ7pjYBupfNvHZwZPWf+RHFTrtGjsZbGoLzVcejtRGoTq6fLx2SB5he50S
	 jekpQHcTcvrDV1mxRhJckYI6C8+sapNi2Wt0pTb3N3ypvuoUqTbHG1NwCrpYEgZ6QOs6M
	 Qr165uacb9qtn5PkZOK2cJVmKl2Toie5KDdHdzrHKlAoVWa3Q9jDnEIMQwvFpmqtHqeEj
	 E/sj/h1hAHWHorQuI1iNMn4BPZU3OYtJ9BRwPX5QCE9m/8O9utmNrw7VJ5Z09138N/l+k
	 8m9LzOEIqr5i0FumJgp2gUWttc7PLFLJi30bqs2YYEiiR6keOyHtpC/prF/5CICYIzw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793822193;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=LBl2/qBMA7OV4BMTYua5kVHXByvRuxQ8RJbkH2xlEeQ=;
	b=KxfZ+fMcUIRncfBRU2z7GFqw11/hHRythL1xYGUqrpX86SPOX0wOYDrdNCIX1/uHnG2q
	 6B5MRWYxqcR7VEquC3hAlADymbVsmX3h3o8tcv16/cPASymiHKgHaQ/UmKL2L2n1Pz6Xo
	 qJtO+LZiY06P+JeD0JQzzTlGLhfmfUn29g+o3WBlvk87fW/We6swiQwArKKRK3qN14O2v
	 NAS+RtGIhP9RqT/JChyUQB5Bq2vfZi3QTxl4ueKApKqyARyns3GtN3LvrROI+CpIHwvUu
	 4JETGrlYL7NueHgQMvVrZ+GMqqZHJ+jdMAGWVjHyHIjwwyx+bHC+hKja3kDuhXadT1w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aKP7JyYG;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4A268609CAC6;
	Wed,  4 Nov 2026 19:56:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aKP7JyYG
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B86BA1F000C1;
	Wed,  4 Nov 2026 19:56:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793822192;
	bh=LBl2/qBMA7OV4BMTYua5kVHXByvRuxQ8RJbkH2xlEeQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=aKP7JyYGkDXXcZgiOMyJDOMnJ3YKXipcdyKMOhnZ/kDushdocc5j2aUosHVgdFjuG
	 W8NqrAjXIVJtlk3D6BRdnDPijmdfnyH55xY4/5GIe8B7ijNhQWuqM7VHbGTChu/S5p
	 bjawb6WUZLBB8pnefyGL4zorD4j/72K+4RlaEoOxwLWCBU80eFeiO+LKNoVR3cDXsM
	 3PJy33mjWSy8B1p5T5flpR5Cr9VBJtwZuxs51UHe1Pt2cbGiY3/+T4y9EH9bSAjyVG
	 E7eQOJVTxndTF1qhOS06r3zzRaWFs4kd9ALYhL3GOdUn4eRB1X31/INX4f8HZSXd4y
	 I59kxqMTzVXsw==
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
Subject: [PATCH RESEND v2 27/30] mm/swapfile: let procfs own the seq_file of /proc/swaps
Date: Wed,  4 Nov 2026 20:56:18 +0100
Message-ID: <20261104-work-procfs-fs-v2-27-319e0f9a8aae@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1169; i=brauner@kernel.org; h=from:subject:message-id; bh=xP8svTINdkdtOq03sFDyUkKM00LKGtRsGg97ENBLGtM=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97vHhXJd8Kth7+zWufRt8tZu59658dXe75H+F8xvTV ml+XhRg2lHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjCRqbMZ/kps+sao8ittxlXf /G8XPGKtjMsDSyLXBR7ut+jjuGbTHMHwP7A9pOPMY4eI2fw/JsV8unzukJPgecs1+ql+y/k/6SR 1sAAA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Declare the seq_operations and let procfs open and free the seq_file.
->proc_open() only records the event count for ->proc_poll() now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 mm/swapfile.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 254ce86fa923..ee4868ecc3a7 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -3410,26 +3410,19 @@ static const struct seq_operations swaps_op = {
 	.show =		swap_show
 };
 
+/* procfs opens the seq_file */
 static int swaps_open(struct inode *inode, struct file *file)
 {
-	struct seq_file *seq;
-	int ret;
-
-	ret = seq_open(file, &swaps_op);
-	if (ret)
-		return ret;
+	struct seq_file *seq = file->private_data;
 
-	seq = file->private_data;
 	seq->poll_event = atomic_read(&proc_poll_event);
 	return 0;
 }
 
 static const struct proc_ops swaps_proc_ops = {
 	.proc_flags	= PROC_ENTRY_PERMANENT,
+	.proc_seq_ops	= &swaps_op,
 	.proc_open	= swaps_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= seq_release,
 	.proc_poll	= swaps_poll,
 };
 

-- 
2.53.0

