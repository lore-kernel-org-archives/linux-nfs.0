Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA29247D936;
	Tue, 22 Sep 2026 11:34:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790076865; cv=none; b=RZYIlJSdPmHJ5zbcgd5hlfjJV0+W4n8ReSZWlwVCxkD0cOF/43r2Yh++WAKj2vt8rJ6VO401TcYShGZoIEyrA+9Wb8miLlQ3WebEV8fs7182J2pL+J3U7JAEgMhiqM3T++bCfiohFOUlo6zkU3zBS33nTHIvJLp769VE4xUgR0I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790076865; c=relaxed/simple;
	bh=oP77YO0NfFcbITGL4/o1Le7e052PM++Idyl5tCNHe/k=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=roGyDgd9yNkIKT6SlNMapVXRsARAMB+ny3+SDgUwSZp3hYiWN9aoc5xQ439W1aisea23RlrT7MUdUA+r5P8irbkJIz+rMZK1bYwurVglauOD49UXGBY7szGHrkOPOS4JI5yIuqXW1U35Ki4vitQPBTm+ybJmHOBvr6ApzCgiArQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ATpiFMGd; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ATpiFMGd"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 98B1C1F0089D;
	Tue, 22 Sep 2026 11:34:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790076862;
	bh=Rq2hjy+iWzEHQZsRdEQL+dCvx/ZmAba4xeM/zW6EjY0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ATpiFMGdyoBUiJkAbR2rRrUa2yyfjEDL6f0lxvhdwsTfjVPGLatpALsG85BkTGY8Z
	 epq3JMv3gzZMOW/JB62cvz1IbBSTS+MxkndJvgpZvgC7fIX7hV2z5JbtSPRcTKcR7I
	 Q8UlyL6bTtJUOibsIQBrPLxvkS91r/UGa5k0CuyXbVX81N8JoeHK2+z5xbeD5zix9b
	 tdo2HUiy4BNsNdteJT9mhIPu5ODw5G9eLzKlv0Cm6sovAQcl02Bmd/5kGAIB69MMYO
	 snQ9wkqHZceEtqmnEh5KM+KhYOJljbTA9RD9+hk6ZJDUP6OOpK/O6RlU54+tGN80q9
	 bwvsb6VrIXKZg==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 22 Sep 2026 07:34:04 -0400
Subject: [PATCH v2 3/8] nfsd: move the control plane to a per-namespace
 mutex
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260922-nfsd-per-net-mutex-v2-3-4a5da8243a73@kernel.org>
References: <20260922-nfsd-per-net-mutex-v2-0-4a5da8243a73@kernel.org>
In-Reply-To: <20260922-nfsd-per-net-mutex-v2-0-4a5da8243a73@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-kselftest@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=33796; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=oP77YO0NfFcbITGL4/o1Le7e052PM++Idyl5tCNHe/k=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqsme5fWoJ79QknL/yzfHvyVST78dMlrcpNE4Wz
 PplBnrQxEKJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarJnuQAKCRAADmhBGVaC
 FQfTEACSUxg8YaAzhJ6pDce5/t6uqXvbs3fXrr2jIrdIwOiPZH8ooHinhO+14q6DHh3AEY7k9Vs
 0HqHGsVnOMjLtkRQ/9m2XOc/lo+vVipnxsJ5dL0ok5L1hz1+xK42KTLfS6uiKRKboHlxU0OtRH4
 rfqt4EVetYlEoqF5qi/lfYOmdTsoGb+lFZugYeN0AYTeu1TpYixkOYcsuFWrGvwcIbgnVIw01/t
 zHc3BsJLMOk64irVdmbxLlTVwlsn0iXmlXZkrlzb/zY0i2f5JJWGClYoBcFchEBMQAnor+lMLJc
 AHu8dlX1lo+2zy4LCPDHQlhMxm2fHZnUTpT8iBECbzBDI70w/Q/Oz3PI6h7br9V/hxIdPYIvNMJ
 iovPnXQ2y5YAMgub8g8FQCKfh6I6AZjjH4y8liISgk0sgLoGyeZLsvU1ivAG0X8wQ2rTrwy+JUH
 iJMx0ePBCx6DqcLHU640i6btWtgBB6C3MHHyd8A/yDwnhZddihvz8VlVhHLJFNKOmaPQlaaptFS
 a8kVJLtl3w2EYJuVSfZ81VR80fnSeQO1IFCWz5oTmDBd0XUHs+1RiSKBBs5yFnIxk7tHwUUf/Aj
 NcSdLSrX0W9VLNb7THOf7oBrs7q6zGHxM+CC0cbJqf/Kh6Ys+MhWfkNqcL2lRjR0+uYQ3MLbZcR
 Ruh+x817rwmup+A==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_mutex serializes the entire NFSD control plane across every network
namespace. The nfsd genl family sets .parallel_ops, so it is the only
serialization there: one container starting nfsd, or one long
RPC_STATUS_GET dump, stalls every other namespace's admin operations. The
nfsd threads suffer too -- the dynamic-thread autoscaler trylocks the same
mutex on every -ETIMEDOUT and -EBUSY, and a failed trylock skips the
spawn/reap entirely.

Almost none of what the mutex covers is actually shared. Add
nn->nfsd_mutex for the per-namespace control plane:

  - nn->nfsd_serv and the svc_serv members hanging off it (->sv_permsocks,
    ->sv_temp_socks, per-pool thread counts)
  - NFSD_NET_UP / NFSD_NET_LOCKD_UP
  - the settables that may only change while the server is down
    (->nfsd_versions, ->nfsd4_lease, ->nfsd4_grace, ->max_blksize, ...)
  - nn->svc_export_cache / nn->svc_expkey_cache liveness
  - nn->conf_id_hashtbl liveness, for the state-revoke walks

