From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH 3/3] NLM lock failover
Date: Mon, 31 Jul 2006 22:09:53 -0400
Message-ID: <1154398193.3378.27.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-hJyCCkahRk11YJhhRdP8"
Cc: cluster-devel@redhat.com, lhh@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7jWY-0007IK-9F
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 18:58:22 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G7jWY-0005Xf-BP
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 18:58:22 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k711wKft031780
	for <nfs@lists.sourceforge.net>; Mon, 31 Jul 2006 21:58:20 -0400
To: nfs@lists.sourceforge.net
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


--=-hJyCCkahRk11YJhhRdP8
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This kernel patch is tested out together with nfs-utils-1.0.8-rc4 and
nfs-utils-lib-1.0.8. No changes are required for these two user mode
packages. The kernel changes enable rpc.statd to add the correct taken-
over IPv4 address in standard dot notation into the 3rd parameter of
ha_callout program. Check out "man rpc.statd" for details.

Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
Signed-off-by: Lon Hohberger <lhh@redhat.com>

fs/lockd/host.c                |    8 ++++++--
fs/lockd/mon.c                 |   15 ++++++++++-----
fs/lockd/svc4proc.c            |    3 ++-
fs/lockd/svcproc.c             |    3 ++-
include/linux/lockd/lockd.h    |    5 +++--
include/linux/lockd/sm_inter.h |    1 +
include/linux/sunrpc/svc.h     |    7 ++++---
7 files changed, 28 insertions(+), 14 deletions(-)




--=-hJyCCkahRk11YJhhRdP8
Content-Disposition: attachment; filename=gfs_statd.patch
Content-Type: text/x-patch; name=gfs_statd.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- linux-2/include/linux/sunrpc/svc.h	2006-07-28 15:50:20.000000000 -0400
+++ linux-3/include/linux/sunrpc/svc.h	2006-07-29 00:52:33.000000000 -0400
@@ -101,8 +101,9 @@ static inline void svc_putu32(struct kve
 	*vp = val;
 	iov->iov_len += sizeof(u32);
 }
-
 	
+typedef __u32	svc_addr_t;
+
 /*
  * The context of a single thread, including the request currently being
  * processed.
@@ -138,8 +139,8 @@ struct svc_rqst {
 	unsigned short
 				rq_secure  : 1;	/* secure port */
 
-
-	__u32			rq_daddr;	/* dest addr of request - reply from here */
+	svc_addr_t		rq_daddr;	/* dest addr of request 
+						   - reply from here */
 
 	void *			rq_argp;	/* decoded arguments */
 	void *			rq_resp;	/* xdr'd results */
