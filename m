Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f49.google.com ([209.85.220.49]:54807 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbaLPTCJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 14:02:09 -0500
Received: by mail-pa0-f49.google.com with SMTP id eu11so14599598pac.36
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 11:02:09 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 03/50] nfs41: pull data server cache from file layout to generic pnfs
Date: Tue, 16 Dec 2014 11:01:06 -0800
Message-Id: <1418756513-95187-4-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

Also pull nfs4_pnfs_ds_addr and nfs4_pnfs_ds to generic pnfs.

They can all be reused by flexfile layout as well.

Reviewed-by: Jeff Layton <jlayton@primarydata.com>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/filelayout/filelayout.h    |  19 ---
 fs/nfs/filelayout/filelayoutdev.c | 235 +------------------------------------
 fs/nfs/pnfs.h                     |  21 ++++
 fs/nfs/pnfs_dev.c                 | 240 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 263 insertions(+), 252 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.h b/fs/nfs/filelayout/filelayout.h
index a5ce9b4..f97eea6 100644
--- a/fs/nfs/filelayout/filelayout.h
+++ b/fs/nfs/filelayout/filelayout.h
@@ -56,24 +56,6 @@ enum stripetype4 {
 	STRIPE_DENSE = 2
 };
 
-/* Individual ip address */
-struct nfs4_pnfs_ds_addr {
-	struct sockaddr_storage	da_addr;
-	size_t			da_addrlen;
-	struct list_head	da_node;  /* nfs4_pnfs_dev_hlist dev_dslist */
-	char			*da_remotestr;	/* human readable addr+port */
-};
-
-struct nfs4_pnfs_ds {
-	struct list_head	ds_node;  /* nfs4_pnfs_dev_hlist dev_dslist */
-	char			*ds_remotestr;	/* comma sep list of addrs */
-	struct list_head	ds_addrs;
-	struct nfs_client	*ds_clp;
-	atomic_t		ds_count;
-	unsigned long		ds_state;
-#define NFS4DS_CONNECTING	0	/* ds is establishing connection */
-};
-
 struct nfs4_file_layout_dsaddr {
 	struct nfs4_deviceid_node	id_node;
 	u32				stripe_count;
@@ -131,7 +113,6 @@ filelayout_test_devid_unavailable(struct nfs4_deviceid_node *node);
 extern struct nfs_fh *
 nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, u32 j);
 
-extern void print_ds(struct nfs4_pnfs_ds *ds);
 u32 nfs4_fl_calc_j_index(struct pnfs_layout_segment *lseg, loff_t offset);
 u32 nfs4_fl_calc_ds_index(struct pnfs_layout_segment *lseg, u32 j);
 struct nfs4_pnfs_ds *nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg,
diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
index d21080a..fbfbb70 100644
--- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -43,114 +43,6 @@ static unsigned int dataserver_timeo = NFS4_DEF_DS_TIMEO;
 static unsigned int dataserver_retrans = NFS4_DEF_DS_RETRANS;
 
 /*
- * Data server cache
- *
- * Data servers can be mapped to different device ids.
- * nfs4_pnfs_ds reference counting
- *   - set to 1 on allocation
- *   - incremented when a device id maps a data server already in the cache.
- *   - decremented when deviceid is removed from the cache.
- */
-static DEFINE_SPINLOCK(nfs4_ds_cache_lock);
-static LIST_HEAD(nfs4_data_server_cache);
-
-/* Debug routines */
-void
-print_ds(struct nfs4_pnfs_ds *ds)
-{
-	if (ds == NULL) {
-		printk("%s NULL device\n", __func__);
-		return;
-	}
-	printk("        ds %s\n"
-		"        ref count %d\n"
-		"        client %p\n"
-		"        cl_exchange_flags %x\n",
-		ds->ds_remotestr,
-		atomic_read(&ds->ds_count), ds->ds_clp,
-		ds->ds_clp ? ds->ds_clp->cl_exchange_flags : 0);
-}
-
-static bool
-same_sockaddr(struct sockaddr *addr1, struct sockaddr *addr2)
-{
-	struct sockaddr_in *a, *b;
-	struct sockaddr_in6 *a6, *b6;
-
-	if (addr1->sa_family != addr2->sa_family)
-		return false;
-
-	switch (addr1->sa_family) {
-	case AF_INET:
-		a = (struct sockaddr_in *)addr1;
-		b = (struct sockaddr_in *)addr2;
-
-		if (a->sin_addr.s_addr == b->sin_addr.s_addr &&
-		    a->sin_port == b->sin_port)
-			return true;
-		break;
-
-	case AF_INET6:
-		a6 = (struct sockaddr_in6 *)addr1;
-		b6 = (struct sockaddr_in6 *)addr2;
-
-		/* LINKLOCAL addresses must have matching scope_id */
-		if (ipv6_addr_src_scope(&a6->sin6_addr) ==
-		    IPV6_ADDR_SCOPE_LINKLOCAL &&
-		    a6->sin6_scope_id != b6->sin6_scope_id)
-			return false;
-
-		if (ipv6_addr_equal(&a6->sin6_addr, &b6->sin6_addr) &&
-		    a6->sin6_port == b6->sin6_port)
-			return true;
-		break;
-
-	default:
-		dprintk("%s: unhandled address family: %u\n",
-			__func__, addr1->sa_family);
-		return false;
-	}
-
-	return false;
-}
-
-static bool
-_same_data_server_addrs_locked(const struct list_head *dsaddrs1,
-			       const struct list_head *dsaddrs2)
-{
-	struct nfs4_pnfs_ds_addr *da1, *da2;
-
-	/* step through both lists, comparing as we go */
-	for (da1 = list_first_entry(dsaddrs1, typeof(*da1), da_node),
-	     da2 = list_first_entry(dsaddrs2, typeof(*da2), da_node);
-	     da1 != NULL && da2 != NULL;
-	     da1 = list_entry(da1->da_node.next, typeof(*da1), da_node),
-	     da2 = list_entry(da2->da_node.next, typeof(*da2), da_node)) {
-		if (!same_sockaddr((struct sockaddr *)&da1->da_addr,
-				   (struct sockaddr *)&da2->da_addr))
-			return false;
-	}
-	if (da1 == NULL && da2 == NULL)
-		return true;
-
-	return false;
-}
-
-/*
- * Lookup DS by addresses.  nfs4_ds_cache_lock is held
- */
-static struct nfs4_pnfs_ds *
-_data_server_lookup_locked(const struct list_head *dsaddrs)
-{
-	struct nfs4_pnfs_ds *ds;
-
-	list_for_each_entry(ds, &nfs4_data_server_cache, ds_node)
-		if (_same_data_server_addrs_locked(&ds->ds_addrs, dsaddrs))
-			return ds;
-	return NULL;
-}
-
-/*
  * Create an rpc connection to the nfs4_pnfs_ds data server
  * Currently only supports IPv4 and IPv6 addresses
  */
@@ -195,30 +87,6 @@ out_put:
 	goto out;
 }
 
