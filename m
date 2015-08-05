Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:33819 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265AbbHEVNp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 17:13:45 -0400
Received: by ykax123 with SMTP id x123so46810090yka.1
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 14:13:45 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 03/18] nfsd: convert laundry_wq to something less nfsd4 specific
Date: Wed,  5 Aug 2015 17:13:21 -0400
Message-Id: <1438809216-4846-4-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, nfsd uses a singlethread workqueue for this, but that's not
necessary. If we have multiple namespaces, then there's no need to
serialize the laundromat runs since they are only requeued at the end of
the work itself.

Also, create_singlethread_workqueue adds the WQ_MEM_RECLAIM flag, which
doesn't really seem to be necessary. The laundromat jobs are always
kicked off via a timer, and not from memory reclaim paths. There's no
need for a rescuer thread.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 23 +++++------------------
 fs/nfsd/nfsd.h      |  1 +
 fs/nfsd/nfssvc.c    | 14 +++++++++++++-
 3 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b3b306bd1830..c94859122e6f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4366,7 +4366,6 @@ nfs4_laundromat(struct nfsd_net *nn)
 	return new_timeo;
 }
 
-static struct workqueue_struct *laundry_wq;
 static void laundromat_main(struct work_struct *);
 
 static void
@@ -4380,7 +4379,7 @@ laundromat_main(struct work_struct *laundry)
 
 	t = nfs4_laundromat(nn);
 	dprintk("NFSD: laundromat_main - sleeping for %ld seconds\n", t);
-	queue_delayed_work(laundry_wq, &nn->laundromat_work, t*HZ);
+	queue_delayed_work(nfsd_laundry_wq, &nn->laundromat_work, t*HZ);
 }
 
 static inline __be32 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_stid *stp)
@@ -6569,7 +6568,8 @@ nfs4_state_start_net(struct net *net)
 	nfsd4_client_tracking_init(net);
 	printk(KERN_INFO "NFSD: starting %ld-second grace period (net %p)\n",
 	       nn->nfsd4_grace, net);
-	queue_delayed_work(laundry_wq, &nn->laundromat_work, nn->nfsd4_grace * HZ);
+	queue_delayed_work(nfsd_laundry_wq, &nn->laundromat_work,
+				nn->nfsd4_grace * HZ);
 	return 0;
 }
 
@@ -6583,22 +6583,10 @@ nfs4_state_start(void)
 	ret = set_callback_cred();
 	if (ret)
 		return -ENOMEM;
-	laundry_wq = create_singlethread_workqueue("nfsd4");
-	if (laundry_wq == NULL) {
-		ret = -ENOMEM;
-		goto out_recovery;
-	}
 	ret = nfsd4_create_callback_queue();
-	if (ret)
-		goto out_free_laundry;
-
-	set_max_delegations();
-
-	return 0;
+	if (!ret)
+		set_max_delegations();
 
-out_free_laundry:
-	destroy_workqueue(laundry_wq);
-out_recovery:
 	return ret;
 }
 
@@ -6635,7 +6623,6 @@ nfs4_state_shutdown_net(struct net *net)
 void
 nfs4_state_shutdown(void)
 {
-	destroy_workqueue(laundry_wq);
 	nfsd4_destroy_callback_queue();
 }
 
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index cf980523898b..0199415344ff 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -62,6 +62,7 @@ struct readdir_cd {
 extern struct svc_program	nfsd_program;
 extern struct svc_version	nfsd_version2, nfsd_version3,
 				nfsd_version4;
+extern struct workqueue_struct	*nfsd_laundry_wq;
 extern struct mutex		nfsd_mutex;
 extern spinlock_t		nfsd_drc_lock;
 extern unsigned long		nfsd_drc_max_mem;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index ad4e2377dd63..ced9944201a0 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -17,6 +17,7 @@
 #include <linux/lockd/bind.h>
 #include <linux/nfsacl.h>
 #include <linux/seq_file.h>
+#include <linux/workqueue.h>
 #include <net/net_namespace.h>
 #include "nfsd.h"
 #include "cache.h"
@@ -28,6 +29,9 @@
 extern struct svc_program	nfsd_program;
 static int			nfsd(void *vrqstp);
 
+/* A workqueue for nfsd-related cleanup tasks */
+struct workqueue_struct		*nfsd_laundry_wq;
+
 /*
  * nfsd_mutex protects nn->nfsd_serv -- both the pointer itself and the members
  * of the svc_serv struct. In particular, ->sv_nrthreads but also to some
@@ -224,11 +228,19 @@ static int nfsd_startup_generic(int nrservs)
 	if (ret)
 		goto dec_users;
 
+	ret = -ENOMEM;
+	nfsd_laundry_wq = alloc_workqueue("%s", WQ_UNBOUND, 0, "nfsd-laundry");
+	if (!nfsd_laundry_wq)
+		goto out_racache;
+
 	ret = nfs4_state_start();
 	if (ret)
-		goto out_racache;
+		goto out_wq;
 	return 0;
 
+out_wq:
+	destroy_workqueue(nfsd_laundry_wq);
+	nfsd_laundry_wq = NULL;
 out_racache:
 	nfsd_racache_shutdown();
 dec_users:
-- 
2.4.3

