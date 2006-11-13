From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/13] SUNRPC: Add a function to format the address in
	an svc_rqst for printing
Date: Mon, 13 Nov 2006 07:58:15 -0500
Message-ID: <20061113125815.4435.14574.stgit@localhost.localdomain>
References: <20061113125640.4435.11957.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GjdfC-00048M-G3
	for nfs@lists.sourceforge.net; Mon, 13 Nov 2006 07:23:59 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GjdfC-0005hf-Uu
	for nfs@lists.sourceforge.net; Mon, 13 Nov 2006 07:23:59 -0800
To: neilb@suse.de
In-Reply-To: <20061113125640.4435.11957.stgit@localhost.localdomain>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

There are loads of places where the RPC server assumes that the rq_addr
fields contains an IPv4 address.  Top among these are error and debugging
messages that display the server's IP address.

Let's refactor the address printing into a separate function that's smart
enough to figure out the difference between IPv4 and IPv6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 fs/lockd/svc.c             |    6 ++--
 fs/lockd/svc4proc.c        |    7 ++--
 fs/lockd/svcproc.c         |    7 ++--
 fs/nfs/callback.c          |   12 +++++--
 fs/nfsd/nfsfh.c            |    8 ++---
 fs/nfsd/nfsproc.c          |    7 ++--
 include/linux/sunrpc/svc.h |    3 ++
 net/sunrpc/svcsock.c       |   75 ++++++++++++++++++++++++++++++++------------
 8 files changed, 84 insertions(+), 41 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 2c3d5ac..d42be4f 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -141,6 +141,7 @@ lockd(struct svc_rqst *rqstp)
 	 */
 	while ((nlmsvc_users || !signalled()) && nlmsvc_pid == current->pid) {
 		long timeout = MAX_SCHEDULE_TIMEOUT;
+		char buf[RPC_MAX_ADDRBUFLEN];
 
 		if (signalled()) {
 			flush_signals(current);
@@ -175,11 +176,10 @@ lockd(struct svc_rqst *rqstp)
 			break;
 		}
 
-		dprintk("lockd: request from %08x\n",
-			(unsigned)ntohl(rqstp->rq_addr.sin_addr.s_addr));
+		dprintk("lockd: request from %s\n", 
+				svc_print_addr(rqstp, buf, sizeof(buf)));
 
 		svc_process(rqstp);
-
 	}
 
 	flush_signals(current);
diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index f67146a..d724eac 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -426,10 +426,9 @@ nlm4svc_proc_sm_notify(struct svc_rqst *
 	dprintk("lockd: SM_NOTIFY     called\n");
 	if (saddr.sin_addr.s_addr != htonl(INADDR_LOOPBACK)
 	 || ntohs(saddr.sin_port) >= 1024) {
-		printk(KERN_WARNING
-			"lockd: rejected NSM callback from %08x:%d\n",
-			ntohl(rqstp->rq_addr.sin_addr.s_addr),
-			ntohs(rqstp->rq_addr.sin_port));
+		char buf[RPC_MAX_ADDRBUFLEN];
+		printk(KERN_WARNING "lockd: rejected NSM callback from %s\n", 
+				svc_print_addr(rqstp, buf, sizeof(buf)));
 		return rpc_system_err;
 	}
 
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 3707c3a..f590304 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -457,10 +457,9 @@ nlmsvc_proc_sm_notify(struct svc_rqst *r
 	dprintk("lockd: SM_NOTIFY     called\n");
 	if (saddr.sin_addr.s_addr != htonl(INADDR_LOOPBACK)
 	 || ntohs(saddr.sin_port) >= 1024) {
-		printk(KERN_WARNING
-			"lockd: rejected NSM callback from %08x:%d\n",
-			ntohl(rqstp->rq_addr.sin_addr.s_addr),
-			ntohs(rqstp->rq_addr.sin_port));
+		char buf[RPC_MAX_ADDRBUFLEN];
+		printk(KERN_WARNING "lockd: rejected NSM callback from %s\n",
+				svc_print_addr(rqstp, buf, sizeof(buf)));
 		return rpc_system_err;
 	}
 
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index e393532..d277ff9 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -71,6 +71,8 @@ static void nfs_callback_svc(struct svc_
 	complete(&nfs_callback_info.started);
 
 	for(;;) {
+		char buf[RPC_MAX_ADDRBUFLEN];
+
 		if (signalled()) {
 			if (nfs_callback_info.users == 0)
 				break;
@@ -88,8 +90,8 @@ static void nfs_callback_svc(struct svc_
 					__FUNCTION__, -err);
 			break;
 		}
-		dprintk("%s: request from %u.%u.%u.%u\n", __FUNCTION__,
-				NIPQUAD(rqstp->rq_addr.sin_addr.s_addr));
+		dprintk("%s: request from %s\n", __FUNCTION__,
+				svc_print_addr(rqstp, buf, sizeof(buf)));
 		svc_process(rqstp);
 	}
 
@@ -166,13 +168,17 @@ static int nfs_callback_authenticate(str
 {
 	struct sockaddr_in *addr = &rqstp->rq_addr;
 	struct nfs_client *clp;
+	char buf[RPC_MAX_ADDRBUFLEN];
 
 	/* Don't talk to strangers */
 	clp = nfs_find_client(addr, 4);
 	if (clp == NULL)
 		return SVC_DROP;
-	dprintk("%s: %u.%u.%u.%u NFSv4 callback!\n", __FUNCTION__, NIPQUAD(addr->sin_addr));
+
+	dprintk("%s: %s NFSv4 callback!\n", __FUNCTION__,
+			svc_print_addr(rqstp, buf, sizeof(buf)));
 	nfs_put_client(clp);
+
 	switch (rqstp->rq_authop->flavour) {
 		case RPC_AUTH_NULL:
 			if (rqstp->rq_proc != CB_NULL)
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 727ab3b..badb2bd 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -20,6 +20,7 @@ #include <linux/dcache.h>
 #include <linux/mount.h>
 #include <asm/pgtable.h>
 
+#include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
 
@@ -180,10 +181,9 @@ fh_verify(struct svc_rqst *rqstp, struct
 		/* Check if the request originated from a secure port. */
 		error = nfserr_perm;
 		if (!rqstp->rq_secure && EX_SECURE(exp)) {
-			printk(KERN_WARNING
-			       "nfsd: request from insecure port (%u.%u.%u.%u:%d)!\n",
-			       NIPQUAD(rqstp->rq_addr.sin_addr.s_addr),
-			       ntohs(rqstp->rq_addr.sin_port));
+			char buf[RPC_MAX_ADDRBUFLEN];
+			printk(KERN_WARNING "nfsd: request from insecure port %s!\n",
+					svc_print_addr(rqstp, buf, sizeof(buf)));
 			goto out;
 		}
 
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index ec983b7..5cc2eec 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -19,6 +19,7 @@ #include <linux/namei.h>
 #include <linux/unistd.h>
 #include <linux/slab.h>
 
+#include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/cache.h>
@@ -147,10 +148,10 @@ nfsd_proc_read(struct svc_rqst *rqstp, s
 	 */
 
 	if (NFSSVC_MAXBLKSIZE_V2 < argp->count) {
+		char buf[RPC_MAX_ADDRBUFLEN];
 		printk(KERN_NOTICE
-			"oversized read request from %u.%u.%u.%u:%d (%d bytes)\n",
-				NIPQUAD(rqstp->rq_addr.sin_addr.s_addr),
-				ntohs(rqstp->rq_addr.sin_port),
+			"oversized read request from %s (%d bytes)\n",
+				svc_print_addr(rqstp, buf, sizeof(buf)),
 				argp->count);
 		argp->count = NFSSVC_MAXBLKSIZE_V2;
 	}
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 6fc2684..8720aa5 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -366,5 +366,8 @@ int		   svc_register(struct svc_serv *, 
 void		   svc_wake_up(struct svc_serv *);
 void		   svc_reserve(struct svc_rqst *rqstp, int space);
 struct svc_pool *  svc_pool_for_cpu(struct svc_serv *serv, int cpu);
+char *		   svc_print_addr(struct svc_rqst *, char *, size_t);
+
+#define	RPC_MAX_ADDRBUFLEN	(63U)
 
 #endif /* SUNRPC_SVC_H */
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 8fa40cf..d93b7cb 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -40,6 +40,7 @@ #include <asm/uaccess.h>
 #include <asm/ioctls.h>
 
 #include <linux/sunrpc/types.h>
+#include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/stats.h>
@@ -84,6 +85,41 @@ static struct cache_deferred_req *svc_de
  */
 static int svc_conn_age_period = 6*60;
 
+static char *__svc_print_addr(struct sockaddr *addr, char *buf, size_t len)
+{
+	switch (addr->sa_family) {
+	case AF_INET:
+		snprintf(buf, len, "%u.%u.%u.%u, port=%u",
+			NIPQUAD(((struct sockaddr_in *) addr)->sin_addr),
+			htons(((struct sockaddr_in *) addr)->sin_port));
+		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		snprintf(buf, len, "%x:%x:%x:%x:%x:%x:%x:%x, port=%u",
+			NIP6(((struct sockaddr_in6 *) addr)->sin6_addr),
+			htons(((struct sockaddr_in6 *) addr)->sin6_port));
+		break;
+#endif
+	default:
+		snprintf(buf, len, "unknown address type");
+		break;
+	}
+	return buf;
+}
+
+/**
+ * svc_print_addr - Format rq_addr field for printing
+ * @rqstp: svc_rqst struct containing address to print
+ * @buf: target buffer for formatted address
+ * @len: length of target buffer
+ *
+ */
+char *svc_print_addr(struct svc_rqst *rqstp, char *buf, size_t len)
+{
+	return __svc_print_addr((struct sockaddr *) &rqstp->rq_addr, buf, len);
+}
+EXPORT_SYMBOL_GPL(svc_print_addr);
+
 /*
  * Queue up an idle server thread.  Must have pool->sp_lock held.
  * Note: this is really a stack rather than a queue, so that we only
@@ -391,6 +427,7 @@ svc_sendto(struct svc_rqst *rqstp, struc
 	size_t		base = xdr->page_base;
 	unsigned int	pglen = xdr->page_len;
 	unsigned int	flags = MSG_MORE;
+	char		buf[RPC_MAX_ADDRBUFLEN];
 
 	slen = xdr->len;
 
@@ -453,9 +490,9 @@ svc_sendto(struct svc_rqst *rqstp, struc
 			len += result;
 	}
 out:
-	dprintk("svc: socket %p sendto([%p %Zu... ], %d) = %d (addr %x)\n",
-			rqstp->rq_sock, xdr->head[0].iov_base, xdr->head[0].iov_len, xdr->len, len,
-		rqstp->rq_addr.sin_addr.s_addr);
+	dprintk("svc: socket %p sendto([%p %Zu... ], %d) = %d (addr %s)\n",
+			rqstp->rq_sock, xdr->head[0].iov_base, xdr->head[0].iov_len,
+			xdr->len, len, svc_print_addr(rqstp, buf, sizeof(buf)));
 
 	return len;
 }
@@ -835,6 +872,7 @@ svc_tcp_accept(struct svc_sock *svsk)
 	struct socket	*newsock;
 	struct svc_sock	*newsvsk;
 	int		err, slen = 0;
+	char		buf[RPC_MAX_ADDRBUFLEN];
 
 	dprintk("svc: tcp_accept %p sock %p\n", svsk, sock);
 	if (!sock)
@@ -865,18 +903,17 @@ svc_tcp_accept(struct svc_sock *svsk)
 	}
 
 	/* Ideally, we would want to reject connections from unauthorized
-	 * hosts here, but when we get encription, the IP of the host won't
-	 * tell us anything. For now just warn about unpriv connections.
+	 * hosts here, but when we get encryption, the IP of the host won't
+	 * tell us anything.  For now just warn about unpriv connections.
 	 */
 	if (ntohs(sin.sin_port) >= 1024) {
 		dprintk(KERN_WARNING
-			"%s: connect from unprivileged port: %u.%u.%u.%u:%d\n",
-			serv->sv_name, 
-			NIPQUAD(sin.sin_addr.s_addr), ntohs(sin.sin_port));
+			"%s: connect from unprivileged port: %s\n",
+			serv->sv_name,
+			__svc_print_addr((struct sockaddr *) &sin, buf,
+								sizeof(buf)));
 	}
-
-	dprintk("%s: connect from %u.%u.%u.%u:%04x\n", serv->sv_name,
-			NIPQUAD(sin.sin_addr.s_addr), ntohs(sin.sin_port));
+	dprintk("%s: connect from %s\n", serv->sv_name, buf);
 
 	/* make sure that a write doesn't block forever when
 	 * low on memory
@@ -910,11 +947,8 @@ svc_tcp_accept(struct svc_sock *svsk)
 					"sockets, consider increasing the "
 					"number of nfsd threads\n",
 						   serv->sv_name);
-				printk(KERN_NOTICE "%s: last TCP connect from "
-					"%u.%u.%u.%u:%d\n",
-					serv->sv_name,
-					NIPQUAD(sin.sin_addr.s_addr),
-					ntohs(sin.sin_port));
+				printk(KERN_NOTICE "%s: last TCP connect from %s\n",
+					serv->sv_name, buf);
 			}
 			/*
 			 * Always select the oldest socket. It's not fair,
@@ -1535,11 +1569,12 @@ static int svc_create_socket(struct svc_
 	struct socket	*sock;
 	int		error;
 	int		type;
+	char		buf[RPC_MAX_ADDRBUFLEN];
 
-	dprintk("svc: svc_create_socket(%s, %d, %u.%u.%u.%u:%d)\n",
-				serv->sv_program->pg_name, protocol,
-				NIPQUAD(sin->sin_addr.s_addr),
-				ntohs(sin->sin_port));
+	dprintk("svc: svc_create_socket(%s, %d, %s)\n",
+			serv->sv_program->pg_name, protocol,
+			__svc_print_addr((struct sockaddr *) sin, buf,
+								sizeof(buf)));
 
 	if (protocol != IPPROTO_UDP && protocol != IPPROTO_TCP) {
 		printk(KERN_WARNING "svc: only UDP and TCP "

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
