Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 34E1851DAF1;
	Tue, 22 Sep 2026 11:34:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790076867; cv=none; b=Jxg9tugEnl/huRtBRPdwZYhYTURwhBtOBp0jVC75Ab844buPYG/NhS6ZiMv61OJHv4s8PNjTXHiKSMaEYXhlJOTaGoAO/VS5Umi87pWYIlMQaVhyNv2/n16GFvP8jZv3FJuH0n4zO5d43Ezpbom3oVRenmAVOqWGS/WNj4WI2FI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790076867; c=relaxed/simple;
	bh=eccpfKgq7LHNRgtiVZPkAmXh6awU7amVgjZZIwNqGXs=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=RXyrEi7c9041S/5yWAqxMO+QIhhjS2W3XFx2/eCL58AsJu56KqjDe5HgqfDINB39mwAtCfO1Ve25PkhgGvX+TipqNKLw9HAX+gmL/820OwvqTcZbJe+NylrN5BXhqtzdBBjNj+h3fOyEikb0uimjr9ntTtSaNnL5zcJHkgf2zcY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NFwRIb3p; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NFwRIb3p"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A7B7C1F000FF;
	Tue, 22 Sep 2026 11:34:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790076863;
	bh=gYr4Al9SkWgWFj4tavPhadksvjnQShdDD9G12OjD91E=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=NFwRIb3pt6de0hgh1P8ccCfiI12RWrbnDWTuyUH/5OfbKYRzTpZKZiTDy0KRWUmcs
	 oORX+Y6ZDVF2UvM2q8W+1KEhorvJSOttX7i3KvAACfXVIDqK4blcfesC8G4jvSn2yG
	 OyZl2t4yKddkFkWvMAoKwef2OWSDRswj8IktkFIRMNA7RJctodpt8dDYBSSyTD81/b
	 04hzi+9kutkEg+TdOqfXJXvOoRfBsD/5h30tNdZIj/Tn8j1I1boRqB5qy4urb7YTK2
	 SlwMrnQorZXSEoh+7jDcJ6MUQAPM56bPEHwMHY5Mf4yvf4kLC7jk1KuO1dogDfxNbZ
	 4MfVmhbEiBY3w==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 22 Sep 2026 07:34:05 -0400
Subject: [PATCH v2 4/8] nfsd: rename nfsd_mutex to nfsd_global_mutex
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260922-nfsd-per-net-mutex-v2-4-4a5da8243a73@kernel.org>
References: <20260922-nfsd-per-net-mutex-v2-0-4a5da8243a73@kernel.org>
In-Reply-To: <20260922-nfsd-per-net-mutex-v2-0-4a5da8243a73@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-kselftest@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=7432; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=eccpfKgq7LHNRgtiVZPkAmXh6awU7amVgjZZIwNqGXs=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqsme51UfH1OjZV+Ww+CTpZ7KIKUsqcr4ohi6bI
 JT/DYM36niJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarJnuQAKCRAADmhBGVaC
 FfvmEACTENxEw1oFHy0u7PfzCmwP9yvuwTHi+etxs0HOVwqpTWyYRkTqUd1mgbdPHe3sdpUcNy7
 kfZZIrgkiFxk1TiIfpbNechvVT+MhnoA5+r9fIkYLouR+oVapdWy7bTm7v3tW9nseihNKRhkuqS
 LUDDKrMz73tLTmZa0nZYMGi+zA1inJy3qRPvvGTdCrrH5FQ2qTAiLZB72gyr3ttrPuywTJetQd6
 LQpX5ef9KZIZJDcSkKnBj+xxvNhKVDTHLoqUM8RjJoQYIfMtdUyZiLwF6P6+32mTenVfBshCaBQ
 hI9B/DJ0xWM2tMe3oZv+1AhVrCgokYWRey0wCHhwh3r+qHFaZftdb/In4oWHf0mXedBswnxJDNp
 YV21CSZjW6LyqNi3da2vFbloXRodzg9Yg+FwXEztFd9IbepBu+86EjBYM+qshoun3YK7cVKl4x5
 14Hrof6kopv9gkbBPliKV2YXsM3KJ4j2xzEbxCwIvuKpgg/bkUoGOP56/dzashlpaiZVtAzYbXO
 3fi99ho2g7kpXLfC5WrHM6WqPDJDKTNjlDHrSwErnxVNkfKrJwWff7DtyStS+tphE2EhsjcdiKx
 7Mo6Fg9IYBAj3o6qVQhDYvkwtwuavKMnA5DZrTF7wUxicIvPb/6Jk+rzUCOo0QoPF9Z2XH5/LOO
 aQrlJj7rXrPOwrQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

