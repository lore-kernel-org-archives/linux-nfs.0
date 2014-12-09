Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51258 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750839AbaLIFkz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 00:40:55 -0500
Subject: [PATCH 01/19] nfs-utils: cleanup daemonization code
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com
Date: Tue, 09 Dec 2014 06:40:45 +0100
Message-ID: <20141209054045.24756.77428.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The daemonization init/ready functions have parameters that are never used,
require the caller to keep track of some pipefds that it has no interest in
and which might not be used in some scenarios. Cleanup both functions a bit.

The idea here is also that these two functions might be good points to insert
more systemd init code later (sd_notify()).

Also, statd had a private copy of the daemonization code for unknown
reasons...so make it use the generic version instead.

Signed-off-by: David Härdeman <david@hardeman.nu>
---
 support/include/nfslib.h    |    5 +-
 support/nfs/mydaemon.c      |   92 ++++++++++++++++++++++---------------------
 utils/gssd/gssd.c           |    4 --
 utils/gssd/gssd.h           |    1 
 utils/gssd/gssd_main_loop.c |    3 -
 utils/gssd/svcgssd.c        |    8 +---
 utils/idmapd/idmapd.c       |    6 +--
 utils/statd/statd.c         |   66 +++++--------------------------
 8 files changed, 67 insertions(+), 118 deletions(-)

diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index c5dc6f8..c9a13cb 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -17,6 +17,7 @@
 #include <sys/socket.h>
 #include <netinet/in.h>
 #include <stdio.h>
+#include <stdbool.h>
 #include <paths.h>
 #include <rpcsvc/nfs_prot.h>
 #include <nfs/nfs.h>
@@ -129,8 +130,8 @@ void			fendrmtabent(FILE *fp);
 void			frewindrmtabent(FILE *fp);
 
 /* mydaemon */
-void mydaemon(int nochdir, int noclose, int *pipefds);
-void release_parent(int *pipefds);
+void daemon_init(bool fg);
+void daemon_ready(void);
 
 /*
  * wildmat borrowed from INN
diff --git a/support/nfs/mydaemon.c b/support/nfs/mydaemon.c
index e885d60..3391eff 100644
--- a/support/nfs/mydaemon.c
+++ b/support/nfs/mydaemon.c
@@ -46,56 +46,61 @@
 #include <errno.h>
 #include <unistd.h>
 #include <stdio.h>
+#include <stdbool.h>
 #include <stdlib.h>
 #include <string.h>
 #include <xlog.h>
 
+#include "nfslib.h"
+
+static int pipefds[2] = { -1, -1};
+
 /**
- * mydaemon - daemonize, but have parent wait to exit
- * @nochdir:	skip chdir()'ing the child to / after forking if true
- * @noclose:	skip closing stdin/stdout/stderr if true
- * @pipefds:	pointer to 2 element array of pipefds
+ * daemon_init - initial daemon setup
+ * @fg:		whether to run in the foreground
  *
  * This function is like daemon(), but with our own special sauce to delay
  * the exit of the parent until the child is set up properly. A pipe is created
  * between parent and child. The parent process will wait to exit until the
- * child dies or writes a '1' on the pipe signaling that it started
- * successfully.
+ * child dies or writes an int on the pipe signaling its status.
  */
 void
