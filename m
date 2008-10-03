From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] NLM: Remove "proto" argument from lockd_up()
Date: Fri, 03 Oct 2008 17:15:30 -0400
Message-ID: <20081003211530.9870.25358.stgit@ingres.1015granger.net>
References: <20081003211305.9870.6835.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:55254 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753150AbYJCVPw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2008 17:15:52 -0400
In-Reply-To: <20081003211305.9870.6835.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Now that lockd_up() starts listeners for both transports, the
"proto" argument is no longer needed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Neil Brown <neilb@suse.de>
---

 fs/lockd/clntlock.c        |    4 ++--
 fs/lockd/svc.c             |    3 +--
 fs/nfsd/nfsctl.c           |    5 ++---
 fs/nfsd/nfssvc.c           |   19 +++++++------------
 include/linux/lockd/bind.h |    2 +-
 5 files changed, 13 insertions(+), 20 deletions(-)

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 2976bf0..8307dd6 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -54,7 +54,7 @@ struct nlm_host *nlmclnt_init(const struct nlmclnt_initdata *nlm_init)
 	u32 nlm_version = (nlm_init->nfs_version == 2) ? 1 : 4;
 	int status;
 
-	status = lockd_up(nlm_init->protocol);
+	status = lockd_up();
 	if (status < 0)
 		return ERR_PTR(status);
 
@@ -215,7 +215,7 @@ reclaimer(void *ptr)
 	/* This one ensures that our parent doesn't terminate while the
 	 * reclaim is in progress */
 	lock_kernel();
-	lockd_up(0); /* note: this cannot fail as lockd is already running */
+	lockd_up();	/* note: this cannot fail as lockd is already running */
 
 	dprintk("lockd: reclaiming locks for host %s\n", host->h_name);
 
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 583d30d..ea9cfa4 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -244,8 +244,7 @@ static int make_socks(struct svc_serv *serv)
 /*
  * Bring up the lockd process if it's not already up.
  */
-int
-lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
+int lockd_up(void)
 {
 	struct svc_serv *serv;
 	int		error = 0;
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index c53e65f..862dff5 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -614,10 +614,9 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size)
 			return -EINVAL;
 		err = nfsd_create_serv();
 		if (!err) {
-			int proto = 0;
-			err = svc_addsock(nfsd_serv, fd, buf, &proto);
+			err = svc_addsock(nfsd_serv, fd, buf, NULL);
 			if (err >= 0) {
-				err = lockd_up(proto);
+				err = lockd_up();
 				if (err < 0)
 					svc_sock_names(buf+strlen(buf)+1, nfsd_serv, buf);
 			}
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 4eed938..052325a 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -244,25 +244,20 @@ static int nfsd_init_socks(int port)
 	if (!list_empty(&nfsd_serv->sv_permsocks))
 		return 0;
 
-	error = lockd_up(IPPROTO_UDP);
-	if (error >= 0) {
-		error = svc_create_xprt(nfsd_serv, "udp", port,
+	error = svc_create_xprt(nfsd_serv, "udp", port,
 					SVC_SOCK_DEFAULTS);
-		if (error < 0)
-			lockd_down();
-	}
 	if (error < 0)
 		return error;
 
-	error = lockd_up(IPPROTO_TCP);
-	if (error >= 0) {
-		error = svc_create_xprt(nfsd_serv, "tcp", port,
+	error = svc_create_xprt(nfsd_serv, "tcp", port,
 					SVC_SOCK_DEFAULTS);
-		if (error < 0)
-			lockd_down();
-	}
 	if (error < 0)
 		return error;
+
+	error = lockd_up();
+	if (error < 0)
+		return error;
+
 	return 0;
 }
 
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index 3d25bcd..7fa42fd 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -53,7 +53,7 @@ extern void	nlmclnt_done(struct nlm_host *host);
 
 extern int	nlmclnt_proc(struct nlm_host *host, int cmd,
 					struct file_lock *fl);
-extern int	lockd_up(int proto);
+extern int	lockd_up(void);
 extern void	lockd_down(void);
 
 unsigned long get_nfs_grace_period(void);