With nn->nfsd_mutex now carrying the per-namespace control plane, give the
remaining module-wide mutex a name that says which one a call site means.
Mechanical; no functional change.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/filecache.c | 14 +++++++-------
 fs/nfsd/netns.h     |  2 +-
 fs/nfsd/nfsctl.c    |  4 ++--
 fs/nfsd/nfsd.h      |  2 +-
 fs/nfsd/nfssvc.c    | 34 +++++++++++++++++-----------------
 5 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 79b9e8c92e70..501772bc8f8d 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -869,7 +869,7 @@ nfsd_file_cache_init(void)
 {
 	int ret;
 
-	lockdep_assert_held(&nfsd_mutex);
+	lockdep_assert_held(&nfsd_global_mutex);
 	if (test_and_set_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags) == 1)
 		return 0;
 
@@ -1011,16 +1011,16 @@ nfsd_file_cache_start_net(struct net *net)
  * nfsd_file_cache_purge - Remove all cache items associated with @net
  * @net: target net namespace
  *
- * Takes nfsd_mutex so the cache cannot be torn down underneath the
+ * Takes nfsd_global_mutex so the cache cannot be torn down underneath the
  * walk.  Callers must not already hold it.
  */
 void
 nfsd_file_cache_purge(struct net *net)
 {
-	mutex_lock(&nfsd_mutex);
+	mutex_lock(&nfsd_global_mutex);
 	if (test_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags) == 1)
 		__nfsd_file_cache_purge(net);
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nfsd_global_mutex);
 }
 
 void
@@ -1045,7 +1045,7 @@ nfsd_file_cache_shutdown(void)
 {
 	int i;
 
-	lockdep_assert_held(&nfsd_mutex);
+	lockdep_assert_held(&nfsd_global_mutex);
 	if (test_and_clear_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags) == 0)
 		return;
 
@@ -1477,7 +1477,7 @@ int nfsd_file_cache_stats_show(struct seq_file *m, void *v)
 	unsigned long lru = 0, total_age = 0;
 
 	/* Serialize with server shutdown */
