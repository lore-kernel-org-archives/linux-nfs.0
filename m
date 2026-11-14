Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794653282;
	b=vj75NtTokj757EMtKH1hhlqjr50ofBOBAGwvzZIizwENxqgM2K1WH8TbiisFJzrtXP2l
	 AirO76MwmKew+a5TFkKAGpzH1266w8y07/X0DifTJYzw04B2sdbS98VJLL/xIHsXTQWnJ
	 krtq35oUtSA41vLzgDTaNWlF+avOPZx0VIsK3kfPu+S3JZfM0hh+MSHnY5X0BqRJsad3u
	 X3IwjXD+MLMBp5mxkYs2pTnsOgOLcgz0ufbimqmp48erAvU6zeKugvoHyQn2NtlcRvvXP
	 serYlyMsq88uw+wNXE8U4y4t85xw5xF+6+KTYdCdczAMaPl/S9hZJdck6elegnvbdkA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794653282;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=z7+ZOGPY2zekwXP8WfcsjECVMTd7aBpsMauFGn8HuGk=;
	b=gsBeR33nGLdy6rKeVsrtvwaR/T8uNMjlLF+M8dK/Lrn2ArrPcjpUR1Vb2pUyTUARNc33
	 UWYeRLq0QIjECL0f3o/x4caePdfDwoshxOxdGroFA0ESOTq6fy5CydxoUBNeT4EYNmSA6
	 nIoB6BaacaTuR8VAGa3VDJWbAqh8SQ5fxcp8KewhCd7dZ6vtp2dP4ifBTszEIoPUh2/10
	 a88cp6N9GOCyKJPjRRpzFz1GHFeRdhdoQgnkBYJ5txm9oVIeXukfFy/8LtpbTSjdGmn53
	 Qorrm5KevP0DEFzqdopGDaXwa2qzoIJs+/0xtv0B3usyyhK94272ywdfsyjsinKoaTQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WP9avIbJ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 26DB3606CE2A;
	Sat, 14 Nov 2026 10:48:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WP9avIbJ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 57E8B1F000C5;
	Sat, 14 Nov 2026 10:47:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794653281;
	bh=z7+ZOGPY2zekwXP8WfcsjECVMTd7aBpsMauFGn8HuGk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=WP9avIbJq6H00r3u1hGxtWvWcrCysrUF3w5YsZlV0n0dOSJC726WmO+7NZ00MaXGG
	 dioJP7Mcm2oVvoFujECZbIxYLpUk4nBnXAZrBGIQKQQt/eE/YAQoSCzLbmaS4oxkG4
	 djFAiqikxPEhZQ1eWvGalXgnaff08xJNGik/kotmPZ2EoDiWgHIZbQwoRT3XqbiuMG
	 fXXu91+tBvXL4ruWm3VqCc1OMwv3QRp/iq7O+QnMyJtWo/LAZTOaBYcFtkARsZrBBq
	 sDc5T4A45SbummM5eglFpNziF7hHg1DH9AYmxnlAK1OoN9MaS31w9/B5WnrZqg7+Ec
	 /NpKVOGl3wnfA==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 11:47:11 +0100
Subject: [PATCH 04/12] target: fileio: don't free the aio command under the
 filesystem
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
Message-Id: <20261114-work-fs-frozen_writes-v1-4-f5ae61c898b1@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3653; i=brauner@kernel.org;
 h=from:subject:message-id; bh=4XIxTnp3VDptPpFeG4yBe+IjV6xeM/LkgZ2az3nmBSU=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9sHFc7ifdfTxpyYqlSknMZn7T2TatfLVtZ0j8jdzJs
 tkbxbaIdpSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEyEIYiRYeLZdZUzzdUFljMk
 MF+4uLhwZ1btDrUvk0OsKn4bnd/6YDPDf2ftood7m+WF3/375bk86dXsnhP3C4Xnq8zbGz6N3eG
 MFQMA
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
command until the I/O is submitted.

Fixes: 769031c92c8b ("scsi: target: target/file: Add support of direct and async I/O")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/target/target_core_file.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/target/target_core_file.c b/drivers/target/target_core_file.c
index ab9824a4852f1..4dace29b6d662 100644
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
@@ -244,10 +245,17 @@ static void fd_destroy_device(struct se_device *dev)
 struct target_core_file_cmd {
 	unsigned long	len;
 	struct se_cmd	*cmd;
+	refcount_t	ref;
 	struct kiocb	iocb;
 	struct bio_vec	bvecs[];
 };
 
+static void cmd_rw_aio_put(struct target_core_file_cmd *cmd)
+{
+	if (refcount_dec_and_test(&cmd->ref))
+		kfree(cmd);
+}
+
 static void cmd_rw_aio_complete(struct kiocb *iocb, long ret)
 {
 	struct target_core_file_cmd *cmd;
@@ -259,7 +267,7 @@ static void cmd_rw_aio_complete(struct kiocb *iocb, long ret)
 	else
 		target_complete_cmd(cmd->cmd, SAM_STAT_GOOD);
 
-	kfree(cmd);
+	cmd_rw_aio_put(cmd);
 }
 
 static sense_reason_t
@@ -288,6 +296,8 @@ fd_execute_rw_aio(struct se_cmd *cmd, struct scatterlist *sgl, u32 sgl_nents,
 
 	iov_iter_bvec(&iter, is_write, aio_cmd->bvecs, sgl_nents, len);
 
+	/* The filesystem may still use the kiocb after it queued the I/O. */
+	refcount_set(&aio_cmd->ref, 2);
 	aio_cmd->cmd = cmd;
 	aio_cmd->len = len;
 	aio_cmd->iocb.ki_pos = cmd->t_task_lba * dev->dev_attrib.block_size;
@@ -305,6 +315,7 @@ fd_execute_rw_aio(struct se_cmd *cmd, struct scatterlist *sgl, u32 sgl_nents,
 
 	if (ret != -EIOCBQUEUED)
 		cmd_rw_aio_complete(&aio_cmd->iocb, ret);
+	cmd_rw_aio_put(aio_cmd);
 
 	return 0;
 }

-- 
2.53.0

