Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827086;
	b=UImFe2C4AkRH7+oOaBj0Q7caGgWozsBhhHO0G0pkFAXpp0aiJfNaR/rmjjzAJkouaZ8u
	 QTSl1KZcURGl8EHlnymXMXhyun45tE8KwXq5muE2WcE/pF/4qFGrUUK+O6ILCPUvWBb5N
	 GQg8jw9eKysLthPIe52n10RnMS1OlcvKk5t/yvj6p58q3t7+RaYuzlntSCono2BRI0efZ
	 XeLxvbgYIWBeHUb1xnUieHmUmaP3NdRMgSWma2w6aT5SQSiS4QBeyzE7Kr5nKOSC7NlyD
	 1tojKq8OpNWIiP7T+FW2reQ/DpIadHrfPP44qEPVNao6WOR4i4+sKrfw48hahCLbUsA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827086;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=OMpbaKeBI5L8FkQMFkb29nIbiRMMLHZJVFaXBaeGePY=;
	b=yzXCfFvwH10WTlABdGC+MflwIJdyxeUBUcKlBx9eqHO5cZAg1M16FlWbXcChfCEcSfra
	 hnDWx4VY+0fbMz1sDBL1EyyoJ9DxO8HBM2tbnC5ZZkvNaNo+/2GorLMzt3K9NFOq+MD+3
	 EfjxTKYU0nO8ipHw+j3HUvARqOtu8uXtVv7XNit7iMlKJqjN8sl7LiU9rOqsFFkT2d0aC
	 rahKzv02Wgp584zrlnrkdfGuDLZW/tOuAlMfLHXewawPx9oYoqy0yaot28kiMYty0H1k4
	 lu8OtGFE/8kHumQk6TxzpA17ZZWlS1F5tNrj9HGnKB+SE+xK1cLztH0xHKu6I/XRY+A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lFoF9CPD;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E5147606A8A0;
	Mon, 16 Nov 2026 11:04:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lFoF9CPD
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D8CBE1F000C6;
	Mon, 16 Nov 2026 11:04:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827085;
	bh=OMpbaKeBI5L8FkQMFkb29nIbiRMMLHZJVFaXBaeGePY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=lFoF9CPDIGkEgE25xUKw49hKyTdiEdYFNOZwdeTj9J1SmGmb1oBWPfrEdNrsdRUjr
	 fDD756qS381VooOpLvccqbSm7AKZizYAZ0ebR8Q9x5DioQoI+Q3/CI1opLJbIGFE7d
	 ATVVSMEU/CXI97Q25AHV4on9hhZfWHB6W16FZDBCuVqa3IyKQxLNISU5/a8Ctu+xzR
	 d8uzzIVlg/bHiGqBodpWCTGsBaED6nAN2mLC0iWnlhIEactj5G+QVd+QsWU9ZgPOXm
	 KtxN7U5x7YL2Z7gQX1Yd14LK5Vf+xRtGYFEu3uINf/LyEVF/M7E7nQxd7YWlZZ3nRt
	 /oirxNPxJpwSA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:03:45 +0100
Subject: [PATCH v2 05/17] nvmet: take freeze protection for writes to files
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
Message-Id: <20261116-work-fs-frozen_writes-v2-5-ecc4a2aac40e@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3831; i=brauner@kernel.org;
 h=from:subject:message-id; bh=J2QFKyeHAJBlCVahOl+cM3lAV6ZnVM2+Fv27RvOSKsI=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9eqz8y7DGxF8miuE4u79doFPtDLO4a0YNEnWHTKZbZ
 lsUiTp0lLIwiHExyIopsji0m4TLLeep2GyUqQEzh5UJZAgDF6cATMRyNSPDjf57PRkpAe+2bXLr
 Z1j/+XB6d2mC0b2txkdZg9kdBXtZGBl2dDCd8dj38tuuO3tqvTOfTfl+PFOh9PEKvWObzots0z7
 HAwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

