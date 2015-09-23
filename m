Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:62243 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755089AbbIWOay (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Sep 2015 10:30:54 -0400
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <jlayton@poochiereds.net>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 3/4] GSSD only fork when uid is not zeo
Date: Wed, 23 Sep 2015 10:30:15 -0400
Message-ID: <1443018616-1335-4-git-send-email-andros@netapp.com>
In-Reply-To: <1443018616-1335-1-git-send-email-andros@netapp.com>
References: <1443018616-1335-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

commit f9cac65972da588d5218236de60a7be11247a8aa added the fork to
process_krb5_upcall so that the child assumes the uid of the principal
requesting service.

When machine credentials are used, a gssd_k5_kt_princ entry is added to
a global list and used by future upcalls to note when valid machine credentials
have been obtained. When a child process performs this task, the entry to the
global list is lost upon exit, and all upcalls for machine credentials re-fetch
a TGT, even when a valid TGT is in the machine kerberos credential cache.

Since forking is not necessary when the principal has uid=0, solve the
gssd_k5_kt_princ_list issue by only forking when the uid != 0.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Jeff Layton <jlayton@poochiereds.net>
---
 utils/gssd/gssd_proc.c | 62 +++++++++++++++++++++++++++++++-------------------
 1 file changed, 38 insertions(+), 24 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 0e04570..8501f38 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -597,33 +597,11 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 	gss_buffer_desc		token;
 	int			err, downcall_err = -EACCES;
 	OM_uint32		maj_stat, min_stat, lifetime_rec;
-	pid_t			pid;
+	pid_t			pid, childpid = -1;
 	gss_name_t		gacceptor = GSS_C_NO_NAME;
 	gss_OID			mech;
 	gss_buffer_desc		acceptor  = {0};
 
-	pid = fork();
-	switch(pid) {
-	case 0:
-		/* Child: fall through to rest of function */
-		break;
-	case -1:
-		/* fork() failed! */
-		printerr(0, "WARNING: unable to fork() to handle upcall: %s\n",
-				strerror(errno));
-		return;
-	default:
-		/* Parent: just wait on child to exit and return */
-		do {
-			pid = wait(&err);
-		} while(pid == -1 && errno != -ECHILD);
-
-		if (WIFSIGNALED(err))
-			printerr(0, "WARNING: forked child was killed with signal %d\n",
-					WTERMSIG(err));
-		return;
-	}
-
 	printerr(1, "handling krb5 upcall (%s)\n", clp->relpath);
 
 	token.length = 0;
@@ -655,6 +633,37 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 		 service ? service : "<null>");
 	if (uid != 0 || (uid == 0 && root_uses_machine_creds == 0 &&
 				service == NULL)) {
+
+		/* already running as uid 0 */
+		if (uid == 0)
+			goto no_fork;
+
+		printerr(1, "Forking\n");
+		pid = fork();
+		switch(pid) {
+		case 0:
+			/* Child: fall through to rest of function */
+			childpid = getpid();
+			printerr(1, "CHILD forked pid %d \n", childpid);
+			break;
+		case -1:
+			/* fork() failed! */
+			printerr(0, "WARNING: unable to fork() to handle"
+				"upcall: %s\n", strerror(errno));
+			return;
+		default:
+			/* Parent: just wait on child to exit and return */
+			do {
+				pid = wait(&err);
+			} while(pid == -1 && errno != -ECHILD);
+
+			if (WIFSIGNALED(err))
+				printerr(0, "WARNING: forked child was killed"
+					 "with signal %d\n", WTERMSIG(err));
+			return;
+		}
+no_fork:
+
 		auth = krb5_not_machine_creds(clp, uid, tgtname, &downcall_err,
 						&err, &rpc_clnt);
 		if (err)
@@ -721,7 +730,12 @@ out:
 		AUTH_DESTROY(auth);
 	if (rpc_clnt)
 		clnt_destroy(rpc_clnt);
-	exit(0);
+
+	pid = getpid();
+	if (pid == childpid)
+		exit(0);
+	else
+		return;
 
 out_return_error:
 	do_error_downcall(fd, uid, downcall_err);
-- 
1.9.3 (Apple Git-50)

