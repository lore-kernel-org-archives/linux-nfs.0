From: Bruce Allan <bwa@us.ibm.com>
Subject: [PATCH 3/5] initial changes for NFS-over-IPv6
 (linux-2.5.66-NFS_IPv6-lockd.dif)
Date: 11 Apr 2003 16:35:35 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1050104137.1413.276.camel@w-bwa1.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bwa@us.ibm.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e1.ny.us.ibm.com ([32.97.182.101])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19483d-0006Ya-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Apr 2003 16:35:45 -0700
Received: from northrelay04.pok.ibm.com (northrelay04.pok.ibm.com [9.56.224.206])
	by e1.ny.us.ibm.com (8.12.9/8.12.2) with ESMTP id h3BNZcWn198850
	for <nfs@lists.sourceforge.net>; Fri, 11 Apr 2003 19:35:38 -0400
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This patch against 2.5.66 provides for IPv6 support for the kernel NLM.

diff -Naurp linux-2.5.66/fs/lockd/clntproc.c linux-2.5.66-NFS_IPV6/fs/lockd/clntproc.c
--- linux-2.5.66/fs/lockd/clntproc.c	2003-03-24 13:59:54.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/fs/lockd/clntproc.c	2003-04-07 17:48:55.000000000 -0700
@@ -119,7 +119,8 @@ nlmclnt_proc(struct inode *inode, int cm
 	/* Retrieve transport protocol from NFS client */
 	proto = NFS_CLIENT(inode)->cl_xprt->prot;
 
-	if (!(host = nlmclnt_lookup_host(NFS_ADDR(inode), proto, vers)))
+	if (!(host = nlmclnt_lookup_host((struct sockaddr *)NFS_ADDR(inode),
+					proto, vers)))
 		return -ENOLCK;
 
 	/* Create RPC client handle if not there, and copy soft
diff -Naurp linux-2.5.66/fs/lockd/host.c linux-2.5.66-NFS_IPV6/fs/lockd/host.c
--- linux-2.5.66/fs/lockd/host.c	2003-03-24 14:00:44.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/fs/lockd/host.c	2003-04-07 17:33:37.000000000 -0700
@@ -39,9 +39,9 @@ static void			nlm_gc_hosts(void);
  * Find an NLM server handle in the cache. If there is none, create it.
  */
 struct nlm_host *
-nlmclnt_lookup_host(struct sockaddr_in *sin, int proto, int version)
+nlmclnt_lookup_host(struct sockaddr *ap, int proto, int version)
 {
-	return nlm_lookup_host(0, sin, proto, version);
+	return nlm_lookup_host(0, ap, proto, version);
 }
 
 /*
@@ -50,7 +50,7 @@ nlmclnt_lookup_host(struct sockaddr_in *
 struct nlm_host *
 nlmsvc_lookup_host(struct svc_rqst *rqstp)
 {
-	return nlm_lookup_host(1, &rqstp->rq_addr,
+	return nlm_lookup_host(1, (struct sockaddr *)&rqstp->rq_addr,
 			       rqstp->rq_prot, rqstp->rq_vers);
 }
 
@@ -58,17 +58,52 @@ nlmsvc_lookup_host(struct svc_rqst *rqst
  * Common host lookup routine for server & client
  */
 struct nlm_host *
-nlm_lookup_host(int server, struct sockaddr_in *sin,
-					int proto, int version)
+nlm_lookup_host(int server, struct sockaddr *ap, int proto, int version)
 {
 	struct nlm_host	*host, **hp;
 	u32		addr;
-	int		hash;
-
-	dprintk("lockd: nlm_lookup_host(%08x, p=%d, v=%d)\n",
-			(unsigned)(sin? ntohl(sin->sin_addr.s_addr) : 0), proto, version);
-
-	hash = NLM_ADDRHASH(sin->sin_addr.s_addr);
+	int		hash = 0;
+	struct sockaddr_in  *sin  = NULL;
+	struct sockaddr_in6 *sin6 = NULL;
+	struct in6_addr     *addr6;
+
+	switch ( ap->sa_family ) {
+	case AF_INET:
+		sin = (struct sockaddr_in *)ap;
+		dprintk("lockd: %s(%08x, p=%d, v=%d)\n",
+			__FUNCTION__,
+			(unsigned)(sin ? ntohl(sin->sin_addr.s_addr) : 0),
+			proto, version);
+
+		hash = NLM_ADDRHASH(sin->sin_addr.s_addr);
+		break;
+
+	case AF_INET6:
+		sin6 = (struct sockaddr_in6 *)ap;
+
+		if ( sin6 )
+			dprintk("lockd: %s(%x:%x:%x:%x:%x:%x:%x:%x, p=%d, v=%d)\n",
+				__FUNCTION__,
+				(unsigned)(ntohs(sin6->sin6_addr.s6_addr16[0])),
+				(unsigned)(ntohs(sin6->sin6_addr.s6_addr16[1])),
+				(unsigned)(ntohs(sin6->sin6_addr.s6_addr16[2])),
+				(unsigned)(ntohs(sin6->sin6_addr.s6_addr16[3])),
+				(unsigned)(ntohs(sin6->sin6_addr.s6_addr16[4])),
+				(unsigned)(ntohs(sin6->sin6_addr.s6_addr16[5])),
+				(unsigned)(ntohs(sin6->sin6_addr.s6_addr16[6])),
+				(unsigned)(ntohs(sin6->sin6_addr.s6_addr16[7])),
+				proto, version);
+		else
+			dprintk("lockd: %s(%08x, p=%d, v=%d)\n", 
+				__FUNCTION__, 0, proto, version);
+
+		hash = NLM_ADDRHASH(sin6->sin6_addr.s6_addr32[3]);
+		break;
+
+	default:
+		printk("lockd: %s unknown addr family", __FUNCTION__);
+		break;
+	}
 
 	/* Lock hash table */
 	down(&nlm_host_sema);
@@ -84,7 +119,7 @@ nlm_lookup_host(int server, struct socka
 		if (host->h_server != server)
 			continue;
 
-		if (nlm_cmp_addr(&host->h_addr, sin)) {
+		if (nlm_cmp_addr((struct sockaddr *)&host->h_addr, ap)) {
 			if (hp != nlm_hosts + hash) {
 				*hp = host->h_next;
 				host->h_next = nlm_hosts[hash];
@@ -103,15 +138,35 @@ nlm_lookup_host(int server, struct socka
 		goto nohost;
 	memset(host, 0, sizeof(*host));
 
-	addr = sin->sin_addr.s_addr;
-	sprintf(host->h_name, "%d.%d.%d.%d",
-			(unsigned char) (ntohl(addr) >> 24),
-			(unsigned char) (ntohl(addr) >> 16),
-			(unsigned char) (ntohl(addr) >>  8),
-			(unsigned char) (ntohl(addr) >>  0));
+	host->h_addr = *(struct sockaddr_storage *)ap;
 
-	host->h_addr       = *sin;
-	host->h_addr.sin_port = 0;	/* ouch! */
+	switch ( ap->sa_family ) {
+	case AF_INET:
+		addr = sin->sin_addr.s_addr;
+		sprintf(host->h_name, "%d.%d.%d.%d",
+				(unsigned char) (ntohl(addr) >> 24),
+				(unsigned char) (ntohl(addr) >> 16),
+				(unsigned char) (ntohl(addr) >>  8),
+				(unsigned char) (ntohl(addr) >>  0));
+
+		((struct sockaddr_in *)&(host->h_addr))->sin_port = 0; /*ouch!*/
+		break;
+
+	case AF_INET6:
+		addr6 = &sin6->sin6_addr;
+		sprintf(host->h_name, "%x:%x:%x:%x:%x:%x:%x:%x",
+				(unsigned char) (ntohs(addr6->s6_addr16[0])),
+				(unsigned char) (ntohs(addr6->s6_addr16[1])),
+				(unsigned char) (ntohs(addr6->s6_addr16[2])),
+				(unsigned char) (ntohs(addr6->s6_addr16[3])),
+				(unsigned char) (ntohs(addr6->s6_addr16[4])),
+				(unsigned char) (ntohs(addr6->s6_addr16[5])),
+				(unsigned char) (ntohs(addr6->s6_addr16[6])),
+				(unsigned char) (ntohs(addr6->s6_addr16[7])));
+
+		((struct sockaddr_in6 *)&(host->h_addr))->sin6_port = 0; /*ouch!*/
+		break;
+	}
 	host->h_version    = version;
 	host->h_proto      = proto;
 	host->h_authflavor = RPC_AUTH_UNIX;
@@ -168,8 +223,28 @@ nlm_bind_host(struct nlm_host *host)
 	struct rpc_clnt	*clnt;
 	struct rpc_xprt	*xprt;
 
-	dprintk("lockd: nlm_bind_host(%08x)\n",
-			(unsigned)ntohl(host->h_addr.sin_addr.s_addr));
+	switch ( host->h_addr.ss_family ) {
+		case AF_INET:
+			dprintk("lockd: %s(%08x)\n",
+				__FUNCTION__,
+				(unsigned)ntohl(((struct sockaddr_in *)&(host->h_addr))->sin_addr.s_addr));
+			break;
+		case AF_INET6:
+			dprintk("lockd: %s(%x:%x:%x:%x:%x:%x:%x:%x)\n",
+				__FUNCTION__,
+				(unsigned)ntohs(((struct sockaddr_in6 *)&(host->h_addr))->sin6_addr.s6_addr16[0]),
+				(unsigned)ntohs(((struct sockaddr_in6 *)&(host->h_addr))->sin6_addr.s6_addr16[1]),
+				(unsigned)ntohs(((struct sockaddr_in6 *)&(host->h_addr))->sin6_addr.s6_addr16[2]),
+				(unsigned)ntohs(((struct sockaddr_in6 *)&(host->h_addr))->sin6_addr.s6_addr16[3]),
+				(unsigned)ntohs(((struct sockaddr_in6 *)&(host->h_addr))->sin6_addr.s6_addr16[4]),
+				(unsigned)ntohs(((struct sockaddr_in6 *)&(host->h_addr))->sin6_addr.s6_addr16[5]),
+				(unsigned)ntohs(((struct sockaddr_in6 *)&(host->h_addr))->sin6_addr.s6_addr16[6]),
+				(unsigned)ntohs(((struct sockaddr_in6 *)&(host->h_addr))->sin6_addr.s6_addr16[7]));
+			break;
+		default:
+			printk("lockd: %s unknown addr family\n", __FUNCTION__);
+			break;
+	}
 
 	/* Lock host handle */
 	down(&host->h_sema);
@@ -193,7 +268,8 @@ nlm_bind_host(struct nlm_host *host)
 		/* Create RPC socket as root user so we get a priv port */
 		current->fsuid = 0;
 		cap_raise (current->cap_effective, CAP_NET_BIND_SERVICE);
-		xprt = xprt_create_proto(host->h_proto, &host->h_addr, NULL);
+		xprt = xprt_create_proto(host->h_proto,
+				(struct sockaddr *)&host->h_addr, NULL);
 		current->fsuid = saved_fsuid;
 		current->cap_effective = saved_cap;
 		if (xprt == NULL)
diff -Naurp linux-2.5.66/fs/lockd/mon.c linux-2.5.66-NFS_IPV6/fs/lockd/mon.c
--- linux-2.5.66/fs/lockd/mon.c	2003-03-24 14:01:12.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/fs/lockd/mon.c	2003-04-10 16:24:11.000000000 -0700
@@ -41,7 +41,24 @@ nsm_mon_unmon(struct nlm_host *host, u32
 	if (!clnt)
 		goto out;
 
-	args.addr = host->h_addr.sin_addr.s_addr;
+#ifdef CONFIG_NFS_IPV6
+	args.addr.family = host->h_addr.ss_family;
+	switch ( host->h_addr.ss_family ) {
+	case AF_INET:
+		args.addr.addr_u.v4.s_addr =
+		       ((struct sockaddr_in *)&(host->h_addr))->sin_addr.s_addr;
+		break;
+	case AF_INET6:
+		ipv6_addr_copy(&args.addr.addr_u.v6,
+			&((struct sockaddr_in6 *)&(host->h_addr))->sin6_addr);
+		break;
+	default:
+		printk("%s unknown address family %d\n", __FUNCTION__,
+		      host->h_addr.ss_family);
+	}
+#else
+	args.addr = ((struct sockaddr_in *)&(host->h_addr))->sin_addr.s_addr;
+#endif
 	args.proto= (host->h_proto<<1) | host->h_server;
 	args.prog = NLM_PROGRAM;
 	args.vers = host->h_version;
@@ -99,19 +116,26 @@ nsm_unmonitor(struct nlm_host *host)
 
 /*
  * Create NSM client for the local host
+ *
+ * TODO:
+ * This code needs to change when there is a way to specify a kernel to have 
+ * IPv6 support but no IPv4 support, i.e. use an AF_INET6 socket with the
+ * in6addr_loopback address, etc.  For now, just use AF_INET socket.
  */
 static struct rpc_clnt *
 nsm_create(void)
 {
 	struct rpc_xprt		*xprt;
 	struct rpc_clnt		*clnt = NULL;
-	struct sockaddr_in	sin;
+	struct sockaddr_storage	addr;
+	struct sockaddr_in	*sin = (struct sockaddr_in *)&addr;
+
+	sin->sin_family = AF_INET;
+	sin->sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+	sin->sin_port = 0;
 
-	sin.sin_family = AF_INET;
-	sin.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
-	sin.sin_port = 0;
+	xprt = xprt_create_proto(IPPROTO_UDP, (struct sockaddr *)&addr, NULL);
 
-	xprt = xprt_create_proto(IPPROTO_UDP, &sin, NULL);
 	if (!xprt)
 		goto out;
 
@@ -139,16 +163,41 @@ static u32 *
 xdr_encode_common(struct rpc_rqst *rqstp, u32 *p, struct nsm_args *argp)
 {
 	char	buffer[20];
+#ifdef CONFIG_NFS_IPV6
+	u32	v4addr;
+#else
 	u32	addr = ntohl(argp->addr);
+#endif
 
 	/*
-	 * Use the dotted-quad IP address of the remote host as
-	 * identifier. Linux statd always looks up the canonical
-	 * hostname first for whatever remote hostname it receives,
-	 * so this works alright.
+	 * Use the IP address of the remote host as identifier.  Linux
+	 * statd always looks up the canonical hostname first for whatever
+	 * remote hostname it receives, so this works alright.
 	 */
+#ifdef CONFIG_NFS_IPV6
+	switch ( argp->addr.family ) {
+	case AF_INET:
+		v4addr = ntohl(argp->addr.addr_u.v4.s_addr);
+		sprintf(buffer, "%d.%d.%d.%d",
+			(v4addr>>24) & 0xff, (v4addr>>16) & 0xff,
+			(v4addr>>8) & 0xff,  (v4addr) & 0xff);
+		break;
+	case AF_INET6:
+		sprintf(buffer, "%x:%x:%x:%x:%x:%x:%x:%x",
+			(unsigned)ntohs(argp->addr.addr_u.v6.s6_addr16[0]),
+			(unsigned)ntohs(argp->addr.addr_u.v6.s6_addr16[1]),
+			(unsigned)ntohs(argp->addr.addr_u.v6.s6_addr16[2]),
+			(unsigned)ntohs(argp->addr.addr_u.v6.s6_addr16[3]),
+			(unsigned)ntohs(argp->addr.addr_u.v6.s6_addr16[4]),
+			(unsigned)ntohs(argp->addr.addr_u.v6.s6_addr16[5]),
+			(unsigned)ntohs(argp->addr.addr_u.v6.s6_addr16[6]),
+			(unsigned)ntohs(argp->addr.addr_u.v6.s6_addr16[7]));
+		break;
+	}
+#else
 	sprintf(buffer, "%d.%d.%d.%d", (addr>>24) & 0xff, (addr>>16) & 0xff,
 				 	(addr>>8) & 0xff,  (addr) & 0xff);
+#endif
 	if (!(p = xdr_encode_string(p, buffer))
 	 || !(p = xdr_encode_string(p, system_utsname.nodename)))
 		return ERR_PTR(-EIO);
@@ -165,7 +214,22 @@ xdr_encode_mon(struct rpc_rqst *rqstp, u
 	p = xdr_encode_common(rqstp, p, argp);
 	if (IS_ERR(p))
 		return PTR_ERR(p);
+#ifdef CONFIG_NFS_IPV6
+	*p++ = argp->addr.family;
+	switch ( argp->addr.family ) {
+	case AF_INET:
+		*p++ = argp->addr.addr_u.v4.s_addr;
+		break;
+	case AF_INET6:
+		*p++ = argp->addr.addr_u.v6.s6_addr32[0];
+		*p++ = argp->addr.addr_u.v6.s6_addr32[1];
+		*p++ = argp->addr.addr_u.v6.s6_addr32[2];
+		*p++ = argp->addr.addr_u.v6.s6_addr32[3];
+		break;
+	}
+#else
 	*p++ = argp->addr;
+#endif
 	*p++ = argp->vers;
 	*p++ = argp->proto;
 	*p++ = 0;
diff -Naurp linux-2.5.66/fs/lockd/svc4proc.c linux-2.5.66-NFS_IPV6/fs/lockd/svc4proc.c
--- linux-2.5.66/fs/lockd/svc4proc.c	2003-03-24 14:00:18.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/fs/lockd/svc4proc.c	2003-04-08 11:40:18.000000000 -0700
@@ -11,6 +11,7 @@
 #include <linux/time.h>
 #include <linux/slab.h>
 #include <linux/in.h>
+#include <linux/in6.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/nfsd/nfsd.h>
@@ -415,36 +416,88 @@ static int
 nlm4svc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
 					      void	        *resp)
 {
-	struct sockaddr_in	saddr = rqstp->rq_addr;
+	struct sockaddr_storage	saddr = rqstp->rq_addr;
+	struct sockaddr_in	*sin  = NULL, *rqstp_sin;
+#ifdef CONFIG_NFS_IPV6
+	struct sockaddr_in6	*sin6 = NULL, *rqstp_sin6;
+#endif
 	int			vers = argp->vers;
 	int			prot = argp->proto >> 1;
 
 	struct nlm_host		*host;
 
 	dprintk("lockd: SM_NOTIFY     called\n");
-	if (saddr.sin_addr.s_addr != htonl(INADDR_LOOPBACK)
-	 || ntohs(saddr.sin_port) >= 1024) {
-		printk(KERN_WARNING
-			"lockd: rejected NSM callback from %08x:%d\n",
-			ntohl(rqstp->rq_addr.sin_addr.s_addr),
-			ntohs(rqstp->rq_addr.sin_port));
-		return rpc_system_err;
-	}
+	switch ( saddr.ss_family ) {
+	case AF_INET:
+		sin = (struct sockaddr_in *)&saddr;
+		rqstp_sin = (struct sockaddr_in *)&(rqstp->rq_addr);
+
+		if (sin->sin_addr.s_addr != htonl(INADDR_LOOPBACK)
+		 || ntohs(sin->sin_port) >= 1024) {
+			printk(KERN_WARNING
+				"lockd: rejected NSM callback from %08x:%d\n",
+				ntohl(rqstp_sin->sin_addr.s_addr),
+				ntohs(rqstp_sin->sin_port));
+			return rpc_system_err;
+		}
 
-	/* Obtain the host pointer for this NFS server and try to
-	 * reclaim all locks we hold on this server.
-	 */
-	saddr.sin_addr.s_addr = argp->addr;
+		/* Obtain the host pointer for this NFS server and try to
+		 * reclaim all locks we hold on this server.
+		 */
+#ifdef CONFIG_NFS_IPV6
+		sin->sin_addr.s_addr = argp->addr.addr_u.v4.s_addr;
+#else
+		sin->sin_addr.s_addr = argp->addr;
+#endif
+		break;
+
+#ifdef CONFIG_NFS_IPV6
+	case AF_INET6:
+		sin6 = (struct sockaddr_in6 *)&saddr;
+		rqstp_sin6 = (struct sockaddr_in6 *)&(rqstp->rq_addr);
+
+		if ( ipv6_addr_cmp(&sin6->sin6_addr,
+				   (struct in6_addr *)&in6addr_loopback)
+		     || ntohs(sin6->sin6_port) >= 1024) {
+			printk(KERN_WARNING
+				"lockd: rejected NSM callback from "
+				"%x:%x:%x:%x:%x:%x:%x:%x port %d\n",
+				ntohs(rqstp_sin6->sin6_addr.s6_addr16[0]),
+				ntohs(rqstp_sin6->sin6_addr.s6_addr16[1]),
+				ntohs(rqstp_sin6->sin6_addr.s6_addr16[2]),
+				ntohs(rqstp_sin6->sin6_addr.s6_addr16[3]),
+				ntohs(rqstp_sin6->sin6_addr.s6_addr16[4]),
+				ntohs(rqstp_sin6->sin6_addr.s6_addr16[5]),
+				ntohs(rqstp_sin6->sin6_addr.s6_addr16[6]),
+				ntohs(rqstp_sin6->sin6_addr.s6_addr16[7]),
+				ntohs(rqstp_sin6->sin6_port));
+			return rpc_system_err;
+		}
+
+		/* Obtain the host pointer for this NFS server and try to
+		 * reclaim all locks we hold on this server.
+		 */
+		ipv6_addr_copy(&sin6->sin6_addr, &argp->addr.addr_u.v6);
+		break;
+#endif
+
+	default:
+		printk("lockd: %s unknown address family %d\n", __FUNCTION__,
+			saddr.ss_family);
+		break;
+	}
 
 	if ((argp->proto & 1)==0) {
-		if ((host = nlmclnt_lookup_host(&saddr, prot, vers)) != NULL) {
+		if ((host = nlmclnt_lookup_host((struct sockaddr *)&saddr,
+						prot, vers)) != NULL) {
 			nlmclnt_recovery(host, argp->state);
 			nlm_release_host(host);
 		}
 	} else {
 		/* If we run on an NFS server, delete all locks held by the client */
 
-		if ((host = nlm_lookup_host(1, &saddr, prot, vers)) != NULL) {
+		if ((host = nlm_lookup_host(1, (struct sockaddr *)&saddr,
+						prot, vers)) != NULL) {
 			nlmsvc_free_host_resources(host);
 			nlm_release_host(host);
 		}
@@ -464,7 +517,7 @@ nlm4svc_callback(struct svc_rqst *rqstp,
 	if (!(call = nlmclnt_alloc_call()))
 		return rpc_system_err;
 
-	host = nlmclnt_lookup_host(&rqstp->rq_addr,
+	host = nlmclnt_lookup_host((struct sockaddr *)&rqstp->rq_addr,
 				rqstp->rq_prot, rqstp->rq_vers);
 	if (!host) {
 		kfree(call);
diff -Naurp linux-2.5.66/fs/lockd/svc.c linux-2.5.66-NFS_IPV6/fs/lockd/svc.c
--- linux-2.5.66/fs/lockd/svc.c	2003-03-24 14:00:51.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/fs/lockd/svc.c	2003-04-07 17:49:30.000000000 -0700
@@ -154,8 +154,26 @@ lockd(struct svc_rqst *rqstp)
 			break;
 		}
 
-		dprintk("lockd: request from %08x\n",
-			(unsigned)ntohl(rqstp->rq_addr.sin_addr.s_addr));
+		switch (rqstp->rq_addr.ss_family) {
+		case AF_INET:
+			dprintk("lockd: request from %08x\n",
+				(unsigned)ntohl(((struct sockaddr_in *)&rqstp->rq_addr)->sin_addr.s_addr));
+			break;
+		case AF_INET6:
+			dprintk("lockd: request from %x:%x:%x:%x:%x:%x:%x:%x\n",
+				(unsigned)(ntohs(((struct sockaddr_in6 *)&rqstp->rq_addr)->sin6_addr.s6_addr16[0])),
+				(unsigned)(ntohs(((struct sockaddr_in6 *)&rqstp->rq_addr)->sin6_addr.s6_addr16[1])),
+				(unsigned)(ntohs(((struct sockaddr_in6 *)&rqstp->rq_addr)->sin6_addr.s6_addr16[2])),
+				(unsigned)(ntohs(((struct sockaddr_in6 *)&rqstp->rq_addr)->sin6_addr.s6_addr16[3])),
+				(unsigned)(ntohs(((struct sockaddr_in6 *)&rqstp->rq_addr)->sin6_addr.s6_addr16[4])),
+				(unsigned)(ntohs(((struct sockaddr_in6 *)&rqstp->rq_addr)->sin6_addr.s6_addr16[5])),
+				(unsigned)(ntohs(((struct sockaddr_in6 *)&rqstp->rq_addr)->sin6_addr.s6_addr16[6])),
+				(unsigned)(ntohs(((struct sockaddr_in6 *)&rqstp->rq_addr)->sin6_addr.s6_addr16[7])));
+			break;
+		default:
+			printk("%s unknown address family %d\n", __FUNCTION__,
+			      rqstp->rq_addr.ss_family);
+		}
 
 		svc_process(serv, rqstp);
 
diff -Naurp linux-2.5.66/fs/lockd/svclock.c linux-2.5.66-NFS_IPV6/fs/lockd/svclock.c
--- linux-2.5.66/fs/lockd/svclock.c	2003-03-24 14:00:13.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/fs/lockd/svclock.c	2003-04-07 17:56:34.000000000 -0700
@@ -176,7 +176,7 @@ nlmsvc_create_block(struct svc_rqst *rqs
 	struct nlm_rqst		*call;
 
 	/* Create host handle for callback */
-	host = nlmclnt_lookup_host(&rqstp->rq_addr,
+	host = nlmclnt_lookup_host((struct sockaddr *)&rqstp->rq_addr,
 				rqstp->rq_prot, rqstp->rq_vers);
 	if (host == NULL)
 		return NULL;
diff -Naurp linux-2.5.66/fs/lockd/svcproc.c linux-2.5.66-NFS_IPV6/fs/lockd/svcproc.c
--- linux-2.5.66/fs/lockd/svcproc.c	2003-03-24 14:00:55.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/fs/lockd/svcproc.c	2003-04-07 17:57:50.000000000 -0700
@@ -443,33 +443,85 @@ static int
 nlmsvc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
 					      void	        *resp)
 {
-	struct sockaddr_in	saddr = rqstp->rq_addr;
+	struct sockaddr_storage	saddr = rqstp->rq_addr;
+	struct sockaddr_in  *sin  = NULL, *sin_rqstp;
+#ifdef CONFIG_NFS_IPV6
+	struct sockaddr_in6 *sin6 = NULL, *sin6_rqstp;
+#endif
 	int			vers = argp->vers;
 	int			prot = argp->proto >> 1;
 	struct nlm_host		*host;
 
 	dprintk("lockd: SM_NOTIFY     called\n");
-	if (saddr.sin_addr.s_addr != htonl(INADDR_LOOPBACK)
-	 || ntohs(saddr.sin_port) >= 1024) {
-		printk(KERN_WARNING
-			"lockd: rejected NSM callback from %08x:%d\n",
-			ntohl(rqstp->rq_addr.sin_addr.s_addr),
-			ntohs(rqstp->rq_addr.sin_port));
-		return rpc_system_err;
-	}
+	switch ( saddr.ss_family ) {
+	case AF_INET:
+		sin = (struct sockaddr_in *)&saddr;
+		sin_rqstp = (struct sockaddr_in *)&(rqstp->rq_addr);
+
+		if (sin->sin_addr.s_addr != htonl(INADDR_LOOPBACK)
+		 || ntohs(sin->sin_port) >= 1024) {
+			printk(KERN_WARNING
+				"lockd: rejected NSM callback from %08x:%d\n",
+				ntohl(sin_rqstp->sin_addr.s_addr),
+				ntohs(sin_rqstp->sin_port));
+			return rpc_system_err;
+		}
+
 
-	/* Obtain the host pointer for this NFS server and try to
-	 * reclaim all locks we hold on this server.
-	 */
-	saddr.sin_addr.s_addr = argp->addr;
+		/* Obtain the host pointer for this NFS server and try to
+		 * reclaim all locks we hold on this server.
+		 */
+#ifdef CONFIG_NFS_IPV6
+		sin->sin_addr.s_addr = argp->addr.addr_u.v4.s_addr;
+#else
+		sin->sin_addr.s_addr = argp->addr;
+#endif
+		break;
+
+#ifdef CONFIG_NFS_IPV6
+	case AF_INET6:
+		sin6 = (struct sockaddr_in6 *)&saddr;
+		sin6_rqstp = (struct sockaddr_in6 *)&(rqstp->rq_addr);
+
+		if ( ipv6_addr_cmp(&sin6->sin6_addr,
+				   (struct in6_addr *)&in6addr_loopback)
+		    || ntohs(sin6->sin6_port) >= 1024) {
+			printk(KERN_WARNING
+				"lockd: rejected NSM callback from "
+				"%x:%x:%x:%x:%x:%x:%x:%x port %d\n",
+				ntohs(sin6_rqstp->sin6_addr.s6_addr16[0]),
+				ntohs(sin6_rqstp->sin6_addr.s6_addr16[1]),
+				ntohs(sin6_rqstp->sin6_addr.s6_addr16[2]),
+				ntohs(sin6_rqstp->sin6_addr.s6_addr16[3]),
+				ntohs(sin6_rqstp->sin6_addr.s6_addr16[4]),
+				ntohs(sin6_rqstp->sin6_addr.s6_addr16[5]),
+				ntohs(sin6_rqstp->sin6_addr.s6_addr16[6]),
+				ntohs(sin6_rqstp->sin6_addr.s6_addr16[7]),
+				ntohs(sin6_rqstp->sin6_port));
+			return rpc_system_err;
+		}
+
+		/* Obtain the host pointer for this NFS server and try to
+		 * reclaim all locks we hold on this server.
+		 */
+		ipv6_addr_copy(&sin6->sin6_addr, &argp->addr.addr_u.v6);
+		break;
+#endif
+
+	default:
+		printk("%s unknown address family %d\n", __FUNCTION__,
+			saddr.ss_family);
+	}
 	if ((argp->proto & 1)==0) {
-		if ((host = nlmclnt_lookup_host(&saddr, prot, vers)) != NULL) {
+		if ((host = nlmclnt_lookup_host((struct sockaddr *)&saddr,
+						prot, vers)) != NULL) {
 			nlmclnt_recovery(host, argp->state);
 			nlm_release_host(host);
 		}
 	} else {
 		/* If we run on an NFS server, delete all locks held by the client */
-		if ((host = nlm_lookup_host(1, &saddr, prot, vers)) != NULL) {
+		if ((host = nlm_lookup_host(1, (struct sockaddr *)&saddr,
+						prot, vers)) != NULL) {
 			nlmsvc_free_host_resources(host);
 			nlm_release_host(host);
 		}
@@ -490,7 +542,7 @@ nlmsvc_callback(struct svc_rqst *rqstp, 
 	if (!(call = nlmclnt_alloc_call()))
 		return rpc_system_err;
 
-	host = nlmclnt_lookup_host(&rqstp->rq_addr,
+	host = nlmclnt_lookup_host((struct sockaddr *)&rqstp->rq_addr,
 				rqstp->rq_prot, rqstp->rq_vers);
 	if (!host) {
 		kfree(call);
diff -Naurp linux-2.5.66/fs/lockd/xdr4.c linux-2.5.66-NFS_IPV6/fs/lockd/xdr4.c
--- linux-2.5.66/fs/lockd/xdr4.c	2003-03-24 13:59:54.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/fs/lockd/xdr4.c	2003-04-10 10:02:30.000000000 -0700
@@ -354,7 +354,22 @@ nlm4svc_decode_reboot(struct svc_rqst *r
 		return 0;
 	argp->state = ntohl(*p++);
 	/* Preserve the address in network byte order */
+#ifdef CONFIG_NFS_IPV6
+	argp->addr.family = *p++;
+	switch ( argp->addr.family ) {
+	case AF_INET:
+		argp->addr.addr_u.v4.s_addr = *p++;
+		break;
+	case AF_INET6:
+		argp->addr.addr_u.v6.s6_addr32[0] = *p++;
+		argp->addr.addr_u.v6.s6_addr32[1] = *p++;
+		argp->addr.addr_u.v6.s6_addr32[2] = *p++;
+		argp->addr.addr_u.v6.s6_addr32[3] = *p++;
+		break;
+	}
+#else
 	argp->addr = *p++;
+#endif
 	return xdr_argsize_check(rqstp, p);
 }
 
diff -Naurp linux-2.5.66/fs/lockd/xdr.c linux-2.5.66-NFS_IPV6/fs/lockd/xdr.c
--- linux-2.5.66/fs/lockd/xdr.c	2003-03-24 13:59:56.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/fs/lockd/xdr.c	2003-04-01 15:10:01.000000000 -0800
@@ -348,8 +348,25 @@ nlmsvc_decode_reboot(struct svc_rqst *rq
 	if (!(p = xdr_decode_string_inplace(p, &argp->mon, &argp->len, SM_MAXSTRLEN)))
 		return 0;
 	argp->state = ntohl(*p++);
+#ifdef CONFIG_NFS_IPV6
+	argp->addr.family = *p++;
+#endif
 	/* Preserve the address in network byte order */
+#ifdef CONFIG_NFS_IPV6
+	switch ( argp->addr.family ) {
+	case AF_INET:
+		argp->addr.addr_u.v4.s_addr = *p++;
+		break;
+	case AF_INET6:
+		argp->addr.addr_u.v6.s6_addr32[0] = *p++;
+		argp->addr.addr_u.v6.s6_addr32[1] = *p++;
+		argp->addr.addr_u.v6.s6_addr32[2] = *p++;
+		argp->addr.addr_u.v6.s6_addr32[3] = *p++;
+		break;
+	}
+#else
 	argp->addr = *p++;
+#endif
 	argp->vers = *p++;
 	argp->proto = *p++;
 	return xdr_argsize_check(rqstp, p);
diff -Naurp linux-2.5.66/include/linux/lockd/lockd.h linux-2.5.66-NFS_IPV6/include/linux/lockd/lockd.h
--- linux-2.5.66/include/linux/lockd/lockd.h	2003-03-24 14:00:08.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/include/linux/lockd/lockd.h	2003-04-07 17:39:34.000000000 -0700
@@ -13,6 +13,7 @@
 
 #include <linux/config.h>
 #include <linux/in.h>
+#include <net/ipv6.h>
 #include <linux/fs.h>
 #include <linux/utsname.h>
 #include <linux/nfsd/nfsfh.h>
@@ -38,7 +39,7 @@
  */
 struct nlm_host {
 	struct nlm_host *	h_next;		/* linked list (hash table) */
-	struct sockaddr_in	h_addr;		/* peer address */
+	struct sockaddr_storage	h_addr;		/* peer address */
 	struct rpc_clnt	*	h_rpcclnt;	/* RPC client to talk to peer */
 	char			h_name[20];	/* remote hostname */
 	u32			h_version;	/* interface version */
@@ -141,9 +142,9 @@ void		  nlmclnt_freegrantargs(struct nlm
 /*
  * Host cache
  */
-struct nlm_host * nlmclnt_lookup_host(struct sockaddr_in *, int, int);
+struct nlm_host * nlmclnt_lookup_host(struct sockaddr *, int, int);
 struct nlm_host * nlmsvc_lookup_host(struct svc_rqst *);
-struct nlm_host * nlm_lookup_host(int server, struct sockaddr_in *, int, int);
+struct nlm_host * nlm_lookup_host(int server, struct sockaddr *, int, int);
 struct rpc_clnt * nlm_bind_host(struct nlm_host *);
 void		  nlm_rebind_host(struct nlm_host *);
 struct nlm_host * nlm_get_host(struct nlm_host *);
@@ -183,12 +184,28 @@ nlmsvc_file_inode(struct nlm_file *file)
 }
 
 /*
- * Compare two host addresses (needs modifying for ipv6)
+ * Compare two host addresses
  */
 static __inline__ int
-nlm_cmp_addr(struct sockaddr_in *sin1, struct sockaddr_in *sin2)
+nlm_cmp_addr(struct sockaddr *a1, struct sockaddr *a2)
 {
-	return sin1->sin_addr.s_addr == sin2->sin_addr.s_addr;
+	if (a1->sa_family != a2->sa_family) return 0;
+
+	switch ( a1->sa_family ) {
+	case AF_INET6:
+		return(!ipv6_addr_cmp(&(((struct sockaddr_in6 *)a1)->sin6_addr),
+				    &(((struct sockaddr_in6 *)a2)->sin6_addr)));
+		break;
+
+	case AF_INET:
+		return ((struct sockaddr_in *)a1)->sin_addr.s_addr == 
+		       ((struct sockaddr_in *)a2)->sin_addr.s_addr;
+		break;
+
+	default:
+		printk("%s unknown address family %d\n", __FUNCTION__,
+		      a1->sa_family);
+	}
 }
 
 /*
diff -Naurp linux-2.5.66/include/linux/lockd/sm_inter.h linux-2.5.66-NFS_IPV6/include/linux/lockd/sm_inter.h
--- linux-2.5.66/include/linux/lockd/sm_inter.h	2003-03-24 14:00:40.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/include/linux/lockd/sm_inter.h	2003-04-07 17:39:55.000000000 -0700
@@ -24,7 +24,11 @@
  * Arguments for all calls to statd
  */
 struct nsm_args {
+#ifdef CONFIG_NFS_IPV6
+	struct nfs_addr	addr;		/* remote address and family */
+#else
 	u32		addr;		/* remote address */
+#endif
 	u32		prog;		/* RPC callback info */
 	u32		vers;
 	u32		proc;
diff -Naurp linux-2.5.66/include/linux/lockd/xdr.h linux-2.5.66-NFS_IPV6/include/linux/lockd/xdr.h
--- linux-2.5.66/include/linux/lockd/xdr.h	2003-03-24 13:59:53.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/include/linux/lockd/xdr.h	2003-04-01 15:10:14.000000000 -0800
@@ -75,7 +75,11 @@ struct nlm_reboot {
 	char *		mon;
 	int		len;
 	u32		state;
+#ifdef CONFIG_NFS_IPV6
+	struct nfs_addr	addr;
+#else
 	u32		addr;
+#endif
 	u32		vers;
 	u32		proto;
 };

-- 
Bruce Allan
Linux Technology Center
IBM Corporation, Beaverton OR



-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
