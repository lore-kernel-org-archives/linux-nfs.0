Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-vbr7.xs4all.nl ([194.109.24.27]:3176 "EHLO
	smtp-vbr7.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755453AbZICOoM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Sep 2009 10:44:12 -0400
Subject: sunrpc: dynamically allocate credcache hashtables [was: Re: VM
 issue causing high CPU loads]
From: Miquel van Smoorenburg <mikevs@xs4all.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Yohan <ytordjman@corp.free.fr>, Andrew Morton <akpm@linux-foundation.org>,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Neil Brown <neilb@suse.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        mikevs@xs4all.net
In-Reply-To: <1251986526.18338.29.camel@heimdal.trondhjem.org>
References: <4A92A25A.4050608@yohan.staff.proxad.net>
	 <20090824162155.ce323f08.akpm@linux-foundation.org>
	 <4A96463E.5080002@corp.free.fr> <4A9C34F8.2010307@corp.free.fr>
	 <20090902170642.f4381c1d.akpm@linux-foundation.org>
	 <1251982884.18338.9.camel@heimdal.trondhjem.org>
	 <4A9FC719.9020104@corp.free.fr>
	 <1251986526.18338.29.camel@heimdal.trondhjem.org>
Content-Type: multipart/mixed; boundary="=-xA1TwXuWMGBFgzI/anK+"
Date: Thu, 03 Sep 2009 16:35:14 +0200
Message-Id: <1251988514.20818.22.camel@laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--=-xA1TwXuWMGBFgzI/anK+
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2009-09-03 at 10:02 -0400, Trond Myklebust wrote:
> On Thu, 2009-09-03 at 15:39 +0200, Yohan wrote:
> > > As far as I can see, there is no RPCSEC_GSS involved, so credentials
> > > should never expire. They will be reused as long as processes aren't
> > > switching between thousands and thousands of different combinations of
> > > uid, gid and groups.
> > My servers are imap servers.
> > Foreach user (~15 million) it have a specific uid over ~10 nfs netapp 
> > storage.
> 
> OK, so 16 hash buckets are likely to be filled with ~10^6 entries each.
> I can see that might be a performance issue...
> 
> So afaics, you did try adjusting the hashtable size. How much larger
> does it have to be before you start to get acceptable performance? If it
> solves your problem we could make hash table sizes adjustable via a
> module parameter, for instance.

That is *exactly* what my patch does :)
I ported it to 2.6.31-rc8-bk2 this afternoon, that was trivial.

What I wanted to discuss was finding out if there was another solution,
or that we should build something that auto-tunes hashtable sizes, of if
there was a way to limit the size of the cache in another way.

I have the same usage pattern as Yohan (also an IMAP server for
potentially a few million different uids) - lots of uids are used, but
not simultaneously (maybe a few hundred or a thousand at the same time).
It's just that the inode/dentry/cred caches never expire because modern
boxes have lots and lots of memory.

Due to personal circumstances though I haven't been able to work on
anything much for the last few months. I apologize for keeping quiet.

Patch attached. I've removed the debugging stuff, this is only the
"dynamically allocate credcache hashtables" patch.

Patch description:

   auth.h: increase RPC_CREDCACHE_HASHBITS from 4 to 12
           (16 hashtable entries -> 4096). This is just the default.
   auth.c: allocate hashtables dyamically
           add sysctl for credcache_hashsize
   auth_generic.c: use rpcauth_init_credcache
   auth_unix.c: use rpcauth_init_credcache
   sunrpc_syms.c: add hashsize module parameter

Mike.

--=-xA1TwXuWMGBFgzI/anK+
Content-Disposition: attachment; filename="linux-2.6.31-rc8-git2-sunprc-credcache_hashsize.patch"
Content-Type: text/x-patch; name="linux-2.6.31-rc8-git2-sunprc-credcache_hashsize.patch"; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit

diff -ruN linux-2.6.31-rc8-git2.orig/include/linux/sunrpc/auth.h linux-2.6.31-rc8-git2/include/linux/sunrpc/auth.h
--- linux-2.6.31-rc8-git2.orig/include/linux/sunrpc/auth.h	2009-08-28 02:59:04.000000000 +0200
+++ linux-2.6.31-rc8-git2/include/linux/sunrpc/auth.h	2009-09-03 12:29:45.000000000 +0200
@@ -60,10 +60,14 @@
 /*
  * Client authentication handle
  */
