Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793632257;
	b=43qTP9ImhQDQ8UwODijvbWibc+fTTtcyFt3VZQxzH0/GZ34jyQdyZpMZzUagJC8PWIXi
	 xH6orgP6Mm8t4T8+opLryqhAEzQdcc/MxXWCr9o1I0E/HT4jjKEb4C7LUV2UR1bwC768m
	 Dujd/Ohyf34W5WhXqV/FUuS/kafG9LNP1BU7aMJFU63JLIYptSSz1SW0+2N1vdJB/07lJ
	 fnkV904ZK9jcLBDC7Dm5X8EoRgu58ZfSii3OD4ETCEuy17U895y0NMfsfuFtllVBi3eI3
	 rk/dvEyIOPm3FHP3JGBO1jyHeuDhecwO4tp8tte/AtusiiX2Hij1u0iYgWjm7kNkqSw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793632257;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=gEfU3T2fMjgdZUubap6/Nt8I8xKTHWl/++QTJaSUEcE=;
	b=bFTf1i8BElNv52Lc3XnmKCpysPR2oz30V0xgUPJ9vNAodCw07Ck0R5jYZ77tl7P5t+0J
	 rFNqhLSW9N/wW2xyYYI4b256pWgxXRIFWH6zkTXaZfv1VnU+FSrfUaMmLmTXkZxUJIRtG
	 XkBfMgy7EXaPZPpEYlx/cdqI+Ey0PoZLPbP5OKzDfv+XLJHo4hTXJV/FwyKl+SK9S3OjX
	 ljQ0/Y2KZgYmpn5y/z+SQ2WHFli0Y/+a51XV+Ib62JBJP9m5p7C13KHlo/xaRy+IIkjsL
	 erZA0nYOb/PaF+4JwAaRJKPLjmRFcCbOUetx1Md3bAAKT4v3GFvTvGKQbLNYRlOHmQA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JEtEk3Xg;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 77E8C608C973;
	Mon,  2 Nov 2026 15:10:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JEtEk3Xg
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AAFB91F00A18;
	Mon,  2 Nov 2026 15:10:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793632257;
	bh=gEfU3T2fMjgdZUubap6/Nt8I8xKTHWl/++QTJaSUEcE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=JEtEk3XgkB7h/KCKSpjSx/GQWpU/P/7tvtCdnnzCxrDpIn594psdLHFTrmfuke6dM
	 slBqHYXHnT54x/QPrsmxH3yeqxfZQPD2y0pgY1+PEiyIIJsHQEmrStcSZUBzYnriXr
	 z1cAZ9kaI1mij4Fc3B7DH9EC4k1fIQp6BDZOK3UL5awrKforvD4qmdeHd8pveKvbcx
	 iZMvCpnYB/tvXMP/UoxQpEd6uLwjQn9oT2yIsRi+8s3j66mGWx98OAk1gVJO1c+yd/
	 xAonphmuY1qwZTlY+D0zGjvzNIJDEogTrjTuIG2qL99CLq6eIn2OG7zpSiKwd/V4oF
	 8+lGx05vpGPgQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:09 +0100
Subject: [PATCH RFC 02/23] zorro: let procfs copy out reads
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
Message-Id: <20261102-work-procfs-drivers-v1-2-a994bd4d3b1a@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1540; i=brauner@kernel.org;
 h=from:subject:message-id; bh=0V4WXwhQL5pRZKlAhpvNvMMTbS/E9DKCsIQEEH9Ob/I=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG7AIbrx5h2jApOfJWsWGW9hzDP7Z1n71GbDkhKjd
 1G75+1S7ShlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZjI/UaG36wcDIusu3nPOnFM
 /P+8oNKCR/ZZrpFyDV/sHU9NRa7UTIb/YfZNrhe7BR60inb8XH12tpIKe1zQvdmbziyrv3LhEYc
 VLwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Implement ->proc_read_buf() so procfs copies what is read from
/proc/bus/zorro/<slot> to userspace after it unpinned the entry.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/zorro/proc.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/zorro/proc.c b/drivers/zorro/proc.c
index f916bf60b312..4e4ba04752ea 100644
--- a/drivers/zorro/proc.c
+++ b/drivers/zorro/proc.c
@@ -28,7 +28,7 @@ proc_bus_zorro_lseek(struct file *file, loff_t off, int whence)
 }
 
 static ssize_t
-proc_bus_zorro_read(struct file *file, char __user *buf, size_t nbytes, loff_t *ppos)
+proc_bus_zorro_read(struct file *file, char *buf, size_t nbytes, loff_t *ppos)
 {
 	struct zorro_dev *z = pde_data(file_inode(file));
 	struct ConfigDev cd;
@@ -49,8 +49,7 @@ proc_bus_zorro_read(struct file *file, char __user *buf, size_t nbytes, loff_t *
 	cd.cd_BoardAddr = cpu_to_be32(zorro_resource_start(z));
 	cd.cd_BoardSize = cpu_to_be32(zorro_resource_len(z));
 
-	if (copy_to_user(buf, (void *)&cd + pos, nbytes))
-		return -EFAULT;
+	memcpy(buf, (void *)&cd + pos, nbytes);
 	*ppos += nbytes;
 
 	return nbytes;
@@ -58,7 +57,7 @@ proc_bus_zorro_read(struct file *file, char __user *buf, size_t nbytes, loff_t *
 
 static const struct proc_ops bus_zorro_proc_ops = {
 	.proc_lseek	= proc_bus_zorro_lseek,
-	.proc_read	= proc_bus_zorro_read,
+	.proc_read_buf	= proc_bus_zorro_read,
 };
 
 static void * zorro_seq_start(struct seq_file *m, loff_t *pos)

-- 
2.53.0

