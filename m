Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-vbr14.xs4all.nl ([194.109.24.34]:3121 "EHLO
	smtp-vbr14.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752941AbZFBO3q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Jun 2009 10:29:46 -0400
Date: Tue, 2 Jun 2009 16:29:36 +0200
From: Miquel van Smoorenburg <mikevs@xs4all.net>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, bfields@fieldses.org, neilb@suse.de,
        mikevs@xs4all.net
Subject: nfs/sunrpc: high CPU usage in rpcauth_lookup_credcache with lots
	of uids [PATCH]
Message-ID: <20090602142933.GA27312@xs4all.net>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

[repost, with more people in the cc: list]

We run a cluster of POP and IMAP servers that are used by
hundreds of thousands of different users- we see as much
as 80.000 different users per server on any given day.

The servers have their mailspool NFS mounted, and each user has
a unique user-id.

We noticed a high CPU load on these servers, sometimes near
100% system time being used on all cores. I used oprofile to
find out where the CPU was being burned and it turned out to
be in rpcauth_lookup_credcache(). The credential cache hashtable
is sized way to small for our purposes- it's just 16 slots,
and with 100.000 entries in the generic and unix credential
caches the chainlength goes over 6000.

It's not that we have tens of thousands of different uids active on
the box at the same time, it's just that the box has lots of RAM
and all the caches - including the credential caches - just
grow and grow.

It appears that both the auth_unix and auth_generic credential
caches grow at the same rate and are the same size, but most of
the entries in the auth_generic credcache are inactive and could
be pruned by a rpcauth_prune_expired() run, where the auth_unix
credcache contains mostly active (refcounted) entries. The
auth_unix credcache can only be pruned by echo 3>/proc/sys/vm/drop_caches.

The patch below adds a hashtable size module parameter which if
set to e.g. 4096 fixes the problem for us. Note that this is a
patch for 2.6.27.x, it applies almost cleanly to 2.6.29.3, but it's
a proof-of-concept patch anyway. I'm not sure if this is the right or
complete fix, we should look into things like:

- is there a way to limit the size of the active number
  of entries in the auth_unix credential cache ?
- should the hashtables be size initially based on the amount of RAM ?
- should the hashtables be resized dynamically during use ?
- should rpcauth_cache_shrinker be run more often, not only
  when there is memory pressure but also from say a timer interrupt ?
  What should be used for nr_to_scan in that case ?
- why are both auth_generic and auth_unix used (probably has a
  good reason but I don't know much of the rpc/auth stuff really)

The simple fix would be to size the caches based on some RAM-based
heuristic, VFS pressure will then limit the hash chainlength to
something reasonable. Correct ? What would that heuristic look like ?


# ------ #

Detailed patch description:

1. bugfixes:
   - rpcauth_prune_expired: check nr_to_scan == 0 before decrementing it
     (in 2.6.29.3 nr_to_scan is decremented but otherwise ignored ?..)
   - rpcauth_prune_expired: keep cred on unused list when
     cred->cr_count == 0 and it's not expired yet
     (also fixed in 2.6.29.3)
   - set RPC_AUTH_EXPIRY_MORATORIUM to 5*HZ to make it match with
     the comment ('5 second garbage collection moratorium')
     (in 2.6.29.3 the comment has been fixed instead)

2. hashtable sizing:
   rpcauth_init_credcache: allocate hashtables dyamically
   auth_unix.c: use rpcauth_init_credcache
   auth_generic.c: use rpcauth_init_credcache
   sunrpc_syms.c: add hashsize module parameter
   init_sunrpc: call rpcauth_init_module with hashsize parameter

3. debugging:
   - rpcauth_prune_expired: don't always delete the
     entire cred_unused list, active entries are retained.
     rpcauth_lookup_credcache: add new creds to cred_unused
     right away, making the cred_unused list really a cred_lru list of
     all creds
   - adds sysctl debugging to analyze the number of active and
     inactive entries on the cred_unused list
   - add a sysctl knob to read the longest chainlength reached
     on any hashtable

diff -ru orig/linux-2.6.27.21/include/linux/sunrpc/auth.h linux-2.6.27.21/include/linux/sunrpc/auth.h
--- orig/linux-2.6.27.21/include/linux/sunrpc/auth.h	2009-03-23 23:04:09.000000000 +0100
+++ linux-2.6.27.21/include/linux/sunrpc/auth.h	2009-05-19 16:02:35.000000000 +0200
@@ -62,8 +62,12 @@
  */
 #define RPC_CREDCACHE_HASHBITS	4
 #define RPC_CREDCACHE_NR	(1 << RPC_CREDCACHE_HASHBITS)
+#define RPC_CREDCACHE_MIN	4
+#define RPC_CREDCACHE_MAX	16384
 struct rpc_cred_cache {
-	struct hlist_head	hashtable[RPC_CREDCACHE_NR];
+	int			hashsize;
+	int			hashbits;
+	struct hlist_head	*hashtable;
 	spinlock_t		lock;
 };
 
@@ -124,9 +128,8 @@
 extern const struct rpc_authops	authunix_ops;
 extern const struct rpc_authops	authnull_ops;
 
-void __init		rpc_init_authunix(void);
-void __init		rpc_init_generic_auth(void);
-void __init		rpcauth_init_module(void);
+int __init		rpc_init_generic_auth(void);
+int __init		rpcauth_init_module(int);
 void __exit		rpcauth_remove_module(void);
 void __exit		rpc_destroy_generic_auth(void);
 
diff -ru orig/linux-2.6.27.21/net/sunrpc/auth.c linux-2.6.27.21/net/sunrpc/auth.c
--- orig/linux-2.6.27.21/net/sunrpc/auth.c	2009-03-23 23:04:09.000000000 +0100
+++ linux-2.6.27.21/net/sunrpc/auth.c	2009-05-19 16:02:05.000000000 +0200
@@ -14,6 +14,8 @@
 #include <linux/hash.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/spinlock.h>
+#include <linux/vmalloc.h>
+#include <linux/sysctl.h>
 
 #ifdef RPC_DEBUG
 # define RPCDBG_FACILITY	RPCDBG_AUTH
@@ -28,6 +30,11 @@
 
 static LIST_HEAD(cred_unused);
 static unsigned long number_cred_unused;
+int credcache_hashsize = RPC_CREDCACHE_NR;
+
+#ifdef RPC_DEBUG
+static int credcache_max_chainlen;
+#endif
 
 static u32
 pseudoflavor_to_flavor(u32 flavor) {
@@ -149,7 +156,14 @@
 	new = kmalloc(sizeof(*new), GFP_KERNEL);
 	if (!new)
 		return -ENOMEM;
-	for (i = 0; i < RPC_CREDCACHE_NR; i++)
+	new->hashsize = credcache_hashsize;
+	new->hashbits = ilog2(new->hashsize);
+	new->hashtable = vmalloc(new->hashsize * sizeof(struct hlist_head));
+	if (!new->hashtable) {
+		kfree(new);
+		return -ENOMEM;
+	}
+	for (i = 0; i < new->hashsize; i++)
 		INIT_HLIST_HEAD(&new->hashtable[i]);
 	spin_lock_init(&new->lock);
 	auth->au_credcache = new;
@@ -186,7 +200,7 @@
 
 	spin_lock(&rpc_credcache_lock);
 	spin_lock(&cache->lock);
-	for (i = 0; i < RPC_CREDCACHE_NR; i++) {
+	for (i = 0; i < cache->hashsize; i++) {
 		head = &cache->hashtable[i];
 		while (!hlist_empty(head)) {
 			cred = hlist_entry(head->first, struct rpc_cred, cr_hash);
@@ -215,13 +229,15 @@
 	if (cache) {
 		auth->au_credcache = NULL;
 		rpcauth_clear_credcache(cache);
+		if (cache->hashtable)
+			vfree(cache->hashtable);
 		kfree(cache);
 	}
 }
 EXPORT_SYMBOL_GPL(rpcauth_destroy_credcache);
 
 
-#define RPC_AUTH_EXPIRY_MORATORIUM (60 * HZ)
+#define RPC_AUTH_EXPIRY_MORATORIUM (5 * HZ)
 
 /*
  * Remove stale credentials. Avoid sleeping inside the loop.
@@ -230,13 +246,12 @@
 rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
 {
 	spinlock_t *cache_lock;
-	struct rpc_cred *cred;
+	struct rpc_cred *cred, *n;
 	unsigned long expired = jiffies - RPC_AUTH_EXPIRY_MORATORIUM;
 
-	while (!list_empty(&cred_unused)) {
-		cred = list_entry(cred_unused.next, struct rpc_cred, cr_lru);
-		list_del_init(&cred->cr_lru);
-		number_cred_unused--;
+	list_for_each_entry_safe(cred, n, &cred_unused, cr_lru) {
+		if (nr_to_scan == 0)
+			break;
 		if (atomic_read(&cred->cr_count) != 0)
 			continue;
 		/* Enforce a 5 second garbage collection moratorium */
@@ -247,13 +262,12 @@
 		spin_lock(cache_lock);
 		if (atomic_read(&cred->cr_count) == 0) {
 			get_rpccred(cred);
-			list_add_tail(&cred->cr_lru, free);
+			list_move_tail(&cred->cr_lru, free);
+			number_cred_unused--;
 			rpcauth_unhash_cred_locked(cred);
 			nr_to_scan--;
 		}
 		spin_unlock(cache_lock);
-		if (nr_to_scan == 0)
-			break;
 	}
 	return nr_to_scan;
 }
@@ -267,8 +281,6 @@
 	LIST_HEAD(free);
 	int res;
 
-	if (list_empty(&cred_unused))
-		return 0;
 	spin_lock(&rpc_credcache_lock);
 	nr_to_scan = rpcauth_prune_expired(&free, nr_to_scan);
 	res = (number_cred_unused / 100) * sysctl_vfs_cache_pressure;
@@ -290,11 +302,19 @@
 	struct rpc_cred	*cred = NULL,
 			*entry, *new;
 	unsigned int nr;
+#ifdef RPC_DEBUG
+	int chainlen = 0;
+#endif
 
-	nr = hash_long(acred->uid, RPC_CREDCACHE_HASHBITS);
+	nr = hash_long(acred->uid, cache->hashbits);
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(entry, pos, &cache->hashtable[nr], cr_hash) {
+#ifdef RPC_DEBUG
+		chainlen++;
+		if (chainlen > credcache_max_chainlen)
+			credcache_max_chainlen = chainlen;
+#endif
 		if (!entry->cr_ops->crmatch(acred, entry, flags))
 			continue;
 		spin_lock(&cache->lock);
@@ -331,6 +351,15 @@
 	} else
 		list_add_tail(&new->cr_lru, &free);
 	spin_unlock(&cache->lock);
+#ifdef RPC_DEBUG
+	/* Add to LRU list early for statistics */
+	if (cred == new) {
+		spin_lock(&rpc_credcache_lock);
+		list_add_tail(&cred->cr_lru, &cred_unused);
+		number_cred_unused++;
+		spin_unlock(&rpc_credcache_lock);
+	}
+#endif
 found:
 	if (test_bit(RPCAUTH_CRED_NEW, &cred->cr_flags)
 			&& cred->cr_ops->cr_init != NULL
@@ -566,19 +595,147 @@
 		test_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags) != 0;
 }
 
+#ifdef RPC_DEBUG
+static int proc_credcache_hashsize(struct ctl_table *table, int write,
+                        struct file *file, void __user *buffer,
+                        size_t *length, loff_t *ppos)
+{
+	int tmp = credcache_hashsize;
+
+	table->data = &tmp;
+	table->maxlen = sizeof(int);
+	proc_dointvec(table, write, file, buffer, length, ppos);
+	if (write) {
+		if (tmp < RPC_CREDCACHE_MIN ||
+		    tmp > RPC_CREDCACHE_MAX ||
+		    !is_power_of_2(tmp))
+			return -EINVAL;
+		credcache_hashsize = tmp;
+	}
+	return 0;
+}
+
+static int proc_auth_credcache_size(struct ctl_table *table, int write,
+                        struct file *file, void __user *buffer,
+                        size_t *length, loff_t *ppos)
+{
+	struct rpc_cred	*cred;
+	unsigned long n, used = 0, unused = 0;
+	int tmp;
+
+	spin_lock(&rpc_credcache_lock);
+        list_for_each_entry(cred, &cred_unused, cr_lru) {
+		if (atomic_read(&cred->cr_count))
+			used++;
+		else
+			unused++;
+	}
+	spin_unlock(&rpc_credcache_lock);
+
+	n = table->extra1 ? used : unused;
+	tmp = n > INT_MAX ? INT_MAX : n;
+	table->data = &tmp;
+	table->maxlen = sizeof(int);
+
+	proc_dointvec(table, write, file, buffer, length, ppos);
+	if (write) {
+		int nr = unused - tmp;
+		if (nr > 0)
+			rpcauth_cache_shrinker(nr, GFP_KERNEL);
+	}
+
+	return 0;
+}
+
+static ctl_table sunrpc_credcache_knobs_table [] = {
+	{
+		.procname	= "credcache_hashsize",
+		.data		= NULL,
+		.mode		= 0644,
+		.proc_handler	= &proc_credcache_hashsize,
+	},
+	{
+		.procname	= "credcache_used",
+		.data		= NULL,
+		.mode		= 0444,
+		.proc_handler	= &proc_auth_credcache_size,
+		.extra1		= (void *)1,
+	},
+	{
+		.procname	= "credcache_unused",
+		.data		= NULL,
+		.mode		= 0644,
+		.proc_handler	= &proc_auth_credcache_size,
+		.extra1		= (void *)0,
+	},
+	{
+		.procname	= "credcache_total",
+		.data		= &number_cred_unused,
+		.maxlen		= sizeof(unsigned long),
+		.mode		= 0444,
+		.proc_handler	= &proc_doulongvec_minmax,
+	},
+	{
+		.procname	= "credcache_max_chainlen",
+		.data		= &credcache_max_chainlen,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
+		.ctl_name	= 0,
+	}
+};
+
+static ctl_table sunrpc_credcache_table[] = {
+	{
+		.ctl_name	= CTL_SUNRPC,
+		.procname	= "sunrpc",
+		.mode		= 0555,
+		.child		= sunrpc_credcache_knobs_table,
+	},
+	{
+		.ctl_name = 0,
+	}
+};
+
+static struct ctl_table_header *sunrpc_credcache_table_header;
+#endif
+
 static struct shrinker rpc_cred_shrinker = {
 	.shrink = rpcauth_cache_shrinker,
 	.seeks = DEFAULT_SEEKS,
 };
 
-void __init rpcauth_init_module(void)
+int __init rpcauth_init_module(int hashsize)
 {
-	rpc_init_authunix();
-	rpc_init_generic_auth();
+	int err;
+
+	if (hashsize) {
+		hashsize = min(hashsize, RPC_CREDCACHE_MAX);
+		hashsize = max(hashsize, RPC_CREDCACHE_MIN);
+		credcache_hashsize = rounddown_pow_of_two(hashsize);
+		printk(KERN_INFO "RPC: credcache hashtable size %d\n",
+							credcache_hashsize);
+	}
+
+	err = rpc_init_generic_auth();
+	if (err)
+		goto out;
+#ifdef RPC_DEBUG
+	sunrpc_credcache_table_header =
+		register_sysctl_table(sunrpc_credcache_table);
+#endif
 	register_shrinker(&rpc_cred_shrinker);
+out:
+	return err;
 }
 
 void __exit rpcauth_remove_module(void)
 {
+#ifdef RPC_DEBUG
+	if (sunrpc_credcache_table_header)
+		unregister_sysctl_table(sunrpc_credcache_table_header);
+#endif
 	unregister_shrinker(&rpc_cred_shrinker);
 }
diff -ru orig/linux-2.6.27.21/net/sunrpc/auth_generic.c linux-2.6.27.21/net/sunrpc/auth_generic.c
--- orig/linux-2.6.27.21/net/sunrpc/auth_generic.c	2009-03-23 23:04:09.000000000 +0100
+++ linux-2.6.27.21/net/sunrpc/auth_generic.c	2009-05-19 12:03:40.000000000 +0200
@@ -26,7 +26,6 @@
 };
 
 static struct rpc_auth generic_auth;
-static struct rpc_cred_cache generic_cred_cache;
 static const struct rpc_credops generic_credops;
 
 /*
@@ -158,20 +157,16 @@
 	return 0;
 }
 
-void __init rpc_init_generic_auth(void)
+int __init rpc_init_generic_auth(void)
 {
-	spin_lock_init(&generic_cred_cache.lock);
+	return rpcauth_init_credcache(&generic_auth);
 }
 
 void __exit rpc_destroy_generic_auth(void)
 {
-	rpcauth_clear_credcache(&generic_cred_cache);
+	rpcauth_destroy_credcache(&generic_auth);
 }
 
-static struct rpc_cred_cache generic_cred_cache = {
-	{{ NULL, },},
-};
-
 static const struct rpc_authops generic_auth_ops = {
 	.owner = THIS_MODULE,
 	.au_name = "Generic",
@@ -182,7 +177,6 @@
 static struct rpc_auth generic_auth = {
 	.au_ops = &generic_auth_ops,
 	.au_count = ATOMIC_INIT(0),
-	.au_credcache = &generic_cred_cache,
 };
 
 static const struct rpc_credops generic_credops = {
diff -ru orig/linux-2.6.27.21/net/sunrpc/auth_unix.c linux-2.6.27.21/net/sunrpc/auth_unix.c
--- orig/linux-2.6.27.21/net/sunrpc/auth_unix.c	2009-03-23 23:04:09.000000000 +0100
+++ linux-2.6.27.21/net/sunrpc/auth_unix.c	2009-05-19 14:06:45.000000000 +0200
@@ -28,15 +28,23 @@
 #endif
 
 static struct rpc_auth		unix_auth;
-static struct rpc_cred_cache	unix_cred_cache;
 static const struct rpc_credops	unix_credops;
 
 static struct rpc_auth *
 unx_create(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
 {
+	int err;
+
 	dprintk("RPC:       creating UNIX authenticator for client %p\n",
 			clnt);
 	atomic_inc(&unix_auth.au_count);
+	if (!unix_auth.au_credcache) {
+		err = rpcauth_init_credcache(&unix_auth);
+		if (err) {
+			atomic_dec(&unix_auth.au_count);
+			return ERR_PTR(err);
+		}
+	}
 	return &unix_auth;
 }
 
@@ -202,11 +210,6 @@
 	return p;
 }
 
-void __init rpc_init_authunix(void)
-{
-	spin_lock_init(&unix_cred_cache.lock);
-}
-
 const struct rpc_authops authunix_ops = {
 	.owner		= THIS_MODULE,
 	.au_flavor	= RPC_AUTH_UNIX,
@@ -218,17 +221,12 @@
 };
 
 static
-struct rpc_cred_cache	unix_cred_cache = {
-};
-
-static
 struct rpc_auth		unix_auth = {
 	.au_cslack	= UNX_WRITESLACK,
 	.au_rslack	= 2,			/* assume AUTH_NULL verf */
 	.au_ops		= &authunix_ops,
 	.au_flavor	= RPC_AUTH_UNIX,
 	.au_count	= ATOMIC_INIT(0),
-	.au_credcache	= &unix_cred_cache,
 };
 
 static
