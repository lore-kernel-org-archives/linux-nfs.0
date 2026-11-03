Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793674980;
	b=VVs8dwH68LoSsXbGhJSbOFOXcjkB2i6mEa4BEeIHgtvfHZgcb7LSFr0o6uDyhJRKtZKq
	 0AEcyHos+G46jagNy6bjQNFDfmi11cY7DaYb14loNWGEfx3sEmblhyuXctEPqJrQPNX2E
	 54YCMJ0B7Z+Zc2ORzV63ZWFzWM+TeOgCX4NghQNmbA4fDZMid0rPxwWlAgHax69kS5IHk
	 n7pkC6JNDZgcn8VN86JUBVp9uC98X0e+AviwTmd3lDkbeHcaXwsgvB79ktG8Zd3/iMrmr
	 8jRt5PzGtwaUVqPM1G7SNmLRPvB3i3hDKyLFjtNGVajYoWWoazbXMZUaLNGUhZRRxRA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793674980;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=Bqs38DpiAMDTxf3d0DpcOwxUeXEJbfBSjs7xg3AYXJg=;
	b=BHn0M68NAkjyDpHg4qWB75aaPJWjteWMAQDdw1c0epj/g4AzLxmt6C10KEu7MoCE9ewk
	 zOEaDwUWkVzzwMLzlmHW8j0dD8xTmc/KoElHpfkw1rr0P2A1S0NVINYx/t3a+bxqi7oQ/
	 IjEvHw4lJdy9jkZVgW5abU5r6G8sjAlrGOPn3T6DANUp+1ZDqgvl8pr1spDPakJ29ucai
	 28Rw9Ucr1qdGz/KeY0jbs0iItnF2zltSYRbVq/mzl8Eq6uh5T4jdRD7OocXwOsXIaJUiO
	 K7h8XTP895+mrxwisY7VycPuM2p69WRAPoYkMXdu9oH8u0e93+2KvSrZqzZa4N4OtEw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eRxj7l4g;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id 113AC606A331;
	Tue,  3 Nov 2026 03:02:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eRxj7l4g
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id 0A28E1F00A1D;
	Tue,  3 Nov 2026 03:02:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793674979;
	bh=Bqs38DpiAMDTxf3d0DpcOwxUeXEJbfBSjs7xg3AYXJg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=eRxj7l4gaMO4uv0aHYV5FwM76bX2cIwC6eUXrTxVhsv90uNis3SkJCQ0/uU57NSmk
	 1GGMfWxkLX8sRcNvT4JUuRhjX2VxJTB7CPzFIWFKLYnAWT5J3kLgtiUldLJV89gwMO
	 p00f6OeASxs/G9iwyzUlj3SKo2dJVJJ363F3TJqG5gnVk0zkKday53CuyU5mW31J2o
	 IWPnSVGQtvQR55MbRQ1AKShR4OdWUn0Du/wgevd1giuDB1gUa7iIQfB8f2AE+q7X6X
	 5ROPRlAs3q4xOLKE+D29YxQbgGdgsbPoW3lp6F8eZlcbNTpxAPjfY+HUqnH9H5FC9j
	 4nBdl8Aew0A/Q==
From: Jarkko Sakkinen <jarkko@kernel.org>
To: David Howells <dhowells@redhat.com>
Cc: Eric Biggers <ebiggers@kernel.org>,
	linux-integrity@vger.kernel.org,
	Mimi Zohar <zohar@linux.ibm.com>,
	keyrings@vger.kernel.org,
	Jarkko Sakkinen <jarkko@kernel.org>,
	Marc Dionne <marc.dionne@auristor.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Paulo Alcantara <pc@manguebit.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Ronnie Sahlberg <ronniesahlberg@gmail.com>,
	Shyam Prasad N <sprasad@microsoft.com>,
	Tom Talpey <tom@talpey.com>,
	Bharath SM <bharathsm@microsoft.com>,
	Ilya Dryomov <idryomov@gmail.com>,
	Alex Markuze <amarkuze@redhat.com>,
	Xiubo Li <xiubo.li@clyso.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@kernel.org>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	Roberto Sassu <roberto.sassu@huawei.com>,
	Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
	Eric Snowberg <eric.snowberg@oracle.com>,
	Paul Moore <paul@paul-moore.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Thorsten Blum <blum@kernel.org>,
	Tim Bird <tim.bird@sony.com>,
	linux-afs@lists.infradead.org (open list:AFS FILESYSTEM),
	linux-kernel@vger.kernel.org (open list),
	linux-nfs@vger.kernel.org (open list:NFS, SUNRPC, AND LOCKD CLIENTS),
	linux-cifs@vger.kernel.org (open list:COMMON INTERNET FILE SYSTEM CLIENT (CIFS and SMB3)),
	samba-technical@lists.samba.org (moderated list:COMMON INTERNET FILE SYSTEM CLIENT (CIFS and SMB3)),
	ceph-devel@vger.kernel.org (open list:CEPH COMMON CODE (LIBCEPH)),
	netdev@vger.kernel.org (open list:NETWORKING [GENERAL]),
	linux-security-module@vger.kernel.org (open list:SECURITY SUBSYSTEM)
