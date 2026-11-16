Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827127;
	b=r1+hKaOHwSJK/CLZMQKX5Y7/M0AVBFYNDs5j7iCUlebvk1okBcwhar4S7m0k5ZjR5RIc
	 1Ized51kGOms9eIdkn3/zVZ1PmqORNqpcKbqtQk3KHxyUXVpxDu7VneFwOBGphnt1mLXU
	 7BWNA8aW2+0RzL0LuugUvyFNd/uzHGzKJtCGU3FTwvYuKveNYXIOZN82kDY1kOFbIlhgt
	 w73AKFAsit3R5D8j7UPafv/OXFrDTDH/4o6MnMuqyAlLcOvWT4yneuqK751zf0xB+18rs
	 xD7V6s4Z21rkjX7TAB9PnBSeIh0KA62qpRtOcPEAfM1Snl2quVFR2qxXOAqQcnyxnFg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827127;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=6nxQGkR2+dQ77VXhMKkc6TeWhcz+nCP3lMiHG+fTsXY=;
	b=xLbbZw/W+Qd/PaG+4OMPHZCpTJpPPpKmBya0XGTUkWFhMOsIynpyCVKmkRDiXZPc4UJX
	 e6iR2V2ek0A35skAB31dBLPTLi191uZUVUkkpcWSr+dRVmOrBKHacZbRYmU8wzvgXWY/H
	 DZ7vEWxF3AK6VXVC/BZ8Hs6xD6nTlj2Yf/vjSxo+vNjuGczF3Oy9Kzci6Yz7c+KU9GZCr
	 AxFJ5TzAZd10BKzMf0+e1Ed4s1idPH0FgNkdrecmuvmrcpJ4V9xsYfn8V38A3YBYo3QyN
	 U8M523N+6WRnUisLihvc9xORbsjr6T/faL+WVKrBVL9/W6PNKO/53U5/UF4sPQJXZnw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=n0gNWaP6;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 60F90606A8AA;
	Mon, 16 Nov 2026 11:05:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=n0gNWaP6
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BC38D1F00927;
	Mon, 16 Nov 2026 11:05:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827127;
	bh=6nxQGkR2+dQ77VXhMKkc6TeWhcz+nCP3lMiHG+fTsXY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=n0gNWaP6+UaJle+lzPIjzK+kyrdMuW2wim4FMgJ0DTFVHRkmRwb05GQtyZ4lcrEsr
	 WlFZlJjd6EHmIj8NzzqDTKy4RpNXFIE4ZB5YKinWiLIV4yE4N/uGMY+6QoW1uNGMzv
	 WoAeWTa83/6NZeA9JdwkbDDGa3YMvfBApWd5SppCS24LPewTESUQ0Ef4mKIVfC5vWA
	 Ir+k9QzWOr857A5zUwd6ZoxCqLRz8FoDlRyKmkMQqHSNs0HSYvIfzdmpkuYyXj0m6h
	 s6cTQ+4KoNp8FYesvPVXR2KA8ehz0xzT8rIyuF5ll1Hqf9UsF8qMO0hse7R038w17P
	 sCSrre2Hcixmw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:03:55 +0100
Subject: [PATCH v2 15/17] loop: use kiocb_write_iter()
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
Message-Id: <20261116-work-fs-frozen_writes-v2-15-ecc4a2aac40e@kernel.org>
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
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1200; i=brauner@kernel.org;
 h=from:subject:message-id; bh=WndiNS7xqPSBhItB27WExsGLYYFKg/7/xrVo1D0g96o=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9eqxXtP1Yx59vm07NWnTitsu3rH+TNSNvb/70UOxp1
 LaO6rdh3R2lLAxiXAyyYoosDu0m4XLLeSo2G2VqwMxhZQIZwsDFKQATUVnF8M+kT8HKTKFTvPkQ
 S/BFj+BK3YqMldUXL1zIzWvT36sSZwFU8bjpkNHbAwqTIjpDBdZwKp7cKMudIf2tb9GRoD9+b+U
 YAQ==
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Use the new helpers instead of open-coding freeze protection for writes
to the backing file.

No functional changes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/block/loop.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index d2f29aadabcc1..872d78006b131 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -325,8 +325,7 @@ static void lo_rw_aio_do_completion(struct loop_cmd *cmd)
 		return;
 	kfree(cmd->bvec);
 	cmd->bvec = NULL;
-	if (req_op(rq) == REQ_OP_WRITE)
-		kiocb_end_write(&cmd->iocb);
+	kiocb_end_write_iter(&cmd->iocb);
 	if (likely(!blk_should_fake_timeout(rq->q)))
 		blk_mq_complete_request(rq);
 }
@@ -395,10 +394,9 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
 		cmd->iocb.ki_flags = 0;
 	}
 
-	if (rw == ITER_SOURCE) {
-		kiocb_start_write(&cmd->iocb);
-		ret = file->f_op->write_iter(&cmd->iocb, &iter);
-	} else
+	if (rw == ITER_SOURCE)
+		ret = kiocb_write_iter(&cmd->iocb, &iter);
+	else
 		ret = file->f_op->read_iter(&cmd->iocb, &iter);
 
 	lo_rw_aio_do_completion(cmd);

-- 
2.53.0

