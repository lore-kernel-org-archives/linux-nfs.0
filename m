From: Olaf Kirch <okir@suse.de>
Subject: [PATCH 4/22] When looking up a lockd host,
	pass hostname & length
Date: Sat, 5 Aug 2006 15:06:47 +0200
Message-ID: <20060805130647.GA8034@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9Lrf-00078I-9H
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:51 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G9Lre-0000Sw-PU
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:51 -0700
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 0B1781FFC8
	for <nfs@lists.sourceforge.net>; Sat,  5 Aug 2006 15:06:48 +0200 (CEST)
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

From: Olaf Kirch <okir@suse.de>
Subject: When looking up a lockd host, pass hostname & length

  This patch adds the peer's hostname (and name length) to
  all calls to nlm*_lookup_host functions. A subsequent patch
  will make use of these.

Signed-off-by: okir@suse.de

 fs/lockd/clntproc.c         |    4 +++-
 fs/lockd/host.c             |   37 +++++++++++++++++++++++++------------
 fs/lockd/svc4proc.c         |    4 ++--
 fs/lockd/svclock.c          |    3 ++-
 fs/lockd/svcproc.c          |    4 ++--
 include/linux/lockd/lockd.h |    6 +++---
 6 files changed, 37 insertions(+), 21 deletions(-)

Index: build/fs/lockd/clntproc.c
===================================================================
--- build.orig/fs/lockd/clntproc.c
+++ build/fs/lockd/clntproc.c
@@ -151,6 +151,7 @@ static void nlmclnt_release_lockargs(str
 int
 nlmclnt_proc(struct inode *inode, int cmd, struct file_lock *fl)
 {
+	struct nfs_server	*nfssrv = NFS_SERVER(inode);
 	struct nlm_host		*host;
 	struct nlm_rqst		*call;
 	sigset_t		oldset;
@@ -166,7 +167,8 @@ nlmclnt_proc(struct inode *inode, int cm
 	/* Retrieve transport protocol from NFS client */
 	proto = NFS_CLIENT(inode)->cl_xprt->prot;
 
-	host = nlmclnt_lookup_host(NFS_ADDR(inode), proto, vers);
+	host = nlmclnt_lookup_host(NFS_ADDR(inode), proto, vers,
+				nfssrv->hostname, strlen(nfssrv->hostname));
 	if (host == NULL)
 		return -ENOLCK;
 
Index: build/fs/lockd/host.c
===================================================================
--- build.orig/fs/lockd/host.c
+++ build/fs/lockd/host.c
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
 
@@ -263,19 +273,22 @@ void nlm_release_host(struct nlm_host *h
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
Index: build/fs/lockd/svc4proc.c
===================================================================
--- build.orig/fs/lockd/svc4proc.c
+++ build/fs/lockd/svc4proc.c
@@ -38,7 +38,7 @@ nlm4svc_retrieve_args(struct svc_rqst *r
 		return nlm_lck_denied_nolocks;
 
 	/* Obtain host handle */
-	if (!(host = nlmsvc_lookup_host(rqstp))
+	if (!(host = nlmsvc_lookup_host(rqstp, lock->caller, lock->len))
 	 || (argp->monitor && nsm_monitor(host) < 0))
 		goto no_locks;
 	*hostp = host;
@@ -260,7 +260,7 @@ static int nlm4svc_callback(struct svc_r
 	struct nlm_rqst	*call;
 	int stat;
 
-	host = nlmsvc_lookup_host(rqstp);
+	host = nlmsvc_lookup_host(rqstp, NULL, 0);
 	if (host == NULL)
 		return rpc_system_err;
 
Index: build/fs/lockd/svclock.c
===================================================================
--- build.orig/fs/lockd/svclock.c
+++ build/fs/lockd/svclock.c
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
Index: build/fs/lockd/svcproc.c
===================================================================
--- build.orig/fs/lockd/svcproc.c
+++ build/fs/lockd/svcproc.c
@@ -66,7 +66,7 @@ nlmsvc_retrieve_args(struct svc_rqst *rq
 		return nlm_lck_denied_nolocks;
 
 	/* Obtain host handle */
-	if (!(host = nlmsvc_lookup_host(rqstp))
+	if (!(host = nlmsvc_lookup_host(rqstp, lock->caller, lock->len))
 	 || (argp->monitor && nsm_monitor(host) < 0))
 		goto no_locks;
 	*hostp = host;
@@ -287,7 +287,7 @@ static int nlmsvc_callback(struct svc_rq
 	struct nlm_rqst	*call;
 	int stat;
 
-	host = nlmsvc_lookup_host(rqstp);
+	host = nlmsvc_lookup_host(rqstp, NULL, 0);
 	if (host == NULL)
 		return rpc_system_err;
 
Index: build/include/linux/lockd/lockd.h
===================================================================
--- build.orig/include/linux/lockd/lockd.h
+++ build/include/linux/lockd/lockd.h
@@ -163,9 +163,9 @@ int		  nlmclnt_reclaim(struct nlm_host *
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
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
