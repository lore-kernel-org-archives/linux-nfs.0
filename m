Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 44DE54EF15D;
	Fri, 18 Sep 2026 14:05:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789740339; cv=none; b=b27QkKCAI1LVwJ1IxHiH2H9sLKDaEhk29jwBY2dCAO+g28FIEjhRy0FOPkTYoBKVFKovvvonZrnRUKIHF+QAWbWBktYMrQWHYXIQ+IFxX/ytVf6+3uTfEQTVvyf8dO38kiJfnNnMr8wEzxVhEQtuVNFKS783qurUzGDYTttBkS0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789740339; c=relaxed/simple;
	bh=TzYJ1FZgG1Ma4e4lSEwYq8NmG/ZbP952XVkuDpDBCac=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=onvJguUtYh/k6m4Fb6dbRbit1Fv+akUJiyewWIlI0wXl4sthymCr/xQbSYH4/54UASgjqWm+KTpLCzI9RPO81tn+tQ5J47ECD6D+gLary5xnCZhoN/BL724MyQvMC6B+HtGgW/vQdU9RHMYMzk1uoxQk6oHT/E2CJ1+6Z6jDLbw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UR5WnBj6; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UR5WnBj6"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7F3551F00898;
	Fri, 18 Sep 2026 14:05:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789740337;
	bh=Sj7NjMSsab8fPlZcvqTkEdnd36rHl0AjmJ/EhVsBjcs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=UR5WnBj6V5VrFZsNlw7QwB6TImlCbnrHRgarDKSut6MiC3CGvdJx8JAxjn18/R0rH
	 l6Dk0Ki4OuVo10Bh208FySMaBbc8bUQvH1ctw8bOXLVeAnXbyDDFA3p+80AllT5eX+
	 PlGJeZy0ho6tgYquCju5tY3oWvhyjywopx4m6E+SA3TboJ4QHygWOVnxjVOjM3ACPL
	 ff7hMUADUxatQhM+N6bCftJjAsWIJl0XljA6vHkk7rLL75e3+0u3dREJHOOYUW3uQE
	 LmX8TIU6y2KSJ26czFXkVMSyIEPbGH1Y/IbJjqva1upC+mxCtvSvd9i7T4ljgu4Sps
	 z1db9t26m2DKg==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 18 Sep 2026 10:05:18 -0400
Subject: [PATCH RFC 3/5] SUNRPC: pass a keyring serial to the TLS handshake
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260918-nfs-mtls-identity-v1-3-197e568d78a7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3044; i=cel@kernel.org;
 h=from:subject:message-id; bh=TzYJ1FZgG1Ma4e4lSEwYq8NmG/ZbP952XVkuDpDBCac=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqrUUrpQR3bmyfKTx4DgbiVoq1tzDRwSGtDz7+9
 kDCKCaCG8eJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaq1FKwAKCRAzarMzb2Z/
 l0wGD/4xtdmAG7KZ387AGVnbMfP3EuKf9LVLK+v48b/JDwgHip70FM8cBjpNYubQGOhL95sdNyo
 zv5iV044W375q5gH4DIsLRE3D2M4lC+eH0Itx0h+pXnRGuFYxRajUY5dxveQJSWMobCX6yF+qLQ
 7HuD+B3Eo5jsPOHkCX/8VcLJn+Bo7VcQbziP8ishYbWCOurmfwk+RR4CbtKwdcHss77nBfqUtFz
 GlPqTTI4Gar6vX6qmZLP7iq+IjV4VaU4Sj2qndW9WMh9Y5rh8zsVSk8oUqpcJv6hfCfiFgzb/qC
 GTLwXLcKxbisOiPnECZaM5pPSqn6DdZfFH6ArFicxNkNgJDw1HEHvmVsSDLRnGFXlLUGSGqoOzi
 uRF7t5qAdIAK8Lmbhk4fb1EXCQ96wM+nj3nTDUnxBQr8wLDIe3QbSlbebuIsoi3PayOwKDkIpHV
 zvu9PkSNI5TC20TCoe7DU95muyZ2WLTMkuo7oWzNXyTM3YyeXR6/pN351/vJm06HCflnLQXK4Pd
 r4m+Fsz/kliXu0xvuuJabhZ7LRPTtXFswX5FEyPBavI71ReXakX+IPRqfmADIc9Iu519XJvvBHk
 cQfZAMHq7SBHYipCd8lR/AwUGWE+1NBUjymb1xvdjamAwpMNhw+cgDJU8FYfLZDCC6eusZA7l1D
 /G2UiGb/e6lgvdw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The handshake upcall links the keyring named in ta_keyring into
tlshd's process keyring before tlshd reads the client certificate and
private key. That link is how tlshd gains possession of keys that
grant no user read permission. xprtsock never fills the field, so an
x509 handshake can present only keys that tlshd's own credentials can
read.

Add a keyring serial to struct xprtsec_parms and pass it to the x509
handshake, so an RPC client can name the keyring that holds its
credentials.

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