-#define RPC_CREDCACHE_HASHBITS	4
+#define RPC_CREDCACHE_HASHBITS	12
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
 
diff -ruN linux-2.6.31-rc8-git2.orig/net/sunrpc/auth.c linux-2.6.31-rc8-git2/net/sunrpc/auth.c
--- linux-2.6.31-rc8-git2.orig/net/sunrpc/auth.c	2009-08-28 02:59:04.000000000 +0200
+++ linux-2.6.31-rc8-git2/net/sunrpc/auth.c	2009-09-03 13:59:01.000000000 +0200
@@ -14,6 +14,8 @@
 #include <linux/hash.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/spinlock.h>
+#include <linux/vmalloc.h>
+#include <linux/sysctl.h>
 
 #ifdef RPC_DEBUG
 # define RPCDBG_FACILITY	RPCDBG_AUTH
@@ -28,6 +30,7 @@
 
 static LIST_HEAD(cred_unused);
 static unsigned long number_cred_unused;
+int credcache_hashsize = RPC_CREDCACHE_NR;
 
 static u32
 pseudoflavor_to_flavor(u32 flavor) {
@@ -147,7 +150,14 @@
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
@@ -184,7 +194,7 @@
 
 	spin_lock(&rpc_credcache_lock);
 	spin_lock(&cache->lock);
-	for (i = 0; i < RPC_CREDCACHE_NR; i++) {
+	for (i = 0; i < cache->hashsize; i++) {
 		head = &cache->hashtable[i];
 		while (!hlist_empty(head)) {
 			cred = hlist_entry(head->first, struct rpc_cred, cr_hash);
@@ -213,6 +223,8 @@
 	if (cache) {
 		auth->au_credcache = NULL;
 		rpcauth_clear_credcache(cache);
+		if (cache->hashtable)
+			vfree(cache->hashtable);
 		kfree(cache);
 	}
 }
@@ -291,7 +303,7 @@
 			*entry, *new;
 	unsigned int nr;
 
-	nr = hash_long(acred->uid, RPC_CREDCACHE_HASHBITS);
+	nr = hash_long(acred->uid, cache->hashbits);
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(entry, pos, &cache->hashtable[nr], cr_hash) {
@@ -568,19 +580,87 @@
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
+static ctl_table sunrpc_credcache_knobs_table [] = {
+	{
+		.procname	= "credcache_hashsize",
+		.data		= NULL,
+		.mode		= 0644,
+		.proc_handler	= &proc_credcache_hashsize,
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
diff -ruN linux-2.6.31-rc8-git2.orig/net/sunrpc/auth_generic.c linux-2.6.31-rc8-git2/net/sunrpc/auth_generic.c
--- linux-2.6.31-rc8-git2.orig/net/sunrpc/auth_generic.c	2009-08-28 02:59:04.000000000 +0200
+++ linux-2.6.31-rc8-git2/net/sunrpc/auth_generic.c	2009-09-03 12:29:45.000000000 +0200
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
diff -ruN linux-2.6.31-rc8-git2.orig/net/sunrpc/auth_unix.c linux-2.6.31-rc8-git2/net/sunrpc/auth_unix.c
--- linux-2.6.31-rc8-git2.orig/net/sunrpc/auth_unix.c	2009-08-28 02:59:04.000000000 +0200
+++ linux-2.6.31-rc8-git2/net/sunrpc/auth_unix.c	2009-09-03 12:29:45.000000000 +0200
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
diff -ruN linux-2.6.31-rc8-git2.orig/net/sunrpc/sunrpc_syms.c linux-2.6.31-rc8-git2/net/sunrpc/sunrpc_syms.c
--- linux-2.6.31-rc8-git2.orig/net/sunrpc/sunrpc_syms.c	2009-08-28 02:59:04.000000000 +0200
+++ linux-2.6.31-rc8-git2/net/sunrpc/sunrpc_syms.c	2009-09-03 12:29:45.000000000 +0200
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
@@ -68,6 +77,8 @@
 #endif
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
+module_param(hashsize, int, 0);
+MODULE_PARM_DESC(hashsize, "size of hashtables for credential caches");
 MODULE_LICENSE("GPL");
 module_init(init_sunrpc);
 module_exit(cleanup_sunrpc);

--=-xA1TwXuWMGBFgzI/anK+--
