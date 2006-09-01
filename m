From: NeilBrown <neilb@suse.de>
Subject: [PATCH 003 of 19] knfsd: When looking up a lockd host,
	pass hostname & length
Date: Fri, 1 Sep 2006 14:38:20 +1000
Message-ID: <1060901043820.27452@suse.de>
References: <20060901141639.27206.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJ0nV-0005ko-Cr
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:38:29 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GJ0nU-0004H4-Qv
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:38:30 -0700
To: Andrew Morton <akpm@osdl.org>
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


From: Olaf Kirch <okir@suse.de>

  This patch adds the peer's hostname (and name length) to
  all calls to nlm*_lookup_host functions. A subsequent patch
  will make use of these (is requested by a sysctl).

Signed-off-by: okir@suse.de
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/lockd/clntproc.c         |    5 ++++-
 ./fs/lockd/host.c             |   37 +++++++++++++++++++++++++------------
 ./fs/lockd/svc4proc.c         |    6 ++++--
 ./fs/lockd/svclock.c          |    3 ++-
 ./fs/lockd/svcproc.c          |    6 ++++--
 ./include/linux/lockd/lockd.h |    6 +++---
 6 files changed, 42 insertions(+), 21 deletions(-)

diff .prev/fs/lockd/clntproc.c ./fs/lockd/clntproc.c
--- .prev/fs/lockd/clntproc.c	2006-08-31 16:59:10.000000000 +1000
+++ ./fs/lockd/clntproc.c	2006-08-31 16:32:15.000000000 +1000
@@ -153,6 +153,7 @@ nlmclnt_proc(struct inode *inode, int cm
 {
 	struct rpc_clnt		*client = NFS_CLIENT(inode);
 	struct sockaddr_in	addr;
+	struct nfs_server	*nfssrv = NFS_SERVER(inode);
 	struct nlm_host		*host;
 	struct nlm_rqst		*call;
 	sigset_t		oldset;
@@ -166,7 +167,9 @@ nlmclnt_proc(struct inode *inode, int cm
 	}
 
 	rpc_peeraddr(client, (struct sockaddr *) &addr, sizeof(addr));
-	host = nlmclnt_lookup_host(&addr, client->cl_xprt->prot, vers);
+	host = nlmclnt_lookup_host(&addr, client->cl_xprt->prot, vers,
+				   nfssrv->nfs_client->cl_hostname,
+				   strlen(nfssrv->nfs_client->cl_hostname));
 	if (host == NULL)
 		return -ENOLCK;
 

diff .prev/fs/lockd/host.c ./fs/lockd/host.c
--- .prev/fs/lockd/host.c	2006-08-31 16:59:10.000000000 +1000
+++ ./fs/lockd/host.c	2006-08-31 16:23:12.000000000 +1000
@@ -39,19 +39,23 @@ static void			nlm_gc_hosts(void);
  * Find an NLM server handle in the cache. If there is none, create it.
  */
 struct nlm_host *
-nlmclnt_lookup_host(const struct sockaddr_in *sin, int proto, int version)
+nlmclnt_lookup_host(const struct sockaddr_in *sin, int proto, int version,
+			const char *hostname, int hostname_len)
 {
-	return nlm_lookup_host(0, sin, proto, version);
+	return nlm_lookup_host(0, sin, proto, version,
+			       hostname, hostname_len);
 }
 
 /*
  * Find an NLM client handle in the cache. If there is none, create it.
  */
 struct nlm_host *
-nlmsvc_lookup_host(struct svc_rqst *rqstp)
+nlmsvc_lookup_host(struct svc_rqst *rqstp,
+			const char *hostname, int hostname_len)
 {
 	return nlm_lookup_host(1, &rqstp->rq_addr,
-			       rqstp->rq_prot, rqstp->rq_vers);
+			       rqstp->rq_prot, rqstp->rq_vers,
+			       hostname, hostname_len);
 }
 
 /*
@@ -59,14 +63,20 @@ nlmsvc_lookup_host(struct svc_rqst *rqst
  */
 struct nlm_host *
 nlm_lookup_host(int server, const struct sockaddr_in *sin,
-					int proto, int version)
+					int proto, int version,
+					const char *hostname,
+					int hostname_len)
 {
 	struct nlm_host	*host, **hp;
 	u32		addr;
 	int		hash;
 
-	dprintk("lockd: nlm_lookup_host(%08x, p=%d, v=%d)\n",
-			(unsigned)(sin? ntohl(sin->sin_addr.s_addr) : 0), proto, version);
+	dprintk("lockd: nlm_lookup_host(%u.%u.%u.%u, p=%d, v=%d, my role=%s, name=%.*s)\n",
+			NIPQUAD(sin->sin_addr.s_addr), proto, version,
+			server? "server" : "client",
+			hostname_len,
+			hostname? hostname : "<none>");
+
 
 	hash = NLM_ADDRHASH(sin->sin_addr.s_addr);
 
@@ -267,19 +277,22 @@ void nlm_release_host(struct nlm_host *h
 void nlm_host_rebooted(const struct sockaddr_in *sin, const struct nlm_reboot *argp)
 {
 	struct nlm_host *host;
+	int server;
 
 	/* Obtain the host pointer for this NFS server and try to
 	 * reclaim all locks we hold on this server.
 	 */
-	if ((argp->proto & 1)==0) {
+	server = (argp->proto & 1)? 1 : 0;
+	host = nlm_lookup_host(server, sin, argp->proto >> 1, argp->vers,
+			argp->mon, argp->len);
+	if (host == NULL)
+		return;
+
+	if (server == 0) {
 		/* We are client, he's the server: try to reclaim all locks. */
-		if ((host = nlmclnt_lookup_host(sin, argp->proto >> 1, argp->vers)) == NULL)
-			return;
 		nlmclnt_recovery(host, argp->state);
 	} else {
 		/* He's the client, we're the server: delete all locks held by the client */
-		if ((host = nlm_lookup_host(1, sin, argp->proto >> 1, argp->vers)) == NULL)
-			return;
 		nlmsvc_free_host_resources(host);
 	}
 	nlm_release_host(host);

diff .prev/fs/lockd/svc4proc.c ./fs/lockd/svc4proc.c
--- .prev/fs/lockd/svc4proc.c	2006-08-31 16:59:10.000000000 +1000
+++ ./fs/lockd/svc4proc.c	2006-08-31 16:59:53.000000000 +1000
@@ -38,7 +38,7 @@ nlm4svc_retrieve_args(struct svc_rqst *r
 		return nlm_lck_denied_nolocks;
 
 	/* Obtain host handle */
-	if (!(host = nlmsvc_lookup_host(rqstp))
+	if (!(host = nlmsvc_lookup_host(rqstp, lock->caller, lock->len))
 	 || (argp->monitor && nsm_monitor(host) < 0))
 		goto no_locks;
 	*hostp = host;
@@ -260,7 +260,9 @@ static int nlm4svc_callback(struct svc_r
 	struct nlm_rqst	*call;
 	int stat;
 
-	host = nlmsvc_lookup_host(rqstp);
+	host = nlmsvc_lookup_host(rqstp,
+				  argp->lock.caller,
+				  argp->lock.len);
 	if (host == NULL)
 		return rpc_system_err;
 

diff .prev/fs/lockd/svclock.c ./fs/lockd/svclock.c
--- .prev/fs/lockd/svclock.c	2006-08-31 16:59:10.000000000 +1000
+++ ./fs/lockd/svclock.c	2006-08-31 16:23:12.000000000 +1000
@@ -179,7 +179,7 @@ nlmsvc_create_block(struct svc_rqst *rqs
 	struct nlm_rqst		*call = NULL;
 
 	/* Create host handle for callback */
-	host = nlmsvc_lookup_host(rqstp);
+	host = nlmsvc_lookup_host(rqstp, lock->caller, lock->len);
 	if (host == NULL)
 		return NULL;
 
@@ -451,6 +451,7 @@ nlmsvc_testlock(struct nlm_file *file, s
 				(long long)conflock->fl.fl_start,
 				(long long)conflock->fl.fl_end);
 		conflock->caller = "somehost";	/* FIXME */
+		conflock->len = strlen(conflock->caller);
 		conflock->oh.len = 0;		/* don't return OH info */
 		conflock->svid = conflock->fl.fl_pid;
 		return nlm_lck_denied;

diff .prev/fs/lockd/svcproc.c ./fs/lockd/svcproc.c
--- .prev/fs/lockd/svcproc.c	2006-08-31 16:59:10.000000000 +1000
+++ ./fs/lockd/svcproc.c	2006-08-31 16:59:39.000000000 +1000
@@ -66,7 +66,7 @@ nlmsvc_retrieve_args(struct svc_rqst *rq
 		return nlm_lck_denied_nolocks;
 
 	/* Obtain host handle */
-	if (!(host = nlmsvc_lookup_host(rqstp))
+	if (!(host = nlmsvc_lookup_host(rqstp, lock->caller, lock->len))
 	 || (argp->monitor && nsm_monitor(host) < 0))
 		goto no_locks;
 	*hostp = host;
@@ -287,7 +287,9 @@ static int nlmsvc_callback(struct svc_rq
 	struct nlm_rqst	*call;
 	int stat;
 
-	host = nlmsvc_lookup_host(rqstp);
+	host = nlmsvc_lookup_host(rqstp,
+				  argp->lock.caller,
+				  argp->lock.len);
 	if (host == NULL)
 		return rpc_system_err;
 

diff .prev/include/linux/lockd/lockd.h ./include/linux/lockd/lockd.h
--- .prev/include/linux/lockd/lockd.h	2006-08-31 16:59:10.000000000 +1000
+++ ./include/linux/lockd/lockd.h	2006-08-31 16:23:12.000000000 +1000
@@ -161,9 +161,9 @@ int		  nlmclnt_reclaim(struct nlm_host *
 /*
  * Host cache
  */
-struct nlm_host * nlmclnt_lookup_host(const struct sockaddr_in *, int, int);
-struct nlm_host * nlmsvc_lookup_host(struct svc_rqst *);
-struct nlm_host * nlm_lookup_host(int server, const struct sockaddr_in *, int, int);
+struct nlm_host * nlmclnt_lookup_host(const struct sockaddr_in *, int, int, const char *, int);
+struct nlm_host * nlmsvc_lookup_host(struct svc_rqst *, const char *, int);
+struct nlm_host * nlm_lookup_host(int server, const struct sockaddr_in *, int, int, const char *, int);
 struct rpc_clnt * nlm_bind_host(struct nlm_host *);
 void		  nlm_rebind_host(struct nlm_host *);
 struct nlm_host * nlm_get_host(struct nlm_host *);

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
