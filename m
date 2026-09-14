Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2F2B0481FC8
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 14:45:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789397153; cv=none; b=OkBpzO+bOrGaEhFXJcbXY9c6GiZ7ziZTVubvhDKdYzUoExb314lmTahImdAc5srooTqP7UQQmRHV42DZwGVPGb+pi9le+4Jdd+c0RwOKjsloZobIOa3UVNkwHScqZWATscF70KeMF4IY+As9gD1u+7/i4gtfG+UmsbU+fcq2vkQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789397153; c=relaxed/simple;
	bh=b48kdeVrrT/UuMq8JLl1fT2WIY6LkLvDKD3d8NgwdbQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=iTkwToeFkO5mKMZ9hEwoOTsVH1V7aFHzNrK7DaVczDqYmGJ1BvXEeft2symJT3Wlt+jMrsaRwKuNL0dWugR+Vi9/3z8vOuVfEyV5iveL8uQnyz4Xce6147uv9yNszxKoJ85YwBO7I1mERGVRNaULTZToCmwZCS8SDaMkhg+cduw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=eTKulz61; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="eTKulz61"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4B8861F000FF;
	Mon, 14 Sep 2026 14:45:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789397149;
	bh=UciFuXHLpOdHcYvmIqtk0Bta3g72s7ZIv090r4OFHfc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=eTKulz619BAWVhovLkODG9BAGHzJchty8T9QWZAtPjrf35ySMtJ++HnvDX+o+EAfs
	 DMmk67/vNMu3k1WRHqanAqZBM7bbxsXzV+bm8iDVF6utJEnivBPra6Xyy2PH5U8tH4
	 +sTQEalQBVlRX1YAZ5ws/R5OhWqiwTvV3i+SK4uZHSTjnkhYd3ukDhIkfSif64why1
	 nTz+ojrdEPduwUnnQY4Fszi8X/ewBvHQekFtfSPpw72s9vnXB8uEcnlf3QEFC3Hs0/
	 Vd5NzixgSJARQnhxUZWdbQwzWaFKlT3PiCUNYERHvwGpg1df70lNRYZw6jHg/nnyoi
	 JLUSfo/TvYdFA==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 14 Sep 2026 10:45:37 -0400
Subject: [PATCH v4 07/11] SUNRPC: Publish TCP reply positions
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-duplicate-reply-cache-v4-7-bcf9d2628a94@kernel.org>
References: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
In-Reply-To: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3814; i=cel@kernel.org;
 h=from:subject:message-id; bh=b48kdeVrrT/UuMq8JLl1fT2WIY6LkLvDKD3d8NgwdbQ=;
 b=kA0DAAoBM2qzM29mf5cByyZiAGqoCJagC7hyt93pIGLVv5tp/k/FSCoW30cK67z8hfmyoTH+0
 okCMwQAAQoAHRYhBCiy5bASht8kPPI+/jNqszNvZn+XBQJqqAiWAAoJEDNqszNvZn+XPS4P/1fK
 WwbqHbdIcBvIkVmkh7KtAVug4Vi+8vmtVI8DCRLhyGEplGCj6yTbVbk6W2BfytLtnKGsghsMFm5
 Zu33qLtcZ43IB4BO9+8+eusHmiNBFTO2QHNbGtHIT8oWXyo28CNocG5p+8g9skjhayVC/sHIAvE
 CWTuvbccb3atUTtQKe2u8cAIJe8OE1Gj5AKbRL4LU6p3Voa6/USf5onkSwiCN4Yzj8LTHFPvl7m
 3Qe552lYAmaV3kwFcqZcGFgU2trFnPSXS0Jqw3kyi9qZoT+rP04JjsSLBalYkVDmoVaDiPY9WaT
 snLhHDMlsTKQlOIUF/hM2P/IS5nuSIqcV2wtWSNzju7CSNGift7IPRzQYT4KS6rLRON1DM63ijO
 xb33kIn4LDeLmKhmDWGElcCnlhthUCrvfEieh1weLchxD48Je2dtBhTGWFXRAl8hiG+aSJROiGB
 0fnYVmPkJaZLPjVVOQ8zszBxrc8oQ7EuYh7u0mYBLOg9bs/ziHmc1HSMf6iVN7W7do0B224/Dt0
 NcbAlM+bs5k91T9IMxVGGeCi1odtjtb1JaQZ2CjNZgR2PYs402wbnUliXpeXicMhBT7Hra2tY88
 QrJKHc8ohYK7Zic/b6idfmJoPJ6XLcX1Isw8X8qYpg0qN62VwnTetxms133D8oKAtTvSOmEmB+x
 C2tVI
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Add the svcsock side of reply-position reporting. A reply's position
is the running count of bytes handed to the socket, kept per socket
under xpt_mutex. A TCP sequence number cannot serve as the position:
the 32-bit space wraps in a few hundred milliseconds at 40 GbE, and
a duplicate reply cache entry lives for two minutes.

