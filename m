Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8659D3D411B;
	Wed,  5 Aug 2026 18:31:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785954674; cv=none; b=ZGQjWMrqcNYztLMSp847iGtFb4dM8IAIg5wlADSeFObSgOMmqeSUXgYYs8fBKwSqddg+zDLGVHp6s1wCDsyKZGLHZN6xaG508ZNOyGDyQihcqwr5FVfJ2ZT2vWMjIIncGL9vK2FDWesuM2bYg7TZBYRDeBi9RBpieCyyYY5Ctxg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785954674; c=relaxed/simple;
	bh=kAZzS+SLfINX6bJlvYzENInhOtMXPsKWQAUWcrsjgsI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=mgyaqcJHfzK+Npybl7AhTbsHpUc8DK0A4m1F/QdkgbSAwbs5xCHkqKmzaN1JcyFalBR8JrbjFPj3XLZy1dyw12TmXxJ1OrUPuFhfmAr0C3BNrmmi9Rj/oWZVUTOPVnX/qBD4db4S6KhBZfWfCCnnjsJwuFueY6zP6cRFvNtJp4M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=PR/Qilrp; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="PR/Qilrp"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3A77A1F00A3F;
	Wed,  5 Aug 2026 18:31:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785954672;
	bh=8FEBPC6zgf2ahd9d6RNFj2SBTAw2a7fa/N/P3lsoNAg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=PR/QilrpGeeDc+DBHgnYnoljk6m4fGcOiMDPYFBSNnKiU2JRLSdAx6i4a8IZuG5Da
	 JYGmwIpazlJgBpmUG4/o5omWnFiNM02+oCm3ex7OLyWdYkS0E0ZB90GsqBXMMREIpj
	 TheXO8G+3uVmAQtsrOlmNK2kjh7i6w7GKqBpU87glZWVzboYFrs6g33H/CpMaC4CHJ
	 4y3KmCGSgsWJGVINUbGDnrQbpkEiDjDGosnuKRgYMgACM+HM5tnUNf06gB6Zqu2Jpb
	 6TBXihgwSsLeUdwjNRqrPvuaLLzjwuxyifxhPo9/WH5b/t5jYcHWLpQt9ZxPDBOzSu
	 yJxrLiu0baGRA==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 05 Aug 2026 14:30:54 -0400
Subject: [PATCH 3/8] SUNRPC: reject a TLS alert record that is not two
 octets
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260805-svcsock-cmsg-fixes-v1-3-43514a32da9b@kernel.org>
References: <20260805-svcsock-cmsg-fixes-v1-0-43514a32da9b@kernel.org>
In-Reply-To: <20260805-svcsock-cmsg-fixes-v1-0-43514a32da9b@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2436; i=cel@kernel.org;
 h=from:subject:message-id; bh=kAZzS+SLfINX6bJlvYzENInhOtMXPsKWQAUWcrsjgsI=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqc4FrwRUlTdH9kPOV1+7e4MVFLJdLK0U23Ey5y
 ovKHGWSPO+JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanOBawAKCRAzarMzb2Z/
 l3jjD/0R6Bu8yLboyjjoteVD9HOma35pNH4UROOLbY92iij9gANfWRo6fpycvPZozvrsOgyC0aO
 9p59wvi/6IM7tjnLreJJZd1PDwPQ0ExourX5FErpqmGDL0UKhmZIpJaRTHURvsfwuKKz/K9vdgN
 H0XvpP5rVHu4kujE4ceXCR29w+XqQOzbjoFxLEnXKNQa8snX/nH6ssQ3V+1z3dpkiqWUvcHStt6
 WOMBoKiHiVbaKN2ArakVyQiy5pK70EWqJwl3OLQaUToe27LivImGslLWlK2Yt/XGjPUnGL3Ob7X
 hyl6tacP68cgKrOoP8lxAE5xNOvX0EeHHmv4D7rNbH22ZiIS3T0BhzIM0Dkxwd32/RBBk/FnwnK
 aPM8rn+F+P5d86bmcLGjpTiMKF0+T1OjTrJZ5KrA67GlxhQR6hiOkgT4iweyx3X4l2kCZ7LQjEn
 YEl/zg9XhYUkyaZNdJ2aKmnElQ4y0iQH3Wy4Lgi4utg9HK3t9GQz8izM/dvrmgI9Ry+bTXr/Pu2
 duLZ5Q+rnckT5p88EvhiAxK9IV7rCa52FlP8HJmWmhcxkY8UenMo6FGMQZYdltJ9CGe1QNdbo2U
 CVUuDq3u+GwK7UZFrwQUdMeaqJkQulZmMf7fnLrNZG/x/9PRvjvswHWFNuntO6L5+V0P1B0aIF+
 /9kOIv92nMbGRrQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

tls_alert_recv() reads two octets from the kvec it is handed and does
not check the length (net/handshake/alert.c). svc_tcp_sock_recv_cmsg()
calls it for any positive receive, and the alert[] buffer it supplies
carries no initializer. A one-octet alert body leaves the description
read from uninitialized stack and reported through
trace_tls_alert_recv().

The peer controls that length. Neither tls_rx_msg_size() nor
tls_rx_one_record() enforces the two-octet Alert payload. A TLS 1.3
record carrying only the inner content-type octet decrypts to a
zero-length payload. RFC 8446 Section 5.1 requires a record with an
Alert type to carry exactly one message, so any other length is
malformed.

Require exactly two octets before parsing and return -EBADMSG
otherwise. That closes the transport rather than acting on a partly
uninitialized alert. Gate the path on a control message rather than a
positive count so that a zero-length record reaches the check.

Fixes: bee47cb026e7 ("sunrpc: fix handling of server side tls alerts")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcsock.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 26780600f6c9..756db84e4aec 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -299,13 +299,23 @@ svc_tcp_sock_recv_cmsg(struct socket *sock, unsigned int *msg_flags)
 	iov_iter_kvec(&msg.msg_iter, ITER_DEST, &alert_kvec, 1,
 		      alert_kvec.iov_len);
 	ret = sock_recvmsg(sock, &msg, MSG_DONTWAIT);
-	if (ret > 0) {
+	/* put_cmsg() shrinks msg_controllen, so a short one means
+	 * kTLS filled in u.cmsg.
+	 */
+	if (ret >= 0 && msg.msg_controllen < sizeof(u)) {
 		/* Returning the count would credit the RPC stream with
 		 * octets that never reached the caller's buffer.
 		 */
 		if (tls_get_record_type(sock->sk, &u.cmsg) !=
 		    TLS_RECORD_TYPE_ALERT)
 			return -EAGAIN;
+		/* An Alert record carries exactly one two-octet message
+		 * (RFC 8446 Section 5.1). alert_kvec caps the receive at two,
+		 * so a longer record produces the same count. MSG_EOR appears
+		 * only once kTLS has drained the whole record.
+		 */
+		if (ret != sizeof(alert) || !(msg.msg_flags & MSG_EOR))
+			return -EBADMSG;
 		iov_iter_revert(&msg.msg_iter, ret);
 		ret = svc_tcp_sock_process_cmsg(sock, &msg, &u.cmsg, -EAGAIN);
 	}

-- 
2.54.0