The global nfsd_mutex keeps only what is genuinely host-wide: the
nfsd_users refcount and the resources it brings up (open file cache, NFSv4
global tables), and the address-notifier registration.
nfsd_startup_generic()/nfsd_shutdown_generic() and the notifier
register/unregister now take it internally, so per-net callers never see
it. nfsd_file_cache_purge() likewise takes it itself, which lets
expkey_flush() drop its hand-rolled lock.

write_recoverydir() still takes the global mutex, but that now serializes
writers only. The startup readers of user_recovery_dirname --
nfsd4_init_recdir() and check_for_legacy_methods() -- run under
nn->nfsd_mutex alone, so a write from one namespace can tear the string
under another namespace's startup. Worst case is a bogus path and a
spurious startup error; the buffer is always NUL-terminated in bounds, so
there is nothing to overrun. Left alone deliberately: that global already
had lock-free readers in nfsd4_cltrack_legacy_{topdir,recdir}(), and legacy
client tracking is deprecated and effectively init-netns-only -- its
usermodehelper upcall always runs in the init mount namespace, so the
stored path can only ever name an init-ns path.

Lock ordering is nn->nfsd_mutex outside the global nfsd_mutex; nothing
takes two namespaces' nfsd_mutexes. struct svc_info already indirects
through a mutex pointer, so pool_stats needs only to be pointed at the new
lock.

The notifier refcount becomes a plain int now that it is genuinely
mutex-guarded -- an atomic was never enough to serialize the
register/unregister against the count. nfsd_create_serv() now takes that
reference before publishing nn->nfsd_serv: namespaces are no longer
serialized against each other here, so ordering it the other way would let
the count dip to zero while another namespace's serv is already visible.

Note: the RPC thread pool needs no global lock here. svc_pool_map has its
own svc_pool_map_mutex and per-pool thread counts live in the per-net
svc_serv.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/export.c                                   |  22 ++--
 fs/nfsd/filecache.c                                |   5 +-
 fs/nfsd/netns.h                                    |  10 ++
 fs/nfsd/nfs4proc.c                                 |   4 +-
 fs/nfsd/nfs4state.c                                |   8 +-
 fs/nfsd/nfsctl.c                                   | 117 ++++++++++---------
 fs/nfsd/nfssvc.c                                   | 129 ++++++++++++++-------
 .../testing/selftests/nfsd/nfsd_netlink_listener.c |   6 +-
 8 files changed, 180 insertions(+), 121 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index e5a0f1ababe6..265ea8fd31c6 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -248,13 +248,7 @@ static struct cache_head *expkey_alloc(void)
 
 static void expkey_flush(void)
 {
-	/*
-	 * Take the nfsd_mutex here to ensure that the file cache is not
-	 * destroyed while we're in the middle of flushing.
-	 */
-	mutex_lock(&nfsd_mutex);
 	nfsd_file_cache_purge(current->nsproxy->net_ns);
-	mutex_unlock(&nfsd_mutex);
 }
 
 static int expkey_notify(struct cache_detail *cd, struct cache_head *h)
