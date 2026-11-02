Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793632403;
	b=IfCicKvWyi1ipusw9z2oXCo19CYuN748rCLFLxloHZrYJBQJ058kOGqyvfk9LtVb4GaB
	 8kQCK3OmCCnIhW9OL9EGuZ714zfjmi9imMzCENyHT+0/UjzJNiYs5YUU9AKZwVtitADIc
	 6azEAKyO68yR2qf+owiYm/4tis7LyAm/Oj80IduELejDA28pqyQiTxbFSeI82EmrfNC5t
	 KRamRZx8c6dAAafMw4FbXQAaG1F5rDuMII2K/rSwZcm+fzeFBmd0Ne4HtWOOnahLcKhVp
	 kNrSVyWxNTwSBI2A4ExRiYNbDa0nvdMQoEy1NNK3/zI482mX4a5mkj4b+X4ADCevXWg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793632403;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=BWMrcMxphM3j3KhJxvOCR+KbGizC6kQdxxuLzJskxVk=;
	b=nrBt8/HsOlPkrLAlPReqlz8GpUi6Ki9AR4L2IHlsIzwyEhQ2SnHQAYp6xMYSM2GDCFCU
	 krgj76RT5Stq5/Jq0p/ifZh23W9HDsDrf3IurY1YFZSbTMReSwKD/weOPgxPSlAmt/6f9
	 lfO5fWxcaSq6oZoNnY3SBmH7qcdZeju6CWcHABUngbhaHwWQgp3Ouy6CDXK7kiuuDfjLa
	 nnLK15QRGUgWh72bXhlbBvbKLoDMyfMiyerLl5Jo+tK65ENW32dec8dRzovLGxpb4rOoS
	 PkaXGjh9uNZmrYokh4brK02Hhud40uTL4JcmZdHZFkePIWbSLDUtZ9Tjhvkaci5Vr3Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mIjK3Qwt;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D50F060913CA;
	Mon,  2 Nov 2026 15:13:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mIjK3Qwt
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 643241F00A16;
	Mon,  2 Nov 2026 15:13:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793632402;
	bh=BWMrcMxphM3j3KhJxvOCR+KbGizC6kQdxxuLzJskxVk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=mIjK3QwtTVilSpcRMeaoz6MTKvP7Sy6dH4N9uXF4AEtvkmOD+/LZgf883MtrMNbfX
	 Fc7qy6+hRUrZLI12uqt+tFP3+FSAd9d3s0S7Oj/5J8YKb9MuvzMCclBQW5ujuLEY3R
	 0jZ40m7Qe6thFpBjmEpgSnaWIQpr2OFaA+Hu2iHvPuRwIzTy5CX2f99EzFV0hO5HRa
	 v3h43WiiAhfIdyZllqL5RbxOqUX3/Hcfx8oBtLvZRAePXNc6Si2FGn6GzYJmq+441r
	 GdWXtRs4TvUpEjCZFIA+oogkhKJvXJm8hEiDfFaliMcEnFuCVmnTvn4+eIcYomOAzM
	 v0Y6JeRoVTSgA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:16 +0100
Subject: [PATCH RFC 09/23] scsi: let procfs own the seq_file of the host
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
Message-Id: <20261102-work-procfs-drivers-v1-9-a994bd4d3b1a@kernel.org>
References: <20261102-work-procfs-drivers-v1-0-a994bd4d3b1a@kernel.org>
In-Reply-To: <20261102-work-procfs-drivers-v1-0-a994bd4d3b1a@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1394; i=brauner@kernel.org;
 h=from:subject:message-id; bh=l1PqfsIz+cqTipGWNtI2ZFkSTs3hYfw6G0B1mtmwjUo=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG4wo+Pp/Vmn2AIF2jK3Rnc8S5TW89ldrDXNvflSK
 a9TlSBvRykLgxgXg6yYIotDu0m43HKeis1GmRowc1iZQIYwcHEKwER2/GNk+LjMbs1f+SqdgEVP
 95yaUyouP9NB9EfZdvNTxdef/51/W53hnylf8tFqgbuGLVyB25bLi7g6NKw02Kjm+6TD3337TuM
 +XgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Declare the show function and let procfs open and free the seq_file of
/proc/scsi/<driver>/<host>. ->proc_open() only preallocates the buffer
now. Reading the file then no longer holds up its removal when the host
goes away.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/scsi/scsi_proc.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/scsi/scsi_proc.c b/drivers/scsi/scsi_proc.c
index 3e49c4c8704f..59229bf9938e 100644
--- a/drivers/scsi/scsi_proc.c
+++ b/drivers/scsi/scsi_proc.c
@@ -94,10 +94,10 @@ static int proc_scsi_show(struct seq_file *m, void *v)
 	return shost->hostt->show_info(m, shost);
 }
 
+/* procfs opens the seq_file */
 static int proc_scsi_host_open(struct inode *inode, struct file *file)
 {
-	return single_open_size(file, proc_scsi_show, pde_data(inode),
-				4 * PAGE_SIZE);
+	return seq_preallocate(file->private_data, 4 * PAGE_SIZE);
 }
 
 static struct scsi_proc_entry *
@@ -140,10 +140,8 @@ scsi_template_proc_dir(const struct scsi_host_template *sht)
 EXPORT_SYMBOL_GPL(scsi_template_proc_dir);
 
 static const struct proc_ops proc_scsi_ops = {
+	.proc_show	= proc_scsi_show,
 	.proc_open	= proc_scsi_host_open,
-	.proc_release	= single_release,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
 	.proc_write	= proc_scsi_host_write
 };
 

-- 
2.53.0

