From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH 3 of 6] svcrpc: move export table checks to a per-program pg_add_client method
Date: Fri, 24 Sep 2004 14:04:16 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16723.40128.804230.618580@cse.unsw.edu.au>
References: <1095375544.839c1c96.3@fieldses.org>
	<1095383919.10216.142.camel@lade.trondhjem.org>
	<20040917022015.GA15212@fieldses.org>
	<16721.8596.980204.899779@cse.unsw.edu.au>
	<20040923214644.GA19291@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAhJv-0001Kt-5Z
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:04:31 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CAhJt-0003U3-KI
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:04:31 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: message from J. Bruce Fields on Thursday September 23
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thursday September 23, bfields@fieldses.org wrote:
> On Wed, Sep 22, 2004 at 04:54:12PM +1000, Neil Brown wrote:
> > Alternately, the code which causes a call-back to be meaningful
> > (e.g. nlmclnt_lock in lockd (??)) could insert the relevant
> > information into the auth cache in advance.
> 
> There's not really a reliable way to do that with the current code since
> userspace can flush the auth_domain cache at whim.


Hmm... yes. Thanks.

I'm thinking that you really need to either involve user-space in
authenticating callbacks (issues like multi-homed servers mean that
the kernel cannot cope by itself at all) or not require RPC
authentication at all (the way 2.4 works).

Does anyone have objections to the following patch, which presumes the 
svcauth_unix_set_client patch from Bruce.  With it, locking starts
working again.


NeilBrown

====================================
Fix call-back authentication problems with lockd.

Currently, lockd callbacks (e.g. GRANT, from server to client) fail
because they cannot be authenticated.
In 2.4, we simply don't bother authenticating callbacks, and this
is probably the easiest approach.  Even checking the source address
in the kernel would not be enough because the server might be multi-homed.

So we introduce a per-procedure flag to say that authentication isn't
needed, make sure the procedure is known to svc_authenticate, and
have the AUTH_UNIX and AUTH_NULL authentication routines allow
such requests through.

Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/lockd/svc4proc.c        |   51 +++++++++++++++++++++----------------------
 ./fs/lockd/svcproc.c         |   51 +++++++++++++++++++++----------------------
 ./include/linux/sunrpc/svc.h |    6 +++++
 ./net/sunrpc/svc.c           |   20 +++++++++++-----
 ./net/sunrpc/svcauth_unix.c  |    4 ++-
 5 files changed, 75 insertions(+), 57 deletions(-)

