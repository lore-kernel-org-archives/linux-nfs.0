Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793119542;
	b=uLHHq+ztpTKPG6nMaR4XK5ogbHHum0szEF553JNXyJ4hR0NpWIO+KPlORjIQohXud3zI
	 pT0S70JnX8ON+Pc60hHS+kSzR+/yWWdu18qw16GWZiFF6dBdRz54M7BIvB3FONJ32IoSf
	 e/KZIHaAAkRmT/xMC1qbYErf7YDievstAa2GgAI4k+LF+L+IfMuYpNh3/4iseMSdqyKih
	 KXrRxQVqAHpA7/24NptfiECJ/3e719cUx98R1OKbzInWc9ps3A5UHWpvNi/fqmMTep/UC
	 erkpTB4LwBL9CCZYw2b5gjnKgTLNo08aKluDv6ckfXurRnL3LlLTyMX7kK8i36zn2bA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793119542;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=jq1Fk1+7x3AM/2zg7Fbt5XSav3EE7FX3Cc6sMyvrql8=;
	b=AXa7+2cRvzZmpG+lxHIpPKJ884eKeY6P1FjA9NWqi4+S2CQBbSkoMgX5uNy3oaaKXxsM
	 cyG3Dv1dicTMGntmT/jtWWojbjV8I5uyNeGuR/C/QFEb7M+hWd9U3v60UiGDkpTzGkjvX
	 j8ztwAAgpsjhgWAUxseCvnzLcfS+W/8H2WcbJ0ndfWUcL1ujg01HvFSRTeHCFHWEXkZ5O
	 2npe0mW3rRW39ghni62274DIKNIqNg6n3UeyE+Q6xMK6PfrgF+TmFonKbVO4JJgAw2bKX
	 wArb9sJ0bCw6OM8fZtTH1cSGH4C+dlsPRX8i9K4uUpc0PtHc3ITZnDtcmCfqcmj6pmQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PSl14wDh;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8A8E3606A32D;
	Tue, 27 Oct 2026 16:45:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PSl14wDh
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6DD741F031E4;
	Tue, 27 Oct 2026 16:45:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793119542;
	bh=jq1Fk1+7x3AM/2zg7Fbt5XSav3EE7FX3Cc6sMyvrql8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=PSl14wDhLZBQNnnAJuXbD2YQ9+JlnQRLHCplDc5D+WYLF6drgT76TYW2Z/3pB1eCN
	 QXywPqjw9SPIQQNtdSXGpDiZ0FYSug0+ppplPST6eQ7dz4SKcXeE7HBc1vgcHeDUlO
	 3/QNsO7iHNPO5ncUmguGk6cMZ/k9spnwnR3Mc1+6rOgxhFgLv8ffWC3D2oBhq40nbc
	 HmFhUZMgXYV2M9rfNQSTHGrW7lKSznSzf29/Kj2TJHDsfD20iGjBla5a0olgX6bSuh
	 Zwpdwh57irLCUEQLjoK8cmCXHAlF/7XZB2Mn7dRopFvXuMDQJWEiylsG58vRSCMcZl
	 wrMLYTffaZt9g==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 27 Oct 2026 12:45:27 -0400
