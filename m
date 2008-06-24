Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Tue, 24 Jun 2008 17:34:32 +0200
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: Steve Dickson <SteveD@redhat.com>
Subject: [Patch] customizable timeouts for kernel cache of kerberos credentials
Message-ID: <20080624153432.GJ4484@ics.muni.cz>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
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


Default expiration time of kerberos tickets is their expiration thus
kdestroy has no effect here. 

This patch adds -t timeout cmd option to rpc.gssd so that client may specify 
timeout for expritation of kerberos tickets in kernel. After this timeout the
rpc.gssd is consulted to pick up a proper kerberos ticked.

By default, timeout is 0 (i.e., no timeout at all) which follows the
previous behavior.

Signed-off-by: Lukas Hejtmanek <xhejtman@ics.muni.cz>


diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index e8612a5..ff5a454 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -60,6 +60,7 @@ char ccachedir[PATH_MAX] = GSSD_DEFAULT_CRED_DIR;
 char *ccachesearch[GSSD_MAX_CCACHE_SEARCH + 1];
 int  use_memcache = 0;
 int  root_uses_machine_creds = 1;
+int  ccache_timeout = 0;
 
 void
 sig_die(int signal)
@@ -82,7 +83,7 @@ sig_hup(int signal)
 static void
 usage(char *progname)
 {
-	fprintf(stderr, "usage: %s [-f] [-M] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir]\n",
+	fprintf(stderr, "usage: %s [-f] [-M] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir] [-t timeout]\n",
 		progname);
 	exit(1);
 }
@@ -99,7 +100,7 @@ main(int argc, char *argv[])
 	char *progname;
 
 	memset(ccachesearch, 0, sizeof(ccachesearch));
-	while ((opt = getopt(argc, argv, "fvrmnMp:k:d:")) != -1) {
+	while ((opt = getopt(argc, argv, "fvrmnMp:k:d:t:")) != -1) {
 		switch (opt) {
 			case 'f':
 				fg = 1;
@@ -134,6 +135,9 @@ main(int argc, char *argv[])
 				if (ccachedir[sizeof(ccachedir)-1] != '\0')
 					errx(1, "ccachedir path name too long");
 				break;
+			case 't':
+				ccache_timeout = atoi(optarg);
+				break;
 			default:
 				usage(argv[0]);
 				break;
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 0f9f428..6dd57bf 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -65,6 +65,7 @@ extern char			keytabfile[PATH_MAX];
 extern char			*ccachesearch[];
 extern int			use_memcache;
 extern int			root_uses_machine_creds;
+extern int 			ccache_timeout;
 
 TAILQ_HEAD(clnt_list_head, clnt_info) clnt_list;
 
diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index 8fa4f4a..81ea68d 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -86,6 +86,11 @@ Increases the verbosity of the output (can be specified multiple times).
 .B -r
 If the rpcsec_gss library supports setting debug level,
 increases the verbosity of the output (can be specified multiple times).
+.TP
+.B -t timeout
+Timeout in seconds for kernel tickets cache. This is workaround in case you want to 
+change kerberos tickets and identities frequently. Default value is 
+0 seconds - no timeout.
 .SH SEE ALSO
 .BR rpc.svcgssd(8)
 .SH AUTHORS
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index be6f440..7202b64 100644
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
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