-mydaemon(int nochdir, int noclose, int *pipefds)
+daemon_init(bool fg)
 {
 	int pid, status, tempfd;
 
+	if (fg)
+		return;
+
 	if (pipe(pipefds) < 0) {
 		xlog_err("mydaemon: pipe() failed: errno %d (%s)\n",
 			 errno, strerror(errno));
-		exit(1);
+		exit(EXIT_FAILURE);
 	}
-	if ((pid = fork ()) < 0) {
+
+	pid = fork();
+	if (pid < 0) {
 		xlog_err("mydaemon: fork() failed: errno %d (%s)\n",
 			 errno, strerror(errno));
-		exit(1);
+		exit(EXIT_FAILURE);
 	}
 
-	if (pid != 0) {
-		/*
-		 * Parent. Wait for status from child.
-		 */
+	if (pid > 0) {
+		/* Parent */
 		close(pipefds[1]);
-		if (read(pipefds[0], &status, 1) != 1)
-			exit(1);
-		exit (0);
+		if (read(pipefds[0], &status, sizeof(status)) != sizeof(status))
+			exit(EXIT_FAILURE);
+		exit(status);
 	}
-	/* Child.	*/
+
+	/* Child */
 	close(pipefds[0]);
 	setsid ();
-	if (nochdir == 0) {
-		if (chdir ("/") == -1) {
-			xlog_err("mydaemon: chdir() failed: errno %d (%s)\n",
-				 errno, strerror(errno));
-			exit(1);
-		}
+
+	if (chdir ("/")) {
+		xlog_err("mydaemon: chdir() failed: errno %d (%s)\n",
+			 errno, strerror(errno));
+		exit(EXIT_FAILURE);
 	}
 
 	while (pipefds[1] <= 2) {
@@ -103,41 +108,38 @@ mydaemon(int nochdir, int noclose, int *pipefds)
 		if (pipefds[1] < 0) {
 			xlog_err("mydaemon: dup() failed: errno %d (%s)\n",
 				 errno, strerror(errno));
-			exit(1);
+			exit(EXIT_FAILURE);
 		}
 	}
 
-	if (noclose == 0) {
-		tempfd = open("/dev/null", O_RDWR);
-		if (tempfd >= 0) {
-			dup2(tempfd, 0);
-			dup2(tempfd, 1);
-			dup2(tempfd, 2);
-			close(tempfd);
-		} else {
-			xlog_err("mydaemon: can't open /dev/null: errno %d "
-				 "(%s)\n", errno, strerror(errno));
-			exit(1);
-		}
+	tempfd = open("/dev/null", O_RDWR);
+	if (tempfd < 0) {
+		xlog_err("mydaemon: can't open /dev/null: errno %d "
+			 "(%s)\n", errno, strerror(errno));
+		exit(EXIT_FAILURE);
 	}
 
-	return;
+	dup2(tempfd, 0);
+	dup2(tempfd, 1);
+	dup2(tempfd, 2);
+	dup2(pipefds[1], 3);
+	pipefds[1] = 3;
+	closeall(4);
 }
 
 /**
- * release_parent - tell the parent that it can exit now
- * @pipefds:	pipefd array that was previously passed to mydaemon()
+ * daemon_ready - tell interested parties that the daemon is ready
  *
- * This function tells the parent process of mydaemon() that it's now clear
- * to exit(0).
+ * This function tells e.g. the parent process that the daemon is up
+ * and running.
  */
 void
-release_parent(int *pipefds)
+daemon_ready(void)
 {
-	int status;
+	int status = 0;
 
 	if (pipefds[1] > 0) {
-		if (write(pipefds[1], &status, 1) != 1) {
+		if (write(pipefds[1], &status, sizeof(status)) != sizeof(status)) {
 			xlog_err("WARN: writing to parent pipe failed: errno "
 				 "%d (%s)\n", errno, strerror(errno));
 		}
diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 6b8b863..dc84b3e 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -66,7 +66,6 @@ int  root_uses_machine_creds = 1;
 unsigned int  context_timeout = 0;
 unsigned int  rpc_timeout = 5;
 char *preferred_realm = NULL;
-int pipefds[2] = { -1, -1 };
 
 void
 sig_die(int signal)
@@ -206,8 +205,7 @@ main(int argc, char *argv[])
 	if (gssd_check_mechs() != 0)
 		errx(1, "Problem with gssapi library");
 
-	if (!fg)
-		mydaemon(0, 0, pipefds);
+	daemon_init(fg);
 
 	signal(SIGINT, sig_die);
 	signal(SIGTERM, sig_die);
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 48f4ad8..84479e8 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -68,7 +68,6 @@ extern int			root_uses_machine_creds;
 extern unsigned int 		context_timeout;
 extern unsigned int rpc_timeout;
 extern char			*preferred_realm;
-extern int			pipefds[2];
 
 TAILQ_HEAD(clnt_list_head, clnt_info) clnt_list;
 
diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
index 6946ab6..9787883 100644
--- a/utils/gssd/gssd_main_loop.c
+++ b/utils/gssd/gssd_main_loop.c
@@ -252,8 +252,7 @@ gssd_run()
 				exit(1);
 			}
 
-			/* release the parent after the initial dir scan */
-			release_parent(pipefds);
+			daemon_ready();
 		}
 		gssd_poll(pollarray, pollsize);
 	}
diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
index 0385725..f1b4347 100644
--- a/utils/gssd/svcgssd.c
+++ b/utils/gssd/svcgssd.c
@@ -62,8 +62,6 @@
 #include "gss_util.h"
 #include "err_util.h"
 
-static int pipefds[2] = { -1, -1 };
-
 void
 sig_die(int signal)
 {
@@ -157,8 +155,7 @@ main(int argc, char *argv[])
 		exit(1);
 	}
 
-	if (!fg)
-		mydaemon(0, 0, pipefds);
+	daemon_init(fg);
 
 	signal(SIGINT, sig_die);
 	signal(SIGTERM, sig_die);
@@ -187,8 +184,7 @@ main(int argc, char *argv[])
 		}
 	}
 
-	if (!fg)
-		release_parent(pipefds);
+	daemon_ready();
 
 	nfs4_init_name_mapping(NULL); /* XXX: should only do this once */
 	gssd_run();
diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index c02849b..aff89d1 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -164,7 +164,6 @@ static char pipefsdir[PATH_MAX];
 static char *nobodyuser, *nobodygroup;
 static uid_t nobodyuid;
 static gid_t nobodygid;
-static int pipefds[2] = { -1, -1 };
 
 /* Used by conffile.c in libnfs.a */
 char *conf_path;
@@ -302,8 +301,7 @@ main(int argc, char **argv)
 	if (nfs4_init_name_mapping(conf_path))
 		errx(1, "Unable to create name to user id mappings.");
 
-	if (!fg)
-		mydaemon(0, 0, pipefds);
+	daemon_init(fg);
 
 	event_init();
 
@@ -380,7 +378,7 @@ main(int argc, char **argv)
 	if (nfsdret != 0 && fd == 0)
 		xlog_err("main: Neither NFS client nor NFSd found");
 
-	release_parent(pipefds);
+	daemon_ready();
 
 	if (event_dispatch() < 0)
 		xlog_err("main: event_dispatch returns errno %d (%s)",
diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index 51a016e..60ce6d1 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -248,13 +248,12 @@ int main (int argc, char **argv)
 	int nlm_udp = 0, nlm_tcp = 0;
 	struct rlimit rlim;
 
-	int pipefds[2] = { -1, -1};
-	char status;
-
 	/* Default: daemon mode, no other options */
 	run_mode = 0;
-	xlog_stderr(0);
-	xlog_syslog(1);
+
+	/* Log to stderr if there's an error during startup */
+	xlog_stderr(1);
+	xlog_syslog(0);
 
 	/* Set the basename */
 	if ((name_p = strrchr(argv[0],'/')) != NULL) {
@@ -394,52 +393,17 @@ int main (int argc, char **argv)
 		simulator (--argc, ++argv);	/* simulator() does exit() */
 #endif
 
-	if (!(run_mode & MODE_NODAEMON)) {
-		int tempfd;
-
-		if (pipe(pipefds)<0) {
-			perror("statd: unable to create pipe");
-			exit(1);
-		}
-		if ((pid = fork ()) < 0) {
-			perror ("statd: Could not fork");
-			exit (1);
-		} else if (pid != 0) {
-			/* Parent.
-			 * Wait for status from child.
-			 */
-			close(pipefds[1]);
-			if (read(pipefds[0], &status, 1) != 1)
-				exit(1);
-			exit (0);
-		}
-		/* Child.	*/
-		close(pipefds[0]);
-		setsid ();
-
-		while (pipefds[1] <= 2) {
-			pipefds[1] = dup(pipefds[1]);
-			if (pipefds[1]<0) {
-				perror("statd: dup");
-				exit(1);
-			}
-		}
-		tempfd = open("/dev/null", O_RDWR);
-		dup2(tempfd, 0);
-		dup2(tempfd, 1);
-		dup2(tempfd, 2);
-		dup2(pipefds[1], 3);
-		pipefds[1] = 3;
-		closeall(4);
-	}
-
-	/* Child. */
+	daemon_init(!(run_mode & MODE_NODAEMON));
 
 	if (run_mode & MODE_LOG_STDERR) {
 		xlog_syslog(0);
 		xlog_stderr(1);
 		xlog_config(D_ALL, 1);
+	} else {
+		xlog_syslog(1);
+		xlog_stderr(0);
 	}
+
 	xlog_open(name_p);
 	xlog(L_NOTICE, "Version " VERSION " starting");
 
@@ -512,16 +476,8 @@ int main (int argc, char **argv)
 	}
 	atexit(statd_unregister);
 
-	/* If we got this far, we have successfully started, so notify parent */
-	if (pipefds[1] > 0) {
-		status = 0;
-		if (write(pipefds[1], &status, 1) != 1) {
-			xlog_warn("writing to parent pipe failed: errno %d (%s)\n",
-				errno, strerror(errno));
-		}
-		close(pipefds[1]);
-		pipefds[1] = -1;
-	}
+	/* If we got this far, we have successfully started */
+	daemon_ready();
 
 	for (;;) {
 		/*