-static void
-destroy_ds(struct nfs4_pnfs_ds *ds)
-{
-	struct nfs4_pnfs_ds_addr *da;
-
-	dprintk("--> %s\n", __func__);
-	ifdebug(FACILITY)
-		print_ds(ds);
-
-	nfs_put_client(ds->ds_clp);
-
-	while (!list_empty(&ds->ds_addrs)) {
-		da = list_first_entry(&ds->ds_addrs,
-				      struct nfs4_pnfs_ds_addr,
-				      da_node);
-		list_del_init(&da->da_node);
-		kfree(da->da_remotestr);
-		kfree(da);
-	}
-
-	kfree(ds->ds_remotestr);
-	kfree(ds);
-}
-
 void
 nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
 {
@@ -229,113 +97,14 @@ nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
 
 	for (i = 0; i < dsaddr->ds_num; i++) {
 		ds = dsaddr->ds_list[i];
-		if (ds != NULL) {
-			if (atomic_dec_and_lock(&ds->ds_count,
-						&nfs4_ds_cache_lock)) {
-				list_del_init(&ds->ds_node);
-				spin_unlock(&nfs4_ds_cache_lock);
-				destroy_ds(ds);
-			}
-		}
+		if (ds != NULL)
+			nfs4_pnfs_ds_put(ds);
 	}
 	kfree(dsaddr->stripe_indices);
 	kfree(dsaddr);
 }
 
 /*
- * Create a string with a human readable address and port to avoid
- * complicated setup around many dprinks.
- */
-static char *
-nfs4_pnfs_remotestr(struct list_head *dsaddrs, gfp_t gfp_flags)
-{
-	struct nfs4_pnfs_ds_addr *da;
-	char *remotestr;
-	size_t len;
-	char *p;
-
-	len = 3;        /* '{', '}' and eol */
-	list_for_each_entry(da, dsaddrs, da_node) {
-		len += strlen(da->da_remotestr) + 1;    /* string plus comma */
-	}
-
-	remotestr = kzalloc(len, gfp_flags);
-	if (!remotestr)
-		return NULL;
-
-	p = remotestr;
-	*(p++) = '{';
-	len--;
-	list_for_each_entry(da, dsaddrs, da_node) {
-		size_t ll = strlen(da->da_remotestr);
-
-		if (ll > len)
-			goto out_err;
-
-		memcpy(p, da->da_remotestr, ll);
-		p += ll;
-		len -= ll;
-
-		if (len < 1)
-			goto out_err;
-		(*p++) = ',';
-		len--;
-	}
-	if (len < 2)
-		goto out_err;
-	*(p++) = '}';
-	*p = '\0';
-	return remotestr;
-out_err:
-	kfree(remotestr);
-	return NULL;
-}
-
-static struct nfs4_pnfs_ds *
-nfs4_pnfs_ds_add(struct list_head *dsaddrs, gfp_t gfp_flags)
-{
-	struct nfs4_pnfs_ds *tmp_ds, *ds = NULL;
-	char *remotestr;
-
-	if (list_empty(dsaddrs)) {
-		dprintk("%s: no addresses defined\n", __func__);
-		goto out;
-	}
-
-	ds = kzalloc(sizeof(*ds), gfp_flags);
-	if (!ds)
-		goto out;
-
-	/* this is only used for debugging, so it's ok if its NULL */
-	remotestr = nfs4_pnfs_remotestr(dsaddrs, gfp_flags);
-
-	spin_lock(&nfs4_ds_cache_lock);
-	tmp_ds = _data_server_lookup_locked(dsaddrs);
-	if (tmp_ds == NULL) {
-		INIT_LIST_HEAD(&ds->ds_addrs);
-		list_splice_init(dsaddrs, &ds->ds_addrs);
-		ds->ds_remotestr = remotestr;
-		atomic_set(&ds->ds_count, 1);
-		INIT_LIST_HEAD(&ds->ds_node);
-		ds->ds_clp = NULL;
-		list_add(&ds->ds_node, &nfs4_data_server_cache);
-		dprintk("%s add new data server %s\n", __func__,
-			ds->ds_remotestr);
-	} else {
-		kfree(remotestr);
-		kfree(ds);
-		atomic_inc(&tmp_ds->ds_count);
-		dprintk("%s data server %s found, inc'ed ds_count to %d\n",
-			__func__, tmp_ds->ds_remotestr,
-			atomic_read(&tmp_ds->ds_count));
-		ds = tmp_ds;
-	}
-	spin_unlock(&nfs4_ds_cache_lock);
-out:
-	return ds;
-}
-
-/*
  * Currently only supports ipv4, ipv6 and one multi-path address.
  */
 static struct nfs4_pnfs_ds_addr *
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index f666bc6..d0b8e0c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -40,6 +40,24 @@ enum {
 	NFS_LSEG_LAYOUTCOMMIT,	/* layoutcommit bit set for layoutcommit */
 };
 
+/* Individual ip address */
+struct nfs4_pnfs_ds_addr {
+	struct sockaddr_storage	da_addr;
+	size_t			da_addrlen;
+	struct list_head	da_node;  /* nfs4_pnfs_dev_hlist dev_dslist */
+	char			*da_remotestr;	/* human readable addr+port */
+};
+
+struct nfs4_pnfs_ds {
+	struct list_head	ds_node;  /* nfs4_pnfs_dev_hlist dev_dslist */
+	char			*ds_remotestr;	/* comma sep list of addrs */
+	struct list_head	ds_addrs;
+	struct nfs_client	*ds_clp;
+	atomic_t		ds_count;
+	unsigned long		ds_state;
+#define NFS4DS_CONNECTING	0	/* ds is establishing connection */
+};
+
 struct pnfs_layout_segment {
 	struct list_head pls_list;
 	struct list_head pls_lc_list;
@@ -274,6 +292,9 @@ bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
 void nfs4_mark_deviceid_unavailable(struct nfs4_deviceid_node *node);
 bool nfs4_test_deviceid_unavailable(struct nfs4_deviceid_node *node);
 void nfs4_deviceid_purge_client(const struct nfs_client *);
+void nfs4_pnfs_ds_put(struct nfs4_pnfs_ds *ds);
+struct nfs4_pnfs_ds *nfs4_pnfs_ds_add(struct list_head *dsaddrs,
+				      gfp_t gfp_flags);
 
 /* pnfs_nfsio.c */
 void pnfs_generic_clear_request_commit(struct nfs_page *req,
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index aa2ec00..26d7e8d 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -358,3 +358,243 @@ nfs4_deviceid_mark_client_invalid(struct nfs_client *clp)
 	}
 	rcu_read_unlock();
 }
