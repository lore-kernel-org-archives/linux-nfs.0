Return-Path: <nfsv4-bounces@linux-nfs.org>
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Subject: [PATCH] gssd: on krb5 upcall,
	have gssd send a more granular error code
Date: Thu,  7 Jan 2010 09:42:35 -0500
Message-Id: <1262875355-4522-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Currently if a krb5 context expires, GSSAPI authenticated RPC calls
start returning error (-EACCES in particular). This is bad when someone has
a long running job that's doing filesystem ops on a krb5 authenticated NFS
mount and just happens to forget to redo a 'kinit' in time.

The existing gssd always does a downcall with a '-1' error code if there
are problems, and the kernel always ignores this error code. Begin to
fix this by having gssd distinguish between someone that has no
credcache at all, and someone who has an expired one. In the case where
there is an existing credcache, have gssd downcall with an error code of
-EKEYEXPIRED. If there's not a credcache, then downcall with an error of
-EACCES.

We can then have the kernel use this error code to handle these
situations differently.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c |    8 ++++++--
 utils/gssd/krb5_util.c |   35 ++++++++++++++++++-----------------
 2 files changed, 24 insertions(+), 19 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 2649236..ae3d2ec 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -901,6 +901,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 	char			**ccname;
 	char			**dirname;
 	int			create_resp = -1;
+	int			err, downcall_err = -EACCES;
 
 	printerr(1, "handling krb5 upcall (%s)\n", clp->dirname);
 
@@ -941,7 +942,10 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 				service == NULL)) {
 		/* Tell krb5 gss which credentials cache to use */
 		for (dirname = ccachesearch; *dirname != NULL; dirname++) {
-			if (gssd_setup_krb5_user_gss_ccache(uid, clp->servername, *dirname) == 0)
+			err = gssd_setup_krb5_user_gss_ccache(uid, clp->servername, *dirname);
+			if (err == -EKEYEXPIRED)
+				downcall_err = -EKEYEXPIRED;
+			else if (!err)
 				create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
 							     AUTHTYPE_KRB5);
 			if (create_resp == 0)
@@ -1031,7 +1035,7 @@ out:
 	return;
 
 out_return_error:
-	do_error_downcall(fd, uid, -1);
+	do_error_downcall(fd, uid, downcall_err);
 	goto out;
 }
 
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index c3c131b..1295f57 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -170,9 +170,8 @@ select_krb5_ccache(const struct dirent *d)
  * what we want. Otherwise, return zero and no dirent pointer.
  * The caller is responsible for freeing the dirent if one is returned.
  *
- * Returns:
- *	0 => could not find an existing entry
- *	1 => found an existing entry
+ * Returns 0 if a valid-looking entry was found and a non-zero error
+ * code otherwise.
  */
 static int
 gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
@@ -186,7 +185,7 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
 	char buf[1030];
 	char *princname = NULL;
 	char *realm = NULL;
-	int score, best_match_score = 0;
+	int score, best_match_score = 0, err = -EACCES;
 
 	memset(&best_match_stat, 0, sizeof(best_match_stat));
 	*d = NULL;
@@ -229,6 +228,7 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
 				printerr(3, "CC file '%s' is expired or corrupt\n",
 					 statname);
 				free(namelist[i]);
+				err = -EKEYEXPIRED;
 				continue;
 			}
 
@@ -284,11 +284,12 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
 		}
 		free(namelist);
 	}
-	if (found)
-	{
+	if (found) {
 		*d = best_match_dir;
+		return 0;
 	}
-	return found;
+
+	return err;
 }
 
 
@@ -1024,29 +1025,29 @@ err_cache:
  * given only a UID.  We really need more information, but we
  * do the best we can.
  *
- * Returns:
- *	0 => a ccache was found
- *	1 => no ccache was found
+ * Returns 0 if a ccache was found, and a non-zero error code otherwise.
  */
 int
 gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername, char *dirname)
 {
 	char			buf[MAX_NETOBJ_SZ];
 	struct dirent		*d;
+	int			err;
 
 	printerr(2, "getting credentials for client with uid %u for "
 		    "server %s\n", uid, servername);
 	memset(buf, 0, sizeof(buf));
-	if (gssd_find_existing_krb5_ccache(uid, dirname, &d)) {
-		snprintf(buf, sizeof(buf), "FILE:%s/%s", dirname, d->d_name);
-		free(d);
-	}
-	else
-		return 1;
+	err = gssd_find_existing_krb5_ccache(uid, dirname, &d);
+	if (err)
+		return err;
+
+	snprintf(buf, sizeof(buf), "FILE:%s/%s", dirname, d->d_name);
+	free(d);
+
 	printerr(2, "using %s as credentials cache for client with "
 		    "uid %u for server %s\n", buf, uid, servername);
 	gssd_set_krb5_ccache_name(buf);
-	return 0;
+	return err;
 }
 
 /*
-- 
1.6.5.2

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
