From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: [PATCH] Remove flowcontrol problems with lockd/tcp in 2.5.8
Date: Fri, 19 Apr 2002 17:57:38 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15551.52722.145993.498317@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16yTNt-0002q7-00
	for <nfs@lists.sourceforge.net>; Fri, 19 Apr 2002 01:04:46 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 19 Apr 2002 18:04:22 +1000
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>




The sunrpc/tcp layer currently allocates some resources linearly with
number of server threads.  This causes problems when there are very
small numbers of threads (e.g. lockd with one thread), so this patch
adds a small constant to the number of threads before calculating
resoures to allocate.

This patch also provide proper upper-limits for the response sizes for
lockd requests, so resources are not over-allocated.

Together these resolve problems with heavy-ish lockd load over tcp.




 ----------- Diffstat output ------------
 ./fs/lockd/svc4proc.c  |   46 +++++++++++++++++++++++--------------------
 ./fs/lockd/svcproc.c   |   52 +++++++++++++++++++++++++++----------------------
 ./net/sunrpc/svcsock.c |    6 ++---
 3 files changed, 57 insertions(+), 47 deletions(-)

--- ./net/sunrpc/svcsock.c	2002/04/19 01:41:05	1.1
+++ ./net/sunrpc/svcsock.c	2002/04/19 01:42:33	1.2
@@ -710,7 +710,7 @@
 	 * We randomly choose between newest and oldest (in terms
 	 * of recent activity) and drop it.
 	 */
-	if (serv->sv_tmpcnt > serv->sv_nrthreads*5) {
+	if (serv->sv_tmpcnt > (serv->sv_nrthreads+3)*5) {
 		struct svc_sock *svsk = NULL;
 		spin_lock_bh(&serv->sv_lock);
 		if (!list_empty(&serv->sv_tempsocks)) {
@@ -924,7 +924,7 @@
 		 * as soon a a complete request arrives.
 		 */
 		svc_sock_setbufsize(svsk->sk_sock,
-				    svsk->sk_server->sv_nrthreads *
+				    (svsk->sk_server->sv_nrthreads+3) *
 				    svsk->sk_server->sv_bufsz,
 				    3 * svsk->sk_server->sv_bufsz);
 	}
@@ -966,7 +966,7 @@
 		if (sock->type == SOCK_STREAM) {
 			/* See svc_tcp_init above for rationale on buffer sizes */
 			svc_sock_setbufsize(sock,
-					    serv->sv_nrthreads *
+					    (serv->sv_nrthreads+3) *
 					    serv->sv_bufsz,
 					    3 * serv->sv_bufsz);
 		} else 
--- ./fs/lockd/svc4proc.c	2002/04/19 01:41:05	1.1
+++ ./fs/lockd/svc4proc.c	2002/04/19 01:42:34	1.2
@@ -537,31 +537,35 @@
    0,					\
    respsize,				\
  }
+#define	Ck	(1+8)	/* cookie */
+#define	No	(1+1024/4)	/* netobj */
+#define	St	1	/* status */
+#define	Rg	4	/* range (offset + length) */
 struct svc_procedure		nlmsvc_procedures4[] = {
-  PROC(null,		void,		void,		void,	void, 0),
-  PROC(test,		testargs,	testres,	args,	res, 0),
-  PROC(lock,		lockargs,	res,		args,	res, 0),
-  PROC(cancel,		cancargs,	res,		args,	res, 0),
-  PROC(unlock,		unlockargs,	res,		args,	res, 0),
-  PROC(granted,		testargs,	res,		args,	res, 0),
-  PROC(test_msg,	testargs,	norep,		args,	void, 0),
-  PROC(lock_msg,	lockargs,	norep,		args,	void, 0),
-  PROC(cancel_msg,	cancargs,	norep,		args,	void, 0),
-  PROC(unlock_msg,	unlockargs,	norep,		args,	void, 0),
-  PROC(granted_msg,	testargs,	norep,		args,	void, 0),
-  PROC(test_res,	testres,	norep,		res,	void, 0),
-  PROC(lock_res,	lockres,	norep,		res,	void, 0),
-  PROC(cancel_res,	cancelres,	norep,		res,	void, 0),
-  PROC(unlock_res,	unlockres,	norep,		res,	void, 0),
-  PROC(granted_res,	grantedres,	norep,		res,	void, 0),
+  PROC(null,		void,		void,		void,	void, 1),
+  PROC(test,		testargs,	testres,	args,	res, Ck+St+2+No+Rg),
+  PROC(lock,		lockargs,	res,		args,	res, Ck+St),
+  PROC(cancel,		cancargs,	res,		args,	res, Ck+St),
+  PROC(unlock,		unlockargs,	res,		args,	res, Ck+St),
+  PROC(granted,		testargs,	res,		args,	res, Ck+St),
+  PROC(test_msg,	testargs,	norep,		args,	void, 1),
+  PROC(lock_msg,	lockargs,	norep,		args,	void, 1),
+  PROC(cancel_msg,	cancargs,	norep,		args,	void, 1),
+  PROC(unlock_msg,	unlockargs,	norep,		args,	void, 1),
+  PROC(granted_msg,	testargs,	norep,		args,	void, 1),
+  PROC(test_res,	testres,	norep,		res,	void, 1),
+  PROC(lock_res,	lockres,	norep,		res,	void, 1),
+  PROC(cancel_res,	cancelres,	norep,		res,	void, 1),
+  PROC(unlock_res,	unlockres,	norep,		res,	void, 1),
+  PROC(granted_res,	grantedres,	norep,		res,	void, 1),
   /* statd callback */
-  PROC(sm_notify,	reboot,		void,		reboot,	void, 0),
+  PROC(sm_notify,	reboot,		void,		reboot,	void, 1),
   PROC(none,		void,		void,		void,	void, 0),
   PROC(none,		void,		void,		void,	void, 0),
   PROC(none,		void,		void,		void,	void, 0),
-  PROC(share,		shareargs,	shareres,	args,	res, 0),
-  PROC(unshare,		shareargs,	shareres,	args,	res, 0),
-  PROC(nm_lock,		lockargs,	res,		args,	res, 0),
-  PROC(free_all,	notify,		void,		args,	void, 0),
+  PROC(share,		shareargs,	shareres,	args,	res, Ck+St+1),
+  PROC(unshare,		shareargs,	shareres,	args,	res, Ck+St+1),
+  PROC(nm_lock,		lockargs,	res,		args,	res, Ck+St),
+  PROC(free_all,	notify,		void,		args,	void, 1),
 
 };
--- ./fs/lockd/svcproc.c	2002/04/19 01:41:05	1.1
+++ ./fs/lockd/svcproc.c	2002/04/19 01:42:34	1.2
@@ -565,31 +565,37 @@
    0,					\
    respsize,				\
  }
