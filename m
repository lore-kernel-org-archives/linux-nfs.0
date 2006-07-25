From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 009 of 11] knfsd: use svc_set_num_threads
Date: Tue, 25 Jul 2006 15:15:33 +1000
Message-ID: <1153804533.21040.22.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5FGc-0003v9-UO
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 22:15:39 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G5FGd-0004Ll-5T
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 22:15:39 -0700
To: Neil Brown <neilb@suse.de>
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

knfsd: Replace the existing list of all nfsd threads with new
code using svc_create_pooled().

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 fs/nfsd/nfssvc.c |   34 ++++------------------------------
 1 files changed, 4 insertions(+), 30 deletions(-)

Index: linus-git/fs/nfsd/nfssvc.c
===================================================================
--- linus-git.orig/fs/nfsd/nfssvc.c	2006-07-24 20:54:04.790615277 +1000
+++ linus-git/fs/nfsd/nfssvc.c	2006-07-24 22:36:40.864677820 +1000
@@ -57,12 +57,6 @@ static atomic_t			nfsd_busy;
 static unsigned long		nfsd_last_call;
 static DEFINE_SPINLOCK(nfsd_call_lock);
 
-struct nfsd_list {
-	struct list_head 	list;
-	struct task_struct	*task;
-};
-static struct list_head nfsd_list = LIST_HEAD_INIT(nfsd_list);
-
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
 static struct svc_stat	nfsd_acl_svcstats;
 static struct svc_version *	nfsd_acl_version[] = {
@@ -135,7 +129,6 @@ nfsd_svc(unsigned short port, int nrserv
 {
 	int	error;
 	int	none_left, found_one, i;
-	struct list_head *victim;
 	
 	lock_kernel();
 	dprintk("nfsd: creating service: vers 0x%x\n",
@@ -197,7 +190,8 @@ nfsd_svc(unsigned short port, int nrserv
 
 		atomic_set(&nfsd_busy, 0);
 		error = -ENOMEM;
-		nfsd_serv = svc_create(&nfsd_program, NFSD_BUFSIZE);
+		nfsd_serv = svc_create_pooled(&nfsd_program, NFSD_BUFSIZE,
+					      nfsd, SIG_NOCLEAN, THIS_MODULE);
 		if (nfsd_serv == NULL)
 			goto out;
 		error = svc_makesock(nfsd_serv, IPPROTO_UDP, port);
@@ -212,24 +206,7 @@ nfsd_svc(unsigned short port, int nrserv
 		do_gettimeofday(&nfssvc_boot);		/* record boot time */
 	} else
 		svc_get(nfsd_serv);
-	nrservs -= (nfsd_serv->sv_nrthreads-1);
-	while (nrservs > 0) {
-		nrservs--;
-		__module_get(THIS_MODULE);
-		error = svc_create_thread(nfsd, nfsd_serv);
-		if (error < 0) {
-			module_put(THIS_MODULE);
-			break;
-		}
-	}
-	victim = nfsd_list.next;
-	while (nrservs < 0 && victim != &nfsd_list) {
-		struct nfsd_list *nl =
-			list_entry(victim,struct nfsd_list, list);
-		victim = victim->next;
-		send_sig(SIG_NOCLEAN, nl->task, 1);
-		nrservs++;
-	}
+	error = svc_set_num_threads(nfsd_serv, NULL, nrservs);
  failure:
 	none_left = (nfsd_serv->sv_nrthreads == 1);
 	svc_destroy(nfsd_serv);		/* Release server */
@@ -273,7 +250,6 @@ nfsd(struct svc_rqst *rqstp)
 	struct svc_serv	*serv = rqstp->rq_server;
 	struct fs_struct *fsp;
 	int		err;
-	struct nfsd_list me;
 	sigset_t shutdown_mask, allowed_mask;
 
 	/* Lock module and set up kernel thread */
@@ -299,8 +275,7 @@ nfsd(struct svc_rqst *rqstp)
 
 	lockd_up();				/* start lockd */
 
-	me.task = current;
-	list_add(&me.list, &nfsd_list);
+	rqstp->rq_task = current;
 
 	unlock_kernel();
 
@@ -375,7 +350,6 @@ nfsd(struct svc_rqst *rqstp)
 	        nfsd_racache_shutdown();	/* release read-ahead cache */
 		nfs4_state_shutdown();
 	}
-	list_del(&me.list);
 	nfsdstats.th_cnt --;
 
 out:

-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
