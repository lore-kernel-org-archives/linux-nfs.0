Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661544;
	b=fc/94KkRaQH4PrywtFzjD/1YTit9/bypzcPma9HLIe1vwwAbaD86DMXePZ9A+yUeo89L
	 XXXBA1L6dSY/AfTxQoMii3SuMkEV/tMQgN0iS+AeEw3oj2NOYFGf4b8Z2HuS7mu6KcCIc
	 KWElcrgcnjn3z6MN5YZ9NIrZEIHK+i3Wj6NT9/0zTD/zUX1nub9Nc+DWMmM3/FoSbPH2P
	 E2jqCuiLH3n5R63a9+0KpkwiYyk8xBIhRANyIrEspYtJoGu/8YaQvi7P/6jyWw/+aQmVd
	 FSmefCJXH71e0f0gp9fLzXkTQNP1enC7Opw5JPEbBOLqIc/hiiJwBxbbDlmP7tiwgjA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661544;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=UFO9l/21W/p57UQi3nxXvGylhBlGyaXo8dkkR6Kzl3g=;
	b=Ga7fjAdixkIgTA1OZVYL7TQwpXO3M+UTW2ozqErakNx/n8lebMTUFa2z75rHYvbEGOMQ
	 T3vU08ftZqcO2hNY/Zj0D8bSo3031PrKRYLs3avhV0URasJXGdWpyFRsbB/OPqAa5R8m2
	 1e69BD4q5b6l0rNW3f2cFSJxAq+jzCxCVlvLnytX+LeU1PhzTQLNWlZQmnw1z1qp+DCFJ
	 AR4V5YhHrPmHmf2Sly5zS2MowF/FAT+Y6ehdCcP/n70oMp9oswwTZjd6s5GmQjxFbNB2E
	 YcBBeLpU5Rqp1rCIQPxraif83ZJ2y+NlE1K0sVrvV+J3yJAYcrnXahTz0N6POm1ADOQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="efVM9o/h";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA2AB606A8AE;
	Sat, 14 Nov 2026 13:05:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=efVM9o/h
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9F1041F000C5;
	Sat, 14 Nov 2026 13:05:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661544;
	bh=UFO9l/21W/p57UQi3nxXvGylhBlGyaXo8dkkR6Kzl3g=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=efVM9o/ht18LNBayF3D7oOTcXQ+zQCvKSlyCayqwAYKv8bDYhkCN28KsHSlR6cMw8
	 4vF4PVm13UDKS8+oQ2cZQEBkjysVe3A6Nrl6NtQAxof/K3X7FCHiReyLELP5MDb8hQ
	 d2gL2CxDePyruIvRh5R3YjiY7iLYLYQu27gg+QG4usERJo01RD8CffYKDn4Arsbfb0
	 kqmBhVnVPQD8zke3AZtVSBf8thbVIXaf/i5ZGVCckkNQ1RDwJaoqZxxDbFNlrAQ2pS
	 KE4SKdC5qQmh16hHjDsNJDaG6MSH9S9GaVw+gzEFRuyMQOhbFY55PU1Zxdk60HYVRk
	 7XRSI9AN43uWw==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:01:42 +0100
Subject: [PATCH RFC v2 01/42] loop: refuse backing files that aren't open
 for reading
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
Message-Id: <20261114-work-loop-pseudo-v2-1-98639a2286fb@kernel.org>
References: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
In-Reply-To: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Jann Horn <jannh@google.com>, Chris Mason <mason@kernel.org>, 
 Josef Bacik <josef@toxicpanda.com>, Christoph Hellwig <hch@lst.de>, 
 linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, 
 target-devel@vger.kernel.org, driver-core@lists.linux.dev, 
 linux-mm@kvack.org, bpf@vger.kernel.org, 
 linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
 apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, fuse-devel@lists.linux.dev, 
 linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, 
 ocfs2-devel@lists.linux.dev, linux-s390@vger.kernel.org, 
 linuxppc-dev@lists.ozlabs.org, linux-usb@vger.kernel.org, 
 Amir Goldstein <amir73il@gmail.com>, linux-erofs@lists.ozlabs.org, 
 linux-kselftest@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, stable@vger.kernel.org, 
 Alexander Mikhalitsyn <alex@amutable.com>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1829; i=brauner@kernel.org;
 h=from:subject:message-id; bh=RNS20EKOa1D5gB/WqkZbolMxn0bhv9TmaIu0BLZLG3o=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iEk7N/1b6Zufav+udO25utxD3izgpkPn8SDLhSpbn
 xXzJ6mEd5SyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEyEfwEjwzfdzxP2LSu3zMqd
 fkThvaV5jphdtEzbnRkiz6M9DdgE2Bn+B03SrPulVrXhk4t5hOLZRXPS3k0t/7U6s9oxvnojx4J
 dXAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

loop_configure() takes any file as long as it implements ->read_iter().
Loop itself never checked whether the file was actually opened for
reading. Buffered I/O went through vfs_iter_read() which refuses files
without FMODE_READ. Direct I/O has called ->read_iter() of the backing
file directly ever since loop grew support for it.

Since commit f2fed441c69b ("loop: stop using vfs_iter_{read,write} for
buffered I/O") buffered I/O calls ->read_iter() directly as well. That
commit was about O_DIRECT handling and the FMODE_READ check went away
as a side effect.

So whoever can set up a loop device can read a file it was only allowed
to open for writing. Open the file O_WRONLY, configure a loop device
with it and read the contents through the loop device.

Refuse backing files that aren't open for reading. Loop always reads
from its backing file so a write-only backing file never made sense in
the first place.

Fixes: bc07c10a3603 ("block: loop: support DIO & AIO")
Fixes: f2fed441c69b ("loop: stop using vfs_iter_{read,write} for buffered I/O")
Cc: stable@vger.kernel.org
Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/block/loop.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index a3325ceab484a..c96e35c3ef423 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -528,6 +528,9 @@ static void loop_assign_backing_file(struct loop_device *lo, struct file *file)
 
 static int loop_check_backing_file(struct file *file)
 {
+	if (!(file->f_mode & FMODE_READ))
+		return -EBADF;
+
 	if (!file->f_op->read_iter)
 		return -EINVAL;
 

-- 
2.53.0

