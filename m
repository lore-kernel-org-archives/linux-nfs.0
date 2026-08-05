Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 851A43D3D1A;
	Wed,  5 Aug 2026 18:31:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785954675; cv=none; b=YpZ2JvlTAqYhZkZkGGK6FTw3PkqQQFkIFCySE0IXUmASbcR7MmYbN6v/I2jcTXBd/SWapbFhtbdcE+rU5aucMUkG/Jar2VnH6sLtIAGbPvV/pfT2/F+zUeGGJNXTGhTxNFCcEggLzvTSmBersUGn4QCjiEtKQjgW61U4CttrEFY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785954675; c=relaxed/simple;
	bh=L4LM1/3oSaW16hJiOgA+Pkpj/9Y/vZbJrc6CmZuniIM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=iaGjc3rQeGMxS2RfI+di18ZXuJ0AkKA+dpcZvTGBFDr4FwLMgC8+ncnOONMSF8b3YTKi28ZjLawsmGJgYJrn5T5PcJ/G++vNGlnd3ASNPVIL/QyQcwRDcdP7+MQvj+abksguYU1qsU9iIQnL90pvEntGkTbnHVDgUXYy1AcQ7m0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=i6UxlJR9; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="i6UxlJR9"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3D7251F000E9;
	Wed,  5 Aug 2026 18:31:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785954673;
	bh=5x8qH8h8i91sM1ShXWknPkWeurJH1ckKHH1kHiukSLU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=i6UxlJR9vFuZrvdrdiFcAiZdG10FMaWwp1Mcqo/qIkRz9o2z/8ZDEgAVYfMYM8eIs
	 91BUoes7E59zzJlIW/HzVulMPNMBYKCqY5xsUtqVGYYeZAvvt9GMOkFq0zVHbIJQMH
	 XWJKRiy/v5qUtclrh9FiKfA80Ebk/XMcZEZwHB8jYpP2ApE8xrO5du5MClcZcc82oE
	 xdr/4XHSlVyW7a2qPySj5i4OZB01b7oSQZ04RcmLEBV1GHDVwLy0Frzr6SQIw9Mvzv
	 n61Iy0KQsPl0MizHCzvhfJKGdU9qA1t+jHd/527205+h7AfvDCASv+4ktL5uBGiJyb
	 x5zRGD1YAj2dQ==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 05 Aug 2026 14:30:55 -0400
Subject: [PATCH 4/8] SUNRPC: resume receiving after a TLS control record
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260805-svcsock-cmsg-fixes-v1-4-43514a32da9b@kernel.org>
References: <20260805-svcsock-cmsg-fixes-v1-0-43514a32da9b@kernel.org>
In-Reply-To: <20260805-svcsock-cmsg-fixes-v1-0-43514a32da9b@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3819; i=cel@kernel.org;
 h=from:subject:message-id; bh=L4LM1/3oSaW16hJiOgA+Pkpj/9Y/vZbJrc6CmZuniIM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqc4FrGnYotuBuKm01CS4M2rRpldbVr70apCTvt
 9piYXFzfp6JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanOBawAKCRAzarMzb2Z/
 l0hwD/4rxmV4BlaOYShgGR6VkK+NwcP34eaqC+1NHPlZvGSjrbCKHsUpjZUyscVb3ity358/3uR
 R1pYm2tX9vwJIZow7em1oZSytCFip6psm4aGpAB9qKc1+AhA7WPqUkX6AKbymCmRjGsy3YH6Cwy
 ISqFKl/Ktwpub+rCf5qJFRWyHdgyheya2kVqcCoJh+aT9gudxafgaNjIzTBd9aqrFD83ou/AoXu
 eENVT6JoPXJmvrdglIqdPECGHctBGKHSUg4t1wgEdCwITN/Eb664Bdpzgqih4nP2W88FvKlak+n
 X2DGyw63MAZOrzOC+KZslEGzCf2pGL1G/CAuJKKJ8xjBRCvbzX7vk/6zYoQRu0nPtiWCFtxQXWE
 M2wvUSKDZ75S1DzX2kQdhiLrDIRn/TVJVRphfyAL4PTFobV+LaaQ9ihX/Y9TkgGmBJKEYnAFn1l
 qkrLZVGnyzPlbDNbS42/Ive0ibkMhsKhBcWPpvEeDakPV4mQ7dNVzkrsgX1P9R3SwI4AVQFW2N9
 lSEmwlgSjFk/vmxGpsv3uOmtXjXzDSB81BU0j/DGMvTFCSKs60IiJrF6XAG27P2J/8zOWOmdKBF
 r13ZF2HTxjGh3nhFR4u3Ab+/5CShTdWOh+VWZcN5HwqbdFdFj7Otp2PE9AyfxzOOTaTokkWFz6q
 X87pnu+aGoidrmQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A TLS control record delivers no payload to the RPC layer.
