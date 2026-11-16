Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827440;
	b=vvBVZ9T97S5FNAB/Izou9IBAMfk61r93QQ69k5bur2zOU+zyMjDzPEcY7ayXZXdyiKiH
	 iIKpj4sU8Nb9pP64MdxlmZJZvASZfPrzgJw57XLbZpJDOJMBiWyAr1HBvXLxYl50NKWTI
	 kdWXC/BrLKCm0ndcyB6AdGxKkGZw3clSgbSK3k0W4hEzf+XRPyJr4A3c+/PmbTgtYi2ko
	 RjcmLcKYlxYeuqtb/XEqV91c6Mo+eT52rOOBy8dUYgzXIWogWoGyum10VluYX2/eklblB
	 uBO38OqtdEHloIJNGukOldu+FtLySiPXUISxPtjIBjtzQpkZU5UgaD1cRaFOBwCGX+w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827440;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=TMBBwOCxq0RbA3xkr3IQCANlyHiMKhXi962Ec8MHN/8=;
	b=O4zd1N5TPEQ4f3nOlr74HSd4IkuJft2wED/KhonwdvjlDs2gnPd2h4FJgzJQdQCagZ9D
	 vb3tPsVOFPdYS7vMPplhucAS7nI0CbqStPQQK9Pg8cLlN67sINHJxUP06z/0QBnLN+V6j
	 gaYtjVU86YV8Is2xBSznvZ2iP1xQqTk4TthKzPXxNwp+5g2n0gTRK8OG816dX7ZWBazv9
	 9yYsyLg2tiwIJ2DB7TrK/ubQDM5PG+IcdVLcov5Rij9Kx5WJB+iZedS2RYHhyzdZ0hHpA
	 prFqa/XAFDJAgYwWbjGfP9IxNpfNKOHoP49zqsyobUmqokiVZq1NToq+biSCfxO7+5A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=l+BIJEfb;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0C6F5606A7AE;
	Mon, 16 Nov 2026 11:10:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=l+BIJEfb
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A58D71F000C5;
	Mon, 16 Nov 2026 11:10:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827439;
	bh=TMBBwOCxq0RbA3xkr3IQCANlyHiMKhXi962Ec8MHN/8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=l+BIJEfbLhnCAiQ9KjFFbH+KikDuWf7Rh0M/jNYiYLFM3JBoCkTU1QtWjpGfqyuFA
	 CSiogIgrJTCRIfQqExj48VIInR4+j/p1TBSDSDU3KHVkiSv4VTwVuUQsOXXPwbSjGT
	 3yic+O5L+OrlvIDI19sfN+4rh3qdY6Q1ReyaauwTlqsXASNdOse/Fh7GmwTFTBPEMk
	 V7YwmUvz678MdFDVA72s+VOIEk7DPWPvjqCbYbQRAxRHaDgQOErh9yRIemYiG+jRQ/
	 TEIFcXsS9+XxNmw10KCpA2RC6gwbTOP/zd6mhzzP3q8aoDPq5vCZ1BkJL96CD5g30G
	 1pPnYhru7oOKg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:05:10 +0100
Subject: [PATCH RFC v3 37/44] zloop: refuse zone files on pseudo
 filesystems
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
Message-Id: <20261116-work-loop-pseudo-v3-37-8cbbea1cf34f@kernel.org>
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
 Alexander Mikhalitsyn <alex@amutable.com>, 
 Chris Down <chris@chrisdown.name>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1558; i=brauner@kernel.org;
 h=from:subject:message-id; bh=XfUA5+m77vNauXdxpoCEKQvxsNkJs1ZrQCEAfm8XKRY=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9etzJVXe0X6Zm0vH193d2OB6eMv+pg2Z/9ALRRoMZX
 vcmSG3X6yhlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZjI+08M/3QZMiNqd39IqXkk
 99PB+YDugQoTg8Xv32en/V7x56/opmMM//NviaY8nxghcZ4/+eSWhcd/HHTXfr+Mf/LvXWXB0xs
 lLRkB
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

zloop opens its zone files by name below the base directory but a bind
mount can put any file there, including a procfs or sysfs file. Refuse
files on pseudo filesystems as zone files just like loop does by
switching to file_check_backing().

Note that the helper only accepts regular files. So far zloop took
anything with ->read_iter() and ->write_iter() as a zone file. That
includes character devices, FIFOs and block devices if someone put them
where zloop expects a zone file. Zone files are created by zloop itself
and zloop truncates them to size and to reset and finish zones which
only works for regular files. So refuse everything else.

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Reviewed-by: Chris Down <chris@chrisdown.name>
Tested-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/block/zloop.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/block/zloop.c b/drivers/block/zloop.c
index 65634a39b0bfc..6f79b9ddbbe00 100644
--- a/drivers/block/zloop.c
+++ b/drivers/block/zloop.c
@@ -1132,10 +1132,9 @@ static int zloop_init_zone(struct zloop_device *zlo, struct zloop_options *opts,
 		return PTR_ERR(zone->file);
 	}
 
-	if (!zone->file->f_op->read_iter || !zone->file->f_op->write_iter) {
-		ret = -EINVAL;
+	ret = file_check_backing(zone->file, FMODE_READ | FMODE_WRITE, 0);
+	if (ret)
 		goto out_fput;
-	}
 
 	if (zlo->block_size) {
 		ret = zloop_get_block_size(zlo, zone);

-- 
2.53.0

