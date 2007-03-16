From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 2/4] Add option to allow root to use credentials other
	than machine credentials
Date: Fri, 16 Mar 2007 10:27:44 -0400
Message-ID: <20070316142743.6349.68414.stgit@RoCk.CiTi.UmIcH.EdU>
References: <20070316141826.6349.9988.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HSDPC-0007EE-T7
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 07:27:42 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HSDPE-0006Po-Je
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 07:27:45 -0700
In-Reply-To: <20070316141826.6349.9988.stgit@RoCk.CiTi.UmIcH.EdU>
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

Add a new option ("-n") to rpc.gssd to indicate that accesses as root
(uid 0) should not use machine credentials, but should instead use
"normal" Kerberos credentials obtained by root.

This change was prompted by a suggestion and patch from Daniel
Muntz <Dan.Muntz@netapp.com>.  That patch suggested trying "normal"
credentials first and falling back to using machine creds for
uid 0 if normal creds failed.

This opens up the case where root may have credentials as "foo@REALM"
and begins accessing files.  Then the context using those credentials
expires and must be renewed.  If the credentials are now expired, then
root's new context would fall back and be created with the machine
credentials.

Instead, this patch insists that the administrator choose to use either
machine credentials for accesses by uid 0 (the default behavior, as
it was before) or "normal" credentials.  In the latter case, arrangements
must be made to obtain credentials before attempting a mount.  There
should be no doubts which credentials are used for uid 0.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/gssd.c      |   14 ++++++--
 utils/gssd/gssd.h      |    1 +
 utils/gssd/gssd.man    |   26 +++++++++------
 utils/gssd/gssd_proc.c |   82 +++++++++++++++++++++++++-----------------------
 4 files changed, 69 insertions(+), 54 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 9988fe4..319dca4 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -57,12 +57,14 @@ char pipefsdir[PATH_MAX] = GSSD_PIPEFS_D
 char keytabfile[PATH_MAX] = GSSD_DEFAULT_KEYTAB_FILE;
 char ccachedir[PATH_MAX] = GSSD_DEFAULT_CRED_DIR;
 int  use_memcache = 0;
+int  root_uses_machine_creds = 1;
 
 void
 sig_die(int signal)
 {
 	/* destroy krb5 machine creds */
-	gssd_destroy_krb5_machine_creds();
+	if (root_uses_machine_creds)
+		gssd_destroy_krb5_machine_creds();
 	printerr(1, "exiting on signal %d\n", signal);
 	exit(1);
 }
