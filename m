From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 17 - Move auth domain lookup into svcauth
Date: Fri, 11 Oct 2002 15:27:31 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17zsKh-0003b8-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zsLC-0003fu-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 22:28:03 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 11 Oct 2002 15:27:43 +1000
To: Linus Torvalds <torvalds@transmeta.com>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


### Comments for ChangeSet

Instead of doing the lookup from ipaddr to domain inside
the nfs server, (and also when lockd calls into nfsd) it is
now done at the rpc authentication level which is a more
sensible place for it.

Note that both AUTH_UNIX and AUTH_NULL do the same lookup.

So that the rpc layer knows that nfsd and lockd both uses the
name space of domains (while other hypothetical services may
not) we introduce a 'class' for each service which svc_auth combines
with the IP address when doing a lookup.



 ----------- Diffstat output ------------
 ./fs/lockd/svc.c             |    1 
 ./fs/nfsd/lockd.c            |    8 ----
 ./fs/nfsd/nfsfh.c            |    2 +
 ./fs/nfsd/nfssvc.c           |    9 -----
 ./fs/nfsd/vfs.c              |    2 -
 ./include/linux/sunrpc/svc.h |    1 
 ./net/sunrpc/svcauth_unix.c  |   72 +++++++++++++++++++++++++++++++++++++++++--
 7 files changed, 77 insertions(+), 18 deletions(-)

--- ./include/linux/sunrpc/svc.h	2002/10/11 00:51:15	1.3
+++ ./include/linux/sunrpc/svc.h	2002/10/11 00:57:14	1.4
@@ -142,6 +142,7 @@ struct svc_program {
 	unsigned int		pg_nvers;	/* number of versions */
 	struct svc_version **	pg_vers;	/* version array */
 	char *			pg_name;	/* service name */
+	char *			pg_class;	/* class name: services sharing authentication */
 	struct svc_stat *	pg_stats;	/* rpc statistics */
 };
 
--- ./fs/nfsd/nfssvc.c	2002/10/11 00:51:15	1.5
+++ ./fs/nfsd/nfssvc.c	2002/10/11 00:57:14	1.6
@@ -206,10 +206,6 @@ nfsd(struct svc_rqst *rqstp)
 		/* Lock the export hash tables for reading. */
 		exp_readlock();
 
-		/* Validate the client's address. This will also defeat
-		 * port probes on port 2049 by unauthorized clients.
-		 */
-		rqstp->rq_client = exp_getclient(&rqstp->rq_addr);
 		/* Process request with signals blocked.  */
 		spin_lock_irq(&current->sig->siglock);
 		siginitsetinv(&current->blocked, ALLOWED_SIGS);
@@ -219,10 +215,6 @@ nfsd(struct svc_rqst *rqstp)
 		svc_process(serv, rqstp);
 
 		/* Unlock export hash tables */
-		if (rqstp->rq_client) {
-			auth_domain_put(rqstp->rq_client);
-			rqstp->rq_client = NULL;
-		}
 		exp_readunlock();
 		update_thread_usage(atomic_read(&nfsd_busy));
 		atomic_dec(&nfsd_busy);
@@ -369,5 +361,6 @@ struct svc_program		nfsd_program = {
 	.pg_nvers		= NFSD_NRVERS,		/* nr of entries in nfsd_version */
 	.pg_vers		= nfsd_version,		/* version table */
 	.pg_name		= "nfsd",		/* program name */
+	.pg_class		= "nfsd",		/* authentication class */
 	.pg_stats		= &nfsd_svcstats,	/* version table */
 };
--- ./fs/nfsd/vfs.c	2002/10/11 00:56:51	1.1
+++ ./fs/nfsd/vfs.c	2002/10/11 00:57:14	1.2
@@ -154,7 +154,7 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 			struct dentry *mounts = dget(dentry);
 			while (follow_down(&mnt,&mounts)&&d_mountpoint(mounts))
 				;
