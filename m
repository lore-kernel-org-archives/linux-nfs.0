Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A1BC23A873C;
	Fri, 18 Sep 2026 14:05:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789740338; cv=none; b=lMcAfJyN8GuXIj2UXyfIf7EONl26q/8Xdr8Dz7ZxritjhWByPZCSDEvnTxjb1zitC+Q9Qx9oewN8yXEGatWcA+rXC1WBbATsO6rITNWmGVAIx6ky4Av1QdkTldTAH2WPtH1zTK14w0Dw/bjfba9amN3rn9yiXSxLkCb56UlPl+4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789740338; c=relaxed/simple;
	bh=nift3EzgVBT7ELvExMEcyjf2uO8EenpGrEladzrt7k0=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=tYgi6ui4N5lNZbmEoPe0xWpxjQqbfhctlUHte/eAmpFb/zzZgk8rJASTv3k5J4qqIYM71whqoK49uPC65m3tRRxuMX0HZcB3pRTj+HK/U0Epb9JUslyYw6jBSkTH8kqtzBu1OrO0vAjM6hhWH5vz7ZsiCMXdzuJgaDLp1O1Zi/w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MFMGhDf0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MFMGhDf0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DD0801F00899;
	Fri, 18 Sep 2026 14:05:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789740336;
	bh=UMcUjvN6XFC946hG82bSeGBcSZR2qNr6SFWsBxr/qXE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=MFMGhDf05PMxn9tB6U4Z9BIVit7ftyPNfI4/XbSiNpd5H7PUNM/Akeny7iSUXNv7V
	 17gFEEs2ZpDn4+Ftwbj/joXP/4RrYq90gR5TGQ/7De4qcFhYQ0/WhYsiaTWAkFqF08
	 kKp9D8LTUI5StZvYMEdsC4M9p2B5PjAZJseJCqiUfIuvIMlRp0X56jWQInIHAPadX3
	 v2Px49dlPY2p1uLx+PqVZShxEgtslfM+NggmVwsimNURPcaFzzwGzzrZ0QoHhzP8NY
	 DI/vQjGaRu24z6pWv2HJUQye3o2Gd3AtP8C0Iub+12yqSVZm2/XtiwtOmdEfPe9IXZ
	 T1jTxoB5W9QuA==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 18 Sep 2026 10:05:17 -0400
Subject: [PATCH RFC 2/5] NFS: allocate the .nfs keyring per network
 namespace
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260918-nfs-mtls-identity-v1-2-197e568d78a7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=4781; i=cel@kernel.org;
 h=from:subject:message-id; bh=nift3EzgVBT7ELvExMEcyjf2uO8EenpGrEladzrt7k0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqrUUrIfFOFnsb0HwfW8/DQOCwNxbbVTZlIV2Ji
 uwFzd2+1HmJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaq1FKwAKCRAzarMzb2Z/
 l3NbD/9G20WN61MKesruNv7P1jdScyzBQxsd22zF7I+079Kp04Ku+FQHhNXD5bJ+mjggcVWVJdi
 XPtQi+borHR38gIQIuMuCjoruBfQjBQ4XcVhFLsanc7wCd6Ly4KJPgRJfIgYJqTHznAV0aLkG8b
 anEh0WsA8AgyT32147lQftJCpweTtJLDdXFylOZj/EK1b0vMg6zytwpVk6066Bz8h+6vODk0ZDO
 ye++o8EwWpe+ZDE0sIBSRENsGQfyjHTsVtmKfQ5C3K0hiVBEgFxbvZnvdtZV6rvntfHpjzn+YJc
 6j+qal4QVKWMTl0cewzSRmT5t6keg6B935zSSjzUo5QqlXjz30icQtXUPD/nfewAcp19HtwCRN+
 SeQKwY7IkoWLqO7uSiDNd3CVWV1bhuVtmXJvtcUqcp7khbR5aGikX2ScuIbj1Hbd/tlOI4ACkm/
 0VihYue24865xBeLvm8PYTRv9RVQq/w2Swvn540wgIX8LKr2NnE1UDzqE3D06hrO4P7IBnjl12D
 tPoVWXyLCX9+jTtbuk8FoFGEZHOrp22xImYr4qYLO9+TBCarbX4NEvLr36LIlh2dl9HhUiz/DAD
 KsYZDnXMfnde4lou+GUL+IYEEXoe7aIpzBGXeJDrjtBwwPJiKw4hsSII4gPXmPEUmRi8tfSMmz5
 dZEo5T6T5Naeyxg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Commit 87268f7a4f1f ("nfs: create a kernel keyring") allocates one
.nfs keyring at module load, and nothing in the NFS client reads it.
One module-wide keyring also cannot isolate x.509 credentials
between network namespaces. Each tlshd instance services the
handshake socket of one network namespace, so a credential
provisioned for that namespace's mounts has to be reachable by that
tlshd and by no other.

Allocate one .nfs keyring per network namespace in nfs_net_init()
and release it in nfs_net_exit(). tlshd finds a keyring by name
through /proc/keys, which is not namespace scoped, so each handshake
request has to carry the keyring serial instead. Allocate the
keyring under a kernel credential rather than that of the task
creating the namespace, so an LSM labels every namespace's keyring
the same way.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/inode.c | 81 +++++++++++++++++++++++++++++++---------------------------
 fs/nfs/netns.h |  2 ++
 2 files changed, 46 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 832923be43a9..bd327fbb12d8 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -2641,11 +2641,50 @@ static int nfsiod_start(void)
 unsigned int nfs_net_id;
 EXPORT_SYMBOL_GPL(nfs_net_id);
 
