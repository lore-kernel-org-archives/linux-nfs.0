From: Wendy Cheng <wcheng@redhat.com>
Subject: [RFC PATCH 3/3] NLM lock failover = statd enablement
Date: Thu, 29 Jun 2006 14:35:36 -0400
Message-ID: <44A41D78.5000201@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080700070101040104030600"
Cc: Lon Hohberger <lhh@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fw1Mg-0006db-At
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 11:35:46 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fw1Mg-0006bS-4v
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 11:35:46 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k5TIZjgQ022400
	for <nfs@lists.sourceforge.net>; Thu, 29 Jun 2006 14:35:45 -0400
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
--------------080700070101040104030600
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This kernel patch has *not* been tested out yet and it needs to be 
paired with user mode nfs-utils changes (not ready in time for this 
RFC). It is included in this submission just to give people a complete 
picture of the implementation. The patch will enable rpc.statd to put 
the correct taken-over IPv4 address in standard dot notation into the 
3rd parameter of ha_callout program (see man rpc.statd for details) for 
"add-client" event. Upon "del-client" event, we would assume the 
monitored host should be removed from server-wide lists, regardless 
individual server's interface.

--------------080700070101040104030600
Content-Type: text/plain;
 name="gfs_statd.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="gfs_statd.patch"

 fs/lockd/clntproc.c            |    2 +-
 fs/lockd/host.c                |    2 +-
 fs/lockd/mon.c                 |   21 +++++++++++++--------
 fs/lockd/svc4proc.c            |    2 +-
 fs/lockd/svcproc.c             |    2 +-
 include/linux/lockd/sm_inter.h |    5 +++--
 6 files changed, 20 insertions(+), 14 deletions(-)

