Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46960 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753056Ab2AQLo2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 06:44:28 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q0HBiSde026294
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 17 Jan 2012 06:44:28 -0500
Subject: svcgssd: Allow administrators to specify timeout for the cached
 context
From: Sachin Prabhu <sprabhu@redhat.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Steve Dickson <steved@redhat.com>
Date: Tue, 17 Jan 2012 11:44:27 +0000
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1326800668.2747.55.camel@sprabhu.fab.redhat.com>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We had a user report that for an export shared with sec=krb5*, any
changes in user credentials(ex: add user to a secondary group) take some
time before they take effect over the NFS share. 

The problem was determined to be caused by the svcgssd process caching
the user credentials. The user credentials were initially cached for an
unlimited amount of time. There was some improvement in this behaviour
with the commit

svcgssd: use the actual context expiration for cache
commit eb3a145789b9eedd39b56e1d76f412435abaa747

The cache expiration time is now set to the time for which the kerberos
ticket is valid. However this is still considered too long. The proposed
solution is to allow administrators to explicitly set a timeout for
which the cache is valid. This is similar to changes which went into
gssd, the corresponding client side program.

The patch adds a -t <timeout> option to rpc.svcgssd so that the server's
administrator can specify an expiry timeout for the cached context.
After this timeout, an upcall is made to obtain the new user
credentials.

The default, timeout 0 results in the old behaviour.

Signed-off-bye: Sachin Prabhu <sprabhu@redhat.com>

diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
index 1afff9e..db99ea3 100644
--- a/utils/gssd/svcgssd.c
+++ b/utils/gssd/svcgssd.c
@@ -70,6 +70,8 @@
  */
 int pipefds[2] = { -1, -1};
 
+unsigned int context_timeout = 0;
+
 static void
 mydaemon(int nochdir, int noclose)
 {
@@ -167,7 +169,7 @@ sig_hup(int signal)
 static void
 usage(char *progname)
 {
-	fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r] [-i] [-p principal]\n",
+	fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r] [-i] [-p principal] [-t timeout]\n",
 		progname);
 	exit(1);
 }
@@ -185,7 +187,7 @@ main(int argc, char *argv[])
 	char *progname;
 	char *principal = NULL;
 
-	while ((opt = getopt(argc, argv, "fivrnp:")) != -1) {
+	while ((opt = getopt(argc, argv, "fivrnp:t:")) != -1) {
 		switch (opt) {
 			case 'f':
 				fg = 1;
@@ -205,6 +207,9 @@ main(int argc, char *argv[])
 			case 'p':
 				principal = optarg;
 				break;
+			case 't':
+				context_timeout = atoi(optarg);
+				break;
 			default:
 				usage(argv[0]);
 				break;
diff --git a/utils/gssd/svcgssd.h b/utils/gssd/svcgssd.h
index 9a2e2e8..869fb63 100644
--- a/utils/gssd/svcgssd.h
+++ b/utils/gssd/svcgssd.h
@@ -40,4 +40,6 @@ void gssd_run(void);
 
 #define GSSD_SERVICE_NAME	"nfs"
 
+extern unsigned int context_timeout;
+
 #endif /* _RPC_SVCGSSD_H_ */
diff --git a/utils/gssd/svcgssd.man b/utils/gssd/svcgssd.man
index 7b2de6b..3688af0 100644
--- a/utils/gssd/svcgssd.man
+++ b/utils/gssd/svcgssd.man
@@ -45,6 +45,14 @@ Use the system default credentials
 .RI (host/ FQDN @ REALM )
 rather than the default
 .RI nfs/ FQDN @ REALM .
+.TP
+.B -t timeout
+Timeout, in seconds, for kernel gss contexts. This option allows you to force
+new kernel contexts to be negotiated after
+.I timeout
+seconds, which allows changing Kerberos tickets and identities frequently.
+The default is no explicit timeout, which means the kernel context will live
+the lifetime of the Kerberos service ticket used in its creation.
 .SH SEE ALSO
 .BR rpc.gssd(8),
 .SH AUTHORS
diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
index c714d99..dae10ca 100644
--- a/utils/gssd/svcgssd_proc.c
+++ b/utils/gssd/svcgssd_proc.c
@@ -497,6 +497,10 @@ handle_nullreq(FILE *f) {
 	/* We no longer need the gss context */
 	gss_delete_sec_context(&ignore_min_stat, &ctx, &ignore_out_tok);
 
+	/* If timeout set, override context timeout */
+	if (context_timeout)
+		ctx_endtime = time(0) + context_timeout;
+
 	do_svc_downcall(&out_handle, &cred, mech, &ctx_token, ctx_endtime,
 			hostbased_name);
 continue_needed:


