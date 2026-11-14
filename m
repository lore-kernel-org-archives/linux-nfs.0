Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794653286;
	b=FOXyBgUS1aRhYbzUa+xuqBmVox8h28ZW7MRUbRBTSmT0+vlCPBvtYSl3Xownw/2DBVps
	 9Nhc3Oc1X27ZsAhkB26yZ2EaGdWB6JmEmLaHEtj7FASOic2JqtYGThAT+pClN2pDQ3sJ2
	 533DbfNh0uYswJl2hi2vxa5WNV6sILVvKzQZW/L+Zl7m27yfK3ZYMyf2br5WKQRJgiPR0
	 BP6cV/Oyl1podqjpp41h4U773YDWE4nbYNOiVSTN/gmdFcACnbXdHNYylmwVM6RktR3bm
	 iuO6W4YFPKqWMeeE9DxWrFWgQPJhi/ynRn4iNadMGTFfpzrDukN/0qf+x9hY58QW92A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794653286;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=ih0/1NciwlkPSH40NFmRHj+H7Yj43A5F4piAAfxz8EU=;
	b=IC9EeiWfCTqq9I/zdg7E1deAh0RmQnkMfmP9GdWdRKnNwnOdmE0gwcdZtrPm9Uamo6Ex
	 BESPifRvTiS/DrlgZygKIFLPJm1S02hjzjvE9rgyp4tUAV7Rlyw5erRXQ7p5lmPQx3Bjb
	 +nBq3sJBf1T+tpv19Gb2cDrKBOeVcDJLdnmcHxOVMWAp5fzJvNhLbUBQ3bZRHVS+rbQnC
	 vd/7XiJAQeDEJwkDempnS6JXQy+VkQ7riqFTIIclOSqSisyQyg8xq1IWEMDC7nRR23rIh
	 7AwBKFMoRCzeA4Hr7a8VdKbqak6+6abHXkFfCye7dhJJiZUkQ091oFgj9J/2Gx8tq1g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Px2WgifG;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0377A60A262E;
	Sat, 14 Nov 2026 10:48:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Px2WgifG
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 353BF1F00ADB;
	Sat, 14 Nov 2026 10:48:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794653285;
	bh=ih0/1NciwlkPSH40NFmRHj+H7Yj43A5F4piAAfxz8EU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Px2WgifG9tt2qa2KP702zDUxihDFuVOpxLXWLK8bZa+qbOSoYvhIT62/LM0tGjJ11
	 Um1L2TAcpXZ5HM1R7W7QHkCRBI4vl5mLaV9jpPcLCl4WGXBBjFz2sXLcONmAO5xKZv
	 JBsVUey85WGetnGnpNXXkEF7Kqbr0AUHDFo5Fo2GdIRuQ73sSxgo4z7SwJzRjd3CBY
	 568Fr2L/VfmsMDIshw1zsjAx1DYodHk/PfrCC8ro08VsW3MPIBrg4H1PIJLwtLOmxH
	 /zHrG0I3msJipOdLMgRBaCooVmi9QX1nFgCVWNPH/U0uk4UoFAbNf/g68NZ5Oq1Vqw
	 XoKSM2eKnXH+w==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 11:47:12 +0100
Subject: [PATCH 05/12] target: fileio: take freeze protection for aio
 writes
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
Message-Id: <20261114-work-fs-frozen_writes-v1-5-f5ae61c898b1@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=4196; i=brauner@kernel.org;
 h=from:subject:message-id; bh=HIFHY9G/S2mY7itWBgazKm1UslrnMns868wvaV80+YI=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9sHHqyrCoYtzSIJv9JehPk5dpQZ57WPdep6tOLwtl5
 ZdGrd/ZUcrCIMbFICumyOLQbhIut5ynYrNRpgbMHFYmkCEMXJwCMJGkLQz/vcQO7JsfqejBf2t5
 z7591WV/72R2vzhiuXfBqfvbz+VYdDL8Fc3qbDixUq02TvumCeulsvJPe0TVCzNeRLOUNzgFdEq
 zAAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

With fd_async_io=1 the fileio backend calls ->write_iter() of the
backing file without taking freeze protection. So a write to the LUN
goes through to a filesystem that is frozen. With the backing file on
ext4:

  WARNING: fs/ext4/ext4_jbd2.c:90 at ext4_journal_check_start+0x1f6/0x2d0, CPU#0: kworker/0:2/40
  Workqueue: target_submission target_queued_submit_work
  Call Trace:
   <TASK>
   __ext4_journal_start_sb+0x7a/0x470
   ext4_dirty_inode+0xa1/0x120
   __mark_inode_dirty+0x154/0x1110
   file_update_time_flags+0x3ab/0x4b0
   ext4_file_write_iter+0xf11/0x1570
   fd_execute_rw+0xb01/0x1700
   __target_execute_cmd+0x53/0x190
   tcm_loop_write_pending+0xe/0x20
   transport_generic_new_cmd+0x612/0xdb0
   __target_submit+0x12c/0x380
   target_queued_submit_work+0x73/0x270
   process_one_work+0x946/0x1820
   worker_thread+0x4f1/0xd60
   kthread+0x364/0x460
   ret_from_fork+0x525/0x770
   ret_from_fork_asm+0x1a/0x30
   </TASK>