Subject: [RFC PATCH v2 03/11] dns_resolver: Clear .dns_resolver cache when the last client unloads
Date: Tue,  3 Nov 2026 05:02:08 +0200
Message-ID: <20261103030226.2685251-4-jarkko@kernel.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261103030226.2685251-1-jarkko@kernel.org>
References: <20261103030226.2685251-1-jarkko@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

dns_query() caches resolved dns_resolver keys into the module-owned
.dns_resolver keyring until the TTL expires or module_exit() revokes the
keyring.

Once live keys pin their key type, cached entries keep dns_resolver.ko
pinned after its client modules unload.

Track active kernel client modules with dns_resolver_cache_get() and
dns_resolver_cache_put(), and do the necessary plumbing for:

1. nfsv4
2. cifs
3. libceph
4. kafs

When the last client unloads, clear .dns_resolver and flush key garbage
collection so dns_resolver.ko can unload immediately.

Signed-off-by: Jarkko Sakkinen <jarkko@kernel.org>
---
 fs/afs/main.c                |  4 ++++
 fs/nfs/dns_resolve.h         |  7 ++++++-
 fs/smb/client/cifsfs.c       |  4 ++++
 include/linux/dns_resolver.h | 13 ++++++++++---
 net/ceph/ceph_common.c       |  7 +++++++
 net/dns_resolver/dns_key.c   | 28 ++++++++++++++++++++++++++++
 6 files changed, 59 insertions(+), 4 deletions(-)

diff --git a/fs/afs/main.c b/fs/afs/main.c
index 7a883c59976f..16ae947d371e 100644
--- a/fs/afs/main.c
+++ b/fs/afs/main.c
@@ -12,6 +12,7 @@
 #include <linux/sched.h>
 #include <linux/random.h>
 #include <linux/proc_fs.h>
+#include <linux/dns_resolver.h>
 #define CREATE_TRACE_POINTS
 #include "internal.h"
 
@@ -183,6 +184,7 @@ static int __init afs_init(void)
 	if (ret < 0)
 		goto error_net;
 
+	dns_resolver_cache_get();
 	/* register the filesystems */
 	ret = afs_fs_init();
 	if (ret < 0)
@@ -199,6 +201,7 @@ static int __init afs_init(void)
 error_proc:
 	afs_fs_exit();
 error_fs:
+	dns_resolver_cache_put();
 	unregister_pernet_device(&afs_net_ops);
 error_net:
 	destroy_workqueue(afs_lock_manager);
@@ -232,6 +235,7 @@ static void __exit afs_exit(void)
 	destroy_workqueue(afs_wq);
 	afs_clean_up_permit_cache();
 	rcu_barrier();
+	dns_resolver_cache_put();
 }
 
 module_exit(afs_exit);
diff --git a/fs/nfs/dns_resolve.h b/fs/nfs/dns_resolve.h
index fe3b172c4de1..4b9ecfb4f7fe 100644
--- a/fs/nfs/dns_resolve.h
+++ b/fs/nfs/dns_resolve.h
@@ -9,13 +9,18 @@
 
 
 #ifdef CONFIG_NFS_USE_KERNEL_DNS
+#include <linux/dns_resolver.h>
+
 static inline int nfs_dns_resolver_init(void)
 {
+	dns_resolver_cache_get();
 	return 0;
 }
 
 static inline void nfs_dns_resolver_destroy(void)
-{}
+{
+	dns_resolver_cache_put();
+}
 
 static inline int nfs_dns_resolver_cache_init(struct net *net)
 {
diff --git a/fs/smb/client/cifsfs.c b/fs/smb/client/cifsfs.c
index bf199a5ca084..9788052599ce 100644
--- a/fs/smb/client/cifsfs.c
+++ b/fs/smb/client/cifsfs.c
@@ -31,6 +31,7 @@
 #include <linux/xattr.h>
 #include <linux/mm.h>
 #include <linux/key-type.h>
+#include <linux/dns_resolver.h>
 #include <linux/fileattr.h>
 #include <uapi/linux/magic.h>
 #include <net/ipv6.h>
@@ -2160,6 +2161,7 @@ init_cifs(void)
 		goto out_cifs_swn_init;
 
 	cifs_proc_init();
+	dns_resolver_cache_get();
 
 	rc = register_filesystem(&cifs_fs_type);
 	if (rc)
@@ -2174,6 +2176,7 @@ init_cifs(void)
 	return 0;
 
 out_clean_proc:
+	dns_resolver_cache_put();
 	cifs_proc_clean();
 	exit_cifs_idmap();
 out_cifs_swn_init:
@@ -2242,6 +2245,7 @@ exit_cifs(void)
 	destroy_workqueue(serverclose_wq);
 	destroy_workqueue(cfid_put_wq);
 	destroy_workqueue(cifsiod_wq);
+	dns_resolver_cache_put();
 }
 
 MODULE_AUTHOR("Steve French");
