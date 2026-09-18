Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E26FC3A873C;
	Fri, 18 Sep 2026 14:05:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789740341; cv=none; b=oyJjlcrhXiKyb+5k2VKfj2OJuN3rxrNHd3gD/Iuf5sHvw1qYKJZj1NZ+dajVAEZ8wcp1a6hPPepBQ6LSjdvI3mDyTORmZQbHsM02JsXqJHr8TRmyzLo0Ir5L3GVB6XH1PNeuqLPXxQge/K+1tazLJK9UShlg8HYXaNe9pUr+xEc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789740341; c=relaxed/simple;
	bh=AbL+F1HyIi0v9a+uLESmSwQIwgMnTS8/MYAqfaYVCRI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Dm1RBaxSVAxKY7iTieXmFlvtLo7Xiv12pHcOVQ4igpZP3BnYqtohOFU7TeVK+6VR3ImSxqP+jjPwWuXZVEeIFKvqAyqKnxrQKe0el1etEecXkTQAenksckaGLxpaBcknfPZqVJrVpLPEHb7VIbPMNQzj8blPrueIq2OsqEKxpZ4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=E3bGCspl; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="E3bGCspl"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 286821F000FF;
	Fri, 18 Sep 2026 14:05:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789740339;
	bh=RuGzpEeGZm5iLtjfuwZwIy6S7yHCQcuVrZ8PaQIHj4I=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=E3bGCsplIKTl0vJ7lXBt1nIteJtwkq6vuabOGErMawRKeWTTxdRZFYs6ZsL6qbC4K
	 O0sRWCgvalz9izqsbRlI5ma1KNIoDnR7qCUdOjclEgJ9B7ecMHRnvOK8C1NMBMkjnW
	 vNJ5pzKFHbjcPHDiJuyw7aM8TiYDn8SHykJahhIZKlkGXD47NoTulJ3GQBiFEE+FYS
	 uf+rl4eGRZr/mJosz4C4HziIA/DENIetjCu79Wp4RwloR7wTcLXG9S/LINhggM0rs1
	 3uBGvUaiDWN3hcnbHB8xPElJhaHKnMaZAqVI7VQfCV/2TFuo7Wo02tPix5rZE5tmlK
	 N3jrwOqt2UWUA==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 18 Sep 2026 10:05:19 -0400
Subject: [PATCH RFC 4/5] NFS: name the namespace .nfs keyring in the x509
 handshake
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260918-nfs-mtls-identity-v1-4-197e568d78a7@kernel.org>
References: <20260918-nfs-mtls-identity-v1-0-197e568d78a7@kernel.org>
In-Reply-To: <20260918-nfs-mtls-identity-v1-0-197e568d78a7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2004; i=cel@kernel.org;
 h=from:subject:message-id; bh=AbL+F1HyIi0v9a+uLESmSwQIwgMnTS8/MYAqfaYVCRI=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqrUUr+h+AIWDV+2rXw53b9vljW+tGR6PkowVoY
 wgByvuxfNiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaq1FKwAKCRAzarMzb2Z/
 l47nD/9+W93masR9JVGO8qQG3FbeLfke6BuG97QhNnC5C+LmETNjBEX2JwG9pe4r/B5b54YYYAD
 y6l1EVRULQ/cncdKpyQvCKbJVUd+CwoHUNNY0cCQ3j+WCDQCsHiCLUtX5+YeN4TevRz+D1vUpbL
 cNVMWNrO1MAb2XbNBBtyvC0pwp+Th/VrrOrEyMAs/2or1GfA26QXLEchyExxB76sipT3N4kXRtP
 ZcsPvKey/AT42jFg93PLpZdRom9ZvwPzcT3Jl4doHz4HFme+tf0XFDFga6t/nwZi6z82ZoO2T4D
 xsf8t0MJKVfp/TGNdARnAWgXfVX6dQDJW1SUrPhSwfvd7WDA9X2Xx3fi0DXEsH8Tq4SVArUMrAG
 NbwsOc8PxMWKkHoK8I1+rKzw4xf1ZzAhy614+ch0AE1gP8oKgNdhWDumaGYWmcndl+iFPGk5T0H
 g0ov6HBTNOoY3sMM8JB2rodHGaDdzi2dAtRqxSkrNFn+6D6jP6QLbjKuqX7K0KpuNQYUZCihiTI
 Orksan3yagZFmAYqzOE+4b0CZxKasDR5zIa0WetSU2Yw9fufgX+6GIvVILA9GZOeT7faDGx+2qV
 S968pczBG3ZIWShlJHJVzgKVRhp92Of50O84aF/oKo207rjSxzX2FXEME/y1oltnKGdrjeK5akP
 JpNIfeOo7qo9F0Q==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Keys on the per-namespace .nfs keyring need not grant user read
permission once tlshd possesses the keyring, but nothing tells tlshd
which keyring to possess. An xprtsec=mtls mount can present only keys
that tlshd's own credentials can read, and one namespace's keys are
not isolated from another's.

Record the serial of the namespace's .nfs keyring in the nfs_client's
xprtsec parameters under the x509 policy, so tlshd possesses that
keyring when it reads the certificate and private key.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/client.c | 9 ++++++++-
 fs/nfs/netns.h  | 7 +++++++
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 60386330aeec..bda1d19db527 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -191,6 +191,13 @@ struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
 
 	clp->cl_principal = "*";
 	clp->cl_xprtsec = cl_init->xprtsec;
+	/*
+	 * Every client in a namespace names the same keyring, so
+	 * nfs_match_client() does not compare keyring_serial.
+	 */
+	if (clp->cl_xprtsec.policy == RPC_XPRTSEC_TLS_X509)
+		clp->cl_xprtsec.keyring_serial =
+			key_serial(nfs_net_keyring(clp->cl_net));
 	return clp;
 
 error_cleanup:
@@ -549,7 +556,7 @@ int nfs_create_rpc_client(struct nfs_client *clp,
 		.version	= clp->rpc_ops->version,
 		.authflavor	= flavor,
 		.cred		= cl_init->cred,
-		.xprtsec	= cl_init->xprtsec,
+		.xprtsec	= clp->cl_xprtsec,
 		.connect_timeout = cl_init->connect_timeout,
 		.reconnect_timeout = cl_init->reconnect_timeout,
 	};
diff --git a/fs/nfs/netns.h b/fs/nfs/netns.h
index da0854510404..c8ca7b989f4b 100644
--- a/fs/nfs/netns.h
+++ b/fs/nfs/netns.h
@@ -47,4 +47,11 @@ struct nfs_net {
 
 extern unsigned int nfs_net_id;
 
+static inline struct key *nfs_net_keyring(struct net *net)
+{
+	struct nfs_net *nn = net_generic(net, nfs_net_id);
+
+	return nn->nfs_keyring;
+}
+
 #endif

-- 
2.55.0

