Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827081;
	b=IscuBtHFBDRhLR7RnnEjjFDEP7S1RdeiZ8Z4/trWoFiEie/GzGEOxQPem7ME2pDgGGC4
	 PXiLwkFBIkVU0o6+h+5Fuw8L8BoM6Zkray+toTJfDJZzBi6zXKiih/TEiwB/i/PTW3wVw
	 G0rdHR8rOO6O6DojUB5wAH49gz5IkLX8XL/uAErrjtJD4ha6+5kBSD6g93BKPE48wgsXt
	 C5h10eDhTtvMhfUhH1FuqCNY1fmevxOhyeQ1PcOB4zy3TLPcEv3RiYh67yXROil/75TWl
	 ZjLXdH0eRYZc7seM4EdoWkDfAC0Huxcy7cAHU7CWQTv7RxxD21bXJl6O0qQKZjzGYcw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827081;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=EWEQe50Q7bYbdLpYkYQap52GI3LJt8CnLN09OmwuI1w=;
	b=sv9XpZTvbrYfxY1eWG/wHiJcOlzAfa6EWPtezDZVtIotq1YFeW1YhjFeUvsId5EJYYjf
	 LnAEj1KtntLm2y6VEyuKjM25spT55IabZcSL/xhrW/Cd+UMYuDZGSO3IKqahxwZi8ilQz
	 cjeTa5RbSVP3Kt7/Yrh4vhcxzWRBsm06C9F5MP5ss0RdAIkj83E6Ln4rCwhrm7v+SB++Q
	 SbDDoR9q0TZO5JwU+P/VnlFPkd0HZg4BtjuV1S0PkfmXJu/CEUSM4OtJd7cFW69I9yUpA
	 YXzK5HBZj+cTc3XgRe38ckvFY/vT43+013LrC7SV1t/UHyIm5ngwLObXO/TA43vGx4Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PafvJE3d;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9E89A606A88F;
	Mon, 16 Nov 2026 11:04:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PafvJE3d
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ADBF11F000C7;
	Mon, 16 Nov 2026 11:04:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827081;
	bh=EWEQe50Q7bYbdLpYkYQap52GI3LJt8CnLN09OmwuI1w=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=PafvJE3dQs6OTj/LdjhOhzqOr8zu4Rs9a7Ti00DrfRgIuCxFWcDacjwO97FZyLBpA
	 jYuevIl9DI19bSn0Dks4p3CjhVQmBu6Z+C7G8ENMP1klGGbVePVvTGDHCDF7A+ebFP
	 XtfrWPtHqIXMmG/6Kj0eF8f//xIYX+bNePhsW8jQoTvZe6wjtCrp7lhxsxP1u/ZMD9
	 tCLsB93fgShCrx0f7WKCB7/FLREZcuLsc4J2cx6WRMz1EgSjBwk2VCNISg3+w/XOaI
	 fywy9B8wP7688ExWLyowqIdnXq89PA9+A4QMQLzwFt6nlWWDckBl2QObVHEs1Siq9V
	 wUyIGDmt6hkHg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:03:44 +0100
Subject: [PATCH v2 04/17] zloop: take freeze protection for writes
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
Message-Id: <20261116-work-fs-frozen_writes-v2-4-ecc4a2aac40e@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2086; i=brauner@kernel.org;
 h=from:subject:message-id; bh=Stx5DC9HTEHrmNCMj043d8T1E73IV+TuEjjoB5nUMbU=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9eqwkwjJ7qdD/d/tmPhEu3TXrtdNe/Y6eqY90e8UC1
 MtfOqbkdJSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEzEOJyRYUZe6+87LsIq6vVh
 2wTC/brNP3r6LxPumf/tZGXY86+iIowMd0+sVF+47/Yzxxfbm9SmN0lN/u6uMlfrXojIv7uPXb3
 l+QA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

zloop calls ->write_iter() of the zone files without taking freeze
protection. So a write to a zloop device goes through to a filesystem
that is frozen. With the zone files on ext4:

  WARNING: fs/ext4/ext4_jbd2.c:90 at ext4_journal_check_start+0x1f6/0x2d0, CPU#3: kworker/u16:4/507
  Workqueue: zloop0 zloop_cmd_workfn
  Call Trace:
   <TASK>
   __ext4_journal_start_sb+0x7a/0x470
   ext4_dirty_inode+0xa1/0x120
   __mark_inode_dirty+0x154/0x1110
   file_update_time_flags+0x3ab/0x4b0
   ext4_buffered_write_iter+0x143/0x630
   ext4_file_write_iter+0x7b9/0x1570
   zloop_do_rw+0x8ac/0xe10
   zloop_cmd_workfn+0xac5/0x1ff0
   process_one_work+0x946/0x1820
   worker_thread+0x4f1/0xd60
   kthread+0x364/0x460
   ret_from_fork+0x525/0x770
   ret_from_fork_asm+0x1a/0x30
   </TASK>

Submit writes with kiocb_write_iter() and drop freeze protection in the
completion callback with kiocb_end_write_iter(). zloop_rw() also calls
the completion callback for I/O that wasn't queued or that failed before
it was submitted. kiocb_end_write_iter() does nothing for these.

Fixes: eb0570c7df23 ("block: new zoned loop block device driver")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/block/zloop.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/block/zloop.c b/drivers/block/zloop.c
index 65634a39b0bfc..76d54c9b89c0b 100644
--- a/drivers/block/zloop.c
+++ b/drivers/block/zloop.c
@@ -514,6 +514,7 @@ static void zloop_rw_complete(struct kiocb *iocb, long ret)
 {
 	struct zloop_cmd *cmd = container_of(iocb, struct zloop_cmd, iocb);
 
+	kiocb_end_write_iter(iocb);
 	cmd->ret = ret;
 	zloop_put_cmd(cmd);
 }
@@ -567,7 +568,7 @@ static int zloop_do_rw(struct zloop_cmd *cmd)
 	cmd->iocb.ki_ioprio = IOPRIO_PRIO_VALUE(IOPRIO_CLASS_NONE, 0);
 
 	if (rw == ITER_SOURCE)
-		return zone->file->f_op->write_iter(&cmd->iocb, &iter);
+		return kiocb_write_iter(&cmd->iocb, &iter);
 	return zone->file->f_op->read_iter(&cmd->iocb, &iter);
 }
 

-- 
2.53.0

