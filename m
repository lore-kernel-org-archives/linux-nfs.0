Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f180.google.com ([209.85.161.180]:64985 "EHLO
	mail-gg0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754582Ab3JCSmT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Oct 2013 14:42:19 -0400
Received: by mail-gg0-f180.google.com with SMTP id k4so418279ggn.39
        for <linux-nfs@vger.kernel.org>; Thu, 03 Oct 2013 11:42:19 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] gssd: switch real uid instead of just fsuid when looking for user creds
Date: Thu,  3 Oct 2013 14:42:11 -0400
Message-Id: <1380825731-3314-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1380825731-3314-1-git-send-email-jlayton@redhat.com>
References: <1380825731-3314-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The part of process_krb5_upcall that handles non-machine user creds
first tries to query GSSAPI for credentials. If that fails, it then
falls back to trawling through likely credcache locations to find them
and then points $KRB5CCNAME at it before proceeding. There are a number
of bugs in this code that this patch attempts to address.

The code that queries GSSAPI for credentials does it as root and that
almost universally fails to do anything useful unless we happen to be
looking for non-machine root creds. Because of this, gssd almost always
falls back to having to search for credcaches "manually" and then set
$KRB5CCNAME if and when they are found. The code that handles credential
switching is in create_auth_rpc_client, so it's too late to be of any
use here.

Worse yet, the GSSAPI code that handles finding credcaches does it based
on the return from getuid(), so just switching the fsuid or even euid is
insufficient. You must switch the real uid.

This code moves the credential switching into process_krb5_upcall and
makes it use setuid() instead of setfsuid(). That's of course
irreversible so we can't switch back to root after doing so. No matter
though since it's probably safer to do all of this as an unprivileged
user anyway.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_main_loop.c |  3 +--
 utils/gssd/gssd_proc.c      | 28 ++++++++++++----------------
 2 files changed, 13 insertions(+), 18 deletions(-)

diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
index 7b0f568..ccf7fe5 100644
--- a/utils/gssd/gssd_main_loop.c
+++ b/utils/gssd/gssd_main_loop.c
@@ -40,8 +40,7 @@
 #include <sys/socket.h>
 #include <sys/poll.h>
 #include <netinet/in.h>
-#include <sys/types.h>
-#include <sys/wait.h>
+
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 1a58809..4856d08 100644
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
@@ -832,7 +834,6 @@ create_auth_rpc_client(struct clnt_info *clp,
 	CLIENT			*rpc_clnt = NULL;
 	struct rpc_gss_sec	sec;
 	AUTH			*auth = NULL;
-	uid_t			save_uid = -1;
 	int			retval = -1;
 	OM_uint32		min_stat;
 	char			rpc_errmsg[1024];
@@ -841,16 +842,6 @@ create_auth_rpc_client(struct clnt_info *clp,
 	struct sockaddr		*addr = (struct sockaddr *) &clp->addr;
 	socklen_t		salen;
 
-	/* Create the context as the user (not as root) */
-	save_uid = geteuid();
-	if (setfsuid(uid) != 0) {
-		printerr(0, "WARNING: Failed to setfsuid for "
-			    "user with uid %d\n", uid);
-		goto out_fail;
-	}
-	printerr(2, "creating context using fsuid %d (save_uid %d)\n",
-			uid, save_uid);
-
 	sec.qop = GSS_C_QOP_DEFAULT;
 	sec.svc = RPCSEC_GSS_SVC_NONE;
 	sec.cred = cred;
@@ -949,11 +940,6 @@ create_auth_rpc_client(struct clnt_info *clp,
   out:
 	if (sec.cred != GSS_C_NO_CREDENTIAL)
 		gss_release_cred(&min_stat, &sec.cred);
-	/* Restore euid to original value */
-	if (((int)save_uid != -1) && (setfsuid(save_uid) != (int)uid)) {
-		printerr(0, "WARNING: Failed to restore fsuid"
-			    " to uid %d from %d\n", save_uid, uid);
-	}
 	return retval;
 
   out_fail:
@@ -1031,6 +1017,16 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 		 service ? service : "<null>");
 	if (uid != 0 || (uid == 0 && root_uses_machine_creds == 0 &&
 				service == NULL)) {
+
+		/* Create the context as the user (not as root) */
+		if (setuid(uid) != 0) {
+			printerr(0, "WARNING: Failed to setuid for "
+					"user with uid %d\n", uid);
+			goto out_return_error;
+		}
+
+		printerr(2, "creating context using real uid %d\n", uid);
+
 		/* Tell krb5 gss which credentials cache to use */
 		/* Try first to acquire credentials directly via GSSAPI */
 		err = gssd_acquire_user_cred(uid, &gss_cred);
-- 
1.8.3.1