@@ -346,7 +340,7 @@ int nfsd_nl_expkey_get_reqs_dumpit(struct sk_buff *skb,
 
 	nn = net_generic(sock_net(skb->sk), nfsd_net_id);
 
-	mutex_lock(&nfsd_mutex);
+	mutex_lock(&nn->nfsd_mutex);
 
 	cd = nn->svc_expkey_cache;
 	if (!cd) {
@@ -425,7 +419,7 @@ int nfsd_nl_expkey_get_reqs_dumpit(struct sk_buff *skb,
 	kfree(seqnos);
 	kfree(items);
 out_unlock:
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 	return ret;
 }
 
@@ -560,7 +554,7 @@ int nfsd_nl_expkey_set_reqs_doit(struct sk_buff *skb,
 
 	nn = net_generic(genl_info_net(info), nfsd_net_id);
 
-	mutex_lock(&nfsd_mutex);
+	mutex_lock(&nn->nfsd_mutex);
 
 	cd = nn->svc_expkey_cache;
 	if (!cd) {
@@ -576,7 +570,7 @@ int nfsd_nl_expkey_set_reqs_doit(struct sk_buff *skb,
 	}
 
 out_unlock:
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 	return ret;
 }
 
@@ -673,7 +667,7 @@ int nfsd_nl_svc_export_get_reqs_dumpit(struct sk_buff *skb,
 
 	nn = net_generic(sock_net(skb->sk), nfsd_net_id);
 
-	mutex_lock(&nfsd_mutex);
+	mutex_lock(&nn->nfsd_mutex);
 
 	cd = nn->svc_export_cache;
 	if (!cd) {
@@ -757,7 +751,7 @@ int nfsd_nl_svc_export_get_reqs_dumpit(struct sk_buff *skb,
 	kfree(seqnos);
 	kfree(items);
 out_unlock:
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 	return ret;
 }
 
@@ -1056,7 +1050,7 @@ int nfsd_nl_svc_export_set_reqs_doit(struct sk_buff *skb,
 
 	nn = net_generic(genl_info_net(info), nfsd_net_id);
 
-	mutex_lock(&nfsd_mutex);
+	mutex_lock(&nn->nfsd_mutex);
 
 	cd = nn->svc_export_cache;
 	if (!cd) {
@@ -1072,7 +1066,7 @@ int nfsd_nl_svc_export_set_reqs_doit(struct sk_buff *skb,
 	}
 
 out_unlock:
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 	return ret;
 }
 
diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 17a94e6fcb15..79b9e8c92e70 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -1011,13 +1011,16 @@ nfsd_file_cache_start_net(struct net *net)
  * nfsd_file_cache_purge - Remove all cache items associated with @net
  * @net: target net namespace
  *
+ * Takes nfsd_mutex so the cache cannot be torn down underneath the
+ * walk.  Callers must not already hold it.
  */
 void
 nfsd_file_cache_purge(struct net *net)
 {
-	lockdep_assert_held(&nfsd_mutex);
+	mutex_lock(&nfsd_mutex);
 	if (test_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags) == 1)
 		__nfsd_file_cache_purge(net);
+	mutex_unlock(&nfsd_mutex);
 }
 
 void
diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 374ce83e2ba0..35199c17f8d1 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -164,6 +164,16 @@ struct nfsd_net {
 	u32 clientid_counter;
 	u32 clverifier_counter;
 
+	/*
+	 * Serializes this namespace's control plane: ->nfsd_serv and the
+	 * svc_serv members that hang off it (->sv_permsocks,
+	 * ->sv_temp_socks, thread counts), the NFSD_NET_* flags, and the
+	 * settables above that may only change while the server is down.
+	 *
+	 * Nests outside the global nfsd_mutex.
+	 */
+	struct mutex nfsd_mutex;
+
 	struct svc_info nfsd_info;
 #define nfsd_serv nfsd_info.serv
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3a82af381a8d..7df60abfbff1 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1703,7 +1703,7 @@ static bool nfsd4_copy_on_sb(const struct nfsd4_copy *copy,
  * @net: net namespace containing the copy operations
  * @sb: targeted superblock
  *
- * Context: Caller must hold nfsd_mutex with NFSD_NET_UP set.  Outside
+ * Context: Caller must hold nn->nfsd_mutex with NFSD_NET_UP set.  Outside
  *          that window nn->conf_id_hashtbl is unallocated or freed,
  *          so the walk would dereference a NULL or dangling pointer.
  */
@@ -1715,7 +1715,7 @@ void nfsd4_cancel_copy_by_sb(struct net *net, struct super_block *sb)
 	unsigned int idhashval;
 	LIST_HEAD(to_cancel);
 
-	lockdep_assert_held(&nfsd_mutex);
+	lockdep_assert_held(&nn->nfsd_mutex);
 	spin_lock(&nn->client_lock);
 	for (idhashval = 0; idhashval < CLIENT_HASH_SIZE; idhashval++) {
 		struct list_head *head = &nn->conf_id_hashtbl[idhashval];
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1de6c6d757c3..0f9340eb281e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2102,7 +2102,7 @@ static void revoke_one_stid(struct nfsd_net *nn, struct nfs4_client *clp,
  * The clients which own the states will subsequently be notified that the
  * states have been "admin-revoked".
  *
- * Context: Caller must hold nfsd_mutex with NFSD_NET_UP set.  Outside
+ * Context: Caller must hold nn->nfsd_mutex with NFSD_NET_UP set.  Outside
  *          that window nn->conf_id_hashtbl is unallocated or freed,
  *          so the walk would dereference a NULL or dangling pointer.
  */
@@ -2111,7 +2111,7 @@ void nfsd4_revoke_states(struct nfsd_net *nn, struct super_block *sb)
 	unsigned int idhashval;
 	unsigned int sc_types;
 
-	lockdep_assert_held(&nfsd_mutex);
+	lockdep_assert_held(&nn->nfsd_mutex);
 
 	sc_types = SC_TYPE_OPEN | SC_TYPE_LOCK | SC_TYPE_DELEG | SC_TYPE_LAYOUT;
 
@@ -2190,7 +2190,7 @@ static struct nfs4_stid *find_one_export_stid(struct nfs4_client *clp,
  * Userspace (exportfs -u) sends this after removing the last client
  * for a path, enabling the underlying filesystem to be unmounted.
  *
- * Context: Caller must hold nfsd_mutex with NFSD_NET_UP set.  Outside
+ * Context: Caller must hold nn->nfsd_mutex with NFSD_NET_UP set.  Outside
  *          that window nn->conf_id_hashtbl is unallocated or freed,
  *          so the walk would dereference a NULL or dangling pointer.
  */
@@ -2199,7 +2199,7 @@ void nfsd4_revoke_export_states(struct nfsd_net *nn, const struct path *path)
 	unsigned int idhashval;
 	unsigned int sc_types;
 
-	lockdep_assert_held(&nfsd_mutex);
+	lockdep_assert_held(&nn->nfsd_mutex);
 
 	sc_types = SC_TYPE_OPEN | SC_TYPE_LOCK | SC_TYPE_DELEG | SC_TYPE_LAYOUT;
 
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 330d0f12e199..5ae33c21cf71 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -302,15 +302,15 @@ static ssize_t write_unlock_fs(struct file *file, char *buf, size_t size)
 	 * 3.  Is that directory the root of an exported file system?
 	 */
 	error = nlmsvc_unlock_all_by_sb(path.dentry->d_sb);
-	mutex_lock(&nfsd_mutex);
 	nn = net_generic(netns(file), nfsd_net_id);
+	mutex_lock(&nn->nfsd_mutex);
 	if (test_bit(NFSD_NET_UP, &nn->flags)) {
 		nfsd4_cancel_copy_by_sb(netns(file), path.dentry->d_sb);
 		nfsd4_revoke_states(nn, path.dentry->d_sb);
 	} else {
 		error = -EINVAL;
 	}
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 
 	path_put(&path);
 	return error;
@@ -436,12 +436,12 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
 		if (newthreads < 0)
 			return -EINVAL;
 		trace_nfsd_ctl_threads(net, newthreads);
-		mutex_lock(&nfsd_mutex);
+		mutex_lock(&nn->nfsd_mutex);
 		if (newthreads > 0 || nn->nfsd_serv != NULL)
 			rv = nfsd_svc(1, &newthreads, net, file->f_cred, NULL);
 		else
 			rv = 0;
-		mutex_unlock(&nfsd_mutex);
+		mutex_unlock(&nn->nfsd_mutex);
 		if (rv < 0)
 			return rv;
 	} else
@@ -484,8 +484,9 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 	int npools;
 	int *nthreads;
 	struct net *net = netns(file);
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
-	mutex_lock(&nfsd_mutex);
+	mutex_lock(&nn->nfsd_mutex);
 	npools = nfsd_nrpools(net);
 	if (npools == 0) {
 		/*
@@ -493,7 +494,7 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 		 * writing to the threads file but NOT the pool_threads
 		 * file, sorry.  Report zero threads.
 		 */
-		mutex_unlock(&nfsd_mutex);
+		mutex_unlock(&nn->nfsd_mutex);
 		strcpy(buf, "0\n");
 		return strlen(buf);
 	}
@@ -547,7 +548,7 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 	rv = mesg - buf;
 out_free:
 	kfree(nthreads);
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 	return rv;
 }
 
@@ -710,11 +711,12 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
  */
 static ssize_t write_versions(struct file *file, char *buf, size_t size)
 {
+	struct nfsd_net *nn = net_generic(netns(file), nfsd_net_id);
 	ssize_t rv;
 
-	mutex_lock(&nfsd_mutex);
+	mutex_lock(&nn->nfsd_mutex);
 	rv = __write_versions(file, buf, size);
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 	return rv;
 }
 
@@ -876,11 +878,12 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size,
  */
 static ssize_t write_ports(struct file *file, char *buf, size_t size)
 {
+	struct nfsd_net *nn = net_generic(netns(file), nfsd_net_id);
 	ssize_t rv;
 
-	mutex_lock(&nfsd_mutex);
+	mutex_lock(&nn->nfsd_mutex);
 	rv = __write_ports(file, buf, size, netns(file));
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 	return rv;
 }
 
@@ -924,13 +927,13 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 		bsize = max_t(int, bsize, 1024);
 		bsize = min_t(int, bsize, NFSSVC_MAXBLKSIZE);
 		bsize &= ~(1024-1);
-		mutex_lock(&nfsd_mutex);
+		mutex_lock(&nn->nfsd_mutex);
 		if (nn->nfsd_serv) {
-			mutex_unlock(&nfsd_mutex);
+			mutex_unlock(&nn->nfsd_mutex);
 			return -EBUSY;
 		}
 		nn->max_blksize = bsize;
-		mutex_unlock(&nfsd_mutex);
+		mutex_unlock(&nn->nfsd_mutex);
 	}
 
 	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%u\n",
@@ -979,9 +982,9 @@ static ssize_t nfsd4_write_time(struct file *file, char *buf, size_t size,
 {
 	ssize_t rv;
 
-	mutex_lock(&nfsd_mutex);
+	mutex_lock(&nn->nfsd_mutex);
 	rv = __nfsd4_write_time(file, buf, size, time, nn);
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 	return rv;
 }
 
@@ -1084,9 +1087,15 @@ static ssize_t write_recoverydir(struct file *file, char *buf, size_t size)
 	ssize_t rv;
 	struct nfsd_net *nn = net_generic(netns(file), nfsd_net_id);
 
+	/*
+	 * nn->nfsd_mutex guards the nn->nfsd_serv check; the recovery
+	 * dirname itself is still shared between namespaces.
+	 */
+	mutex_lock(&nn->nfsd_mutex);
 	mutex_lock(&nfsd_mutex);
 	rv = __write_recoverydir(file, buf, size, nn);
 	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 	return rv;
 }
 #endif
@@ -1530,9 +1539,9 @@ int nfsd_nl_rpc_status_get_dumpit(struct sk_buff *skb,
 	int i, ret, rqstp_index = 0;
 	struct nfsd_net *nn;
 
-	mutex_lock(&nfsd_mutex);
-
 	nn = net_generic(sock_net(skb->sk), nfsd_net_id);
+
+	mutex_lock(&nn->nfsd_mutex);
 	if (!nn->nfsd_serv) {
 		ret = -ENODEV;
 		goto out_unlock;
@@ -1649,7 +1658,7 @@ int nfsd_nl_rpc_status_get_dumpit(struct sk_buff *skb,
 out:
 	rcu_read_unlock();
 out_unlock:
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 
 	return ret;
 }
@@ -1659,7 +1668,7 @@ int nfsd_nl_rpc_status_get_dumpit(struct sk_buff *skb,
  * @attr: nlattr NFSD_A_SERVER_FH_KEY
  * @nn: nfsd_net
  *
- * Callers should hold nfsd_mutex, returns 0 on success or negative errno.
+ * Callers should hold nn->nfsd_mutex, returns 0 on success or negative errno.
  * Callers must ensure the server is shut down (sv_nrthreads == 0),
  * userspace documentation asserts the key may only be set when the server
  * is not running.
@@ -1714,7 +1723,7 @@ int nfsd_nl_threads_set_doit(struct sk_buff *skb, struct genl_info *info)
 				 GENL_HDRLEN, rem)
 		nrpools++;
 
-	mutex_lock(&nfsd_mutex);
+	mutex_lock(&nn->nfsd_mutex);
 
 	nthreads = kzalloc_objs(int, nrpools);
 	if (!nthreads) {
@@ -1779,7 +1788,7 @@ int nfsd_nl_threads_set_doit(struct sk_buff *skb, struct genl_info *info)
 	if (ret > 0)
 		ret = 0;
 out_unlock:
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 	kfree(nthreads);
 	return ret;
 }
@@ -1808,7 +1817,7 @@ int nfsd_nl_threads_get_doit(struct sk_buff *skb, struct genl_info *info)
 		goto err_free_msg;
 	}
 
-	mutex_lock(&nfsd_mutex);
+	mutex_lock(&nn->nfsd_mutex);
 
 	err = nla_put_u32(skb, NFSD_A_SERVER_GRACETIME,
 			  nn->nfsd4_grace) ||
@@ -1838,14 +1847,14 @@ int nfsd_nl_threads_get_doit(struct sk_buff *skb, struct genl_info *info)
 			goto err_unlock;
 	}
 
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 
 	genlmsg_end(skb, hdr);
 
 	return genlmsg_reply(skb, info);
 
 err_unlock:
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 err_free_msg:
 	nlmsg_free(skb);
 
@@ -1868,11 +1877,11 @@ int nfsd_nl_version_set_doit(struct sk_buff *skb, struct genl_info *info)
 	if (GENL_REQ_ATTR_CHECK(info, NFSD_A_SERVER_PROTO_VERSION))
 		return -EINVAL;
 
-	mutex_lock(&nfsd_mutex);
-
 	nn = net_generic(genl_info_net(info), nfsd_net_id);
+
+	mutex_lock(&nn->nfsd_mutex);
 	if (nn->nfsd_serv) {
-		mutex_unlock(&nfsd_mutex);
+		mutex_unlock(&nn->nfsd_mutex);
 		return -EBUSY;
 	}
 
@@ -1915,7 +1924,7 @@ int nfsd_nl_version_set_doit(struct sk_buff *skb, struct genl_info *info)
 		}
 	}
 
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 
 	return 0;
 }
@@ -1943,9 +1952,9 @@ int nfsd_nl_version_get_doit(struct sk_buff *skb, struct genl_info *info)
 		goto err_free_msg;
 	}
 
-	mutex_lock(&nfsd_mutex);
 	nn = net_generic(genl_info_net(info), nfsd_net_id);
 
+	mutex_lock(&nn->nfsd_mutex);
 	for (i = 2; i <= 4; i++) {
 		int j;
 
@@ -1987,13 +1996,13 @@ int nfsd_nl_version_get_doit(struct sk_buff *skb, struct genl_info *info)
 		}
 	}
 
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 	genlmsg_end(skb, hdr);
 
 	return genlmsg_reply(skb, info);
 
 err_nfsd_unlock:
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 err_free_msg:
 	nlmsg_free(skb);
 
@@ -2004,7 +2013,7 @@ int nfsd_nl_version_get_doit(struct sk_buff *skb, struct genl_info *info)
  * Transport classes NFSD knows how to instantiate. Vetting the name here
  * keeps a bogus string from reaching svc_xprt_create_from_sa(), where an
  * unknown name triggers a request_module("svc%s", name) upcall under
- * nfsd_mutex.
+ * nn->nfsd_mutex.
  */
 static bool nfsd_nl_transport_supported(const char *name)
 {
@@ -2085,14 +2094,15 @@ static int nfsd_nl_validate_listeners(struct genl_info *info)
 	return count;
 }
 
-static size_t nfsd_nl_listener_set_msgsize(struct svc_serv *serv)
+static size_t nfsd_nl_listener_set_msgsize(struct nfsd_net *nn,
+					   struct svc_serv *serv)
 {
 	size_t size = GENL_HDRLEN +		    /* genlmsg_iput() */
 		      nla_total_size(0);	    /* userspace-rpcbind */
 	struct svc_xprt *xprt;
 	unsigned int p;
 
-	lockdep_assert_held(&nfsd_mutex);
+	lockdep_assert_held(&nn->nfsd_mutex);
 
 	for (p = 0; p < serv->sv_nprogs; p++)
 		size += serv->sv_programs[p].pg_nvers *
@@ -2118,15 +2128,16 @@ static struct sk_buff *
 nfsd_nl_listener_set_msg(struct genl_info *info, struct net *net,
 			 struct svc_serv *serv)
 {
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	struct svc_xprt *xprt;
 	struct sk_buff *skb;
 	unsigned int p, i;
 	void *hdr;
 	int err;
 
-	lockdep_assert_held(&nfsd_mutex);
+	lockdep_assert_held(&nn->nfsd_mutex);
 
-	skb = genlmsg_new(nfsd_nl_listener_set_msgsize(serv), GFP_KERNEL);
+	skb = genlmsg_new(nfsd_nl_listener_set_msgsize(nn, serv), GFP_KERNEL);
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 
@@ -2244,10 +2255,10 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 
 	userspace_rpcbind = nla_get_flag(info->attrs[NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND]);
 
-	mutex_lock(&nfsd_mutex);
-
 	nn = net_generic(net, nfsd_net_id);
 
+	mutex_lock(&nn->nfsd_mutex);
+
 	/*
 	 * An empty list destroys the serv, and nfsd_destroy_serv() drops
 	 * whatever svc_bind() took either way, so teardown is not an
@@ -2258,13 +2269,13 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 	    nn->nfsd_serv->sv_no_rpcbind != userspace_rpcbind) {
 		NL_SET_ERR_MSG(info->extack,
 			       "cannot change rpcbind ownership while a server exists");
-		mutex_unlock(&nfsd_mutex);
+		mutex_unlock(&nn->nfsd_mutex);
 		return -EBUSY;
 	}
 
 	err = nfsd_create_serv(net, userspace_rpcbind);
 	if (err) {
-		mutex_unlock(&nfsd_mutex);
+		mutex_unlock(&nn->nfsd_mutex);
 		return err;
 	}
 
@@ -2433,7 +2444,7 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 		nfsd_destroy_serv(net);
 
 out_unlock_mtx:
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 
 	/* rskb is only built once err is known to be zero. */
 	if (rskb)
@@ -2467,9 +2478,9 @@ int nfsd_nl_listener_get_doit(struct sk_buff *skb, struct genl_info *info)
 		goto err_free_msg;
 	}
 
-	mutex_lock(&nfsd_mutex);
 	nn = net_generic(genl_info_net(info), nfsd_net_id);
 
+	mutex_lock(&nn->nfsd_mutex);
 	/* no nfs server? Just send empty socket list */
 	if (!nn->nfsd_serv)
 		goto out_unlock_mtx;
@@ -2498,14 +2509,14 @@ int nfsd_nl_listener_get_doit(struct sk_buff *skb, struct genl_info *info)
 	}
 	spin_unlock_bh(&serv->sv_lock);
 out_unlock_mtx:
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 	genlmsg_end(skb, hdr);
 
 	return genlmsg_reply(skb, info);
 
 err_serv_unlock:
 	spin_unlock_bh(&serv->sv_lock);
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 err_free_msg:
 	nlmsg_free(skb);
 
@@ -2589,7 +2600,7 @@ int nfsd_nl_cache_flush_doit(struct sk_buff *skb, struct genl_info *info)
 	if (info->attrs[NFSD_A_CACHE_FLUSH_MASK])
 		mask = nla_get_u32(info->attrs[NFSD_A_CACHE_FLUSH_MASK]);
 
-	mutex_lock(&nfsd_mutex);
+	mutex_lock(&nn->nfsd_mutex);
 
 	if ((mask & NFSD_CACHE_TYPE_SVC_EXPORT) &&
 	    nn->svc_export_cache)
@@ -2599,7 +2610,7 @@ int nfsd_nl_cache_flush_doit(struct sk_buff *skb, struct genl_info *info)
 	    nn->svc_expkey_cache)
 		cache_purge(nn->svc_expkey_cache);
 
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 
 	return 0;
 }
