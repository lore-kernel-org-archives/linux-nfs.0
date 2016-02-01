Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:35422 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487AbcBARWE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Feb 2016 12:22:04 -0500
Received: by mail-ig0-f173.google.com with SMTP id t15so40366192igr.0
        for <linux-nfs@vger.kernel.org>; Mon, 01 Feb 2016 09:22:04 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH v3 05/13] SUNRPC: Add a structure to track multiple transports
Date: Mon,  1 Feb 2016 12:21:09 -0500
Message-Id: <1454347277-10997-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1454347277-10997-5-git-send-email-trond.myklebust@primarydata.com>
References: <1454347277-10997-1-git-send-email-trond.myklebust@primarydata.com>
 <1454347277-10997-2-git-send-email-trond.myklebust@primarydata.com>
 <1454347277-10997-3-git-send-email-trond.myklebust@primarydata.com>
 <1454347277-10997-4-git-send-email-trond.myklebust@primarydata.com>
 <1454347277-10997-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to support multipathing/trunking we will need the ability to
track multiple transports. This patch sets up a basic structure for
doing so.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/xprt.h          |   5 +
 include/linux/sunrpc/xprtmultipath.h |  69 +++++
 net/sunrpc/Makefile                  |   3 +-
 net/sunrpc/xprt.c                    |   1 +
 net/sunrpc/xprtmultipath.c           | 473 +++++++++++++++++++++++++++++++++++
 5 files changed, 550 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/sunrpc/xprtmultipath.h
 create mode 100644 net/sunrpc/xprtmultipath.c

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 83218129ff28..fb0d212e0d3a 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -198,6 +198,11 @@ struct rpc_xprt {
 	unsigned int		bind_index;	/* bind function index */
 
 	/*
+	 * Multipath
+	 */
+	struct list_head	xprt_switch;
+
+	/*
 	 * Connection of transports
 	 */
 	unsigned long		bind_timeout,
diff --git a/include/linux/sunrpc/xprtmultipath.h b/include/linux/sunrpc/xprtmultipath.h
new file mode 100644
index 000000000000..5a9acffa41be
--- /dev/null
+++ b/include/linux/sunrpc/xprtmultipath.h
@@ -0,0 +1,69 @@
+/*
+ * RPC client multipathing definitions
+ *
+ * Copyright (c) 2015, 2016, Primary Data, Inc. All rights reserved.
+ *
+ * Trond Myklebust <trond.myklebust@primarydata.com>
+ */
+#ifndef _NET_SUNRPC_XPRTMULTIPATH_H
+#define _NET_SUNRPC_XPRTMULTIPATH_H
+
+struct rpc_xprt_iter_ops;
+struct rpc_xprt_switch {
+	spinlock_t		xps_lock;
+	struct kref		xps_kref;
+
+	unsigned int		xps_nxprts;
+	struct list_head	xps_xprt_list;
+
+	struct net *		xps_net;
+
+	const struct rpc_xprt_iter_ops *xps_iter_ops;
+
+	struct rcu_head		xps_rcu;
+};
+
+struct rpc_xprt_iter {
+	struct rpc_xprt_switch __rcu *xpi_xpswitch;
+	struct rpc_xprt *	xpi_cursor;
+
+	const struct rpc_xprt_iter_ops *xpi_ops;
+};
+
+
+struct rpc_xprt_iter_ops {
+	void (*xpi_rewind)(struct rpc_xprt_iter *);
+	struct rpc_xprt *(*xpi_xprt)(struct rpc_xprt_iter *);
+	struct rpc_xprt *(*xpi_next)(struct rpc_xprt_iter *);
+};
+
+extern struct rpc_xprt_switch *xprt_switch_alloc(struct rpc_xprt *xprt,
+		gfp_t gfp_flags);
+
+extern struct rpc_xprt_switch *xprt_switch_get(struct rpc_xprt_switch *xps);
+extern void xprt_switch_put(struct rpc_xprt_switch *xps);
+
+extern void rpc_xprt_switch_set_roundrobin(struct rpc_xprt_switch *xps);
+
+extern void rpc_xprt_switch_add_xprt(struct rpc_xprt_switch *xps,
+		struct rpc_xprt *xprt);
+extern void rpc_xprt_switch_remove_xprt(struct rpc_xprt_switch *xps,
+		struct rpc_xprt *xprt);
+
+extern void xprt_iter_init(struct rpc_xprt_iter *xpi,
+		struct rpc_xprt_switch *xps);
+
+extern void xprt_iter_init_listall(struct rpc_xprt_iter *xpi,
+		struct rpc_xprt_switch *xps);
+
+extern void xprt_iter_destroy(struct rpc_xprt_iter *xpi);
+
+extern struct rpc_xprt_switch *xprt_iter_xchg_switch(
+		struct rpc_xprt_iter *xpi,
+		struct rpc_xprt_switch *newswitch);
+
+extern struct rpc_xprt *xprt_iter_xprt(struct rpc_xprt_iter *xpi);
+extern struct rpc_xprt *xprt_iter_get_xprt(struct rpc_xprt_iter *xpi);
+extern struct rpc_xprt *xprt_iter_get_next(struct rpc_xprt_iter *xpi);
+
+#endif
diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
index b512fbd9d79a..ea7ffa12e0f9 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -12,7 +12,8 @@ sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
 	    svc.o svcsock.o svcauth.o svcauth_unix.o \
 	    addr.o rpcb_clnt.o timer.o xdr.o \
 	    sunrpc_syms.o cache.o rpc_pipe.o \
-	    svc_xprt.o
+	    svc_xprt.o \
+	    xprtmultipath.o
 sunrpc-$(CONFIG_SUNRPC_DEBUG) += debugfs.o
 sunrpc-$(CONFIG_SUNRPC_BACKCHANNEL) += backchannel_rqst.o
 sunrpc-$(CONFIG_PROC_FS) += stats.o
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 605858699f6c..323b332f8f7c 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1319,6 +1319,7 @@ static void xprt_init(struct rpc_xprt *xprt, struct net *net)
 	spin_lock_init(&xprt->bc_pa_lock);
 	INIT_LIST_HEAD(&xprt->bc_pa_list);
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
+	INIT_LIST_HEAD(&xprt->xprt_switch);
 
 	xprt->last_used = jiffies;
 	xprt->cwnd = RPC_INITCWND;
diff --git a/net/sunrpc/xprtmultipath.c b/net/sunrpc/xprtmultipath.c
new file mode 100644
index 000000000000..c2fbf723e660
--- /dev/null
+++ b/net/sunrpc/xprtmultipath.c
@@ -0,0 +1,473 @@
+/*
+ * Multipath support for RPC
+ *
+ * Copyright (c) 2015, 2016, Primary Data, Inc. All rights reserved.
+ *
+ * Trond Myklebust <trond.myklebust@primarydata.com>
+ *
+ */
+#include <linux/types.h>
+#include <linux/kref.h>
+#include <linux/list.h>
+#include <linux/rcupdate.h>
+#include <linux/rculist.h>
+#include <linux/slab.h>
+#include <asm/cmpxchg.h>
+#include <linux/spinlock.h>
+#include <linux/sunrpc/xprt.h>
+#include <linux/sunrpc/xprtmultipath.h>
+
+typedef struct rpc_xprt *(*xprt_switch_find_xprt_t)(struct list_head *head,
+		const struct rpc_xprt *cur);
+
+static const struct rpc_xprt_iter_ops rpc_xprt_iter_singular;
+static const struct rpc_xprt_iter_ops rpc_xprt_iter_roundrobin;
+static const struct rpc_xprt_iter_ops rpc_xprt_iter_listall;
+
+static void xprt_switch_add_xprt_locked(struct rpc_xprt_switch *xps,
+		struct rpc_xprt *xprt)
+{
+	if (unlikely(xprt_get(xprt) == NULL))
+		return;
+	list_add_tail_rcu(&xprt->xprt_switch, &xps->xps_xprt_list);
+	smp_wmb();
+	if (xps->xps_nxprts == 0)
+		xps->xps_net = xprt->xprt_net;
+	xps->xps_nxprts++;
+}
+
+/**
+ * rpc_xprt_switch_add_xprt - Add a new rpc_xprt to an rpc_xprt_switch
+ * @xps: pointer to struct rpc_xprt_switch
+ * @xprt: pointer to struct rpc_xprt
+ *
+ * Adds xprt to the end of the list of struct rpc_xprt in xps.
+ */
+void rpc_xprt_switch_add_xprt(struct rpc_xprt_switch *xps,
+		struct rpc_xprt *xprt)
+{
+	if (xprt == NULL)
+		return;
+	spin_lock(&xps->xps_lock);
+	if (xps->xps_net != xprt->xprt_net || xps->xps_net == NULL)
+		xprt_switch_add_xprt_locked(xps, xprt);
+	spin_unlock(&xps->xps_lock);
+}
+
+static void xprt_switch_remove_xprt_locked(struct rpc_xprt_switch *xps,
+		struct rpc_xprt *xprt)
+{
+	if (unlikely(xprt == NULL))
+		return;
+	xps->xps_nxprts--;
+	if (xps->xps_nxprts == 0)
+		xps->xps_net = NULL;
+	smp_wmb();
+	list_del_rcu(&xprt->xprt_switch);
+}
+
+/**
+ * rpc_xprt_switch_remove_xprt - Removes an rpc_xprt from a rpc_xprt_switch
+ * @xps: pointer to struct rpc_xprt_switch
+ * @xprt: pointer to struct rpc_xprt
+ *
+ * Removes xprt from the list of struct rpc_xprt in xps.
+ */
+void rpc_xprt_switch_remove_xprt(struct rpc_xprt_switch *xps,
+		struct rpc_xprt *xprt)
+{
+	spin_lock(&xps->xps_lock);
+	xprt_switch_remove_xprt_locked(xps, xprt);
+	spin_unlock(&xps->xps_lock);
+	xprt_put(xprt);
+}
+
+/**
+ * xprt_switch_alloc - Allocate a new struct rpc_xprt_switch
+ * @xprt: pointer to struct rpc_xprt
+ * @gfp_flags: allocation flags
+ *
+ * On success, returns an initialised struct rpc_xprt_switch, containing
+ * the entry xprt. Returns NULL on failure.
+ */
+struct rpc_xprt_switch *xprt_switch_alloc(struct rpc_xprt *xprt,
+		gfp_t gfp_flags)
+{
+	struct rpc_xprt_switch *xps;
+
+	xps = kmalloc(sizeof(*xps), gfp_flags);
+	if (xps != NULL) {
+		spin_lock_init(&xps->xps_lock);
+		kref_init(&xps->xps_kref);
+		xps->xps_nxprts = 0;
+		INIT_LIST_HEAD(&xps->xps_xprt_list);
+		xps->xps_iter_ops = &rpc_xprt_iter_singular;
+		xprt_switch_add_xprt_locked(xps, xprt);
+	}
+
+	return xps;
+}
+
+static void xprt_switch_free_entries(struct rpc_xprt_switch *xps)
+{
+	spin_lock(&xps->xps_lock);
+	while (!list_empty(&xps->xps_xprt_list)) {
+		struct rpc_xprt *xprt;
+
+		xprt = list_first_entry(&xps->xps_xprt_list,
+				struct rpc_xprt, xprt_switch);
+		xprt_switch_remove_xprt_locked(xps, xprt);
+		spin_unlock(&xps->xps_lock);
+		xprt_put(xprt);
+		spin_lock(&xps->xps_lock);
+	}
+	spin_unlock(&xps->xps_lock);
+}
+
+static void xprt_switch_free(struct kref *kref)
+{
+	struct rpc_xprt_switch *xps = container_of(kref,
+			struct rpc_xprt_switch, xps_kref);
+
+	xprt_switch_free_entries(xps);
+	kfree_rcu(xps, xps_rcu);
+}
+
+/**
+ * xprt_switch_get - Return a reference to a rpc_xprt_switch
+ * @xps: pointer to struct rpc_xprt_switch
+ *
+ * Returns a reference to xps unless the refcount is already zero.
+ */
+struct rpc_xprt_switch *xprt_switch_get(struct rpc_xprt_switch *xps)
+{
+	if (xps != NULL && kref_get_unless_zero(&xps->xps_kref))
+		return xps;
+	return NULL;
+}
+
+/**
+ * xprt_switch_put - Release a reference to a rpc_xprt_switch
+ * @xps: pointer to struct rpc_xprt_switch
+ *
+ * Release the reference to xps, and free it once the refcount is zero.
+ */
+void xprt_switch_put(struct rpc_xprt_switch *xps)
+{
+	if (xps != NULL)
+		kref_put(&xps->xps_kref, xprt_switch_free);
+}
+
+/**
+ * rpc_xprt_switch_set_roundrobin - Set a round-robin policy on rpc_xprt_switch
+ * @xps: pointer to struct rpc_xprt_switch
+ *
+ * Sets a round-robin default policy for iterators acting on xps.
+ */
+void rpc_xprt_switch_set_roundrobin(struct rpc_xprt_switch *xps)
+{
+	if (READ_ONCE(xps->xps_iter_ops) != &rpc_xprt_iter_roundrobin)
+		WRITE_ONCE(xps->xps_iter_ops, &rpc_xprt_iter_roundrobin);
+}
+
+static
+const struct rpc_xprt_iter_ops *xprt_iter_ops(const struct rpc_xprt_iter *xpi)
+{
+	if (xpi->xpi_ops != NULL)
+		return xpi->xpi_ops;
+	return rcu_dereference(xpi->xpi_xpswitch)->xps_iter_ops;
+}
+
+static
+void xprt_iter_no_rewind(struct rpc_xprt_iter *xpi)
+{
+}
+
+static
+void xprt_iter_default_rewind(struct rpc_xprt_iter *xpi)
+{
+	WRITE_ONCE(&xpi->xpi_cursor, NULL);
+}
+
+static
+struct rpc_xprt *xprt_switch_find_first_entry(struct list_head *head)
+{
+	return list_first_or_null_rcu(head, struct rpc_xprt, xprt_switch);
+}
+
+static
+struct rpc_xprt *xprt_iter_first_entry(struct rpc_xprt_iter *xpi)
+{
+	struct rpc_xprt_switch *xps = rcu_dereference(xpi->xpi_xpswitch);
+
+	if (xps == NULL)
+		return NULL;
+	return xprt_switch_find_first_entry(&xps->xps_xprt_list);
+}
+
+static
+struct rpc_xprt *xprt_switch_find_current_entry(struct list_head *head,
+		const struct rpc_xprt *cur)
+{
+	struct rpc_xprt *pos;
+
+	list_for_each_entry_rcu(pos, head, xprt_switch) {
+		if (cur == pos)
+			return pos;
+	}
+	return NULL;
+}
+
+static
+struct rpc_xprt *xprt_iter_current_entry(struct rpc_xprt_iter *xpi)
+{
+	struct rpc_xprt_switch *xps = rcu_dereference(xpi->xpi_xpswitch);
+	struct list_head *head;
+
+	if (xps == NULL)
+		return NULL;
+	head = &xps->xps_xprt_list;
+	if (xpi->xpi_cursor == NULL || xps->xps_nxprts < 2)
+		return xprt_switch_find_first_entry(head);
+	return xprt_switch_find_current_entry(head, xpi->xpi_cursor);
+}
+
+static
+struct rpc_xprt *xprt_switch_find_next_entry(struct list_head *head,
+		const struct rpc_xprt *cur)
+{
+	struct rpc_xprt *pos, *prev = NULL;
+
+	list_for_each_entry_rcu(pos, head, xprt_switch) {
+		if (cur == prev)
+			return pos;
+		prev = pos;
+	}
+	return NULL;
+}
+
+static
+struct rpc_xprt *xprt_switch_set_next_cursor(struct list_head *head,
+		struct rpc_xprt **cursor,
+		xprt_switch_find_xprt_t find_next)
+{
+	struct rpc_xprt *cur, *pos, *old;
+
+	cur = READ_ONCE(*cursor);
+	for (;;) {
+		old = cur;
+		pos = find_next(head, old);
+		cur = cmpxchg_relaxed(cursor, old, pos);
+		if (cur == old)
+			break;
+	}
+	return pos;
+}
+
+static
+struct rpc_xprt *xprt_iter_next_entry_multiple(struct rpc_xprt_iter *xpi,
+		xprt_switch_find_xprt_t find_next)
+{
+	struct rpc_xprt_switch *xps = rcu_dereference(xpi->xpi_xpswitch);
+	struct list_head *head;
+
+	if (xps == NULL)
+		return NULL;
+	head = &xps->xps_xprt_list;
+	if (xps->xps_nxprts < 2)
+		return xprt_switch_find_first_entry(head);
+	return xprt_switch_set_next_cursor(head, &xpi->xpi_cursor, find_next);
+}
+
+static
+struct rpc_xprt *xprt_switch_find_next_entry_roundrobin(struct list_head *head,
+		const struct rpc_xprt *cur)
+{
+	struct rpc_xprt *ret;
+
+	ret = xprt_switch_find_next_entry(head, cur);
+	if (ret != NULL)
+		return ret;
+	return xprt_switch_find_first_entry(head);
+}
+
+static
+struct rpc_xprt *xprt_iter_next_entry_roundrobin(struct rpc_xprt_iter *xpi)
+{
+	return xprt_iter_next_entry_multiple(xpi,
+			xprt_switch_find_next_entry_roundrobin);
+}
+
+static
+struct rpc_xprt *xprt_iter_next_entry_all(struct rpc_xprt_iter *xpi)
+{
+	return xprt_iter_next_entry_multiple(xpi, xprt_switch_find_next_entry);
+}
+
+/*
+ * xprt_iter_rewind - Resets the xprt iterator
+ * @xpi: pointer to rpc_xprt_iter
+ *
+ * Resets xpi to ensure that it points to the first entry in the list
+ * of transports.
+ */
+static
+void xprt_iter_rewind(struct rpc_xprt_iter *xpi)
+{
+	rcu_read_lock();
+	xprt_iter_ops(xpi)->xpi_rewind(xpi);
+	rcu_read_unlock();
+}
+
+static void __xprt_iter_init(struct rpc_xprt_iter *xpi,
+		struct rpc_xprt_switch *xps,
+		const struct rpc_xprt_iter_ops *ops)
+{
+	rcu_assign_pointer(xpi->xpi_xpswitch, xprt_switch_get(xps));
+	xpi->xpi_cursor = NULL;
+	xpi->xpi_ops = ops;
+}
+
+/**
+ * xprt_iter_init - Initialise an xprt iterator
+ * @xpi: pointer to rpc_xprt_iter
+ * @xps: pointer to rpc_xprt_switch
+ *
+ * Initialises the iterator to use the default iterator ops
+ * as set in xps. This function is mainly intended for internal
+ * use in the rpc_client.
+ */
+void xprt_iter_init(struct rpc_xprt_iter *xpi,
+		struct rpc_xprt_switch *xps)
+{
+	__xprt_iter_init(xpi, xps, NULL);
+}
+
+/**
+ * xprt_iter_init_listall - Initialise an xprt iterator
+ * @xpi: pointer to rpc_xprt_iter
+ * @xps: pointer to rpc_xprt_switch
+ *
+ * Initialises the iterator to iterate once through the entire list
+ * of entries in xps.
+ */
+void xprt_iter_init_listall(struct rpc_xprt_iter *xpi,
+		struct rpc_xprt_switch *xps)
+{
+	__xprt_iter_init(xpi, xps, &rpc_xprt_iter_listall);
+}
+
+/**
+ * xprt_iter_xchg_switch - Atomically swap out the rpc_xprt_switch
+ * @xpi: pointer to rpc_xprt_iter
+ * @xps: pointer to a new rpc_xprt_switch or NULL
+ *
+ * Swaps out the existing xpi->xpi_xpswitch with a new value.
+ */
+struct rpc_xprt_switch *xprt_iter_xchg_switch(struct rpc_xprt_iter *xpi,
+		struct rpc_xprt_switch *newswitch)
+{
+	struct rpc_xprt_switch __rcu *oldswitch;
+
+	/* Atomically swap out the old xpswitch */
+	oldswitch = xchg(&xpi->xpi_xpswitch, RCU_INITIALIZER(newswitch));
+	if (newswitch != NULL)
+		xprt_iter_rewind(xpi);
+	return rcu_dereference_protected(oldswitch, true);
+}
+
+/**
+ * xprt_iter_destroy - Destroys the xprt iterator
+ * @xpi pointer to rpc_xprt_iter
+ */
+void xprt_iter_destroy(struct rpc_xprt_iter *xpi)
+{
+	xprt_switch_put(xprt_iter_xchg_switch(xpi, NULL));
+}
+
+/**
+ * xprt_iter_xprt - Returns the rpc_xprt pointed to by the cursor
+ * @xpi: pointer to rpc_xprt_iter
+ *
+ * Returns a pointer to the struct rpc_xprt that is currently
+ * pointed to by the cursor.
+ * Caller must be holding rcu_read_lock().
+ */
+struct rpc_xprt *xprt_iter_xprt(struct rpc_xprt_iter *xpi)
+{
+	WARN_ON_ONCE(!rcu_read_lock_held());
+	return xprt_iter_ops(xpi)->xpi_xprt(xpi);
+}
+
+static
+struct rpc_xprt *xprt_iter_get_helper(struct rpc_xprt_iter *xpi,
+		struct rpc_xprt *(*fn)(struct rpc_xprt_iter *))
+{
+	struct rpc_xprt *ret;
+
+	do {
+		ret = fn(xpi);
+		if (ret == NULL)
+			break;
+		ret = xprt_get(ret);
+	} while (ret == NULL);
+	return ret;
+}
+
+/**
+ * xprt_iter_get_xprt - Returns the rpc_xprt pointed to by the cursor
+ * @xpi: pointer to rpc_xprt_iter
+ *
+ * Returns a reference to the struct rpc_xprt that is currently
+ * pointed to by the cursor.
+ */
+struct rpc_xprt *xprt_iter_get_xprt(struct rpc_xprt_iter *xpi)
+{
+	struct rpc_xprt *xprt;
+
+	rcu_read_lock();
+	xprt = xprt_iter_get_helper(xpi, xprt_iter_ops(xpi)->xpi_xprt);
+	rcu_read_unlock();
+	return xprt;
+}
+
+/**
+ * xprt_iter_get_next - Returns the next rpc_xprt following the cursor
+ * @xpi: pointer to rpc_xprt_iter
+ *
+ * Returns a reference to the struct rpc_xprt that immediately follows the
+ * entry pointed to by the cursor.
+ */
+struct rpc_xprt *xprt_iter_get_next(struct rpc_xprt_iter *xpi)
+{
+	struct rpc_xprt *xprt;
+
+	rcu_read_lock();
+	xprt = xprt_iter_get_helper(xpi, xprt_iter_ops(xpi)->xpi_next);
+	rcu_read_unlock();
+	return xprt;
+}
+
+/* Policy for always returning the first entry in the rpc_xprt_switch */
+static
+const struct rpc_xprt_iter_ops rpc_xprt_iter_singular = {
+	.xpi_rewind = xprt_iter_no_rewind,
+	.xpi_xprt = xprt_iter_first_entry,
+	.xpi_next = xprt_iter_first_entry,
+};
+
+/* Policy for round-robin iteration of entries in the rpc_xprt_switch */
+static
+const struct rpc_xprt_iter_ops rpc_xprt_iter_roundrobin = {
+	.xpi_rewind = xprt_iter_default_rewind,
+	.xpi_xprt = xprt_iter_current_entry,
+	.xpi_next = xprt_iter_next_entry_roundrobin,
+};
+
+/* Policy for once-through iteration of entries in the rpc_xprt_switch */
+static
+const struct rpc_xprt_iter_ops rpc_xprt_iter_listall = {
+	.xpi_rewind = xprt_iter_default_rewind,
+	.xpi_xprt = xprt_iter_current_entry,
+	.xpi_next = xprt_iter_next_entry_all,
+};
-- 
2.5.0