Subject: [PATCH 4/6] NFSD: Keep per-export statistics across export cache
 updates
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261027-export-iomode-v1-4-262ed932a036@kernel.org>
References: <20261027-export-iomode-v1-0-262ed932a036@kernel.org>
In-Reply-To: <20261027-export-iomode-v1-0-262ed932a036@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
 Shuah Khan <skhan@linuxfoundation.org>, 
 Randy Dunlap <rdunlap@infradead.org>, Mike Snitzer <snitzer@kernel.org>, 
 Donald Hunter <donald.hunter@gmail.com>, Jakub Kicinski <kuba@kernel.org>, 
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>
Cc: Steve Dickson <steved@redhat.com>, netdev@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 linux-doc@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=13126; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=GQ8u6mw+L8sdVp9BTaya3XnGp6xMKZ4Ev2QXmykjLYQ=;
 b=kA0DAAoBAA5oQRlWghUByyZiAGrg1SvIi1o6w/oc7F8IVEVnHZ2xxe67Q90zA60KeHUn2WgIg
 IkCMwQAAQoAHRYhBEvA17JEcbKhhOr10wAOaEEZVoIVBQJq4NUrAAoJEAAOaEEZVoIVzVAQALnG
 kwquN/3DIVvc4XQJZ2iuLZMZR7HrBJHt6kp8H+zj/7qpiMQvcOfaLYwO6L1ZOxQaFa9zRjxVUMj
 uuugk4Y8sxYiLydc/xC4M6KkFdKWcZA9lrptWjQwczDRa4fnxZCxcZEeriSGp8w/21X0ThDimKl
 PLKMbvqWj4rIBO4rmXM5I9qVhFTI5jGSgYmSZJggEjIWSX1USDCEV/bowcpy2nPMz1v2wL/HXmg
 ki3LrbFrDcSPZdaTlV2Tt3oedjx0ACUmvMw9zqr0WSkBIrqnZDPpsFhwNC5z1ZbIAomcey5HUMi
 RcC64l/RhTFQbntinRmfx/51BzfEFfsByjim832sddcgDiIEQNU7EWGqk/LOwNg3f+cmO7vaXZL
 cZdLRB9uM0st0PSN3VF4i0/XE2dlc1+/8KiqYeDhnN7AUwJGJH8X4AXixLqZrSL/tvRPdKQAATY
 D6LrmTVtv7v6g78xM+4jX+PxsP1wqC67sB99aahWT8zSZK2fvnVTI1740edPMyafa9U6Q0dfT9e
 hqMMDzbEYDqfwdyC2pfsvUdCVZakqsJGgz568pu1W4hkTCjVorwP1SHn+sPOJkzW5VBP1Rti3BA
 0xGzX91HAxWHYMiKPrT0qafVmDh0KhR1wxqtUvDNBlk8l4yQZjTEhK0TJTc7AG/SCk3Dc/tyyut
 Z+ZhQ
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The counters in /proc/fs/nfsd/export_stats live in the export cache
entry. mountd replaces an entry when it refreshes it, and a cache
flush (exportfs -r) or an nfsd restart removes all of them, so the
counters of an export restart at zero at unpredictable times. A tool
that samples the counters over an interval then loses the traffic of
the replaced entry.

Keep the statistics in a per-net table keyed on the export root and
the client name. The root is identified by the st_dev and inode
number that getattr reports, plus the inode generation. btrfs
subvolumes share i_sb->s_dev and a snapshot root has the inode number
and generation of its source, but getattr gives each subvolume its
own st_dev.

Every export cache entry for the same root and client takes a
reference to the shared export_stats in svc_export_init() and drops
it when the entry is freed. Keying on the inode instead of holding
ex_path keeps unused statistics from pinning the exported mount.

Statistics that no entry has used for an hour no longer match a
lookup, since the dev_t of a vanished filesystem can be reused by
another one. A delayed work item, queued when statistics become idle,
frees them; net shutdown frees the rest.

A replaced cache entry stays hashed until cache_clean() and would show
the same shared counters as its replacement, so export_stats skips it.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/export.c | 236 +++++++++++++++++++++++++++++++++++++++++++++++--------
 fs/nfsd/export.h |  16 ++++
 fs/nfsd/netns.h  |   6 ++
 3 files changed, 226 insertions(+), 32 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index c71350965789..640973d02b6c 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -594,28 +594,198 @@ static void nfsd4_fslocs_free(struct nfsd4_fs_locations *fsloc)
 	fsloc->locations = NULL;
 }
 
-static int export_stats_init(struct export_stats *stats)
+/* Drop export_stats that no export cache entry has used for this long */
+#define EXPORT_STATS_IDLE_SECS	3600
+
+static u64 export_stats_key(dev_t dev, u64 ino)
+{
+	return ((u64)dev << 32) ^ ino;
+}
+
+static bool export_stats_expired(const struct export_stats *stats,
+				 time64_t now)
+{
+	return !stats->es_users &&
+	       now - stats->es_idle_since > EXPORT_STATS_IDLE_SECS;
+}
+
+/*
+ * Expired statistics never match: once the filesystem is gone, its
+ * dev_t can be reused by a different one.
+ */
+static struct export_stats *export_stats_find(struct nfsd_net *nn, dev_t dev,
+					      u64 ino, u32 gen,
+					      const char *client, time64_t now)
+{
+	struct export_stats *stats;
+
+	hash_for_each_possible(nn->export_stats_hash, stats, es_node,
+			       export_stats_key(dev, ino))
+		if (stats->es_dev == dev && stats->es_ino == ino &&
+		    stats->es_gen == gen && !strcmp(stats->es_client, client) &&
+		    !export_stats_expired(stats, now))
+			return stats;
+	return NULL;
+}
+
+static void export_stats_free(struct export_stats *stats)
 {
-	stats->start_time = ktime_get_seconds();
-	return percpu_counter_init_many(stats->counter, 0, GFP_KERNEL,
-					EXP_STATS_COUNTERS_NUM);
+	percpu_counter_destroy_many(stats->counter, EXP_STATS_COUNTERS_NUM);
+	kfree(stats->es_client);
+	kfree(stats);
 }
 