-			exp2 = exp_get_by_name(rqstp->rq_client, mnt, mounts);
+			exp2 = exp_get_by_name(exp->ex_client, mnt, mounts);
 			if (exp2 && EX_CROSSMNT(exp2)) {
 				/* successfully crossed mount point */
 				exp = exp2;
--- ./fs/nfsd/lockd.c	2002/10/11 00:51:15	1.2
+++ ./fs/nfsd/lockd.c	2002/10/11 00:57:14	1.3
@@ -32,18 +32,12 @@ nlm_fopen(struct svc_rqst *rqstp, struct
 	fh.fh_export = NULL;
 
 	exp_readlock();
-	rqstp->rq_client = exp_getclient(&rqstp->rq_addr);
-	if (rqstp->rq_client == NULL)
-		nfserr = nfserr_stale;
-	else
-		nfserr = nfsd_open(rqstp, &fh, S_IFREG, MAY_LOCK, filp);
+	nfserr = nfsd_open(rqstp, &fh, S_IFREG, MAY_LOCK, filp);
 	if (!nfserr) {
 		dget(filp->f_dentry);
 		mntget(filp->f_vfsmnt);
 	}
 	fh_put(&fh);
-	if (rqstp->rq_client)
-		auth_domain_put(rqstp->rq_client);
 	rqstp->rq_client = NULL;
 	exp_readunlock();
  	/* nlm and nfsd don't share error codes.
--- ./fs/nfsd/nfsfh.c	2002/10/11 00:56:51	1.1
+++ ./fs/nfsd/nfsfh.c	2002/10/11 00:57:14	1.2
@@ -103,6 +103,8 @@ fh_verify(struct svc_rqst *rqstp, struct
 		int data_left = fh->fh_size/4;
 
 		error = nfserr_stale;
+		if (rqstp->rq_client == NULL)
+			goto out;
 		if (rqstp->rq_vers > 2)
 			error = nfserr_badhandle;
 		if (rqstp->rq_vers == 4 && fh->fh_size == 0)
--- ./fs/lockd/svc.c	2002/10/11 00:56:51	1.1
+++ ./fs/lockd/svc.c	2002/10/11 00:57:14	1.2
@@ -389,5 +389,6 @@ struct svc_program	nlmsvc_program = {
 	.pg_nvers	= NLM_NRVERS,		/* number of entries in nlmsvc_version */
 	.pg_vers	= nlmsvc_version,	/* version table */
 	.pg_name	= "lockd",		/* service name */
+	.pg_class	= "nfsd",		/* share authentication with nfsd */
 	.pg_stats	= &nlmsvc_stats,	/* stats table */
 };
--- ./net/sunrpc/svcauth_unix.c	2002/10/11 00:51:16	1.2
+++ ./net/sunrpc/svcauth_unix.c	2002/10/11 00:57:15	1.3
@@ -201,6 +201,8 @@ svcauth_null_accept(struct svc_rqst *rqs
 {
 	struct svc_buf	*argp = &rqstp->rq_argbuf;
 	struct svc_buf	*resp = &rqstp->rq_resbuf;
+	int		rv=0;
+	struct ip_map key, *ipm;
 
 	if ((argp->len -= 3) < 0) {
 		return SVC_GARBAGE;
@@ -224,12 +226,45 @@ svcauth_null_accept(struct svc_rqst *rqs
 	/* Put NULL verifier */
 	svc_putu32(resp, RPC_AUTH_NULL);
 	svc_putu32(resp, 0);
-	return SVC_OK;
+
+	key.m_class = rqstp->rq_server->sv_program->pg_class;
+	key.m_addr = rqstp->rq_addr.sin_addr;
+
+	ipm = ip_map_lookup(&key, 0);
+
+	rqstp->rq_client = NULL;
+
+	if (ipm)
+		switch (cache_check(&ip_map_cache, &ipm->h)) {
+		case -EAGAIN:
+			rv = SVC_DROP;
+			break;
+		case -ENOENT:
+			rv = SVC_OK; /* rq_client is NULL */
+			break;
+		case 0:
+			rqstp->rq_client = &ipm->m_client->h;
+			cache_get(&rqstp->rq_client->h);
+			ip_map_put(&ipm->h, &ip_map_cache);
+			rv = SVC_OK;
+			break;
+		default: BUG();
+		}
+	else rv = SVC_DROP;
+
+	if (rqstp->rq_client == NULL && proc != 0)
+		*authp = rpc_autherr_badcred;
+
+	return rv;
 }
 
 static int
 svcauth_null_release(struct svc_rqst *rqstp)
 {
+	if (rqstp->rq_client)
+		auth_domain_put(rqstp->rq_client);
+	rqstp->rq_client = NULL;
+
 	return 0; /* don't drop */
 }
 
@@ -250,6 +285,8 @@ svcauth_unix_accept(struct svc_rqst *rqs
 	struct svc_cred	*cred = &rqstp->rq_cred;
 	u32		*bufp = argp->buf, slen, i;
 	int		len   = argp->len;
+	int		rv=0;
+	struct ip_map key, *ipm;
 
 	if ((len -= 3) < 0)
 		return SVC_GARBAGE;
@@ -285,7 +322,34 @@ svcauth_unix_accept(struct svc_rqst *rqs
 	svc_putu32(resp, RPC_AUTH_NULL);
 	svc_putu32(resp, 0);
 
-	return SVC_OK;
+	key.m_class = rqstp->rq_server->sv_program->pg_class;
+	key.m_addr = rqstp->rq_addr.sin_addr;
+
+	ipm = ip_map_lookup(&key, 0);
+
+	rqstp->rq_client = NULL;
+
+	if (ipm)
+		switch (cache_check(&ip_map_cache, &ipm->h)) {
+		case -EAGAIN:
+			rv = SVC_DROP;
+			break;
+		case -ENOENT:
+			rv = SVC_OK; /* rq_client is NULL */
+			break;
+		case 0:
+			rqstp->rq_client = &ipm->m_client->h;
+			cache_get(&rqstp->rq_client->h);
+			ip_map_put(&ipm->h, &ip_map_cache);
+			rv = SVC_OK;
+			break;
+		default: BUG();
+		}
+	else rv = SVC_DROP;
+
+	if (rqstp->rq_client == NULL && proc != 0)
+		goto badcred;
+	return rv;
 
 badcred:
 	*authp = rpc_autherr_badcred;
@@ -297,6 +361,10 @@ svcauth_unix_release(struct svc_rqst *rq
 {
 	/* Verifier (such as it is) is already in place.
 	 */
+	if (rqstp->rq_client)
+		auth_domain_put(rqstp->rq_client);
+	rqstp->rq_client = NULL;
+
 	return 0;
 }
 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
