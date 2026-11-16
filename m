Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827094;
	b=APH0I/nQutfeiYkpRk6o5/E58T8l3CT/U7ZHMZgf3hjI+vX8Vjx8OkG8FukmMArbZfas
	 GYGj0bFnNBT6YLFpDjbdg7vXG2GY8zHRFaE2mije11Et1rcbI3/skbXrdk6qcYzPULGg1
	 fD+D0aT8vQsJVP7QaHDTTkwqFagMTYxyRXq4RfpZAY0B83TgsZE+Ot5tRUnsL6beRi5S0
	 gm9GpvLXCRWKTIL1+lB+3TfgTSbrXWMR6e1bm4/geAPnRenFYgHipZiW1RC3EjaOWaRbN
	 bLwYp0oqdPOzVaukuHipmUL75lR4sOPJZqySepSmuwgpLeoNbG5R80pJ9/kfXO/O83g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827094;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=CGT6lYWV7+MTFrcd9Hkn4PROzI9r5OHEQYJ/85o2rx4=;
	b=euhg0umWNYxJsBUz5SBEZJXDDwoEQyLZOrsEO1Lp9rfq+Z0rRvRlVvfabIKgj5jAHVd7
	 5uW2yE9c38v9XQAsUGfMBo1AskUfyzaGE6rawFV/oveONQoAD1EFESlRsj5KuMzZG7H4i
	 V4nNktnQGCoU3YDa9PT2dq4AIrEayZmHFUC+jQ8OgtnjD/TYujatn7GFXmED08SGBgw97
	 wqwr9FVBVN6STdytInf5uL45491fspYKMT20Jp8u+jALZvIxGadFA39g8xkLpX0qqb+Ij
	 JCTF99pcsIJW4Qp6ynmXxY4W0bW6rzqKBmvv9JhVUZf7nKS70gCxPQJtYfknB9JHAZA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YrXKRoj7;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1A429606A8A0;
	Mon, 16 Nov 2026 11:04:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YrXKRoj7
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 13EAD1F000D3;
	Mon, 16 Nov 2026 11:04:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827093;
	bh=CGT6lYWV7+MTFrcd9Hkn4PROzI9r5OHEQYJ/85o2rx4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=YrXKRoj7hYn2+ZjIVHE1rFDcotZKzJGWV+gKQ6yybnV0zsnhl0EdVnEgsaxFR4vz6
	 v5Fk+DSF36PyDuzTgAAjNYwVOo4qsw7y9UF5g9GZTDM6MJPgp2mNeDYnNDQSTxdfaP
	 9LNNLGe1QXYP2BMesvZ7a049fB7AMjcJ/h+/wRx/y70ECT8kdyQw5kBx+KswtTfUDS
	 PBrr48HlhbF5Ehtm+4yZHxsyzRHSBcwIlBO7Ot9/Pz8puLYygyWBrCRbzm4/G9k/uQ
	 31fHO5+9WfinhzkFbIp1gPtrH4Q6ZRJye+Z2q1Ls5/LmVAm+w0nxbu7wT2dDSd4bGo
	 kg8Hw+7m3Paig==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:03:47 +0100
Subject: [PATCH v2 07/17] target: fileio: take freeze protection for aio
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
Message-Id: <20261116-work-fs-frozen_writes-v2-7-ecc4a2aac40e@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2554; i=brauner@kernel.org;
 h=from:subject:message-id; bh=odczWWAJfAcRe3p+krtaO8nSx1NU1nb1y8bUX3hioHw=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9eqy6Zcusfy+2fC699Tfy0oulb9drKbn+jX28cU5vB
 kOY0s9TZztKWRjEuBhkxRRZHNpNwuWW81RsNsrUgJnDygQyhIGLUwAmErKWkeHqptw+qyMfJ73Z
 xZz5ffPTKibBHNv96Z/XTVm0///tFiZRhv9OF1qF/dS/ONQIvfWyDeHlOt3mtXOa6VEXjtsaj69
 +vs4EAA==
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

Submit writes with kiocb_write_iter() and drop freeze protection in the
completion callback with kiocb_end_write_iter().

Note that the completion callback couldn't tell from the command whether
it completes a write anyway. COMPARE AND WRITE is a write but reads the
data to compare first. kiocb_write_iter() marks the kiocb with
IOCB_WRITE so the callback doesn't need to know.

Fixes: 769031c92c8b ("scsi: target: target/file: Add support of direct and async I/O")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/target/target_core_file.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/target/target_core_file.c b/drivers/target/target_core_file.c
index 4b23fadd7bb88..e8a44ddf6f5c9 100644
--- a/drivers/target/target_core_file.c
+++ b/drivers/target/target_core_file.c
@@ -268,6 +268,7 @@ static void cmd_rw_aio_complete(struct kiocb *iocb, long ret)
 	struct target_core_file_cmd *cmd;
 
 	cmd = container_of(iocb, struct target_core_file_cmd, iocb);
+	kiocb_end_write_iter(iocb);
 	cmd->ret = ret;
 	cmd_rw_aio_put(cmd);
 }
@@ -311,7 +312,7 @@ fd_execute_rw_aio(struct se_cmd *cmd, struct scatterlist *sgl, u32 sgl_nents,
 		aio_cmd->iocb.ki_flags |= IOCB_DSYNC;
 
 	if (is_write)
-		ret = file->f_op->write_iter(&aio_cmd->iocb, &iter);
+		ret = kiocb_write_iter(&aio_cmd->iocb, &iter);
 	else
 		ret = file->f_op->read_iter(&aio_cmd->iocb, &iter);
 

-- 
2.53.0