@@ -2947,14 +2958,14 @@ int nfsd_nl_unlock_filesystem_doit(struct sk_buff *skb,
 
 	error = nlmsvc_unlock_all_by_sb(path.dentry->d_sb);
 
-	mutex_lock(&nfsd_mutex);
+	mutex_lock(&nn->nfsd_mutex);
 	if (test_bit(NFSD_NET_UP, &nn->flags)) {
 		nfsd4_cancel_copy_by_sb(net, path.dentry->d_sb);
 		nfsd4_revoke_states(nn, path.dentry->d_sb);
 	} else {
 		error = -EINVAL;
 	}
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 
 	path_put(&path);
 	return error;
@@ -2994,13 +3005,13 @@ int nfsd_nl_unlock_export_doit(struct sk_buff *skb, struct genl_info *info)
 	if (error)
 		return error;
 
-	mutex_lock(&nfsd_mutex);
+	mutex_lock(&nn->nfsd_mutex);
 	if (test_bit(NFSD_NET_UP, &nn->flags)) {
 		nfsd_file_close_export(net, &path);
 		nfsd4_revoke_export_states(nn, &path);
 	} else
 		error = -EINVAL;
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 
 	path_put(&path);
 	return error;
@@ -3057,7 +3068,8 @@ static __net_init int nfsd_net_init(struct net *net)
 		nn->nfsd_versions[i] = nfsd_support_version(i);
 	for (i = 0; i < sizeof(nn->nfsd4_minorversions); i++)
 		nn->nfsd4_minorversions[i] = nfsd_support_version(4);
-	nn->nfsd_info.mutex = &nfsd_mutex;
+	mutex_init(&nn->nfsd_mutex);
+	nn->nfsd_info.mutex = &nn->nfsd_mutex;
 	nn->nfsd_serv = NULL;
 	nfsd4_init_leases_net(nn);
 	get_random_bytes(&nn->siphash_key, sizeof(nn->siphash_key));
@@ -3121,6 +3133,7 @@ static __net_exit void nfsd_net_exit(struct net *net)
 	percpu_counter_destroy_many(nn->counter, NFSD_STATS_COUNTERS_NUM);
 	nfsd_idmap_shutdown(net);
 	nfsd_export_shutdown(net);
+	mutex_destroy(&nn->nfsd_mutex);
 }
 
 static struct pernet_operations nfsd_net_ops = {
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 77e1e6ba686d..3d47e5c86bd5 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -55,16 +55,22 @@ static __be32			nfsd_init_request(struct svc_rqst *,
 						struct svc_process_info *);
 
 /*
- * nfsd_mutex protects nn->nfsd_serv -- both the pointer itself and some members
- * of the svc_serv struct such as ->sv_temp_socks and ->sv_permsocks.
+ * NFSD's control plane is serialized by two mutexes.
  *
- * Finally, the nfsd_mutex also protects some of the global variables that are
- * accessed when nfsd starts and that are settable via the write_* routines in
- * nfsctl.c. In particular:
+ * Nearly everything is per-namespace and belongs to nn->nfsd_mutex: the
+ * nn->nfsd_serv pointer and the svc_serv members that hang off it
+ * (->sv_permsocks, ->sv_temp_socks, per-pool thread counts), the
+ * NFSD_NET_* flags, and the nfsd_net settables that may only change while
+ * that namespace's server is down (->nfsd_versions, ->nfsd4_lease,
+ * ->nfsd4_grace, ->max_blksize, ...).
  *
- *	user_recovery_dirname
- *	user_lease_time
- *	nfsd_versions
+ * The global nfsd_mutex covers only what is genuinely shared between
+ * namespaces: the nfsd_users refcount and the host-wide resources it
+ * brings up and tears down (the open file cache and the NFSv4 global
+ * tables), the address-notifier registration, and user_recovery_dirname.
+ *
+ * Lock ordering is nn->nfsd_mutex outside the global nfsd_mutex.  Nothing
+ * takes two namespaces' nfsd_mutexes.
  */
 DEFINE_MUTEX(nfsd_mutex);
 
@@ -251,20 +257,23 @@ int nfsd_nrthreads(struct net *net)
 	int rv = 0;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
-	/* nfsd_mutex keeps nn->nfsd_serv valid across the read. */
-	mutex_lock(&nfsd_mutex);
+	/* nn->nfsd_mutex keeps nn->nfsd_serv valid across the read. */
+	mutex_lock(&nn->nfsd_mutex);
 	if (nn->nfsd_serv)
 		rv = svc_serv_maxthreads(nn->nfsd_serv);
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 	return rv;
 }
 