+
+#define	Ck	(1+8)	/* cookie */
+#define	St	1	/* status */
+#define	No	(1+1024/4) /* Net Obj */
+#define	Rg	2	/* range - offset + size */
+
 struct svc_procedure		nlmsvc_procedures[] = {
-  PROC(null,		void,		void,		void,	void, 0),
-  PROC(test,		testargs,	testres,	args,	res, 0),
-  PROC(lock,		lockargs,	res,		args,	res, 0),
-  PROC(cancel,		cancargs,	res,		args,	res, 0),
-  PROC(unlock,		unlockargs,	res,		args,	res, 0),
-  PROC(granted,		testargs,	res,		args,	res, 0),
-  PROC(test_msg,	testargs,	norep,		args,	void, 0),
-  PROC(lock_msg,	lockargs,	norep,		args,	void, 0),
-  PROC(cancel_msg,	cancargs,	norep,		args,	void, 0),
-  PROC(unlock_msg,	unlockargs,	norep,		args,	void, 0),
-  PROC(granted_msg,	testargs,	norep,		args,	void, 0),
-  PROC(test_res,	testres,	norep,		res,	void, 0),
-  PROC(lock_res,	lockres,	norep,		res,	void, 0),
-  PROC(cancel_res,	cancelres,	norep,		res,	void, 0),
-  PROC(unlock_res,	unlockres,	norep,		res,	void, 0),
-  PROC(granted_res,	grantedres,	norep,		res,	void, 0),
+  PROC(null,		void,		void,		void,	void, 1),
+  PROC(test,		testargs,	testres,	args,	res, Ck+St+2+No+Rg),
+  PROC(lock,		lockargs,	res,		args,	res, Ck+St),
+  PROC(cancel,		cancargs,	res,		args,	res, Ck+St),
+  PROC(unlock,		unlockargs,	res,		args,	res, Ck+St),
+  PROC(granted,		testargs,	res,		args,	res, Ck+St),
+  PROC(test_msg,	testargs,	norep,		args,	void, 1),
+  PROC(lock_msg,	lockargs,	norep,		args,	void, 1),
+  PROC(cancel_msg,	cancargs,	norep,		args,	void, 1),
+  PROC(unlock_msg,	unlockargs,	norep,		args,	void, 1),
+  PROC(granted_msg,	testargs,	norep,		args,	void, 1),
+  PROC(test_res,	testres,	norep,		res,	void, 1),
+  PROC(lock_res,	lockres,	norep,		res,	void, 1),
+  PROC(cancel_res,	cancelres,	norep,		res,	void, 1),
+  PROC(unlock_res,	unlockres,	norep,		res,	void, 1),
+  PROC(granted_res,	grantedres,	norep,		res,	void, 1),
   /* statd callback */
-  PROC(sm_notify,	reboot,		void,		reboot,	void, 0),
-  PROC(none,		void,		void,		void,	void, 0),
-  PROC(none,		void,		void,		void,	void, 0),
-  PROC(none,		void,		void,		void,	void, 0),
-  PROC(share,		shareargs,	shareres,	args,	res, 0),
-  PROC(unshare,		shareargs,	shareres,	args,	res, 0),
-  PROC(nm_lock,		lockargs,	res,		args,	res, 0),
+  PROC(sm_notify,	reboot,		void,		reboot,	void, 1),
+  PROC(none,		void,		void,		void,	void, 1),
+  PROC(none,		void,		void,		void,	void, 1),
+  PROC(none,		void,		void,		void,	void, 1),
+  PROC(share,		shareargs,	shareres,	args,	res, Ck+St+1),
+  PROC(unshare,		shareargs,	shareres,	args,	res, Ck+St+1),
+  PROC(nm_lock,		lockargs,	res,		args,	res, Ck+St),
   PROC(free_all,	notify,		void,		args,	void, 0),
 
 };

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
