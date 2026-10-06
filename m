Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EEDEC49E12B;
	Tue,  6 Oct 2026 15:31:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791300685; cv=none; b=MMJYXBeE6yvL7YJuqzaadRNMO5fhog/5Xbs+Mq639kB3C9pB6r41zzu+NGGe/Pf56xD9/YgaswrpRoZMIBQRYknbh4gRSTEhCJJTgSs2XXNtvOf6x22FWUk8Nb02V2QD5ZjH8AwuBrdchf87zANnhTgykusG4rQOoUKtQAPGgQk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791300685; c=relaxed/simple;
	bh=GQizQASativnqu3g5lUKkzoyqlGuVGwb/MYVgbctTQ4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=N5t0yINwqWUMvpsn4Ptew38WsSv+7CA2BInRkKFVklziZDHvH9fh6k4bMPkD5hbvF47eXWgZDlBd0w+8XeiOZkfhkQg3Y/tER4IL6p3mn2EOhAuUqgx7k3vgnQtieCX8srb2a1Dm6GzW0Pbk0VtWhqTAW+vQsdtW7kS6z2pYBA4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Dk7axECX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Dk7axECX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2FB341F0089B;
	Tue,  6 Oct 2026 15:31:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791300683;
	bh=Qwgi4Z/+R4uby/Z3E1pEqwY/lL59k1nx0HVpxZuI6XI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Dk7axECXCBtn02w6xJnHjcA3ZtnA0zkvaKhL8vZF6EFJXBXAajj6p8UMRfSm1TRoQ
	 Qh+wjzvo2LSJ+u2VFdD25xSAt6Ij5Kd3geg5BXJSVxKvJ0e1fhboW9lKVW9BaRPptu
	 6lC8zNSNEliyZJirTkpizCGOG4Ja/WzZQQbTeE6mAAZDI+uqlZgaq8aky+rooCN3//
	 H/+Rd7PkKS1Ml06Xhl5JKb728BdgzfTCk0zQXnLHlIbLrpHJCKOiyjGhKQ6CpkiStq
	 uPbU7nyO1y3xh/+a4v/yYwSPPSz3WBCZyo+6Yg9iRikGMneRlqzQBJA+90qa7Hr57/
	 v/i71rAJwKlZw==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 06 Oct 2026 11:31:15 -0400
Subject: [PATCH v4 4/5] NFS: name the namespace .nfs keyring in the x509
 handshake
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261006-nfs-mtls-identity-v4-4-1fdf8cc65da7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2012; i=cel@kernel.org;
 h=from:subject:message-id; bh=GQizQASativnqu3g5lUKkzoyqlGuVGwb/MYVgbctTQ4=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqxRRD4fOwMAjjWJF+7OurEpyF8v5C1OzDHdK+O
 hYRMduvPWKJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCasUUQwAKCRAzarMzb2Z/
 lzsEEAC7Yao/2OJayUT3qglQlT30qha0LX2uMp/a2f5yoenZS8SKKrryich3oCAr3ZmW88xAV/G
 x/2IzkV++tFyu0HjBK1LCQbrwGkq7QvHSmsFtS/rvUSq5wS+Dgz6gSwSy/G/GLfe2sAFMRLN2Ez
 Eyn/gZUm5bY4dM5M/RURj4+0oh8aWYN42wubDiR9jlnuYM70//5NqNpV+jrnfM/cA8VP/vFVpp0
 ZwzKAhEecj1vSylVlrsNz+5nETYjj/0nYe8kFIXdH6f5fgG3spn83Ag1P1gGnOmh8v6ER4TNM9H
 QbroG2eaQ+iLkFm58bXxuBO/OYrjOEm+3JFKyjLveaqcSYaHj3vV79LpnRS+NzJyCKiCb9NeYR+
 P0b90FvraKApfuHQIffgGteydUC/W6LPHbGCdmwNFZd+NSVNp4yuCraCA/TV9OjbE8eMKzh9dY7
 yQANV/YXPYq0iOvd61IpW/jiQrd6+KkYrOaPajevE4HTIAMcWPZp5Ka4pnJfH5zSMlXyjPGBJv+
 JtawDQQkkcnPYzVJPehPVBKTwc+8viKXQpjS02z9RbWSHuTGhJGc3woYPUYpbLBdpI76XQRO3x1
 pi4CM08IJQD5xPKzwBtndSr8ySCJotQcjCAxL3xRDihMlPIX5XO9cpwb/L6yMYT24wbq6SSAUd2
 fBr/CnZHMj7ZSaw==
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

