Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795490536;
	b=s53xxZLSvX9cCZnjX7igEaINHas/6PVcYjSJwbUByhh6gLmgMMcrq+Ntp5YnOD9zH0UU
	 l8Xym7v4cbgD0Edt8tCDZz9FJ6cDvLRe77cuA+B5oi35cK/Ci/KqSvZ9X1bcXVtPQ3Tvn
	 vaaAHFbqUk3I/9zv/YYKUsPssliOFDd89M8Ig+xzc24hQfcOG4QqQVNqofNi6au1zSjLy
	 +zsoCU0iCUpH82z072Zqnh8SQ9v+luLTxOrBBEBJ1WfiL1m/MNUtyO+WK+mra7lYtFK5j
	 1S5/oSBUnP9eWBtfRHpgt+LBXlGeBz3kTRCTDRzPZkGsFLr+i++zG2NrI7EaVbP65Dg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795490536;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=bVfvvmEjAM/6hgydjnReCt70wQaeDYFwgD80M4CsGls=;
	b=T37vdFGHZ1OOl7CpfpZG/8qJ+YXcSVw8Fquf0AmRnJUybgZi8+z1zPmeOg4CeFcQ/fJR
	 cslypiSWrh6UvEB1HsMKI8GzgBpKJrd4jrkxy2ZHeX3/xoFiqxSm+Ro8fKCOfdLDEGoBd
	 MxGiuNsWHIa6NwUkoEUIUgp/69ZdBjz+uXwGOEuYIFLsVTz681ITTtFmCfERygDVYPOVN
	 JLTR7b/CB5l0t3OpEbSq3bV9Xmmw/cPDoj5ahyykfB+APhJKQ0DjeGlD4AGLKqFMBJWQa
	 jkCRmPXyTJMbz7ObAM0rS9ZJ1usp6PPYsKMvN8bluQX1aci3Y5QojwVgoJ4FBmLs9lQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=H0UDfE8h;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 95695606A31E
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 03:22:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=H0UDfE8h
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7C5EA1F000C0;
	Tue, 24 Nov 2026 03:22:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795490536;
	bh=bVfvvmEjAM/6hgydjnReCt70wQaeDYFwgD80M4CsGls=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=H0UDfE8hY2/jxUJAfiJi2sNELycFDEw64alg6v2pPMyfX7jj7QL6Lk9H1RNjLyoWy
	 dPaiKjJeAOcFlgjiwzZWpsqFnvmzrQQOA94QIthuPwlCib4Ur7tC3tx2o1J25oJuk5
	 LQIwFjNLdiGD17kyYlwdqVbBjulwJ1pYl9xlZLtrkjDjSOZuWTezsTbGiHKc14UpQO
	 tWHE5Eh2cZGkXbJfYgdgEt7NU8mp/vDDHnZh48KvFPxXrF75R3c7Fokm7Uo6qRR2hn
	 AfG1/y9ZE+LCnMHfGwOU8rhg35CJJTrssbVl/OzgxfynWOqrbAmENxOLFtt82mpwak
	 /F3ivZGgZDuKA==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 23 Nov 2026 22:22:04 -0500
