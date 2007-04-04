From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: lockd and statd
Date: Wed, 04 Apr 2007 18:48:47 -0400
Message-ID: <46142B4F.1030507@redhat.com>
References: <57bc13580704040011u3058e6d9wd0d4fc0de63d4d93@mail.gmail.com>	
	<1175690426.6118.6.camel@heimdal.trondhjem.org>	
	<57bc13580704040909o386259f1q84367459ce555671@mail.gmail.com>	
	<200704041933.27315.okir@lst.de> <4613F34C.2040709@redhat.com>
	<1175722463.7279.16.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050707040002050803070805"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HZEbU-000525-Qu
	for nfs@lists.sourceforge.net; Wed, 04 Apr 2007 16:09:25 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HZEbW-0007ir-CM
	for nfs@lists.sourceforge.net; Wed, 04 Apr 2007 16:09:27 -0700
In-Reply-To: <1175722463.7279.16.camel@heimdal.trondhjem.org>
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
--------------050707040002050803070805
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Wed, 2007-04-04 at 14:49 -0400, Wendy Cheng wrote:
>   
>>   
>>     
>> I'm wondering what would be the reason(s) that the community version of 
>> Linux statd is put in user space ? Any one cares to give either a 
>> technical or historical explanation ?
>>     
>
> Off the cuff, I can think of 2 main reasons why it needs to be in user
> space:
>  1) It creates and maintains a directory hierarchy on permanent storage
> (as opposed to in a pseudo filesystem).
>  2) It needs to resolve addresses via DNS etc.
>   

Ha! #2 happens to be my question.. Is there any reason why it has to be 
dnsname ? The following is my issue:

While testing out the NLM failover patches, on Neil's new 
nfs-utils-1.1.0-rc1, sm_mon_1_svc() writes to /var/lib/nfs/sm using 
dnsname (say, for example, dhcp146.something.com), even the kernel has 
passed it a dotted IP address (say 192.168.24.146, since I can't use 
"nsm_use_hostnames" as lockd module param). Unfortunately, the 
sm_unmon_1_svc() doesn't do similar conversion. So when kernel side 
tries to delete the monitored name, I got:

Apr  4 18:12:25 dhcp143 kernel: lockd: delete host dhcp146.perf.redhat.com
Apr  4 18:12:25 dhcp143 kernel: lockd: 
nsm_unmonitor(dhcp146.perf.redhat.com)
Apr  4 18:12:25 dhcp143 rpc.statd[4210]: unlink 
(/var/lib/nfs/sm/192.168.24.146): No such file or directory

BTW, don't be fooled by above lockd trace (it printed out hostname but 
I'm very sure I passed in IPV4 dotted address as seen by the attached 
kernel statd patch).

Oversight ? My configuration problem ? nfs-util bug ? my bug ? or I 
mis-understand the logic ?

--- Wendy






--------------050707040002050803070805
Content-Type: text/x-patch;
 name="003_gfs_nlm.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="003_gfs_nlm.patch"

