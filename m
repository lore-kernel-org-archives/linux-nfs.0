Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f52.google.com ([209.85.128.52]:64505 "EHLO
	mail-qe0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753118Ab3KOTPi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 14:15:38 -0500
Received: by mail-qe0-f52.google.com with SMTP id cz11so2002385qeb.25
        for <linux-nfs@vger.kernel.org>; Fri, 15 Nov 2013 11:15:38 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] nfs-utils: consolidate mydaemon() and release_parent() implementations
Date: Fri, 15 Nov 2013 14:15:30 -0500
Message-Id: <1384542931-18753-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1384542931-18753-1-git-send-email-jlayton@redhat.com>
References: <1384542931-18753-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We currently have 2 cut-and-paste versions of this code. One for idmapd
and one for svcgssd.[1]

The two are basically equivalent but there are some small differences,
mostly related to how errors in that function are logged. svcgssd uses
printerr() with a priority of 1, which only prints errors if -v was
specified. That doesn't seem to be quite right. Daemonizing errors are
necessarily fatal and should be logged as such. The one for idmapd uses
err(), which always prints to stderr even though we have the xlog
facility set up. Since both have xlog configured at this point, log the
errors using xlog_err() instead.

The only other significant difference I see is that the idmapd version
will open "/" if it's unable to open "/dev/null". I believe that however
was a holdover from an earlier version of that function that did not
error out when we were unable to open a file descriptor. Since the
function does that now, I don't believe we need that fallback anymore.

[1]: technically, we have a third in statd too, but it's different
     enough that I don't want to touch it here.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 support/include/nfslib.h |   4 ++
 support/nfs/Makefile.am  |   2 +-
 support/nfs/mydaemon.c   | 148 +++++++++++++++++++++++++++++++++++++++++++++++
 utils/gssd/svcgssd.c     |  90 +---------------------------
 utils/idmapd/idmapd.c    |  82 +-------------------------
 5 files changed, 159 insertions(+), 167 deletions(-)
 create mode 100644 support/nfs/mydaemon.c

diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index f210a06..ce4b14b 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -128,6 +128,10 @@ void			fputrmtabent(FILE *fp, struct rmtabent *xep, long *pos);
 void			fendrmtabent(FILE *fp);
 void			frewindrmtabent(FILE *fp);
 
+/* mydaemon */
+void mydaemon(int nochdir, int noclose, int *pipefds);
+void release_parent(int *pipefds);
+
 /*
  * wildmat borrowed from INN
  */
diff --git a/support/nfs/Makefile.am b/support/nfs/Makefile.am
index 05c2fc4..fb9b8c1 100644
--- a/support/nfs/Makefile.am
+++ b/support/nfs/Makefile.am
@@ -2,7 +2,7 @@
 
 noinst_LIBRARIES = libnfs.a
 libnfs_a_SOURCES = exports.c rmtab.c xio.c rpcmisc.c rpcdispatch.c \
-		   xlog.c xcommon.c wildmat.c nfsclient.c \
+		   xlog.c xcommon.c wildmat.c mydaemon.c nfsclient.c \
 		   nfsexport.c getfh.c nfsctl.c rpc_socket.c getport.c \
 		   svc_socket.c cacheio.c closeall.c nfs_mntent.c conffile.c \
 		   svc_create.c atomicio.c strlcpy.c strlcat.c
