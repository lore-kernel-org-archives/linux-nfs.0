Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827098;
	b=ki+q7TIydA9IRTJ3Iuvza9cUQsfFoprlZeu89uzI8Hmb1Q898SdDAv4z+GVDYlErjJSz
	 Rt1Sb7DjELlmOUpzXG40o/A1kdiJm9xgE7bA5km7CtdVf+/4WAJVBi4bGBCK5zqB8aLWA
	 VEtDbPD0Ci5qpwqGDyjEx6/TVqDGfIMj5KWmgMzJxOCPtYIKEx9bNRM+oKCMO1hhAsEia
	 82px+tj3N/Gn3rE4Ir1JyeSn6NxabWh8usHCc13X0z83IL+fi06dPjSaZvTFd22SWbwUb
	 48g03PGMKxlaOQe7TpJznX8oWEB29ZRN2bNZQ/oSwlPB1CLqmWod2LGZX2XGIeRcq/w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827098;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=rGbOPfT1yqUwvO1m52rPtj56PBfhsl6HwTcjr6r9MlY=;
	b=KBnvNfGHBPtgl9cCIaQyV1RNlEsBn0f0kAKD8Q7ssAvLqz5aczSMkKFitOrGU9Z54Ttm
	 Z1oHRoOS+mbe/9qxALIBN1kVz+vsp/MDUxOcy2ujQpCna8vg1qYKzi0Qbq3xavk7HUCGS
	 r9QSSbOVsBcctrDQHViaya1t6UrwEi9Vlty0iD5j+NjRIw5fJzk0ZOYpwTRHRjsS38PpF
	 rUXu0gxbatPWGAB1zGQBLhEA6Yl/gIh+GMVVVwZW6XGAZmsDCk/CLz7wK8BrhBEVfjqft
	 FdJyp2t1UbfZJtAM/ee3HCIgQyqePaL89qsw88EADPjiI8B7GS3im61lFby68PFrKXQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BNoGazjB;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F3A9060A5BD2;
	Mon, 16 Nov 2026 11:04:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BNoGazjB
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2B7B81F000C5;
	Mon, 16 Nov 2026 11:04:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827097;
	bh=rGbOPfT1yqUwvO1m52rPtj56PBfhsl6HwTcjr6r9MlY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=BNoGazjBxWR+CNpzOdNZGQkEHyjMC5rjb3rqOwRQrvHhl4JuTermScglTO41V4rUK
	 hZndB2qWZxm/m+nVDVm2meccG5hgcZmAhgFPyyCKAWza6Zxtqw9x9QO5gVl2vUD0sp
	 gJmMvzERCz8KJHDDGOztHplpn6ncwf+KBAqGQ5MCdP9BCzItG0p4dUghIfRRxO01KM
	 g1NdHIXg77CPcNpQfV2xMrsoxfm32siNqfBzYGzljzXna82cJGpeIQ+DjTjuiC7Y7/
	 nXfqzRwSL4TsON4GFDoArUv9Sk5x9ALaaafE3GUxdDIaifsqEMHi1T7Q2N7xk685Dk
	 815Mk1Puw6t7w==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:03:48 +0100
Subject: [PATCH v2 08/17] loop: take freeze protection for discard and
 write zeroes
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
Message-Id: <20261116-work-fs-frozen_writes-v2-8-ecc4a2aac40e@kernel.org>
References: <20261116-work-fs-frozen_writes-v2-0-ecc4a2aac40e@kernel.org>
In-Reply-To: <20261116-work-fs-frozen_writes-v2-0-ecc4a2aac40e@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1772; i=brauner@kernel.org;
 h=from:subject:message-id; bh=3iiZH5iMD4I3JcLZEMc4xg7xYKXAAdlzVQQRTB4v7fk=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9eqxW9uBZ9rfzwnIFc5vS2rgZlu3fmji3J3qu6+xgh
 Rh+zqzXHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABNJTGX4X7v2hsP5RkmlkO5/
 hxVuzfq9mtlRe6VEzwe/hP7+2lB3Tob/mS+v2z1bcumyVcktC833q/7P6ubZqyifpRq4O8p82p9
 J/AA=
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
 drivers/block/loop.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index a3325ceab484a..d2f29aadabcc1 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -259,7 +259,8 @@ static int lo_fallocate(struct loop_device *lo, struct request *rq, loff_t pos,
 	if (!bdev_max_discard_sectors(lo->lo_device))
 		return -EOPNOTSUPP;
 
-	ret = file->f_op->fallocate(file, mode, pos, blk_rq_bytes(rq));
+	scoped_guard(file_write, file)
+		ret = file->f_op->fallocate(file, mode, pos, blk_rq_bytes(rq));
 	if (unlikely(ret && ret != -EINVAL && ret != -EOPNOTSUPP))
 		return -EIO;
 

-- 
2.53.0