@@ -78,7 +80,7 @@ sig_hup(int signal)
 static void
 usage(char *progname)
 {
-	fprintf(stderr, "usage: %s [-f] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir]\n",
+	fprintf(stderr, "usage: %s [-f] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir]\n",
 		progname);
 	exit(1);
 }
@@ -93,7 +95,7 @@ main(int argc, char *argv[])
 	extern char *optarg;
 	char *progname;
 
-	while ((opt = getopt(argc, argv, "fvrmMp:k:d:")) != -1) {
+	while ((opt = getopt(argc, argv, "fvrmnMp:k:d:")) != -1) {
 		switch (opt) {
 			case 'f':
 				fg = 1;
@@ -104,6 +106,9 @@ main(int argc, char *argv[])
 			case 'M':
 				use_memcache = 1;
 				break;
+			case 'n':
+				root_uses_machine_creds = 0;
+				break;
 			case 'v':
 				verbosity++;
 				break;
@@ -160,7 +165,8 @@ #endif
 	signal(SIGHUP, sig_hup);
 
 	/* Process keytab file and get machine credentials */
-	gssd_refresh_krb5_machine_creds();
+	if (root_uses_machine_creds)
+		gssd_refresh_krb5_machine_creds();
 
 	gssd_run();
 	printerr(0, "gssd_run returned!\n");
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index ec91e89..3622b48 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -62,6 +62,7 @@ extern char			pipefsdir[PATH_MAX];
 extern char			keytabfile[PATH_MAX];
 extern char			ccachedir[PATH_MAX];
 extern int			use_memcache;
+extern int			root_uses_machine_creds;
 
 TAILQ_HEAD(clnt_list_head, clnt_info) clnt_list;
 
diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index 250d26f..1a30d69 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -2,11 +2,11 @@
 .\" rpc.gssd(8)
 .\"
 .\" Copyright (C) 2003 J. Bruce Fields <bfields@umich.edu>
-.TH rpc.gssd 8 "17 Mar 2003"
+.TH rpc.gssd 8 "14 Mar 2007"
 .SH NAME
 rpc.gssd \- rpcsec_gss daemon
 .SH SYNOPSIS
-.B "rpc.gssd [-f] [-k keytab] [-p pipefsdir] [-v] [-r] [-d ccachedir]"
+.B "rpc.gssd [-f] [-n] [-k keytab] [-p pipefsdir] [-v] [-r] [-d ccachedir]"
 .SH DESCRIPTION
 The rpcsec_gss protocol gives a means of using the gss-api generic security
 api to provide security for protocols using rpc (in particular, nfs).  Before
@@ -25,6 +25,19 @@ Runs
 .B rpc.gssd
 in the foreground and sends output to stderr (as opposed to syslogd)
 .TP
+.B -n
+By default,
+.B rpc.gssd
+treats accesses by the user with UID 0 specially, and uses
+"machine credentials" for all accesses by that user which
+require Kerberos authentication.
+With the \-n option, "machine credentials" will not be used
+for accesses by UID 0.  Instead, credentials must be obtained
+manually like all other users.  Use of this option means that
+"root" must manually obtain Kerberos credentials before
+attemtpting to mount an nfs filesystem requiring Kerberos
+authentication.
+.TP
 .B -k keytab
 Tells
 .B rpc.gssd
@@ -32,15 +45,6 @@ to use the keys for principals nfs/hostn
 .I keytab
 to obtain machine credentials.
 The default value is "/etc/krb5.keytab".
-.\".TP
-.\".B -m
-.\"Ordinarily,
-.\".B rpc.gssd
-.\"looks for a cached ticket for user $UID in /tmp/krb5cc_$UID.
-.\"With the -m option, the user with uid 0 will be treated specially, and will
-.\"be mapped instead to the credentials for the principal nfs/hostname found in
-.\"the keytab file.
-.\"(This option is now the default and is ignored if specified.)
 .TP
 .B -p path
 Tells
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 68d645d..04de4e6 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -675,6 +675,7 @@ handle_krb5_upcall(struct clnt_info *clp
 	gss_buffer_desc		token;
 	char			**credlist = NULL;
 	char			**ccname;
+	int			create_resp = -1;
 
 	printerr(1, "handling krb5 upcall\n");
 
@@ -688,49 +689,52 @@ handle_krb5_upcall(struct clnt_info *clp
 		goto out;
 	}
 
-	if (uid == 0) {
-		int success = 0;
-
-		/*
-		 * Get a list of credential cache names and try each
-		 * of them until one works or we've tried them all
-		 */
-		if (gssd_get_krb5_machine_cred_list(&credlist)) {
-			printerr(0, "WARNING: Failed to obtain machine "
-				    "credentials for connection to "
-				    "server %s\n", clp->servername);
-				goto out_return_error;
-		}
-		for (ccname = credlist; ccname && *ccname; ccname++) {
-			gssd_setup_krb5_machine_gss_ccache(*ccname);
-			if ((create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
-						    AUTHTYPE_KRB5)) == 0) {
-				/* Success! */
-				success++;
-				break;
-			}
-			printerr(2, "WARNING: Failed to create krb5 context "
-				    "for user with uid %d with credentials "
-				    "cache %s for server %s\n",
-				 uid, *ccname, clp->servername);
-		}
-		gssd_free_krb5_machine_cred_list(credlist);
-		if (!success) {
-			printerr(0, "WARNING: Failed to create krb5 context "
-				    "for user with uid %d with any "
-				    "credentials cache for server %s\n",
-				 uid, clp->servername);
-			goto out_return_error;
-		}
-	}
-	else {
+	if (uid != 0 || (uid == 0 && root_uses_machine_creds == 0)) {
 		/* Tell krb5 gss which credentials cache to use */
 		gssd_setup_krb5_user_gss_ccache(uid, clp->servername);
 
-		if ((create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
-							AUTHTYPE_KRB5)) != 0) {
+		create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
+						     AUTHTYPE_KRB5);
+	}
+	if (create_resp != 0) {
+		if (uid == 0 && root_uses_machine_creds == 1) {
+			int success = 0;
+
+			/*
+			 * Get a list of credential cache names and try each
+			 * of them until one works or we've tried them all
+			 */
+			if (gssd_get_krb5_machine_cred_list(&credlist)) {
+				printerr(0, "WARNING: Failed to obtain machine "
+					 "credentials for connection to "
+					 "server %s\n", clp->servername);
+					goto out_return_error;
+			}
+			for (ccname = credlist; ccname && *ccname; ccname++) {
+				gssd_setup_krb5_machine_gss_ccache(*ccname);
+				if ((create_auth_rpc_client(clp, &rpc_clnt,
+							    &auth, uid,
+							    AUTHTYPE_KRB5)) == 0) {
+					/* Success! */
+					success++;
+					break;
+				}
+				printerr(2, "WARNING: Failed to create krb5 context "
+					 "for user with uid %d with credentials "
+					 "cache %s for server %s\n",
+					 uid, *ccname, clp->servername);
+			}
+			gssd_free_krb5_machine_cred_list(credlist);
+			if (!success) {
+				printerr(0, "WARNING: Failed to create krb5 context "
+					 "for user with uid %d with any "
+					 "credentials cache for server %s\n",
+					 uid, clp->servername);
+				goto out_return_error;
+			}
+		} else {
 			printerr(0, "WARNING: Failed to create krb5 context "
-				    "for user with uid %d for server %s\n",
+				 "for user with uid %d for server %s\n",
 				 uid, clp->servername);
 			goto out_return_error;
 		}

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