diff --git a/support/nfs/mydaemon.c b/support/nfs/mydaemon.c
new file mode 100644
index 0000000..e885d60
--- /dev/null
+++ b/support/nfs/mydaemon.c
@@ -0,0 +1,148 @@
+/*
+  mydaemon.c
+
+  Copyright (c) 2000 The Regents of the University of Michigan.
+  All rights reserved.
+
+  Copyright (c) 2000 Dug Song <dugsong@UMICH.EDU>.
+  Copyright (c) 2002 Andy Adamson <andros@UMICH.EDU>.
+  Copyright (c) 2002 Marius Aamodt Eriksen <marius@UMICH.EDU>.
+  Copyright (c) 2002 J. Bruce Fields <bfields@UMICH.EDU>.
+  Copyright (c) 2013 Jeff Layton <jlayton@redhat.com>
+
+  All rights reserved, all wrongs reversed.
+
+  Redistribution and use in source and binary forms, with or without
+  modification, are permitted provided that the following conditions
+  are met:
+
+  1. Redistributions of source code must retain the above copyright
+     notice, this list of conditions and the following disclaimer.
+  2. Redistributions in binary form must reproduce the above copyright
+     notice, this list of conditions and the following disclaimer in the
+     documentation and/or other materials provided with the distribution.
+  3. Neither the name of the University nor the names of its
+     contributors may be used to endorse or promote products derived
+     from this software without specific prior written permission.
+
+  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+
+*/
+
+#include <sys/param.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <errno.h>
+#include <unistd.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <xlog.h>
+
+/**
+ * mydaemon - daemonize, but have parent wait to exit
+ * @nochdir:	skip chdir()'ing the child to / after forking if true
+ * @noclose:	skip closing stdin/stdout/stderr if true
+ * @pipefds:	pointer to 2 element array of pipefds
+ *
+ * This function is like daemon(), but with our own special sauce to delay
+ * the exit of the parent until the child is set up properly. A pipe is created
+ * between parent and child. The parent process will wait to exit until the
+ * child dies or writes a '1' on the pipe signaling that it started
+ * successfully.
+ */
+void
+mydaemon(int nochdir, int noclose, int *pipefds)
+{
+	int pid, status, tempfd;
+
+	if (pipe(pipefds) < 0) {
+		xlog_err("mydaemon: pipe() failed: errno %d (%s)\n",
+			 errno, strerror(errno));
+		exit(1);
+	}
+	if ((pid = fork ()) < 0) {
+		xlog_err("mydaemon: fork() failed: errno %d (%s)\n",
+			 errno, strerror(errno));
+		exit(1);
+	}
+
+	if (pid != 0) {
+		/*
+		 * Parent. Wait for status from child.
+		 */
+		close(pipefds[1]);
+		if (read(pipefds[0], &status, 1) != 1)
+			exit(1);
+		exit (0);
+	}
+	/* Child.	*/
+	close(pipefds[0]);
+	setsid ();
+	if (nochdir == 0) {
+		if (chdir ("/") == -1) {
+			xlog_err("mydaemon: chdir() failed: errno %d (%s)\n",
+				 errno, strerror(errno));
+			exit(1);
+		}
+	}
+
+	while (pipefds[1] <= 2) {
+		pipefds[1] = dup(pipefds[1]);
+		if (pipefds[1] < 0) {
+			xlog_err("mydaemon: dup() failed: errno %d (%s)\n",
+				 errno, strerror(errno));
+			exit(1);
+		}
+	}
+
+	if (noclose == 0) {
+		tempfd = open("/dev/null", O_RDWR);
+		if (tempfd >= 0) {
+			dup2(tempfd, 0);
+			dup2(tempfd, 1);
+			dup2(tempfd, 2);
+			close(tempfd);
+		} else {
+			xlog_err("mydaemon: can't open /dev/null: errno %d "
+				 "(%s)\n", errno, strerror(errno));
+			exit(1);
+		}
+	}
+
+	return;
+}
+
+/**
+ * release_parent - tell the parent that it can exit now
+ * @pipefds:	pipefd array that was previously passed to mydaemon()
+ *
+ * This function tells the parent process of mydaemon() that it's now clear
+ * to exit(0).
+ */
+void
+release_parent(int *pipefds)
+{
+	int status;
+
+	if (pipefds[1] > 0) {
+		if (write(pipefds[1], &status, 1) != 1) {
+			xlog_err("WARN: writing to parent pipe failed: errno "
+				 "%d (%s)\n", errno, strerror(errno));
+		}
+		close(pipefds[1]);
+		pipefds[1] = -1;
+	}
+}
+
diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
index 8aee3b2..0385725 100644
--- a/utils/gssd/svcgssd.c
+++ b/utils/gssd/svcgssd.c
@@ -62,91 +62,7 @@
 #include "gss_util.h"
 #include "err_util.h"
 
-/*
- * mydaemon creates a pipe between the partent and child
- * process. The parent process will wait until the
- * child dies or writes a '1' on the pipe signaling
- * that it started successfully.
- */
-int pipefds[2] = { -1, -1};
-
-static void
-mydaemon(int nochdir, int noclose)
-{
-	int pid, status, tempfd;
-
-	if (pipe(pipefds) < 0) {
-		printerr(1, "mydaemon: pipe() failed: errno %d (%s)\n",
-			errno, strerror(errno));
-		exit(1);
-	}
-	if ((pid = fork ()) < 0) {
-		printerr(1, "mydaemon: fork() failed: errno %d (%s)\n",
-			errno, strerror(errno));
-		exit(1);
-	}
-
-	if (pid != 0) {
-		/*
-		 * Parent. Wait for status from child.
-		 */
-		close(pipefds[1]);
-		if (read(pipefds[0], &status, 1) != 1)
-			exit(1);
-		exit (0);
-	}
-	/* Child.	*/
-	close(pipefds[0]);
-	setsid ();
-	if (nochdir == 0) {
-		if (chdir ("/") == -1) {
-			printerr(1, "mydaemon: chdir() failed: errno %d (%s)\n",
-				errno, strerror(errno));
-			exit(1);
-		}
-	}
-
-	while (pipefds[1] <= 2) {
-		pipefds[1] = dup(pipefds[1]);
-		if (pipefds[1] < 0) {
-			printerr(1, "mydaemon: dup() failed: errno %d (%s)\n",
-				errno, strerror(errno));
-			exit(1);
-		}
-	}
-
-	if (noclose == 0) {
-		tempfd = open("/dev/null", O_RDWR);
-		if (tempfd >= 0) {
-			dup2(tempfd, 0);
-			dup2(tempfd, 1);
-			dup2(tempfd, 2);
-			close(tempfd);
-		} else {
-			printerr(1, "mydaemon: can't open /dev/null: errno %d "
-				    "(%s)\n", errno, strerror(errno));
-			exit(1);
-		}
-	}
-
-	return;
-}
-
-static void
-release_parent(void)
-{
-	int status;
-
-	if (pipefds[1] > 0) {
-		if (write(pipefds[1], &status, 1) != 1) {
-			printerr(1, 
-				"WARN: writing to parent pipe failed: errno %d (%s)\n",
-				errno, strerror(errno));
-		}
-		close(pipefds[1]);
-		pipefds[1] = -1;
-	}
-}
+static int pipefds[2] = { -1, -1 };
 
 void
 sig_die(int signal)
