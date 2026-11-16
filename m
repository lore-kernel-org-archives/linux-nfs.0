Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827102;
	b=eIHtmgUTsjK+wbTONZu/b9M2sdhptpJIyq6Avid7YM3itM9fcxjjTqLRc+EQ+bVTguKv
	 0CWpz6ckFunO0AQwHh0P2o6NyoOsai8C1LV9sLUlGgVzCYuGuKtJoCH/7rGMpAwRP1Te8
	 qjLUhH46/GgPFX+HdhJZa4yk0wszh2E9uo3F473CsA1suqWA9NCPO6w85OKGpoQ8THerc
	 6jqpVhcLARiAPSfGZm0Wa2ViGT/IiUtalcUX8qIXp2DqeoutI2Olfq1amsktn7OTxUlTX
	 Ph9Wr0U6CTBlkwfqkQCQLfFNgGT2nL3MKftx+/TzbD6/F7xWW0fw0RrIEaHkP/1A+uA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827102;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=jHld24Oo1MWppo8/tfsSpZWU26RUmIMv95z42v9sotY=;
	b=NS2Udzdd6HxxBtWqP3kqoqR4bdZN9sQ4wl35hbcgcUCHn++u/nTn6UVC9dATn4YILUPQ
	 lpciFmENhWGIKz9t2Dr2p7gFiIOKIDIEv9M1Xf8dEGMNbTT2fui5tqM+2OYGDrH4EIRD9
	 5G/7QlaHTrYQSlaHTtkGTFwaZ3kKNiUr+2cV1Ho+Z6T/EsB4PaFrGxEdA7h8ki595j67V
	 7W7b3KtvNWgsitdW7eT5ooI8J+FT//SAgcojjcRzCETkvlnH8yX8E4wowRPh0Eo62PXGE
	 iyIfwYTgmHheuh/8uDJ7jyjqVhFOq1sPmngGoEV3YJh8PF1dDEW7g09ryrpOAxfyUUg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cQFtUDoF;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D4404606F1FF;
	Mon, 16 Nov 2026 11:05:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cQFtUDoF
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 558C11F01573;
	Mon, 16 Nov 2026 11:04:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827102;
	bh=jHld24Oo1MWppo8/tfsSpZWU26RUmIMv95z42v9sotY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=cQFtUDoFrQUz2WcbhXtkg02LHOrOLlYpUiFModvav8ZzlPl9cVV1Hd6Mzx97pXc8E
	 uC9A9hM3FdwQDgXCii3ZlvLmTUSWghY0gyv6DTq2Bf7hrtzjJzlrZ+W9lGQazMtuR6
	 q8WK06huhLK+DSB7eBUyu8cN4jTmRbZp520sbGPQtqw1zHjXF182+fiGQ63eN4SJdt
	 yzlmcWsQK7yMX8m8MTzLT5pPVNZvCXbixSM1pKr7rj22/l5wh28GiSpnygnvBeLDgi
	 Fi53LVfO78qk7qtdkRpPavVN5CQmViQGdt0QHOZaF9kN2LMnVGvoHEn6CPtk2AAmVw
	 fjnHFGrm6VARw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:03:49 +0100
Subject: [PATCH v2 09/17] zloop: take freeze protection when recording
 write pointers
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
Message-Id: <20261116-work-fs-frozen_writes-v2-9-ecc4a2aac40e@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1992; i=brauner@kernel.org;
 h=from:subject:message-id; bh=RHFI0o15CfHlL7wXbapiTqB0SqtZl6Dvtj6uSPjdx74=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9eqyu897T6MG0jN4vHBm5s4MeGO7ISJJ2eH7JTaxHp
 Ut6woSXHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABMJ3MHI0OB33ZO3h+/nCrbg
 SI0ZP5XmmskdebwqUIA9VuavjLv6FYb/WS1H99zdbuv1b83KI9OZ6g4yKabxZFuKXl4WcuH0td9
 nuQA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

With discard_write_cache a flush records the write pointer of each
active zone in an xattr of its zone file. zloop_record_safe_wps() uses
vfs_setxattr() for that which leaves freeze protection to the caller.
So a flush rewrites the xattrs on a filesystem that is frozen. With the
zone files on ext4:

  WARNING: fs/ext4/ext4_jbd2.c:90 at ext4_journal_check_start+0x1f6/0x2d0, CPU#0: kworker/u16:2/46
  Workqueue: zloop0 zloop_cmd_workfn
  Call Trace:
   <TASK>
   __ext4_journal_start_sb+0x7a/0x470
   ext4_xattr_set+0x20d/0x380
   __vfs_setxattr+0x10f/0x170
   __vfs_setxattr_noperm+0xf4/0x5e0
   vfs_setxattr+0x14d/0x3d0
   zloop_cmd_workfn+0x384/0x1ff0
   process_one_work+0x946/0x1820
   worker_thread+0x4f1/0xd60
   kthread+0x364/0x460
   ret_from_fork+0x525/0x770
   ret_from_fork_asm+0x1a/0x30
   </TASK>

Take freeze protection around vfs_setxattr() with mnt_want_write_file()
like fsetxattr() does.

Fixes: 829def1e35ca ("zloop: forget write cache on force removal")
Cc: stable@vger.kernel.org
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/block/zloop.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/block/zloop.c b/drivers/block/zloop.c
index 76d54c9b89c0b..d20a0d2afa855 100644
--- a/drivers/block/zloop.c
+++ b/drivers/block/zloop.c
@@ -719,8 +719,13 @@ static int zloop_record_safe_wps(struct zloop_device *zlo)
 
 		if (!zloop_zone_is_active(zone))
 			continue;
-		ret = vfs_setxattr(file_mnt_idmap(file), file_dentry(file),
-				"user.zloop.wp", &zone->wp, sizeof(zone->wp), 0);
+		ret = mnt_want_write_file(file);
+		if (!ret) {
+			ret = vfs_setxattr(file_mnt_idmap(file),
+					file_dentry(file), "user.zloop.wp",
+					&zone->wp, sizeof(zone->wp), 0);
+			mnt_drop_write_file(file);
+		}
 		if (ret) {
 			pr_err("%pg: failed to record write pointer (%d)\n",
 				zlo->disk->part0, ret);

-- 
2.53.0