--- linux-nlm-2/include/linux/lockd/sm_inter.h	2007-03-26 18:25:38.000000000 -0400
+++ linux/include/linux/lockd/sm_inter.h	2007-04-03 21:55:42.000000000 -0400
@@ -25,6 +25,7 @@
  */
 struct nsm_args {
 	__be32		addr;		/* remote address */
+	__be32          serv;		/* server ip address */
 	u32		prog;		/* RPC callback info */
 	u32		vers;
 	u32		proc;
@@ -40,7 +41,7 @@ struct nsm_res {
 	u32		state;
 };
 
-int		nsm_monitor(struct nlm_host *);
+int		nsm_monitor(struct nlm_host *, __be32 ip);
 int		nsm_unmonitor(struct nlm_host *);
 extern int	nsm_local_state;
 
--- linux-nlm-2/include/linux/lockd/lockd.h	2007-03-26 18:25:38.000000000 -0400
+++ linux/include/linux/lockd/lockd.h	2007-04-04 10:45:14.000000000 -0400
@@ -39,12 +39,12 @@
 struct nlm_host {
 	struct hlist_node	h_hash;		/* doubly linked list */
 	struct sockaddr_in	h_addr;		/* peer address */
+	__be32			h_server;	/* server ip for NLM failover */
 	struct rpc_clnt	*	h_rpcclnt;	/* RPC client to talk to peer */
 	char *			h_name;		/* remote hostname */
 	u32			h_version;	/* interface version */
 	unsigned short		h_proto;	/* transport proto */
 	unsigned short		h_reclaiming : 1,
-				h_server     : 1, /* server side, not client side */
 				h_inuse      : 1;
 	wait_queue_head_t	h_gracewait;	/* wait while reclaiming */
 	struct rw_semaphore	h_rwsem;	/* Reboot recovery lock */
@@ -62,11 +62,18 @@ struct nlm_host {
 	struct nsm_handle *	h_nsmhandle;	/* NSM status handle */
 };
 
+struct nsm_fo_monitored {
+	struct list_head	list;
+	__be32			addr;
+};
+
 struct nsm_handle {
 	struct list_head	sm_link;
 	atomic_t		sm_count;
 	char *			sm_name;
 	struct sockaddr_in	sm_addr;
+	struct mutex		sm_mutex;
+	struct nsm_fo_monitored sm_serverip;
 	unsigned int		sm_monitored : 1,
 				sm_sticky : 1;	/* don't unmonitor */
 };
@@ -254,7 +261,7 @@ static inline int
 nlmsvc_check_grace_period(struct nlm_args *argp)
 {
 	/* check for system wide grace period */
-	if (nlmsvc_grace_period)
+	if (nlmsvc_grace_period) 
 		return 1;
 
 	/* check for per exported fsid grace period */
--- linux-nlm-2/net/sunrpc/svcsock.c	2007-03-26 18:26:06.000000000 -0400
+++ linux/net/sunrpc/svcsock.c	2007-04-04 17:09:15.000000000 -0400
@@ -1111,6 +1111,44 @@ failed:
 	return;
 }
 
+/* Added for NLM-cluster failover implementation */ 
+static inline void svc_tcp_get_server_address(struct svc_rqst *rqstp)
+{
+	struct socket *sock = rqstp->rq_sock->sk_sock;
+	struct sockaddr_in6 sin6;
+	struct sockaddr_in *sin = (struct sockaddr_in *) &sin6;
+	int len, err;
+
+	/* ref: inet_getname, inet6_getname, and sys_getsockname */
+	err = sock->ops->getname(sock, (struct sockaddr *) sin, &len, 0);
+	if (err) {
+		dprintk("svc_tcp_get_server_address: getname err=%d\n", err);
+		return;
+	}
+		
+        switch (rqstp->rq_sock->sk_sk->sk_family) {
+        case AF_INET: 
+		/* sanity check */
+		if (sin->sin_family != AF_INET)
+			printk("sunrpc: inet address family mismatch %d\n",
+				(int) sin->sin_family); 
+                rqstp->rq_daddr.addr = sin->sin_addr;
+                break;
+        case AF_INET6: 
+		/* sanity check */
+		if (sin6.sin6_family != AF_INET6)
+			printk("sunrpc: inet6 address family mismatch %d\n",
+				(int) sin6.sin6_family); 
+                ipv6_addr_copy(&rqstp->rq_daddr.addr6, &sin6.sin6_addr); 
+                break;
+	default:
+		break;
+	}
+
+	/* no error return */
+	return;
+}
+
 /*
  * Receive data from a TCP socket.
  */
@@ -1260,6 +1298,8 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	if (serv->sv_stats)
 		serv->sv_stats->nettcpcnt++;
 
+	svc_tcp_get_server_address(rqstp);
+
 	return len;
 
  err_delete:
--- linux-nlm-2/fs/lockd/host.c	2007-03-26 18:19:11.000000000 -0400
+++ linux/fs/lockd/host.c	2007-04-04 12:02:50.000000000 -0400
@@ -34,16 +34,16 @@ static DEFINE_MUTEX(nlm_host_mutex);
 
 static void			nlm_gc_hosts(void);
 static struct nsm_handle *	__nsm_find(const struct sockaddr_in *,
-					const char *, int, int);
+					const char *, int, int, __be32);
 static struct nsm_handle *	nsm_find(const struct sockaddr_in *sin,
 					 const char *hostname,
-					 int hostname_len);
+					 int hostname_len, __be32 ip);
 
 /*
  * Common host lookup routine for server & client
  */
 static struct nlm_host *