diff --git a/include/linux/dns_resolver.h b/include/linux/dns_resolver.h
index 976cbbdb2832..cc11e09b0df3 100644
--- a/include/linux/dns_resolver.h
+++ b/include/linux/dns_resolver.h
@@ -27,8 +27,15 @@
 #include <uapi/linux/dns_resolver.h>
 
 struct net;
-extern int dns_query(struct net *net, const char *type, const char *name, size_t namelen,
-		     const char *options, char **_result, time64_t *_expiry,
-		     bool invalidate);
+#if IS_ENABLED(CONFIG_DNS_RESOLVER)
+int dns_query(struct net *net, const char *type, const char *name, size_t namelen,
+	      const char *options, char **_result, time64_t *_expiry,
+	      bool invalidate);
+void dns_resolver_cache_get(void);
+void dns_resolver_cache_put(void);
+#else
+static inline void dns_resolver_cache_get(void) { }
+static inline void dns_resolver_cache_put(void) { }
+#endif
 
 #endif /* _LINUX_DNS_RESOLVER_H */
diff --git a/net/ceph/ceph_common.c b/net/ceph/ceph_common.c
index a797c7360e3c..df62a269cb73 100644
--- a/net/ceph/ceph_common.c
+++ b/net/ceph/ceph_common.c
@@ -8,6 +8,7 @@
 #include <linux/in6.h>
 #include <linux/key.h>
 #include <keys/ceph-type.h>
+#include <linux/dns_resolver.h>
 #include <linux/module.h>
 #include <linux/mount.h>
 #include <linux/nsproxy.h>
@@ -890,6 +891,9 @@ static int __init init_ceph_lib(void)
 	if (ret < 0)
 		goto out_msgr;
 
+#ifdef CONFIG_CEPH_LIB_USE_DNS_RESOLVER
+	dns_resolver_cache_get();
+#endif
 	pr_info("loaded (mon/osd proto %d/%d)\n",
 		CEPH_MONC_PROTOCOL, CEPH_OSDC_PROTOCOL);
 
@@ -913,6 +917,9 @@ static void __exit exit_ceph_lib(void)
 	ceph_msgr_exit();
 	ceph_crypto_shutdown();
 	ceph_debugfs_cleanup();
+#ifdef CONFIG_CEPH_LIB_USE_DNS_RESOLVER
+	dns_resolver_cache_put();
+#endif
 }
 
 module_init(init_ceph_lib);
diff --git a/net/dns_resolver/dns_key.c b/net/dns_resolver/dns_key.c
index 451247864a63..63f4fac0dbc8 100644
--- a/net/dns_resolver/dns_key.c
+++ b/net/dns_resolver/dns_key.c
@@ -16,6 +16,7 @@
 #include <linux/kernel.h>
 #include <linux/keyctl.h>
 #include <linux/err.h>
+#include <linux/mutex.h>
 #include <linux/seq_file.h>
 #include <linux/dns_resolver.h>
 #include <keys/dns_resolver-type.h>
@@ -31,6 +32,8 @@ module_param_named(debug, dns_resolver_debug, uint, 0644);
 MODULE_PARM_DESC(debug, "DNS Resolver debugging mask");
 
 const struct cred *dns_resolver_cache;
+static DEFINE_MUTEX(dns_resolver_cache_mutex);
+static unsigned int dns_resolver_cache_users;
 
 #define	DNS_ERRORNO_OPTION	"dnserror"
 
@@ -306,6 +309,31 @@ static long dns_resolver_read(const struct key *key,
 	return user_read(key, buffer, buflen);
 }
 
+void dns_resolver_cache_get(void)
+{
+	mutex_lock(&dns_resolver_cache_mutex);
+	dns_resolver_cache_users++;
+	mutex_unlock(&dns_resolver_cache_mutex);
+}
+EXPORT_SYMBOL_GPL(dns_resolver_cache_get);
+
+void dns_resolver_cache_put(void)
+{
+	int ret;
+
+	mutex_lock(&dns_resolver_cache_mutex);
+	if (--dns_resolver_cache_users == 0 && dns_resolver_cache) {
+		ret = keyring_clear(dns_resolver_cache->thread_keyring);
+		if (ret)
+			pr_warn_ratelimited("dns_resolver: Failed to clear cache: %d\n",
+					    ret);
+		else
+			key_gc_flush();
+	}
+	mutex_unlock(&dns_resolver_cache_mutex);
+}
+EXPORT_SYMBOL_GPL(dns_resolver_cache_put);
+
 struct key_type key_type_dns_resolver = {
 	.name		= "dns_resolver",
 	.flags		= KEY_TYPE_NET_DOMAIN | KEY_TYPE_INSTANT_REAP,
-- 
2.47.3

