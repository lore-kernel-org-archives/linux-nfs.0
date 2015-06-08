Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:29788 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570AbbFHFaN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2015 01:30:13 -0400
Message-ID: <55752861.1090904@oracle.com>
Date: Sun, 07 Jun 2015 22:30:09 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [RFC PATCH V3 5/7] nfsd/sunrpc: abstract out svc_set_num_threads
 to sv_ops
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

sunrpc: abstract out svc_set_num_threads to sv_ops
    
Add an operation that will do setup of the service. In the case of a
classic thread-based service that means starting up threads. In the case
of a workqueue-based service, the setup will do something different.
    
Author: Jeff Layton <jlayton@primarydata.com>
Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
Tested-by: Shirley Ma <shirliey.ma@oracle.com>
---
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index d8b9b4c..ad4e237 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -395,6 +395,7 @@ static struct svc_serv_ops nfsd_thread_sv_ops = {
 	.svo_shutdown		= nfsd_last_thread,
 	.svo_function		= nfsd,
 	.svo_enqueue_xprt	= svc_xprt_do_enqueue,
+	.svo_setup		= svc_set_num_threads,
 	.svo_module		= THIS_MODULE,
 };
 
@@ -507,8 +508,8 @@ int nfsd_set_nrthreads(int n, int *nthreads, struct net *net)
 	/* apply the new numbers */
 	svc_get(nn->nfsd_serv);
 	for (i = 0; i < n; i++) {
-		err = svc_set_num_threads(nn->nfsd_serv, &nn->nfsd_serv->sv_pools[i],
-				    	  nthreads[i]);
+		err = nn->nfsd_serv->sv_ops->svo_setup(nn->nfsd_serv,
+				&nn->nfsd_serv->sv_pools[i], nthreads[i]);
 		if (err)
 			break;
 	}
@@ -547,7 +548,8 @@ nfsd_svc(int nrservs, struct net *net)
 	error = nfsd_startup_net(nrservs, net);
 	if (error)
 		goto out_destroy;
-	error = svc_set_num_threads(nn->nfsd_serv, NULL, nrservs);
+	error = nn->nfsd_serv->sv_ops->svo_setup(nn->nfsd_serv,
+			NULL, nrservs);
 	if (error)
 		goto out_shutdown;
 	/* We are holding a reference to nn->nfsd_serv which
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 51dd3f1..12941f6 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -61,6 +61,9 @@ struct svc_serv_ops {
 	/* queue up a transport for servicing */
 	void		(*svo_enqueue_xprt)(struct svc_xprt *);
 
+	/* set up thread (or whatever) execution context */
+	int		(*svo_setup)(struct svc_serv *, struct svc_pool *, int);
+
 	/* optional module to count when adding threads (pooled svcs only) */
 	struct module	*svo_module;
 };