-	mutex_lock(&nfsd_mutex);
+	mutex_lock(&nfsd_global_mutex);
 	if (test_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags) == 1) {
 		struct bucket_table *tbl;
 		struct rhashtable *ht;
@@ -1491,7 +1491,7 @@ int nfsd_file_cache_stats_show(struct seq_file *m, void *v)
 		buckets = tbl->size;
 		rcu_read_unlock();
 	}
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nfsd_global_mutex);
 
 	for_each_possible_cpu(i) {
 		hits += per_cpu(nfsd_file_cache_hits, i);
diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 35199c17f8d1..866d5f64641f 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -170,7 +170,7 @@ struct nfsd_net {
 	 * ->sv_temp_socks, thread counts), the NFSD_NET_* flags, and the
 	 * settables above that may only change while the server is down.
 	 *
-	 * Nests outside the global nfsd_mutex.
+	 * Nests outside nfsd_global_mutex.
 	 */
 	struct mutex nfsd_mutex;
 
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 5ae33c21cf71..e2455a549e25 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1092,9 +1092,9 @@ static ssize_t write_recoverydir(struct file *file, char *buf, size_t size)
 	 * dirname itself is still shared between namespaces.
 	 */
 	mutex_lock(&nn->nfsd_mutex);
-	mutex_lock(&nfsd_mutex);
+	mutex_lock(&nfsd_global_mutex);
 	rv = __write_recoverydir(file, buf, size, nn);
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nfsd_global_mutex);
 	mutex_unlock(&nn->nfsd_mutex);
 	return rv;
 }
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 0864d6d564e2..d824d2c39029 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -46,7 +46,7 @@ enum {
 
 extern struct svc_program	nfsd_programs[];
 extern const struct svc_version	nfsd_version2, nfsd_version3, nfsd_version4;
-extern struct mutex		nfsd_mutex;
+extern struct mutex		nfsd_global_mutex;
 extern atomic_t			nfsd_th_cnt;		/* number of available threads */
 
 extern const struct seq_operations nfs_exports_op;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 3d47e5c86bd5..5cb92c3829f9 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -64,15 +64,15 @@ static __be32			nfsd_init_request(struct svc_rqst *,
  * that namespace's server is down (->nfsd_versions, ->nfsd4_lease,
  * ->nfsd4_grace, ->max_blksize, ...).
  *
- * The global nfsd_mutex covers only what is genuinely shared between
+ * nfsd_global_mutex covers only what is genuinely shared between
  * namespaces: the nfsd_users refcount and the host-wide resources it
  * brings up and tears down (the open file cache and the NFSv4 global
  * tables), the address-notifier registration, and user_recovery_dirname.
  *
- * Lock ordering is nn->nfsd_mutex outside the global nfsd_mutex.  Nothing
- * takes two namespaces' nfsd_mutexes.
+ * Lock ordering is nn->nfsd_mutex outside nfsd_global_mutex.  Nothing takes
+ * two namespaces' nfsd_mutexes.
  */
-DEFINE_MUTEX(nfsd_mutex);
+DEFINE_MUTEX(nfsd_global_mutex);
 
 #if IS_ENABLED(CONFIG_NFS_LOCALIO)
 static const struct svc_version *localio_versions[] = {
@@ -272,7 +272,7 @@ static int __nfsd_startup_generic(void)
 {
 	int ret;
 
-	lockdep_assert_held(&nfsd_mutex);
+	lockdep_assert_held(&nfsd_global_mutex);
 
 	if (nfsd_users++)
 		return 0;
@@ -297,20 +297,20 @@ static int nfsd_startup_generic(void)
 {
 	int ret;
 
-	mutex_lock(&nfsd_mutex);
+	mutex_lock(&nfsd_global_mutex);
 	ret = __nfsd_startup_generic();
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nfsd_global_mutex);
 	return ret;
 }
 
 static void nfsd_shutdown_generic(void)
 {
-	mutex_lock(&nfsd_mutex);
+	mutex_lock(&nfsd_global_mutex);
 	if (!--nfsd_users) {
 		nfs4_state_shutdown();
 		nfsd_file_cache_shutdown();
 	}
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nfsd_global_mutex);
 }
 
 static bool nfsd_needs_lockd(struct nfsd_net *nn)
@@ -525,31 +525,31 @@ static struct notifier_block nfsd_inet6addr_notifier = {
 };
 #endif
 
-/* Number of namespaces with a serv, guarded by nfsd_mutex */
+/* Number of namespaces with a serv, guarded by nfsd_global_mutex */
 static int nfsd_notifier_users;
 
 static void nfsd_register_notifiers(void)
 {
-	mutex_lock(&nfsd_mutex);
+	mutex_lock(&nfsd_global_mutex);
 	if (!nfsd_notifier_users++) {
 		register_inetaddr_notifier(&nfsd_inetaddr_notifier);
 #if IS_ENABLED(CONFIG_IPV6)
 		register_inet6addr_notifier(&nfsd_inet6addr_notifier);
 #endif
 	}
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nfsd_global_mutex);
 }
 
 static void nfsd_unregister_notifiers(void)
 {
-	mutex_lock(&nfsd_mutex);
+	mutex_lock(&nfsd_global_mutex);
 	if (!--nfsd_notifier_users) {
 		unregister_inetaddr_notifier(&nfsd_inetaddr_notifier);
 #if IS_ENABLED(CONFIG_IPV6)
 		unregister_inet6addr_notifier(&nfsd_inet6addr_notifier);
 #endif
 	}
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nfsd_global_mutex);
 }
 
 /**
@@ -690,9 +690,9 @@ int nfsd_create_serv(struct net *net, bool no_rpcbind)
 	}
 	/*
 	 * Register before publishing nn->nfsd_serv.  Namespaces are only
-	 * serialized against each other by nfsd_mutex here, so
-	 * taking the reference first is what guarantees a visible
-	 * nn->nfsd_serv never coincides with an unregistered notifier.
+	 * serialized against each other by nfsd_global_mutex here, so taking
+	 * the reference first is what guarantees a visible nn->nfsd_serv
+	 * never coincides with an unregistered notifier.
 	 */
 	nfsd_register_notifiers();
 

-- 
2.55.0

