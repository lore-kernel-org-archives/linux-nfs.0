From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: Upcoming nfs-utils 1.1.3 release.
Date: Tue, 24 Jun 2008 10:33:55 +0200
Message-ID: <20080624083355.GW4484@ics.muni.cz>
References: <48600CCC.5000203@RedHat.com> <20080623205704.GU4484@ics.muni.cz>
	<486016B2.1000506@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="GID0FwUMdk1T2AWN"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <486016B2.1000506@RedHat.com>
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


--GID0FwUMdk1T2AWN
Content-Type: text/plain; charset=iso-8859-2
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 23, 2008 at 05:33:38PM -0400, Steve Dickson wrote:
> Sorry I must have missed the posting... would you mind sending me a poi=
nter
> to those posting?

as promissed, my patch is attached. hope you like it :)

--=20
Luk=E1=B9 Hejtm=E1nek

--GID0FwUMdk1T2AWN
Content-Type: text/x-diff; charset=iso-8859-2
Content-Disposition: attachment; filename="gssd.patch"

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index e8612a5..1ad14f7 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -60,6 +60,8 @@ char ccachedir[PATH_MAX] = GSSD_DEFAULT_CRED_DIR;
 char *ccachesearch[GSSD_MAX_CCACHE_SEARCH + 1];
 int  use_memcache = 0;
 int  root_uses_machine_creds = 1;
+char *preferred_realm = NULL;
+int ccache_timeout = 0;
 
 void
 sig_die(int signal)
