From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 17 - Tidy up the rpc authentication interface.
Date: Fri, 11 Oct 2002 15:27:30 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17zsKg-0003ax-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zsL5-0003fU-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 22:27:56 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 11 Oct 2002 15:27:38 +1000
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


[This is the third set of nfsd patches today.  The ordering is:
 first:  set of 4   - misc fixes
 second: set of 8   - NFSv4 support
 finally:set of 17  - new caching infrastructure
]
This series of 17 patches introduces a new caching infrastructure
for rpc services such as nfsd.  It is used to store authentication
information and anything else that the service needs from user-space.

In the first instance it will store:

- mapping from IP address to client.
- mapping from client + filehandle fragment to directory
- mapping from client + directory to export options.

There is (will be) a facility for the kernel to request information
from user space, and for user-space to fill in that information in a
cache.

Eventually this infrastructure will be used for supporting NFSv4
(which needs username/uid mappings) and cryptographic authentication
(which needs per-user crypto context from user-space).

The last 7 patches in this set will be sent to linux-kernel was well
as they implement the kernel<->user communication and so are likely to
be of wider interest.

Note: this new code is still fully  backwards compatable with
the current nfs-utils.  They will cause entries to be put in
the caches with a expiry date in 2038, and as they don't show any
interest in the upcall mechanism any entries found to be missing
in the cache wil be treated as negative entries.

### Comments for ChangeSet

Define auth_ops that contains a method for authenticating a request and a 
method for authorising a reply.  Call both methods as appropriate.

Also discard rq_verfed and cr_flavour, neither ever used.
And discard rq_auth as it isn't needed.


 ----------- Diffstat output ------------
 ./fs/nfsd/nfssvc.c               |    2 
 ./include/linux/sunrpc/svc.h     |    9 +-
 ./include/linux/sunrpc/svcauth.h |   66 ++++++++++++++------
 ./net/sunrpc/svc.c               |   18 ++---
 ./net/sunrpc/svcauth.c           |  127 +++++++++++++++++++++++++++------------
 ./net/sunrpc/svcsock.c           |    1 
 6 files changed, 152 insertions(+), 71 deletions(-)

