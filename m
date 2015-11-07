Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51297 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753946AbbKGSOO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Nov 2015 13:14:14 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 53302461C4
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2015 18:14:14 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-59-101.rdu2.redhat.com [10.10.59.101])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id tA7IECrM027545
	for <linux-nfs@vger.kernel.org>; Sat, 7 Nov 2015 13:14:13 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/3] gssd: reworked first level of debugging
Date: Sat,  7 Nov 2015 13:14:08 -0500
Message-Id: <1446920050-5968-2-git-send-email-steved@redhat.com>
In-Reply-To: <1446920050-5968-1-git-send-email-steved@redhat.com>
References: <1446920050-5968-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cleaned up first level of debugging. Only
errors and warnings are logged.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/gssd_proc.c | 24 +++++++++---------------
 utils/gssd/krb5_util.c | 16 ++++++++++------
 2 files changed, 19 insertions(+), 21 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index cee8991..3d9ca75 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -150,7 +150,7 @@ do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
 	unsigned int timeout = context_timeout;
 	unsigned int buf_size = 0;
 
-	printerr(1, "doing downcall: lifetime_rec=%u acceptor=%.*s\n",
+	printerr(2, "doing downcall: lifetime_rec=%u acceptor=%.*s\n",
 		lifetime_rec, acceptor->length, acceptor->value);
 	buf_size = sizeof(uid) + sizeof(timeout) + sizeof(pd->pd_seq_win) +
 		sizeof(pd->pd_ctx_hndl.length) + pd->pd_ctx_hndl.length +
@@ -189,7 +189,7 @@ do_error_downcall(int k5_fd, uid_t uid, int err)
 	unsigned int timeout = 0;
 	int	zero = 0;
 
-	printerr(1, "doing error downcall\n");
+	printerr(2, "doing error downcall\n");
 
 	if (WRITE_BYTES(&p, end, uid)) goto out_err;
 	if (WRITE_BYTES(&p, end, timeout)) goto out_err;
@@ -484,7 +484,7 @@ krb5_not_machine_creds(struct clnt_info *clp, uid_t uid, char *tgtname,
 	char		**dname;
 	int		err, resp = -1;
 
-	printerr(1, "krb5_not_machine_creds: uid %d tgtname %s\n", 
+	printerr(2, "krb5_not_machine_creds: uid %d tgtname %s\n", 
 		uid, tgtname);
 
 	*chg_err = change_identity(uid);
@@ -531,7 +531,7 @@ krb5_use_machine_creds(struct clnt_info *clp, uid_t uid, char *tgtname,
 	int	nocache = 0;
 	int	success = 0;
 
-	printerr(1, "krb5_use_machine_creds: uid %d tgtname %s\n", 
+	printerr(2, "krb5_use_machine_creds: uid %d tgtname %s\n", 
 		uid, tgtname);
 
 	do {
@@ -601,8 +601,6 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 	gss_OID			mech;
 	gss_buffer_desc		acceptor  = {0};
 
-	printerr(1, "handling krb5 upcall (%s)\n", clp->relpath);
-
 	token.length = 0;
 	token.value = NULL;
 	memset(&pd, 0, sizeof(struct authgss_private_data));
@@ -628,8 +626,6 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 	 * used for this case is not important.
 	 *
 	 */
-	printerr(2, "%s: service is '%s'\n", __func__,
-		 service ? service : "<null>");
 	if (uid != 0 || (uid == 0 && root_uses_machine_creds == 0 &&
 				service == NULL)) {
 
@@ -643,7 +639,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 			/* Child: fall through to rest of function */
 			childpid = getpid();
 			unsetenv("KRB5CCNAME");
-			printerr(1, "CHILD forked pid %d \n", childpid);
+			printerr(2, "CHILD forked pid %d \n", childpid);
 			break;
 		case -1:
 			/* fork() failed! */
@@ -676,9 +672,7 @@ no_fork:
 			if (auth == NULL)
 				goto out_return_error;
 		} else {
-			printerr(1, "WARNING: Failed to create krb5 context "
-				 "for user with uid %d for server %s\n",
-				 uid, clp->servername);
+			/* krb5_not_machine_creds logs the error */
 			goto out_return_error;
 		}
 	}
@@ -752,6 +746,8 @@ handle_krb5_upcall(struct clnt_info *clp)
 		return;
 	}
 
+	printerr(2, "\n%s: uid %d (%s)\n", __func__, uid, clp->relpath);
+
 	process_krb5_upcall(clp, uid, clp->krb5_fd, NULL, NULL);
 }
 
@@ -768,8 +764,6 @@ handle_gssd_upcall(struct clnt_info *clp)
 	char			*service = NULL;
 	char			*enctypes = NULL;
 
-	printerr(1, "handling gssd upcall (%s)\n", clp->relpath);
-
 	lbuflen = read(clp->gssd_fd, lbuf, sizeof(lbuf));
 	if (lbuflen <= 0 || lbuf[lbuflen-1] != '\n') {
 		printerr(0, "WARNING: handle_gssd_upcall: "
@@ -778,7 +772,7 @@ handle_gssd_upcall(struct clnt_info *clp)
 	}
 	lbuf[lbuflen-1] = 0;
 
-	printerr(2, "%s: '%s'\n", __func__, lbuf);
+	printerr(2, "\n%s: '%s' (%s)\n", __func__, lbuf, clp->relpath);
 
 	for (p = strtok(lbuf, " "); p; p = strtok(NULL, " ")) {
 		if (!strncmp(p, "mech=", strlen("mech=")))
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index f48de2c..1d91483 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -451,8 +451,7 @@ gssd_get_single_krb5_cred(krb5_context context,
 	}
 
 	code = 0;
-	printerr(2, "Successfully obtained machine credentials for "
-		 "principal '%s' stored in ccache '%s'\n", pname, cc_name);
+	printerr(2, "%s: principal '%s' ccache:'%s'\n", __func__, pname, cc_name);
   out:
 #if HAVE_KRB5_GET_INIT_CREDS_OPT_SET_ADDRESSLESS
 	if (init_opts)
@@ -1410,16 +1409,21 @@ gssd_acquire_krb5_cred(gss_cred_id_t *gss_cred)
 int
 gssd_acquire_user_cred(gss_cred_id_t *gss_cred)
 {
-	OM_uint32 min_stat;
+	OM_uint32 maj_stat, min_stat;
 	int ret;
 
 	ret = gssd_acquire_krb5_cred(gss_cred);
 
 	/* force validation of cred to check for expiry */
 	if (ret == 0) {
-		if (gss_inquire_cred(&min_stat, *gss_cred, NULL, NULL,
-				     NULL, NULL) != GSS_S_COMPLETE)
-			ret = -1;
+		maj_stat = gss_inquire_cred(&min_stat, *gss_cred, 
+			NULL, NULL, NULL, NULL);
+		if (maj_stat != GSS_S_COMPLETE) {
+			if (get_verbosity() > 0)
+				pgsserr("gss_inquire_cred",
+					maj_stat, min_stat, &krb5oid);
+				ret = -1;
+			}
 	}
 
 	return ret;
-- 
2.4.3

