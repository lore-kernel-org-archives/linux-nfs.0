Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f43.google.com ([209.85.128.43]:58728 "EHLO
	mail-qe0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754577Ab3JCTta (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Oct 2013 15:49:30 -0400
Received: by mail-qe0-f43.google.com with SMTP id gh4so2173671qeb.30
        for <linux-nfs@vger.kernel.org>; Thu, 03 Oct 2013 12:49:29 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/2] gssd: have process_krb5_upcall fork before handling upcall
Date: Thu,  3 Oct 2013 15:49:19 -0400
Message-Id: <1380829760-4928-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1380829760-4928-1-git-send-email-jlayton@redhat.com>
References: <1380829760-4928-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to handle KEYRING: caches, we need to be able to switch the
real UID of the process to the designated one, but that opens the door
to allowing gssd to be killed or reniced during the window where we've
switched credentials.

Change gssd to fork before trying to handle each upcall. The child will
do the work to establish the context and the parent task will just wait
for it to exit. It's still possible for the child to be killed or
reniced, but that would only affect a single upcall instead of the
entire daemon.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index e58c341..fd258f7 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -67,6 +67,8 @@
 #include <errno.h>
 #include <gssapi/gssapi.h>
 #include <netdb.h>
+#include <sys/types.h>
+#include <sys/wait.h>
 
 #include "gssd.h"
 #include "err_util.h"
@@ -982,6 +984,23 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 	int			err, downcall_err = -EACCES;
 	gss_cred_id_t		gss_cred;
 	OM_uint32		maj_stat, min_stat, lifetime_rec;
+	pid_t			pid;
+
+	pid = fork();
+	switch(pid) {
+	case 0:
+		/* Child: fall through to rest of function */
+		break;
+	case -1:
+		/* fork() failed! */
+		printerr(0, "WARNING: unable to fork() to handle upcall: %s\n",
+				strerror(errno));
+		return;
+	default:
+		/* Parent: just wait on child to exit and return */
+		wait(&err);
+		return;
+	}
 
 	printerr(1, "handling krb5 upcall (%s)\n", clp->dirname);
 
@@ -1121,7 +1140,7 @@ out:
 		AUTH_DESTROY(auth);
 	if (rpc_clnt)
 		clnt_destroy(rpc_clnt);
-	return;
+	exit(0);
 
 out_return_error:
 	do_error_downcall(fd, uid, downcall_err);
-- 
1.8.3.1

