Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:14252 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759284Ab2INI0F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Sep 2012 04:26:05 -0400
Subject: [PATCH 2/2] NFSd: set nfsd_serv to NULL after service destruction
To: stable@vger.kernel.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, bfields@redhat.com, viro@zeniv.linux.org.uk,
        jbottomley@parallels.com
Date: Fri, 14 Sep 2012 12:25:56 +0400
Message-ID: <20120914082550.14353.46041.stgit@localhost6.localdomain6>
In-Reply-To: <20120914082201.14353.83847.stgit@localhost6.localdomain6>
References: <20120914082201.14353.83847.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

upstream commit 57c8b13e3cd0f94944c9691ce7f58e5fcef8a12d

In nfsd_destroy():

	if (destroy)
		svc_shutdown_net(nfsd_serv, net);
	svc_destroy(nfsd_server);

svc_shutdown_net(nfsd_serv, net) calls nfsd_last_thread(), which sets
nfsd_serv to NULL, causing a NULL dereference on the following line.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsd.h   |    2 ++
 fs/nfsd/nfssvc.c |   10 +++++-----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index e3339ca..1336a65 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -80,6 +80,8 @@ static inline void nfsd_destroy(struct net *net)
 	if (destroy)
 		svc_shutdown_net(nfsd_serv, net);
 	svc_destroy(nfsd_serv);
+	if (destroy)
+		nfsd_serv = NULL;
 }
 
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index e866af4..5f4b8f2 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -256,8 +256,6 @@ static void nfsd_shutdown(void)
 
 static void nfsd_last_thread(struct svc_serv *serv, struct net *net)
 {
-	/* When last nfsd thread exits we need to do some clean-up */
-	nfsd_serv = NULL;
 	nfsd_shutdown();
 
 	svc_rpcb_cleanup(serv, net);
@@ -334,6 +332,7 @@ static int nfsd_get_default_max_blksize(void)
 int nfsd_create_serv(void)
 {
 	int error;
+	struct net *net = current->nsproxy->net_ns;
 
 	WARN_ON(!mutex_is_locked(&nfsd_mutex));
 	if (nfsd_serv) {
@@ -348,7 +347,7 @@ int nfsd_create_serv(void)
 	if (nfsd_serv == NULL)
 		return -ENOMEM;
 
-	error = svc_bind(nfsd_serv, current->nsproxy->net_ns);
+	error = svc_bind(nfsd_serv, net);
 	if (error < 0) {
 		svc_destroy(nfsd_serv);
 		return error;
@@ -559,12 +558,13 @@ nfsd(void *vrqstp)
 	nfsdstats.th_cnt --;
 
 out:
-	if (rqstp->rq_server->sv_nrthreads == 1)
-		svc_shutdown_net(rqstp->rq_server, &init_net);
+	rqstp->rq_server = NULL;
 
 	/* Release the thread */
 	svc_exit_thread(rqstp);
 
+	nfsd_destroy(&init_net);
+
 	/* Release module */
 	mutex_unlock(&nfsd_mutex);
 	module_put_and_exit(0);