The synchronous path doesn't have that problem. vfs_iter_write() takes
freeze protection.

Take freeze protection around the write. A write that wasn't queued
drops it right away. A write that was queued drops it in the completion
callback.

Note that the completion callback can't tell from the command whether
it completes a write. COMPARE AND WRITE is a write but reads the data to
compare first. So remember the direction of the I/O in the aio command.

Fixes: 769031c92c8b ("scsi: target: target/file: Add support of direct and async I/O")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/target/target_core_file.c | 31 +++++++++++++++++++++++--------
 1 file changed, 23 insertions(+), 8 deletions(-)

diff --git a/drivers/target/target_core_file.c b/drivers/target/target_core_file.c
index 4dace29b6d662..27b266a092b18 100644
--- a/drivers/target/target_core_file.c
+++ b/drivers/target/target_core_file.c
@@ -246,6 +246,7 @@ struct target_core_file_cmd {
 	unsigned long	len;
 	struct se_cmd	*cmd;
 	refcount_t	ref;
+	bool		is_write;
 	struct kiocb	iocb;
 	struct bio_vec	bvecs[];
 };
@@ -256,12 +257,8 @@ static void cmd_rw_aio_put(struct target_core_file_cmd *cmd)
 		kfree(cmd);
 }
 
-static void cmd_rw_aio_complete(struct kiocb *iocb, long ret)
+static void cmd_rw_aio_done(struct target_core_file_cmd *cmd, long ret)
 {
-	struct target_core_file_cmd *cmd;
-
-	cmd = container_of(iocb, struct target_core_file_cmd, iocb);
-
 	if (ret != cmd->len)
 		target_complete_cmd(cmd->cmd, SAM_STAT_CHECK_CONDITION);
 	else
@@ -270,6 +267,19 @@ static void cmd_rw_aio_complete(struct kiocb *iocb, long ret)
 	cmd_rw_aio_put(cmd);
 }
 
+static void cmd_rw_aio_complete(struct kiocb *iocb, long ret)
+{
+	struct target_core_file_cmd *cmd;
+
+	cmd = container_of(iocb, struct target_core_file_cmd, iocb);
+
+	/* A queued write still holds freeze protection. */
+	if (cmd->is_write)
+		kiocb_end_write(iocb);
+
+	cmd_rw_aio_done(cmd, ret);
+}
+
 static sense_reason_t
 fd_execute_rw_aio(struct se_cmd *cmd, struct scatterlist *sgl, u32 sgl_nents,
 	      enum dma_data_direction data_direction)
@@ -300,6 +310,7 @@ fd_execute_rw_aio(struct se_cmd *cmd, struct scatterlist *sgl, u32 sgl_nents,
 	refcount_set(&aio_cmd->ref, 2);
 	aio_cmd->cmd = cmd;
 	aio_cmd->len = len;
+	aio_cmd->is_write = is_write;
 	aio_cmd->iocb.ki_pos = cmd->t_task_lba * dev->dev_attrib.block_size;
 	aio_cmd->iocb.ki_filp = file;
 	aio_cmd->iocb.ki_complete = cmd_rw_aio_complete;
@@ -308,13 +319,17 @@ fd_execute_rw_aio(struct se_cmd *cmd, struct scatterlist *sgl, u32 sgl_nents,
 	if (is_write && (cmd->se_cmd_flags & SCF_FUA))
 		aio_cmd->iocb.ki_flags |= IOCB_DSYNC;
 
-	if (is_write)
+	if (is_write) {
+		kiocb_start_write(&aio_cmd->iocb);
 		ret = file->f_op->write_iter(&aio_cmd->iocb, &iter);
-	else
+		if (ret != -EIOCBQUEUED)
+			kiocb_end_write(&aio_cmd->iocb);
+	} else {
 		ret = file->f_op->read_iter(&aio_cmd->iocb, &iter);
+	}
 
 	if (ret != -EIOCBQUEUED)
-		cmd_rw_aio_complete(&aio_cmd->iocb, ret);
+		cmd_rw_aio_done(aio_cmd, ret);
 	cmd_rw_aio_put(aio_cmd);
 
 	return 0;

-- 
2.53.0