The file backend calls ->write_iter() of the backing file without
taking freeze protection. So a write to a namespace goes through to a
filesystem that is frozen. With the backing file on ext4 and
buffered_io:

  WARNING: fs/ext4/ext4_jbd2.c:90 at ext4_journal_check_start+0x1f6/0x2d0, CPU#1: kworker/1:1/56
  Workqueue: nvmet-buffered-io-wq nvmet_file_buffered_io_work
  Call Trace:
   <TASK>
   __ext4_journal_start_sb+0x7a/0x470
   ext4_dirty_inode+0xa1/0x120
   __mark_inode_dirty+0x154/0x1110
   file_update_time_flags+0x3ab/0x4b0
   ext4_buffered_write_iter+0x143/0x630
   ext4_file_write_iter+0x7b9/0x1570
   nvmet_file_submit_bvec+0x2e7/0x590
   nvmet_file_execute_io+0x460/0x830
   process_one_work+0x946/0x1820
   worker_thread+0x4f1/0xd60
   kthread+0x364/0x460
   ret_from_fork+0x525/0x770
   ret_from_fork_asm+0x1a/0x30
   </TASK>

The same happens with direct I/O.

Submit writes with kiocb_write_iter() and drop freeze protection in the
completion callback with kiocb_end_write_iter(). nvmet_file_io_done() is
also called for I/O that wasn't queued and for I/O that failed before
the kiocb was even set up. So queued I/O gets its own callback.

Note that buffered I/O is tried with IOCB_NOWAIT first. That attempt
must not wait until the filesystem is thawed. kiocb_write_iter() only
tries to get freeze protection then and fails with -EAGAIN otherwise.
The write is then retried from the workqueue like any other write that
would have blocked.

Fixes: d5eff33ee6f8 ("nvmet: add simple file backed ns support")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/nvme/target/io-cmd-file.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/nvme/target/io-cmd-file.c b/drivers/nvme/target/io-cmd-file.c
index 695963dd932ee..8f97dc597c038 100644
--- a/drivers/nvme/target/io-cmd-file.c
+++ b/drivers/nvme/target/io-cmd-file.c
@@ -77,27 +77,27 @@ static ssize_t nvmet_file_submit_bvec(struct nvmet_req *req, loff_t pos,
 		unsigned long nr_segs, size_t count, int ki_flags)
 {
 	struct kiocb *iocb = &req->f.iocb;
-	ssize_t (*call_iter)(struct kiocb *iocb, struct iov_iter *iter);
+	struct file *file = req->ns->file;
 	struct iov_iter iter;
 	int rw;
 
 	if (req->cmd->rw.opcode == nvme_cmd_write) {
 		if (req->cmd->rw.control & cpu_to_le16(NVME_RW_FUA))
 			ki_flags |= IOCB_DSYNC;
-		call_iter = req->ns->file->f_op->write_iter;
 		rw = ITER_SOURCE;
 	} else {
-		call_iter = req->ns->file->f_op->read_iter;
 		rw = ITER_DEST;
 	}
 
 	iov_iter_bvec(&iter, rw, req->f.bvec, nr_segs, count);
 
 	iocb->ki_pos = pos;
-	iocb->ki_filp = req->ns->file;
-	iocb->ki_flags = ki_flags | iocb->ki_filp->f_iocb_flags;
+	iocb->ki_filp = file;
+	iocb->ki_flags = ki_flags | file->f_iocb_flags;
 
-	return call_iter(iocb, &iter);
+	if (rw == ITER_DEST)
+		return file->f_op->read_iter(iocb, &iter);
+	return kiocb_write_iter(iocb, &iter);
 }
 
 static void nvmet_file_io_done(struct kiocb *iocb, long ret)
@@ -117,6 +117,12 @@ static void nvmet_file_io_done(struct kiocb *iocb, long ret)
 	nvmet_req_complete(req, status);
 }
 
+static void nvmet_file_io_complete(struct kiocb *iocb, long ret)
+{
+	kiocb_end_write_iter(iocb);
+	nvmet_file_io_done(iocb, ret);
+}
+
 static bool nvmet_file_execute_io(struct nvmet_req *req, int ki_flags)
 {
 	ssize_t nr_bvec = req->sg_cnt;
@@ -175,7 +181,7 @@ static bool nvmet_file_execute_io(struct nvmet_req *req, int ki_flags)
 	 * for the IOCB_NOWAIT case.
 	 */
 	if (!(ki_flags & IOCB_NOWAIT))
-		req->f.iocb.ki_complete = nvmet_file_io_done;
+		req->f.iocb.ki_complete = nvmet_file_io_complete;
 
 	ret = nvmet_file_submit_bvec(req, pos, bv_cnt, total_len, ki_flags);
 

-- 
2.53.0

