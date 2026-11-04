Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793801476;
	b=zJ+trEsUo4MefZ7gP2FP4fgHjvEOUzVy/+LXJPClN8RAm650la/auz1Q4NqKSESunfWL
	 Vzru0VPFbeWvruYhKWN8QNuqsF8gob6/OiAQbl3HEyWmEWC9knee2ijvb9IbqR8LgnP96
	 srHrBJ39qDywP6Gk1dxHSMSZOd9Hl9z86WTqyWOFCC/qotL9KWJoG6MRgAIevXoYlrp0I
	 JN6ruc5m7Gs5vNspg5SCNG8byE1HwefwiFRCqaLAgZ0k+Dp1FNSml2ceajBTMjicMeQth
	 oYIrzqj+7BEbEhowLQczwRn5I+pgZ0783v+7R2bK+XpoL/f7skZ4F9I5HaHoJmpIVZg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793801476;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=xV477epFviKsmaszl55lgee6+nC/JrmaD78Xje/EaSU=;
	b=HOez1kUVKpeS9bfvTdAr7+J5wRvLi2kBCfVBtsJgTrkNv6fVoUyVWdWno9cM0AAtod+g
	 hYVazQfRbe7zZ+HEgclg7WGTf87XgS7DggR0Gqr+lTrDi6gW5vopIBQ4kczOf+oMMkh4F
	 GpQJhwinKYdmvZLOs51mD6+MtP17vTLjZl/3qi6PykeK0lqjZNgP9cWGKyzyrod5FZO44
	 W0gAq5FHFoyXmyTrT+mdeXxkpKT/MLu4y0mwKn6sTF0Xkhconf4PQetRs7Pcpi/F2SUzp
	 gpd3VoSIpQFFURPnLwFnYUO2Z06GfJjay7dE9AMCL1UZa0IqIpRUe/R4L/kK0GfEKsw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kBTcQMDf;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4E563606D812;
	Wed,  4 Nov 2026 14:11:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kBTcQMDf
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4975E1F00A17;
	Wed,  4 Nov 2026 14:11:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793801476;
	bh=xV477epFviKsmaszl55lgee6+nC/JrmaD78Xje/EaSU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kBTcQMDfIfhgGCB2H5aYQxQRMvLdNKH/d+5O2po0CccPDxREQjjx7ULlVUCMV3KQ7
	 nGJBs1Ii7V/gEzgz1aNzZubS1T+coejkXwh3fIO25OK97FV95pWVSv6nFH9M3VzQMU
	 MdXSus9nY15Mo8+C99IWC2ri/JdxnbOrQ7PtsrJA2yggGlzSY3EBcCkEMSatxDVMwD
	 Hvcw0PjGlEeEOCiHBmWw/FL+zIQPKUUBO2CIayHfNximvDUGjig1thCDZ+3OWPbmYb
	 NCKtTuKX1TrAmPfik/PvKv2UYjK6xLUdWmc3GHzKYLqDaCK3dW3V9PGPnlr6qzC4eA
	 Er/OItBMDbmxg==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 04 Nov 2026 09:11:01 -0500
Subject: [PATCH v8 01/14] SUNRPC: Reject an AUTH_TLS probe inside a TLS
 session
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
Message-Id: <20261104-duplicate-reply-cache-v8-1-eea5b90e4318@kernel.org>
References: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
In-Reply-To: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1494; i=cel@kernel.org;
 h=from:subject:message-id; bh=bRiCz+D0MM4tKXKtXLNBsAuhCgKqmhqHujaY3f3WiHM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6z0AQGmAAitZ3BEPrTChKFDBHo+LouZZbFNqN
 TLLkAFAYfeJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaus9AAAKCRAzarMzb2Z/
 l/3zD/9YvN5C57dhj783PdgsiyhyKOCPllnCSShvZx9qQh9cfLyas9bjVBPhyTpJHlaKsOl2AIl
 SgxMF6AelhxVjUs3Kih+qjBywCBbe5oSunRd4R2LEiEyKF27Bpr8ehZD+dvI2V5BwhbogUG4Jja
 RBdSyPyhcVE4kNrFRnVjM7sl9Rsl/ImZUn/m4kw3tTU3ISlnRZVMQE8xwz5zQ/hcqBhknCU/jV1
 HKf4KFcFSpQdmbGHKtDm8YMsCsHPqhGXPFi3iu/r33UAmNXS4gY2XbfDVjKxsrScz7O/wZ9QxQw
 iPRk39W45dQPMekcwMUtc/738rsiM+lhhd8sv197kqK1Z7HcIAgo93o5W0pNYVxeyndWFCqUJqk
 hBjD302TZQ139mEkF9sw4HMYt8fNRyLkJJJ+nRjCnRHPEpbVb+aoU71M5s9SeZbalPnJuLxHJ9t
 CU7z9TDMpGZwmKjY3x7V+qXSdBLBvJ9aC9WelYUnQrLbnFN1nXQUJQsAzR+WjDatO+Vf0rqvPfC
 95M8fz2fnTLDwlk0Jqssdp2VvZdvyODIcpyncs8H/kg7MmyPwBWomwVJh8nPYLEQ1CmfGCvlgxA
 yRwbQt/+srcE90TKazyD/b3p5BZ/CaFq7KTyf2jtyOJE0IbsMyhoeSrnEAyQDZpnQOUWVF9mF9k
 eQ2Di0RFrnI3ODg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svcauth_tls_accept() accepts an AUTH_TLS probe on a connection that
already carries a TLS session. It sets XPT_HANDSHAKE, and
svc_tcp_handshake() then clears XPT_TLS_SESSION and calls
tls_server_hello_x509(). The first handshake_req stays hashed until
the socket is destroyed, so the second request fails with -EBUSY and
svc_tcp_handshake() leaves the connection open. The kTLS ULP is
still installed, but XPT_TLS_SESSION is clear, so every later test
of that flag treats the connection as cleartext.

RFC 9289 Section 4.1 requires the server to reject a probe sent
within an existing TLS session with AUTH_BADCRED. Deny the call
there, before the handshake is started.

Fixes: 74aaf96feaca ("SUNRPC: Teach server to recognize RPC_AUTH_TLS")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcauth_unix.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index ad8a73653e42..fee7e20e2e9b 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -1144,6 +1144,12 @@ svcauth_tls_accept(struct svc_rqst *rqstp)
 		return SVC_DENIED;
 	}
 
+	/* RFC 9289 Section 4.1: a probe inside a TLS session is rejected */
+	if (test_bit(XPT_TLS_SESSION, &xprt->xpt_flags)) {
+		rqstp->rq_auth_stat = rpc_autherr_badcred;
+		return SVC_DENIED;
+	}
+
 	/* Signal that mapping to nobody uid/gid is required */
 	cred->cr_uid = INVALID_UID;
 	cred->cr_gid = INVALID_GID;

-- 
2.56.0

