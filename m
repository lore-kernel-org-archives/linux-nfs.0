Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E5C1F35E943
	for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 17:21:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789752103; cv=none; b=JrfjnCie0iy7Bo0Jw8RkaCy8C8d7u18HI25NT45Uufm2pcuVcZTjmfsyPU+wUEtUY4VzFp2swaJ10ViMHB7Iz1cZvkRveBzELLsYJjKwLxwS67KeqcozEgDWvPtN1wDOkI+LuCNIsCJHZ90zn22kXYvHaNu9yWFpyFMykHucB60=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789752103; c=relaxed/simple;
	bh=b48kdeVrrT/UuMq8JLl1fT2WIY6LkLvDKD3d8NgwdbQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=UzI+Ds32vva2MQV0/XLt/YqHYteA/mpLuhwNNrH8TWf56J1GlyzJahi2nIF7XbTmyvP3s0T8pcpfbXpj872EqsEaiqBQRm3gUT0zEx2PKBdgslbE3MwyeTRWJ8wXnyRp9QGYtwzHqjRhAuaDSNxspA1DE3HfMU6buWcTZW/Oxho=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MI+V1/2f; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MI+V1/2f"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B3CE41F008A1;
	Fri, 18 Sep 2026 17:21:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789752094;
	bh=UciFuXHLpOdHcYvmIqtk0Bta3g72s7ZIv090r4OFHfc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=MI+V1/2f415V/RONvlWDzPueRulDz5zahyZuKOsgE0TZd8WYTLTJaDppKOOQ+c1jM
	 m6pjmPX990HZH6pGoLjeSWQA4chyfJfyWAj8py6BNSFQuiH5jBEALjSuuLcrKVvhuQ
	 C4OGxLJ57leSXRneunl5c1NSWle7ADt4ghqUDbpSVxOmkzPBgceHPPCAXLHMiRjeL9
	 /h8fzSrKb7ezFgL+QllMUbkD8VjaTki5v9nuwJ4AjKjyMh016kounD1K4W9uRKYy75
	 S8Sv12Ie5Z3vvwLIZOb/6bZz2fn1F3BMdW8u/GBAQ6nxXlf3hEVoLgcZ0OeP3ioXfW
	 eHorXsCAx0enA==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 18 Sep 2026 13:21:20 -0400
Subject: [PATCH v5 08/11] SUNRPC: Publish TCP reply positions
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260918-duplicate-reply-cache-v5-8-b6aba9ebf2f4@kernel.org>
References: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
In-Reply-To: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3814; i=cel@kernel.org;
 h=from:subject:message-id; bh=b48kdeVrrT/UuMq8JLl1fT2WIY6LkLvDKD3d8NgwdbQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqrXMWkvXV8ynsCXWkwl8cgjlB4RW5T35H7Uc8c
 t96lODcYVWJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaq1zFgAKCRAzarMzb2Z/
 l7aBD/sE1oymC7fGzM8RVuFbIPC5CYCM/Y+k3YQQpX6L14zOLyfrlBtMQFTp9EdsVkV0tBfaDbz
 6OxuZlWPg0R9owsRxU2lM3eNqz1RteWboAhoGAYUlgMxfMQ9/0xJVoqpCp7bi9A+qhcYJTXeftR
 +iqN9i6IrOUofMO5VQZB8djwd3hq27BqOjZfe96IiKXG6qm+BHj6bRK1XwGdVVezItP1amCyCtP
 L0TUyj9RuemJfFPmsFGvX+kLuO6GNyQe0lUgsP03mCgGTk69RC3pHmru1GgeJynZvdohBxW5fnW
 DT1x92nFFZjI6Pj4KGbE6YKba5fN3UXowQU5W22ddzLpkaVxDPyjBWRgppH5ehXPzeVNNLQno2r
 vbUkRJsAjtwLcZdHTuqiwHVQ5MVjgk2h52P0uOPkq9rb7uy1aJ3ox/GnFD8Ed/HZrOIezQYd0Fb
 W47OTy8GVRNVpRjFcQZol4ha9UqMuE7LfnNwIUoyIe/lpUu4aEp0vOewQSINMRqERWd7Dkgfiq9
 ALJqNmI7OFD5Iln1Ii6gW4bVEIxYgCsAhNe4ilyi3ujsx0qKze3C7cjIemY4Z0R39xM1phorc3k
 NuUEWgkKuYI9Rtsce588pmaRPH4rB9AwwrrDpP4K4fj5i9vqBkvdTS69p3bdofTVJduTzUxrvjw
 K3uThEo/VrjwTUw==
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

