Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827131;
	b=3xTys3C1Rjw2AFXYTqn9tDTFQUzVnvlHnXTEsiswbZtsApoRVMO+TVFiSacWg8p6uQtt
	 7O4S2IQSYVesaw0j+ep6j6GF/fpOHRtO08lcdUUjGGK39EATBLR66guCs2NoKTnRa8ssQ
	 TCIkKEXtEzM5K1lLIxXHzbHGLAt/tyiEa7C3tBaLb3RUB+kjA9wYnYJapLamI3mFEtK1U
	 CHo+koLrFHwgIDSh1vEWkr065zdLjtrrUMGGp7gnGkyIVX8aSfcx/pQgb1cm7AydHlNHA
	 UvvRh0uekEj7gfyV7V1iCPRb4U7IvrkQGXLz6dFb5+GsxRqlsROGarZPxRIaSR679Hw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827131;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Up4QcDgioDZqUrec7no2Sv6eS8z1skBOes4Nvk8uSaY=;
	b=kjY53zj/FVL2422I4/doWGVRvAb+3TAN/KOZxjIPAZ4h0oFSdgjRwo+9wuiiTT/1R+vM
	 O/iO4goNWS9OlJC3xJm+X5M5poGGVBgOTcUPInQqDOiKcnM2BgN97/I/DfuWqChRGZ2M4
	 Zx1jxfsiEyczcpOIaA0Y8Qqh7dnhnlGMRlR0tRHpQ1g07WwOCGlsJdYC3pWzOGGBFjUuO
	 NxXhlST0sAzDpRpR2dQ4FhICgW1WNDCO2gJcQh2Ew2ti60CU/d2joO5vnGMKqMCGVqtmG
	 +1EWySmYb2LkwHAnISnxQXgoI0e5poUx1Pp823G1joSCP3Dp7hhRtGIWNxw26DTxEng==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="UJf/sVnW";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A433F60A263D;
	Mon, 16 Nov 2026 11:05:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=UJf/sVnW
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B7DAB1F00926;
	Mon, 16 Nov 2026 11:05:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827131;
	bh=Up4QcDgioDZqUrec7no2Sv6eS8z1skBOes4Nvk8uSaY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=UJf/sVnWA5PbX7ZnzaL5uM5WD2CNUwQM2ooXztogsWbtOE1shubZUqTcSwkLkRFQq
	 FAhnv2rRmOrIR9n6e15wIFY5690R32XIGNOE5nneN5BsA/53klUD4O2b3SjyXye+2l
	 tFOKWD662r/pcXHsBEn5J7I8x7L37ljUXyU3b7esgv4TQdDYtYBaDDuxpiAUlOutx4
	 hfico32rbTfgNCKvOCfMnwrZIHczpPeZC4/trq8cZ2uwAzDdy103/i+3g4/bF3ydnq
	 PvCytT/H66q3RwtTUpQh2d9/XVkkHy2eBh4HCZ8X90WETLxPbZgmuIzsEVrV79ouWe
	 cBtvTC9Ei56Cw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:03:56 +0100
Subject: [PATCH v2 16/17] fs: use kiocb_write_iter() in
 vfs_iocb_iter_write()
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
Message-Id: <20261116-work-fs-frozen_writes-v2-16-ecc4a2aac40e@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1463; i=brauner@kernel.org;
 h=from:subject:message-id; bh=MCaMNnJkL9G2ZH6ZyKJ0L2XRF9HMQi7Wd1t5jXBxpyk=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9emxwMOyM8JrvK5ZdNFvFsuCiy8fCH8/Wpcn/1vXM/
 Dw5Ush4d0cpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBE0qQYGdpNBeuZ5rlJmD4p
 SHz5Yu19p9yF99dum3W/kEe8ipXliTMjwy652s4dFQEfzqgFmQnbOc7+1+OT/fVc45rT9tvjp1m
 +YQIA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

vfs_iocb_iter_write() open-codes what kiocb_write_iter() does. Use it.
The kiocb is marked with IOCB_WRITE now so the caller can drop freeze
protection with kiocb_end_write_iter().

This also means that an IOCB_NOWAIT write fails with -EAGAIN instead of
waiting for a frozen filesystem. No caller passes IOCB_NOWAIT today.
overlayfs and fuse passthrough don't set FMODE_NOWAIT and cachefiles
and nfsd don't ask for it.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/read_write.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 6767283108991..eca0aa73e5a4d 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -923,7 +923,7 @@ ssize_t vfs_iter_read(struct file *file, struct iov_iter *iter, loff_t *ppos,
 EXPORT_SYMBOL(vfs_iter_read);
 
 /*
- * Caller is responsible for calling kiocb_end_write() on completion
+ * Caller is responsible for calling kiocb_end_write_iter() on completion
  * if async iocb was queued.
  */
 ssize_t vfs_iocb_iter_write(struct file *file, struct kiocb *iocb,
@@ -946,10 +946,7 @@ ssize_t vfs_iocb_iter_write(struct file *file, struct kiocb *iocb,
 	if (ret < 0)
 		return ret;
 
-	kiocb_start_write(iocb);
-	ret = file->f_op->write_iter(iocb, iter);
-	if (ret != -EIOCBQUEUED)
-		kiocb_end_write(iocb);
+	ret = kiocb_write_iter(iocb, iter);
 	if (ret > 0)
 		fsnotify_modify(file);
 

-- 
2.53.0

