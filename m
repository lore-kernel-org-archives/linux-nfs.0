Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795490534;
	b=2vQwvSiBAKu8OgjdrFZxVr4QOwWJSXtIz7Ey6gDDJgovueyHsZ8Bg60CqteE74ul/qrH
	 MndP8ZkkcRCw9tDl2mmIa/MGZoZ4XREm5v6xZvqeUQtmedO1PAceGJfutXeJV5CoxfEUb
	 DQfrws5S1l3Ml4rtT7418PndKkRx8IOLYgRLXyQbImnMWk02p4rDd4CHsr8WrdhZ3uPlI
	 0nZBIaYUBM6KPgyRrMr+Y0HkR264KQkM3ny17v27L9mI7d9FhAQyclg7TS6SV/94DuPeK
	 qQRuAdG2EyyGc6bRcCWmvTAITNvQtz9ZFi6zTyl6I5H/LEueR79WJKhWE2ba0HH5ekA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795490534;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=rSQ/WIUTmk4ZQR770AfGm3SEOx5tkSq/DJ5PFNUgKVE=;
	b=aYLj1sRrtbRMBy4wLgB+pDJOehiCxE0sXhBpaNpsN+frIYgR6Jmvj/XX71xnFkhGA08E
	 SanGMdz8q64RG4oFkPzGY57T+VXWZEcSkh8f0AJerJWSlSl7y1nzkyGknlXrSbSDPL7WI
	 MA7EDu6bO+OLVCyGpGemAch1qRElxwpUu6++zRHBgc9SBD+HU9Lkzaz8P5RkOkvdN+9Du
	 DWhVzlySeplNApt8RY9e29Myy/cd8evwtFfvTBmQpzVTpJEWG1yB4Rr3AgqjP3hWGNeHG
	 tuAgLm3VAak0E3HXgq8I37MoOl1mDnFwDLq8VjSNSnd/ddokPmOHVQiLlkzUNEU8zmA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="bAMOgII/";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0BCFC606A31E
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 03:22:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bAMOgII/
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8634F1F000D2;
	Tue, 24 Nov 2026 03:22:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795490533;
	bh=rSQ/WIUTmk4ZQR770AfGm3SEOx5tkSq/DJ5PFNUgKVE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=bAMOgII/TjJzrcjdo4SUGomMmwcu3QI5jZBb/Qm0UQunQ+pRvkCROFdApVSbueJ8b
	 KofkordyQextyJhMh9IebrBh2RP4XZQJb9b2CH0UDLCHF070UGwsZPcreo+z7Ue3k8
	 jhlajcwuvjt1qMYYKhfjJfeHcSWRAFHR37k4jKzyvVTX/cuzRTcmy+LaoGhr/vs4Da
	 hrHV7drEoX59e7aZJJ5E03rp1warRosuJYklZSjo8P2dTvSauotmAOEU6dkINhQh5d
	 DoU+AFrcSJ9vT/opN7N7EiqxyjDs937bidLe6T3+R+nOjqoMsi6CS9Y3w79JVQK/f/
	 wHAVdHTTvVbEw==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 23 Nov 2026 22:22:02 -0500
Subject: [PATCH 1/7] SUNRPC: Do not read the socket once a TLS handshake is
 pending
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
Message-Id: <20261123-xprtsec-recv-snapshot-v1-1-90564efc4cff@kernel.org>
References: <20261123-xprtsec-recv-snapshot-v1-0-90564efc4cff@kernel.org>
In-Reply-To: <20261123-xprtsec-recv-snapshot-v1-0-90564efc4cff@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2119; i=cel@kernel.org;
 h=from:subject:message-id; bh=XLQpBdJgwNXYqohxxp2Glg5duQ+HgP9WDRZwK1LEeM0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBrBQLhR9GOoWIrGffKhyus3sLApPtv+nzRi0oSH
 cL1wv5kNveJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCawUC4QAKCRAzarMzb2Z/
 lz69D/9Au3Klu+nwsrm9r/qjBBZUgL2EsmcY0/9Joy6XXT8aCD1qe8+vaOtMOThQI1gYGQZE6+J
 baEqGJ366h4ITZvOf6MTEWE3Bw1XZfznxS74CRnK9bdcgf3kpQBuXmrrutVCUBqWcDycCHoq9oa
 yyP1bMu+2QOrFXPBWr/F0BaOE4p972drl+PILpOiVy8X0dwdTt/xbFOyKokKUk1Hd6Nx32eK5jq
 d27WjScWofO6iLE0ADqDyS7hwPLh85zoeuaZ1HWgU3UaHrTSs2HaWfSLUIrZCCMsv3JFvVA+Yez
 kFlkiIK8OQMmy8MlfIGJu+5CXO+Fj3tK+r9aEWEKVOgrNspLyBRlSy4YYGK47P0WpEqz4/toNoF
 X2MnbxGWwMP77KCCWlt4GCfQH+8ue/E7uQGazuMXQu2LqI7R1AO+wM1XaSaXPHoecMLW+a8ETo8
 ysBkKysJ33e1LYKisTSElfyNl2hQaAxYbUh+xEgZ1f6lTVhRk2o/jTzScPKeP9PFMSRdomFoIIT
 WlNxfpWbcfXHtlViE5TSqBbMFy2GtxGOZ9oPBlkE01XJ0WBRe+uTQuSLQKFGhq2gg1/V09JrQvE
 /mFYtqJo5yh1clKely3r+nC6e3gzGzt8cZbrYNUpD9RKtHWnqEz/6WSoTikHhv6AzVcroOKXCwT
 omxM5O1j+PxRbEA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

When svc_tcp_recvfrom() completes a record, it sets XPT_DATA, and
svc_xprt_received() enqueues the transport again. A second thread
can then enter svc_tcp_recvfrom() while the thread that received an
AUTH_TLS probe is still processing it. If the second thread passes
the XPT_HANDSHAKE test in svc_handle_xprt() before
svcauth_tls_accept() sets the bit, nothing stops its ->read_sock
call. When that call runs after the client has received the STARTTLS
reply and sent its ClientHello, svc_tcp_recvfrom() consumes the
ClientHello as an RPC record. The record marker decodes to an
oversized length, NFSD closes the connection, and the TLS mount
fails.

Test XPT_HANDSHAKE again after taking the socket lock, and leave the
socket unread when it is set. svcauth_tls_accept() sets the bit
before the STARTTLS reply is sent, and tcp_sendmsg() takes the same
socket lock. A read that misses the bit therefore finishes before
the reply leaves. svc_tcp_handshake() sets XPT_DATA once the session
is up, so receiving resumes after the handshake.

Fixes: 8962291142cd ("SUNRPC: Receive RPC records with ->read_sock")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcsock.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 1586c8f3c78f..d187674ca6ee 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1156,6 +1156,16 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	svc_tcp_restore_pages(svsk, rqstp);
 
 	lock_sock(sock->sk);
+	/* svcauth_tls_accept() sets XPT_HANDSHAKE before the STARTTLS
+	 * reply goes out, and sending the reply takes the socket lock.
+	 * Testing XPT_HANDSHAKE under that lock leaves the ClientHello
+	 * for tlshd.
+	 */
+	if (test_bit(XPT_HANDSHAKE, &svsk->sk_xprt.xpt_flags)) {
+		release_sock(sock->sk);
+		len = -EAGAIN;
+		goto err_incomplete;
+	}
 	len = sock->ops->read_sock(sock->sk, &desc, svc_tcp_recv_actor);
 	/* ->read_sock stops at urgent data and consumes none of it.
 	 * Only recvmsg() clears the condition, and this path calls

-- 
2.56.0

