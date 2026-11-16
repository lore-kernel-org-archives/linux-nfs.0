Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827106;
	b=GF/UClb3ciOnh5J58qdsdPyprfLY/gn3xgfVtS/odmhCu5KLiKw29ckjdecOj2F5HzvN
	 9bY/+9RJpmD/E7oHw13wafMlrn5HtjlsFOGMpTs/5YbCv5ecFV0IalvKRaRzTq+iKBEGY
	 BitCx3PjPECa/vQx4jWycrFwcRsU0Jh+beiBSsh2Wehiql1Gu3gvl/m3b31Y+3fe+rog9
	 l6XBD0SFvDcq9lzTf2z2Fhr8H0VQg71STRDuBroMiMV+1yi4EwghyvfLk6WaDFLr0alTx
	 VJJR2DxvziyQ4OlWyxGCOHhKTc4G4bnIuaN3b0RaEKLNOt/lChSpCUB751tyqhI5usA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827106;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Wy/trncCKOEfTT0E9AIfIq9GDwPb+xtZOWXOFtUVT80=;
	b=oENSR14vxHzgpZ2WqlYJf7qqof8qb05JykfARTT/Mns8KC6VB/zV/4KrfpNZ2gY6X1UV
	 RYTI5oxQr96vfKse+NWniOnUyQTAn5FZkAcFZNsTtJ94nxTndws11AprKzfQ4rPwO6Vts
	 8K0khsPDazz52HkIkDzIg6VgitUXPEoyDKr44ujqzVkpDVl6AYd9UqXypRgnUR8CqQiEa
	 vCSvfdXKua2I2zrnfMz68udj+mewkJ6fBNxtKeuY5yxipbIc66BkxobljYHgoHDoEk4ti
	 wDWEEhwntZSkuq3MxgGcNge/uF1KsiOvf1rddsjXbJ9fZKZgUXy2hYByYhP+gdnXu5Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CcIB4Hbm;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7A945606A89B;
	Mon, 16 Nov 2026 11:05:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CcIB4Hbm
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 90EA61F000C6;
	Mon, 16 Nov 2026 11:05:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827106;
	bh=Wy/trncCKOEfTT0E9AIfIq9GDwPb+xtZOWXOFtUVT80=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=CcIB4HbmBgYc5EEMXgIRtc19Qwnoi6JLiX/zxxMppwz5egObZb/cjCtm2SIxhU1RT
	 i4c38dgiLMKZpLpd6ICIjf9A/VjTxGnwiv6t9rFiEt/zS+MKF+DRInOfOJcJErkv+Y
	 sKipY2C2Y+xAXP7XwccmsI0YdmD9ZZuSHkIEjX5M6kQ4c/qUdEQ9wgsck4nOWm+I53
	 xiDlNaNQcqE8XLjMzEKAsejvUuii1rayUUGPiMA228x8Cga1/3Zi5DKOS8r6RB4ntr
	 AqDbxmGDFarP8m3AGeXA1KKI4Wk/W+PJfLQotnGU0nS1i2zYERCLihGJs1HHXPksgw
	 gnKOpLRWaBT7A==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:03:50 +0100
Subject: [PATCH v2 10/17] target: fileio: take freeze protection for unmap
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
Message-Id: <20261116-work-fs-frozen_writes-v2-10-ecc4a2aac40e@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2121; i=brauner@kernel.org;
 h=from:subject:message-id; bh=l/Efbc9gKVczuM0MtkeYpCTx8c98kWfbXxfwlfze3Hc=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9eqwplyRmco/FgOXWPyUzSalfLs83zW8pOKNyhf9X2
 JF5Txc87ChlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZhIZQ0jw6wjtxb5J/4UOiRx
 aoK7XoeEnMd2qzyftgJxu7Pd+x0mPGf4Z5Nnvf7oChOPI7vZ/PTVkm02GC07t2zHU4dtwb4fax2
 3sAIA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

UNMAP and WRITE SAME with UNMAP=1 end up in fd_execute_unmap() which
calls ->fallocate() of the backing file directly. That skips the freeze
protection vfs_fallocate() would have taken. So they go straight
through to a filesystem that is frozen, with and without fd_async_io.
With the backing file on ext4:

  WARNING: fs/ext4/ext4_jbd2.c:90 at ext4_journal_check_start+0x1f6/0x2d0, CPU#1: kworker/1:1/50
  Workqueue: target_submission target_queued_submit_work
  Call Trace:
   <TASK>
   __ext4_journal_start_sb+0x7a/0x470
   ext4_dirty_inode+0xa1/0x120
   __mark_inode_dirty+0x154/0x1110
   file_update_time_flags+0x3ab/0x4b0
   ext4_fallocate+0x286/0x3440
   fd_execute_unmap+0x1eb/0x6e0
   sbc_execute_write_same_unmap+0x93/0xe0
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

Take freeze protection around ->fallocate() like vfs_fallocate() does.

Fixes: 70d3ae5c8075 ("target/file: Add WRITE_SAME w/ UNMAP=1 emulation support")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/target/target_core_file.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/target/target_core_file.c b/drivers/target/target_core_file.c
index e8a44ddf6f5c9..5600ef7bbdbb6 100644
--- a/drivers/target/target_core_file.c
+++ b/drivers/target/target_core_file.c
@@ -584,7 +584,8 @@ fd_execute_unmap(struct se_cmd *cmd, sector_t lba, sector_t nolb)
 		if (!file->f_op->fallocate)
 			return TCM_LOGICAL_UNIT_COMMUNICATION_FAILURE;
 
-		ret = file->f_op->fallocate(file, mode, pos, len);
+		scoped_guard(file_write, file)
+			ret = file->f_op->fallocate(file, mode, pos, len);
 		if (ret < 0) {
 			pr_warn("FILEIO: fallocate() failed: %d\n", ret);
 			return TCM_LOGICAL_UNIT_COMMUNICATION_FAILURE;

-- 
2.53.0

