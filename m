Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B03B73B42FA;
	Fri, 25 Sep 2026 19:16:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790363804; cv=none; b=JNCP2NLIkg4LofhQ2Z7WrqWNkBE0qK3AtDcMYr109++6dxDSugqftuXQoSKWDhH/orsi22dZ6gxfh5Aaj1UWnujE+CtJO8wmbLGukCoqMKH+rlwvDnzquKiLBZ5MtKi4J04Gel+TrW1IZiy3vAEbIU0AjoYOFNS+RTWzshiGTK4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790363804; c=relaxed/simple;
	bh=OQvlxbgMDbQ+XQWdp56aG6emwbq6XG4UwEBtQiZr1N8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=t+WW61W2+fMDevIXb6F2LCWJQbmulheU7EgOaxNTaDZmxxRxh+WcODjGQIfNjfqMzo7CkjG8H6r9g49QQpCyoROrU1/+x3lOcdEoM/9Tf9ffZyNvhrlo+GwSI41qm9oEFUdx2vNHTDfW+xoTmqLwgSrjw5zm2VCQvDV4lJabKGA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nrh1xMhM; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nrh1xMhM"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 25B161F00893;
	Fri, 25 Sep 2026 19:16:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790363802;
	bh=2T6wiFEwIPQwrpaVCtxnzBQrwyoSW9kJbaH/USmDhCk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=nrh1xMhMbR72KYdoilElKB8rDNJcJab91mVf2zYJukFmF+1R9gvJsx/uwfJMdMIAw
	 0wsXHAaoJUH7b+l/9/3vkY2+0XnmoNAVR4UDPuo5Bq+CZCxhuGY/VNIYgICEoJTF36
	 hRfp9CW/yEl3tN+MtErW+ay0Lkdfl55e+DbRlvoHCQTpI3RZT2pf1yhOYHxxRaOQUQ
	 iyNZ4uUO7gk9Rteq7tKjPC7EnRb+2aaLOP+GxXDYWFl009tQCfcUqinhz6a17gPHBG
	 Y00D/Ls2CYCVVsgF+M+m+95Le2mmrahWZ74IBHNmO3SA3reUKNErRjRNm/sOFub3gM
	 EHu6TP6KgiPlQ==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 25 Sep 2026 15:16:25 -0400
Subject: [PATCH RFC v2 3/5] SUNRPC: pass a keyring serial number to the TLS
 handshake
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260925-nfs-mtls-identity-v2-3-aa3ad17dd6c8@kernel.org>
References: <20260925-nfs-mtls-identity-v2-0-aa3ad17dd6c8@kernel.org>
In-Reply-To: <20260925-nfs-mtls-identity-v2-0-aa3ad17dd6c8@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, 
 Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
 Shuah Khan <skhan@linuxfoundation.org>, 
 Randy Dunlap <rdunlap@infradead.org>, 
 Christian Brauner <brauner@kernel.org>, David Howells <dhowells@redhat.com>, 
 Sagi Grimberg <sagi@grimberg.me>
Cc: linux-nfs@vger.kernel.org, keyrings@vger.kernel.org, 
 kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org, 
 linux-doc@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3051; i=cel@kernel.org;
 h=from:subject:message-id; bh=OQvlxbgMDbQ+XQWdp56aG6emwbq6XG4UwEBtQiZr1N8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqtsiT2PPiQF+qqQuJJ0lLf5YUyfkP2ybuilz45
 Ps/jf4ip8aJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCarbIkwAKCRAzarMzb2Z/
 l35iD/4uL1L1JoROtw0NR+6oOZE9hm9YF+OKGOtv+z4JB3XeDaBPS7o2cCEJc4eChvKZqvuiZl/
 IyJGFqqQNjCibHoo+Q8w7DPdJd7m+duJtaWhiAiArA/KktgRa2R9mCj3xvqPLbyku4BoqO3XNUp
 mgOfjbTdMO94pwmkEvx1dA8N/J808DwZJkzwkT3IxcHbe8FkUS7sJEvH3eodJ3HH0IpMZEQxQzR
 DhhYNeJY3+t800BO2o9Q5bz/vFm1PyG6Gpn1Ug+s2pD8l8vBdVuCyqSByDQ4Kkqeu6cl+7KFvql
 pjCrJIC64iHl2Ek7ltvGDsRBwmAbbPLo4MeU1/gHczv+oX2dG2kdR0VXXrElab5Wd3pW7yfiLMK
 c08RWn5F2TjF9QYTCnIQrLM5xsWtTnUKvkl/F6DQ3cfTyrrUGf1zbBhBQKgNUh4mgPByHANES7W
 lnWGUs7ge6J5eQDtluUeNlzs972cNjAEVQezVzerasZ/AWKP1OPSkce1iqCybFDYIDF75fDyMOx
 TBFjRKmE8RXT0e8c9QVjEmCTT0qgs1tFyrTqqykr2v5i7RqcafW/+dyZbFlbB1MZA9HbFeykeLJ
 Wok55dCUZHYaAva6wcbhHrLuWAukmWO36vTq+UuVd57larp9KFonHrBHOY2FQrMCp6Or1qw8u/d
 FnYMrGuZ3pLPpAw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The handshake upcall links the keyring named in ta_keyring into
