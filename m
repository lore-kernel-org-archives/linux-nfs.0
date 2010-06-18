From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] nfsd: just keep single lockd reference for nfsd
Date: Fri, 18 Jun 2010 07:02:20 -0400
Message-ID: <1276858940-15499-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, chris-TF6qbakwsgc2epGFuHBODCp2UmYkHbXO@public.gmane.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51148 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758468Ab0FRLGl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jun 2010 07:06:41 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch should replace the other patches that I proposed to make
sure that each sv_permsock entry holds a lockd refrence.

Right now, nfsd keeps a lockd reference for each socket that it has
open. This is unnecessary and complicates the error handling on
startup and shutdown. Change it to just do a lockd_up when creating
the nfsd_serv and just do a single lockd_down when taking down the
last nfsd thread.

This patch also changes the error handling in nfsd_create_serv a
bit too. There doesn't seem to be any need to reset the nfssvc_boot
time if the nfsd startup failed.

Note though that this does change the user-visible behavior slightly.
Today when someone writes a text socktype and port to the portlist file
prior to starting nfsd, lockd is not started when nfsd threads are
brought up. With this change, it will be started any time that
the nfsd_serv is created. I'm making the assumption that that's not a
problem. If it is then we'll need to take a different approach to fixing
this.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfsctl.c |   10 ----------
 fs/nfsd/nfssvc.c |   25 ++++++++++---------------
 2 files changed, 10 insertions(+), 25 deletions(-)

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
index a06ea99..6b59d32 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -183,9 +183,7 @@ int nfsd_nrthreads(void)
 static void nfsd_last_thread(struct svc_serv *serv)
 {
 	/* When last nfsd thread exits we need to do some clean-up */
-	struct svc_xprt *xprt;
-	list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list)
-		lockd_down();
+	lockd_down();
 	nfsd_serv = NULL;
 	nfsd_racache_shutdown();
 	nfs4_state_shutdown();
@@ -264,13 +262,18 @@ int nfsd_create_serv(void)
 			nfsd_max_blksize /= 2;
 	}
 
+	err = lockd_up();
+	if (err != 0)
+		return err;
+
 	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
 				      nfsd_last_thread, nfsd, THIS_MODULE);
-	if (nfsd_serv == NULL)
-		err = -ENOMEM;
-	else
-		set_max_drc();
+	if (nfsd_serv == NULL) {
+		lockd_down();
+		return -ENOMEM;
+	}
 
+	set_max_drc();
 	do_gettimeofday(&nfssvc_boot);		/* record boot time */
 	return err;
 }
@@ -286,19 +289,11 @@ static int nfsd_init_socks(int port)
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
 
-- 
1.5.5.6

