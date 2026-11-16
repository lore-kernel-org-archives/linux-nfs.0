Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827135;
	b=PiHV3rL5w+TVE+9kD1pOtOZPT74Cc0DdRL+cRJeOj+UUV2pIp/ryyhqWoHxONEXkOp0X
	 Xj+0oYSty8iLLQZ/aj3Lujts2HVdAMXYuCueVs19Ro7/dtLH8P3gnxrCC1bq91pRaznZt
	 o2BzcGrN9Q0ekJa2vwxFlhSa9F2U/IvrJXFNzMFIGzhVZUJ9EOuqVvuwRdVQn1fZRLgP4
	 iIJG7cYdtd+v7BHf+DJdgLF5xjvAhJ6a5BFJtlKiQS1Vcw3CS4rpab1qTSvQcalCGmFDe
	 GgZC5c3qiklYV5gmOHtpES8Qbe6Ui7MN7umQCcqLtfxoWUsOuIOo2qyEcG6QttDPq1A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827135;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=1QF0+KKDPXTbJ0UkYlxOFTSFnDq8YOHfFuDVPMQMMME=;
	b=d046Wrych4HqoCSp1W1aN+w6yk65Y42gHchVb5Z6Y8vUW4nfknzkJsHQwzrZTe7I9zG6
	 S/qhpps7Hx+EfYFyo5Kp38y5Sx7rbRmG17r37mrJxLqXtpBRKZhlJmdwteQrb60usyOpg
	 WJjW3BMxQlClZ8JrjNMsiTzH5pGTM5run0nEM5xeJGSJp9keYDRHYh+6vq03fR/dmIG6P
	 dO+8tS3+4NUsVVyr319c5U7aR+Fbj/7F+dYZMlbtNoEKdBdJr15XMnGjLGIW6yBFJLaAD
	 ff/2Ask2UIjXkakzVnLX8BAWAyPEEewcH4itBkse8kfKScxsduKOGtwTvcsuOGXwFBA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="ck/Fpf51";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A58D2606A32F;
	Mon, 16 Nov 2026 11:05:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ck/Fpf51
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BC1521F000C6;
	Mon, 16 Nov 2026 11:05:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827135;
	bh=1QF0+KKDPXTbJ0UkYlxOFTSFnDq8YOHfFuDVPMQMMME=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ck/Fpf51qFS3EHEddNfmsL1bIe8Taey8LjrZGzNMpgHEPuJ1VvtqdvBfaqG6qhxpE
	 mrvS+azIkIJJPAnJUWMmlL83WA2/8T+yNE+Q8o2SvCBwQw8MYdA1DMAdF/BvJXG4y8
	 d2j8oNmy9+IWdWgTdbtT87Gv6/psMcS4+lIam8QX4mcOoDUMYwgSTrzikk7HGB3fvq
	 e6KjCy8Rwjga2FSODjRJBeaHywt7cIh0nMaZ031BK6ucqMIOUZopgpVRZmUNNSkTll
	 AYR/aZepGfDfpKqRhXkb0qEqYqzZymz+CtzjtPuZqR4AozUUXGawQTMJLRC7yZTg8K
	 ZpjJq4FFpxmfA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:03:57 +0100
Subject: [PATCH v2 17/17] backing-file: use kiocb_end_write_iter()
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
Message-Id: <20261116-work-fs-frozen_writes-v2-17-ecc4a2aac40e@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1554; i=brauner@kernel.org;
 h=from:subject:message-id; bh=ekRldUrgBiFG3YHdph7NV3YyVlYUFmWnca1eOlEjyD8=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9emy47av6aq8f8tcaf53VT85reJav/Xmzjf5Cp/lGC
 3azfpaS7ShlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZjIfmFGhi+LejYIbrW4lLA6
 XtKg3PbEi8KdggESFeHRX7r4pypxNjEyvN6uH8u0PHH5bZ+9XLv5PD+cZBe5cf0028OjegtCzaa
 +5gMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

vfs_iocb_iter_write() marks the kiocb with IOCB_WRITE now. Drop freeze
protection with kiocb_end_write_iter() in the completion callback and
get rid of aio->is_write.

No functional changes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/backing-file.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/fs/backing-file.c b/fs/backing-file.c
index 5780f60662d07..e86f5685758eb 100644
--- a/fs/backing-file.c
+++ b/fs/backing-file.c
@@ -106,8 +106,6 @@ struct backing_aio {
 	struct kiocb iocb;
 	refcount_t ref;
 	struct kiocb *orig_iocb;
-	/* used for aio completion */
-	bool is_write;
 	void (*end_write)(struct kiocb *iocb, ssize_t);
 	struct work_struct work;
 	long res;
@@ -148,9 +146,8 @@ static void backing_aio_rw_complete(struct kiocb *iocb, long res)
 	struct backing_aio *aio = container_of(iocb, struct backing_aio, iocb);
 	struct kiocb *orig_iocb = aio->orig_iocb;
 
-	/* Pairs with kiocb_start_write() in vfs_iocb_iter_write() */
-	if (aio->is_write)
-		kiocb_end_write(iocb);
+	/* Pairs with kiocb_write_iter() in vfs_iocb_iter_write() */
+	kiocb_end_write_iter(iocb);
 
 	backing_aio_cleanup(aio, res);
 	orig_iocb->ki_complete(orig_iocb, res);
@@ -264,7 +261,6 @@ static int do_backing_file_write_iter(struct file *file, struct iov_iter *iter,
 		return -ENOMEM;
 
 	aio->orig_iocb = iocb;
-	aio->is_write = true;
 	aio->end_write = end_write;
 	kiocb_clone(&aio->iocb, iocb, get_file(file));
 	aio->iocb.ki_flags = flags;

-- 
2.53.0