--- linux-2.6.17-2/include/linux/lockd/sm_inter.h	2006-06-27 22:52:32.000000000 -0400
+++ linux-2.6.17-3/include/linux/lockd/sm_inter.h	2006-06-28 23:20:02.000000000 -0400
@@ -25,6 +25,7 @@
  */
 struct nsm_args {
 	u32		addr;		/* remote address */
+	u32		serv;		/* server ip address */
 	u32		prog;		/* RPC callback info */
 	u32		vers;
 	u32		proc;
@@ -39,8 +40,8 @@ struct nsm_res {
 	u32		state;
 };
 
-int		nsm_monitor(struct nlm_host *);
-int		nsm_unmonitor(struct nlm_host *);
+int		nsm_monitor(struct nlm_host *, __u32 *serv_ip);
+int		nsm_unmonitor(struct nlm_host *, __u32 *serv_ip);
 extern u32	nsm_local_state;
 
 #endif /* LINUX_LOCKD_SM_INTER_H */
--- linux-2.6.17-2/fs/lockd/svc4proc.c	2006-06-28 14:19:24.000000000 -0400
+++ linux-2.6.17-3/fs/lockd/svc4proc.c	2006-06-29 09:10:02.000000000 -0400
@@ -58,7 +58,7 @@ nlm4svc_retrieve_args(struct svc_rqst *r
 
 	/* Obtain host handle */
 	if (!(host = nlmsvc_lookup_host(rqstp))
-	 || (argp->monitor && !host->h_monitored && nsm_monitor(host) < 0))
+	 || (argp->monitor && !host->h_monitored && nsm_monitor(host, &rqstp->rq_daddr) < 0))
 		goto no_locks;
 	*hostp = host;
 
--- linux-2.6.17-2/fs/lockd/svcproc.c	2006-06-28 14:19:50.000000000 -0400
+++ linux-2.6.17-3/fs/lockd/svcproc.c	2006-06-29 09:10:02.000000000 -0400
@@ -89,7 +89,7 @@ nlmsvc_retrieve_args(struct svc_rqst *rq
 
 	/* Obtain host handle */
 	if (!(host = nlmsvc_lookup_host(rqstp))
-	 || (argp->monitor && !host->h_monitored && nsm_monitor(host) < 0))
+	 || (argp->monitor && !host->h_monitored && nsm_monitor(host, &rqstp->rq_daddr) < 0))
 		goto no_locks;
 	*hostp = host;
 
--- linux-2.6.17-2/fs/lockd/clntproc.c	2006-06-27 22:49:16.000000000 -0400
+++ linux-2.6.17-3/fs/lockd/clntproc.c	2006-06-29 09:10:02.000000000 -0400
@@ -501,7 +501,7 @@ nlmclnt_lock(struct nlm_rqst *req, struc
 	struct nlm_wait *block = NULL;
 	int status = -ENOLCK;
 
-	if (!host->h_monitored && nsm_monitor(host) < 0) {
+	if (!host->h_monitored && nsm_monitor(host,NULL) < 0) {
 		printk(KERN_NOTICE "lockd: failed to monitor %s\n",
 					host->h_name);
 		goto out;
--- linux-2.6.17-2/fs/lockd/mon.c	2006-06-27 22:49:16.000000000 -0400
+++ linux-2.6.17-3/fs/lockd/mon.c	2006-06-29 09:21:03.000000000 -0400
@@ -14,7 +14,6 @@
 #include <linux/lockd/lockd.h>
 #include <linux/lockd/sm_inter.h>
 
-
 #define NLMDBG_FACILITY		NLMDBG_MONITOR
 
 static struct rpc_clnt *	nsm_create(void);
@@ -30,7 +29,7 @@ u32				nsm_local_state;
  * Common procedure for SM_MON/SM_UNMON calls
  */
 static int
-nsm_mon_unmon(struct nlm_host *host, u32 proc, struct nsm_res *res)
+nsm_mon_unmon(struct nlm_host *host, __u32 *serv_ip, u32 proc, struct nsm_res *res)
 {
 	struct rpc_clnt	*clnt;
 	int		status;
@@ -47,6 +46,7 @@ nsm_mon_unmon(struct nlm_host *host, u32
 	}
 
 	args.addr = host->h_addr.sin_addr.s_addr;
+	args.serv = *serv_ip;
 	args.proto= (host->h_proto<<1) | host->h_server;
 	args.prog = NLM_PROGRAM;
 	args.vers = host->h_version;
@@ -68,14 +68,14 @@ nsm_mon_unmon(struct nlm_host *host, u32
  * Set up monitoring of a remote host
  */
 int
-nsm_monitor(struct nlm_host *host)
+nsm_monitor(struct nlm_host *host, __u32 *serv_ip)
 {
 	struct nsm_res	res;
 	int		status;
 
 	dprintk("lockd: nsm_monitor(%s)\n", host->h_name);
 
-	status = nsm_mon_unmon(host, SM_MON, &res);
+	status = nsm_mon_unmon(host, serv_ip, SM_MON, &res);
 
 	if (status < 0 || res.status != 0)
 		printk(KERN_NOTICE "lockd: cannot monitor %s\n", host->h_name);
@@ -88,14 +88,14 @@ nsm_monitor(struct nlm_host *host)
  * Cease to monitor remote host
  */
 int
-nsm_unmonitor(struct nlm_host *host)
+nsm_unmonitor(struct nlm_host *host, __u32 *serv_ip)
 {
 	struct nsm_res	res;
 	int		status;
 
 	dprintk("lockd: nsm_unmonitor(%s)\n", host->h_name);
 
-	status = nsm_mon_unmon(host, SM_UNMON, &res);
+	status = nsm_mon_unmon(host, serv_ip, SM_UNMON, &res);
 	if (status < 0)
 		printk(KERN_NOTICE "lockd: cannot unmonitor %s\n", host->h_name);
 	else
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
--- linux-2.6.17-2/fs/lockd/host.c	2006-06-27 22:49:14.000000000 -0400
+++ linux-2.6.17-3/fs/lockd/host.c	2006-06-29 09:10:02.000000000 -0400
@@ -329,7 +329,7 @@ nlm_gc_hosts(void)
 			*q = host->h_next;
 			/* Don't unmonitor hosts that have been invalidated */
 			if (host->h_monitored && !host->h_killed)
-				nsm_unmonitor(host);
+				nsm_unmonitor(host, NULL);
 			if ((clnt = host->h_rpcclnt) != NULL) {
 				if (atomic_read(&clnt->cl_users)) {
 					printk(KERN_WARNING

--------------080700070101040104030600
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--------------080700070101040104030600
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080700070101040104030600--