+#ifdef CONFIG_KEYS
+static int nfs_init_keyring(struct nfs_net *nn)
+{
+	struct cred *cred;
+	struct key *keyring;
+
+	cred = prepare_kernel_cred(&init_task);
+	if (!cred)
+		return -ENOMEM;
+	keyring = keyring_alloc(".nfs", GLOBAL_ROOT_UID, GLOBAL_ROOT_GID, cred,
+				(KEY_POS_ALL & ~KEY_POS_SETATTR) |
+				(KEY_USR_ALL & ~KEY_USR_SETATTR),
+				KEY_ALLOC_NOT_IN_QUOTA, NULL, NULL);
+	put_cred(cred);
+	if (IS_ERR(keyring))
+		return PTR_ERR(keyring);
+	nn->nfs_keyring = keyring;
+	return 0;
+}
+
+static void nfs_exit_keyring(struct nfs_net *nn)
+{
+	key_put(nn->nfs_keyring);
+}
+#else
+static inline int nfs_init_keyring(struct nfs_net *nn)
+{
+	return 0;
+}
+
+static inline void nfs_exit_keyring(struct nfs_net *nn)
+{
+}
+#endif /* CONFIG_KEYS */
+
 static int nfs_net_init(struct net *net)
 {
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
 	int err;
 
+	err = nfs_init_keyring(nn);
+	if (err)
+		return err;
+
 	nfs_clients_init(net);
 
 	if (!rpc_proc_register(net, &nn->rpcstats)) {
@@ -2663,14 +2702,18 @@ static int nfs_net_init(struct net *net)
 	rpc_proc_unregister(net, "nfs");
 err_proc_rpc:
 	nfs_clients_exit(net);
+	nfs_exit_keyring(nn);
 	return err;
 }
 
 static void nfs_net_exit(struct net *net)
 {
+	struct nfs_net *nn = net_generic(net, nfs_net_id);
+
 	rpc_proc_unregister(net, "nfs");
 	nfs_fs_proc_net_exit(net);
 	nfs_clients_exit(net);
+	nfs_exit_keyring(nn);
 }
 
 static struct pernet_operations nfs_net_ops = {
@@ -2680,35 +2723,6 @@ static struct pernet_operations nfs_net_ops = {
 	.size = sizeof(struct nfs_net),
 };
 
-#ifdef CONFIG_KEYS
-static struct key *nfs_keyring;
-
-static int __init nfs_init_keyring(void)
-{
-	nfs_keyring = keyring_alloc(".nfs",
-			     GLOBAL_ROOT_UID, GLOBAL_ROOT_GID,
-			     current_cred(),
-			     (KEY_POS_ALL & ~KEY_POS_SETATTR) |
-			     (KEY_USR_ALL & ~KEY_USR_SETATTR),
-			     KEY_ALLOC_NOT_IN_QUOTA, NULL, NULL);
-	return PTR_ERR_OR_ZERO(nfs_keyring);
-}
-
-static void nfs_exit_keyring(void)
-{
-	key_put(nfs_keyring);
-}
-#else
-static inline int nfs_init_keyring(void)
-{
-	return 0;
-}
-
-static inline void nfs_exit_keyring(void)
-{
-}
-#endif /* CONFIG_KEYS */
-
 /*
  * Initialize NFS
  */
@@ -2716,13 +2730,9 @@ static int __init init_nfs_fs(void)
 {
 	int err;
 
-	err = nfs_init_keyring();
-	if (err)
-		return err;
-
 	err = nfs_sysfs_init();
 	if (err < 0)
-		goto err_keyring;
+		return err;
 
 	err = register_pernet_subsys(&nfs_net_ops);
 	if (err < 0)
@@ -2779,8 +2789,6 @@ static int __init init_nfs_fs(void)
 	unregister_pernet_subsys(&nfs_net_ops);
 err_sysfs:
 	nfs_sysfs_exit();
-err_keyring:
-	nfs_exit_keyring();
 	return err;
 }
 
@@ -2796,7 +2804,6 @@ static void __exit exit_nfs_fs(void)
 	nfs_fs_proc_exit();
 	nfsiod_stop();
 	nfs_sysfs_exit();
-	nfs_exit_keyring();
 }
 
 /* Not quite true; I just maintain it */
diff --git a/fs/nfs/netns.h b/fs/nfs/netns.h
index 36658579100d..da0854510404 100644
--- a/fs/nfs/netns.h
+++ b/fs/nfs/netns.h
@@ -16,6 +16,7 @@ struct bl_dev_msg {
 	uint32_t major, minor;
 };
 
+struct key;
 struct nfs_netns_client;
 
 struct nfs_net {
@@ -36,6 +37,7 @@ struct nfs_net {
 #endif /* CONFIG_NFS_V4 */
 	struct nfs_netns_client *nfs_client;
 	spinlock_t nfs_client_lock;
+	struct key *nfs_keyring;
 	ktime_t boot_time;
 	struct rpc_stat rpcstats;
 #ifdef CONFIG_PROC_FS

-- 
2.55.0

