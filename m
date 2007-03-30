From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 5/8] Use newly added keytab functions
Date: Fri, 30 Mar 2007 18:32:14 -0400
Message-ID: <20070330223214.28802.46584.stgit@RoCk.CiTi.UmIcH.EdU>
References: <20070330222511.28802.38147.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HXPdl-0000Kl-UC
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 15:32:14 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HXPdn-0006KT-L3
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 15:32:16 -0700
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

Use the new functions added in the previous patch.

Obtain machine credentials in a pre-determined order

Look for appropriate machine credentials in the following order:
     root/<fqdn>@REALM
     nfs/<fqdn>@REALM
     host/<fqdn>@REALM
     root/<any-name>@REALM
     nfs/<any-name>@REALM
     host/<any-name>@REALM

The first matching credential will be used.

Also, the machine credentials to be used are now determined
"on-demand" rather than at gssd startup.  This allows keytab
additions to be noticed and used without requiring a restart of gssd.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/gssd.c      |    4 ----
 utils/gssd/gssd.man    |   21 ++++++++++++++++-----
 utils/gssd/gssd_proc.c |    8 +++++---
 utils/gssd/krb5_util.c |   15 ++++++++-------
 utils/gssd/krb5_util.h |    3 ++-
 5 files changed, 31 insertions(+), 20 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 747637c..b6c4ee4 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -165,10 +165,6 @@ #endif
 	signal(SIGTERM, sig_die);
 	signal(SIGHUP, sig_hup);
 
-	/* Process keytab file and get machine credentials */
-	if (root_uses_machine_creds)
-		gssd_refresh_krb5_machine_creds();
-
 	gssd_run();
 	printerr(0, "gssd_run returned!\n");
 	abort();
diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index f2ecd69..8da10b2 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -45,14 +45,25 @@ to use the keys found in
 .I keytab
 to obtain "machine credentials".
 The default value is "/etc/krb5.keytab".
+.IP
 Previous versions of
 .B rpc.gssd
 used only "nfs/*" keys found within the keytab.
-Now, the first keytab entry for each distinct Kerberos realm
-within the keytab is used.  This means that an NFS client
-no longer needs an "nfs/hostname" principal and keytab entry,
-but can instead use a "host/hostname" (or any other) keytab
-entry that is available.
+To be more consistent with other implementations, we now look for
+specific keytab entries.  The search order for keytabs to be used
+for "machine credentials" is now:
+.br
+  root/<hostname>@<REALM>
+.br
+  nfs/<hostname>@<REALM>
+.br
+  host/<hostname>@<REALM>
+.br
+  root/<anyname>@<REALM>
+.br
+  nfs/<anyname>@<REALM>
+.br
+  host/<anyname>@<REALM>
 .TP
 .B -p path
 Tells
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index eff740c..48880b6 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -700,14 +700,16 @@ handle_krb5_upcall(struct clnt_info *clp
 		if (uid == 0 && root_uses_machine_creds == 1) {
 			int success = 0;
 
+			gssd_refresh_krb5_machine_credential(clp->servername,
+							     NULL);
 			/*
 			 * Get a list of credential cache names and try each
 			 * of them until one works or we've tried them all
 			 */
 			if (gssd_get_krb5_machine_cred_list(&credlist)) {
-				printerr(0, "WARNING: Failed to obtain machine "
-					 "credentials for connection to "
-					 "server %s\n", clp->servername);
+				printerr(0, "ERROR: No credentials found "
+					 "for connection to server %s\n",
+					 clp->servername);
 					goto out_return_error;
 			}
 			for (ccname = credlist; ccname && *ccname; ccname++) {
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 20396e0..dee2639 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -358,8 +358,8 @@ #ifdef TEST_SHORT_LIFETIME
 	printerr(0, "WARNING: Using (debug) short machine cred lifetime!\n");
 	krb5_get_init_creds_opt_set_tkt_life(&options, 5*60);
 #endif
-        if ((code = krb5_get_init_creds_keytab(context, &my_creds, ple->princ,
-	                                  kt, 0, NULL, &options))) {
+	if ((code = krb5_get_init_creds_keytab(context, &my_creds, ple->princ,
+					       kt, 0, NULL, &options))) {
 		char *pname;
 		if ((krb5_unparse_name(context, ple->princ, &pname))) {
 			pname = NULL;
@@ -1146,18 +1146,19 @@ gssd_get_krb5_machine_cred_list(char ***
 	retval = -1;
 	*list = (char **) NULL;
 
-	/* Refresh machine credentials */
-	if ((retval = gssd_refresh_krb5_machine_creds())) {
-		goto out;
-	}
-
 	if ((l = (char **) malloc(listsize * sizeof(char *))) == NULL) {
 		retval = ENOMEM;
 		goto out;
 	}
 
+	/* Need to serialize list if we ever become multi-threaded! */
+
 	for (ple = gssd_k5_kt_princ_list; ple; ple = ple->next) {
 		if (ple->ccname) {
+			/* Make sure cred is up-to-date before returning it */
+			retval = gssd_refresh_krb5_machine_credential(NULL, ple);
+			if (retval)
+				continue;
 			if (i + 1 > listsize) {
 				listsize += listinc;
 				l = (char **)
diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
index 625d53c..ce7cb57 100644
--- a/utils/gssd/krb5_util.h
+++ b/utils/gssd/krb5_util.h
@@ -5,7 +5,8 @@ #include <krb5.h>
 
 /*
  * List of principals from our keytab that we
- * may try to get credentials for
+ * will try to use to obtain credentials
+ * (known as a principal list entry (ple))
  */
 struct gssd_k5_kt_princ {
 	struct gssd_k5_kt_princ *next;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