svc_tcp_recvfrom() clears XPT_DATA before the receive, and
svc_tcp_sock_recv_cmsg() returns -EAGAIN for the record it consumed.
Nothing marks the transport ready again. kTLS raises data_ready for
arriving TCP segments, not for records it has already decrypted. An
RPC Call queued behind an alert or a KeyUpdate waits until the client
sends more. The client blocks until its RPC timeout expires.

The receive takes only the first two octets of the record. kTLS holds
the remainder on its receive list, where each later receive takes two
octets more.

Drain a record that is not an alert, then mark the transport ready
once a control record has been consumed.

Fixes: 5e052dda121e ("SUNRPC: Recognize control messages in server-side TCP socket code")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcsock.c | 55 +++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 52 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 756db84e4aec..d8e836e0832e 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -238,6 +238,39 @@ static int svc_one_sock_name(struct svc_sock *svsk, char *buf, int remaining)
 	return len;
 }
 
+/*
+ * kTLS delivers a record only up to the caller's buffer and keeps
+ * the remainder on its receive list, where no further data_ready
+ * announces it. Consume the whole record.
+ */
+static void
+svc_tcp_sock_drain_record(struct socket *sock)
+{
+	union {
+		struct cmsghdr	cmsg;
+		u8		buf[CMSG_SPACE(sizeof(u8))];
+	} u;
+	u8 discard[64];
+	struct kvec discard_kvec = {
+		.iov_base = discard,
+		.iov_len = sizeof(discard),
+	};
+
+	for (;;) {
+		struct msghdr msg = {
+			.msg_control = &u,
+			.msg_controllen = sizeof(u),
+		};
+
+		iov_iter_kvec(&msg.msg_iter, ITER_DEST, &discard_kvec, 1,
+			      discard_kvec.iov_len);
+		if (sock_recvmsg(sock, &msg, MSG_DONTWAIT) <= 0)
+			break;
+		if (msg.msg_flags & MSG_EOR)
+			break;
+	}
+}
+
 static int
 svc_tcp_sock_process_cmsg(struct socket *sock, struct msghdr *msg,
 			  struct cmsghdr *cmsg, int ret)
@@ -303,12 +336,20 @@ svc_tcp_sock_recv_cmsg(struct socket *sock, unsigned int *msg_flags)
 	 * kTLS filled in u.cmsg.
 	 */
 	if (ret >= 0 && msg.msg_controllen < sizeof(u)) {
+		u8 content_type = tls_get_record_type(sock->sk, &u.cmsg);
+
 		/* Returning the count would credit the RPC stream with
 		 * octets that never reached the caller's buffer.
 		 */
-		if (tls_get_record_type(sock->sk, &u.cmsg) !=
-		    TLS_RECORD_TYPE_ALERT)
+		if (content_type != TLS_RECORD_TYPE_ALERT) {
+			/* Draining an application data record would
+			 * discard the RPC stream.
+			 */
+			if (content_type != TLS_RECORD_TYPE_DATA &&
+			    !(msg.msg_flags & MSG_EOR))
+				svc_tcp_sock_drain_record(sock);
 			return -EAGAIN;
+		}
 		/* An Alert record carries exactly one two-octet message
 		 * (RFC 8446 Section 5.1). alert_kvec caps the receive at two,
 		 * so a longer record produces the same count. MSG_EOR appears
@@ -331,8 +372,16 @@ svc_tcp_sock_recvmsg(struct svc_sock *svsk, struct msghdr *msg)
 	ret = sock_recvmsg(sock, msg, MSG_DONTWAIT);
 	if (msg->msg_flags & MSG_CTRUNC) {
 		msg->msg_flags &= ~(MSG_CTRUNC | MSG_EOR);
-		if (ret == 0 || ret == -EIO)
+		if (ret == 0 || ret == -EIO) {
 			ret = svc_tcp_sock_recv_cmsg(sock, &msg->msg_flags);
+			/* A control record delivers nothing to the caller,
+			 * and kTLS announces no data_ready for records it
+			 * already holds. Mark the transport ready so that
+			 * the records behind this one are received.
+			 */
+			if (ret == -EAGAIN)
+				set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
+		}
 	}
 	return ret;
 }

-- 
2.54.0

