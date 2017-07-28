Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:53523 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752949AbdG1Uu1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Jul 2017 16:50:27 -0400
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <anna.schumaker@netapp.com>, <olga.kornievskaia@netapp.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 2/2] GSSD add option to not put gss version in downcall
Date: Fri, 28 Jul 2017 16:50:22 -0400
Message-ID: <1501275022-24313-3-git-send-email-andros@netapp.com>
In-Reply-To: <1501275022-24313-1-git-send-email-andros@netapp.com>
References: <1501275022-24313-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This results in using GSSv1, and not trying GSSv3

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 utils/gssd/gssd.c      | 9 +++++++--
 utils/gssd/gssd.h      | 1 +
 utils/gssd/gssd_proc.c | 2 +-
 3 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 4d18d35..58cd0b2 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -89,6 +89,8 @@ unsigned int  rpc_timeout = 5;
 char *preferred_realm = NULL;
 /* Avoid DNS reverse lookups on server names */
 static bool avoid_dns = true;
+/* Add gss version to downcall for GSSv3 */
+bool use_gss_vers = true;
 int thread_started = false;
 pthread_mutex_t pmutex = PTHREAD_MUTEX_INITIALIZER;
 pthread_cond_t pcond = PTHREAD_COND_INITIALIZER;
@@ -832,7 +834,7 @@ sig_die(int signal)
 static void
 usage(char *progname)
 {
-	fprintf(stderr, "usage: %s [-f] [-l] [-M] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir] [-t timeout] [-R preferred realm] [-D]\n",
+	fprintf(stderr, "usage: %s [-f] [-l] [-M] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir] [-t timeout] [-R preferred realm] [-D] [-G]\n",
 		progname);
 	exit(1);
 }
@@ -877,7 +879,7 @@ main(int argc, char *argv[])
 	if (s)
 		preferred_realm = s;
 
-	while ((opt = getopt(argc, argv, "DfvrlmnMp:k:d:t:T:R:")) != -1) {
+	while ((opt = getopt(argc, argv, "DGfvrlmnMp:k:d:t:T:R:")) != -1) {
 		switch (opt) {
 			case 'f':
 				fg = 1;
@@ -925,6 +927,9 @@ main(int argc, char *argv[])
 			case 'D':
 				avoid_dns = false;
 				break;
+			case 'G':
+				use_gss_vers = false;
+				break;
 			default:
 				usage(argv[0]);
 				break;
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index f4f5975..e2604c0 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -66,6 +66,7 @@ extern pthread_mutex_t ple_lock;
 extern pthread_cond_t pcond;
 extern pthread_mutex_t pmutex;
 extern int thread_started;
+extern bool use_gss_vers;
 
 struct clnt_info {
 	TAILQ_ENTRY(clnt_info)	list;
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 689d916..f2cee58 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -149,7 +149,6 @@ do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
 	char    *buf = NULL, *p = NULL, *end = NULL;
 	unsigned int timeout = context_timeout;
 	unsigned int buf_size = 0;
-	bool use_gss_vers = true;
 
 retry:
 	printerr(2, "doing downcall: lifetime_rec=%u acceptor=%.*s"
@@ -330,6 +329,7 @@ create_auth_rpc_client(struct clnt_info *clp,
 	sec.svc = RPCSEC_GSS_SVC_NONE;
 	sec.cred = cred;
 	sec.req_flags = 0;
+	sec.gss_vers = use_gss_vers ? RPCSEC_GSS3_VERSION : RPCSEC_GSS_VERSION;
 	if (authtype == AUTHTYPE_KRB5) {
 		sec.mech = (gss_OID)&krb5oid;
 		sec.req_flags = GSS_C_MUTUAL_FLAG;
-- 
1.8.3.1

