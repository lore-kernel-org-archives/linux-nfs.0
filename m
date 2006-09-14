From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH 3/4 Revised] NLM failover - statd changes
Date: Thu, 14 Sep 2006 00:50:40 -0400
Message-ID: <4508DFA0.2060806@redhat.com>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000806050900010405040704"
Cc: lhh@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GNizH-0006XZ-4e
	for nfs@lists.sourceforge.net; Wed, 13 Sep 2006 21:38:07 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GNizH-0001Ce-CN
	for nfs@lists.sourceforge.net; Wed, 13 Sep 2006 21:38:08 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k8E4c6Xu021047
	for <nfs@lists.sourceforge.net>; Thu, 14 Sep 2006 00:38:06 -0400
To: nfs@lists.sourceforge.net, cluster-devel@redhat.com
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

This is a multi-part message in MIME format.
--------------000806050900010405040704
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This kernel patch should be paired with nfs-utils user mode changes (in 
patch 4-4 based on nfs-utils-1.0.8-rc4) that is optional. If changes 
made in patch 4-4 is not presented in nfs-utils, the rpc.statd will 
ignore whatever this kernel patch does.

The changes record the ip interface that accepts the lock requests and 
passes the correct "my_name" (in standard IPV4 dot notation) to user 
mode statd (instead of system_utsname.nodename). This enables rpc.statd 
to add the correct taken-over IPv4 address into the 3rd parameter of 
ha_callout program. Current nfs-utils always resets "my_name" into 
loopback address (127.0.0.1), regardless the statement made in rpc.statd 
man page. Check out "man rpc.statd" for details.

Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
Signed-off-by: Lon Hohberger  <lhh@redhat.com>

 fs/lockd/host.c                |    4 ++--
 fs/lockd/mon.c                 |   21 +++++++++++++++++----
 fs/lockd/svc4proc.c            |    8 +++++++-
 fs/lockd/svcproc.c             |    2 +-
 include/linux/lockd/lockd.h    |    5 +++--
 include/linux/lockd/sm_inter.h |    1 +
 include/linux/sunrpc/svc.h     |    5 +++--
 net/sunrpc/svcsock.c           |    5 +++++
 8 files changed, 39 insertions(+), 12 deletions(-)



--------------000806050900010405040704
Content-Type: text/x-patch;
 name="gfs_statd.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="gfs_statd.patch"

--- linux-2/include/linux/sunrpc/svc.h	2006-09-11 16:52:34.000000000 -0400
+++ linux-3/include/linux/sunrpc/svc.h	2006-09-13 14:07:32.000000000 -0400
@@ -102,6 +102,7 @@ static inline void svc_putu32(struct kve
 	iov->iov_len += sizeof(u32);
 }
 
+typedef __u32  svc_addr_t;
 	
 /*
  * The context of a single thread, including the request currently being
@@ -138,8 +139,8 @@ struct svc_rqst {
 	unsigned short
 				rq_secure  : 1;	/* secure port */
 
-
-	__u32			rq_daddr;	/* dest addr of request - reply from here */
+	svc_addr_t		rq_daddr;	/* dest addr of request 
+						   - reply from here */
 
 	void *			rq_argp;	/* decoded arguments */
 	void *			rq_resp;	/* xdr'd results */