-static void export_stats_reset(struct export_stats *stats)
+static void export_stats_queue_reap(struct nfsd_net *nn)
 {
+	queue_delayed_work(system_dfl_wq, &nn->export_stats_reaper,
+			   (EXPORT_STATS_IDLE_SECS + 1) * HZ);
+}
+
+/*
+ * Free expired statistics. Re-arm while idle ones remain, because
+ * export_stats_put() does not queue the work while it is pending.
+ */
+static void export_stats_reap(struct work_struct *work)
+{
+	struct nfsd_net *nn = container_of(to_delayed_work(work),
+					   struct nfsd_net,
+					   export_stats_reaper);
+	time64_t now = ktime_get_seconds();
+	struct export_stats *stats;
+	struct hlist_node *tmp;
+	HLIST_HEAD(expired);
+	bool idle = false;
+	int bkt;
+
+	spin_lock_bh(&nn->export_stats_lock);
+	hash_for_each_safe(nn->export_stats_hash, bkt, tmp, stats, es_node) {
+		if (export_stats_expired(stats, now)) {
+			hash_del(&stats->es_node);
+			hlist_add_head(&stats->es_node, &expired);
+		} else if (!stats->es_users) {
+			idle = true;
+		}
+	}
+	if (idle)
+		export_stats_queue_reap(nn);
+	spin_unlock_bh(&nn->export_stats_lock);
+
+	hlist_for_each_entry_safe(stats, tmp, &expired, es_node) {
+		hlist_del(&stats->es_node);
+		export_stats_free(stats);
+	}
+}
+
+/*
+ * Return the statistics of the export root and client of @exp, with a
+ * reference. Keying them on the root inode rather than on ex_path keeps
+ * an unused export_stats from pinning the exported mount. Returns NULL
+ * if getattr or memory allocation fails.
+ */
+static struct export_stats *export_stats_get(struct svc_export *exp)
+{
+	struct nfsd_net *nn = net_generic(exp->cd->net, nfsd_net_id);
+	struct inode *inode = d_inode(exp->ex_path.dentry);
+	const char *client = exp->ex_client->name;
+	time64_t now = ktime_get_seconds();
+	u32 gen = inode->i_generation;
+	struct export_stats *stats, *new;
+	struct kstat stat;
+	dev_t dev;
+	u64 ino;
+
+	/*
+	 * btrfs subvolumes share i_sb->s_dev, and a snapshot's root has the
+	 * inode number and generation of its source. getattr reports a
+	 * separate st_dev for each subvolume. The key is never shown to
+	 * anyone, so skip the LSM check.
+	 */
+	if (vfs_getattr_nosec(&exp->ex_path, &stat, STATX_INO,
+			      AT_STATX_DONT_SYNC))
+		return NULL;
+	dev = stat.dev;
+	ino = stat.ino;
+
+	spin_lock_bh(&nn->export_stats_lock);
+	stats = export_stats_find(nn, dev, ino, gen, client, now);
+	if (stats)
+		stats->es_users++;
+	spin_unlock_bh(&nn->export_stats_lock);
+	if (stats)
+		return stats;
+
+	new = kzalloc_obj(*new);
+	if (!new)
+		return NULL;
+	new->es_client = kstrdup(client, GFP_KERNEL);
+	if (!new->es_client ||
+	    percpu_counter_init_many(new->counter, 0, GFP_KERNEL,
+				     EXP_STATS_COUNTERS_NUM)) {
+		kfree(new->es_client);
+		kfree(new);
+		return NULL;
+	}
+	new->es_nn = nn;
+	new->es_users = 1;
+	new->es_dev = dev;
+	new->es_ino = ino;
+	new->es_gen = gen;
+	new->start_time = now;
+
+	spin_lock_bh(&nn->export_stats_lock);
+	stats = export_stats_find(nn, dev, ino, gen, client, now);
 	if (stats) {
-		int i;
+		stats->es_users++;
+	} else {
+		hash_add(nn->export_stats_hash, &new->es_node,
+			 export_stats_key(dev, ino));
+		stats = new;
+		new = NULL;
+	}
+	spin_unlock_bh(&nn->export_stats_lock);
 
-		for (i = 0; i < EXP_STATS_COUNTERS_NUM; i++)
-			percpu_counter_set(&stats->counter[i], 0);
+	if (new)
+		export_stats_free(new);
+	return stats;
+}
+
+/* Called from an RCU callback */
+static void export_stats_put(struct export_stats *stats)
+{
+	struct nfsd_net *nn;
+
+	if (!stats)
+		return;
+	nn = stats->es_nn;
+	spin_lock_bh(&nn->export_stats_lock);
+	if (!--stats->es_users) {
+		stats->es_idle_since = ktime_get_seconds();
+		export_stats_queue_reap(nn);
 	}
+	spin_unlock_bh(&nn->export_stats_lock);
 }
 
