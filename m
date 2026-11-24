Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795490535;
	b=ADkjIItmbL/imZh+aQoeW9KI2K9zqXfbDSdyFiZquDNn06GMuMA0C9SnFRLgqryxw9mD
	 8Je87QRMqs1ASioMB2/n3tT6T99EIE9qkwh+nlvQA3AXlN5Bh/BTwYkCMEdbYwfdfYzdq
	 YYQbQwwBNuJeJQRMQeEeVPi1k+zeCots4Re7dsPR2u83ww/RqYnJ2YoaGsKUKHfg01vom
	 zsmMAYh9FDqgOHv2m6A5UIbhZWD64Q5CrMWhoJQEs+X2+3L4HkJ3sldZ8FeTtn6v9kCjW
	 qT2AQMQ2TpV4NU/6Wn7iMA5QuCc4EgCqPKzMIpEgJukRDCPXfW6u8GbHSQ6q5y5gmOQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795490535;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=5ksqjsvE6TG7slVQTeN+mGgQEe9gIBPWHjqw+DhIogk=;
	b=A0B3GPnkCRYnOng9BPOwMfMANgTxQXEfKgJfdMM0AH9tEvdNtBhMyvLFKUmnDWA4Tjad
	 EoykMEnbMjj1xGhioiSPBst08cdxXzkR73IGmcspwBjQrmp50FqPsxVeYNfUcnQ38sypw
	 MRlhSlXrpZ7BVn+8rp5pp3yhS27cdvmGZew6qlRb8W7oLJzVoM1CZ4NXcQ6TGB5j+9XD3
	 RVJt7T0hPHjufvW6il0ahGB6n+qgZwQapkUiJaYAYwy4M248TzR6YOsynGE0pOsUcvPxo
	 WnjE5OfPHiADKsIjfw1Byoln7UhEuYpYg1KGWLJKtEeeMpoD3japVmlybCJk0dEkE7g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LdQSRFID;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4C3C5606A31E
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 03:22:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LdQSRFID
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 14EC21F000C0;
	Tue, 24 Nov 2026 03:22:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795490534;
	bh=5ksqjsvE6TG7slVQTeN+mGgQEe9gIBPWHjqw+DhIogk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=LdQSRFIDRFqnz7DD/vvsaLukt5DRkba15isXMZ1oIwCykvF1LW8XRZlCMnhzz3TJB
	 ktnSa1+hSf3gkXO1hLzoncDOi9Aaou/M+OlMo/BhypbeGlVbN0Dfp4rbrxOmbdaTb3
	 smzN/I7LGgcybiHxy94JLhoyiVq1SS6WU2wk1gMLjKQQB3UEevMIHOV/gX2p8xVw0l
	 BCjAcRj6Q8h4M9Z0GXnJwxuOV/gfGpsu22vuFLkAodcNIngS9PsPeBj5c2g9GVKw0S
	 +HOx7tcx5V4gAzYazfFoFWD2ex5pXDg4Bo9zfYaggk5rbSp2QlT/fxSWbqKkt4Pewu
	 0F5YRSkEQ2AuA==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 23 Nov 2026 22:22:03 -0500