--- linux-2/include/linux/lockd/lockd.h	2006-07-28 15:51:49.000000000 -0400
+++ linux-3/include/linux/lockd/lockd.h	2006-07-28 15:53:36.000000000 -0400
@@ -39,12 +39,13 @@
 struct nlm_host {
 	struct nlm_host *	h_next;		/* linked list (hash table) */
 	struct sockaddr_in	h_addr;		/* peer address */
+	svc_addr_t		h_server;    	/* server ip for NLM failover */
 	struct rpc_clnt	*	h_rpcclnt;	/* RPC client to talk to peer */
 	char			h_name[20];	/* remote hostname */
 	u32			h_version;	/* interface version */
 	unsigned short		h_proto;	/* transport proto */
 	unsigned short		h_reclaiming : 1,
-				h_server     : 1, /* server side, not client side */
+				h_where      : 1,	
 				h_inuse      : 1,
 				h_killed     : 1,
 				h_monitored  : 1;
@@ -180,7 +181,7 @@ int		  nlmclnt_reclaim(struct nlm_host *
  */
 struct nlm_host * nlmclnt_lookup_host(struct sockaddr_in *, int, int);
 struct nlm_host * nlmsvc_lookup_host(struct svc_rqst *);
-struct nlm_host * nlm_lookup_host(int server, struct sockaddr_in *, int, int);
+struct nlm_host * nlm_lookup_host(svc_addr_t server, struct sockaddr_in *, int, int);
 struct rpc_clnt * nlm_bind_host(struct nlm_host *);
 void		  nlm_rebind_host(struct nlm_host *);
 struct nlm_host * nlm_get_host(struct nlm_host *);
--- linux-2/include/linux/lockd/sm_inter.h	2006-07-28 15:50:20.000000000 -0400
+++ linux-3/include/linux/lockd/sm_inter.h	2006-07-28 15:53:36.000000000 -0400
@@ -25,6 +25,7 @@
  */
 struct nsm_args {
 	u32		addr;		/* remote address */
+	u32		serv;		/* server ip address */
 	u32		prog;		/* RPC callback info */
 	u32		vers;
 	u32		proc;
--- linux-2/fs/lockd/svc4proc.c	2006-07-28 15:51:49.000000000 -0400
+++ linux-3/fs/lockd/svc4proc.c	2006-07-29 00:53:56.000000000 -0400
@@ -473,7 +473,8 @@ nlm4svc_proc_sm_notify(struct svc_rqst *
 	} else {
 		/* If we run on an NFS server, delete all locks held by the client */
 
-		if ((host = nlm_lookup_host(1, &saddr, prot, vers)) != NULL) {
+		if ((host = nlm_lookup_host(rqstp->rq_daddr, 
+				&saddr, prot, vers)) != NULL) {
 			nlmsvc_free_host_resources(host);
 			nlm_release_host(host);
 		}
--- linux-2/fs/lockd/svcproc.c	2006-07-28 15:51:49.000000000 -0400
+++ linux-3/fs/lockd/svcproc.c	2006-07-28 15:53:36.000000000 -0400
@@ -501,7 +501,8 @@ nlmsvc_proc_sm_notify(struct svc_rqst *r
 		}
 	} else {
 		/* If we run on an NFS server, delete all locks held by the client */
-		if ((host = nlm_lookup_host(1, &saddr, prot, vers)) != NULL) {
+		if ((host = nlm_lookup_host(rqstp->rq_daddr, 
+				&saddr, prot, vers)) != NULL) {
 			nlmsvc_free_host_resources(host);
 			nlm_release_host(host);
 		}
--- linux-2/fs/lockd/mon.c	2006-07-28 15:50:18.000000000 -0400
+++ linux-3/fs/lockd/mon.c	2006-07-29 00:54:58.000000000 -0400
@@ -14,7 +14,6 @@
 #include <linux/lockd/lockd.h>
 #include <linux/lockd/sm_inter.h>
 
-
 #define NLMDBG_FACILITY		NLMDBG_MONITOR
 
 static struct rpc_clnt *	nsm_create(void);
@@ -47,7 +46,8 @@ nsm_mon_unmon(struct nlm_host *host, u32
 	}
 
 	args.addr = host->h_addr.sin_addr.s_addr;
-	args.proto= (host->h_proto<<1) | host->h_server;
+	args.serv = host->h_server;
+	args.proto= (host->h_proto<<1) | host->h_where;
 	args.prog = NLM_PROGRAM;
 	args.vers = host->h_version;
 	args.proc = NLMPROC_NSM_NOTIFY;
@@ -142,7 +142,7 @@ out_err:
 static u32 *
 xdr_encode_common(struct rpc_rqst *rqstp, u32 *p, struct nsm_args *argp)
 {
-	char	buffer[20];
+	char	buffer[100]; 
 
 	/*
 	 * Use the dotted-quad IP address of the remote host as
@@ -151,8 +151,13 @@ xdr_encode_common(struct rpc_rqst *rqstp
 	 * so this works alright.
 	 */
 	sprintf(buffer, "%u.%u.%u.%u", NIPQUAD(argp->addr));
-	if (!(p = xdr_encode_string(p, buffer))
-	 || !(p = xdr_encode_string(p, system_utsname.nodename)))
+	if (!(p = xdr_encode_string(p, buffer)))
+		return ERR_PTR(-EIO);
+	if (argp->serv) 
+		sprintf(buffer, "%u.%u.%u.%u", NIPQUAD(argp->serv));
+	else 
+		sprintf(buffer, "%s", system_utsname.nodename);
+	if (!(p = xdr_encode_string(p, buffer)))
 		return ERR_PTR(-EIO);
 	*p++ = htonl(argp->prog);
 	*p++ = htonl(argp->vers);
--- linux-2/fs/lockd/host.c	2006-07-28 15:50:18.000000000 -0400
+++ linux-3/fs/lockd/host.c	2006-07-28 15:53:36.000000000 -0400
@@ -51,7 +51,7 @@ nlmclnt_lookup_host(struct sockaddr_in *
 struct nlm_host *
 nlmsvc_lookup_host(struct svc_rqst *rqstp)
 {
-	return nlm_lookup_host(1, &rqstp->rq_addr,
+	return nlm_lookup_host(rqstp->rq_daddr, &rqstp->rq_addr,
 			       rqstp->rq_prot, rqstp->rq_vers);
 }
 
@@ -59,7 +59,7 @@ nlmsvc_lookup_host(struct svc_rqst *rqst
  * Common host lookup routine for server & client
  */
 struct nlm_host *
-nlm_lookup_host(int server, struct sockaddr_in *sin,
+nlm_lookup_host(svc_addr_t server, struct sockaddr_in *sin,
 					int proto, int version)
 {
 	struct nlm_host	*host, **hp;
@@ -121,6 +121,10 @@ nlm_lookup_host(int server, struct socka
 	host->h_state      = 0;			/* pseudo NSM state */
 	host->h_nsmstate   = 0;			/* real NSM state */
 	host->h_server	   = server;
+	if (server) 
+		host->h_where = 1;
+	else
+		host->h_where = 0;
 	host->h_next       = nlm_hosts[hash];
 	nlm_hosts[hash]    = host;
 	INIT_LIST_HEAD(&host->h_lockowners);

--=-hJyCCkahRk11YJhhRdP8
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--=-hJyCCkahRk11YJhhRdP8
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-hJyCCkahRk11YJhhRdP8--
