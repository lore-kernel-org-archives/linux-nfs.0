From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: [Patch] fix rpc.gssd problem with ccache
Date: Wed, 25 Jun 2008 19:02:06 +0200
Message-ID: <20080625170206.GC4486@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

gssd_setup_krb5_user_gss_ccache must return an error if no usable cache is 
found. Trying to use invalid default cache and continue is not good idea at all.

Signed-off-by: Lukas Hejtmanek <xhejtman@ics.muni.cz>

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 7202b64..e7cefc5 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -703,9 +703,8 @@ handle_krb5_upcall(struct clnt_info *clp)
 	if (uid != 0 || (uid == 0 && root_uses_machine_creds == 0)) {
 		/* Tell krb5 gss which credentials cache to use */
 		for (dirname = ccachesearch; *dirname != NULL; dirname++) {
-			gssd_setup_krb5_user_gss_ccache(uid, clp->servername, *dirname);
-
-			create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
+			if(!gssd_setup_krb5_user_gss_ccache(uid, clp->servername, *dirname))
+				create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
 							     AUTHTYPE_KRB5);
 			if (create_resp == 0)
 				break;
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 983fb2c..4915293 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -994,9 +994,10 @@ err_cache:
  * do the best we can.
  *
  * Returns:
- *	void
+ *	0 = ok
+ *	1 = error
  */
-void
+int
 gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername, char *dirname)
 {
 	char			buf[MAX_NETOBJ_SZ];
@@ -1010,11 +1011,11 @@ gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername, char *dirname)
 		free(d);
 	}
 	else
-		snprintf(buf, sizeof(buf), "FILE:%s/%s%u",
-			dirname, GSSD_DEFAULT_CRED_PREFIX, uid);
+		return 1;
 	printerr(2, "using %s as credentials cache for client with "
 		    "uid %u for server %s\n", buf, uid, servername);
 	gssd_set_krb5_ccache_name(buf);
+	return 0;
 }
 
 /*
diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
index 431fdaf..addae1c 100644
--- a/utils/gssd/krb5_util.h
+++ b/utils/gssd/krb5_util.h
@@ -17,7 +17,7 @@ struct gssd_k5_kt_princ {
 };
 
 
-void gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername,
+int gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername,
 				     char *dirname);
 int  gssd_get_krb5_machine_cred_list(char ***list);
 void gssd_free_krb5_machine_cred_list(char **list);