+
+/*
+ * Data server cache
+ *
+ * Data servers can be mapped to different device ids.
+ * nfs4_pnfs_ds reference counting
+ *   - set to 1 on allocation
+ *   - incremented when a device id maps a data server already in the cache.
+ *   - decremented when deviceid is removed from the cache.
+ */
+static DEFINE_SPINLOCK(nfs4_ds_cache_lock);
+static LIST_HEAD(nfs4_data_server_cache);
+
+/* Debug routines */
+static void
+print_ds(struct nfs4_pnfs_ds *ds)
+{
+	if (ds == NULL) {
+		printk(KERN_WARNING "%s NULL device\n", __func__);
+		return;
+	}
+	printk(KERN_WARNING "        ds %s\n"
+		"        ref count %d\n"
+		"        client %p\n"
+		"        cl_exchange_flags %x\n",
+		ds->ds_remotestr,
+		atomic_read(&ds->ds_count), ds->ds_clp,
+		ds->ds_clp ? ds->ds_clp->cl_exchange_flags : 0);
+}
+
+static bool
+same_sockaddr(struct sockaddr *addr1, struct sockaddr *addr2)
+{
+	struct sockaddr_in *a, *b;
+	struct sockaddr_in6 *a6, *b6;
+
+	if (addr1->sa_family != addr2->sa_family)
+		return false;
+
+	switch (addr1->sa_family) {
+	case AF_INET:
+		a = (struct sockaddr_in *)addr1;
+		b = (struct sockaddr_in *)addr2;
+
+		if (a->sin_addr.s_addr == b->sin_addr.s_addr &&
+		    a->sin_port == b->sin_port)
+			return true;
+		break;
+
+	case AF_INET6:
+		a6 = (struct sockaddr_in6 *)addr1;
+		b6 = (struct sockaddr_in6 *)addr2;
+
+		/* LINKLOCAL addresses must have matching scope_id */
+		if (ipv6_addr_src_scope(&a6->sin6_addr) ==
+		    IPV6_ADDR_SCOPE_LINKLOCAL &&
+		    a6->sin6_scope_id != b6->sin6_scope_id)
+			return false;
+
+		if (ipv6_addr_equal(&a6->sin6_addr, &b6->sin6_addr) &&
+		    a6->sin6_port == b6->sin6_port)
+			return true;
+		break;
+
+	default:
+		dprintk("%s: unhandled address family: %u\n",
+			__func__, addr1->sa_family);
+		return false;
+	}
+
+	return false;
+}
+
+static bool
+_same_data_server_addrs_locked(const struct list_head *dsaddrs1,
+			       const struct list_head *dsaddrs2)
+{
+	struct nfs4_pnfs_ds_addr *da1, *da2;
+
+	/* step through both lists, comparing as we go */
+	for (da1 = list_first_entry(dsaddrs1, typeof(*da1), da_node),
+	     da2 = list_first_entry(dsaddrs2, typeof(*da2), da_node);
+	     da1 != NULL && da2 != NULL;
+	     da1 = list_entry(da1->da_node.next, typeof(*da1), da_node),
+	     da2 = list_entry(da2->da_node.next, typeof(*da2), da_node)) {
+		if (!same_sockaddr((struct sockaddr *)&da1->da_addr,
+				   (struct sockaddr *)&da2->da_addr))
+			return false;
+	}
+	if (da1 == NULL && da2 == NULL)
+		return true;
+
+	return false;
+}
+
+/*
+ * Lookup DS by addresses.  nfs4_ds_cache_lock is held
+ */
+static struct nfs4_pnfs_ds *
+_data_server_lookup_locked(const struct list_head *dsaddrs)
+{
+	struct nfs4_pnfs_ds *ds;
+
+	list_for_each_entry(ds, &nfs4_data_server_cache, ds_node)
+		if (_same_data_server_addrs_locked(&ds->ds_addrs, dsaddrs))
+			return ds;
+	return NULL;
+}
+
+static void destroy_ds(struct nfs4_pnfs_ds *ds)
+{
+	struct nfs4_pnfs_ds_addr *da;
+
+	dprintk("--> %s\n", __func__);
+	ifdebug(FACILITY)
+		print_ds(ds);
+
+	nfs_put_client(ds->ds_clp);
+
+	while (!list_empty(&ds->ds_addrs)) {
+		da = list_first_entry(&ds->ds_addrs,
+				      struct nfs4_pnfs_ds_addr,
+				      da_node);
+		list_del_init(&da->da_node);
+		kfree(da->da_remotestr);
+		kfree(da);
+	}
+
+	kfree(ds->ds_remotestr);
+	kfree(ds);
+}
+
+void nfs4_pnfs_ds_put(struct nfs4_pnfs_ds *ds)
+{
+	if (atomic_dec_and_lock(&ds->ds_count,
+				&nfs4_ds_cache_lock)) {
+		list_del_init(&ds->ds_node);
+		spin_unlock(&nfs4_ds_cache_lock);
+		destroy_ds(ds);
+	}
+}
+EXPORT_SYMBOL_GPL(nfs4_pnfs_ds_put);
+
+/*
+ * Create a string with a human readable address and port to avoid
+ * complicated setup around many dprinks.
+ */
+static char *
+nfs4_pnfs_remotestr(struct list_head *dsaddrs, gfp_t gfp_flags)
+{
+	struct nfs4_pnfs_ds_addr *da;
+	char *remotestr;
+	size_t len;
+	char *p;
+
+	len = 3;        /* '{', '}' and eol */
+	list_for_each_entry(da, dsaddrs, da_node) {
+		len += strlen(da->da_remotestr) + 1;    /* string plus comma */
+	}
+
+	remotestr = kzalloc(len, gfp_flags);
+	if (!remotestr)
+		return NULL;
+
+	p = remotestr;
+	*(p++) = '{';
+	len--;
+	list_for_each_entry(da, dsaddrs, da_node) {
+		size_t ll = strlen(da->da_remotestr);
+
+		if (ll > len)
+			goto out_err;
+
+		memcpy(p, da->da_remotestr, ll);
+		p += ll;
+		len -= ll;
+
+		if (len < 1)
+			goto out_err;
+		(*p++) = ',';
+		len--;
+	}
+	if (len < 2)
+		goto out_err;
+	*(p++) = '}';
+	*p = '\0';
+	return remotestr;
+out_err:
+	kfree(remotestr);
+	return NULL;
+}
+
+/*
+ * Given a list of multipath struct nfs4_pnfs_ds_addr, add it to ds cache if
+ * uncached and return cached struct nfs4_pnfs_ds.
+ */
+struct nfs4_pnfs_ds *
+nfs4_pnfs_ds_add(struct list_head *dsaddrs, gfp_t gfp_flags)
+{
+	struct nfs4_pnfs_ds *tmp_ds, *ds = NULL;
+	char *remotestr;
+
+	if (list_empty(dsaddrs)) {
+		dprintk("%s: no addresses defined\n", __func__);
+		goto out;
+	}
+
+	ds = kzalloc(sizeof(*ds), gfp_flags);
+	if (!ds)
+		goto out;
+
+	/* this is only used for debugging, so it's ok if its NULL */
+	remotestr = nfs4_pnfs_remotestr(dsaddrs, gfp_flags);
+
+	spin_lock(&nfs4_ds_cache_lock);
+	tmp_ds = _data_server_lookup_locked(dsaddrs);
+	if (tmp_ds == NULL) {
+		INIT_LIST_HEAD(&ds->ds_addrs);
+		list_splice_init(dsaddrs, &ds->ds_addrs);
+		ds->ds_remotestr = remotestr;
+		atomic_set(&ds->ds_count, 1);
+		INIT_LIST_HEAD(&ds->ds_node);
+		ds->ds_clp = NULL;
+		list_add(&ds->ds_node, &nfs4_data_server_cache);
+		dprintk("%s add new data server %s\n", __func__,
+			ds->ds_remotestr);
+	} else {
+		kfree(remotestr);
+		kfree(ds);
+		atomic_inc(&tmp_ds->ds_count);
+		dprintk("%s data server %s found, inc'ed ds_count to %d\n",
+			__func__, tmp_ds->ds_remotestr,
+			atomic_read(&tmp_ds->ds_count));
+		ds = tmp_ds;
+	}
+	spin_unlock(&nfs4_ds_cache_lock);
+out:
+	return ds;
+}
+EXPORT_SYMBOL_GPL(nfs4_pnfs_ds_add);
-- 
1.9.3

