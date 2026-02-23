Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2770B2727FC;
	Mon, 23 Feb 2026 17:10:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771866619; cv=none; b=Qom+Hk4hkmFWSkttM4PAYmzC5ARklCpJF8EqGzG7SxRTgyxg1shACNqZzBLfJLat8743ycf6tDHITTYifwEuXQ9dH1e9U/Qskll+gA/g200+61MNM0v43YZBK1pahkqhe3x3G8fzBt/AtZuoaVi3Q0EPhYQLehQQjAwQwVaaPtw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771866619; c=relaxed/simple;
	bh=HgXUYRIJ3uMhjEi7JEY7sJBsQZ1d46lcqUMgcKlCt4U=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=XocHaEPspAdD/WmX/FwYIWNQCVJiBpSW4F22O+uO1CwE7O5vt+fz+2gPV3pauiwbPvPpRQcj1GGnfDfnhaFxyZrycbLBARdWdRp+Ue9nGQxCBBdlypTdJQPERKMVKpbtxpV27hs3x83PRH5FGj3m+VuFbzc7fYAt9BfAC8yfDvk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iotOkam2; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iotOkam2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ADB4DC19421;
	Mon, 23 Feb 2026 17:10:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771866618;
	bh=HgXUYRIJ3uMhjEi7JEY7sJBsQZ1d46lcqUMgcKlCt4U=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:From;
	b=iotOkam2ISt+FodG5GU2DJaX22tW5sTIIa45v1M36nCWqVQzJrMbGovaotFvuMKYr
	 xUAIsFOg+sBDyXaAE6wF1dQ7nDpLZZvmAD7r9Gd9Bi7igavVeWo/XhgczlAh22wdPw
	 yGNW508nnGIW3pTECNGp6A3lRUXOSAVNvNNETLeNlqT3fkqG/NEIXodWiJnp4g7+JE
	 rwGyooTdJLZKB1TWhABNKXaIrltaN8YOTjW4h2qiSVI9vB3JMdQ6KaPNzYDYKRP9Fe
	 xqP1Ostmm4M5JK6llKCyra7r22UMc4UHHRenS1b1UJKIV9yRrszq2wPbVeQuLBc7m3
	 YthtUY4vx1Fqw==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 23 Feb 2026 12:09:58 -0500
Subject: [PATCH v2 1/4] sunrpc: fix cache_request leak in cache_release
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260223-sunrpc-cache-v2-1-91fc827c4d33@kernel.org>
References: <20260223-sunrpc-cache-v2-0-91fc827c4d33@kernel.org>
In-Reply-To: <20260223-sunrpc-cache-v2-0-91fc827c4d33@kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neilb@ownmail.net>
X-Mailer: b4 0.14.2
X-Developer-Signature: v=1; a=openpgp-sha256; l=2648; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=HgXUYRIJ3uMhjEi7JEY7sJBsQZ1d46lcqUMgcKlCt4U=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBpnIn3YtioMuJ6isoY+vhVzeS4I7a0QwN9K1spA
 79epzNIpSaJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaZyJ9wAKCRAADmhBGVaC
 FXgsD/9O3UtxRjNSCMdntB2K5fWq+vl4BX7xOJQRXf0GETa9GTchwJZ7ExEuMym98/QWbNdDoAw
 SIlKIexuBGY/7vM0UqrcKoWMr62NFZIqMZwbWSOEM3APIDwz0aU8n7iUjYPqKataOvgVAKscXqy
 Y7PAO+s/ajyjbLMU12b6LZm3S6o5s1Y43cOefS8uAAOLoS4IK2krrsGD2b8EOpnKkRKMXwrFV8Z
 XETJxoaPn787Gck8elWQPQb6zDQTiW5Y+4COyfSS3ytK0h1GN6twpjnaEc1vTsaxExqve8/yG4W
 N80BVRZ3o+52ooX04HYiV0s2CqF3+9OrKZgwRJRsfBX62EaS4v2uy1VEc/XnODHtzvXhI9ILw/Q
 nRSKbrR9wPZRLY8VaxA8QVIW3pVHIoA1KH54e1Sz4xBrYq7GhtZlLtoHgbohp+cT3gRHEwVIa2D
 GD3SJzUPxy8x4P764vX1B0e2lnfvpVD/wREwyko5SWwTpbuf1vaAFZoGwWdOL6vKlwARdVqCTxZ
 2UXCtc6u1peKsF3CFecrOakK1vNOun9ALW7KBsQxvd0y8ZitKv8N2oJ64gwGcWCIwvCw3zqkvAr
 BAhBl9eh5Xec/xRq5bYkVENOQxaiFWXLbASCs9Y+hL75AEudBlD4kKHIaKT21fCXrO5rFOx9jpH
 sRQZV+8Iexv5gWw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

When a reader's file descriptor is closed while in the middle of reading
a cache_request (rp->offset != 0), cache_release() decrements the
request's readers count but never checks whether it should free the
request.

In cache_read(), when readers drops to 0 and CACHE_PENDING is clear, the
cache_request is removed from the queue and freed along with its buffer
and cache_head reference. cache_release() lacks this cleanup.

The only other path that frees requests with readers == 0 is
cache_dequeue(), but it runs only when CACHE_PENDING transitions from
set to clear. If that transition already happened while readers was
still non-zero, cache_dequeue() will have skipped the request, and no
subsequent call will clean it up.

Add the same cleanup logic from cache_read() to cache_release(): after
decrementing readers, check if it reached 0 with CACHE_PENDING clear,
and if so, dequeue and free the cache_request.

Reported-by: NeilBrown <neilb@ownmail.net>
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 net/sunrpc/cache.c | 26 +++++++++++++++++++++-----
 1 file changed, 21 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index b82f7cde0c9be6071ee4040150672872e548161d..86b3fd5a429d77f7f917f398a02cb7a5ff8dd1e0 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1062,14 +1062,25 @@ static int cache_release(struct inode *inode, struct file *filp,
 	struct cache_reader *rp = filp->private_data;
 
 	if (rp) {
+		struct cache_request *rq = NULL;
+
 		spin_lock(&queue_lock);
 		if (rp->offset) {
 			struct cache_queue *cq;
-			for (cq= &rp->q; &cq->list != &cd->queue;
-			     cq = list_entry(cq->list.next, struct cache_queue, list))
+			for (cq = &rp->q; &cq->list != &cd->queue;
+			     cq = list_entry(cq->list.next,
+					     struct cache_queue, list))
 				if (!cq->reader) {
-					container_of(cq, struct cache_request, q)
-						->readers--;
+					struct cache_request *cr =
+						container_of(cq,
+						struct cache_request, q);
+					cr->readers--;
+					if (cr->readers == 0 &&
+					    !test_bit(CACHE_PENDING,
+						      &cr->item->flags)) {
+						list_del(&cr->q.list);
+						rq = cr;
+					}
 					break;
 				}
 			rp->offset = 0;
@@ -1077,9 +1088,14 @@ static int cache_release(struct inode *inode, struct file *filp,
 		list_del(&rp->q.list);
 		spin_unlock(&queue_lock);
 
+		if (rq) {
+			cache_put(rq->item, cd);
+			kfree(rq->buf);
+			kfree(rq);
+		}
+
 		filp->private_data = NULL;
 		kfree(rp);
-
 	}
 	if (filp->f_mode & FMODE_WRITE) {
 		atomic_dec(&cd->writers);

-- 
2.53.0

