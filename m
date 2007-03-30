From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 7/8] Remove the now unused functions
Date: Fri, 30 Mar 2007 18:32:19 -0400
Message-ID: <20070330223219.28802.87863.stgit@RoCk.CiTi.UmIcH.EdU>
References: <20070330222511.28802.38147.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HXPdq-0000LJ-Bh
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 15:32:18 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HXPds-0006Ol-10
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 15:32:20 -0700
In-Reply-To: <20070330222511.28802.38147.stgit@RoCk.CiTi.UmIcH.EdU>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Kevin Coffman <kwc@citi.umich.edu>

Remove functions that are no longer used when when obtaining
machine credentials.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/krb5_util.c |  234 ------------------------------------------------
 utils/gssd/krb5_util.h |    1 
 2 files changed, 0 insertions(+), 235 deletions(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 5d433b1..50773b1 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -134,9 +134,6 @@ static int select_krb5_ccache(const stru
 static int gssd_find_existing_krb5_ccache(uid_t uid, struct dirent **d);
 static int gssd_get_single_krb5_cred(krb5_context context,
 		krb5_keytab kt, struct gssd_k5_kt_princ *ple);
-static int gssd_have_realm_ple(void *realm);
-static int gssd_process_krb5_keytab(krb5_context context, krb5_keytab kt,
-		char *kt_name);
 
 
 /*
@@ -422,147 +419,6 @@ #endif
 }
 
 /*
- * Determine if we already have a ple for the given realm
- *
- * Returns:
- *	0 => no ple found for given realm
- *	1 => found ple for given realm
- */
-static int
-gssd_have_realm_ple(void *r)
-{
-	struct gssd_k5_kt_princ *ple;
-#ifdef HAVE_KRB5
-	krb5_data *realm = (krb5_data *)r;
-#else
-	char *realm = (char *)r;
-#endif
-
-	for (ple = gssd_k5_kt_princ_list; ple; ple = ple->next) {
-#ifdef HAVE_KRB5
-		if ((realm->length == strlen(ple->realm)) &&
-		    (strncmp(realm->data, ple->realm, realm->length) == 0)) {
-#else
-		if (strcmp(realm, ple->realm) == 0) {
-#endif
-		    return 1;
-		}
-	}
-	return 0;
-}
-
-/*
- * Process the given keytab file and create a list of principals we
- * might use as machine credentials.
- *
- * Returns:
- *	0 => Sucess
- *	nonzero => Error
- */
-static int
-gssd_process_krb5_keytab(krb5_context context, krb5_keytab kt, char *kt_name)
-{
-	krb5_kt_cursor cursor;
-	krb5_keytab_entry kte;
-	krb5_error_code code;
-	struct gssd_k5_kt_princ *ple;
-	int retval = -1;
-
-	/*
-	 * Look through each entry in the keytab file and determine
-	 * if we might want to use it as machine credentials.  If so,
-	 * save info in the global principal list (gssd_k5_kt_princ_list).
-	 * Note: (ple == principal list entry)
-	 */
-	if ((code = krb5_kt_start_seq_get(context, kt, &cursor))) {
-		printerr(0, "ERROR: %s while beginning keytab scan "
-			    "for keytab '%s'\n",
-			error_message(code), kt_name);
-		retval = code;
-		goto out;
-	}
-
-	while ((code = krb5_kt_next_entry(context, kt, &kte, &cursor)) == 0) {
-		char *pname;
-		if ((code = krb5_unparse_name(context, kte.principal,
-					      &pname))) {
-			printerr(0, "WARNING: Skipping keytab entry because "
-				    "we failed to unparse principal name: %s\n",
-				 error_message(code));
-			krb5_kt_free_entry(context, &kte);
-			continue;
-		}
-		printerr(2, "Processing keytab entry for principal '%s'\n",
-			 pname);
-		/* Just use the first keytab entry found for each realm */
-	        if ((!gssd_have_realm_ple((void *)&kte.principal->realm)) ) {
-			printerr(2, "We WILL use this entry (%s)\n", pname);
-			ple = malloc(sizeof(struct gssd_k5_kt_princ));
-			if (ple == NULL) {
-				printerr(0, "ERROR: could not allocate storage "
-					    "for principal list entry\n");
-				k5_free_unparsed_name(context, pname);
-				krb5_kt_free_entry(context, &kte);
-				retval = ENOMEM;
-				goto out;
-			}
-			/* These will be filled in later */
-			ple->next = NULL;
-			ple->ccname = NULL;
-			ple->endtime = 0;
-			if ((ple->realm =
-#ifdef HAVE_KRB5
-				strndup(kte.principal->realm.data,
-					kte.principal->realm.length))
-#else
-				strdup(kte.principal->realm))
-#endif
-					== NULL) {
-				printerr(0, "ERROR: %s while copying realm to "
-					    "principal list entry\n",
-					 "not enough memory");
-				k5_free_unparsed_name(context, pname);
-				krb5_kt_free_entry(context, &kte);
-				retval = ENOMEM;
-				goto out;
-			}
-			if ((code = krb5_copy_principal(context,
-					kte.principal, &ple->princ))) {
-				printerr(0, "ERROR: %s while copying principal "
-					    "to principal list entry\n",
-					error_message(code));
-				k5_free_unparsed_name(context, pname);
-				krb5_kt_free_entry(context, &kte);
-				retval = code;
-				goto out;
-			}
-			if (gssd_k5_kt_princ_list == NULL)
-				gssd_k5_kt_princ_list = ple;
-			else {
-				ple->next = gssd_k5_kt_princ_list;
-				gssd_k5_kt_princ_list = ple;
-			}
-		}
-		else {
-			printerr(2, "We will NOT use this entry (%s)\n",
-				pname);
-		}
-		k5_free_unparsed_name(context, pname);
-		krb5_kt_free_entry(context, &kte);
-	}
-
-	if ((code = krb5_kt_end_seq_get(context, kt, &cursor))) {
-		printerr(0, "WARNING: %s while ending keytab scan for "
-			    "keytab '%s'\n",
-			 error_message(code), kt_name);
-	}
-
-	retval = 0;
-  out:
-	return retval;
-}
-
-/*
  * Depending on the version of Kerberos, we either need to use
  * a private function, or simply set the environment variable.
  */
@@ -1039,96 +895,6 @@ gssd_setup_krb5_machine_gss_ccache(char 
 }
 
 /*
- * The first time through this routine, go through the keytab and
- * determine which keys we will try to use as machine credentials.
- * Every time through this routine, try to obtain credentials using
- * the keytab entries selected the first time through.
- *
- * Returns:
- *	0 => obtained one or more credentials
- *	nonzero => error
- *
- */
-
-int
-gssd_refresh_krb5_machine_creds(void)
-{
-	krb5_context context = NULL;
-	krb5_keytab kt = NULL;;
-	krb5_error_code code;
-	int retval = -1;
-	struct gssd_k5_kt_princ *ple;
-	int gotone = 0;
-	static int processed_keytab = 0;
-
-
-	code = krb5_init_context(&context);
-	if (code) {
-		printerr(0, "ERROR: %s while initializing krb5 in "
-			    "gssd_refresh_krb5_machine_creds\n",
-			 error_message(code));
-		retval = code;
-		goto out;
-	}
-
-	printerr(1, "Using keytab file '%s'\n", keytabfile);
-
-	if ((code = krb5_kt_resolve(context, keytabfile, &kt))) {
-		printerr(0, "ERROR: %s while resolving keytab '%s'\n",
-			 error_message(code), keytabfile);
-		goto out;
-	}
-
-	/* Only go through the keytab file once.  Only print messages once. */
-	if (gssd_k5_kt_princ_list == NULL && !processed_keytab) {
-		processed_keytab = 1;
-		gssd_process_krb5_keytab(context, kt, keytabfile);
-		if (gssd_k5_kt_princ_list == NULL) {
-			printerr(0, "ERROR: No usable keytab entries found in "
-				    "keytab '%s'\n", keytabfile);
-			printerr(0, "Do you have a valid keytab entry for "
-				    "%s/<your.host>@<YOUR.REALM> in "
-				    "keytab file %s ?\n",
-				    GSSD_SERVICE_NAME, keytabfile);
-			printerr(0, "Continuing without (machine) credentials "
-				    "- nfs4 mounts with Kerberos will fail\n");
-		}
-	}
-
-	/*
-	 * If we don't have any keytab entries we liked, then we have a problem
-	 */
-	if (gssd_k5_kt_princ_list == NULL) {
-		retval = ENOENT;
-		goto out;
-	}
-
-	/*
-	 * Now go through the list of saved entries and get initial
-	 * credentials for them (We can't do this while making the
-	 * list because it messes up the keytab iteration cursor
-	 * when we use the keytab to get credentials.)
-	 */
-	for (ple = gssd_k5_kt_princ_list; ple; ple = ple->next) {
-		if ((gssd_get_single_krb5_cred(context, kt, ple)) == 0) {
-			gotone++;
-		}
-	}
-	if (!gotone) {
-		printerr(0, "ERROR: No usable machine credentials obtained\n");
-		goto out;
-	}
-
-	retval = 0;
-  out:
-  	if (kt) krb5_kt_close(context, kt);
-	krb5_free_context(context);
-
-	return retval;
-}
-
-
-/*
  * Return an array of pointers to names of credential cache files
  * which can be used to try to create gss contexts with a server.
  *
diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
index ce7cb57..6041048 100644
--- a/utils/gssd/krb5_util.h
+++ b/utils/gssd/krb5_util.h
@@ -19,7 +19,6 @@ struct gssd_k5_kt_princ {
 
 void gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername);
 int  gssd_get_krb5_machine_cred_list(char ***list);
-int  gssd_refresh_krb5_machine_creds(void);
 void gssd_free_krb5_machine_cred_list(char **list);
 void gssd_setup_krb5_machine_gss_ccache(char *servername);
 void gssd_destroy_krb5_machine_creds(void);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