tlshd's process keyring before tlshd reads the client certificate and
private key. That link is how tlshd gains possession of keys that
grant no user read permission. xprtsock never fills the field, so an
x509 handshake can present only keys that tlshd's own credentials can
read.

Add a keyring serial number to struct xprtsec_parms and pass it to
the x509 handshake, so an RPC client can name the keyring that holds
its credentials.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/fs_context.c         | 1 +
 fs/nfs/nfs3client.c         | 1 +
 fs/nfs/nfs4client.c         | 1 +
 include/linux/sunrpc/xprt.h | 1 +
 net/sunrpc/xprtsock.c       | 1 +
 5 files changed, 5 insertions(+)

diff --git a/fs/nfs/fs_context.c b/fs/nfs/fs_context.c
index 1967de7d1dff..f8f5f8b2954e 100644
--- a/fs/nfs/fs_context.c
+++ b/fs/nfs/fs_context.c
@@ -1750,6 +1750,7 @@ static int nfs_init_fs_context(struct fs_context *fc)
 		ctx->minorversion	= 0;
 		ctx->need_mount		= true;
 		ctx->xprtsec.policy	= RPC_XPRTSEC_NONE;
+		ctx->xprtsec.keyring_serial	= TLS_NO_KEYRING;
 		ctx->xprtsec.cert_serial	= TLS_NO_CERT;
 		ctx->xprtsec.privkey_serial	= TLS_NO_PRIVKEY;
 
diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
index 5d97c1d38bb6..c5d8278838b2 100644
--- a/fs/nfs/nfs3client.c
+++ b/fs/nfs/nfs3client.c
@@ -101,6 +101,7 @@ struct nfs_client *nfs3_set_ds_client(struct nfs_server *mds_srv,
 		.cred = mds_srv->cred,
 		.xprtsec = {
 			.policy = RPC_XPRTSEC_NONE,
+			.keyring_serial = TLS_NO_KEYRING,
 			.cert_serial = TLS_NO_CERT,
 			.privkey_serial = TLS_NO_PRIVKEY,
 		},
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index b661f446ea49..05df0fcabfb5 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -809,6 +809,7 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
 		.cred = mds_srv->cred,
 		.xprtsec = {
 			.policy = RPC_XPRTSEC_NONE,
+			.keyring_serial = TLS_NO_KEYRING,
 			.cert_serial = TLS_NO_CERT,
 			.privkey_serial = TLS_NO_PRIVKEY,
 		},
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index a82045804d34..005730623f3b 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -145,6 +145,7 @@ struct xprtsec_parms {
 	enum xprtsec_policies	policy;
 
 	/* authentication material */
+	key_serial_t		keyring_serial;
 	key_serial_t		cert_serial;
 	key_serial_t		privkey_serial;
 };
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7f60723fa64d..2825dec82d6e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2636,6 +2636,7 @@ static int xs_tls_handshake_sync(struct rpc_xprt *lower_xprt, struct xprtsec_par
 			goto out_put_xprt;
 		break;
 	case RPC_XPRTSEC_TLS_X509:
+		args.ta_keyring = xprtsec->keyring_serial;
 		args.ta_my_cert = xprtsec->cert_serial;
 		args.ta_my_privkey = xprtsec->privkey_serial;
 		rc = tls_client_hello_x509(&args, GFP_KERNEL);

-- 
2.55.0

