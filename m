From: NeilBrown <neilb@suse.de>
Subject: [PATCH 009 of 11] knfsd: use svc_set_num_threads to manage
	threads in knfsd
Date: Mon, 31 Jul 2006 10:42:29 +1000
Message-ID: <1060731004229.29279@suse.de>
References: <20060731103458.29040.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7Lrf-0003uf-EJ
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 17:42:36 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G7Lrf-00077m-6h
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 17:42:36 -0700
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


From: Greg Banks <gnb@melbourne.sgi.com>

knfsd: Replace the existing list of all nfsd threads with new
code using svc_create_pooled().

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfssvc.c |   36 +++++-------------------------------
 1 file changed, 5 insertions(+), 31 deletions(-)

diff .prev/fs/nfsd/nfssvc.c ./fs/nfsd/nfssvc.c
--- .prev/fs/nfsd/nfssvc.c	2006-07-31 10:29:38.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2006-07-31 10:31:08.000000000 +1000
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
@@ -206,8 +200,9 @@ int nfsd_create_serv(void)
 	}
 
 	atomic_set(&nfsd_busy, 0);
-	nfsd_serv = svc_create(&nfsd_program, NFSD_BUFSIZE,
-			       nfsd_last_thread);
+	nfsd_serv = svc_create_pooled(&nfsd_program, NFSD_BUFSIZE,
+				      nfsd_last_thread,
+				      nfsd, SIG_NOCLEAN, THIS_MODULE);
 	if (nfsd_serv == NULL)
 		err = -ENOMEM;
 	unlock_kernel();
@@ -247,7 +242,6 @@ int
 nfsd_svc(unsigned short port, int nrservs)
 {
 	int	error;
-	struct list_head *victim;
 	
 	lock_kernel();
 	dprintk("nfsd: creating service\n");
@@ -275,24 +269,7 @@ nfsd_svc(unsigned short port, int nrserv
 	if (error)
 		goto failure;
 
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
 	svc_destroy(nfsd_serv);		/* Release server */
  out:
@@ -329,7 +306,6 @@ nfsd(struct svc_rqst *rqstp)
 {
 	struct fs_struct *fsp;
 	int		err;
-	struct nfsd_list me;
 	sigset_t shutdown_mask, allowed_mask;
 
 	/* Lock module and set up kernel thread */
@@ -353,8 +329,7 @@ nfsd(struct svc_rqst *rqstp)
 
 	nfsdstats.th_cnt++;
 
-	me.task = current;
-	list_add(&me.list, &nfsd_list);
+	rqstp->rq_task = current;
 
 	unlock_kernel();
 
@@ -413,7 +388,6 @@ nfsd(struct svc_rqst *rqstp)
 
 	lock_kernel();
 
-	list_del(&me.list);
 	nfsdstats.th_cnt --;
 
 out:

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
