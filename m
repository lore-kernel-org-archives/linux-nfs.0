Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794735028;
	b=b/TCEgmp3b8beD8k89ZUpwm9oWCZL1/bRAEkAGfSeWQ2HLrg/3UZPX/l6wom0B0Ynn1R
	 0SWspLz2cpPr1bpAnNxLzwmpY61DqYOgkzT7diN82j9e+dZF/eQaP3qYA3rQFEFPF1RHq
	 5i9zefvHp99ybr0uFpmEJ+A5JYpngfonZrZjJ6og9oRPIP5+3CxKtk+E7rQzO4BXerRT3
	 mcbVBzEYFazT8Pdu8brQ55Ak8h4xo/KX9XhD+lNGSqfSYip7PuieEduD+U5MIbI/9IJRP
	 qmdd3jnSy5YVd3YCjS5UWSJ47AWfr7gAmi2AOJJLE9bvhQtaOCO8g+orr7A72T0t5SQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794735028;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=e7MOyX724bqCWJsCrd4OjXjEcyjDNuCUpHqJ3uJvgjY=;
	b=if4FE9mFZTimctrs8840DtaN3sZa3U65goiDLRxCaxLrrGG05+K09f75mJt1KNYo5vyI
	 O5dCT/Hic+q+T1XD7UCX7MVyAutR5Qc92gulcGwWMERame5Lm15sdIBoPu9nWv3XgVlCs
	 Nnm37prBB4V4Gu7dWMaksZDeerVlIzOl1cG1qE7u348alPfdcZtj2EeyB3Qesf8YS3XEC
	 xmTmLgTQH20wjAr1UXlsImKTO9Rwf5x1WfVbs2Njxbk9fd5fx/HAqdnY+s4gmnMgofWKt
	 gn7NxbV1ReTRxc6Qvb6mIGrj0xk3CrDM3xMqKm+EyCQgLTdSzQpsKz3ngW55UEMxubw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=D4BDbSLF;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6CF2A606A327;
	Sun, 15 Nov 2026 09:30:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=D4BDbSLF
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 926E11F000C4;
	Sun, 15 Nov 2026 09:30:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794735028;
	bh=e7MOyX724bqCWJsCrd4OjXjEcyjDNuCUpHqJ3uJvgjY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=D4BDbSLFVk4e+fV6ihG6kKryjFjt03+TIbG64DUmJoPCcOlP1b9vDrUdSBoHvEXxJ
	 ldj3rhO3iRDntZCKRLkvsUOAmXeS1mHMkR0qC9TiqDgSaT+m9Owk/1bZbmBLJxsQh8
	 PTW4FfSElqmIKtraDSDebgIUuu6ZZR0FCa8QmYQBAfd2LN1q3XSnlHSyVEPHKMl5eJ
	 F533fyUtOVcdvUYNq3jrnkuV3ByRLnh+ry56M4lSxZ6/Hp1rYOL4urCykZ2AAfXMp6
	 K11q3gPNCNfLg9bjJG+AqAl+3I8V2sWY6Pv15+bcu15Ch7utqYTM9Huq11ly4MDsvE
	 LbISVNk4ZZhuw==
Date: Sun, 15 Nov 2026 10:30:22 +0100
From: Christian Brauner <brauner@kernel.org>
To: Jan Kara <jack@suse.cz>
Cc: Shakeel Butt <shakeel.butt@linux.dev>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, io-uring@vger.kernel.org, Christoph Hellwig <hch@lst.de>, 
	linux-block@vger.kernel.org, linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org, 
	target-devel@vger.kernel.org, linux-unionfs@vger.kernel.org, bpf@vger.kernel.org, 
	linux-nfs@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH 04/12] target: fileio: don't free the aio command under
 the filesystem
Message-ID: <20261115-rasch-haltbar-gebrechen-faac5fad7805@brauner>
References: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org>
 <20261114-work-fs-frozen_writes-v1-4-f5ae61c898b1@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20261114-work-fs-frozen_writes-v1-4-f5ae61c898b1@kernel.org>

On Sat, Nov 14, 2026 at 11:47:11AM +0100, Christian Brauner wrote:
> The read completed and freed the command before ext4_dio_read_iter() got
> to file_accessed(iocb->ki_filp).
> 
> Do what loop, zloop and fs/backing-file.c do and hold a reference to the
> command until the I/O is submitted.

As sashiko pointed out (cf. [1]) the completion callback still completes
the command. That drops the LUN reference while ->read_iter() or
->write_iter() may still be running. The device and its backing file
can go away underneath the filesystem. So we must complete the command
on the final put as well. I've folded:

5/12 gets simpler on top of this. kiocb_end_write() just moves into
cmd_rw_aio_complete() which is now called exactly once for every I/O.
I've folded both.

[1]: https://lore.kernel.org/r/sashiko-outbox-214401@kernel.org

-- >8 --
Subject: [PATCH] target: fileio: don't free the aio command under the filesystem

