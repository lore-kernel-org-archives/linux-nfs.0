From: Greg Banks <gnb@sgi.com>
Subject: [patch 3/5] Make the dprintk() macro record information about the callsite
Date: Mon, 19 Jan 2009 17:40:21 +1100
Message-ID: <20090119064912.165619000@sgi.com>
References: <20090119064018.442220000@sgi.com>
Cc: "Frank Ch. Eigler" <fche@redhat.com>
To: Linux NFS ML <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:58550 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753160AbZASGtY (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Mon, 19 Jan 2009 01:49:24 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the definition of dprintk() to generate an array of records in
a special new .dprintk section, which describe the module, filename,
line number, function, and printk format of each dprintk.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 include/linux/dprintk.h        |   91 ++++++++++++++++++++++++++++++
 include/linux/lockd/debug.h    |    6 -
 include/linux/nfs_fs.h         |   18 -----
 include/linux/nfsd/debug.h     |   12 +--
 include/linux/sunrpc/debug.h   |   29 +++++++--
 net/sunrpc/cache.c             |    2 
 net/sunrpc/xprtrdma/rpc_rdma.c |    2 
 7 files changed, 124 insertions(+), 36 deletions(-)

Index: bfields/include/linux/dprintk.h
===================================================================
--- /dev/null
+++ bfields/include/linux/dprintk.h
@@ -0,0 +1,91 @@
+/*
+ * dprintk.h - a generic /proc interface for enabling individual debugging printks.
+ *
+ * By Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
+ * Copyright (c) 2008 Silicon Graphics Inc.  All Rights Reserved.
+ * $Id: dprintk.h,v 1.1 2008/09/04 04:46:06 gnb Exp $
+ */
+#ifndef _LINUX_DPRINTK_H_
+#define _LINUX_DPRINTK_H_ 1
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+
+/*
+ * An instance of this structure is created in a special
+ * ELF section at every dprintk() callsite.  At runtime,
+ * the special section is treated as an array of these.
+ */
+struct _dprintk
+{
+	/*
+	 * These fields are used to drive the /proc user interface
+	 * for selecting and displaying dprintk() callsites.
+	 */
+	const char *function;
+	const char *filename;
+	const char *format;
+	unsigned int lineno;
+	/*
+	 * This magic number helps finding the bound of the special
+	 * ELF section (for various stupid reasons we don't have an
+	 * accurate idea of the end of the loaded section).
+	 */
+#define _DPRINTK_MAGIC		0xc0ffee
+	unsigned int magic:24;
+	/*
+	 * The flags field controls the behaviour at the callsite.
+	 * The bits here are changed dynamically when the user
+	 * writes commands to /proc/dprintk.
+	 */
+#define _DPRINTK_FLAGS_PRINT	(1<<0)	/* printk() a message using the format */
+#define _DPRINTK_FLAGS_STACK	(1<<1)	/* print a kernel stack using dump_stack() */
+#define _DPRINTK_FLAGS_CRASH	(1<<2)	/* cause a kernel crash for debugging */
+#define _DPRINTK_FLAGS_DEFAULT	0
+	unsigned int flags:8;
+};
+
+
+/*
+ * Basic callsite functionality.  The `cond' argument allows
+ * the caller to add an extra logical condition to the check
+ * for printk().  The NFS code uses that to implement a
+ * dfprintk() macro which is dprintk() with an additional
+ * check of the NFS global debug bitmasks.
+ */
+#define __dprintk(cond, fmt, ...)				\
+do {								\
+	static struct _dprintk					\
+		__attribute__((section(".dprintk"))) _dp = {	\
+		.function = __FUNCTION__,			\
+		.filename = __FILE__,				\
+		.format = fmt,					\
+		.lineno = __LINE__,				\
+		.magic = _DPRINTK_MAGIC,			\
+		.flags = _DPRINTK_FLAGS_DEFAULT			\
+	};							\
+	if (unlikely(_dp.flags || (cond)))			\
+		printk(_dp.format, ## __VA_ARGS__);		\
+	if (unlikely(_dp.flags & _DPRINTK_FLAGS_STACK))		\
+		dump_stack();					\
+	BUG_ON(_dp.flags & _DPRINTK_FLAGS_CRASH);		\
+} while(0)
+
+/*
+ * Default definition of dprintk_check.  This macro exists
+ * only to allow calling code to redefine it to add extra
+ * logic which enables dprintk() callsites in ways other
+ * than the individual callsite flags.  For example, NFS
+ * uses this to implement backwards-compatible global debug
+ * bitmasks.
+ */
+#ifndef dprintk_check
+#define dprintk_check   0
+#endif
+
+/*
+ * This is the macro that most calling code should be using.
+ */
+#define dprintk(fmt, ...)   __dprintk(dprintk_check, fmt, ## __VA_ARGS__)
+
+#endif /* _LINUX_DPRINTK_H_ */
Index: bfields/include/linux/lockd/debug.h
===================================================================
--- bfields.orig/include/linux/lockd/debug.h
+++ bfields/include/linux/lockd/debug.h
@@ -21,11 +21,9 @@
 # define LOCKD_DEBUG		1
 #endif
 
-#undef ifdebug
 #if defined(RPC_DEBUG) && defined(LOCKD_DEBUG)
-# define ifdebug(flag)		if (unlikely(nlm_debug & NLMDBG_##flag))
-#else
-# define ifdebug(flag)		if (0)
+# undef debugcheck
+# define debugcheck(fac)	(nlm_debug & NLMDBG_##fac)
 #endif
 
 #endif /* __KERNEL__ */
Index: bfields/include/linux/nfsd/debug.h
===================================================================
--- bfields.orig/include/linux/nfsd/debug.h
+++ bfields/include/linux/nfsd/debug.h
@@ -36,13 +36,9 @@
 #define NFSDDBG_NOCHANGE	0xFFFF
 
 
-#ifdef __KERNEL__
-# undef ifdebug
-# ifdef NFSD_DEBUG
-#  define ifdebug(flag)		if (nfsd_debug & NFSDDBG_##flag)
-# else
-#  define ifdebug(flag)		if (0)
-# endif
-#endif /* __KERNEL__ */
+#if defined(__KERNEL__) && defined(NFSD_DEBUG)
+# undef debugcheck
+# define debugcheck(fac)	(nfsd_debug & NFSDDBG_##fac)
+#endif
 
 #endif /* LINUX_NFSD_DEBUG_H */
Index: bfields/include/linux/nfs_fs.h
===================================================================
--- bfields.orig/include/linux/nfs_fs.h
+++ bfields/include/linux/nfs_fs.h
@@ -598,22 +598,10 @@ extern void * nfs_root_data(void);
 #define NFSDBG_FSCACHE		0x0800
 #define NFSDBG_ALL		0xFFFF
 
-#ifdef __KERNEL__
-
-/*
- * Enable debugging support for nfs client.
- * Requires RPC_DEBUG.
- */
-#ifdef RPC_DEBUG
+#if defined(__KERNEL__) && defined(RPC_DEBUG)
 # define NFS_DEBUG
+# undef debugcheck
+# define debugcheck(fac)	(nfs_debug & NFSDBG_##fac)
 #endif
 
-# undef ifdebug
-# ifdef NFS_DEBUG
-#  define ifdebug(fac)		if (unlikely(nfs_debug & NFSDBG_##fac))
-# else
-#  define ifdebug(fac)		if (0)
-# endif
-#endif /* __KERNEL */
-
 #endif
Index: bfields/include/linux/sunrpc/debug.h
===================================================================
--- bfields.orig/include/linux/sunrpc/debug.h
+++ bfields/include/linux/sunrpc/debug.h
@@ -30,6 +30,7 @@
 
 #include <linux/timer.h>
 #include <linux/workqueue.h>
+#include <linux/dprintk.h>
 
 /*
  * Enable RPC debugging/profiling.
@@ -41,6 +42,20 @@
 
 /*
  * Debugging macros etc
+ *
+ * The RPC (and NFS etc) code can do the following:
+ *
+ * a) at the start of a .c file set up the default
+ *    debug bit to be used for all dprintk()s, e.g.
+ *   #define RPCDBG_FACILITY  RPCDBG_MISC
+ *
+ * b) call dprintk(), to do a debug print conditional
+ *    on the default debug bit, e.g.
+ *   dprintk("nfsd: write complete err=%d\n", err);
+ *
+ * c) call dfprintk(), to do a debug print conditional
+ *    on a specified non-default debug bit, e.g.
+ *   dfprintk(VFS, "NFS: find_dirent_index() returns %d\n", status);
  */
 #ifdef RPC_DEBUG
 extern unsigned int		rpc_debug;
@@ -49,15 +64,15 @@ extern unsigned int		nfsd_debug;
 extern unsigned int		nlm_debug;
 #endif
 
-#define dprintk(args...)	dfprintk(FACILITY, ## args)
-
-#undef ifdebug
-#ifdef RPC_DEBUG			
-# define ifdebug(fac)		if (unlikely(rpc_debug & RPCDBG_##fac))
-# define dfprintk(fac, args...)	do { ifdebug(fac) printk(args); } while(0)
+#ifdef RPC_DEBUG
+# define debugcheck(fac)	(rpc_debug & RPCDBG_##fac)
+# undef dprintk_check
+# define dprintk_check		debugcheck(FACILITY)
+# define dfprintk(fac, args...)	__dprintk(debugcheck(fac), args)
 # define RPC_IFDEBUG(x)		x
 #else
-# define ifdebug(fac)		if (0)
+# undef dprintk
+# define dprintk(args...)	do ; while (0)
 # define dfprintk(fac, args...)	do ; while (0)
 # define RPC_IFDEBUG(x)
 #endif
Index: bfields/net/sunrpc/cache.c
===================================================================
--- bfields.orig/net/sunrpc/cache.c
+++ bfields/net/sunrpc/cache.c
@@ -1236,7 +1236,7 @@ static int c_show(struct seq_file *m, vo
 	if (p == SEQ_START_TOKEN)
 		return cd->cache_show(m, cd, NULL);
 
-	ifdebug(CACHE)
+	if (unlikely(debugcheck(CACHE)))
 		seq_printf(m, "# expiry=%ld refcnt=%d flags=%lx\n",
 			   h->expiry_time, atomic_read(&h->ref.refcount), h->flags);
 	cache_get(h);
Index: bfields/net/sunrpc/xprtrdma/rpc_rdma.c
===================================================================
--- bfields.orig/net/sunrpc/xprtrdma/rpc_rdma.c
+++ bfields/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -568,7 +568,7 @@ rpcrdma_count_chunks(struct rpcrdma_rep 
 	total_len = 0;
 	while (i--) {
 		struct rpcrdma_segment *seg = &cur_wchunk->wc_target;
-		ifdebug(FACILITY) {
+		if (unlikely(debugcheck(FACILITY))) {
 			u64 off;
 			xdr_decode_hyper((__be32 *)&seg->rs_offset, &off);
 			dprintk("RPC:       %s: chunk %d@0x%llx:0x%x\n",

--
-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
