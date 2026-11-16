Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827454;
	b=Fhu7n+IxiXZFiYYNxp6fmcgD3HcFLxeEY15uCBMQ8CUb0zjD/05yUWkcSnAmYOBUKRTD
	 VInhTZ5mrTynau0AndkwSPGtMUU/xug+bQ5qSNqcSYTH07+R49A/KxT5p0Ua3DTMAyTiM
	 xGLCfBixdutukVS5YlGMG6Nsz7DlKo1zlD97WV0M3FXyHyHbXRPM/Kr4NMyk8zoQ/stmt
	 5RG+ehr6+fHoqo250YTLx/gnUanvdtO+vY3x0MEDwuwxEiiUXK/9IMfxlu2VGhqBZh9Hb
	 akBCbI/HzMRsj8387XVG2cMu9M7gQGuVOagKbZWU/DSpls8fOZeYWLQ2mooFv3dPfyA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827454;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=BY87H/RnXilQq13XAhtvlglG6136WbkekRPXJvo2I3U=;
	b=s+k//LAOGv22X8fclpoZMjvu3uPFshH5VexG7uQL4NqaSBr44WS8zmnySYxf0hGbTQTD
	 q+RPLc7odXiLath/8jAWaH0fkKZoFH4NZuuuxlyheeohy7Ie/Z0CQ0G9PoW3FVuiFW/H6
	 gQSUkt+E+5a87lLaT7zGV3Yvnv0d1wTCMNP1/njanX0LSrEZtaq2nxPTXgeZN1zDDRuJj
	 OMxhNeSY95nSonQM7GWF8X7RjjgeyiyadCdU8YeWXisjDfD+sBpMd+ViErqM0jv8ApK8C
	 tNXKDZOvTiS9X0lwnYDxr+dU8uQlmLYPUtxsX//HLbttdmwrLWYx7OPD+cP/GhJ+2Qw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Tsq4iuTK;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C4EB460A6F54;
	Mon, 16 Nov 2026 11:10:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Tsq4iuTK
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 416851F000C5;
	Mon, 16 Nov 2026 11:10:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827454;
	bh=BY87H/RnXilQq13XAhtvlglG6136WbkekRPXJvo2I3U=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Tsq4iuTKRhulkomOLwfJCGY7RSUTospv3OqWJbcYQQFjEoKupjSCxw6Yy3rPq4pB9
	 +LrXvKA4rBly7ufMqZGGURI/PkATv40fMYkjtpqcL/tNHRyeTByFbJTZmujbH0d7/Q
	 HXCq2zQGevHC5tGi3GM/YXAFadxr211gKZs+efK2OMgZEBHzheaSEy+WXOjCe8RO5r
	 TJ2bRHJjwjB/ITjzevhBLxBTbfuTMUOIvIjO5xZFZMBmnzadWnSvOl1+uUswfItRJz
	 cvn+ZB4G6vMTJzmJfSaWRJJZDIQQXhCz05Bm/gc8LbBO51UdG9XgtkJRygpVExqJdR
	 0R8YByohYWTAQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:05:12 +0100
Subject: [PATCH RFC v3 39/44] target: fileio: refuse files on pseudo
 filesystems as backing files
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
Message-Id: <20261116-work-loop-pseudo-v3-39-8cbbea1cf34f@kernel.org>
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
In-Reply-To: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
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
 "Christian Brauner (Amutable)" <brauner@kernel.org>, 
 Sashiko <sashiko-bot@kernel.org>, Chris Down <chris@chrisdown.name>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=2223; i=brauner@kernel.org;
 h=from:subject:message-id; bh=11gfWGw/ZwPDfVFtqD+CkdePFs+glK5xVNQbp3ek2T8=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9etzj8cs54I/rlC7xuCARluu5a1aodKvyswTvkD6zv
 1dfVPVMRykLgxgXg6yYIotDu0m43HKeis1GmRowc1iZQIYwcHEKwETirBj+e2jMajfMFJqpekRG
 aqlo40Pe5TUVy7c/+DD7XlLpsaZOLoa/knzXPN++Mv3K99Ndbp9ymKjRnUWue9I2sb1mqWq5pLu
 bHQA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

fd_dev_name can name any file including files on procfs or sysfs. The
initiator then gets to read and write kernel interfaces through the LUN
with kernel credentials. Refuse files on pseudo filesystems just like
loop does by switching to file_check_backing().

Do the same for the protection file. With DIF protection enabled the
fileio backend keeps the protection information in a second file. It is
named like the backing file with ".protection" appended and
fd_init_prot() opens it by path. Whatever that path leads to was taken
without any checks.

Note that the helper only accepts regular files and block devices as
backing file and only regular files as protection file. So far the
backing file could be anything with ->read_iter() and ->write_iter()
including character devices and FIFOs.

Reported-by: Sashiko <sashiko-bot@kernel.org>
Closes: https://lore.kernel.org/all/sashiko-outbox-206765@kernel.org
Reviewed-by: Chris Down <chris@chrisdown.name>
Tested-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/target/target_core_file.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/target/target_core_file.c b/drivers/target/target_core_file.c
index a5391e57e9aa5..c747cc4a647ff 100644
--- a/drivers/target/target_core_file.c
+++ b/drivers/target/target_core_file.c
@@ -145,8 +145,8 @@ static int fd_configure_device(struct se_device *dev)
 	}
 	fd_dev->fd_file = file;
 
-	if (!file->f_op->read_iter || !file->f_op->write_iter) {
-		pr_err("FILEIO: %s lacks ->read_iter or ->write_iter\n",
+	if (file_check_backing(file, FMODE_READ | FMODE_WRITE, S_IFBLK)) {
+		pr_err("FILEIO: %s can't be used as a backing file\n",
 		       fd_dev->fd_dev_name);
 		ret = -EINVAL;
 		goto fail;
@@ -861,6 +861,12 @@ static int fd_init_prot(struct se_device *dev)
 		ret = PTR_ERR(prot_file);
 		return ret;
 	}
+
+	if (file_check_backing(prot_file, FMODE_READ | FMODE_WRITE, 0)) {
+		pr_err("FILEIO: %s can't be used as a protection file\n", buf);
+		filp_close(prot_file, NULL);
+		return -EINVAL;
+	}
 	fd_dev->fd_prot_file = prot_file;
 
 	return 0;

-- 
2.53.0

