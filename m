Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:48701 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752203Ab0I0SEA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Sep 2010 14:04:00 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1P0Hhq-0004af-2s
	for linux-nfs@vger.kernel.org; Mon, 27 Sep 2010 13:41:39 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] svcgssd: Adding a <-p principal> flag
Date: Mon, 27 Sep 2010 13:41:36 -0400
Message-Id: <1285609297-3424-2-git-send-email-steved@redhat.com>
In-Reply-To: <1285609297-3424-1-git-send-email-steved@redhat.com>
References: <1285609297-3424-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Eberhard Kuemmerle <e.kuemmerle@fz-juelich.de>

Allow the principal that is used to get the machines creds definable
on the command like with the new '-p <principal>'. This is useful
in cluster environments.

Signed-off-by:  Eberhard Kuemmerle <E.Kuemmerle@fz-juelich.de>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/gss_util.c |    4 ++--
 utils/gssd/gss_util.h |    2 +-
 utils/gssd/gssd.h     |    1 -
 utils/gssd/svcgssd.c  |   28 ++++++++++++++++++++--------
 4 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/utils/gssd/gss_util.c b/utils/gssd/gss_util.c
index 99aceb3..8fe1e9b 100644
--- a/utils/gssd/gss_util.c
+++ b/utils/gssd/gss_util.c
@@ -191,7 +191,7 @@ pgsserr(char *msg, u_int32_t maj_stat, u_int32_t min_stat, const gss_OID mech)
 }
 
 int
-gssd_acquire_cred(char *server_name)
+gssd_acquire_cred(char *server_name, const gss_OID oid)
 {
 	gss_buffer_desc name;
 	gss_name_t target_name;
@@ -203,7 +203,7 @@ gssd_acquire_cred(char *server_name)
 	name.length = strlen(server_name);
 
 	maj_stat = gss_import_name(&min_stat, &name,
-			(const gss_OID) GSS_C_NT_HOSTBASED_SERVICE,
+			oid,
 			&target_name);
 
 	if (maj_stat != GSS_S_COMPLETE) {
diff --git a/utils/gssd/gss_util.h b/utils/gssd/gss_util.h
index bfe8c4a..67b3077 100644
--- a/utils/gssd/gss_util.h
+++ b/utils/gssd/gss_util.h
@@ -37,7 +37,7 @@
 
 extern gss_cred_id_t	gssd_creds;
 
-int gssd_acquire_cred(char *server_name);
+int gssd_acquire_cred(char *server_name, const gss_OID oid);
 void pgsserr(char *msg, u_int32_t maj_stat, u_int32_t min_stat,
 	const gss_OID mech);
 int gssd_check_mechs(void);
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 465c305..b1b5793 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -100,7 +100,6 @@ int update_client_list(void);
 void handle_krb5_upcall(struct clnt_info *clp);
 void handle_spkm3_upcall(struct clnt_info *clp);
 void handle_gssd_upcall(struct clnt_info *clp);
-int gssd_acquire_cred(char *server_name);
 void gssd_run(void);
 
 
diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
index e7375a4..9b463f3 100644
--- a/utils/gssd/svcgssd.c
+++ b/utils/gssd/svcgssd.c
@@ -167,7 +167,7 @@ sig_hup(int signal)
 static void
 usage(char *progname)
 {
-	fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r] [-i]\n",
+	fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r] [-i] [-p principal]\n",
 		progname);
 	exit(1);
 }
@@ -180,9 +180,10 @@ main(int argc, char *argv[])
 	int verbosity = 0;
 	int rpc_verbosity = 0;
 	int idmap_verbosity = 0;
-	int opt;
+	int opt, status;
 	extern char *optarg;
 	char *progname;
+	char *principal = NULL;
 
 	while ((opt = getopt(argc, argv, "fivrnp:")) != -1) {
 		switch (opt) {
@@ -201,6 +202,9 @@ main(int argc, char *argv[])
 			case 'r':
 				rpc_verbosity++;
 				break;
+			case 'p':
+				principal = optarg;
+				break;
 			default:
 				usage(argv[0]);
 				break;
@@ -244,12 +248,20 @@ main(int argc, char *argv[])
 	signal(SIGTERM, sig_die);
 	signal(SIGHUP, sig_hup);
 
-	if (get_creds && !gssd_acquire_cred(GSSD_SERVICE_NAME)) {
-                printerr(0, "unable to obtain root (machine) credentials\n");
-                printerr(0, "do you have a keytab entry for "
-			    "nfs/<your.host>@<YOUR.REALM> in "
-			    "/etc/krb5.keytab?\n");
-		exit(1);
+	if (get_creds) {
+		if (principal)
+			status = gssd_acquire_cred(principal, 
+				((const gss_OID)GSS_C_NT_USER_NAME));
+		else
+			status = gssd_acquire_cred(GSSD_SERVICE_NAME, 
+				(const gss_OID)GSS_C_NT_HOSTBASED_SERVICE);
+		if (status == FALSE) {
+			printerr(0, "unable to obtain root (machine) credentials\n");
+			printerr(0, "do you have a keytab entry for "
+				"nfs/<your.host>@<YOUR.REALM> in "
+				"/etc/krb5.keytab?\n");
+			exit(1);
+		}
 	}
 
 	if (!fg)
-- 
1.7.2.3

