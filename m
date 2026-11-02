Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793629338;
	b=yjdi+dx3LQ/D0tn3KOX7ZQdXjmx45q5d6P1f5AJYvJ+8RQrvO+6jvaMxxmYG/EVTO+Zm
	 i2d+LXhNc5xfGLSdhBCRKYqmJMwinY1sty75E/4OQcRgtTI2Jg3vquieSI3IvJ7CVbek0
	 p8PtxkiXy9ctFFJ5f/TTCMb2UxIVaalwXEi8ifu2W14GqaRgymbaGlPMxMElE4PlTi4Yh
	 5hY0IzbK6zhlAVDfI60GtSdmcBqlg/rMna+x59kpDIjw3kWPR3yqKYI+CceQZhEoThraJ
	 x3siVHjOCf6OpZYAn5V6uqa11JiWAQHJeC0T9eI8YOI6dtDkOzFpdcliGniSK3OLk/w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793629338;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=pGKkc9crGkZecPr8vk7TgMVLcv4DpuQHsFCpp4FMbY8=;
	b=gjzQKuKozuRR9DDKU970mbzRKSh3WR+8m5T8P/ffTlXDcPc5awWpoGqoU2wBBI0rTbtv
	 7rgnu33L/mkyQwsqTS8QEYAqJzD1YLB8CErFVb2ofnsSMrSL19Hb5iNyc6YcgEATc0LY9
	 v0h6/RzU3uukAKWmxuO+e/pYyeOcTRfkhoD/vNnXlTUfX4DkWqCrFZSIXSJkLMwkfNtcJ
	 KIf3aSFFYIyAtiymNwC4YXC+lrpd66gI6o+/nI5YaWEL85mvl5t3K/cQcgseuxb5v9zqM
	 vZ/eUC1Zy/gvpHgsbY3O7scrgfhCTfV11XouFOxPRmGaXFMC0gImjjo46TEn40SeFsw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Df3TZq60;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B4C7A606A33B;
	Mon,  2 Nov 2026 14:22:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Df3TZq60
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B385C1F00A1A;
	Mon,  2 Nov 2026 14:22:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793629337;
	bh=pGKkc9crGkZecPr8vk7TgMVLcv4DpuQHsFCpp4FMbY8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Df3TZq60vzd3Ud6sHKXoJyOdQDpB0y91AXsdElaLXcBNikKzPy/szHHI0/CwhfdRn
	 WsM9i5bSUctcGEqYeXI7QRDxIUmUu6UVak83Uv46oMzFfbpgzCr7WVMlJ4BZ9J3HMW
	 AjiG1/VEQjOOGRPDINpgdmcZyMZLtyj1mgE1Unq9dkmYqFAk/CpLvDVWQcV09cYgAf
	 ujO/67H0xCQCJ6g61xa0UOqeiUbiLYXf42d70VBXVhX79yB82XPCpH4/p7mnlrDBHD
	 DpkuL3OCzDyMvDM0Y7nF2tWK4aAoLW1EUN7+2jUNhTpoMsfy3rJmuVaCfP3vQoVnEw
	 qrmaSSpx2GTbg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:21:17 +0100
Subject: [PATCH RFC 02/38] PNP: isapnp: don't read past the end of the
 buffer on a large pread()
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
Message-Id: <20261102-work-procfs-bugfixes-v1-2-59422ed3e465@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1282; i=brauner@kernel.org;
 h=from:subject:message-id; bh=r49sdX7Qo0uBjLpgxxQ+IVLBreEaXwT40T2nEujvZRA=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9mJN1Oevk86ly4dxr5u5ckPH96NsbLxgkniTHLPuY0
 Ppb4oDwx45SFgYxLgZZMUUWh3aTcLnlPBWbjTI1YOawMoEMYeDiFICJ5CsyMpyUnxT0MYT7za6w
 DL3kKeLy+fudHgfx3zRQWh2/9tvz59EM/2MUrjVNN51Y9MLwwibHKsNwxzdPq+cE1u3LTEhIn7J
 PhRUA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

isapnp_proc_bus_read() truncates the position to an int. A pread() at
an offset like 0xfffffc00 turns it negative, the check against the size
of the configuration space passes, and the loop then puts everything
from that position up to byte 256 into the reader's buffer, no matter
how few bytes were asked for.

Keep the position as a loff_t and clamp the count against what is left
of the configuration space.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/pnp/isapnp/proc.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/pnp/isapnp/proc.c b/drivers/pnp/isapnp/proc.c
index c1f6e6bd0eb2..8197c7f29743 100644
--- a/drivers/pnp/isapnp/proc.c
+++ b/drivers/pnp/isapnp/proc.c
@@ -23,14 +23,12 @@ static ssize_t isapnp_proc_bus_read(struct file *file, char __user * buf,
 				    size_t nbytes, loff_t * ppos)
 {
 	struct pnp_dev *dev = pde_data(file_inode(file));
-	int pos = *ppos;
+	loff_t pos = *ppos;
 	int cnt, size = 256;
 
 	if (pos >= size)
 		return 0;
-	if (nbytes >= size)
-		nbytes = size;
-	if (pos + nbytes > size)
+	if (nbytes > size - pos)
 		nbytes = size - pos;
 	cnt = nbytes;
 

-- 
2.53.0

