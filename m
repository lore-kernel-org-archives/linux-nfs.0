Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 776B349D5BA
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 13:22:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789996968; cv=none; b=ds4uS60xJUbW8CJhJxd4/Ltqv2kMDQMdSwB+eDB/ve4B89HIObZObYE7Y8nX2nOy+S+IOnVqK7152gBzeSWcWix7WjAsccuXHJj2obQTR7dgQ2bYQ5SGBes7nIThJlI01J4s0vWpXq6x3RLXjraI/ZForonyT70uOYzuKfZ3z14=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789996968; c=relaxed/simple;
	bh=b48kdeVrrT/UuMq8JLl1fT2WIY6LkLvDKD3d8NgwdbQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=UoWgTw9A8iLS1/F8EBMzbP5p0PWnneuv5mWHQkJHYc46ulqWf2a72HLZENjM9C2aLyZd1y079C9sYr77phVjuRwuLLUMEBzeTMsxry/WjMKzm8bOpCXIf9lFNLfMcPW8r5ZPikO8dZjPeIpEZEaFPtGvOBuUx00DFedKg6tTp6U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UrFslJxo; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UrFslJxo"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B565C1F00898;
	Mon, 21 Sep 2026 13:22:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789996967;
	bh=UciFuXHLpOdHcYvmIqtk0Bta3g72s7ZIv090r4OFHfc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=UrFslJxoTUXs+a7WwXr9QoeQQihwn7MOLcm2wFPSAUn9oQtHr7tvXyUu9xc2jot3Q
	 Lx52tLZZ9Vb8tqh8Oro9mCtoyjab/yKUgiva7PnDgZs9d8OolR8oMui7o04IthiUQT
	 k57+GAhRWZnPKNMaFcIW/mA8D2Vef2MzYvjRq5+3BS898nTAP/kpP/nqRAB585wNZE
	 nA6nyIoSGCGOFAkf/4qzansOXOzo6UhLXrTmxs5eN8y6hIkryfIhM6wW0cPExpjuU1
	 NljfNn6QVQ5JFzvFqFuaJOSd7fSFNjWi4ppmLws4eHig9exzBJEl4/ZvTwp/HngU/b
	 5HG1pIaEgVyPA==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 21 Sep 2026 09:22:35 -0400
Subject: [PATCH v6 09/12] SUNRPC: Publish TCP reply positions
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260921-duplicate-reply-cache-v6-9-db5e13fd9944@kernel.org>
References: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
In-Reply-To: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3814; i=cel@kernel.org;
 h=from:subject:message-id; bh=b48kdeVrrT/UuMq8JLl1fT2WIY6LkLvDKD3d8NgwdbQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqsS+ejuVKnrtYuT9t4F4gmqwpDLAJcvqQJ8fSg
 Y1gdUPzZySJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCarEvngAKCRAzarMzb2Z/
 l9JxEAC2ZJHCfq+x+/ixxCb6uJm6iYj9qbKhmbhYGwmMvMgaYh3vckKfG5Ooq8+htdL7DhgtFda
 7WgvK5rwNjXBE7H4ADl+VusKXCFE0NewfGjIqEt1uFFrwvcmnDL6x0IX6Qjb0m102q+HukbgJNc
 6E46PLXHvHTESlrkWwyKA8ezYYMyQXtmgU375F4IC3bwInZSe+COTkxTcpdS2rjuJ4Nebpcig7y
 yO1kgSEc3y6Eh9FoBgp+dn5CXlP2RVo3BMMHGeRLtHIgDoOdeWBnXUd7wZDvk0MxpOz2gBDZQvs
 FgtUlDziXZfeoGGkzH8l9L1LPrKNp0PzoGzw1o5OrT2STZHX4CQxwMjzY4EZCw6P4unwJoPzpXl
 rZ+Tin6N629juGy/yba2It1va0TjzG5VyiHiu/LOdFOyZzYT0JSelqanOATVZqhqFm5198/xlQX
 rhzf1k7t2nEJlCWwhP1iPsh2WGGh1gzShI1IrXDiV1m7RTz0QV8uQQOjp/4yC/RvSR05uGB/9NB
 mi7/VmHo7ioOGFR2gYM5g5keqvmdnOIJ4NAVtjmD95bCkXFKTc5hzNokh/KtSP0c+ESmpM0yZjA
 NFPok3Wf/GAjIibYs5BWoJ/orwWNhSdnX5t/D2vDcwckKrgJ/i0iwbo/Yy/v51cscgu6TG+QRRd
 6e5gNvAryBZXEww==
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