--- ./include/linux/sunrpc/svc.h	2002/10/11 00:40:49	1.1
+++ ./include/linux/sunrpc/svc.h	2002/10/11 00:41:07	1.2
@@ -98,6 +98,7 @@ struct svc_rqst {
 
 	struct svc_serv *	rq_server;	/* RPC service definition */
 	struct svc_procedure *	rq_procinfo;	/* procedure info */
+	struct auth_ops *	rq_authop;	/* authentication flavour */
 	struct svc_cred		rq_cred;	/* auth info */
 	struct sk_buff *	rq_skbuff;	/* fast recv inet buffer */
 	struct svc_buf		rq_defbuf;	/* default buffer */
@@ -108,10 +109,10 @@ struct svc_rqst {
 	u32			rq_vers;	/* program version */
 	u32			rq_proc;	/* procedure number */
 	u32			rq_prot;	/* IP protocol */
-	unsigned short		rq_verfed  : 1,	/* reply has verifier */
+	unsigned short
 				rq_userset : 1,	/* auth->setuser OK */
-				rq_secure  : 1,	/* secure port */
-				rq_auth    : 1;	/* check client */
+				rq_secure  : 1;	/* secure port */
+
 
 	void *			rq_argp;	/* decoded arguments */
 	void *			rq_resp;	/* xdr'd results */
@@ -128,7 +129,7 @@ struct svc_rqst {
 						 * to report (real or virtual)
 						 */
 
-	wait_queue_head_t	rq_wait;	/* synchronozation */
+	wait_queue_head_t	rq_wait;	/* synchronization */
 };
 
 /*
--- ./include/linux/sunrpc/svcauth.h	2002/10/11 00:40:49	1.1
+++ ./include/linux/sunrpc/svcauth.h	2002/10/11 00:41:07	1.2
@@ -14,34 +14,64 @@
 #include <linux/sunrpc/msg_prot.h>
 
 struct svc_cred {
-	rpc_authflavor_t	cr_flavor;
 	uid_t			cr_uid;
 	gid_t			cr_gid;
 	gid_t			cr_groups[NGROUPS];
 };
 
 struct svc_rqst;		/* forward decl */
-
-void	svc_authenticate(struct svc_rqst *rqstp, u32 *statp, u32 *authp);
-int	svc_auth_register(rpc_authflavor_t flavor,
-				void (*)(struct svc_rqst *,u32 *,u32 *));
-void	svc_auth_unregister(rpc_authflavor_t flavor);
-
-#if 0
 /*
- * Decoded AUTH_UNIX data. This is different from what's in the RPC lib.
+ * Each authentication flavour registers an auth_ops
+ * structure.
+ * name is simply the name.
+ * flavour gives the auth flavour. It determines where the flavour is registered
+ * accept() is given a request and should verify it.
+ *   It should inspect the authenticator and verifier, and possibly the data.
+ *    If there is a problem with the authentication *authp should be set.
+ *    The return value of accept() can indicate:
+ *      OK - authorised. client and credential are set in rqstp.
+ *           reqbuf points to arguments
+ *           resbuf points to good place for results.  verfier
+ *             is (probably) already in place.  Certainly space is
+ *	       reserved for it.
+ *      DROP - simply drop the request. It may have been deferred
+ *      GARBAGE - rpc garbage_args error
+ *      SYSERR - rpc system_err error
+ *      DENIED - authp holds reason for denial.
+ *
+ *   accept is passed the proc number so that it can accept NULL rpc requests
+ *   even if it cannot authenticate the client (as is sometimes appropriate).
+ *
+ * release() is given a request after the procedure has been run.
+ *  It should sign/encrypt the results if needed
+ * It should return:
+ *    OK - the resbuf is ready to be sent
+ *    DROP - the reply should be quitely dropped
+ *    DENIED - authp holds a reason for MSG_DENIED
+ *    SYSERR - rpc system_err
  */
-#define NGRPS		16
-struct authunix_parms {
-	u32		aup_stamp;
-	u32		aup_uid;
-	u32		aup_gid;
-	u32		aup_len;
-	u32		aup_gids[NGRPS];
+struct auth_ops {
+	char *	name;
+	int	flavour;
+	int	(*accept)(struct svc_rqst *rq, u32 *authp, int proc);
+	int	(*release)(struct svc_rqst *rq);
 };
+extern struct auth_ops	*authtab[RPC_AUTH_MAXFLAVOR];
 
-struct svc_authops *	auth_getops(rpc_authflavor_t flavor);
-#endif
+#define	SVC_GARBAGE	1
+#define	SVC_SYSERR	2
+#define	SVC_VALID	3
+#define	SVC_NEGATIVE	4
+#define	SVC_OK		5
+#define	SVC_DROP	6
+#define	SVC_DENIED	7
+#define	SVC_PENDING	8
+
+
+extern int	svc_authenticate(struct svc_rqst *rqstp, u32 *statp, u32 *authp, int proc);
+extern int	svc_authorise(struct svc_rqst *rqstp);
+extern int	svc_auth_register(rpc_authflavor_t flavor, struct auth_ops *aops);
+extern void	svc_auth_unregister(rpc_authflavor_t flavor);
 
 
 #endif /* __KERNEL__ */
--- ./fs/nfsd/nfssvc.c	2002/10/10 23:24:44	1.3
+++ ./fs/nfsd/nfssvc.c	2002/10/11 00:41:07	1.4
@@ -173,8 +173,6 @@ nfsd(struct svc_rqst *rqstp)
 	current->rlim[RLIMIT_FSIZE].rlim_cur = RLIM_INFINITY;
 
 	nfsdstats.th_cnt++;
-	/* Let svc_process check client's authentication. */
-	rqstp->rq_auth = 1;
 
 	lockd_up();				/* start lockd */
 
--- ./net/sunrpc/svc.c	2002/10/11 00:40:50	1.1
+++ ./net/sunrpc/svc.c	2002/10/11 00:41:07	1.2
@@ -262,18 +262,14 @@ svc_process(struct svc_serv *serv, struc
 	argp->buf += 5;
 	argp->len -= 5;
 
-	/* Used by nfsd to only allow the NULL procedure for amd. */
-	if (rqstp->rq_auth && !rqstp->rq_client && proc) {
-		auth_stat = rpc_autherr_badcred;
-		goto err_bad_auth;
-	}
-
 	/*
 	 * Decode auth data, and add verifier to reply buffer.
 	 * We do this before anything else in order to get a decent
 	 * auth verifier.
 	 */
-	svc_authenticate(rqstp, &rpc_stat, &auth_stat);
+	if (svc_authenticate(rqstp, &rpc_stat, &auth_stat, proc))
+		/* drop the request, it has probably been deferred */
+		goto dropit;
 
 	if (rpc_stat != rpc_success)
 		goto err_garbage;
@@ -347,10 +343,14 @@ svc_process(struct svc_serv *serv, struc
 
 	if (procp->pc_encode == NULL)
 		goto dropit;
-sendit:
+
+ sendit:
+	if (svc_authorise(rqstp))
+		goto dropit;
 	return svc_send(rqstp);
 
-dropit:
+ dropit:
+	svc_authorise(rqstp);	/* doesn't hurt to call this twice */
 	dprintk("svc: svc_process dropit\n");
 	svc_drop(rqstp);
 	return 0;
--- ./net/sunrpc/svcauth.c	2002/10/11 00:40:50	1.1
+++ ./net/sunrpc/svcauth.c	2002/10/11 00:41:07	1.2
@@ -20,30 +20,40 @@
 #define RPCDBG_FACILITY	RPCDBG_AUTH
 
 /*
- * Type of authenticator function
- */
-typedef void	(*auth_fn_t)(struct svc_rqst *rqstp, u32 *statp, u32 *authp);
-
-/*
  * Builtin auth flavors
  */
-static void	svcauth_null(struct svc_rqst *rqstp, u32 *statp, u32 *authp);
-static void	svcauth_unix(struct svc_rqst *rqstp, u32 *statp, u32 *authp);
+static int	svcauth_null_accept(struct svc_rqst *rqstp, u32 *authp, int proc);
+static int	svcauth_null_release(struct svc_rqst *rqstp);
+static int	svcauth_unix_accept(struct svc_rqst *rqstp, u32 *authp, int proc);
+static int	svcauth_unix_release(struct svc_rqst *rqstp);
+
+struct auth_ops svcauth_null = {
+	.name		= "null",
+	.flavour	= RPC_AUTH_NULL,
+	.accept 	= svcauth_null_accept,
+	.release	= svcauth_null_release,
+};
+
+struct auth_ops svcauth_unix = {
+	.name		= "unix",
+	.flavour	= RPC_AUTH_UNIX,
+	.accept 	= svcauth_unix_accept,
+	.release	= svcauth_unix_release,
+};
 
 /*
  * Table of authenticators
  */
-static auth_fn_t	authtab[RPC_AUTH_MAXFLAVOR] = {
-	svcauth_null,
-	svcauth_unix,
-	NULL,
+static struct auth_ops	*authtab[RPC_AUTH_MAXFLAVOR] = {
+	[0] = &svcauth_null,
+	[1] = &svcauth_unix,
 };
 
-void
-svc_authenticate(struct svc_rqst *rqstp, u32 *statp, u32 *authp)
+int
+svc_authenticate(struct svc_rqst *rqstp, u32 *statp, u32 *authp, int proc)
 {
 	rpc_authflavor_t	flavor;
-	auth_fn_t		func;
+	struct auth_ops		*aops;
 
 	*statp = rpc_success;
 	*authp = rpc_auth_ok;
@@ -52,21 +62,53 @@ svc_authenticate(struct svc_rqst *rqstp,
 	flavor = ntohl(flavor);
 
 	dprintk("svc: svc_authenticate (%d)\n", flavor);
-	if (flavor >= RPC_AUTH_MAXFLAVOR || !(func = authtab[flavor])) {
+	if (flavor >= RPC_AUTH_MAXFLAVOR || !(aops = authtab[flavor])) {
 		*authp = rpc_autherr_badcred;
-		return;
+		return 0;
+	}
+
+	rqstp->rq_authop = aops;
+	switch (aops->accept(rqstp, authp, proc)) {
+	case SVC_OK:
+		return 0;
+	case SVC_GARBAGE:
+		*statp = rpc_garbage_args;
+		return 0;
+	case SVC_SYSERR:
+		*statp = rpc_system_err;
+		return 0;
+	case SVC_DENIED:
+		return 0;
+	case SVC_DROP:
+		break;
 	}
+	return 1; /* drop the request */
+}
+
+/* A reqeust, which was authenticated, has now executed.
+ * Time to finalise the the credentials and verifier
+ * and release and resources
+ */
+int svc_authorise(struct svc_rqst *rqstp)
+{
+	struct auth_ops *aops = rqstp->rq_authop;
+	int rv = 0;
 
-	rqstp->rq_cred.cr_flavor = flavor;
-	func(rqstp, statp, authp);
+	rqstp->rq_authop = NULL;
+	
+	if (aops) 
+		rv = aops->release(rqstp);
+
+	/* FIXME should I count and release authops */
+	return rv;
 }
 
 int
-svc_auth_register(rpc_authflavor_t flavor, auth_fn_t func)
+svc_auth_register(rpc_authflavor_t flavor, struct auth_ops *aops)
 {
 	if (flavor >= RPC_AUTH_MAXFLAVOR || authtab[flavor])
 		return -EINVAL;
-	authtab[flavor] = func;
+	authtab[flavor] = aops;
 	return 0;
 }
 
@@ -77,25 +119,24 @@ svc_auth_unregister(rpc_authflavor_t fla
 		authtab[flavor] = NULL;
 }
 
-static void
-svcauth_null(struct svc_rqst *rqstp, u32 *statp, u32 *authp)
+static int
+svcauth_null_accept(struct svc_rqst *rqstp, u32 *authp, int proc)
 {
 	struct svc_buf	*argp = &rqstp->rq_argbuf;
 	struct svc_buf	*resp = &rqstp->rq_resbuf;
 
 	if ((argp->len -= 3) < 0) {
-		*statp = rpc_garbage_args;
-		return;
+		return SVC_GARBAGE;
 	}
 	if (*(argp->buf)++ != 0) {	/* we already skipped the flavor */
 		dprintk("svc: bad null cred\n");
 		*authp = rpc_autherr_badcred;
-		return;
+		return SVC_DENIED;
 	}
 	if (*(argp->buf)++ != RPC_AUTH_NULL || *(argp->buf)++ != 0) {
 		dprintk("svc: bad null verf\n");
 		*authp = rpc_autherr_badverf;
-		return;
+		return SVC_DENIED;
 	}
 
 	/* Signal that mapping to nobody uid/gid is required */
@@ -104,13 +145,19 @@ svcauth_null(struct svc_rqst *rqstp, u32
 	rqstp->rq_cred.cr_groups[0] = NOGROUP;
 
 	/* Put NULL verifier */
-	rqstp->rq_verfed = 1;
 	svc_putu32(resp, RPC_AUTH_NULL);
 	svc_putu32(resp, 0);
+	return SVC_OK;
+}
+
+static int
+svcauth_null_release(struct svc_rqst *rqstp)
+{
+	return 0; /* don't drop */
 }
 
-static void
-svcauth_unix(struct svc_rqst *rqstp, u32 *statp, u32 *authp)
+static int
+svcauth_unix_accept(struct svc_rqst *rqstp, u32 *authp, int proc)
 {
 	struct svc_buf	*argp = &rqstp->rq_argbuf;
 	struct svc_buf	*resp = &rqstp->rq_resbuf;
@@ -118,14 +165,12 @@ svcauth_unix(struct svc_rqst *rqstp, u32
 	u32		*bufp = argp->buf, slen, i;
 	int		len   = argp->len;
 
-	if ((len -= 3) < 0) {
-		*statp = rpc_garbage_args;
-		return;
-	}
+	if ((len -= 3) < 0)
+		return SVC_GARBAGE;
 
 	bufp++;					/* length */
 	bufp++;					/* time stamp */
-	slen = (ntohl(*bufp++) + 3) >> 2;	/* machname length */
+	slen = XDR_QUADLEN(ntohl(*bufp++));	/* machname length */
 	if (slen > 64 || (len -= slen + 3) < 0)
 		goto badcred;
 	bufp += slen;				/* skip machname */
@@ -144,19 +189,27 @@ svcauth_unix(struct svc_rqst *rqstp, u32
 
 	if (*bufp++ != RPC_AUTH_NULL || *bufp++ != 0) {
 		*authp = rpc_autherr_badverf;
-		return;
+		return SVC_DENIED;
 	}
 
 	argp->buf = bufp;
 	argp->len = len;
 
 	/* Put NULL verifier */
-	rqstp->rq_verfed = 1;
 	svc_putu32(resp, RPC_AUTH_NULL);
 	svc_putu32(resp, 0);
 
-	return;
+	return SVC_OK;
 
 badcred:
 	*authp = rpc_autherr_badcred;
+	return SVC_DENIED;
+}
+
+static int
+svcauth_unix_release(struct svc_rqst *rqstp)
+{
+	/* Verifier (such as it is) is already in place.
+	 */
+	return 0;
 }
--- ./net/sunrpc/svcsock.c	2002/10/11 00:40:50	1.1
+++ ./net/sunrpc/svcsock.c	2002/10/11 00:41:07	1.2
@@ -1089,7 +1089,6 @@ svc_recv(struct svc_serv *serv, struct s
 
 	rqstp->rq_secure  = ntohs(rqstp->rq_addr.sin_port) < 1024;
 	rqstp->rq_userset = 0;
-	rqstp->rq_verfed  = 0;
 
 	svc_getu32(&rqstp->rq_argbuf, rqstp->rq_xid);
 	svc_putu32(&rqstp->rq_resbuf, rqstp->rq_xid);


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