The acknowledged position is derived from the socket's unacknowledged
byte count, write_seq minus snd_una, after each successful send. The
two are read without the socket lock, as tcp_ioctl() reads them for
SIOCOUTQ: write_seq advances only under xpt_mutex, and a stale
snd_una only lowers the result. Refreshing the position only in the
send path means a consumer sees the acknowledgment state as of the
previous reply on that connection, stale by one round trip but never
ahead of the peer. A failed or refused send leaves rq_reply_pos at
zero, so the reply is never reported as acknowledged.

Under kTLS the socket counts ciphertext while svcsock counts
plaintext, and tls_sw_sendmsg() can return the full plaintext count
with part of a record still waiting for socket write space. The
unacknowledged count then understates what the peer has yet to
receive. Whether a record is pending is state private to net/tls, so
a TLS session publishes no acknowledged position and its replies
are retained for the full interval.

Assisted-by: LLM
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svcsock.h |  3 +++
 net/sunrpc/svcsock.c           | 29 +++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 372a00882ca6..b6e0767de35a 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -41,6 +41,9 @@ struct svc_sock {
 
 	struct page_frag_cache  sk_frag_cache;
 
+	/* reply bytes handed to the socket; protected by xpt_mutex */
+	u64			sk_send_pos;
+
 	struct completion	sk_handshake_done;
 
 	/* received data */
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index e5459d504b6a..b9bab3751e76 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1390,6 +1390,32 @@ static int svc_tcp_sendmsg(struct svc_sock *svsk, struct svc_rqst *rqstp,
 	return ret;
 }
 
+/*
+ * Bytes the socket has not seen acknowledged all belong to the most
+ * recent replies, so sk_send_pos less that count is the acknowledged
+ * position. write_seq advances only under xpt_mutex, which the caller
+ * holds, and a stale snd_una only lowers the result.
+ *
+ * Under kTLS, tls_sw_sendmsg() can return the full plaintext count
+ * with part of a record still waiting for socket write space, leaving
+ * write_seq short of the reply. Whether a record is pending is private
+ * to net/tls, so a TLS session publishes no acknowledged position.
+ */
+static void svc_tcp_update_acked(struct svc_sock *svsk)
+{
+	struct tcp_sock *tp = tcp_sk(svsk->sk_sk);
+	u64 unacked, acked;
+
+	if (test_bit(XPT_TLS_SESSION, &svsk->sk_xprt.xpt_flags))
+		return;
+	unacked = READ_ONCE(tp->write_seq) - READ_ONCE(tp->snd_una);
+	if (unacked >= svsk->sk_send_pos)
+		return;
+	acked = svsk->sk_send_pos - unacked;
+	if (acked > atomic64_read(&svsk->sk_xprt.xpt_acked_pos))
+		atomic64_set(&svsk->sk_xprt.xpt_acked_pos, acked);
+}
+
 /**
  * svc_tcp_sendto - Send out a reply on a TCP socket
  * @rqstp: completed svc_rqst
@@ -1418,6 +1444,9 @@ static int svc_tcp_sendto(struct svc_rqst *rqstp)
 	trace_svcsock_tcp_send(xprt, sent);
 	if (sent < 0 || sent != (xdr->len + sizeof(marker)))
 		goto out_close;
+	svsk->sk_send_pos += sent;
+	rqstp->rq_reply_pos = svsk->sk_send_pos;
+	svc_tcp_update_acked(svsk);
 	mutex_unlock(&xprt->xpt_mutex);
 	return sent;
 

-- 
2.55.0