+/* Number of namespaces holding the host-wide resources up */
 static int nfsd_users = 0;
 
-static int nfsd_startup_generic(void)
+static int __nfsd_startup_generic(void)
 {
 	int ret;
 
+	lockdep_assert_held(&nfsd_mutex);
+
 	if (nfsd_users++)
 		return 0;
 
@@ -284,13 +293,24 @@ static int nfsd_startup_generic(void)
 	return ret;
 }
 
-static void nfsd_shutdown_generic(void)
+static int nfsd_startup_generic(void)
 {
-	if (--nfsd_users)
-		return;
+	int ret;
 
-	nfs4_state_shutdown();
-	nfsd_file_cache_shutdown();
+	mutex_lock(&nfsd_mutex);
+	ret = __nfsd_startup_generic();
+	mutex_unlock(&nfsd_mutex);
+	return ret;
+}
+
+static void nfsd_shutdown_generic(void)
+{
+	mutex_lock(&nfsd_mutex);
+	if (!--nfsd_users) {
+		nfs4_state_shutdown();
+		nfsd_file_cache_shutdown();
+	}
+	mutex_unlock(&nfsd_mutex);
 }
 
 static bool nfsd_needs_lockd(struct nfsd_net *nn)
@@ -505,8 +525,32 @@ static struct notifier_block nfsd_inet6addr_notifier = {
 };
 #endif
 
