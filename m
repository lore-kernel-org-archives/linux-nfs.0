Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 57A0B49E15F;
	Tue,  6 Oct 2026 15:31:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791300683; cv=none; b=LsA+peyzQxQN5hwE2ux5BRimhDtggebyaCEddmuxtVtIE3ejv9JI8QQmRzkZlOZnOHxnXwVE30TBdVrlWxLWNnYtx/YtNbrbEvU29katsu3BDpm1pLaPVtH6T2basCivUNhOWZxrnlO6H7kaGcS2zOk2YjRSZWfBAztmd+n1FnY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791300683; c=relaxed/simple;
	bh=OQvlxbgMDbQ+XQWdp56aG6emwbq6XG4UwEBtQiZr1N8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=LI/r6W4oPu8/sudW/cjxmSt88FFybJK+2oMvtpYvXk/4FbjS3F/e6zZNoYC8gfQ3StkSzpZrGLQSX5RYUz7wGcbXGUJDuqGd8ZM9311WDSmHJZyl0jP12EmDDg6h0hzpAOr/114i25r7C5rv790AGcd0b3ntSwVu9Tr3qR9qNvQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iopJ31Xs; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iopJ31Xs"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 906B41F0089C;
	Tue,  6 Oct 2026 15:31:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791300682;
	bh=2T6wiFEwIPQwrpaVCtxnzBQrwyoSW9kJbaH/USmDhCk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=iopJ31XsipCdsgcwqaCmCsP5QoSNq9y/icu5QqCnf8Ogo1NRQrph5HLBb6V0A301I
	 UcqR/R7Dr3DKZjjOMMseQEYi9/OOmDYesFU4monHmqR+GTVIe1LZjowWNsNWmg/+EE
	 cWJ45tlHmlsy7lUfWYHAcmudSBEIaQXAFH7C680nruEy5BnZ6t2QBCIS7gg6Bn648U
	 0OUuvVheZus1LjJXyh1wjJILgqS/eKp2O3T6WwmtK8pShx+xMUUn2gAO/RUh/zFuEH
	 uIoznBU4Zrr9hXmL6N7sBj/Pl6l5gAH/LimUKNgPHneUFFOtYNOSePzbMK5RJekxGe
	 96X5H7oEHg+xg==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 06 Oct 2026 11:31:14 -0400
Subject: [PATCH v4 3/5] SUNRPC: pass a keyring serial number to the TLS
 handshake
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261006-nfs-mtls-identity-v4-3-1fdf8cc65da7@kernel.org>
References: <20261006-nfs-mtls-identity-v4-0-1fdf8cc65da7@kernel.org>
In-Reply-To: <20261006-nfs-mtls-identity-v4-0-1fdf8cc65da7@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
 Randy Dunlap <rdunlap@infradead.org>, 
 Christian Brauner <brauner@kernel.org>, David Howells <dhowells@redhat.com>, 
 Sagi Grimberg <sagi@grimberg.me>, Eric Dumazet <edumazet@kernel.org>
Cc: linux-nfs@vger.kernel.org, keyrings@vger.kernel.org, 
 kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org, 
 linux-doc@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3051; i=cel@kernel.org;
 h=from:subject:message-id; bh=OQvlxbgMDbQ+XQWdp56aG6emwbq6XG4UwEBtQiZr1N8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqxRRD1Ld6VhknQdFzayb5AUYNdRM2DFtkV5LBM
 M9VZWIyjP6JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCasUUQwAKCRAzarMzb2Z/
 l3qjEACW3oZ0OCK5SVT2c/TDzp94pJ7Y1eVO5qMLI5LGRlHKXAG/FiEwUnUpPpuO+qC3+d8FALN
 sFDRCMIQvtXP+T7GaetVda3fonBiOFrqPU5AkwjRuG1WQv8Tv7KnTeZigsyhzfb8ookVMu8/3lQ
 N7HWWNWLxYp8CzR8YTVXCx181K+3gN0eR/JOhLh29gF76G6JiaryAINT4EbxUJWMG12yuRUrc3k
 DMO07v+lekAk7ibjwvvpQkszjiRik55GQ+4ZbXt2wWkUUDOqpM2CV0i3528pHRdBqSkkgeUGLgc
 w1ZqbMYgjNZvuo+zEBdKFiQGbxK9fho07MAN3dLehR27w/9YI+6uXr2VDjkazhUK04KPL0T21dS
 9dh8onaYmUSxT2AXUSyKBNf/1Vg8AMdccvg++3uzRQwgBTmRf79jI8ActoB0MytOKgWtqUnLTBu
 8BT66G+v95B0kqrWGjA36SPR/FSKtKwBYZ7d8pJ+7ydcqW6dBmhYdvPCe+0Ggh91CXMd6hLUgZj
 UO+1z8QIfbvS7/tY4/ZtAAEj/P9L37MM+xBsDyqG4O4oT8ecwOgwAhp+j8xXVopARU2P2EO4jax
 Tt0KH3p2E+4c5/xh2G2LjgPmJc11qe4+dBGEj5M7X2cRFfSXBO60pQfn4cJnBoevvgISWFE5mgc
 NYzMLg7hPIIpS5Q==
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