@@ -82,7 +84,7 @@ sig_hup(int signal)
 static void
 usage(char *progname)
 {
-	fprintf(stderr, "usage: %s [-f] [-M] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir]\n",
+	fprintf(stderr, "usage: %s [-f] [-M] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir][-R preferred realm] [-t ticketstimeout]\n",
 		progname);
 	exit(1);
 }
@@ -99,7 +101,7 @@ main(int argc, char *argv[])
 	char *progname;
 
 	memset(ccachesearch, 0, sizeof(ccachesearch));
-	while ((opt = getopt(argc, argv, "fvrmnMp:k:d:")) != -1) {
+	while ((opt = getopt(argc, argv, "fvrmnMp:k:d:R:t:")) != -1) {
 		switch (opt) {
 			case 'f':
 				fg = 1;
@@ -134,6 +136,12 @@ main(int argc, char *argv[])
 				if (ccachedir[sizeof(ccachedir)-1] != '\0')
 					errx(1, "ccachedir path name too long");
 				break;
+			case 'R':
+				preferred_realm = strdup(optarg);
+				break;
+			case 't':
+				ccache_timeout = atoi(optarg);
+				break;
 			default:
 				usage(argv[0]);
 				break;
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 0f9f428..b3d6c82 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -65,6 +65,8 @@ extern char			keytabfile[PATH_MAX];
 extern char			*ccachesearch[];
 extern int			use_memcache;
 extern int			root_uses_machine_creds;
+extern char			*preferred_realm;
+extern int			ccache_timeout;
 
 TAILQ_HEAD(clnt_list_head, clnt_info) clnt_list;
 
diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index 8fa4f4a..2b5ff27 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -86,6 +86,15 @@ Increases the verbosity of the output (can be specified multiple times).
 .B -r
 If the rpcsec_gss library supports setting debug level,
 increases the verbosity of the output (can be specified multiple times).
+.TP
+.B -R realm
+Tickets from this realm will be preffered when scaning ccache dir.
+By default no realm is preferred.
+.TP
+.B -t timeout
+Timeout for kernel tickets cache. This is workaround in case you want to 
+change kerberos tickets and identities frequently. Default value is 
+0 - no timeout.
 .SH SEE ALSO
 .BR rpc.svcgssd(8)
 .SH AUTHORS
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index be6f440..81e3bb8 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -427,7 +427,7 @@ do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
 	    gss_buffer_desc *context_token)
 {
 	char    *buf = NULL, *p = NULL, *end = NULL;
-	unsigned int timeout = 0; /* XXX decide on a reasonable value */
+	unsigned int timeout = ccache_timeout;
 	unsigned int buf_size = 0;
 
 	printerr(1, "doing downcall\n");
@@ -703,11 +703,10 @@ handle_krb5_upcall(struct clnt_info *clp)
 	if (uid != 0 || (uid == 0 && root_uses_machine_creds == 0)) {
 		/* Tell krb5 gss which credentials cache to use */
 		for (dirname = ccachesearch; *dirname != NULL; dirname++) {
-			gssd_setup_krb5_user_gss_ccache(uid, clp->servername, *dirname);
-
-			create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
+			if(!gssd_setup_krb5_user_gss_ccache(uid, clp->servername, *dirname))
+				create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
 							     AUTHTYPE_KRB5);
-			if (create_resp == 0)
+			if (create_resp == 0) 
 				break;
 		}
 	}
@@ -729,7 +728,7 @@ handle_krb5_upcall(struct clnt_info *clp)
 			}
 			for (ccname = credlist; ccname && *ccname; ccname++) {
 				gssd_setup_krb5_machine_gss_ccache(*ccname);
-				if ((create_auth_rpc_client(clp, &rpc_clnt,
+				if((create_auth_rpc_client(clp, &rpc_clnt,
 							    &auth, uid,
 							    AUTHTYPE_KRB5)) == 0) {
 					/* Success! */
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 512c1cf..ad38cc7 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -135,7 +135,7 @@ static int gssd_find_existing_krb5_ccache(uid_t uid, char *dirname,
 		struct dirent **d);
 static int gssd_get_single_krb5_cred(krb5_context context,
 		krb5_keytab kt, struct gssd_k5_kt_princ *ple);
-
+static int query_krb5_ccache(const char* cred_cache, char **ret_princname, char **ret_realm);
 
 /*
  * Called from the scandir function to weed out potential krb5
@@ -153,7 +153,9 @@ select_krb5_ccache(const struct dirent *d)
 	 * but apparenlty reiser4 always has DT_UNKNOWN.
 	 * Check for IS_REG after stat() call instead.
 	 */
-	if (strstr(d->d_name, GSSD_DEFAULT_CRED_PREFIX))
+	/*if (!strnstr(d->d_name, GSSD_DEFAULT_CRED_PREFIX, strlen(GSSD_DEFAULT_CRED_PREFIX)))
+	 * strnstr is not on all systems! */
+	if (!strncmp(d->d_name, GSSD_DEFAULT_CRED_PREFIX, strlen(GSSD_DEFAULT_CRED_PREFIX)))
 		return 1;
 	else
 		return 0;
@@ -179,6 +181,10 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
 	int found = 0;
 	struct dirent *best_match_dir = NULL;
 	struct stat best_match_stat, tmp_stat;
+	char buf[1030];
+	char *princname;
+	char *realm = NULL;
+	int score, best_match_score = 0;
 
 	memset(&best_match_stat, 0, sizeof(best_match_stat));
 	*d = NULL;
@@ -194,6 +200,8 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
 				 namelist[i]->d_name);
 			snprintf(statname, sizeof(statname),
 				 "%s/%s", dirname, namelist[i]->d_name);
+			snprintf(buf, sizeof(buf), "FILE:%s/%s", dirname, 
+					namelist[i]->d_name);
 			if (lstat(statname, &tmp_stat)) {
 				printerr(0, "Error doing stat on file '%s'\n",
 					 statname);
@@ -213,9 +221,19 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
 				free(namelist[i]);
 				continue;
 			}
-			printerr(3, "CC file '%s' matches owner check and has "
-				 "mtime of %u\n",
-				 namelist[i]->d_name, tmp_stat.st_mtime);
+			if (!query_krb5_ccache(buf, &princname, &realm)) {
+				printerr(3, "CC file '%s' expired or corrupt\n", statname);
+				continue;
+			}
+
+			score = 0;
+			if (preferred_realm && !strcmp(realm, preferred_realm)) 
+				score+=1;
+
+			printerr(3, "CC file '%s'(%s@%s) passed all checks and"
+				    " has mtime of %u\n",
+				 namelist[i]->d_name, princname, realm, 
+				 tmp_stat.st_mtime);
 			/*
 			 * if more than one match is found, return the most
 			 * recent (the one with the latest mtime), and
@@ -224,20 +242,26 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
 			if (!found) {
 				best_match_dir = namelist[i];
 				best_match_stat = tmp_stat;
+				best_match_score = score;
 				found++;
 			}
 			else {
 				/*
-				 * If the current match has an mtime later
+				 * If current score is higher than best match 
+				 * score, we use the current match. Otherwies,
+				 * if the current match has an mtime later
 				 * than the one we are looking at, then use
 				 * the current match.  Otherwise, we still
 				 * have the best match.
 				 */
-				if (tmp_stat.st_mtime >
-					    best_match_stat.st_mtime) {
+				if (best_match_score < score ||
+				    (best_match_score == score && 
+				       tmp_stat.st_mtime >
+					    best_match_stat.st_mtime)) {
 					free(best_match_dir);
 					best_match_dir = namelist[i];
 					best_match_stat = tmp_stat;
+					best_match_score = score;
 				}
 				else {
 					free(namelist[i]);
@@ -248,6 +272,8 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
 					 best_match_dir->d_name,
 					 best_match_stat.st_mtime);
 			}
+			free(princname);
+			free(realm);
 		}
 		free(namelist);
 	}
@@ -884,6 +910,82 @@ out:
 	return retval;
 }
 
+
+static int
+check_for_tgt (krb5_context context, krb5_ccache ccache,
+		krb5_principal principal)
+{
+	krb5_error_code ret;
+	krb5_creds creds;
+	krb5_cc_cursor cur;
+	int found = 0;
+
+	ret = krb5_cc_start_seq_get(context, ccache, &cur);
+	if (ret) 
+		return 0;
+
+	while (!found && !(ret = krb5_cc_next_cred(context, ccache, &cur, &creds))) {
+		if (creds.server->length == 2 &&
+				strcmp(creds.server->realm.data,
+					principal->realm.data) == 0 &&
+				strcmp((char *)creds.server->data[0].data,
+					"krbtgt") == 0 &&
+				strcmp((char *)creds.server->data[1].data,
+					principal->realm.data) == 0 &&
+				creds.times.endtime > time(NULL))
+			found = 1;
+		krb5_free_cred_contents(context, &creds);
+	}
+	if (ret == KRB5_CC_END) {
+		krb5_cc_end_seq_get(context, ccache, &cur);
+	}
+
+	return found;
+}
+
+static
+int query_krb5_ccache(const char* cred_cache, char **ret_princname, char **ret_realm)
+{
+	krb5_error_code ret;
+	krb5_context context;
+	krb5_ccache ccache;
+	krb5_principal principal;
+	int found = 0;
+	char *str = NULL;
+
+	ret = krb5_init_context (&context);
+	if (ret) 
+		return 0;
+
+	if(!cred_cache || krb5_cc_resolve(context, cred_cache, &ccache))
+		goto err_cache;
+
+	if (krb5_cc_set_flags(context, ccache, 0))
+		goto err_princ;
+
+	ret = krb5_cc_get_principal (context, ccache, &principal);
+	if (ret) 
+		goto err_princ;
+
+	found = check_for_tgt (context, ccache, principal);
+	if (found) {
+		ret = krb5_unparse_name (context, principal, ret_princname);
+		if (!ret && (str = strchr(*ret_princname, '@'))) {
+			*str = '\0';
+			*ret_realm = strdup(str+1);
+		} else{
+			found = 0;
+		}
+	}
+	krb5_free_principal (context, principal);
+err_princ:
+	krb5_cc_set_flags(context, ccache,  KRB5_TC_OPENCLOSE);
+	krb5_cc_close (context, ccache);
+err_cache:
+	krb5_free_context (context);
+	return found;
+}
+
 /*==========================*/
 /*===  External routines ===*/
 /*==========================*/
@@ -894,9 +996,11 @@ out:
  * do the best we can.
  *
  * Returns:
- *	void
+ *      0 = ok
+ *      1 = error
+ *	
  */
-void
+int
 gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername, char *dirname)
 {
 	char			buf[MAX_NETOBJ_SZ];
@@ -910,11 +1014,11 @@ gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername, char *dirname)
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
index 431fdaf..27bd692 100644
--- a/utils/gssd/krb5_util.h
+++ b/utils/gssd/krb5_util.h
@@ -17,7 +17,7 @@ struct gssd_k5_kt_princ {
 };
 
 
-void gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername,
+int  gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername,
 				     char *dirname);
 int  gssd_get_krb5_machine_cred_list(char ***list);
 void gssd_free_krb5_machine_cred_list(char **list);

--GID0FwUMdk1T2AWN
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--GID0FwUMdk1T2AWN--
