From: Bruce Allan <bwa@us.ibm.com>
Subject: [PATCH 4/5] initial changes for NFS-over-IPv6
 (linux-2.5.66-NFS_IPv6-sunrpc.dif)
Date: 11 Apr 2003 16:35:47 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1050104148.1412.280.camel@w-bwa1.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bwa@us.ibm.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e35.co.us.ibm.com ([32.97.110.133])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19483o-0006Zt-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Apr 2003 16:35:56 -0700
Received: from westrelay04.boulder.ibm.com (westrelay04.boulder.ibm.com [9.17.193.32])
	by e35.co.us.ibm.com (8.12.9/8.12.2) with ESMTP id h3BNZnuT090082
	for <nfs@lists.sourceforge.net>; Fri, 11 Apr 2003 19:35:49 -0400
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

This patch against 2.5.66 provides for IPv6 support for the kernel
sunrpc.

diff -Naurp linux-2.5.66/net/sunrpc/clnt.c linux-2.5.66-NFS_IPV6/net/sunrpc/clnt.c
--- linux-2.5.66/net/sunrpc/clnt.c	2003-03-24 14:00:18.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/net/sunrpc/clnt.c	2003-04-07 17:42:37.000000000 -0700
@@ -27,6 +27,7 @@
 #include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/in.h>
+#include <linux/in6.h>
 #include <linux/utsname.h>
 
 #include <linux/sunrpc/clnt.h>
