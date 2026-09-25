Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5FDAA4E534B;
	Fri, 25 Sep 2026 19:16:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790363805; cv=none; b=ESlx3brZoRfOVvQzLE1Mfhc7zR62A+n/kuYtIgH6lR/qcMVPyhP+YlYz57LAnDxl1pVBND8htt/inF9LMK5iq/tmytSz4ngBBVf7DaM7kNjBrrFlyefwNmu4eUWlTG9Dkpel9U1CazKcVIJ34ADJDO6DK6rodSNxDFuaHsyMUpI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790363805; c=relaxed/simple;
	bh=GQizQASativnqu3g5lUKkzoyqlGuVGwb/MYVgbctTQ4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=CnACt57le9VSBZXojDJfJezEmEoHFh679UNxoTobYBiIV+t+0KyPiQmMQ0+f09p/qiqKPzsmKratbE0X3MOIjlbVT/3ek60+V+s9ZlQKLx0KizBsyZhRTimQT5PB3ePUeGPKXv0GZjsdhKZEyc1m8DrDv+fZMNqGCeMrmenIEVU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=o3ngtk3o; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="o3ngtk3o"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D0BAA1F000FF;
	Fri, 25 Sep 2026 19:16:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790363804;
	bh=Qwgi4Z/+R4uby/Z3E1pEqwY/lL59k1nx0HVpxZuI6XI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=o3ngtk3omakiJQupk62tjlMBGOShNyahd4x5V+b1Wrfnsq3Hh0QMsZbpNqbExen4e
	 5dLN/0HKbzjB8iIeBBR3Fk/O8G2//l6ljvzRiJYwNbdGuR5pvDEbPJ9fCQXhoc/oXk
	 PsI/8c5o+CWCKhKWvI2Ug4Mc6wuS4soKcVpm1xC+1E0FaTVGsczFmeFB41vw75JY8l
	 meTW/pUtiNHh5LXPLZ3vIOr5TL4lo+3gICzcFira+XMnvpeNHIT4G+8xLa0Pf4Jnw9
	 nfrT7FyUUkI/aldnOKSFabT5POzRT0MAgZwSyB9VQjbKr9ikSy7misVWz0PddsGh3W
	 9gZ8mePpik0MA==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 25 Sep 2026 15:16:26 -0400
Subject: [PATCH RFC v2 4/5] NFS: name the namespace .nfs keyring in the
 x509 handshake
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260925-nfs-mtls-identity-v2-4-aa3ad17dd6c8@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2012; i=cel@kernel.org;
 h=from:subject:message-id; bh=GQizQASativnqu3g5lUKkzoyqlGuVGwb/MYVgbctTQ4=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqtsiTKUecfTrMR+fcznGj2Fww34BKCifZJTHHJ
 RE4LXHUQfCJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCarbIkwAKCRAzarMzb2Z/
 l6z2D/kBvaq5A1/ar3pGanf1y8zcXUqaI1boc2SeTV556bdUchABeXxVqRPlX2DSt8BVG2qIYhS
 Xx3VRcKs5Q4IWOILCzPnot6/RBTay6SZTQTURkfTnRYhTliMXFumoebwYVlVjUDO/uEy/6ziXN0
 2pfe9xDlB6FFGta+9Fb3kWondNjkYHQ+TTbLRi4G7ad7s8AB5wysZhkcQGvkdgnMsNzw0UZGwwY
 xnDcYLuOQVJEr9NBzYu4Mg9Haf2n5RYAWJujtd2p7gHTCtcD7qLaF4FZzGqfIMvmQ/vKqNrvPRJ
 cgWOwdpKvNNDB1vInL7VF08gf5oUgJyheDDqvmYyn5hK39BcQnKUGty4uMdivAHquVLn1ZBpIRQ
 H/efjLO29mS1LMD5bzonSFeHUDMdF75fW850W4TgGlVNUGd0FeQOZkziCuHrDk/fUGz8tia7C3h
 CW90D5NKzSpH2wCjj9XLXcTpjXm+sY02Sq1ksUP38m9PASHZpO61QnEVftMfUfhrJZHjLLdDJAb
 yqN/UGUafumAqXiETFyNv1nFRBuno8WyP7yr9s2RY9TO6d1FhxHYiEBdVLGlFgAD8yrWqS7G+4r
 Q6bLL4Wyz78LcbTGZemuimLdh5EwzE4qdYuFF4MlNRsQV4z4aneDO4yM+Lhu/IjLuAF4AbYoWGd
 TDefIU60A9X1ncg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Keys on the per-namespace .nfs keyring need not grant user read
permission once tlshd possesses the keyring, but nothing tells tlshd
which keyring to possess. An xprtsec=mtls mount can present only keys
that tlshd's own credentials can read, and one namespace's keys are
not isolated from another's.

Record the serial number of the namespace's .nfs keyring in the
nfs_client's xprtsec parameters under the x509 policy, so tlshd
possesses that keyring when it reads the certificate and private
key.

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