-static void export_stats_destroy(struct export_stats *stats)
+static s64 export_stats_sum(struct export_stats *stats, int counter)
 {
-	if (stats)
-		percpu_counter_destroy_many(stats->counter,
-					    EXP_STATS_COUNTERS_NUM);
+	return stats ? percpu_counter_sum_positive(&stats->counter[counter]) : 0;
+}
+
+static void export_stats_shutdown(struct nfsd_net *nn)
+{
+	struct export_stats *stats;
+	struct hlist_node *tmp;
+	int bkt;
+
+	/* Wait for svc_export_release() to drop its references */
+	rcu_barrier();
+	/* Only now, as those last puts can queue the reaper */
+	cancel_delayed_work_sync(&nn->export_stats_reaper);
+	hash_for_each_safe(nn->export_stats_hash, bkt, tmp, stats, es_node) {
+		hash_del(&stats->es_node);
+		if (WARN_ON_ONCE(stats->es_users))
+			continue;
+		export_stats_free(stats);
+	}
 }
 
 static void svc_export_release(struct rcu_head *rcu_head)
@@ -624,8 +794,7 @@ static void svc_export_release(struct rcu_head *rcu_head)
 			ex_rcu);
 
 	nfsd4_fslocs_free(&exp->ex_fslocs);
-	export_stats_destroy(exp->ex_stats);
-	kfree(exp->ex_stats);
+	export_stats_put(exp->ex_stats);
 	kfree(exp->ex_uuid);
 	kfree(exp);
 }
@@ -1497,15 +1666,15 @@ static int svc_export_show(struct seq_file *m,
 	seq_putc(m, '\t');
 	seq_escape(m, exp->ex_client->name, " \t\n\\");
 	if (export_stats) {
-		struct percpu_counter *counter = exp->ex_stats->counter;
+		struct export_stats *stats = exp->ex_stats;
 
-		seq_printf(m, "\t%lld\n", exp->ex_stats->start_time);
+		seq_printf(m, "\t%lld\n", stats ? stats->start_time : 0);
 		seq_printf(m, "\tfh_stale: %lld\n",
-			   percpu_counter_sum_positive(&counter[EXP_STATS_FH_STALE]));
+			   export_stats_sum(stats, EXP_STATS_FH_STALE));
 		seq_printf(m, "\tio_read: %lld\n",
-			   percpu_counter_sum_positive(&counter[EXP_STATS_IO_READ]));
+			   export_stats_sum(stats, EXP_STATS_IO_READ));
 		seq_printf(m, "\tio_write: %lld\n",
-			   percpu_counter_sum_positive(&counter[EXP_STATS_IO_WRITE]));
+			   export_stats_sum(stats, EXP_STATS_IO_WRITE));
 		seq_putc(m, '\n');
 		return 0;
 	}
@@ -1557,7 +1726,7 @@ static void svc_export_init(struct cache_head *cnew, struct cache_head *citem)
 	new->ex_layout_types = 0;
 	new->ex_uuid = NULL;
 	new->cd = item->cd;
