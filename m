Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:55298 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752958Ab3IZOpf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 10:45:35 -0400
Subject: [PATCH 3/4] SunRPC: Use no_printk() for the null dprintk() and
 dfprintk()
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: David Howells <dhowells@redhat.com>
Cc: olof@lixom.net, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 26 Sep 2013 15:45:25 +0100
Message-ID: <20130926144525.29424.11130.stgit@warthog.procyon.org.uk>
In-Reply-To: <20130926144502.29424.21633.stgit@warthog.procyon.org.uk>
References: <20130926144502.29424.21633.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use no_printk() for the null dprintk() and dfprintk() so that the compiler
doesn't complain about unused variables for stuff that's just printed.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/lockd/svc.c               |    6 ++++--
 fs/lockd/svclock.c           |    6 ++++--
 fs/nfs/fscache.c             |    2 +-
 fs/nfsd/nfs4proc.c           |    6 ++----
 fs/nfsd/nfsfh.c              |   10 ++++++----
 include/linux/sunrpc/debug.h |   37 ++++++++++++++++++-------------------
 include/linux/sunrpc/sched.h |   15 +++++++--------
 net/sunrpc/clnt.c            |    4 ++--
 net/sunrpc/sched.c           |   11 +++--------
 net/sunrpc/svcsock.c         |   33 +++++++++++++++++++--------------
 10 files changed, 66 insertions(+), 64 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 10d6c41..ba73105 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -147,7 +147,6 @@ lockd(void *vrqstp)
 	 */
 	while (!kthread_should_stop()) {
 		long timeout = MAX_SCHEDULE_TIMEOUT;
-		RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 
 		/* update sv_maxconn if it has changed */
 		rqstp->rq_server->sv_maxconn = nlm_max_connections;
@@ -167,8 +166,11 @@ lockd(void *vrqstp)
 		err = svc_recv(rqstp, timeout);
 		if (err == -EAGAIN || err == -EINTR)
 			continue;
-		dprintk("lockd: request from %s\n",
+		ifdebug(FACILITY) {
+			char buf[RPC_MAX_ADDRBUFLEN];
+			dprintk("lockd: request from %s\n",
 				svc_print_addr(rqstp, buf, sizeof(buf)));
+		}
 
 		svc_process(rqstp);
 	}
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index e066a39..2749f44 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -53,9 +53,9 @@ static const struct rpc_call_ops nlmsvc_grant_ops;
 static LIST_HEAD(nlm_blocked);
 static DEFINE_SPINLOCK(nlm_blocked_lock);
 
-#ifdef LOCKD_DEBUG
 static const char *nlmdbg_cookie2a(const struct nlm_cookie *cookie)
 {
+#ifdef LOCKD_DEBUG
 	/*
 	 * We can get away with a static buffer because we're only
 	 * called with BKL held.
@@ -79,8 +79,10 @@ static const char *nlmdbg_cookie2a(const struct nlm_cookie *cookie)
 	*p = '\0';
 
 	return buf;
-}
+#else
+	return "";
 #endif
+}
 
 /*
  * Insert a blocked lock into the global list
diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index 24d1d1c..3e8e0aa 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -317,7 +317,7 @@ void nfs_fscache_reset_inode_cookie(struct inode *inode)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_server *nfss = NFS_SERVER(inode);
-	NFS_IFDEBUG(struct fscache_cookie *old = nfsi->fscache);
+	struct fscache_cookie *old = nfsi->fscache;
 
 	nfs_fscache_inode_lock(inode);
 	if (nfsi->fscache) {
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 419572f..1254635 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1172,9 +1172,7 @@ struct nfsd4_operation {
 
 static struct nfsd4_operation nfsd4_ops[];
 
-#ifdef NFSD_DEBUG
 static const char *nfsd4_op_name(unsigned opnum);
-#endif
 
 /*
  * Enforce NFSv4.1 COMPOUND ordering rules:
@@ -1842,14 +1840,14 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 };
 
-#ifdef NFSD_DEBUG
 static const char *nfsd4_op_name(unsigned opnum)
 {
+#ifdef NFSD_DEBUG
 	if (opnum < ARRAY_SIZE(nfsd4_ops))
 		return nfsd4_ops[opnum].op_name;
+#endif
 	return "unknown_operation";
 }
-#endif
 
 #define nfsd4_voidres			nfsd4_voidargs
 struct nfsd4_voidargs { int dummy; };
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 814afaa..0aba73a 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -87,10 +87,12 @@ static __be32 nfsd_setuser_and_check_port(struct svc_rqst *rqstp,
 
 	/* Check if the request originated from a secure port. */
 	if (!rqstp->rq_secure && !(flags & NFSEXP_INSECURE_PORT)) {
-		RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
-		dprintk(KERN_WARNING
-		       "nfsd: request from insecure port %s!\n",
-		       svc_print_addr(rqstp, buf, sizeof(buf)));
+		ifdebug(FACILITY) {
+			char buf[RPC_MAX_ADDRBUFLEN];
+			dprintk(KERN_WARNING
+				"nfsd: request from insecure port %s!\n",
+				svc_print_addr(rqstp, buf, sizeof(buf)));
+		}
 		return nfserr_perm;
 	}
 
diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 889474b..60116cb 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -38,30 +38,29 @@ extern unsigned int		nlm_debug;
 #undef ifdebug
 #ifdef RPC_DEBUG			
 # define ifdebug(fac)		if (unlikely(rpc_debug & RPCDBG_##fac))
-
-# define dfprintk(fac, fmt, ...)		\
-	do { \
-		ifdebug(fac) \
-			printk(KERN_DEFAULT fmt, ##__VA_ARGS__);	\
-	} while (0)
-
-# define dfprintk_rcu(fac, fmt, ...)		\
-	do { \
-		ifdebug(fac) { \
-			rcu_read_lock(); \
-			printk(KERN_DEFAULT fmt, ##__VA_ARGS__);	\
-			rcu_read_unlock(); \
-		} \
-	} while (0)
-
+# define __dprintk(fmt, ...)	printk(KERN_DEFAULT fmt, ##__VA_ARGS__);
 # define RPC_IFDEBUG(x)		x
 #else
-# define ifdebug(fac)			if (0)
-# define dfprintk(fac, fmt, ...)	do {} while (0)
-# define dfprintk_rcu(fac, fmt, ...)	do {} while (0)
+# define ifdebug(fac)		if (0)
+# define __dprintk(fmt, ...)	no_printk(KERN_DEFAULT fmt, ##__VA_ARGS__);
 # define RPC_IFDEBUG(x)
 #endif
 
+#define dfprintk(fac, fmt, ...)				\
+	do {						\
+		ifdebug(fac)				\
+			__dprintk(fmt, ##__VA_ARGS__);	\
+	} while (0)
+
+#define dfprintk_rcu(fac, fmt, ...)			\
+	do {						\
+		ifdebug(fac) {				\
+			rcu_read_lock();		\
+			__dprintk(fmt, ##__VA_ARGS__);	\
+			rcu_read_unlock();		\
+		}					\
+	} while (0)
+
 /*
  * Sysctl interface for RPC debugging
  */
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 01543d0..25523ca 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -250,23 +250,22 @@ static inline int rpc_wait_for_completion_task(struct rpc_task *task)
 	return __rpc_wait_for_completion_task(task, NULL);
 }
 
-#if defined(RPC_DEBUG) || defined (RPC_TRACEPOINTS)
 static inline const char * rpc_qname(const struct rpc_wait_queue *q)
 {
-	return ((q && q->name) ? q->name : "unknown");
+#if defined(RPC_DEBUG) || defined (RPC_TRACEPOINTS)
+	if (q && q->name)
+		return q->name;
+#endif
+	return "unknown";
 }
 
 static inline void rpc_assign_waitqueue_name(struct rpc_wait_queue *q,
 		const char *name)
 {
+#if defined(RPC_DEBUG) || defined (RPC_TRACEPOINTS)
 	q->name = name;
-}
-#else
-static inline void rpc_assign_waitqueue_name(struct rpc_wait_queue *q,
-		const char *name)
-{
-}
 #endif
+}
 
 static inline unsigned short rpc_task_pid(const struct rpc_task *t)
 {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index ef452a29..1c6d494 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1282,9 +1282,9 @@ rpc_restart_call(struct rpc_task *task)
 }
 EXPORT_SYMBOL_GPL(rpc_restart_call);
 
-#ifdef RPC_DEBUG
 static const char *rpc_proc_name(const struct rpc_task *task)
 {
+#ifdef RPC_DEBUG
 	const struct rpc_procinfo *proc = task->tk_msg.rpc_proc;
 
 	if (proc) {
@@ -1293,9 +1293,9 @@ static const char *rpc_proc_name(const struct rpc_task *task)
 		else
 			return "NULL";
 	} else
+#endif
 		return "no proc";
 }
-#endif
 
 /*
  * 0.  Initial state
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 0a4b07c..8e325f5 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -258,18 +258,13 @@ static int rpc_wait_bit_killable(void *word)
 	return 0;
 }
 
-#if defined(RPC_DEBUG) || defined(RPC_TRACEPOINTS)
 static void rpc_task_set_debuginfo(struct rpc_task *task)
 {
+#if defined(RPC_DEBUG) || defined(RPC_TRACEPOINTS)
 	static atomic_t rpc_pid;
-
-	rpc_task_pid(task) = atomic_inc_return(&rpc_pid);
-}
-#else
-static inline void rpc_task_set_debuginfo(struct rpc_task *task)
-{
-}
+	task->tk_pid = atomic_inc_return(&rpc_pid);
 #endif
+}
 
 static void rpc_set_active(struct rpc_task *task)
 {
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 9c9caaa..67e890e 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -244,7 +244,6 @@ static int svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
 	int		len = 0;
 	unsigned long tailoff;
 	unsigned long headoff;
-	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 
 	if (rqstp->rq_prot == IPPROTO_UDP) {
 		struct msghdr msg = {
@@ -267,9 +266,12 @@ static int svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
 			       rqstp->rq_respages[0], tailoff);
 
 out:
-	dprintk("svc: socket %p sendto([%p %Zu... ], %d) = %d (addr %s)\n",
-		svsk, xdr->head[0].iov_base, xdr->head[0].iov_len,
-		xdr->len, len, svc_print_addr(rqstp, buf, sizeof(buf)));
+	ifdebug(FACILITY) {
+		char buf[RPC_MAX_ADDRBUFLEN];
+		dprintk("svc: socket %p sendto([%p %Zu... ], %d) = %d (addr %s)\n",
+			svsk, xdr->head[0].iov_base, xdr->head[0].iov_len,
+			xdr->len, len, svc_print_addr(rqstp, buf, sizeof(buf)));
+	}
 
 	return len;
 }
@@ -809,7 +811,6 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	struct socket	*newsock;
 	struct svc_sock	*newsvsk;
 	int		err, slen;
-	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 
 	dprintk("svc: tcp_accept %p sock %p\n", svsk, sock);
 	if (!sock)
@@ -839,14 +840,16 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	 * hosts here, but when we get encryption, the IP of the host won't
 	 * tell us anything.  For now just warn about unpriv connections.
 	 */
-	if (!svc_port_is_privileged(sin)) {
-		dprintk(KERN_WARNING
-			"%s: connect from unprivileged port: %s\n",
-			serv->sv_name,
-			__svc_print_addr(sin, buf, sizeof(buf)));
+	ifdebug(FACILITY) {
+		char buf[RPC_MAX_ADDRBUFLEN];
+		__svc_print_addr(sin, buf, sizeof(buf));
+		if (!svc_port_is_privileged(sin)) {
+			dprintk(KERN_WARNING
+				"%s: connect from unprivileged port: %s\n",
+				serv->sv_name, buf);
+		}
+		dprintk("%s: connect from %s\n", serv->sv_name, buf);
 	}
-	dprintk("%s: connect from %s\n", serv->sv_name,
-		__svc_print_addr(sin, buf, sizeof(buf)));
 
 	/* make sure that a write doesn't block forever when
 	 * low on memory
@@ -1465,11 +1468,13 @@ static struct svc_xprt *svc_create_socket(struct svc_serv *serv,
 	int		newlen;
 	int		family;
 	int		val;
-	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 
-	dprintk("svc: svc_create_socket(%s, %d, %s)\n",
+	ifdebug(FACILITY) {
+		char buf[RPC_MAX_ADDRBUFLEN];
+		dprintk("svc: svc_create_socket(%s, %d, %s)\n",
 			serv->sv_program->pg_name, protocol,
 			__svc_print_addr(sin, buf, sizeof(buf)));
+	}
 
 	if (protocol != IPPROTO_UDP && protocol != IPPROTO_TCP) {
 		printk(KERN_WARNING "svc: only UDP and TCP "