-/* Only used under nfsd_mutex, so this atomic may be overkill: */
-static atomic_t nfsd_notifier_refcount = ATOMIC_INIT(0);
+/* Number of namespaces with a serv, guarded by nfsd_mutex */
+static int nfsd_notifier_users;
+
+static void nfsd_register_notifiers(void)
+{
+	mutex_lock(&nfsd_mutex);
+	if (!nfsd_notifier_users++) {
+		register_inetaddr_notifier(&nfsd_inetaddr_notifier);
+#if IS_ENABLED(CONFIG_IPV6)
+		register_inet6addr_notifier(&nfsd_inet6addr_notifier);
+#endif
+	}
+	mutex_unlock(&nfsd_mutex);
+}
+
+static void nfsd_unregister_notifiers(void)
+{
+	mutex_lock(&nfsd_mutex);
+	if (!--nfsd_notifier_users) {
+		unregister_inetaddr_notifier(&nfsd_inetaddr_notifier);
+#if IS_ENABLED(CONFIG_IPV6)
+		unregister_inet6addr_notifier(&nfsd_inet6addr_notifier);
+#endif
+	}
+	mutex_unlock(&nfsd_mutex);
+}
 
 /**
  * nfsd_destroy_serv - tear down NFSD's svc_serv for a namespace
@@ -517,19 +561,13 @@ void nfsd_destroy_serv(struct net *net)
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	struct svc_serv *serv = nn->nfsd_serv;
 
-	lockdep_assert_held(&nfsd_mutex);
+	lockdep_assert_held(&nn->nfsd_mutex);
 
 	spin_lock(&nfsd_notifier_lock);
 	nn->nfsd_serv = NULL;
 	spin_unlock(&nfsd_notifier_lock);
 
-	/* check if the notifier still has clients */
-	if (atomic_dec_return(&nfsd_notifier_refcount) == 0) {
-		unregister_inetaddr_notifier(&nfsd_inetaddr_notifier);
-#if IS_ENABLED(CONFIG_IPV6)
-		unregister_inet6addr_notifier(&nfsd_inet6addr_notifier);
-#endif
-	}
+	nfsd_unregister_notifiers();
 
 	/*
 	 * write_ports can create the server without actually starting
@@ -586,17 +624,17 @@ void nfsd_shutdown_threads(struct net *net)
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	struct svc_serv *serv;
 
-	mutex_lock(&nfsd_mutex);
+	mutex_lock(&nn->nfsd_mutex);
 	serv = nn->nfsd_serv;
 	if (serv == NULL) {
-		mutex_unlock(&nfsd_mutex);
+		mutex_unlock(&nn->nfsd_mutex);
 		return;
 	}
 
 	/* Kill outstanding nfsd threads */
 	svc_set_num_threads(serv, 0, 0);
 	nfsd_destroy_serv(net);