-	export_stats_reset(new->ex_stats);
+	new->ex_stats = export_stats_get(new);
 }
 
 static void export_update(struct cache_head *cnew, struct cache_head *citem)
@@ -1596,18 +1765,8 @@ static struct cache_head *svc_export_alloc(void)
 	if (!i)
 		return NULL;
 
-	i->ex_stats = kmalloc_obj(*(i->ex_stats));
-	if (!i->ex_stats) {
-		kfree(i);
-		return NULL;
-	}
-
-	if (export_stats_init(i->ex_stats)) {
-		kfree(i->ex_stats);
-		kfree(i);
-		return NULL;
-	}
-
+	/* svc_export_init() attaches the shared statistics */
+	i->ex_stats = NULL;
 	return &i->h;
 }
 
@@ -2190,6 +2349,14 @@ static int e_show(struct seq_file *m, void *p)
 
 	if (cache_check_rcu(cd, &exp->h, NULL))
 		return 0;
+	/*
+	 * sunrpc_cache_update() leaves a replaced entry hashed, with an
+	 * expiry_time of zero, until cache_clean() removes it. It shares
+	 * export_stats with its replacement, so showing it would count the
+	 * same traffic twice.
+	 */
+	if (export_stats && !exp->h.expiry_time)
+		return 0;
 
 	return svc_export_show(m, cd, cp);
 }
@@ -2212,6 +2379,10 @@ nfsd_export_init(struct net *net)
 
 	dprintk("nfsd: initializing export module (net: %x).\n", net->ns.inum);
 
+	spin_lock_init(&nn->export_stats_lock);
+	hash_init(nn->export_stats_hash);
+	INIT_DELAYED_WORK(&nn->export_stats_reaper, export_stats_reap);
+
 	nn->svc_export_cache = cache_create_net(&svc_export_cache_template, net);
 	if (IS_ERR(nn->svc_export_cache))
 		return PTR_ERR(nn->svc_export_cache);
@@ -2264,6 +2435,7 @@ nfsd_export_shutdown(struct net *net)
 	cache_unregister_net(nn->svc_export_cache, net);
 	cache_destroy_net(nn->svc_expkey_cache, net);
 	cache_destroy_net(nn->svc_export_cache, net);
+	export_stats_shutdown(nn);
 	svcauth_unix_purge(net);
 
 	dprintk("nfsd: export shutdown complete (net: %x).\n", net->ns.inum);
diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
index 0e832990a12c..70842782629f 100644
--- a/fs/nfsd/export.h
+++ b/fs/nfsd/export.h
@@ -11,6 +11,7 @@
 #include <linux/nfs4.h>
 
 struct knfsd_fh;
+struct nfsd_net;
 struct svc_fh;
 struct svc_rqst;
 
@@ -55,7 +56,22 @@ enum {
 	EXP_STATS_COUNTERS_NUM
 };
 
+/*
+ * Export cache entries are replaced when mountd refreshes them and are
+ * removed by a cache flush. The statistics of an export outlive its
+ * cache entries: every entry for the same export root and client shares
+ * one export_stats, which stays in nn->export_stats_hash for a time
+ * after its last entry is gone.
+ */
 struct export_stats {
+	struct hlist_node	es_node;
+	struct nfsd_net		*es_nn;
+	unsigned int		es_users;	/* under nn->export_stats_lock */
+	time64_t		es_idle_since;
+	dev_t			es_dev;
+	u64			es_ino;
+	u32			es_gen;
+	char			*es_client;
 	time64_t		start_time;
 	struct percpu_counter	counter[EXP_STATS_COUNTERS_NUM];
 };
diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index fa3545963902..66e8cfff238b 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -11,6 +11,7 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <linux/filelock.h>
+#include <linux/hashtable.h>
 #include <linux/nfs4.h>
 #include <linux/percpu_counter.h>
 #include <linux/percpu-refcount.h>
@@ -77,6 +78,11 @@ struct nfsd_net {
 	struct cache_detail *svc_expkey_cache;
 	struct cache_detail *svc_export_cache;
 
+	/* per-export statistics, shared by export cache entries */
+	spinlock_t export_stats_lock;
+	DECLARE_HASHTABLE(export_stats_hash, 6);
+	struct delayed_work export_stats_reaper;
+
 	struct cache_detail *idtoname_cache;
 	struct cache_detail *nametoid_cache;
 

-- 
2.56.0