With fd_async_io=1 the fileio backend allocates a command that holds the
kiocb for every read and write and frees it in the completion callback.
Nothing keeps the command alive until ->read_iter() or ->write_iter()
return. But a filesystem may use the kiocb after it queued the I/O. ext4
does that for direct reads:

  BUG: KASAN: slab-use-after-free in ext4_dio_read_iter+0x5e1/0x690
  Workqueue: target_submission target_queued_submit_work
  Call Trace:
   <TASK>
   dump_stack_lvl+0x5d/0x80
   print_report+0x14b/0x4b0
   kasan_report+0x108/0x130
   ext4_dio_read_iter+0x5e1/0x690
   fd_execute_rw+0xd30/0x1700
   __target_execute_cmd+0x53/0x190
   transport_generic_new_cmd+0x65a/0xdb0
   __target_submit+0x12c/0x380
   target_queued_submit_work+0x73/0x270
   process_one_work+0x946/0x1820
   worker_thread+0x4f1/0xd60
   kthread+0x364/0x460
   ret_from_fork+0x525/0x770
   ret_from_fork_asm+0x1a/0x30
   </TASK>

  Allocated by task 59:
   __kmalloc_noprof+0x223/0x830
   fd_execute_rw+0x766/0x1700
   __target_execute_cmd+0x53/0x190
   transport_generic_new_cmd+0x65a/0xdb0
   __target_submit+0x12c/0x380
   target_queued_submit_work+0x73/0x270

  Freed by task 14:
   kfree+0x267/0x6a0
   blk_update_request+0x3f5/0x1260
   blk_mq_end_request+0x59/0x450
   blk_complete_reqs+0xb0/0x130
   handle_softirqs+0x20c/0x860
   run_ksoftirqd+0x31/0x60

The read completed and freed the command before ext4_dio_read_iter() got
to file_accessed(iocb->ki_filp).

Do what loop, zloop and fs/backing-file.c do and hold a reference to the
command until the I/O is submitted. Only complete the target command
when the last reference is dropped as well. Otherwise the command drops
its LUN reference while the filesystem still uses the kiocb and the
device and with it the backing file can go away underneath it.

Fixes: 769031c92c8b ("scsi: target: target/file: Add support of direct and async I/O")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/target/target_core_file.c | 25 +++++++++++++++++++------
 1 file changed, 19 insertions(+), 6 deletions(-)

diff --git a/drivers/target/target_core_file.c b/drivers/target/target_core_file.c
index ab9824a4852f1..4b23fadd7bb88 100644
--- a/drivers/target/target_core_file.c
+++ b/drivers/target/target_core_file.c
@@ -15,6 +15,7 @@
 #include <linux/timer.h>
 #include <linux/blkdev.h>
 #include <linux/slab.h>
+#include <linux/refcount.h>
 #include <linux/spinlock.h>
 #include <linux/module.h>
 #include <linux/vmalloc.h>
@@ -243,25 +244,34 @@ static void fd_destroy_device(struct se_device *dev)
 
 struct target_core_file_cmd {
 	unsigned long	len;
+	long		ret;
 	struct se_cmd	*cmd;
+	refcount_t	ref;
 	struct kiocb	iocb;
 	struct bio_vec	bvecs[];
 };
 
-static void cmd_rw_aio_complete(struct kiocb *iocb, long ret)
+static void cmd_rw_aio_put(struct target_core_file_cmd *cmd)
 {
-	struct target_core_file_cmd *cmd;
-
-	cmd = container_of(iocb, struct target_core_file_cmd, iocb);
+	if (!refcount_dec_and_test(&cmd->ref))
+		return;
 
-	if (ret != cmd->len)
+	if (cmd->ret != cmd->len)
 		target_complete_cmd(cmd->cmd, SAM_STAT_CHECK_CONDITION);
 	else
 		target_complete_cmd(cmd->cmd, SAM_STAT_GOOD);
-
 	kfree(cmd);
 }
 
+static void cmd_rw_aio_complete(struct kiocb *iocb, long ret)
+{
+	struct target_core_file_cmd *cmd;
+
+	cmd = container_of(iocb, struct target_core_file_cmd, iocb);
+	cmd->ret = ret;
+	cmd_rw_aio_put(cmd);
+}
+
 static sense_reason_t
 fd_execute_rw_aio(struct se_cmd *cmd, struct scatterlist *sgl, u32 sgl_nents,
 	      enum dma_data_direction data_direction)
@@ -288,6 +298,8 @@ fd_execute_rw_aio(struct se_cmd *cmd, struct scatterlist *sgl, u32 sgl_nents,
 
 	iov_iter_bvec(&iter, is_write, aio_cmd->bvecs, sgl_nents, len);
 
+	/* The filesystem may still use the kiocb after it queued the I/O. */
+	refcount_set(&aio_cmd->ref, 2);
 	aio_cmd->cmd = cmd;
 	aio_cmd->len = len;
 	aio_cmd->iocb.ki_pos = cmd->t_task_lba * dev->dev_attrib.block_size;
@@ -305,6 +317,7 @@ fd_execute_rw_aio(struct se_cmd *cmd, struct scatterlist *sgl, u32 sgl_nents,
 
 	if (ret != -EIOCBQUEUED)
 		cmd_rw_aio_complete(&aio_cmd->iocb, ret);
+	cmd_rw_aio_put(aio_cmd);
 
 	return 0;
 }

-- 