@@ -122,7 +123,18 @@ rpc_create_client(struct rpc_xprt *xprt,
 	clnt->cl_maxproc  = version->nrprocs;
 	clnt->cl_server   = servname;
 	clnt->cl_protname = program->name;
-	clnt->cl_port     = xprt->addr.sin_port;
+	switch ( xprt->addr.ss_family ) {
+	case AF_INET:
+		clnt->cl_port = ((struct sockaddr_in *)&(xprt->addr))->sin_port;
+		break;
+	case AF_INET6:
+		clnt->cl_port = ((struct sockaddr_in6 *)&(xprt->addr))->sin6_port;
+		break;
+	default:
+		printk("RPC: %s unknown address family %d\n", __FUNCTION__,
+			xprt->addr.ss_family);
+		break;
+	}
 	clnt->cl_prog     = program->number;
 	clnt->cl_vers     = version->number;
 	clnt->cl_prot     = xprt->prot;
diff -Naurp linux-2.5.66/net/sunrpc/pmap_clnt.c linux-2.5.66-NFS_IPV6/net/sunrpc/pmap_clnt.c
--- linux-2.5.66/net/sunrpc/pmap_clnt.c	2003-03-24 14:00:39.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/net/sunrpc/pmap_clnt.c	2003-04-10 16:30:04.000000000 -0700
@@ -16,6 +16,7 @@
 #include <linux/errno.h>
 #include <linux/uio.h>
 #include <linux/in.h>
+#include <linux/in6.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/xprt.h>
 #include <linux/sunrpc/sched.h>
@@ -29,7 +30,7 @@
 #define PMAP_GETPORT		3
 
 static struct rpc_procinfo	pmap_procedures[];
-static struct rpc_clnt *	pmap_create(char *, struct sockaddr_in *, int);
+static struct rpc_clnt *	pmap_create(char *, struct sockaddr *, int);
 static void			pmap_getport_done(struct rpc_task *);
 extern struct rpc_program	pmap_program;
 static spinlock_t		pmap_lock = SPIN_LOCK_UNLOCKED;
@@ -42,7 +43,7 @@ void
 rpc_getport(struct rpc_task *task, struct rpc_clnt *clnt)
 {
 	struct rpc_portmap *map = &clnt->cl_pmap;
-	struct sockaddr_in *sap = &clnt->cl_xprt->addr;
+	struct sockaddr *sap = (struct sockaddr *)&clnt->cl_xprt->addr;
 	struct rpc_message msg = {
 		.rpc_proc	= &pmap_procedures[PMAP_GETPORT],
 		.rpc_argp	= map,
@@ -94,7 +95,7 @@ bailout:
 
 #ifdef CONFIG_ROOT_NFS
 int
-rpc_getport_external(struct sockaddr_in *sin, __u32 prog, __u32 vers, int prot)
+rpc_getport_external(struct sockaddr *sin, __u32 prog, __u32 vers, int prot)
 {
 	struct rpc_portmap map = {
 		.pm_prog	= prog,
@@ -142,7 +143,18 @@ pmap_getport_done(struct rpc_task *task)
 	} else {
 		/* byte-swap port number first */
 		clnt->cl_port = htons(clnt->cl_port);
-		clnt->cl_xprt->addr.sin_port = clnt->cl_port;
+		switch ( clnt->cl_xprt->addr.ss_family ) {
+		case AF_INET:
+			((struct sockaddr_in *)&(clnt->cl_xprt->addr))->sin_port = clnt->cl_port;
+			break;
+		case AF_INET6:
+			((struct sockaddr_in6 *)&(clnt->cl_xprt->addr))->sin6_port = clnt->cl_port;
+			break;
+		default:
+			printk("RPC: %s unknown address family %d\n",
+				__FUNCTION__, clnt->cl_xprt->addr.ss_family);
+			break;
+		}
 	}
 	spin_lock(&pmap_lock);
 	clnt->cl_binding = 0;
@@ -153,11 +165,17 @@ pmap_getport_done(struct rpc_task *task)
 /*
  * Set or unset a port registration with the local portmapper.
  * port == 0 means unregister, port != 0 means register.
+ *
+ * TODO:
+ * This code needs to change when there is a way to specify a kernel to have 
+ * IPv6 support but no IPv4 support, i.e. use an AF_INET6 socket with the 
+ * in6addr_loopback address, etc.  For now, just use AF_INET socket.
  */
 int
 rpc_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
 {
-	struct sockaddr_in	sin;
+	struct sockaddr_storage	addr;
+	struct sockaddr_in  *sin  = NULL;
 	struct rpc_portmap	map;
 	struct rpc_clnt		*pmap_clnt;
 	unsigned int		error = 0;
@@ -165,9 +183,12 @@ rpc_register(u32 prog, u32 vers, int pro
 	dprintk("RPC: registering (%d, %d, %d, %d) with portmapper.\n",
 			prog, vers, prot, port);
 
-	sin.sin_family = AF_INET;
-	sin.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
-	if (!(pmap_clnt = pmap_create("localhost", &sin, IPPROTO_UDP))) {
+	sin = (struct sockaddr_in *)&addr;
+
+	sin->sin_family = AF_INET;
+	sin->sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+	if (!(pmap_clnt = pmap_create("localhost", (struct sockaddr *)&addr,
+					IPPROTO_UDP))) {
 		dprintk("RPC: couldn't create pmap client\n");
 		return -EACCES;
 	}
@@ -192,7 +213,7 @@ rpc_register(u32 prog, u32 vers, int pro
 }
 
 static struct rpc_clnt *
-pmap_create(char *hostname, struct sockaddr_in *srvaddr, int proto)
+pmap_create(char *hostname, struct sockaddr *srvaddr, int proto)
 {
 	struct rpc_xprt	*xprt;
 	struct rpc_clnt	*clnt;
@@ -200,7 +221,21 @@ pmap_create(char *hostname, struct socka
 	/* printk("pmap: create xprt\n"); */
 	if (!(xprt = xprt_create_proto(proto, srvaddr, NULL)))
 		return NULL;
-	xprt->addr.sin_port = htons(RPC_PMAP_PORT);
+	switch (srvaddr->sa_family) {
+	case AF_INET:
+		((struct sockaddr_in *)&(xprt->addr))->sin_family = AF_INET;
+		((struct sockaddr_in *)&(xprt->addr))->sin_port =
+			htons(RPC_PMAP_PORT);
+		break;
+	case AF_INET6:
+		((struct sockaddr_in6 *)&(xprt->addr))->sin6_family = AF_INET6;
+		((struct sockaddr_in6 *)&(xprt->addr))->sin6_port =
+			htons(RPC_PMAP_PORT);
+		break;
+	default:
+		printk("%s unknown address family %d\n", __FUNCTION__,
+		      srvaddr->sa_family);
+	}
 
 	/* printk("pmap: create clnt\n"); */
 	clnt = rpc_create_client(xprt, hostname,
diff -Naurp linux-2.5.66/net/sunrpc/rpc_pipe.c linux-2.5.66-NFS_IPV6/net/sunrpc/rpc_pipe.c
--- linux-2.5.66/net/sunrpc/rpc_pipe.c	2003-03-24 14:00:14.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/net/sunrpc/rpc_pipe.c	2003-04-07 17:51:03.000000000 -0700
@@ -272,8 +272,27 @@ rpc_show_info(struct seq_file *m, void *
 	seq_printf(m, "RPC server: %s\n", clnt->cl_server);
 	seq_printf(m, "service: %s (%d) version %d\n", clnt->cl_protname,
 			clnt->cl_prog, clnt->cl_vers);
-	seq_printf(m, "address: %u.%u.%u.%u\n",
-			NIPQUAD(clnt->cl_xprt->addr.sin_addr.s_addr));
+	switch ( clnt->cl_xprt->addr.ss_family ) {
+	case AF_INET:
+		seq_printf(m, "address: %u.%u.%u.%u\n",
+			NIPQUAD(((struct sockaddr_in *)&(clnt->cl_xprt->addr))->sin_addr.s_addr));
+		break;
+	case AF_INET6:
+		seq_printf(m, "address: %x:%x:%x:%x:%x:%x:%x:%x\n",
+			ntohs(((struct sockaddr_in6 *)&(clnt->cl_xprt->addr))->sin6_addr.s6_addr16[0]),
+			ntohs(((struct sockaddr_in6 *)&(clnt->cl_xprt->addr))->sin6_addr.s6_addr16[1]),
+			ntohs(((struct sockaddr_in6 *)&(clnt->cl_xprt->addr))->sin6_addr.s6_addr16[2]),
+			ntohs(((struct sockaddr_in6 *)&(clnt->cl_xprt->addr))->sin6_addr.s6_addr16[3]),
+			ntohs(((struct sockaddr_in6 *)&(clnt->cl_xprt->addr))->sin6_addr.s6_addr16[4]),
+			ntohs(((struct sockaddr_in6 *)&(clnt->cl_xprt->addr))->sin6_addr.s6_addr16[5]),
+			ntohs(((struct sockaddr_in6 *)&(clnt->cl_xprt->addr))->sin6_addr.s6_addr16[6]),
+			ntohs(((struct sockaddr_in6 *)&(clnt->cl_xprt->addr))->sin6_addr.s6_addr16[7]));
+		break;
+	default:
+		printk("RPC: %s unknown address family %d\n", __FUNCTION__,
+			clnt->cl_xprt->addr.ss_family);
+		break;
+	}
 	return 0;
 }
 
diff -Naurp linux-2.5.66/net/sunrpc/sched.c linux-2.5.66-NFS_IPV6/net/sunrpc/sched.c
--- linux-2.5.66/net/sunrpc/sched.c	2003-03-24 14:00:44.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/net/sunrpc/sched.c	2003-04-04 07:48:17.000000000 -0800
@@ -1115,9 +1115,10 @@ void rpc_show_tasks(void)
 		"-rpcwait -action- --exit--\n");
 	alltask_for_each(t, le, &all_tasks)
 		printk("%05d %04d %04x %06d %8p %6d %8p %08ld %8s %8p %8p\n",
-			t->tk_pid, t->tk_msg.rpc_proc->p_proc,
+			t->tk_pid,
+			t->tk_msg.rpc_proc ? t->tk_msg.rpc_proc->p_proc : 0,
 			t->tk_flags, t->tk_status,
-			t->tk_client, t->tk_client->cl_prog,
+			t->tk_client, t->tk_client ? t->tk_client->cl_prog : 0,
 			t->tk_rqstp, t->tk_timeout,
 			t->tk_rpcwait ? rpc_qname(t->tk_rpcwait) : " <NULL> ",
 			t->tk_action, t->tk_exit);
diff -Naurp linux-2.5.66/net/sunrpc/svcauth_unix.c linux-2.5.66-NFS_IPV6/net/sunrpc/svcauth_unix.c
--- linux-2.5.66/net/sunrpc/svcauth_unix.c	2003-03-24 14:00:51.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/net/sunrpc/svcauth_unix.c	2003-04-10 16:19:37.000000000 -0700
@@ -90,7 +90,11 @@ static void svcauth_unix_domain_release(
 struct ip_map {
 	struct cache_head	h;
 	char			*m_class; /* e.g. "nfsd" */
-	struct in_addr		m_addr;
+	sa_family_t		m_family;
+	union {
+		struct in_addr	v4;
+		struct in6_addr	v6;
+	} m_addr;
 	struct unix_domain	*m_client;
 	int			m_add_change;
 };
@@ -109,18 +113,46 @@ void ip_map_put(struct cache_head *item,
 
 static inline int ip_map_hash(struct ip_map *item)
 {
-	return hash_str(item->m_class, IP_HASHBITS) ^ 
-		hash_long((unsigned long)item->m_addr.s_addr, IP_HASHBITS);
+	int ret = 0;
+
+	switch (item->m_family) {
+	case AF_INET:
+		ret = hash_str(item->m_class, IP_HASHBITS) ^ 
+			hash_long(item->m_addr.v4.s_addr, IP_HASHBITS);
+		break;
+	case AF_INET6:
+		ret = hash_str(item->m_class, IP_HASHBITS) ^ 
+			hash_long(item->m_addr.v6.s6_addr32[3], IP_HASHBITS);
+		break;
+	}
+	return ret;
 }
 static inline int ip_map_match(struct ip_map *item, struct ip_map *tmp)
 {
-	return strcmp(tmp->m_class, item->m_class) == 0
-		&& tmp->m_addr.s_addr == item->m_addr.s_addr;
+	if (strcmp(tmp->m_class, item->m_class) ||
+		tmp->m_family != item->m_family)
+		return 0;
+	switch (item->m_family) {
+	case AF_INET:
+		return (tmp->m_addr.v4.s_addr == item->m_addr.v4.s_addr);
+		break;
+	case AF_INET6:
+		return !ipv6_addr_cmp(&tmp->m_addr.v6, &item->m_addr.v6);
+		break;
+	}
 }
 static inline void ip_map_init(struct ip_map *new, struct ip_map *item)
 {
 	new->m_class = strdup(item->m_class);
-	new->m_addr.s_addr = item->m_addr.s_addr;
+	new->m_family = item->m_family;
+	switch (item->m_family) {
+	case AF_INET:
+		new->m_addr.v4.s_addr = item->m_addr.v4.s_addr;
+		break;
+	case AF_INET6:
+		ipv6_addr_copy(&new->m_addr.v6, &item->m_addr.v6);
+		break;
+	}
 }
 static inline void ip_map_update(struct ip_map *new, struct ip_map *item)
 {
@@ -133,29 +165,53 @@ static void ip_map_request(struct cache_
 				  struct cache_head *h,
 				  char **bpp, int *blen)
 {
-	char text_addr[20];
+#ifndef INET6_ADDRSTRLEN
+#define INET6_ADDRSTRLEN 46
+#endif
+	char text_addr[INET6_ADDRSTRLEN];
 	struct ip_map *im = container_of(h, struct ip_map, h);
-	__u32 addr = im->m_addr.s_addr;
-	
-	snprintf(text_addr, 20, "%u.%u.%u.%u",
-		 ntohl(addr) >> 24 & 0xff,
-		 ntohl(addr) >> 16 & 0xff,
-		 ntohl(addr) >>  8 & 0xff,
-		 ntohl(addr) >>  0 & 0xff);
+	char family[5];
+
+	switch (im->m_family) {
+	case AF_INET:
+		snprintf(text_addr, 20, "%u.%u.%u.%u",
+			 ntohl(im->m_addr.v4.s_addr) >> 24 & 0xff,
+			 ntohl(im->m_addr.v4.s_addr) >> 16 & 0xff,
+			 ntohl(im->m_addr.v4.s_addr) >>  8 & 0xff,
+			 ntohl(im->m_addr.v4.s_addr) >>  0 & 0xff);
+		break;
+	case AF_INET6:
+		snprintf(text_addr, INET6_ADDRSTRLEN, "%x:%x:%x:%x:%x:%x:%x:%x",
+			 ntohs(im->m_addr.v6.s6_addr16[0]),
+			 ntohs(im->m_addr.v6.s6_addr16[1]),
+			 ntohs(im->m_addr.v6.s6_addr16[2]),
+			 ntohs(im->m_addr.v6.s6_addr16[3]),
+			 ntohs(im->m_addr.v6.s6_addr16[4]),
+			 ntohs(im->m_addr.v6.s6_addr16[5]),
+			 ntohs(im->m_addr.v6.s6_addr16[6]),
+			 ntohs(im->m_addr.v6.s6_addr16[7]));
+		break;
+	}
 
 	qword_add(bpp, blen, im->m_class);
+	snprintf(family, 5, "%d", im->m_family);
+	qword_add(bpp, blen, family);
 	qword_add(bpp, blen, text_addr);
 	(*bpp)[-1] = '\n';
 }
 
 static struct ip_map *ip_map_lookup(struct ip_map *, int);
+/* function defined with DefineSimpleCacheLookup(ip_map) macro */
+
 static int ip_map_parse(struct cache_detail *cd,
 			  char *mesg, int mlen)
 {
-	/* class ipaddress [domainname] */
+	/* class family ipaddress [domainname] */
 	char class[50], buf[50];
 	int len;
 	int b1,b2,b3,b4;
+	u16 w1,w2,w3,w4,w5,w6,w7,w8;
+	sa_family_t family = AF_INET;
 	char c;
 	struct ip_map ipm, *ipmp;
 	struct auth_domain *dom;
@@ -169,12 +225,28 @@ static int ip_map_parse(struct cache_det
 	len = qword_get(&mesg, class, 50);
 	if (len <= 0) return -EINVAL;
 
-	/* ip address */
+	/* ip address family */
 	len = qword_get(&mesg, buf, 50);
 	if (len <= 0) return -EINVAL;
 
-	if (sscanf(buf, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
+	if (sscanf(buf, "%hu%c", &family, &c) != 1)
 		return -EINVAL;
+
+	/* ip address */
+	len = qword_get(&mesg, buf, 50);
+	if (len <= 0) return -EINVAL;
+
+	switch (family) {
+	case AF_INET:
+		if (sscanf(buf, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
+			return -EINVAL;
+		break;
+	case AF_INET6:
+		if (sscanf(buf, "%hu:%hu:%hu:%hu:%hu:%hu:%hu:%hu%c",
+			   &w1, &w2, &w3, &w4, &w5, &w6, &w7, &w8, &c) != 8)
+			return -EINVAL;
+		break;
+	}
 	
 	expiry = get_expiry(&mesg);
 	if (expiry ==0)
@@ -192,8 +264,23 @@ static int ip_map_parse(struct cache_det
 		dom = NULL;
 
 	ipm.m_class = class;
-	ipm.m_addr.s_addr =
-		htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
+	ipm.m_family = family;
+	switch (family) {
+	case AF_INET:
+		ipm.m_addr.v4.s_addr =
+			htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
+		break;
+	case AF_INET6:
+		ipm.m_addr.v6.s6_addr16[0] = htons(w1);
+		ipm.m_addr.v6.s6_addr16[1] = htons(w2);
+		ipm.m_addr.v6.s6_addr16[2] = htons(w3);
+		ipm.m_addr.v6.s6_addr16[3] = htons(w4);
+		ipm.m_addr.v6.s6_addr16[4] = htons(w5);
+		ipm.m_addr.v6.s6_addr16[5] = htons(w6);
+		ipm.m_addr.v6.s6_addr16[6] = htons(w7);
+		ipm.m_addr.v6.s6_addr16[7] = htons(w8);
+		break;
+	}
 	ipm.h.flags = 0;
 	if (dom)
 		ipm.m_client = container_of(dom, struct unix_domain, h);
@@ -219,23 +306,39 @@ static int ip_map_show(struct seq_file *
 		       char *pbuf)
 {
 	struct ip_map *im;
-	struct in_addr addr;
 
 	if (h == NULL) {
-		seq_puts(m, "#class IP domain\n");
+		seq_puts(m, "#class family IP domain\n");
 		return 0;
 	}
 	im = container_of(h, struct ip_map, h);
-	/* class addr domain */
-	addr = im->m_addr;
-	seq_printf(m, "%s %d.%d.%d.%d %s\n",
-		   im->m_class,
-		   htonl(addr.s_addr) >> 24 & 0xff,
-		   htonl(addr.s_addr) >> 16 & 0xff,
-		   htonl(addr.s_addr) >>  8 & 0xff,
-		   htonl(addr.s_addr) >>  0 & 0xff,
-		   im->m_client->h.name
-		   );
+	/* class family addr domain */
+	switch(im->m_family) {
+	case AF_INET:
+		seq_printf(m, "%s %d %d.%d.%d.%d %s\n",
+			   im->m_class,
+			   im->m_family,
+			   htonl(im->m_addr.v4.s_addr) >> 24 & 0xff,
+			   htonl(im->m_addr.v4.s_addr) >> 16 & 0xff,
+			   htonl(im->m_addr.v4.s_addr) >>  8 & 0xff,
+			   htonl(im->m_addr.v4.s_addr) >>  0 & 0xff,
+			   im->m_client->h.name);
+		break;
+	case AF_INET6:
+		seq_printf(m, "%s %d %x:%x:%x:%x:%x:%x:%x:%x %s\n",
+			   im->m_class,
+			   im->m_family,
+			   htons(im->m_addr.v6.s6_addr16[0]),
+			   htons(im->m_addr.v6.s6_addr16[1]),
+			   htons(im->m_addr.v6.s6_addr16[2]),
+			   htons(im->m_addr.v6.s6_addr16[3]),
+			   htons(im->m_addr.v6.s6_addr16[4]),
+			   htons(im->m_addr.v6.s6_addr16[5]),
+			   htons(im->m_addr.v6.s6_addr16[6]),
+			   htons(im->m_addr.v6.s6_addr16[7]),
+			   im->m_client->h.name);
+		break;
+	}
 	return 0;
 }
 	
@@ -253,7 +356,11 @@ struct cache_detail ip_map_cache = {
 static DefineSimpleCacheLookup(ip_map)
 

+#ifdef CONFIG_NFS_IPV6
+int auth_unix_add_addr(struct nfs_addr addr, struct auth_domain *dom)
+#else
 int auth_unix_add_addr(struct in_addr addr, struct auth_domain *dom)
+#endif
 {
 	struct unix_domain *udom;
 	struct ip_map ip, *ipmp;
@@ -262,7 +369,20 @@ int auth_unix_add_addr(struct in_addr ad
 		return -EINVAL;
 	udom = container_of(dom, struct unix_domain, h);
 	ip.m_class = "nfsd";
-	ip.m_addr = addr;
+#ifdef CONFIG_NFS_IPV6
+	ip.m_family = addr.family;
+	switch ( addr.family ) {
+	case AF_INET:
+		ip.m_addr.v4 = addr.addr_u.v4;
+		break;
+	case AF_INET6:
+		ipv6_addr_copy(&ip.m_addr.v6, &addr.addr_u.v6);
+		break;
+	}
+#else
+	ip.m_family = AF_INET;
+	ip.m_addr.v4 = addr;
+#endif
 	ip.m_client = udom;
 	ip.m_add_change = udom->addr_changes+1;
 	ip.h.flags = 0;
@@ -287,13 +407,26 @@ int auth_unix_forget_old(struct auth_dom
 	return 0;
 }
 
-struct auth_domain *auth_unix_lookup(struct in_addr addr)
+struct auth_domain *auth_unix_lookup(struct sockaddr *addr)
 {
 	struct ip_map key, *ipm;
 	struct auth_domain *rv;
 
 	key.m_class = "nfsd";
-	key.m_addr = addr;
+	key.m_family = addr->sa_family;
+	switch ( addr->sa_family ) {
+	case AF_INET:
+		key.m_addr.v4 = ((struct sockaddr_in *)addr)->sin_addr;
+		break;
+	case AF_INET6:
+		ipv6_addr_copy(&key.m_addr.v6,
+				&((struct sockaddr_in6 *)addr)->sin6_addr);
+		break;
+	default:
+		printk("%s unknown address family %d\n", __FUNCTION__,
+		      addr->sa_family);
+		break;
+	}
 
 	ipm = ip_map_lookup(&key, 0);
 
@@ -352,7 +485,21 @@ svcauth_null_accept(struct svc_rqst *rqs
 	svc_putu32(resv, 0);
 
 	key.m_class = rqstp->rq_server->sv_program->pg_class;
-	key.m_addr = rqstp->rq_addr.sin_addr;
+	switch ( rqstp->rq_addr.ss_family ) {
+	case AF_INET:
+		key.m_family = AF_INET;
+		key.m_addr.v4 =
+			((struct sockaddr_in *)&(rqstp->rq_addr))->sin_addr;
+		break;
+	case AF_INET6:
+		key.m_family = AF_INET6;
+		ipv6_addr_copy(&key.m_addr.v6,
+			&((struct sockaddr_in6 *)&(rqstp->rq_addr))->sin6_addr);
+		break;
+	default:
+		printk("%s unknown address family %d\n", __FUNCTION__,
+		      rqstp->rq_addr.ss_family);
+	}
 
 	ipm = ip_map_lookup(&key, 0);
 
@@ -443,7 +590,21 @@ svcauth_unix_accept(struct svc_rqst *rqs
 

 	key.m_class = rqstp->rq_server->sv_program->pg_class;
-	key.m_addr = rqstp->rq_addr.sin_addr;
+	switch ( rqstp->rq_addr.ss_family ) {
+	case AF_INET:
+		key.m_family = AF_INET;
+		key.m_addr.v4 = 
+			((struct sockaddr_in *)&(rqstp->rq_addr))->sin_addr;
+		break;
+	case AF_INET6:
+		key.m_family = AF_INET6;
+		ipv6_addr_copy(&key.m_addr.v6,
+			&((struct sockaddr_in6 *)&(rqstp->rq_addr))->sin6_addr);
+		break;
+	default:
+		printk("%s unknown address family %d\n", __FUNCTION__,
+		      rqstp->rq_addr.ss_family);
+	}
 

 	ipm = ip_map_lookup(&key, 0);
diff -Naurp linux-2.5.66/net/sunrpc/svcsock.c linux-2.5.66-NFS_IPV6/net/sunrpc/svcsock.c
--- linux-2.5.66/net/sunrpc/svcsock.c	2003-03-24 14:00:00.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/net/sunrpc/svcsock.c	2003-04-07 17:53:54.000000000 -0700
@@ -24,6 +24,7 @@
 #include <linux/fcntl.h>
 #include <linux/net.h>
 #include <linux/in.h>
+#include <linux/in6.h>
 #include <linux/inet.h>
 #include <linux/udp.h>
 #include <linux/tcp.h>
@@ -35,6 +36,7 @@
 #include <net/sock.h>
 #include <net/checksum.h>
 #include <net/ip.h>
+#include <net/ipv6.h>
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
 
@@ -337,6 +339,8 @@ svc_sendto(struct svc_rqst *rqstp, struc
 	struct page	**ppage = xdr->pages;
 	size_t		base = xdr->page_base;
 	unsigned int	pglen = xdr->page_len;
+	struct sockaddr_in  *sin  = NULL;
+	struct sockaddr_in6 *sin6 = NULL;
 	unsigned int	flags = MSG_MORE;
 
 	slen = xdr->len;
@@ -398,9 +402,37 @@ svc_sendto(struct svc_rqst *rqstp, struc
 out:
 	up(&svsk->sk_sem);
 
-	dprintk("svc: socket %p sendto([%p %Zu... ], %d) = %d (addr %x)\n",
-			rqstp->rq_sock, xdr->head[0].iov_base, xdr->head[0].iov_len, xdr->len, len,
-		rqstp->rq_addr.sin_addr.s_addr);
+	switch ( rqstp->rq_addr.ss_family ) {
+	case AF_INET:
+		sin = (struct sockaddr_in *)&(rqstp->rq_addr);
+		dprintk("svc: socket %p sendto([%p %Zu... ], %d) = %d "
+			"(addr %08x)\n",
+			rqstp->rq_sock, xdr->head[0].iov_base,
+			xdr->head[0].iov_len, xdr->len, len,
+			sin->sin_addr.s_addr);
+		break;
+
+	case AF_INET6:
+		sin6 = (struct sockaddr_in6 *)&(rqstp->rq_addr);
+		dprintk("svc: socket %p sendto([%p %Zu... ], %d) = %d "
+			"(addr %x:%x:%x:%x:%x:%x:%x:%x)\n",
+			rqstp->rq_sock, xdr->head[0].iov_base,
+			xdr->head[0].iov_len, xdr->len, len,
+			ntohs(sin6->sin6_addr.s6_addr16[0]),
+			ntohs(sin6->sin6_addr.s6_addr16[1]),
+			ntohs(sin6->sin6_addr.s6_addr16[2]),
+			ntohs(sin6->sin6_addr.s6_addr16[3]),
+			ntohs(sin6->sin6_addr.s6_addr16[4]),
+			ntohs(sin6->sin6_addr.s6_addr16[5]),
+			ntohs(sin6->sin6_addr.s6_addr16[6]),
+			ntohs(sin6->sin6_addr.s6_addr16[7]));
+		break;
+
+	default:
+		printk("svc: %s unknown address family %d\n", __FUNCTION__,
+			rqstp->rq_addr.ss_family);
+		break;
+	}
 
 	return len;
 }
@@ -541,6 +573,8 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	struct svc_serv	*serv = svsk->sk_server;
 	struct sk_buff	*skb;
 	int		err, len;
+	struct sockaddr_in  *sin  = NULL;
+	struct sockaddr_in6 *sin6 = NULL;
 
 	if (test_and_clear_bit(SK_CHNGBUF, &svsk->sk_flags))
 	    /* udp sockets need large rcvbuf as all pending
@@ -571,9 +605,26 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_prot        = IPPROTO_UDP;
 
 	/* Get sender address */
-	rqstp->rq_addr.sin_family = AF_INET;
-	rqstp->rq_addr.sin_port = skb->h.uh->source;
-	rqstp->rq_addr.sin_addr.s_addr = skb->nh.iph->saddr;
+	switch ( skb->sk->family ) {
+	case AF_INET:
+		sin = (struct sockaddr_in *)&(rqstp->rq_addr);
+		sin->sin_family      = AF_INET;
+		sin->sin_port        = skb->h.uh->source;
+		sin->sin_addr.s_addr = skb->nh.iph->saddr;
+		break;
+
+	case AF_INET6:
+		sin6 = (struct sockaddr_in6 *)&(rqstp->rq_addr);
+		sin6->sin6_family = AF_INET6;
+		sin6->sin6_port   = skb->h.uh->source;
+		ipv6_addr_copy(&sin6->sin6_addr, &((skb->nh.ipv6h)->saddr));
+		break;
+
+	default:
+		printk("svc: %s unknown address family %d\n", __FUNCTION__,
+			skb->sk->family);
+		break;
+	}
 
 	if (skb_is_nonlinear(skb)) {
 		/* we have to copy */
@@ -725,7 +776,9 @@ svc_tcp_data_ready(struct sock *sk, int 
 static void
 svc_tcp_accept(struct svc_sock *svsk)
 {
-	struct sockaddr_in sin;
+	struct sockaddr_storage addr;
+	struct sockaddr_in  *sin  = NULL;
+	struct sockaddr_in6 *sin6 = NULL;
 	struct svc_serv	*serv = svsk->sk_server;
 	struct socket	*sock = svsk->sk_sock;
 	struct socket	*newsock;
@@ -756,8 +809,8 @@ svc_tcp_accept(struct svc_sock *svsk)
 	set_bit(SK_CONN, &svsk->sk_flags);
 	svc_sock_enqueue(svsk);
 
-	slen = sizeof(sin);
-	err = ops->getname(newsock, (struct sockaddr *) &sin, &slen, 1);
+	slen = sizeof(addr);
+	err = ops->getname(newsock, (struct sockaddr *) &addr, &slen, 1);
 	if (err < 0) {
 		if (net_ratelimit())
 			printk(KERN_WARNING "%s: peername failed (err %d)!\n",
@@ -769,15 +822,65 @@ svc_tcp_accept(struct svc_sock *svsk)
 	 * hosts here, but when we get encription, the IP of the host won't
 	 * tell us anything. For now just warn about unpriv connections.
 	 */
-	if (ntohs(sin.sin_port) >= 1024) {
-		dprintk(KERN_WARNING
-			"%s: connect from unprivileged port: %u.%u.%u.%u:%d\n",
-			serv->sv_name, 
-			NIPQUAD(sin.sin_addr.s_addr), ntohs(sin.sin_port));
-	}
+	switch ( addr.ss_family ) {
+	case AF_INET:
+		sin = (struct sockaddr_in *)&addr;
+		if (ntohs(sin->sin_port) >= 1024) {
+			dprintk(KERN_WARNING
+				"%s: connect from unprivileged port: "
+				"%u.%u.%u.%u:%d\n",
+				serv->sv_name, 
+				NIPQUAD(sin->sin_addr.s_addr),
+				ntohs(sin->sin_port));
+		}
+		else
+			dprintk("%s: connect from %u.%u.%u.%u:%d\n",
+				serv->sv_name,
+				NIPQUAD(sin->sin_addr.s_addr),
+				ntohs(sin->sin_port));
+		break;
 
-	dprintk("%s: connect from %u.%u.%u.%u:%04x\n", serv->sv_name,
-			NIPQUAD(sin.sin_addr.s_addr), ntohs(sin.sin_port));
+	case AF_INET6:
+		sin6 = (struct sockaddr_in6 *)&addr;
+		if (ntohs(sin6->sin6_port) >= 1024) {
+			/* FIXME 
+			 * replace with NIP6 if/when available in a common
+			 * networking header
+			 */
+			dprintk(KERN_WARNING
+				"%s: connect from unprivileged port: "
+				"%x:%x:%x:%x:%x:%x:%x:%x port %d\n",
+				serv->sv_name, 
+				ntohs(sin6->sin6_addr.s6_addr16[0]),
+				ntohs(sin6->sin6_addr.s6_addr16[1]),
+				ntohs(sin6->sin6_addr.s6_addr16[2]),
+				ntohs(sin6->sin6_addr.s6_addr16[3]),
+				ntohs(sin6->sin6_addr.s6_addr16[4]),
+				ntohs(sin6->sin6_addr.s6_addr16[5]),
+				ntohs(sin6->sin6_addr.s6_addr16[6]),
+				ntohs(sin6->sin6_addr.s6_addr16[7]),
+				ntohs(sin6->sin6_port));
+		}
+		else
+			dprintk("%s: connect from "
+				"%x:%x:%x:%x:%x:%x:%x:%x port %d\n",
+				serv->sv_name,
+				ntohs(sin6->sin6_addr.s6_addr16[0]),
+				ntohs(sin6->sin6_addr.s6_addr16[1]),
+				ntohs(sin6->sin6_addr.s6_addr16[2]),
+				ntohs(sin6->sin6_addr.s6_addr16[3]),
+				ntohs(sin6->sin6_addr.s6_addr16[4]),
+				ntohs(sin6->sin6_addr.s6_addr16[5]),
+				ntohs(sin6->sin6_addr.s6_addr16[6]),
+				ntohs(sin6->sin6_addr.s6_addr16[7]),
+				ntohs(sin->sin_port));
+		break;
+
+	default:
+		printk("svc: %s unknown address family %d\n", __FUNCTION__,
+			addr.ss_family);
+		break;
+	}
 
 	/* make sure that a write doesn't block forever when
 	 * low on memory
@@ -1188,7 +1291,20 @@ svc_recv(struct svc_serv *serv, struct s
 		spin_unlock_bh(&serv->sv_lock);
 	}
 
-	rqstp->rq_secure  = ntohs(rqstp->rq_addr.sin_port) < 1024;
+	switch ( rqstp->rq_addr.ss_family ) {
+	case AF_INET:
+		rqstp->rq_secure = ntohs(((struct sockaddr_in *)&(rqstp->rq_addr))->sin_port) < 1024;
+		break;
+
+	case AF_INET6:
+		rqstp->rq_secure = ntohs(((struct sockaddr_in6 *)&(rqstp->rq_addr))->sin6_port) < 1024;
+		break;
+
+	default:
+		printk("svc: %s unknown address family %d\n", __FUNCTION__,
+			rqstp->rq_addr.ss_family);
+		break;
+	}
 	rqstp->rq_userset = 0;
 	rqstp->rq_chandle.defer = svc_defer;
 
@@ -1312,17 +1428,47 @@ svc_setup_socket(struct svc_serv *serv, 
  * Create socket for RPC service.
  */
 static int
-svc_create_socket(struct svc_serv *serv, int protocol, struct sockaddr_in *sin)
+svc_create_socket(struct svc_serv *serv, int protocol, struct sockaddr *addr)
 {
 	struct svc_sock	*svsk;
 	struct socket	*sock;
 	int		error;
 	int		type;
-
-	dprintk("svc: svc_create_socket(%s, %d, %u.%u.%u.%u:%d)\n",
-				serv->sv_program->pg_name, protocol,
-				NIPQUAD(sin->sin_addr.s_addr),
-				ntohs(sin->sin_port));
+	u32		family = PF_UNSPEC;
+	struct sockaddr_in  *sin  = NULL;
+	struct sockaddr_in6 *sin6 = NULL;
+
+	switch ( addr->sa_family ) {
+	case AF_INET:
+		sin = (struct sockaddr_in *)addr;
+		dprintk("svc: svc_create_socket(%s, %d, %u.%u.%u.%u:%d)\n",
+			serv->sv_program->pg_name, protocol,
+			NIPQUAD(sin->sin_addr.s_addr),
+			ntohs(sin->sin_port));
+		family = PF_INET;
+		break;
+
+	case AF_INET6:
+		sin6 = (struct sockaddr_in6 *)addr;
+		dprintk("svc: svc_create_socket(%s, %d, %x:%x:%x:%x:%x:%x:%x:%x port %d)\n",
+			serv->sv_program->pg_name, protocol,
+			ntohs(sin6->sin6_addr.s6_addr16[0]),
+			ntohs(sin6->sin6_addr.s6_addr16[1]),
+			ntohs(sin6->sin6_addr.s6_addr16[2]),
+			ntohs(sin6->sin6_addr.s6_addr16[3]),
+			ntohs(sin6->sin6_addr.s6_addr16[4]),
+			ntohs(sin6->sin6_addr.s6_addr16[5]),
+			ntohs(sin6->sin6_addr.s6_addr16[6]),
+			ntohs(sin6->sin6_addr.s6_addr16[7]),
+			ntohs(sin6->sin6_port));
+		family = PF_INET6;
+		break;
+
+	default:
+		printk("svc: %s unknown address family %d\n", __FUNCTION__,
+			addr->sa_family);
+		break;
+	}
 
 	if (protocol != IPPROTO_UDP && protocol != IPPROTO_TCP) {
 		printk(KERN_WARNING "svc: only UDP and TCP "
@@ -1331,13 +1477,24 @@ svc_create_socket(struct svc_serv *serv,
 	}
 	type = (protocol == IPPROTO_UDP)? SOCK_DGRAM : SOCK_STREAM;
 
-	if ((error = sock_create(PF_INET, type, protocol, &sock)) < 0)
+	if ((error = sock_create(family, type, protocol, &sock)) < 0)
 		return error;
 
-	if (sin != NULL) {
+	if (addr != NULL) {
 		sock->sk->reuse = 1; /* allow address reuse */
-		error = sock->ops->bind(sock, (struct sockaddr *) sin,
+		switch ( addr->sa_family ) {
+		case AF_INET:
+			error = sock->ops->bind(sock, (struct sockaddr *) sin,
 						sizeof(*sin));
+			break;
+		case AF_INET6:
+			error = sock->ops->bind(sock, (struct sockaddr *) sin6,
+						sizeof(*sin6));
+			break;
+		default:
+			printk("%s unknown address family %d\n", __FUNCTION__,
+			      addr->sa_family);
+		}
 		if (error < 0)
 			goto bummer;
 	}
@@ -1399,13 +1556,32 @@ svc_delete_socket(struct svc_sock *svsk)
 int
 svc_makesock(struct svc_serv *serv, int protocol, unsigned short port)
 {
-	struct sockaddr_in	sin;
+	struct sockaddr_storage	addr;
+	struct sockaddr_in      *sin  = NULL;
+	struct sockaddr_in6     *sin6 = NULL;
+	int			error;
+
+	/* create IPv4 socket */
+	dprintk("svc: creating ipv4 socket proto = %d\n", protocol);
+	memset(&addr, 0, sizeof(struct sockaddr_storage));
+	sin                  = (struct sockaddr_in *)&addr;
+	sin->sin_family      = AF_INET;
+	sin->sin_addr.s_addr = INADDR_ANY;
+	sin->sin_port        = htons(port);
+	if (error = svc_create_socket(serv, protocol, (struct sockaddr *)&addr))
+		return error;
 
-	dprintk("svc: creating socket proto = %d\n", protocol);
-	sin.sin_family      = AF_INET;
-	sin.sin_addr.s_addr = INADDR_ANY;
-	sin.sin_port        = htons(port);
-	return svc_create_socket(serv, protocol, &sin);
+#ifdef CONFIG_NFS_IPV6
+	/* create IPv6 socket */
+	dprintk("svc: creating ipv6 socket proto = %d\n", protocol);
+	memset(&addr, 0, sizeof(struct sockaddr_storage));
+	sin6                 = (struct sockaddr_in6 *)&addr;
+	sin6->sin6_family    = AF_INET6;
+	sin6->sin6_port      = htons(port);
+	ipv6_addr_copy(&sin6->sin6_addr, &ip6addr_any);
+	error = svc_create_socket(serv, protocol, (struct sockaddr *)&addr);
+#endif
+	return error;
 }
 
 /*
diff -Naurp linux-2.5.66/net/sunrpc/xprt.c linux-2.5.66-NFS_IPV6/net/sunrpc/xprt.c
--- linux-2.5.66/net/sunrpc/xprt.c	2003-03-24 14:00:55.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/net/sunrpc/xprt.c	2003-04-07 17:48:42.000000000 -0700
@@ -86,9 +86,10 @@ static void	xprt_request_init(struct rpc
 static inline void	do_xprt_reserve(struct rpc_task *);
 static void	xprt_disconnect(struct rpc_xprt *);
 static void	xprt_conn_status(struct rpc_task *task);
-static struct rpc_xprt * xprt_setup(int proto, struct sockaddr_in *ap,
+static struct rpc_xprt * xprt_setup(int proto, struct sockaddr *ap,
 						struct rpc_timeout *to);
-static struct socket *xprt_create_socket(int, struct rpc_timeout *, int);
+static struct socket *xprt_create_socket(sa_family_t, int,
+						struct rpc_timeout *, int);
 static void	xprt_bind_socket(struct rpc_xprt *, struct socket *);
 static int      __xprt_get_cong(struct rpc_xprt *, struct rpc_task *);
 
@@ -421,9 +422,22 @@ xprt_connect(struct rpc_task *task)
 		task->tk_status = -EIO;
 		return;
 	}
-	if (!xprt->addr.sin_port) {
-		task->tk_status = -EIO;
-		return;
+	switch ( xprt->addr.ss_family ) {
+	case AF_INET:
+		if (!((struct sockaddr_in *)&(xprt->addr))->sin_port) {
+			task->tk_status = -EIO;
+			return;
+		}
+		break;
+	case AF_INET6:
+		if (!((struct sockaddr_in6 *)&(xprt->addr))->sin6_port) {
+			task->tk_status = -EIO;
+			return;
+		}
+		break;
+	default:
+		printk("%s unknown address family %d\n", __FUNCTION__,
+		      xprt->addr.ss_family);
 	}
 	if (!xprt_lock_write(xprt, task))
 		return;
@@ -435,7 +449,8 @@ xprt_connect(struct rpc_task *task)
 	 * Start by resetting any existing state.
 	 */
 	xprt_close(xprt);
-	if (!(sock = xprt_create_socket(xprt->prot, &xprt->timeout, xprt->resvport))) {
+	if (!(sock = xprt_create_socket(xprt->addr.ss_family, xprt->prot,
+					&xprt->timeout, xprt->resvport))) {
 		/* couldn't create socket or bind to reserved port;
 		 * this is likely a permanent error, so cause an abort */
 		task->tk_status = -EIO;
@@ -1370,7 +1385,7 @@ xprt_set_timeout(struct rpc_timeout *to,
  * Initialize an RPC client
  */
 static struct rpc_xprt *
-xprt_setup(int proto, struct sockaddr_in *ap, struct rpc_timeout *to)
+xprt_setup(int proto, struct sockaddr *ap, struct rpc_timeout *to)
 {
 	struct rpc_xprt	*xprt;
 	struct rpc_rqst	*req;
@@ -1383,7 +1398,7 @@ xprt_setup(int proto, struct sockaddr_in
 		return NULL;
 	memset(xprt, 0, sizeof(*xprt)); /* Nnnngh! */
 
-	xprt->addr = *ap;
+	xprt->addr = *((struct sockaddr_storage *)ap);
 	xprt->prot = proto;
 	xprt->stream = (proto == IPPROTO_TCP)? 1 : 0;
 	if (xprt->stream) {
@@ -1426,16 +1441,40 @@ xprt_setup(int proto, struct sockaddr_in
 static inline int
 xprt_bindresvport(struct socket *sock)
 {
-	struct sockaddr_in myaddr;
-	int		err, port;
+	struct sockaddr_in	sin;
+	int			err, port;
+
+	memset(&sin, 0, sizeof(sin));
+	sin.sin_family = AF_INET;
+	port = 800;
+	do {
+		sin.sin_port = htons(port);
+		err = sock->ops->bind(sock, (struct sockaddr *) &sin,
+						sizeof(sin));
+	} while (err == -EADDRINUSE && --port > 0);
+
+	if (err < 0)
+		printk("RPC: Can't bind to reserved port (%d).\n", -err);
+
+	return err;
+}
+
+/*
+ * Bind to a reserved port - IPv6 version
+ */
+static inline int
+xprt_bindresvport6(struct socket *sock)
+{
+	struct sockaddr_in6	sin6;
+	int                     err, port;
 
-	memset(&myaddr, 0, sizeof(myaddr));
-	myaddr.sin_family = AF_INET;
+	memset(&sin6, 0, sizeof(sin6));
+	sin6.sin6_family = AF_INET6;
 	port = 800;
 	do {
-		myaddr.sin_port = htons(port);
-		err = sock->ops->bind(sock, (struct sockaddr *) &myaddr,
-						sizeof(myaddr));
+		sin6.sin6_port = htons(port);
+		err = sock->ops->bind(sock, (struct sockaddr *) &sin6,
+						sizeof(sin6));
 	} while (err == -EADDRINUSE && --port > 0);
 
 	if (err < 0)
@@ -1502,7 +1541,7 @@ xprt_sock_setbufsize(struct rpc_xprt *xp
  * and connect stream sockets.
  */
 static struct socket *
-xprt_create_socket(int proto, struct rpc_timeout *to, int resvport)
+xprt_create_socket(sa_family_t family, int proto, struct rpc_timeout *to, int resvport)
 {
 	struct socket	*sock;
 	int		type, err;
@@ -1512,13 +1551,14 @@ xprt_create_socket(int proto, struct rpc
 
 	type = (proto == IPPROTO_UDP)? SOCK_DGRAM : SOCK_STREAM;
 
-	if ((err = sock_create(PF_INET, type, proto, &sock)) < 0) {
+	if ((err = sock_create(family, type, proto, &sock)) < 0) {
 		printk("RPC: can't create socket (%d).\n", -err);
 		goto failed;
 	}
 
 	/* If the caller has the capability, bind to a reserved port */
-	if (resvport && xprt_bindresvport(sock) < 0) {
+	if (resvport && ((family == AF_INET)? (xprt_bindresvport(sock) < 0) :
+					(xprt_bindresvport6(sock) < 0))) {
 		printk("RPC: can't bind to reserved port.\n");
 		goto failed;
 	}
@@ -1534,7 +1574,7 @@ failed:
  * Create an RPC client transport given the protocol and peer address.
  */
 struct rpc_xprt *
-xprt_create_proto(int proto, struct sockaddr_in *sap, struct rpc_timeout *to)
+xprt_create_proto(int proto, struct sockaddr *sap, struct rpc_timeout *to)
 {
 	struct rpc_xprt	*xprt;
 
@@ -1546,7 +1586,8 @@ xprt_create_proto(int proto, struct sock
 	if (!xprt->stream) {
 		struct socket *sock;
 
-		sock = xprt_create_socket(proto, to, xprt->resvport);
+		sock = xprt_create_socket(sap->sa_family, proto,
+					to, xprt->resvport);
 		if (!sock)
 			goto out_bad;
 		xprt_bind_socket(xprt, sock);
diff -Naurp linux-2.5.66/include/linux/sunrpc/clnt.h linux-2.5.66-NFS_IPV6/include/linux/sunrpc/clnt.h
--- linux-2.5.66/include/linux/sunrpc/clnt.h	2003-03-24 14:00:49.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/include/linux/sunrpc/clnt.h	2003-04-07 17:41:13.000000000 -0700
@@ -142,7 +142,7 @@ extern void rpciod_wake_up(void);
 /*
  * Helper function for NFSroot support
  */
-int		rpc_getport_external(struct sockaddr_in *, __u32, __u32, int);
+int		rpc_getport_external(struct sockaddr *, __u32, __u32, int);
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
diff -Naurp linux-2.5.66/include/linux/sunrpc/svcauth.h linux-2.5.66-NFS_IPV6/include/linux/sunrpc/svcauth.h
--- linux-2.5.66/include/linux/sunrpc/svcauth.h	2003-03-24 14:00:19.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/include/linux/sunrpc/svcauth.h	2003-04-07 17:41:42.000000000 -0700
@@ -15,6 +15,7 @@
 #include <linux/sunrpc/msg_prot.h>
 #include <linux/sunrpc/cache.h>
 #include <linux/hash.h>
+#include <net/ipv6.h>
 
 struct svc_cred {
 	uid_t			cr_uid;
@@ -106,10 +107,14 @@ extern void	svc_auth_unregister(rpc_auth
 
 extern struct auth_domain *unix_domain_find(char *name);
 extern void auth_domain_put(struct auth_domain *item);
+#ifdef CONFIG_NFS_IPV6
+extern int auth_unix_add_addr(struct nfs_addr addr, struct auth_domain *dom);
+#else
 extern int auth_unix_add_addr(struct in_addr addr, struct auth_domain *dom);
+#endif
 extern struct auth_domain *auth_domain_lookup(struct auth_domain *item, int set);
 extern struct auth_domain *auth_domain_find(char *name);
-extern struct auth_domain *auth_unix_lookup(struct in_addr addr);
+extern struct auth_domain *auth_unix_lookup(struct sockaddr *addr);
 extern int auth_unix_forget_old(struct auth_domain *dom);
 extern void svcauth_unix_purge(void);
 
diff -Naurp linux-2.5.66/include/linux/sunrpc/svc.h linux-2.5.66-NFS_IPV6/include/linux/sunrpc/svc.h
--- linux-2.5.66/include/linux/sunrpc/svc.h	2003-03-24 14:00:44.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/include/linux/sunrpc/svc.h	2003-04-07 17:41:29.000000000 -0700
@@ -11,6 +11,7 @@
 #define SUNRPC_SVC_H
 
 #include <linux/in.h>
+#include <linux/in6.h>
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/svcauth.h>
@@ -100,7 +101,7 @@ static inline void svc_putu32(struct iov
 struct svc_rqst {
 	struct list_head	rq_list;	/* idle list */
 	struct svc_sock *	rq_sock;	/* socket */
-	struct sockaddr_in	rq_addr;	/* peer address */
+	struct sockaddr_storage	rq_addr;	/* peer address */
 	int			rq_addrlen;
 
 	struct svc_serv *	rq_server;	/* RPC service definition */
@@ -218,7 +219,7 @@ static inline void svc_free_allpages(str
 struct svc_deferred_req {
 	struct svc_serv		*serv;
 	u32			prot;	/* protocol (UDP or TCP) */
-	struct sockaddr_in	addr;
+	struct sockaddr_storage	addr;
 	struct svc_sock		*svsk;	/* where reply must go */
 	struct cache_deferred_req handle;
 	int			argslen;
diff -Naurp linux-2.5.66/include/linux/sunrpc/xprt.h linux-2.5.66-NFS_IPV6/include/linux/sunrpc/xprt.h
--- linux-2.5.66/include/linux/sunrpc/xprt.h	2003-03-24 14:01:13.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/include/linux/sunrpc/xprt.h	2003-04-07 17:42:07.000000000 -0700
@@ -12,6 +12,7 @@
 #include <linux/uio.h>
 #include <linux/socket.h>
 #include <linux/in.h>
+#include <linux/in6.h>
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/xdr.h>
 
@@ -128,7 +129,7 @@ struct rpc_xprt {
 	struct sock *		inet;		/* INET layer */
 
 	struct rpc_timeout	timeout;	/* timeout parms */
-	struct sockaddr_in	addr;		/* server address */
+	struct sockaddr_storage	addr;		/* server address */
 	int			prot;		/* IP protocol */
 
 	unsigned long		cong;		/* current congestion */
@@ -178,7 +179,7 @@ struct rpc_xprt {
 
 #ifdef __KERNEL__
 
-struct rpc_xprt *	xprt_create_proto(int proto, struct sockaddr_in *addr,
+struct rpc_xprt *	xprt_create_proto(int proto, struct sockaddr *addr,
 					struct rpc_timeout *toparms);
 int			xprt_destroy(struct rpc_xprt *);
 void			xprt_shutdown(struct rpc_xprt *);

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