--- linux-2/include/linux/lockd/lockd.h	2006-09-13 22:48:00.000000000 -0400
+++ linux-3/include/linux/lockd/lockd.h	2006-09-13 22:51:41.000000000 -0400
@@ -39,12 +39,13 @@
 struct nlm_host {
 	struct nlm_host *	h_next;		/* linked list (hash table) */
 	struct sockaddr_in	h_addr;		/* peer address */
+	svc_addr_t		h_server;	/* server ip for NLM failover */
 	struct rpc_clnt	*	h_rpcclnt;	/* RPC client to talk to peer */
 	char			h_name[20];	/* remote hostname */
 	u32			h_version;	/* interface version */
 	unsigned short		h_proto;	/* transport proto */
 	unsigned short		h_reclaiming : 1,
-				h_server     : 1, /* server side, not client side */
+				h_notused    : 1, 
 				h_inuse      : 1,
 				h_killed     : 1,
 				h_monitored  : 1;
@@ -175,7 +176,7 @@ int		  nlmclnt_reclaim(struct nlm_host *
  */
 struct nlm_host * nlmclnt_lookup_host(struct sockaddr_in *, int, int);
 struct nlm_host * nlmsvc_lookup_host(struct svc_rqst *);
-struct nlm_host * nlm_lookup_host(int server, struct sockaddr_in *, int, int);
+struct nlm_host * nlm_lookup_host(svc_addr_t server, struct sockaddr_in *, int, int);
 struct rpc_clnt * nlm_bind_host(struct nlm_host *);
 void		  nlm_rebind_host(struct nlm_host *);
 struct nlm_host * nlm_get_host(struct nlm_host *);
--- linux-2/include/linux/lockd/sm_inter.h	2006-09-11 16:52:34.000000000 -0400
+++ linux-3/include/linux/lockd/sm_inter.h	2006-09-13 14:07:32.000000000 -0400
@@ -25,6 +25,7 @@
  */
 struct nsm_args {
 	u32		addr;		/* remote address */
+	u32		serv;		/* server ip address */
 	u32		prog;		/* RPC callback info */
 	u32		vers;
 	u32		proc;
--- linux-2/net/sunrpc/svcsock.c	2006-09-11 16:50:47.000000000 -0400
+++ linux-3/net/sunrpc/svcsock.c	2006-09-13 14:05:40.000000000 -0400
@@ -454,6 +454,7 @@ svc_recvfrom(struct svc_rqst *rqstp, str
 	struct msghdr	msg;
 	struct socket	*sock;
 	int		len, alen;
+	struct sockaddr_in   daddr;
 
 	rqstp->rq_addrlen = sizeof(rqstp->rq_addr);
 	sock = rqstp->rq_sock->sk_sock;
@@ -474,6 +475,10 @@ svc_recvfrom(struct svc_rqst *rqstp, str
 	alen = sizeof(rqstp->rq_addr);
 	sock->ops->getname(sock, (struct sockaddr *)&rqstp->rq_addr, &alen, 1);
 
+	/* add server ip for nlm lock failover */
+	sock->ops->getname(sock, (struct sockaddr *)&daddr, &alen, 0);
+	rqstp->rq_daddr = daddr.sin_addr.s_addr;
+
 	dprintk("svc: socket %p recvfrom(%p, %Zu) = %d\n",
 		rqstp->rq_sock, iov[0].iov_base, iov[0].iov_len, len);
 
--- linux-2/fs/lockd/svc4proc.c	2006-09-13 14:03:39.000000000 -0400
+++ linux-3/fs/lockd/svc4proc.c	2006-09-13 14:16:54.000000000 -0400
@@ -138,6 +138,12 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp
 		return rpc_success;
 	}
 
+#if 0
+	if (argp->reclaim) {
+		printk("nlm4svc_proc_lock lock reclaim received\n");
+	}
+#endif
+
 	/* Obtain client and file */
 	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
 		return rpc_success;
@@ -462,7 +468,7 @@ nlm4svc_proc_sm_notify(struct svc_rqst *
 	} else {
 		/* If we run on an NFS server, delete all locks held by the client */
 
-		if ((host = nlm_lookup_host(1, &saddr, prot, vers)) != NULL) {
+		if ((host = nlm_lookup_host(rqstp->rq_daddr, &saddr, prot, vers)) != NULL) {
 			nlmsvc_free_host_resources(host);
 			nlm_release_host(host);
 		}
--- linux-2/fs/lockd/svcproc.c	2006-09-13 13:51:59.000000000 -0400
+++ linux-3/fs/lockd/svcproc.c	2006-09-13 14:06:58.000000000 -0400
@@ -491,7 +491,7 @@ nlmsvc_proc_sm_notify(struct svc_rqst *r
 		}
 	} else {
 		/* If we run on an NFS server, delete all locks held by the client */
-		if ((host = nlm_lookup_host(1, &saddr, prot, vers)) != NULL) {
+		if ((host = nlm_lookup_host(rqstp->rq_daddr, &saddr, prot, vers)) != NULL) {
 			nlmsvc_free_host_resources(host);
 			nlm_release_host(host);
 		}
--- linux-2/fs/lockd/mon.c	2006-09-11 16:51:58.000000000 -0400
+++ linux-3/fs/lockd/mon.c	2006-09-13 14:06:59.000000000 -0400
@@ -47,7 +47,8 @@ nsm_mon_unmon(struct nlm_host *host, u32
 	}
 
 	args.addr = host->h_addr.sin_addr.s_addr;
-	args.proto= (host->h_proto<<1) | host->h_server;
+	args.serv = host->h_server;
+	args.proto= (host->h_proto<<1) | (host->h_server ? 1:0);
 	args.prog = NLM_PROGRAM;
 	args.vers = host->h_version;
 	args.proc = NLMPROC_NSM_NOTIFY;
@@ -135,6 +136,13 @@ out_err:
 	return clnt;
 }
 
+/* We want "buffer" in xdr_encode_common() to hold
+ * either the system_utsname.nodename string (__NEW_UTS_LEN+1)
+ * or IPv4 dot notation (16 bytes+1) for now.
+ */ 
+
+#define	XDR_ENCODE_BUF_LEN __NEW_UTS_LEN+1	
+
 /*
  * XDR functions for NSM.
  */
@@ -142,7 +150,7 @@ out_err:
 static u32 *
 xdr_encode_common(struct rpc_rqst *rqstp, u32 *p, struct nsm_args *argp)
 {
-	char	buffer[20];
+	char	buffer[XDR_ENCODE_BUF_LEN];
 
 	/*
 	 * Use the dotted-quad IP address of the remote host as
@@ -151,8 +159,13 @@ xdr_encode_common(struct rpc_rqst *rqstp
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
--- linux-2/fs/lockd/host.c	2006-09-11 16:51:58.000000000 -0400
+++ linux-3/fs/lockd/host.c	2006-09-13 14:06:59.000000000 -0400
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

--------------000806050900010405040704
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--------------000806050900010405040704
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------000806050900010405040704--