-	mutex_unlock(&nfsd_mutex);
+	mutex_unlock(&nn->nfsd_mutex);
 }
 
 struct svc_rqst *nfsd_current_rqst(void)
@@ -619,7 +657,7 @@ int nfsd_create_serv(struct net *net, bool no_rpcbind)
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	struct svc_serv *serv;
 
-	WARN_ON(!mutex_is_locked(&nfsd_mutex));
+	WARN_ON(!mutex_is_locked(&nn->nfsd_mutex));
 	if (nn->nfsd_serv)
 		return 0;
 
@@ -650,17 +688,18 @@ int nfsd_create_serv(struct net *net, bool no_rpcbind)
 		percpu_ref_exit(&nn->nfsd_net_ref);
 		return error;
 	}
+	/*
+	 * Register before publishing nn->nfsd_serv.  Namespaces are only
+	 * serialized against each other by nfsd_mutex here, so
+	 * taking the reference first is what guarantees a visible
+	 * nn->nfsd_serv never coincides with an unregistered notifier.
+	 */
+	nfsd_register_notifiers();
+
 	spin_lock(&nfsd_notifier_lock);
 	nn->nfsd_serv = serv;
 	spin_unlock(&nfsd_notifier_lock);
 
-	/* check if the notifier is already set */
-	if (atomic_inc_return(&nfsd_notifier_refcount) == 1) {
-		register_inetaddr_notifier(&nfsd_inetaddr_notifier);
-#if IS_ENABLED(CONFIG_IPV6)
-		register_inet6addr_notifier(&nfsd_inet6addr_notifier);
-#endif
-	}
 	nfsd_reset_write_verifier(nn);
 	return 0;
 }
