Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794653289;
	b=qP8/8IvRz97MjOOQUUI4r3LGJu3NYNiGLR6r/99BQV13aELtOAuhtKCRfJeqHhB3orv8
	 NMau/j9M9/FrBsoGrSN1fc1fUKP1AnDC2j0uz2FSOxtLS/a5CT1QxXQA4CLA2Q/zhhxLW
	 cGsPjCOOXawNAErohZVeQ/hbytYQ4nPa8OpThT+eTwSBzrPD7RRLZFN5/5lKGNHp15Tgq
	 ZZUDtKegyjj50upNik8Or1oejLR8FdVpKYZtbp7TP1KiLJqfy47cWf51tRedvs6jQsghC
	 xKeDLAGjf+XRgZRCbSIYg4T5BOLOGoFg6AeLHNPI12wV2DAY3XN7exzmNMgAQGabNJA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794653289;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=gbCVq4/5eiYFaf+PhR9hp/bgYYe511qQstYUk8yenAg=;
	b=v/DDjlsp/eXgnw0lJPCPptX+icW4jfwm+Q4grB5YFX1PAgAQ073OYgo6I67QL7dkqRCt
	 ZbXHbCHcvoWFRuKs75U/CqTuC4qSqchmp34lnuLwxrjnrtswf8HV/4QcThF343cH9x8HS
	 8vonmpyj7ZELTEmGAGRsAKtxt7GSoaNIrc6WkbrAw7yGPmNd2V7Jl0WbrQzyPyvSMnSVv
	 b/Yw161oGkBfC1vVfEsJP4/7v0Xfn2lSwIBU7U0Jwx/C4UVj7BPu+GZXOVdyFd0zIRUJY
	 mPA7bOJwAcpNXC3gZAIWmg0fuEGU3VrQ38GPcxASYa0jZcQfu4Ul/t9tt4D9FWXA3pw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=C85Y3Cm+;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BF88A606A32E;
	Sat, 14 Nov 2026 10:48:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=C85Y3Cm+
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 22D6E1F00ADB;
	Sat, 14 Nov 2026 10:48:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794653289;
	bh=gbCVq4/5eiYFaf+PhR9hp/bgYYe511qQstYUk8yenAg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=C85Y3Cm+x4ix8leBBiSDG9Fb4Ss6w5SPx2bBk675rPnAs9wQca1+FOUGBhv2xuxw7
	 MK0TWIbAZocOlPzC+eNHjZzXFrIartDFgirA5LLHTYK6FMX7vb4Rc09IGDAn5/YBLl
	 b7oDPnZv2aK2wdSGEbscs8nzdjUU3HKPxU5oLD/Z6NZ5kE+8noXMmX+PlpZVr3Sb+Q
	 uF1CPyiyyGh6+6Don0HFTMptVIMeKDH1/BsbrmNOfQNwRJf2+L3dY6EaZ/wjL/uArI
	 IflUJ2auYkZiYC+bTHRNmE7FhUs7kksihdKyw3g49S3BPRCv68b17YPahKv00vn70b
	 XL1qNDb7gwh/A==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 11:47:13 +0100
Subject: [PATCH 06/12] loop: take freeze protection for discard and write
 zeroes
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
Message-Id: <20261114-work-fs-frozen_writes-v1-6-f5ae61c898b1@kernel.org>
References: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org>
In-Reply-To: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org>
To: Jan Kara <jack@suse.cz>
Cc: Shakeel Butt <shakeel.butt@linux.dev>, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, 
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, 
 io-uring@vger.kernel.org, Christoph Hellwig <hch@lst.de>, 
 linux-block@vger.kernel.org, linux-nvme@lists.infradead.org, 
 linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, 
 linux-unionfs@vger.kernel.org, bpf@vger.kernel.org, 
 linux-nfs@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1706; i=brauner@kernel.org;
 h=from:subject:message-id; bh=xHFfdTQ766WF3iw3WyUIkHbq04BvqXzbCzn5QRQPOhQ=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9sHFe2uP2eit76RRN2/P7Ch4xJy7svPFPQYaNQ7F0t
 YgZ17bnHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABORymRk6LxwQDPU1ke6KrWN
 0/DNt5X/U2cqFlXvvDfHcFnELm7T74wMk+/8WTR5ft0Jh7vyXv9e/5VZ/rjbJ3vz/F6dRd84hVv
 U+AA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Discard and write zeroes requests end up in lo_fallocate() which calls
->fallocate() of the backing file directly. That skips the freeze
protection vfs_fallocate() would have taken. So they go straight
through to a filesystem that is frozen. With the backing file on ext4:

  WARNING: fs/ext4/ext4_jbd2.c:90 at ext4_journal_check_start+0x1f6/0x2d0, CPU#3: kworker/u16:1/44
  Workqueue: loop1 loop_rootcg_workfn
  Call Trace:
   <TASK>
   __ext4_journal_start_sb+0x7a/0x470
   ext4_dirty_inode+0xa1/0x120
   __mark_inode_dirty+0x154/0x1110
   file_update_time_flags+0x3ab/0x4b0
   ext4_fallocate+0x286/0x3440
   lo_fallocate+0x13e/0x290
   loop_process_work+0x486/0xe70
   process_one_work+0x946/0x1820
   worker_thread+0x4f1/0xd60
   kthread+0x364/0x460
   ret_from_fork+0x525/0x770
   ret_from_fork_asm+0x1a/0x30
   </TASK>

Take freeze protection around ->fallocate() like vfs_fallocate() does.

Fixes: dfaa2ef68e80 ("loop: add discard support for loop devices")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/block/loop.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index a3325ceab484a..77f0601475bb9 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -259,7 +259,9 @@ static int lo_fallocate(struct loop_device *lo, struct request *rq, loff_t pos,
 	if (!bdev_max_discard_sectors(lo->lo_device))
 		return -EOPNOTSUPP;
 
+	file_start_write(file);
 	ret = file->f_op->fallocate(file, mode, pos, blk_rq_bytes(rq));
+	file_end_write(file);
 	if (unlikely(ret && ret != -EINVAL && ret != -EOPNOTSUPP))
 		return -EIO;
 

-- 
2.53.0

