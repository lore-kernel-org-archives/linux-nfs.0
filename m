Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ADAC728640B;
	Sat,  8 Aug 2026 15:40:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786203624; cv=none; b=h+vcCtkUG0+11KD8vm2GsZtpjtjd2aui8j4PfNpYq2GvqrfEwxh7tuHxBrLmjJ7vCM0evMbVD2TiB3CNwqeWwasEWVtovHbdXCSs91gm6phfoh2vHjzn8bkxHyrNnsf5MIgGLOuDyooyydQKAeHMYoW+JU/YZwlSkuIuOPqeGiE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786203624; c=relaxed/simple;
	bh=DDbX8FhgiMdnXPpsiweqY2F+CQKrWEC6NkhvD10SiUQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=PPd1BXrMgFEgO14o/o02QFqdCCzteYhh3KCd5Kf+gujKIwsZJnaqXe7EbiwtXgnowGALm73t/zyHb0F+GXRhA1ckFyHyEusXEYyby5sTX6f+OvgrZ9rvnjlmrr5V32KBSOH2jW3SNusBSJUQ4ZeID07AFLSfv9VGqHH56PUwtqU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=E9S8w6mn; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="E9S8w6mn"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 67D9B1F00AC4;
	Sat,  8 Aug 2026 15:40:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786203622;
	bh=xHv9U2YcK/1Iv660yIM5y3B0NHQ9ZXuBkqt5gVtPeuI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=E9S8w6mn+lhwVny0wBWmzwsXxSJTGp8EnQ9FXMxHTTDPQplH5wKZmtW4TpfEzKZ53
	 khZPgEyeJ06ez9C8FJFN40Un6JkYgQTT/w+B9GLWAQaCCfQXAYNNzQH+sps3ASTTRZ
	 uq//Cr9OxPvE6Qwxz+00O79ioOHjuWdnIkYAwo4w0lyqJ6qCvGC8aCCf+22w40zyJC
	 KPizZ5xHljfDJn7sQyt655zz5ShruOVCji8DKS1Dj0DLMh4Tstzb8xZMXdnuleCihi
	 CjDT5oN/uWOGpMkdqbHw4W3S17A8CERJ1cFmfY0FWVsMbMKxWhc2U0KvfGkqfHglMl
	 dnfUeFpjUQ48w==
From: Chuck Lever <cel@kernel.org>
Date: Sat, 08 Aug 2026 11:40:09 -0400
Subject: [PATCH v3 1/7] SUNRPC: do not credit control-record octets to the
 RPC stream
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260808-svcsock-cmsg-fixes-v3-1-62d9a631c880@kernel.org>
References: <20260808-svcsock-cmsg-fixes-v3-0-62d9a631c880@kernel.org>
In-Reply-To: <20260808-svcsock-cmsg-fixes-v3-0-62d9a631c880@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2006; i=cel@kernel.org;
 h=from:subject:message-id; bh=DDbX8FhgiMdnXPpsiweqY2F+CQKrWEC6NkhvD10SiUQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqd03jCScQiXAQj2IGfhpZuPoRfyGBoFYrgn0X6
 9U/P8iLN+uJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCandN4wAKCRAzarMzb2Z/
 l2/AD/9c5JpONQrRZlJD47nV0ZjrBLFzEecqCRzwIMlWW9IZYYeOWVXtx0KBVRA8Qd1lyQT9qze
 4unkkL8Of7/qDJ5css+Qe8pNTT/KKnJbbKj28yx4e/V9sIEoRnfPPlCL5QBAJ/62+B4eHz8eXAb
 BXoqyYV75ip5/1gCJFknySHmNIdpLBAiQ7xEQPl+efqrUV9lq5sTbxtn3UDiJGnvchoYzUahpKq
 2hxDlCkRKAzVVsuNQqFFZkBPQlMCjHKp9jJH7hUL/FUGfQ+oY/uD4JB3xXKFQR/JsJAEfcnmWy7
 mo1CwACmw/KGUQKCER84B7lR9Auv5kN3VuvFzYkAzZUw7O4e2P3n205lhqbhyctVj2vzJbUajnW
 ElIcsXDsrRjcoUPzULvrsATgtcLownhO8y/obldLOfmOVqhk/lCowxmjmmq/nOB86Bnpjlu4j6x
 TgRe4/tv042WqBNR98EmOOZTe6eMzZfvuk3N225g7r7QZzDndgDqdB93pMgTu9qohrWgVdj1mz7
 RTygqoQFulM4+AYBNRhgDs1HjwFOx35Cq9fkCrHrqxdm8wP/ebmHWmzegE6nY1y5w9tRg8A2WdI
 47bkqP1w7Q+fQEIXeO7vpCjdIWrpTLj37r+3UzlAFou0UtEvakab9fWyZkOL11Y7MVBESWAs84r
 XbXkU0cL7ArtU1g==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svc_tcp_sock_recv_cmsg() receives up to two octets into a local
buffer, and returns that count for any record type other than
TLS_RECORD_TYPE_ALERT. Nothing reached the caller's buffer, but
svc_tcp_read_marker() adds the count to sk_tcplen and
svc_tcp_read_msg()'s caller adds it to sk_datalen. The RPC stream
advances over octets it never received. The fragment marker is
assembled from stale sk_marker octets. The message body comes from
pages nothing wrote.

A conforming client reaches this. RFC 8446 Section 4.6.3 lets either
peer send KeyUpdate once it has sent its Finished, and svcsock has no
rekey path. kTLS leaves the partially consumed record on ctx->rx_list,
so the body drains two octets per svc_tcp_recvfrom() call. Each pair
is credited the same way.

Return -EAGAIN for a record that is not an alert. That is what
svc_tcp_sock_process_cmsg()'s default arm returned before the receive
moved into a local buffer.

Fixes: bee47cb026e7 ("sunrpc: fix handling of server side tls alerts")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcsock.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 50e5e7f5b762..8e1009302e3b 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -289,8 +289,13 @@ svc_tcp_sock_recv_cmsg(struct socket *sock, unsigned int *msg_flags)
 	iov_iter_kvec(&msg.msg_iter, ITER_DEST, &alert_kvec, 1,
 		      alert_kvec.iov_len);
 	ret = sock_recvmsg(sock, &msg, MSG_DONTWAIT);
-	if (ret > 0 &&
-	    tls_get_record_type(sock->sk, &u.cmsg) == TLS_RECORD_TYPE_ALERT) {
+	if (ret > 0) {
+		/* Returning the count would credit the RPC stream with
+		 * octets that never reached the caller's buffer.
+		 */
+		if (tls_get_record_type(sock->sk, &u.cmsg) !=
+		    TLS_RECORD_TYPE_ALERT)
+			return -EAGAIN;
 		iov_iter_revert(&msg.msg_iter, ret);
 		ret = svc_tcp_sock_process_cmsg(sock, &msg, &u.cmsg, -EAGAIN);
 	}

-- 
2.54.0