@@ -707,7 +746,7 @@ int nfsd_set_nrthreads(int n, int *nthreads, struct net *net)
 	int err = 0;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
-	lockdep_assert_held(&nfsd_mutex);
+	lockdep_assert_held(&nn->nfsd_mutex);
 
 	if (nn->nfsd_serv == NULL || n <= 0)
 		return 0;
@@ -777,7 +816,7 @@ nfsd_svc(int n, int *nthreads, struct net *net, const struct cred *cred, const c
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	struct svc_serv *serv;
 
-	lockdep_assert_held(&nfsd_mutex);
+	lockdep_assert_held(&nn->nfsd_mutex);
 
 	dprintk("nfsd: creating service\n");
 
@@ -955,13 +994,13 @@ nfsd(void *vrqstp)
 		switch (svc_recv(rqstp, 5 * HZ)) {
 		case -ETIMEDOUT:
 			/* No work arrived within the timeout window */
-			if (mutex_trylock(&nfsd_mutex)) {
+			if (mutex_trylock(&nn->nfsd_mutex)) {
 				if (pool->sp_nrthreads > pool->sp_nrthrmin) {
 					trace_nfsd_dynthread_kill(net, pool);
 					set_bit(RQ_VICTIM, &rqstp->rq_flags);
 					have_mutex = true;
 				} else {
-					mutex_unlock(&nfsd_mutex);
+					mutex_unlock(&nn->nfsd_mutex);
 				}
 			} else {
 				trace_nfsd_dynthread_trylock_fail(net, pool);
@@ -970,7 +1009,7 @@ nfsd(void *vrqstp)
 		case -EBUSY:
 			/* No idle threads; consider spawning another */
 			if (pool->sp_nrthreads < pool->sp_nrthrmax) {
-				if (mutex_trylock(&nfsd_mutex)) {
+				if (mutex_trylock(&nn->nfsd_mutex)) {
 					if (pool->sp_nrthreads < pool->sp_nrthrmax) {
 						int ret;
 
@@ -980,7 +1019,7 @@ nfsd(void *vrqstp)
 							pr_notice_ratelimited("%s: unable to spawn new thread: %d\n",
 									      __func__, ret);
 					}
-					mutex_unlock(&nfsd_mutex);
+					mutex_unlock(&nn->nfsd_mutex);
 				} else {
 					trace_nfsd_dynthread_trylock_fail(net, pool);
 				}
@@ -998,7 +1037,7 @@ nfsd(void *vrqstp)
 	/* Release the thread */
 	svc_exit_thread(rqstp);
 	if (have_mutex)
-		mutex_unlock(&nfsd_mutex);
+		mutex_unlock(&nn->nfsd_mutex);
 	return 0;
 }
 
diff --git a/tools/testing/selftests/nfsd/nfsd_netlink_listener.c b/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
index bef7e8b1ee71..1294057b6f62 100644
--- a/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
+++ b/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
@@ -5,7 +5,7 @@
  *
  * Three groups:
  *   validation  - malformed/abusive LISTENER_SET requests are rejected by
- *                 nfsd_nl_validate_listeners(), before nfsd_mutex is taken.
+ *                 nfsd_nl_validate_listeners(), before nn->nfsd_mutex is taken.
  *   functional  - create/add/remove listeners and verify LISTENER_GET
  *                 reflects the set (round-trip of transport + addr:port).
  *   semantics   - once threads are running (THREADS_SET) a listener change
@@ -949,8 +949,8 @@ TEST_F(nfsd_listener, val_missing_transport)
 }
 
 /*
- * A name matching no transport class must be refused before nfsd_mutex is
- * taken, so it never reaches svc_xprt_create_from_sa() and its
+ * A name matching no transport class must be refused before nn->nfsd_mutex
+ * is taken, so it never reaches svc_xprt_create_from_sa() and its
  * request_module("svc%s", name) upcall.
  *
  * The errno cannot show that -- svc_xprt_create_from_sa() returns

-- 
2.55.0

