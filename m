Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794653297;
	b=KK4IC7JXD4U0C0o+zPPBmB7L/N6Y9HE07gcfnIzykZYpthAsDk7DYZDLFdqFMKd+jfFO
	 ayHmHoLhum+4oEbG8HfVefh+/r/evHDMzxenWhz6OdU6T8QBT5QYAk35nwqM/vOyjhUzu
	 FZaleIZ+IWEBFozawYjHii/xnaED+ZFc0vUxWD4o/Rx+ERYrGpecbfZHDhhhlcV711XJ6
	 TxNkIhBbcJlT3gkoH4qwBojpiQFP11IZ10/NQHmS6IRrCt2q5eBJ3mb/eOYbD5DIT9Xa0
	 7staq5TUD3aMDi7mcdDkDTii5IaA6cKAw6vYyhmGDp0YGFGcFtLvEiMpKZoJZxJ2BaA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794653297;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=vtgEf1FdH6u+rKYkdVT9EyPwgKqRpMwoRzTFDVcRn0s=;
	b=RYddF1MVoCeZnTPBSKzqHrlsAaXWDKm1faVOJvrTkrChaCfQf8FNd9QnkGEf5L5gvmcA
	 TW3sAqQErwiYiKFq5RLVd6UpRiNZtSrb+HzKgIHb0Xu7imyV4uBD8PNXaVnTMCDVDbgOU
	 FMm4qiDMYfx1OZXKS+5mJL6vUykQKvTHrXjp/T7LdRtEZeCIajLKbFrwZTue6IMivCZq0
	 PPnKuarVAl+0WYIE+4A5HbS5c8HJyzm3XAdWcOoQ69UreuLZ8QDEbT4rhKybrM9ohrgux
	 PppCqSD+oKtU8tAlBKYDM4irTH9GDnJ8tMsgHmvXZjTaaMk4SsgXdCbSlCKKcBXjPow==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="Txw7O9W/";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D3470606A336;
	Sat, 14 Nov 2026 10:48:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Txw7O9W/
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EB3211F000C4;
	Sat, 14 Nov 2026 10:48:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794653297;
	bh=vtgEf1FdH6u+rKYkdVT9EyPwgKqRpMwoRzTFDVcRn0s=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Txw7O9W/WWBa/Hrxbh27c+ZvJvTAnPMnnvi6OX/ATEGV8iWKj2Bmd+rqE/CXDvmIs
	 ROmlmuRoPLs6Tj7gFkFI7rhup5s/2DA/hcXGi83xX5cK88xPd9TzXGYGkLpO98HoC7
	 UF2G15weEGCHA69MM/wF7IPfUpm047QnVqmPTA2xH8zPyaOjIC0Mjb1TQllJxb29dA
	 aWOOYZScPtdNAI2GekGodgy3ErDuZ3HVmoHM4RvyRi1a2oeUCdiSuVkzsqQOsX60DO
	 B7fhcszQXKngwegLkOb8r+7I2wz33WAbD4mqxNwS2baSAbb68ral4uxuRe4nNKsJXw
	 NB/9tFk3RzncA==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 11:47:15 +0100
Subject: [PATCH 08/12] target: fileio: take freeze protection for unmap
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
Message-Id: <20261114-work-fs-frozen_writes-v1-8-f5ae61c898b1@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2068; i=brauner@kernel.org;
 h=from:subject:message-id; bh=Hll022vtvY2B8DZtCefJaSIabzkH690ND5dZekBlzps=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9sHH7dSvIaONhQf5prVut5JMcT3p8ieCMlxX8mfz05
 r/rpr+rO0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACbyh43hv9PlL9/XPOc8/f2b
 dM8dl8usn01snl06sm/bTf/lf658z93A8L+OfcedLL3r6w9m/jz/PWOtjsrVZfE35Y9KKfK8W7j
 3qw0nAA==
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
 drivers/target/target_core_file.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/target/target_core_file.c b/drivers/target/target_core_file.c
index 27b266a092b18..3fe4035b22a94 100644
--- a/drivers/target/target_core_file.c
+++ b/drivers/target/target_core_file.c
@@ -596,7 +596,9 @@ fd_execute_unmap(struct se_cmd *cmd, sector_t lba, sector_t nolb)
 		if (!file->f_op->fallocate)
 			return TCM_LOGICAL_UNIT_COMMUNICATION_FAILURE;
 
+		file_start_write(file);
 		ret = file->f_op->fallocate(file, mode, pos, len);
+		file_end_write(file);
 		if (ret < 0) {
 			pr_warn("FILEIO: fallocate() failed: %d\n", ret);
 			return TCM_LOGICAL_UNIT_COMMUNICATION_FAILURE;

-- 
2.53.0