Subject: [PATCH 3/7] SUNRPC: Close the transport when a handshake finds a
 partial record
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
Message-Id: <20261123-xprtsec-recv-snapshot-v1-3-90564efc4cff@kernel.org>
References: <20261123-xprtsec-recv-snapshot-v1-0-90564efc4cff@kernel.org>
In-Reply-To: <20261123-xprtsec-recv-snapshot-v1-0-90564efc4cff@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2323; i=cel@kernel.org;
 h=from:subject:message-id; bh=zpTyat+CM7eRau0mJeXocDa4TIV7+RwYdgf/KOackzQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBrBQLhGND87g1yQWahBpHj/cgRkL0RjmdmsoR6O
 R4P7hzGlXmJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCawUC4QAKCRAzarMzb2Z/
 l7i8D/4s+yBpt37oHk4kwbJEz4UCDcbITOui2LKJb31rVEKeWZNP80TOwglNzksDYVt26FvHX08
 fvT8+IsKnhIVKBdaTfF890cBW28BCgxd9uu9x0C3cu4dgMRV5Gzy1Uj3rRK0Tpg9sVxt0HO9MAx
 aNNDH0dELAhvNI/ucz0i3wxjQNRIw/AJ6OYqdtFUzSppemhmNxmtgGYPQq1KyK9zubuy28ofG6h
 3Z4MbhBTo+n76szCgBUYeOCav9EiiNxDzHTxrpjG09xPvBH97M56SerKcUf+bGuiYBHgsnpXVpo
 ogw/ScGiykCVbNYxsT9BnwdYpmBe6ez1cl1krapsl0nnz+fGxJ7km+7AJvBaGKqJXZBj0s0b1HJ
 G2obekqsRjrHfewtMGAis7Rl1X75rt+785s+Kl+ElOAN3mmTOJt6wsG3/uqhkcuREUEi/1ca5JH
 Qn/sw2848Rmi5J6RxnZDcDJXahydoif70+W/GRc35tZEYYs0idNddvroVmkkKScUC6pC0qRsxpr
 3vfiWeHK26ps+Kjz7GIGoW0Waar0IV80+LeIhPRLTuLzDZlPXBxoPcci1fXAw4qnR08dtBiklwM
 JP73RRz7p5oMDA8ghijpPuTAErlMpz4wR1hxoWljd5Gq/Etz5g2GBW0capbYS7t7BLCaVzJwi1u
 j8gjgvkn2vYNDNw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svc_tcp_recvfrom() releases the transport with XPT_DATA set as soon
as it has read the AUTH_TLS probe. XPT_HANDSHAKE is not set until
svcauth_tls_accept() processes that probe, so another nfsd thread can
call svc_tcp_recvfrom() on whatever follows the probe in the meantime.

An on-path attacker can append bytes to the TCP stream right after
the client's probe: a record marker and most of an RPC call.
svc_tcp_recvfrom() keeps that partial record in sk_tcplen,
sk_datalen, and sk_pages, and svc_tcp_handshake() leaves the record
in place. Once the handshake completes, the next svc_tcp_recvfrom()
call takes the rest of the record from the client's decrypted data.
NFSD then dispatches a call the attacker wrote on a transport with
XPT_TLS_SESSION set, and the xprtsec=tls or xprtsec=mtls export
check accepts it.

RFC 9289 has the client wait for the STARTTLS reply before it sends
the ClientHello, so a conforming client never leaves record bytes
pending when the handshake starts. When record bytes are pending,
close the transport instead of starting the handshake.

Fixes: b3cbf98e2fdf ("SUNRPC: Support TLS handshake in the server-side TCP socket code")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/trace/events/sunrpc.h | 1 +
 net/sunrpc/svcsock.c          | 6 ++++++
 2 files changed, 7 insertions(+)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index ff855197880d..dde2d7dac305 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -2090,6 +2090,7 @@ DEFINE_SVC_XPRT_EVENT(free);
 		TP_ARGS(xprt))
 
 DEFINE_SVC_TLS_EVENT(start);
+DEFINE_SVC_TLS_EVENT(partial_record);
 DEFINE_SVC_TLS_EVENT(upcall);
 DEFINE_SVC_TLS_EVENT(unavailable);
 DEFINE_SVC_TLS_EVENT(not_started);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index d187674ca6ee..c6d5adb78cb2 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -424,6 +424,12 @@ static void svc_tcp_handshake(struct svc_xprt *xprt)
 	};
 	int ret;
 
+	/* A record that began in plaintext cannot finish under TLS. */
+	if (svsk->sk_tcplen || svsk->sk_datalen) {
+		trace_svc_tls_partial_record(xprt);
+		goto out_close;
+	}
+
 	trace_svc_tls_upcall(xprt);
 
 	clear_bit(XPT_TLS_SESSION, &xprt->xpt_flags);

-- 
2.56.0

