From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] sunrpc - 3 of 3 - Some tidyup of svc_authenticate
Date: Tue, 07 Jan 2003 13:39:40 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18VjeW-00071v-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net,  Chuck Lever <cel@citi.umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Vjee-0005sS-00
	for <nfs@lists.sourceforge.net>; Mon, 06 Jan 2003 18:39:48 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <cel@citi.umich.edu>) By tone With Smtp ;
	Tue, 7 Jan 2003 13:39:40 +1100
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


### Comments for ChangeSet
Instead of returning rpc_stat in a by-reference parameter,
we encode that status in the return value.

Also, don't pass 'proc' parameter to ->accept, as it is 
implicit in rqstp.



 ----------- Diffstat output ------------
 ./include/linux/sunrpc/svcauth.h |    4 ++--
 ./net/sunrpc/svc.c               |   27 +++++++++++++++++----------
 ./net/sunrpc/svcauth.c           |   21 +++------------------
 ./net/sunrpc/svcauth_unix.c      |    8 ++++----
 4 files changed, 26 insertions(+), 34 deletions(-)

diff ./include/linux/sunrpc/svcauth.h~current~ ./include/linux/sunrpc/svcauth.h
--- ./include/linux/sunrpc/svcauth.h~current~	2003-01-07 13:36:43.000000000 +1100
+++ ./include/linux/sunrpc/svcauth.h	2003-01-07 13:36:43.000000000 +1100
@@ -83,7 +83,7 @@ struct auth_domain {
 struct auth_ops {
 	char *	name;
 	int	flavour;
-	int	(*accept)(struct svc_rqst *rq, u32 *authp, int proc);
+	int	(*accept)(struct svc_rqst *rq, u32 *authp);
 	int	(*release)(struct svc_rqst *rq);
 	void	(*domain_release)(struct auth_domain *);
 };
@@ -99,7 +99,7 @@ extern struct auth_ops	*authtab[RPC_AUTH
 #define	SVC_PENDING	8
 
 
-extern int	svc_authenticate(struct svc_rqst *rqstp, u32 *statp, u32 *authp, int proc);
+extern int	svc_authenticate(struct svc_rqst *rqstp, u32 *authp);
 extern int	svc_authorise(struct svc_rqst *rqstp);
 extern int	svc_auth_register(rpc_authflavor_t flavor, struct auth_ops *aops);
 extern void	svc_auth_unregister(rpc_authflavor_t flavor);

diff ./net/sunrpc/svc.c~current~ ./net/sunrpc/svc.c
--- ./net/sunrpc/svc.c~current~	2003-01-07 13:36:43.000000000 +1100
+++ ./net/sunrpc/svc.c	2003-01-07 13:36:43.000000000 +1100
@@ -304,16 +304,21 @@ svc_process(struct svc_serv *serv, struc
 	 * We do this before anything else in order to get a decent
 	 * auth verifier.
 	 */
-	if (svc_authenticate(rqstp, &rpc_stat, &auth_stat, proc))
-		/* drop the request, it has probably been deferred */
-		goto dropit;
-
-	if (rpc_stat != rpc_success)
-		goto err_garbage;
-
-	if (auth_stat != rpc_auth_ok)
+	switch (svc_authenticate(rqstp, &auth_stat)) {
+	case SVC_OK:
+		break;
+	case SVC_GARBAGE:
+		rpc_stat = rpc_garbage_args;
+		goto err_bad;
+	case SVC_SYSERR:
+		rpc_stat = rpc_system_err;
+		goto err_bad;
+	case SVC_DENIED:
 		goto err_bad_auth;
-
+	case SVC_DROP:
+		goto dropit;
+	}
+		
 	progp = serv->sv_program;
 	if (prog != progp->pg_prog)
 		goto err_bad_prog;
@@ -458,7 +463,9 @@ err_garbage:
 #ifdef RPC_PARANOIA
 	printk("svc: failed to decode args\n");
 #endif
+	rpc_stat = rpc_garbage_args;
+err_bad:
 	serv->sv_stats->rpcbadfmt++;
-	svc_putu32(resv, rpc_garbage_args);
+	svc_putu32(resv, rpc_stat);
 	goto sendit;
 }

diff ./net/sunrpc/svcauth.c~current~ ./net/sunrpc/svcauth.c
--- ./net/sunrpc/svcauth.c~current~	2003-01-07 13:36:43.000000000 +1100
+++ ./net/sunrpc/svcauth.c	2003-01-07 13:36:43.000000000 +1100
@@ -33,12 +33,11 @@ static struct auth_ops	*authtab[RPC_AUTH
 };
 
 int
-svc_authenticate(struct svc_rqst *rqstp, u32 *statp, u32 *authp, int proc)
+svc_authenticate(struct svc_rqst *rqstp, u32 *authp)
 {
 	rpc_authflavor_t	flavor;
 	struct auth_ops		*aops;
 
-	*statp = rpc_success;
 	*authp = rpc_auth_ok;
 
 	flavor = ntohl(svc_getu32(&rqstp->rq_arg.head[0]));
@@ -46,25 +45,11 @@ svc_authenticate(struct svc_rqst *rqstp,
 	dprintk("svc: svc_authenticate (%d)\n", flavor);
 	if (flavor >= RPC_AUTH_MAXFLAVOR || !(aops = authtab[flavor])) {
 		*authp = rpc_autherr_badcred;
-		return 0;
+		return SVC_DENIED;
 	}
 
 	rqstp->rq_authop = aops;
-	switch (aops->accept(rqstp, authp, proc)) {
-	case SVC_OK:
-		return 0;
-	case SVC_GARBAGE:
-		*statp = rpc_garbage_args;
-		return 0;
-	case SVC_SYSERR:
-		*statp = rpc_system_err;
-		return 0;
-	case SVC_DENIED:
-		return 0;
-	case SVC_DROP:
-		break;
-	}
-	return 1; /* drop the request */
+	return aops->accept(rqstp, authp);
 }
 
 /* A reqeust, which was authenticated, has now executed.

diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
--- ./net/sunrpc/svcauth_unix.c~current~	2003-01-07 13:36:43.000000000 +1100
+++ ./net/sunrpc/svcauth_unix.c	2003-01-07 13:36:43.000000000 +1100
@@ -321,7 +321,7 @@ void svcauth_unix_purge(void)
 
 
 static int
-svcauth_null_accept(struct svc_rqst *rqstp, u32 *authp, int proc)
+svcauth_null_accept(struct svc_rqst *rqstp, u32 *authp)
 {
 	struct iovec	*argv = &rqstp->rq_arg.head[0];
 	struct iovec	*resv = &rqstp->rq_res.head[0];
@@ -376,7 +376,7 @@ svcauth_null_accept(struct svc_rqst *rqs
 		}
 	else rv = SVC_DROP;
 
-	if (rqstp->rq_client == NULL && proc != 0)
+	if (rqstp->rq_client == NULL && rqstp->rq_proc != 0)
 		*authp = rpc_autherr_badcred;
 
 	return rv;
@@ -402,7 +402,7 @@ struct auth_ops svcauth_null = {
 
 
 int
-svcauth_unix_accept(struct svc_rqst *rqstp, u32 *authp, int proc)
+svcauth_unix_accept(struct svc_rqst *rqstp, u32 *authp)
 {
 	struct iovec	*argv = &rqstp->rq_arg.head[0];
 	struct iovec	*resv = &rqstp->rq_res.head[0];
@@ -470,7 +470,7 @@ svcauth_unix_accept(struct svc_rqst *rqs
 		}
 	else rv = SVC_DROP;
 
-	if (rqstp->rq_client == NULL && proc != 0)
+	if (rqstp->rq_client == NULL && rqstp->rq_proc != 0)
 		goto badcred;
 	return rv;
 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
