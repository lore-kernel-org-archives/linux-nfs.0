Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:36005 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755253Ab3FCBBM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 2 Jun 2013 21:01:12 -0400
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Date: Mon, 03 Jun 2013 11:00:22 +1000
Subject: [PATCH 3/3] gssd: add -N option to use root credentials as machine
 credentials.
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Message-ID: <20130603010022.20080.88360.stgit@notabene.brown>
In-Reply-To: <20130603005219.20080.1927.stgit@notabene.brown>
References: <20130603005219.20080.1927.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since linux-3.7, the kernel asks explicitly for machine credentials
rather than root credentials to authenticate state management requests.

This causes a regression for people who do not have machine
credentials configured and were using "gssd -n" to instruct gssd to
disable the default mapping of using machine credentials to authorise
accesses by 'root'.

This patch adds '-N' flag which instruct gssd explicitly to use 'root'
credentials whenever 'machine' credentials are requested.  Thus
  gssd -n -N
provides the same service that
  gssd -n
used to.

In summary:

Credentials used for different request types and different gssd flags:

   Request type: |     "gssd"      "gssd -n"   "gssd -N"    "gssd -nN"
                 |
     machine     |     machine      machine     root         root
                 |
     root        |     machine      root        machine      root

Signed-off-by: NeilBrown <neilb@suse.de>
---
 utils/gssd/gssd.c      |    9 ++++++---
 utils/gssd/gssd.h      |    1 +
 utils/gssd/gssd.man    |   13 ++++++++++++-
 utils/gssd/gssd_proc.c |   12 +++++++-----
 4 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 8ee478b..7a405b6 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -61,6 +61,7 @@ char ccachedir[PATH_MAX] = GSSD_DEFAULT_CRED_DIR ":" GSSD_USER_CRED_DIR;
 char *ccachesearch[GSSD_MAX_CCACHE_SEARCH + 1];
 int  use_memcache = 0;
 int  root_uses_machine_creds = 1;
+int  machine_uses_root_creds = 0;
 unsigned int  context_timeout = 0;
 char *preferred_realm = NULL;
 
@@ -68,8 +69,7 @@ void
 sig_die(int signal)
 {
 	/* destroy krb5 machine creds */
-	if (root_uses_machine_creds)
-		gssd_destroy_krb5_machine_creds();
+	gssd_destroy_krb5_machine_creds();
 	printerr(1, "exiting on signal %d\n", signal);
 	exit(0);
 }
@@ -102,7 +102,7 @@ main(int argc, char *argv[])
 	char *progname;
 
 	memset(ccachesearch, 0, sizeof(ccachesearch));
-	while ((opt = getopt(argc, argv, "DfvrlmnMp:k:d:t:R:")) != -1) {
+	while ((opt = getopt(argc, argv, "DfvrlmNnMp:k:d:t:R:")) != -1) {
 		switch (opt) {
 			case 'f':
 				fg = 1;
@@ -116,6 +116,9 @@ main(int argc, char *argv[])
 			case 'n':
 				root_uses_machine_creds = 0;
 				break;
+			case 'N':
+				machine_uses_root_creds = 1;
+				break;
 			case 'v':
 				verbosity++;
 				break;
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 86472a1..5057440 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -65,6 +65,7 @@ extern char			keytabfile[PATH_MAX];
 extern char			*ccachesearch[];
 extern int			use_memcache;
 extern int			root_uses_machine_creds;
+extern int			machine_uses_root_creds;
 extern unsigned int 		context_timeout;
 extern char			*preferred_realm;
 
diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index ac13fd4..0a06e8c 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -8,7 +8,7 @@
 rpc.gssd \- RPCSEC_GSS daemon
 .SH SYNOPSIS
 .B rpc.gssd
-.RB [ \-DfMnlvr ]
+.RB [ \-DfMnNlvr ]
 .RB [ \-k
 .IR keytab ]
 .RB [ \-p
@@ -227,6 +227,17 @@ in the foreground and sends output to stderr (as opposed to syslogd)
 When specified, UID 0 is forced to obtain user credentials
 which are used instead of the local system's machine credentials.
 .TP
+.B -N
+With NFSv4, some requests to the server need to authenticated
+as coming from "the machine" rather than from any particular user.
+These requests will normally be authenticated using the "machine
+credentials" even if
+.B -n
+is set.  Adding
+.B -N
+causes these requests to use the credentials of UID 0 in place of the
+machine credentials.
+.TP
 .BI "-k " keytab
 Tells
 .B rpc.gssd
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index b7e2bbb..f9d6f51 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -988,7 +988,8 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 	/*
 	 * If "service" is specified, then the kernel is indicating that
 	 * we must use machine credentials for this request.  (Regardless
-	 * of the uid value or the setting of root_uses_machine_creds.)
+	 * of the uid value or the setting of root_uses_machine_creds,
+	 * though setting machine_uses_root_creds can override this)
 	 * If the service value is "*", then any service name can be used.
 	 * Otherwise, it specifies the service name that should be used.
 	 * (For now, the values of service will only be "*" or "nfs".)
@@ -1008,8 +1009,9 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 	 */
 	printerr(2, "%s: service is '%s'\n", __func__,
 		 service ? service : "<null>");
-	if (uid != 0 || (uid == 0 && root_uses_machine_creds == 0 &&
-				service == NULL)) {
+	if (uid != 0 ||
+	    (!root_uses_machine_creds && !service) ||
+	    ( machine_uses_root_creds &&  service)) {
 		/* Tell krb5 gss which credentials cache to use */
 		/* Try first to acquire credentials directly via GSSAPI */
 		err = gssd_acquire_user_cred(uid, &gss_cred);
@@ -1028,8 +1030,8 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 		}
 	}
 	if (create_resp != 0) {
-		if (uid == 0 && (root_uses_machine_creds == 1 ||
-				service != NULL)) {
+		if ((uid == 0 && root_uses_machine_creds) ||
+		    (service != NULL && !machine_uses_root_creds)) {
 			int nocache = 0;
 			int success = 0;
 			do {


