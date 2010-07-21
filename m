Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15142 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755862Ab0GUNVn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Jul 2010 09:21:43 -0400
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] nfsd: just keep single lockd reference for nfsd (try #4)
Date: Wed, 21 Jul 2010 09:21:41 -0400
Message-Id: <1279718501-6834-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Right now, nfsd keeps a lockd reference for each socket that it has
open. This is unnecessary and complicates the error handling on startup
and shutdown. Change it to just do a lockd_up when starting the first
nfsd thread just do a single lockd_down when taking down the last nfsd
thread. Because of the strange way the sv_count is handled, this
requires an extra flag to tell whether the nfsd_serv holds a reference
for lockd or not.

This patch also changes the error handling in nfsd_create_serv a bit
too. There doesn't seem to be any need to reset the nfssvc_boot time if
the nfsd startup failed.

Note though that this does change the user-visible behavior slightly.
Today, a lockd_up is done whenever a socket fd is handed off to the
kernel. With this change, lockd is brought up as soon as the first
thread is started. I think this makes more sense. If there are problems
in userspace, the old scheme had the possibility to start lockd long
before any nfsd threads were started. This patch helps minimize that
possibility.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfsctl.c |   10 ----------
 fs/nfsd/nfssvc.c |   42 +++++++++++++++++++++++++++++-------------
 2 files changed, 29 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 9e8645a..b1c5be8 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -949,15 +949,8 @@ static ssize_t __write_ports_addfd(char *buf)
 	if (err != 0)
 		return err;
 
-	err = lockd_up();
-	if (err != 0) {
-		svc_destroy(nfsd_serv);
-		return err;
-	}
-
 	err = svc_addsock(nfsd_serv, fd, buf, SIMPLE_TRANSACTION_LIMIT);
 	if (err < 0) {
-		lockd_down();
 		svc_destroy(nfsd_serv);
 		return err;
 	}
@@ -982,9 +975,6 @@ static ssize_t __write_ports_delfd(char *buf)
 	if (nfsd_serv != NULL)
 		len = svc_sock_names(nfsd_serv, buf,
 					SIMPLE_TRANSACTION_LIMIT, toclose);
-	if (len >= 0)
-		lockd_down();
-
 	kfree(toclose);
 	return len;
 }
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index a06ea99..2e15db0 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -25,6 +25,7 @@
 extern struct svc_program	nfsd_program;
 static int			nfsd(void *vrqstp);
 struct timeval			nfssvc_boot;
+static bool			nfsd_lockd_up;
 
 /*
  * nfsd_mutex protects nfsd_serv -- both the pointer itself and the members
@@ -183,9 +184,10 @@ int nfsd_nrthreads(void)
 static void nfsd_last_thread(struct svc_serv *serv)
 {
 	/* When last nfsd thread exits we need to do some clean-up */
-	struct svc_xprt *xprt;
-	list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list)
+	if (nfsd_lockd_up) {
 		lockd_down();
+		nfsd_lockd_up = false;
+	}
 	nfsd_serv = NULL;
 	nfsd_racache_shutdown();
 	nfs4_state_shutdown();
@@ -267,10 +269,9 @@ int nfsd_create_serv(void)
 	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
 				      nfsd_last_thread, nfsd, THIS_MODULE);
 	if (nfsd_serv == NULL)
-		err = -ENOMEM;
-	else
-		set_max_drc();
+		return -ENOMEM;
 
+	set_max_drc();
 	do_gettimeofday(&nfssvc_boot);		/* record boot time */
 	return err;
 }
@@ -286,19 +287,11 @@ static int nfsd_init_socks(int port)
 	if (error < 0)
 		return error;
 
-	error = lockd_up();
-	if (error < 0)
-		return error;
-
 	error = svc_create_xprt(nfsd_serv, "tcp", PF_INET, port,
 					SVC_SOCK_DEFAULTS);
 	if (error < 0)
 		return error;
 
-	error = lockd_up();
-	if (error < 0)
-		return error;
-
 	return 0;
 }
 
@@ -380,6 +373,7 @@ int
 nfsd_svc(unsigned short port, int nrservs)
 {
 	int	error;
+	bool	lockd_started = false;
 
 	mutex_lock(&nfsd_mutex);
 	dprintk("nfsd: creating service\n");
@@ -395,6 +389,16 @@ nfsd_svc(unsigned short port, int nrservs)
 	error =	nfsd_racache_init(2*nrservs);
 	if (error<0)
 		goto out;
+
+	/* start lockd iff we're starting threads */
+	if ((nrservs > 0) && !nfsd_lockd_up) {
+		error = lockd_up();
+		if (error != 0)
+			goto out;
+		nfsd_lockd_up = true;
+		lockd_started = true;
+	}
+
 	error = nfs4_state_start();
 	if (error)
 		goto out;
@@ -416,12 +420,24 @@ nfsd_svc(unsigned short port, int nrservs)
 		 * so subtract 1
 		 */
 		error = nfsd_serv->sv_nrthreads - 1;
+
+	/* if we brought all threads down, do a lockd_down */
+	if ((error == 0) && nfsd_lockd_up) {
+		lockd_down();
+		nfsd_lockd_up = false;
+	}
+
 failure:
 	svc_destroy(nfsd_serv);		/* Release server */
 shutdown_state:
 	if (error < 0)
 		nfs4_state_shutdown();
 out:
+	/* lockd_down if there was an error, and we did a lockd_up */
+	if (lockd_started && error < 0) {
+		lockd_down();
+		nfsd_lockd_up = false;
+	}
 	mutex_unlock(&nfsd_mutex);
 	return error;
 }
-- 
1.5.5.6