diff -ru orig/linux-2.6.27.21/net/sunrpc/sunrpc_syms.c linux-2.6.27.21/net/sunrpc/sunrpc_syms.c
--- orig/linux-2.6.27.21/net/sunrpc/sunrpc_syms.c	2009-03-23 23:04:09.000000000 +0100
+++ linux-2.6.27.21/net/sunrpc/sunrpc_syms.c	2009-05-19 12:53:10.000000000 +0200
@@ -23,6 +23,7 @@
 #include <linux/sunrpc/xprtsock.h>
 
 extern struct cache_detail ip_map_cache, unix_gid_cache;
+static int hashsize;
 
 static int __init
 init_sunrpc(void)
@@ -31,13 +32,14 @@
 	if (err)
 		goto out;
 	err = rpc_init_mempool();
-	if (err) {
-		unregister_rpc_pipefs();
-		goto out;
-	}
+	if (err)
+		goto out_err1;
 #ifdef RPC_DEBUG
 	rpc_register_sysctl();
 #endif
+	err = rpcauth_init_module(hashsize);
+	if (err)
+		goto out_err2;
 #ifdef CONFIG_PROC_FS
 	rpc_proc_init();
 #endif
@@ -45,7 +47,14 @@
 	cache_register(&unix_gid_cache);
 	svc_init_xprt_sock();	/* svc sock transport */
 	init_socket_xprt();	/* clnt sock transport */
-	rpcauth_init_module();
+	goto out;
+out_err2:
+	rpc_destroy_mempool();
+#ifdef RPC_DEBUG
+	rpc_unregister_sysctl();
+#endif
+out_err1:
+	unregister_rpc_pipefs();
 out:
 	return err;
 }
@@ -67,6 +76,8 @@
 	rpc_proc_exit();
 #endif
 }
+module_param(hashsize, int, 0);
+MODULE_PARM_DESC(hashsize, "size of hashtables for credential caches");
 MODULE_LICENSE("GPL");
 module_init(init_sunrpc);
 module_exit(cleanup_sunrpc);
