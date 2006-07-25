From: NeilBrown <neilb@suse.de>
Subject: [PATCH 004 of 9] knfsd: Add a callback for when last rpc
	thread finishes.
Date: Tue, 25 Jul 2006 11:54:42 +1000
Message-ID: <1060725015442.21945@suse.de>
References: <20060725114207.21779.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5C8o-0004bN-4v
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 18:55:22 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5C8n-00040a-Q6
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 18:55:22 -0700
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


nfsd has some cleanup that it wants to do when the last thread
exits, and there will shortly be some more.
So collect this all into one place and define a callback for
an rpc service to call when the service is about to be destroyed.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/lockd/svc.c             |    2 +-
 ./fs/nfsd/nfssvc.c           |   40 ++++++++++++++++++----------------------
 ./include/linux/sunrpc/svc.h |    8 +++++++-
 ./net/sunrpc/svc.c           |    7 ++++++-
 4 files changed, 32 insertions(+), 25 deletions(-)

diff .prev/fs/lockd/svc.c ./fs/lockd/svc.c
--- .prev/fs/lockd/svc.c	2006-07-24 14:55:00.000000000 +1000
+++ ./fs/lockd/svc.c	2006-07-24 15:13:40.000000000 +1000
@@ -236,7 +236,7 @@ lockd_up(void)
 			"lockd_up: no pid, %d users??\n", nlmsvc_users);
 
 	error = -ENOMEM;
-	serv = svc_create(&nlmsvc_program, LOCKD_BUFSIZE);
+	serv = svc_create(&nlmsvc_program, LOCKD_BUFSIZE, NULL);
 	if (!serv) {
 		printk(KERN_WARNING "lockd_up: create service failed\n");
 		goto out;

diff .prev/fs/nfsd/nfssvc.c ./fs/nfsd/nfssvc.c
--- .prev/fs/nfsd/nfssvc.c	2006-07-24 14:50:53.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2006-07-24 15:14:31.000000000 +1000
@@ -130,11 +130,25 @@ int nfsd_nrthreads(void)
 		return nfsd_serv->sv_nrthreads;
 }
 
+static int killsig = 0; /* signal that was used to kill last nfsd */
+static void nfsd_last_thread(struct svc_serv *serv)
+{
+	/* When last nfsd thread exits we need to do some clean-up */
+	nfsd_serv = NULL;
+	nfsd_racache_shutdown();
+	nfs4_state_shutdown();
+
+	printk(KERN_WARNING "nfsd: last server has exited\n");
+	if (killsig != SIG_NOCLEAN) {
+		printk(KERN_WARNING "nfsd: unexporting all filesystems\n");
+		nfsd_export_flush();
+	}
+}
 int
 nfsd_svc(unsigned short port, int nrservs)
 {
 	int	error;
-	int	none_left, found_one, i;
+	int	found_one, i;
 	struct list_head *victim;
 	
 	lock_kernel();
@@ -197,7 +211,8 @@ nfsd_svc(unsigned short port, int nrserv
 
 		atomic_set(&nfsd_busy, 0);
 		error = -ENOMEM;
-		nfsd_serv = svc_create(&nfsd_program, NFSD_BUFSIZE);
+		nfsd_serv = svc_create(&nfsd_program, NFSD_BUFSIZE,
+				       nfsd_last_thread);
 		if (nfsd_serv == NULL)
 			goto out;
 		error = svc_makesock(nfsd_serv, IPPROTO_UDP, port);
@@ -231,13 +246,7 @@ nfsd_svc(unsigned short port, int nrserv
 		nrservs++;
 	}
  failure:
-	none_left = (nfsd_serv->sv_nrthreads == 1);
 	svc_destroy(nfsd_serv);		/* Release server */
-	if (none_left) {
-		nfsd_serv = NULL;
-		nfsd_racache_shutdown();
-		nfs4_state_shutdown();
-	}
  out:
 	unlock_kernel();
 	return error;
@@ -353,7 +362,7 @@ nfsd(struct svc_rqst *rqstp)
 			if (sigismember(&current->pending.signal, signo) &&
 			    !sigismember(&current->blocked, signo))
 				break;
-		err = signo;
+		killsig = signo;
 	}
 	/* Clear signals before calling lockd_down() and svc_exit_thread() */
 	flush_signals(current);
@@ -362,19 +371,6 @@ nfsd(struct svc_rqst *rqstp)
 
 	/* Release lockd */
 	lockd_down();
-
-	/* Check if this is last thread */
-	if (serv->sv_nrthreads==1) {
-		
-		printk(KERN_WARNING "nfsd: last server has exited\n");
-		if (err != SIG_NOCLEAN) {
-			printk(KERN_WARNING "nfsd: unexporting all filesystems\n");
-			nfsd_export_flush();
-		}
-		nfsd_serv = NULL;
-	        nfsd_racache_shutdown();	/* release read-ahead cache */
-		nfs4_state_shutdown();
-	}
 	list_del(&me.list);
 	nfsdstats.th_cnt --;
 

diff .prev/include/linux/sunrpc/svc.h ./include/linux/sunrpc/svc.h
--- .prev/include/linux/sunrpc/svc.h	2006-07-24 14:42:06.000000000 +1000
+++ ./include/linux/sunrpc/svc.h	2006-07-24 15:13:40.000000000 +1000
@@ -42,6 +42,11 @@ struct svc_serv {
 	int			sv_tmpcnt;	/* count of temporary sockets */
 
 	char *			sv_name;	/* service name */
+
+	void			(*sv_shutdown)(struct svc_serv *serv);
+						/* Callback to use when last thread
+						 * exits.
+						 */
 };
 
 /*
@@ -311,7 +316,8 @@ typedef void		(*svc_thread_fn)(struct sv
 /*
  * Function prototypes.
  */
-struct svc_serv *  svc_create(struct svc_program *, unsigned int);
+struct svc_serv *  svc_create(struct svc_program *, unsigned int,
+			      void (*shutdown)(struct svc_serv*));
 int		   svc_create_thread(svc_thread_fn, struct svc_serv *);
 void		   svc_exit_thread(struct svc_rqst *);
 void		   svc_destroy(struct svc_serv *);

diff .prev/net/sunrpc/svc.c ./net/sunrpc/svc.c
--- .prev/net/sunrpc/svc.c	2006-07-24 14:40:46.000000000 +1000
+++ ./net/sunrpc/svc.c	2006-07-24 15:13:40.000000000 +1000
@@ -26,7 +26,8 @@
  * Create an RPC service
  */
 struct svc_serv *
-svc_create(struct svc_program *prog, unsigned int bufsize)
+svc_create(struct svc_program *prog, unsigned int bufsize,
+	   void (*shutdown)(struct svc_serv *serv))
 {
 	struct svc_serv	*serv;
 	int vers;
@@ -40,6 +41,7 @@ svc_create(struct svc_program *prog, uns
 	serv->sv_nrthreads = 1;
 	serv->sv_stats     = prog->pg_stats;
 	serv->sv_bufsz	   = bufsize? bufsize : 4096;
+	serv->sv_shutdown  = shutdown;
 	xdrsize = 0;
 	while (prog) {
 		prog->pg_lovers = prog->pg_nvers-1;
@@ -92,6 +94,9 @@ svc_destroy(struct svc_serv *serv)
 				  sk_list);
 		svc_delete_socket(svsk);
 	}
+	if (serv->sv_shutdown)
+		serv->sv_shutdown(serv);
+
 	while (!list_empty(&serv->sv_permsocks)) {
 		svsk = list_entry(serv->sv_permsocks.next,
 				  struct svc_sock,

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
