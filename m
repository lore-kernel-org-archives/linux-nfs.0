Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827089;
	b=C5op2Qr23+92tIK0wwcYgsT4F6QTrTqmGEW7cl5sgemsBGtnNk4oF7QQoyOMUurG7fxI
	 cPSMumhQg8e7VRcVFx0pppkytIezjgvYYNPwVmVDu7pqXOI0h8OrTwEh/+upGmcO/lEsN
	 J/H9oVsDLBFTcyMuzgdhn3Sncv5vLrGYD/IfjaTo+kdSi5ZA63uFAfJ+s5MdthdaOCgW3
	 XZgJvNei5CWDghHJbu6UkND+y7hYihz0qKX9QJhsDf28EY7yxzvFLKHXA7T7KM1aw9Fau
	 Z3/FbuNIFSlkMHFz+ct2+Jno/U1G24uoGIqfkKOa9lkyv758SP/nfg54i+MouwQo33A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827089;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=rLjMzucVvAg0/2ubS/mq+wqOERAfWvgX+KIv/hkuemY=;
	b=JrNMhl1OMk1X+cAPo0ZBTcO/Iyk9o2X3R4cbB5xeXqJ0UnDCmKPoHFetDMAfx4ciA6u2
	 B+XK/zzt3Z/j0dvgLyWHDNLHCXCToet7Eh5Yj29z+rpEL9NGRrvX9z4N1c5tC38VkCyIg
	 QH5adekJBrv3THnYSjqNTVBOlfQg/uqfsJXSxqXDAEZbZoDEfepuiecPKNKbPMi1fP/F/
	 wgENCYrolfyxzj00ndkJYCiC+KhPk6KHMAkpK0Xo7QNn9RSrAXKSHAg0g7IcDJwHA9RVZ
	 ZCu/MBphY62Qg/EYQV7twnAFC5OQpzDTULYxHz7DHPZ7bx+I7Q3YjG6Vkjq9iU2Oq/g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ehf1KYsa;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B180C60A5BD2;
	Mon, 16 Nov 2026 11:04:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ehf1KYsa
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F00281F000D2;
	Mon, 16 Nov 2026 11:04:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827089;
	bh=rLjMzucVvAg0/2ubS/mq+wqOERAfWvgX+KIv/hkuemY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ehf1KYsaBzcvEZRRn9FVaFqDFmqB0UQ0g1iARuGWtVkKt8d4vqdiKbMEUacE8S6tg
	 ZS+s+sXs0D3y5MI3pqIoktVwqVYEci0dnL6MJ4FLFCDKoHt/RN8XVVhtlWyZMvlS+W
	 PykMOLDUXh7g7a2X3nlZaks4sNuve2SSmwD5VkZ79tMA2w3SwgaQk0heYZYOkZOmpm
	 qQKBTrbyPLe+W8yT7CPCaTJX4nkpbZMg2yvZr4A7OvKQkr971In+xEsBT2EKdfEqSz
	 1Gr3POLxMK33OUFzxEUXZh9hs4dRlTE4B906114LgxJ5/RS52DaZBy/nTHfJWT6pSw
	 iX5m2TBE2RFtg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:03:46 +0100
Subject: [PATCH v2 06/17] target: fileio: don't free the aio command under
 the filesystem
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
Message-Id: <20261116-work-fs-frozen_writes-v2-6-ecc4a2aac40e@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=4336; i=brauner@kernel.org;
 h=from:subject:message-id; bh=3WHrQEBl/d4Gta/2IhTxL7wycPfQZedhBDFwdSyAbEM=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9eqyyWWzZ5+5Lb54u6LVLmVYaZKBlPeNbpXHmrPjX1
 msO186Z2FHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjCRX/WMDPPPPfsgxxOwXSt7
 18Wys0pRvrt2GTAvPLt797nm7smfbmgxMlzI2R1ZUd7iffJ/PndElTbb/fDIE3+jTc0dC8qUlr7
 KYgAA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

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
2.53.0

