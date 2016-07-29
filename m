Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35073 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750962AbcG2FEs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2016 01:04:48 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Fri, 29 Jul 2016 15:03:36 +1000
Subject: [PATCH 2/7] mountd: remove the --exports-file option
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-ID: <146976861654.20186.7932993398701298729.stgit@noble>
In-Reply-To: <146976807524.20186.8871903418718212567.stgit@noble>
References: <146976807524.20186.8871903418718212567.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is completely ineffective.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/mountd/auth.c     |    5 +----
 utils/mountd/mountd.c   |   11 +++--------
 utils/mountd/mountd.h   |    2 +-
 utils/mountd/mountd.man |    8 --------
 4 files changed, 5 insertions(+), 21 deletions(-)

diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index 894a7a53957f..0881d9a6edba 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -36,7 +36,6 @@ enum auth_error
 };
 
 static void		auth_fixpath(char *path);
-static char	*export_file = NULL;
 static nfs_export my_exp;
 static nfs_client my_client;
 
@@ -44,10 +43,8 @@ extern int new_cache;
 extern int use_ipaddr;
 
 void
-auth_init(char *exports)
+auth_init(void)
 {
-
-	export_file = exports;
 	auth_reload();
 	xtab_mount_write();
 }
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 063da269f895..7a51b093f66a 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -57,7 +57,6 @@ static struct option longopts[] =
 	{ "descriptors", 1, 0, 'o' },
 	{ "debug", 1, 0, 'd' },
 	{ "help", 0, 0, 'h' },
-	{ "exports-file", 1, 0, 'f' },
 	{ "nfs-version", 1, 0, 'V' },
 	{ "no-nfs-version", 1, 0, 'N' },
 	{ "version", 0, 0, 'v' },
@@ -689,7 +688,6 @@ get_exportlist(void)
 int
 main(int argc, char **argv)
 {
-	char	*export_file = _PATH_EXPORTS;
 	char    *state_dir = NFS_STATEDIR;
 	char	*progname;
 	unsigned int listeners = 0;
@@ -709,7 +707,7 @@ main(int argc, char **argv)
 
 	/* Parse the command line options and arguments. */
 	opterr = 0;
-	while ((c = getopt_long(argc, argv, "o:nFd:f:p:P:hH:N:V:vurs:t:g", longopts, NULL)) != EOF)
+	while ((c = getopt_long(argc, argv, "o:nFd:p:P:hH:N:V:vurs:t:g", longopts, NULL)) != EOF)
 		switch (c) {
 		case 'g':
 			manage_gids = 1;
@@ -728,9 +726,6 @@ main(int argc, char **argv)
 		case 'd':
 			xlog_sconfig(optarg, 1);
 			break;
-		case 'f':
-			export_file = optarg;
-			break;
 		case 'H': /* PRC: specify a high-availability callout program */
 			ha_callout_prog = optarg;
 			break;
@@ -862,7 +857,7 @@ main(int argc, char **argv)
 	sa.sa_handler = sig_hup;
 	sigaction(SIGHUP, &sa, NULL);
 
-	auth_init(export_file);
+	auth_init();
 
 	if (!foreground) {
 		/* We first fork off a child. */
@@ -908,7 +903,7 @@ usage(const char *prog, int n)
 {
 	fprintf(stderr,
 "Usage: %s [-F|--foreground] [-h|--help] [-v|--version] [-d kind|--debug kind]\n"
-"	[-o num|--descriptors num] [-f exports-file|--exports-file=file]\n"
+"	[-o num|--descriptors num]\n"
 "	[-p|--port port] [-V version|--nfs-version version]\n"
 "	[-N version|--no-nfs-version version] [-n|--no-tcp]\n"
 "	[-H prog |--ha-callout prog] [-r |--reverse-lookup]\n"
diff --git a/utils/mountd/mountd.h b/utils/mountd/mountd.h
index 6d358a75d9f3..f058f01d3584 100644
--- a/utils/mountd/mountd.h
+++ b/utils/mountd/mountd.h
@@ -39,7 +39,7 @@ bool_t		mount_pathconf_2_svc(struct svc_req *, dirpath *, ppathcnf *);
 bool_t		mount_mnt_3_svc(struct svc_req *, dirpath *, mountres3 *);
 
 void		mount_dispatch(struct svc_req *, SVCXPRT *);
-void		auth_init(char *export_file);
+void		auth_init(void);
 unsigned int	auth_reload(void);
 nfs_export *	auth_authenticate(const char *what,
 					const struct sockaddr *caller,
diff --git a/utils/mountd/mountd.man b/utils/mountd/mountd.man
index 66e3bba7e865..e0d1a0acba3a 100644
--- a/utils/mountd/mountd.man
+++ b/utils/mountd/mountd.man
@@ -86,14 +86,6 @@ Turn on debugging. Valid kinds are: all, auth, call, general and parse.
 .B \-F " or " \-\-foreground
 Run in foreground (do not daemonize)
 .TP
-.B \-f export-file " or " \-\-exports-file export-file
-This option specifies the exports file, listing the clients that this
-server is prepared to serve and parameters to apply to each
-such mount (see
-.BR exports (5)).
-By default, export information is read from
-.IR /etc/exports .
-.TP
 .B \-h " or " \-\-help
 Display usage message.
 .TP


