Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B724649E13F;
	Tue,  6 Oct 2026 15:31:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791300682; cv=none; b=MBcrCmXb3DdhGmbrQDlx99HQRa8yibE8Me7jPiarlzRj7q++VntyJyqA6S3dz48/4Mj5MFc5ZoFYjOJm71U8F3BB2//1qwZPwZQqI9j+Rv3pvrTHTPjew9+M2stZfLcH38rn7Opq9ExJaaUnM1sFJgG03Ks7xl6YwWSl84xi5eU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791300682; c=relaxed/simple;
	bh=VcKuqXZlLadPSGMWjo9wNWzO8hCMrFKqVKP3Xmj7HOw=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Qzk+CGroEjanHhAeVkrY+AXp33EF7ibrgTSe2foGgDIGMKwHpJZQg0zWJKLhoBOntD0LW0w9x8+zWGSmYICrQtlGq5SsNnscvrswIxxp3CLOyK1WkJZxOcilOcHo7YhZrPUSP9lWVT11zRq2vqu7ySAzYMSjj64uQ+85YetrAn4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NijHNR+4; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NijHNR+4"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EEE731F0089B;
	Tue,  6 Oct 2026 15:31:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791300680;
	bh=cvUv3jGg6zzMbaPR20eS+0KIEk0aaIJ19AvZe8/54Kw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=NijHNR+4MNXxayWrVjgDLyirD+NwNTVEYgxJQt9LtrUMdS+IPaGCgQJQblxt3zWQV
	 GsLj9DJNenDv1cwLVksE6YS/B/x4eJRDEwo//hls05Nhyne3lgtcKXuVOzs24MPIUt
	 Ck+l+TbJ4EvhpzvZFFpUFVF6TsibD+PHe8kEeoJzuudM+3BAPxvMKK0XFxP/Nuo1UR
	 GjaZDoTwCntWBNbyZX145JmXKdQ/EetjrqGbFJbF1mqETI8W8yln/Hnu7Oc16Js+M1
	 QGEhvc0yJXgqkKp3i+F1UNn8L376sE8iS6ISnbFVPGJ4VQjbJupZOHqVAq3KppF0w+
	 aSc4mzuGn8c0A==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 06 Oct 2026 11:31:13 -0400
Subject: [PATCH v4 2/5] NFS: allocate the .nfs keyring per network
 namespace
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261006-nfs-mtls-identity-v4-2-1fdf8cc65da7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=5160; i=cel@kernel.org;
 h=from:subject:message-id; bh=VcKuqXZlLadPSGMWjo9wNWzO8hCMrFKqVKP3Xmj7HOw=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqxRRDH4Lxu/H1UfWU2X73aKNZYGCgrmRqKYcCN
 g9icsWnX/6JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCasUUQwAKCRAzarMzb2Z/
 lyIdEACNx0Gwu/eUZ0pg6TW04Pw+TQ4UWpS+NjPDNXVthAMGJFbAdYhIPuqNUYDzTSlUn7vPyv9
 zh9FyHfwjqiDH8RAnueNai1mrqM2lZxsllCHk8YwKYoblBcW2xtqqmCa3FSydGQ45pDMd4mM7y1
 Im3QFFP7cMxPZ24etWXVoF0UT5mubuA3lDtqSE+Sn7io1KUOFAVU7FBevsS+k65PHxNKruVnV/p
 brMG5hvLF7e5PbsN4pMXIuMMgcHa/a1jCQx0YE84RSKdhrwbc4x2Tzx0W3o51B8KGAcLtLIGk7n
 GP27/QwtIIvs1wIYl13/uCZzoW6BSuzv3YMnkFx7EdwmtZ0kqJzH2PJS4x/zlMSDLq8PzEVB7pL
 yCGr7gUrUxFfz3wh5PL19O1YTyJViBKSOHQU8Ghx0LOrh5LiQS7ym9Sv0MOxIMuKCws7BBXCxWE
 y5e9bUNuyNmDDTo0z24E6D99piPV/GRtOFlyB0EVzhn1OOB7LrH6YqcwHIBLgUsvgtT4h4ki36e
 lOHlY22aDPCNxGkVb/phfKFzCBdw/abjKp1NoUT9Q0fuzgbZHyoPS1GDLmARryuYyichwg8rrZ5
 YR4gPnY53e6TC3+I1+5qrdKnXkCpS965z6MixeTCCmxVu0LGj25v/+5bvPFG12wbQ1Me5G+tTtx
 JzinrSobyvcDtLA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Commit 87268f7a4f1f ("nfs: create a kernel keyring") allocates one
.nfs keyring at module load, and nothing in the NFS client reads it.
One module-wide keyring also cannot isolate x.509 credentials
between network namespaces. Each tlshd instance services the
handshake socket of one network namespace, so a credential
provisioned for that namespace's mounts has to be reachable by that
tlshd but not by a tlshd in another user namespace.

Allocate one .nfs keyring per network namespace in nfs_net_init()
and release it in nfs_net_exit(). tlshd finds a keyring by name
through /proc/keys, which is not namespace scoped, so each handshake
request has to carry the keyring serial number instead. Allocate
the keyring under a kernel credential rather than that of the task
creating the namespace, so an LSM labels every namespace's keyring
the same way.

The keyring grants its owner every permission and everyone else
none. Make the owner of the network namespace's user namespace the
keyring's owner, so that in a container with its own user namespace
the container's root can provision the keyring and its tlshd can
link it.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/inode.c | 83 ++++++++++++++++++++++++++++++++--------------------------
 fs/nfs/netns.h |  2 ++
 2 files changed, 48 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 832923be43a9..2b494fa5ecc0 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -2641,11 +2641,52 @@ static int nfsiod_start(void)
 unsigned int nfs_net_id;
 EXPORT_SYMBOL_GPL(nfs_net_id);
 
+#ifdef CONFIG_KEYS
+static int nfs_init_keyring(struct net *net)
+{
+	struct nfs_net *nn = net_generic(net, nfs_net_id);
+	struct cred *cred;
+	struct key *keyring;
+
+	cred = prepare_kernel_cred(&init_task);
+	if (!cred)
+		return -ENOMEM;
+	keyring = keyring_alloc(".nfs", net->user_ns->owner,
+				net->user_ns->group, cred,
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
+static inline int nfs_init_keyring(struct net *net)
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
 
+	err = nfs_init_keyring(net);
+	if (err)
+		return err;
+
 	nfs_clients_init(net);
 
 	if (!rpc_proc_register(net, &nn->rpcstats)) {
@@ -2663,14 +2704,18 @@ static int nfs_net_init(struct net *net)
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
@@ -2680,35 +2725,6 @@ static struct pernet_operations nfs_net_ops = {
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
@@ -2716,13 +2732,9 @@ static int __init init_nfs_fs(void)
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
@@ -2779,8 +2791,6 @@ static int __init init_nfs_fs(void)
 	unregister_pernet_subsys(&nfs_net_ops);
 err_sysfs:
 	nfs_sysfs_exit();
-err_keyring:
-	nfs_exit_keyring();
 	return err;
 }
 
@@ -2796,7 +2806,6 @@ static void __exit exit_nfs_fs(void)
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