-nlm_lookup_host(int server, const struct sockaddr_in *sin,
+nlm_lookup_host(union svc_addr_u *server, const struct sockaddr_in *sin,
 					int proto, int version,
 					const char *hostname,
 					int hostname_len)
@@ -53,6 +53,7 @@ nlm_lookup_host(int server, const struct
 	struct nlm_host	*host;
 	struct nsm_handle *nsm = NULL;
 	int		hash;
+	__be32		server_ip;
 
 	dprintk("lockd: nlm_lookup_host(%u.%u.%u.%u, p=%d, v=%d, my role=%s, name=%.*s)\n",
 			NIPQUAD(sin->sin_addr.s_addr), proto, version,
@@ -60,6 +61,13 @@ nlm_lookup_host(int server, const struct
 			hostname_len,
 			hostname? hostname : "<none>");
 
+	/* NLM failover: ipv4 for now */
+	if (server)
+		server_ip = server->addr.s_addr;
+	else
+		server_ip = 0;
+
+	dprintk("lockd: server_ip = %u.%u.%u.%u\n", NIPQUAD(server_ip));
 
 	hash = NLM_ADDRHASH(sin->sin_addr.s_addr);
 
@@ -89,7 +97,7 @@ nlm_lookup_host(int server, const struct
 			continue;
 		if (host->h_version != version)
 			continue;
-		if (host->h_server != server)
+		if (host->h_server != server_ip)
 			continue;
 
 		/* Move to head of hash chain. */
@@ -107,7 +115,7 @@ nlm_lookup_host(int server, const struct
 	/* Sadly, the host isn't in our hash table yet. See if
 	 * we have an NSM handle for it. If not, create one.
 	 */
-	if (!nsm && !(nsm = nsm_find(sin, hostname, hostname_len)))
+	if (!nsm && !(nsm = nsm_find(sin, hostname, hostname_len, server_ip)))
 		goto out;
 
 	host = kzalloc(sizeof(*host), GFP_KERNEL);
@@ -130,7 +138,10 @@ nlm_lookup_host(int server, const struct
 	host->h_state      = 0;			/* pseudo NSM state */
 	host->h_nsmstate   = 0;			/* real NSM state */
 	host->h_nsmhandle  = nsm;
-	host->h_server	   = server;
+
+	/* NLM failover: only ipv4 for now */
+	host->h_server	   = server_ip;
+
 	hlist_add_head(&host->h_hash, chain);
 	INIT_LIST_HEAD(&host->h_lockowners);
 	spin_lock_init(&host->h_lock);
@@ -180,7 +191,7 @@ struct nlm_host *
 nlmclnt_lookup_host(const struct sockaddr_in *sin, int proto, int version,
 			const char *hostname, int hostname_len)
 {
-	return nlm_lookup_host(0, sin, proto, version,
+	return nlm_lookup_host(NULL, sin, proto, version,
 			       hostname, hostname_len);
 }
 
@@ -191,7 +202,7 @@ struct nlm_host *
 nlmsvc_lookup_host(struct svc_rqst *rqstp,
 			const char *hostname, int hostname_len)
 {
-	return nlm_lookup_host(1, svc_addr_in(rqstp),
+	return nlm_lookup_host(&rqstp->rq_daddr, svc_addr_in(rqstp),
 			       rqstp->rq_prot, rqstp->rq_vers,
 			       hostname, hostname_len);
 }
@@ -314,7 +325,7 @@ void nlm_host_rebooted(const struct sock
 			hostname, NIPQUAD(sin->sin_addr));
 
 	/* Find the NSM handle for this peer */
-	if (!(nsm = __nsm_find(sin, hostname, hostname_len, 0)))
+	if (!(nsm = __nsm_find(sin, hostname, hostname_len, 0, 0)))
 		return;
 
 	/* When reclaiming locks on this peer, make sure that
@@ -445,7 +456,7 @@ static DEFINE_MUTEX(nsm_mutex);
 static struct nsm_handle *
 __nsm_find(const struct sockaddr_in *sin,
 		const char *hostname, int hostname_len,
-		int create)
+		int create, __be32 server_ip)
 {
 	struct nsm_handle *nsm = NULL;
 	struct list_head *pos;
@@ -490,6 +501,11 @@ __nsm_find(const struct sockaddr_in *sin
 		atomic_set(&nsm->sm_count, 1);
 
 		list_add(&nsm->sm_link, &nsm_handles);
+
+		/* NLM failover */
+		mutex_init(&nsm->sm_mutex);
+		INIT_LIST_HEAD(&nsm->sm_serverip.list);
+		nsm->sm_serverip.addr = server_ip;
 	}
 
 out:
@@ -498,9 +514,28 @@ out:
 }
 
 static struct nsm_handle *
-nsm_find(const struct sockaddr_in *sin, const char *hostname, int hostname_len)
+nsm_find(const struct sockaddr_in *sin, const char *hostname, int hostname_len,
+		__be32 server_ip)
+{
+	return __nsm_find(sin, hostname, hostname_len, 1, server_ip);
+}
+
+/*
+ * NLM failover:
+ *	nsm_mutex should be obtained before entry
+ *	fo_ip not NULL
+ */
+void
+nsm_release_fo_ip(struct nsm_fo_monitored *fo_ip)
 {
-	return __nsm_find(sin, hostname, hostname_len, 1);
+	struct list_head *pos, *n, *head=&fo_ip->list;
+	struct nsm_fo_monitored *server_ip;
+
+	list_for_each_safe(pos, n, head) {
+		server_ip = list_entry(pos, struct nsm_fo_monitored, list);
+		kfree(server_ip);
+	}
+	return;
 }
 
 /*
@@ -515,6 +550,8 @@ nsm_release(struct nsm_handle *nsm)
 		mutex_lock(&nsm_mutex);
 		if (atomic_read(&nsm->sm_count) == 0) {
 			list_del(&nsm->sm_link);
+			if (!list_empty(&nsm->sm_serverip.list))
+				nsm_release_fo_ip(&nsm->sm_serverip);
 			kfree(nsm);
 		}
 		mutex_unlock(&nsm_mutex);
--- linux-nlm-2/fs/lockd/mon.c	2007-03-26 18:19:10.000000000 -0400
+++ linux/fs/lockd/mon.c	2007-04-04 16:11:05.000000000 -0400
@@ -30,7 +30,7 @@ int				nsm_local_state;
  * Common procedure for SM_MON/SM_UNMON calls
  */
 static int
-nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
+nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res, __be32 server_ip)
 {
 	struct rpc_clnt	*clnt;
 	int		status;
@@ -48,6 +48,12 @@ nsm_mon_unmon(struct nsm_handle *nsm, u3
 
 	memset(&args, 0, sizeof(args));
 	args.mon_name = nsm->sm_name;
+
+	/* NLM failover:
+	 * only IPV4 is supported at this moment 
+	 */
+	args.serv = server_ip;
+
 	args.addr = nsm->sm_addr.sin_addr.s_addr;
 	args.prog = NLM_PROGRAM;
 	args.vers = 3;
@@ -65,28 +71,71 @@ nsm_mon_unmon(struct nsm_handle *nsm, u3
 	return status;
 }
 
+static inline
+int nsm_is_monitored(struct nlm_host *host, __be32 server)
+{
+	struct nsm_handle *nsm = host->h_nsmhandle;
+	struct list_head *pos, *head;
+	struct nsm_fo_monitored *fo_entry;
+
+	/* client */
+	if (!server)
+		return nsm->sm_monitored;
+
+	/* server */
+	if (!nsm->sm_monitored)
+		return 0;
+
+	/* search for monitored list */
+	mutex_lock(&nsm->sm_mutex);
+	head = &nsm->sm_serverip.list;
+	list_for_each(pos, head) {
+		fo_entry = list_entry(pos, struct nsm_fo_monitored, list);
+		if (fo_entry->addr == server) {
+			mutex_unlock(&nsm->sm_mutex);
+			return 1;
+		}
+	}
+	mutex_unlock(&nsm->sm_mutex);
+
+	return 0;
+}
+
 /*
  * Set up monitoring of a remote host
  */
 int
-nsm_monitor(struct nlm_host *host)
+nsm_monitor(struct nlm_host *host, __be32 server)
 {
 	struct nsm_handle *nsm = host->h_nsmhandle;
 	struct nsm_res	res;
 	int		status;
+	struct nsm_fo_monitored *fo_entry;
 
 	dprintk("lockd: nsm_monitor(%s)\n", host->h_name);
 	BUG_ON(nsm == NULL);
 
-	if (nsm->sm_monitored)
+	if (nsm_is_monitored(host, server)) {
+		dprintk("nsm_monitor: sm_monitored is true - returning 0\n");
 		return 0;
+	}
 
-	status = nsm_mon_unmon(nsm, SM_MON, &res);
+	status = nsm_mon_unmon(nsm, SM_MON, &res, server);
 
 	if (status < 0 || res.status != 0)
 		printk(KERN_NOTICE "lockd: cannot monitor %s\n", host->h_name);
-	else
+	else if (nsm->sm_monitored) {
+		fo_entry = kzalloc(sizeof(struct nsm_fo_monitored), GFP_KERNEL);
+		if (!fo_entry) {
+			printk("lockd: out of memory, can't add fo_entry\n");
+			return -ENOMEM;
+		}
+		fo_entry->addr = server;
+		INIT_LIST_HEAD(&fo_entry->list);
+		list_add(&fo_entry->list, &nsm->sm_serverip.list);
+	} else
 		nsm->sm_monitored = 1;
+
 	return status;
 }
 
@@ -98,7 +147,9 @@ nsm_unmonitor(struct nlm_host *host)
 {
 	struct nsm_handle *nsm = host->h_nsmhandle;
 	struct nsm_res	res;
-	int		status = 0;
+	int		status = 0, error=0;
+	struct list_head *pos, *head=&nsm->sm_serverip.list;
+	struct nsm_fo_monitored *fo_entry;
 
 	if (nsm == NULL)
 		return 0;
@@ -108,11 +159,21 @@ nsm_unmonitor(struct nlm_host *host)
 	 && nsm->sm_monitored && !nsm->sm_sticky) {
 		dprintk("lockd: nsm_unmonitor(%s)\n", host->h_name);
 
-		status = nsm_mon_unmon(nsm, SM_UNMON, &res);
-		if (status < 0)
-			printk(KERN_NOTICE "lockd: cannot unmonitor %s\n",
+		/* Unmonitor each server IP 
+		 * 	todo: need to re-think error handling
+		 */
+		mutex_lock(&nsm->sm_mutex);
+		list_for_each(pos, head) {
+			fo_entry = list_entry(pos, struct nsm_fo_monitored, list);
+			status = nsm_mon_unmon(nsm, SM_UNMON, &res, fo_entry->addr);
+			if (status < 0) {
+				error++;
+				printk(KERN_NOTICE "lockd: cannot unmonitor %s\n",
 					host->h_name);
-		else
+			} 
+		}
+		mutex_unlock(&nsm->sm_mutex);
+		if (!error)
 			nsm->sm_monitored = 0;
 	}
 	nsm_release(nsm);
@@ -144,6 +205,13 @@ nsm_create(void)
 	return rpc_create(&args);
 }
 
+/* We want "buffer" in xdr_encode_common() to hold
+ * either the system_utsname.nodename string (__NEW_UTS_LEN+1)
+ * or IPv4 dot notation (16 bytes+1) for now.
+ */
+
+#define        XDR_ENCODE_BUF_LEN __NEW_UTS_LEN+1
+
 /*
  * XDR functions for NSM.
  */
@@ -151,7 +219,8 @@ nsm_create(void)
 static __be32 *
 xdr_encode_common(struct rpc_rqst *rqstp, __be32 *p, struct nsm_args *argp)
 {
-	char	buffer[20], *name;
+	char	*name;
+	char    buffer[XDR_ENCODE_BUF_LEN];
 
 	/*
 	 * Use the dotted-quad IP address of the remote host as
@@ -161,13 +230,20 @@ xdr_encode_common(struct rpc_rqst *rqstp
 	 */
 	if (nsm_use_hostnames) {
 		name = argp->mon_name;
-	} else {
+	} else { 
 		sprintf(buffer, "%u.%u.%u.%u", NIPQUAD(argp->addr));
 		name = buffer;
 	}
-	if (!(p = xdr_encode_string(p, name))
-	 || !(p = xdr_encode_string(p, utsname()->nodename)))
+	if (!(p = xdr_encode_string(p, name)))
+		return ERR_PTR(-EIO);
+
+	if (argp->serv)
+		sprintf(buffer, "%u.%u.%u.%u", NIPQUAD(argp->serv));
+	else
+		sprintf(buffer, "%s", utsname()->nodename);
+	if (!(p = xdr_encode_string(p, buffer)))
 		return ERR_PTR(-EIO);
+
 	*p++ = htonl(argp->prog);
 	*p++ = htonl(argp->vers);
 	*p++ = htonl(argp->proc);
--- linux-nlm-2/fs/lockd/clntproc.c	2007-03-26 18:19:10.000000000 -0400
+++ linux/fs/lockd/clntproc.c	2007-04-03 21:49:04.000000000 -0400
@@ -500,7 +500,7 @@ nlmclnt_lock(struct nlm_rqst *req, struc
 	unsigned char fl_flags = fl->fl_flags;
 	int status = -ENOLCK;
 
-	if (nsm_monitor(host) < 0) {
+	if (nsm_monitor(host, 0) < 0) {
 		printk(KERN_NOTICE "lockd: failed to monitor %s\n",
 					host->h_name);
 		goto out;

--------------050707040002050803070805
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------050707040002050803070805
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------050707040002050803070805--