@@ -242,7 +158,7 @@ main(int argc, char *argv[])
 	}
 
 	if (!fg)
-		mydaemon(0, 0);
+		mydaemon(0, 0, pipefds);
 
 	signal(SIGINT, sig_die);
 	signal(SIGTERM, sig_die);
@@ -272,7 +188,7 @@ main(int argc, char *argv[])
 	}
 
 	if (!fg)
-		release_parent();
+		release_parent(pipefds);
 
 	nfs4_init_name_mapping(NULL); /* XXX: should only do this once */
 	gssd_run();
diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index b6c6231..c02849b 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -157,9 +157,6 @@ static int nfsdopenone(struct idmap_client *);
 static void nfsdreopen_one(struct idmap_client *);
 static void nfsdreopen(void);
 
-void    mydaemon(int, int);
-void    release_parent(void);
-
 static int verbose = 0;
 #define DEFAULT_IDMAP_CACHE_EXPIRY 600 /* seconds */
 static int cache_entry_expiration = 0;
@@ -167,6 +164,7 @@ static char pipefsdir[PATH_MAX];
 static char *nobodyuser, *nobodygroup;
 static uid_t nobodyuid;
 static gid_t nobodygid;
+static int pipefds[2] = { -1, -1 };
 
 /* Used by conffile.c in libnfs.a */
 char *conf_path;
@@ -305,7 +303,7 @@ main(int argc, char **argv)
 		errx(1, "Unable to create name to user id mappings.");
 
 	if (!fg)
-		mydaemon(0, 0);
+		mydaemon(0, 0, pipefds);
 
 	event_init();
 
@@ -382,7 +380,7 @@ main(int argc, char **argv)
 	if (nfsdret != 0 && fd == 0)
 		xlog_err("main: Neither NFS client nor NFSd found");
 
-	release_parent();
+	release_parent(pipefds);
 
 	if (event_dispatch() < 0)
 		xlog_err("main: event_dispatch returns errno %d (%s)",
@@ -929,77 +927,3 @@ getfield(char **bpp, char *fld, size_t fldsz)
 
 	return (0);
 }
-/*
- * mydaemon creates a pipe between the partent and child
- * process. The parent process will wait until the
- * child dies or writes a '1' on the pipe signaling
- * that it started successfully.
- */
-int pipefds[2] = { -1, -1};
-
-void
-mydaemon(int nochdir, int noclose)
-{
-	int pid, status, tempfd;
-
-	if (pipe(pipefds) < 0)
-		err(1, "mydaemon: pipe() failed: errno %d", errno);
-
-	if ((pid = fork ()) < 0)
-		err(1, "mydaemon: fork() failed: errno %d", errno);
-
-	if (pid != 0) {
-		/*
-		 * Parent. Wait for status from child.
-		 */
-		close(pipefds[1]);
-		if (read(pipefds[0], &status, 1) != 1)
-			exit(1);
-		exit (0);
-	}
-	/* Child.	*/
-	close(pipefds[0]);
-	setsid ();
-	if (nochdir == 0) {
-		if (chdir ("/") == -1)
-			err(1, "mydaemon: chdir() failed: errno %d", errno);
-	}
-
-	while (pipefds[1] <= 2) {
-		pipefds[1] = dup(pipefds[1]);
-		if (pipefds[1] < 0)
-			err(1, "mydaemon: dup() failed: errno %d", errno);
-	}
-
-	if (noclose == 0) {
-		tempfd = open("/dev/null", O_RDWR);
-		if (tempfd < 0)
-			tempfd = open("/", O_RDONLY);
-		if (tempfd >= 0) {
-			dup2(tempfd, 0);
-			dup2(tempfd, 1);
-			dup2(tempfd, 2);
-			close(tempfd);
-		} else {
-			err(1, "mydaemon: can't open /dev/null: errno %d",
-			       errno);
-			exit(1);
-		}
-	}
-
-	return;
-}
-void
-release_parent(void)
-{
-	int status;
-
-	if (pipefds[1] > 0) {
-		if (write(pipefds[1], &status, 1) != 1) {
-			err(1, "Writing to parent pipe failed: errno %d (%s)\n",
-				errno, strerror(errno));
-		}
-		close(pipefds[1]);
-		pipefds[1] = -1;
-	}
-}
-- 
1.8.3.1