diff ./fs/lockd/svc4proc.c~current~ ./fs/lockd/svc4proc.c
--- ./fs/lockd/svc4proc.c~current~	2004-09-24 12:10:40.000000000 +1000
+++ ./fs/lockd/svc4proc.c	2004-09-24 13:43:10.000000000 +1000
@@ -537,7 +537,7 @@ nlm4svc_callback_exit(struct rpc_task *t
 
 struct nlm_void			{ int dummy; };
 
-#define PROC(name, xargt, xrest, argt, rest, respsize)	\
+#define PROC(name, xargt, xrest, argt, rest, respsize, flags)	\
  { .pc_func	= (svc_procfunc) nlm4svc_proc_##name,	\
    .pc_decode	= (kxdrproc_t) nlm4svc_decode_##xargt,	\
    .pc_encode	= (kxdrproc_t) nlm4svc_encode_##xrest,	\
@@ -545,36 +545,37 @@ struct nlm_void			{ int dummy; };
    .pc_argsize	= sizeof(struct nlm_##argt),		\
    .pc_ressize	= sizeof(struct nlm_##rest),		\
    .pc_xdrressize = respsize,				\
+   .pc_flags    = flags,				\
  }
 #define	Ck	(1+8)	/* cookie */
 #define	No	(1+1024/4)	/* netobj */
 #define	St	1	/* status */
 #define	Rg	4	/* range (offset + length) */
 struct svc_procedure		nlmsvc_procedures4[] = {
-  PROC(null,		void,		void,		void,	void, 1),
-  PROC(test,		testargs,	testres,	args,	res, Ck+St+2+No+Rg),
-  PROC(lock,		lockargs,	res,		args,	res, Ck+St),
-  PROC(cancel,		cancargs,	res,		args,	res, Ck+St),
-  PROC(unlock,		unlockargs,	res,		args,	res, Ck+St),
-  PROC(granted,		testargs,	res,		args,	res, Ck+St),
-  PROC(test_msg,	testargs,	norep,		args,	void, 1),
-  PROC(lock_msg,	lockargs,	norep,		args,	void, 1),
-  PROC(cancel_msg,	cancargs,	norep,		args,	void, 1),
-  PROC(unlock_msg,	unlockargs,	norep,		args,	void, 1),
-  PROC(granted_msg,	testargs,	norep,		args,	void, 1),
-  PROC(test_res,	testres,	norep,		res,	void, 1),
-  PROC(lock_res,	lockres,	norep,		res,	void, 1),
-  PROC(cancel_res,	cancelres,	norep,		res,	void, 1),
-  PROC(unlock_res,	unlockres,	norep,		res,	void, 1),
-  PROC(granted_res,	res,		norep,		res,	void, 1),
+  PROC(null,		void,		void,		void,	void, 1, PC_NO_AUTH_NEEDED),
+  PROC(test,		testargs,	testres,	args,	res, Ck+St+2+No+Rg, 0),
+  PROC(lock,		lockargs,	res,		args,	res, Ck+St, 0),
+  PROC(cancel,		cancargs,	res,		args,	res, Ck+St, 0),
+  PROC(unlock,		unlockargs,	res,		args,	res, Ck+St, 0),
+  PROC(granted,		testargs,	res,		args,	res, Ck+St, PC_NO_AUTH_NEEDED),
+  PROC(test_msg,	testargs,	norep,		args,	void, 1, 0),
+  PROC(lock_msg,	lockargs,	norep,		args,	void, 1, 0),
+  PROC(cancel_msg,	cancargs,	norep,		args,	void, 1, 0),
+  PROC(unlock_msg,	unlockargs,	norep,		args,	void, 1, 0),
+  PROC(granted_msg,	testargs,	norep,		args,	void, 1, PC_NO_AUTH_NEEDED),
+  PROC(test_res,	testres,	norep,		res,	void, 1, PC_NO_AUTH_NEEDED),
+  PROC(lock_res,	lockres,	norep,		res,	void, 1, PC_NO_AUTH_NEEDED),
+  PROC(cancel_res,	cancelres,	norep,		res,	void, 1, PC_NO_AUTH_NEEDED),
+  PROC(unlock_res,	unlockres,	norep,		res,	void, 1, PC_NO_AUTH_NEEDED),
+  PROC(granted_res,	res,		norep,		res,	void, 1, PC_NO_AUTH_NEEDED),
   /* statd callback */
-  PROC(sm_notify,	reboot,		void,		reboot,	void, 1),
-  PROC(none,		void,		void,		void,	void, 0),
-  PROC(none,		void,		void,		void,	void, 0),
-  PROC(none,		void,		void,		void,	void, 0),
-  PROC(share,		shareargs,	shareres,	args,	res, Ck+St+1),
-  PROC(unshare,		shareargs,	shareres,	args,	res, Ck+St+1),
-  PROC(nm_lock,		lockargs,	res,		args,	res, Ck+St),
-  PROC(free_all,	notify,		void,		args,	void, 1),
+  PROC(sm_notify,	reboot,		void,		reboot,	void, 1, PC_NO_AUTH_NEEDED),
+  PROC(none,		void,		void,		void,	void, 0, 0),
+  PROC(none,		void,		void,		void,	void, 0, 0),
+  PROC(none,		void,		void,		void,	void, 0, 0),
+  PROC(share,		shareargs,	shareres,	args,	res, Ck+St+1, 0),
+  PROC(unshare,		shareargs,	shareres,	args,	res, Ck+St+1, 0),
+  PROC(nm_lock,		lockargs,	res,		args,	res, Ck+St, 0),
+  PROC(free_all,	notify,		void,		args,	void, 1, 0),
 
 };

diff ./fs/lockd/svcproc.c~current~ ./fs/lockd/svcproc.c
--- ./fs/lockd/svcproc.c~current~	2004-09-24 12:11:21.000000000 +1000
+++ ./fs/lockd/svcproc.c	2004-09-24 13:43:16.000000000 +1000
@@ -561,7 +561,7 @@ nlmsvc_callback_exit(struct rpc_task *ta
 
 struct nlm_void			{ int dummy; };
 
-#define PROC(name, xargt, xrest, argt, rest, respsize)	\
+#define PROC(name, xargt, xrest, argt, rest, respsize, flags)	\
  { .pc_func	= (svc_procfunc) nlmsvc_proc_##name,	\
    .pc_decode	= (kxdrproc_t) nlmsvc_decode_##xargt,	\
    .pc_encode	= (kxdrproc_t) nlmsvc_encode_##xrest,	\
@@ -569,6 +569,7 @@ struct nlm_void			{ int dummy; };
    .pc_argsize	= sizeof(struct nlm_##argt),		\
    .pc_ressize	= sizeof(struct nlm_##rest),		\
    .pc_xdrressize = respsize,				\
+   .pc_flags    = flags,				\
  }
 
 #define	Ck	(1+8)	/* cookie */
@@ -577,30 +578,30 @@ struct nlm_void			{ int dummy; };
 #define	Rg	2	/* range - offset + size */
 
 struct svc_procedure		nlmsvc_procedures[] = {
-  PROC(null,		void,		void,		void,	void, 1),
-  PROC(test,		testargs,	testres,	args,	res, Ck+St+2+No+Rg),
-  PROC(lock,		lockargs,	res,		args,	res, Ck+St),
-  PROC(cancel,		cancargs,	res,		args,	res, Ck+St),
-  PROC(unlock,		unlockargs,	res,		args,	res, Ck+St),
-  PROC(granted,		testargs,	res,		args,	res, Ck+St),
-  PROC(test_msg,	testargs,	norep,		args,	void, 1),
-  PROC(lock_msg,	lockargs,	norep,		args,	void, 1),
-  PROC(cancel_msg,	cancargs,	norep,		args,	void, 1),
-  PROC(unlock_msg,	unlockargs,	norep,		args,	void, 1),
-  PROC(granted_msg,	testargs,	norep,		args,	void, 1),
-  PROC(test_res,	testres,	norep,		res,	void, 1),
-  PROC(lock_res,	lockres,	norep,		res,	void, 1),
-  PROC(cancel_res,	cancelres,	norep,		res,	void, 1),
-  PROC(unlock_res,	unlockres,	norep,		res,	void, 1),
-  PROC(granted_res,	res,		norep,		res,	void, 1),
+  PROC(null,		void,		void,		void,	void, 1, PC_NO_AUTH_NEEDED),
+  PROC(test,		testargs,	testres,	args,	res, Ck+St+2+No+Rg, 0),
+  PROC(lock,		lockargs,	res,		args,	res, Ck+St, 0),
+  PROC(cancel,		cancargs,	res,		args,	res, Ck+St, 0),
+  PROC(unlock,		unlockargs,	res,		args,	res, Ck+St, 0),
+  PROC(granted,		testargs,	res,		args,	res, Ck+St, PC_NO_AUTH_NEEDED),
+  PROC(test_msg,	testargs,	norep,		args,	void, 1, 0),
+  PROC(lock_msg,	lockargs,	norep,		args,	void, 1, 0),
+  PROC(cancel_msg,	cancargs,	norep,		args,	void, 1, 0),
+  PROC(unlock_msg,	unlockargs,	norep,		args,	void, 1, 0),
+  PROC(granted_msg,	testargs,	norep,		args,	void, 1, PC_NO_AUTH_NEEDED),
+  PROC(test_res,	testres,	norep,		res,	void, 1, PC_NO_AUTH_NEEDED),
+  PROC(lock_res,	lockres,	norep,		res,	void, 1, PC_NO_AUTH_NEEDED),
+  PROC(cancel_res,	cancelres,	norep,		res,	void, 1, PC_NO_AUTH_NEEDED),
+  PROC(unlock_res,	unlockres,	norep,		res,	void, 1, PC_NO_AUTH_NEEDED),
+  PROC(granted_res,	res,		norep,		res,	void, 1, PC_NO_AUTH_NEEDED),
   /* statd callback */
-  PROC(sm_notify,	reboot,		void,		reboot,	void, 1),
-  PROC(none,		void,		void,		void,	void, 1),
-  PROC(none,		void,		void,		void,	void, 1),
-  PROC(none,		void,		void,		void,	void, 1),
-  PROC(share,		shareargs,	shareres,	args,	res, Ck+St+1),
-  PROC(unshare,		shareargs,	shareres,	args,	res, Ck+St+1),
-  PROC(nm_lock,		lockargs,	res,		args,	res, Ck+St),
-  PROC(free_all,	notify,		void,		args,	void, 0),
+  PROC(sm_notify,	reboot,		void,		reboot,	void, 1, PC_NO_AUTH_NEEDED),
+  PROC(none,		void,		void,		void,	void, 1, 0),
+  PROC(none,		void,		void,		void,	void, 1, 0),
+  PROC(none,		void,		void,		void,	void, 1, 0),
+  PROC(share,		shareargs,	shareres,	args,	res, Ck+St+1, 0),
+  PROC(unshare,		shareargs,	shareres,	args,	res, Ck+St+1, 0),
+  PROC(nm_lock,		lockargs,	res,		args,	res, Ck+St, 0),
+  PROC(free_all,	notify,		void,		args,	void, 0, 0),
 
 };

diff ./include/linux/sunrpc/svc.h~current~ ./include/linux/sunrpc/svc.h
--- ./include/linux/sunrpc/svc.h~current~	2004-09-24 11:49:40.000000000 +1000
+++ ./include/linux/sunrpc/svc.h	2004-09-24 11:51:18.000000000 +1000
@@ -285,8 +285,14 @@ struct svc_procedure {
 	unsigned int		pc_count;	/* call count */
 	unsigned int		pc_cachetype;	/* cache info (NFS) */
 	unsigned int		pc_xdrressize;	/* maximum size of XDR reply */
+	unsigned long		pc_flags;	/* various per-procedude flags */
 };
 
+/* pc_flags values */
+#define	PC_NO_AUTH_NEEDED	1	/* an authenticate request is not required for
+					 * this proceedure.  e.g. NULL and lockd call-backs
+					 */
+
 /*
  * This is the RPC server thread function prototype
  */

diff ./net/sunrpc/svc.c~current~ ./net/sunrpc/svc.c
--- ./net/sunrpc/svc.c~current~	2004-09-24 11:52:04.000000000 +1000
+++ ./net/sunrpc/svc.c	2004-09-24 12:03:21.000000000 +1000
@@ -305,7 +305,19 @@ svc_process(struct svc_serv *serv, struc
 	rqstp->rq_vers = vers = ntohl(svc_getu32(argv));	/* version number */
 	rqstp->rq_proc = proc = ntohl(svc_getu32(argv));	/* procedure number */
 
+	/* find version and procedure before calling svc_authenticate, 
+	 * is the later might need details of the former, but don't
+	 * return errors yet - if there is an auth error it but over-ride any
+	 * others to avoid information leakage
+	 */
 	progp = serv->sv_program;
+	if (vers < progp->pg_nvers)
+		versp = progp->pg_vers[vers];
+	if (versp && proc < versp->vs_nproc)
+		procp = versp->vs_proc + proc;
+	rqstp->rq_server   = serv;
+	rqstp->rq_procinfo = procp;
+
 	/*
 	 * Decode auth data, and add verifier to reply buffer.
 	 * We do this before anything else in order to get a decent
@@ -335,15 +347,11 @@ svc_process(struct svc_serv *serv, struc
 	if (prog != progp->pg_prog)
 		goto err_bad_prog;
 
-	if (vers >= progp->pg_nvers ||
-	  !(versp = progp->pg_vers[vers]))
+	if (!versp)
 		goto err_bad_vers;
 
-	procp = versp->vs_proc + proc;
-	if (proc >= versp->vs_nproc || !procp->pc_func)
+	if (!procp || !procp->pc_func)
 		goto err_bad_proc;
-	rqstp->rq_server   = serv;
-	rqstp->rq_procinfo = procp;
 
 	/* Syntactic check complete */
 	serv->sv_stats->rpccnt++;

diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
--- ./net/sunrpc/svcauth_unix.c~current~	2004-09-24 11:49:09.000000000 +1000
+++ ./net/sunrpc/svcauth_unix.c	2004-09-24 12:28:26.000000000 +1000
@@ -335,7 +335,9 @@ svcauth_unix_set_client(struct svc_rqst 
 	struct ip_map key, *ipm;
 
 	rqstp->rq_client = NULL;
-	if (rqstp->rq_proc == 0)
+	if (rqstp->rq_proc == 0 ||
+	    (rqstp->rq_procinfo &&
+	     (rqstp->rq_procinfo->pc_flags & PC_NO_AUTH_NEEDED)))
 		return SVC_OK;
 
 	strcpy(key.m_class, rqstp->rq_server->sv_program->pg_class);


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