Subject: [PATCH 2/7] SUNRPC: Check for the backchannel first in
 svcauth_tls_accept()
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
Message-Id: <20261123-xprtsec-recv-snapshot-v1-2-90564efc4cff@kernel.org>
References: <20261123-xprtsec-recv-snapshot-v1-0-90564efc4cff@kernel.org>
In-Reply-To: <20261123-xprtsec-recv-snapshot-v1-0-90564efc4cff@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2017; i=cel@kernel.org;
 h=from:subject:message-id; bh=3RpepyWiLgXTbn8vOSEyacS4HptXrdp7FllZm5LdWhc=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBrBQLhAvNvK+7i0TxIt9SOzHzPzAuFw7AfJsgQU
 F1UOXVUfRuJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCawUC4QAKCRAzarMzb2Z/
 l1Z6EACGeB3FjcYOlnS2yaB/1mP7tMJP4XdN9mFLP6or4aC/6TQZUzdyRldayGNJvPIiMewC/zn
 OAsYnPM4aWAB2t6dCQYaNVkbmUU0sPLF3yCHVUUWA3OkcU0okkK3cOslezxzcNbD4ZK6ktaojSa
 0VwEwI1ppVnKRzXnpyamgeCNOr8e32i9c4152NNLsDtxdwOKLaKDQRW8HWx3F3Dge1lfjnTJojS
 aSNM09KcXNajNeYQBOlWdSesKVraNQ436eMKXlbZvlaxMl1yHucv2p2Dr19WxfMlfeSSG0WOq+b
 d5khDlR8AMcSK7DlK47r9mDk8w94F6o4/mBuw4VOYR19Mq0JGNuMQQ6hB/P4pQ8g+2n7vfsLOp7
 kXFJWBFjGyXEHhQGsZNVKGa+lxpzeETEk6sHPnpiWff0iY54JwNoi64QjLfTXmBSXfN/Bwi8Su5
 +FyfQ9E21RPsd9BRpZktE0rcfHteAm29Lh8O+dNGW9H7HLH1w3EGpnqKTSXo0odsD4+PVeQckIF
 2ZlvCt899aC7gKoQxHzYvri3cOAo2OkAfxdw5sAKEhtlgByDvnzeBerlgrZzKCs9pEGJIIK72+D
 JSSoeqsDglLiJss36Y5b6dmGzavXp9hTF7wjdaakV9XaxMabBFjCtgJDi8KtahjgEoafsLSJ+AC
 2BuOZ7C9PI4uh/w==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svcauth_tls_accept() recognizes the NFSv4.1 backchannel by testing
rq_xprt for NULL, after it has decoded the credential and verifier.
The test is correct only because svc_process_bc() never sets rq_xprt.
Nothing at the check names that dependency.

Call svc_is_backchannel() before decoding the credential, and remove
the NULL rq_xprt test. svc_xprt.c and the NFS client's callback code
already use svc_is_backchannel() to recognize the backchannel. RFC
9289 Section 5.1.1 specifies that reverse-direction operation uses
the TLS session already on the connection, so an AUTH_TLS probe on
the backchannel never starts a handshake.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcauth_unix.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index eeb8972ed654..0c4654c2f6c9 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -6,6 +6,7 @@
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/svcauth.h>
+#include <linux/sunrpc/bc_xprt.h>
 #include <linux/sunrpc/gss_api.h>
 #include <linux/sunrpc/addr.h>
 #include <linux/err.h>
@@ -1116,6 +1117,12 @@ svcauth_tls_accept(struct svc_rqst *rqstp)
 	void *body;
 	__be32 *p;
 
+	/* A backchannel cannot start a TLS session (RFC 9289 Section 5.1.1) */
+	if (svc_is_backchannel(rqstp)) {
+		rqstp->rq_auth_stat = rpc_autherr_badcred;
+		return SVC_DENIED;
+	}
+
 	/* Length of Call's credential body field: */
 	if (xdr_stream_decode_u32(xdr, &len) < 0)
 		return SVC_GARBAGE;
@@ -1138,12 +1145,6 @@ svcauth_tls_accept(struct svc_rqst *rqstp)
 		return SVC_DENIED;
 	}
 
-	/* AUTH_TLS is not valid on backchannel (rq_xprt is NULL) */
-	if (!xprt) {
-		rqstp->rq_auth_stat = rpc_autherr_badcred;
-		return SVC_DENIED;
-	}
-
 	/* Signal that mapping to nobody uid/gid is required */
 	cred->cr_uid = INVALID_UID;
 	cred->cr_gid = INVALID_GID;

-- 
2.56.0

