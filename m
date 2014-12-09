Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51259 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752540AbaLIFk7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 00:40:59 -0500
Subject: [PATCH 02/19] nfs-utils: gssd - merge gssd_main_loop.c and gssd.c
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com
Date: Tue, 09 Dec 2014 06:40:50 +0100
Message-ID: <20141209054050.24756.77103.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Having all the main loop code in one file is important in preparation
for later patches which add inotify and libevent.

Signed-off-by: David Härdeman <david@hardeman.nu>
---
 utils/gssd/Makefile.am      |    1 
 utils/gssd/gssd.c           |  224 ++++++++++++++++++++++++++++++++++++-
 utils/gssd/gssd.h           |    4 -
 utils/gssd/gssd_main_loop.c |  262 -------------------------------------------
 4 files changed, 220 insertions(+), 271 deletions(-)
 delete mode 100644 utils/gssd/gssd_main_loop.c

diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
index 62a70af..0f0142b 100644
--- a/utils/gssd/Makefile.am
+++ b/utils/gssd/Makefile.am
@@ -36,7 +36,6 @@ COMMON_SRCS = \
 gssd_SOURCES = \
 	$(COMMON_SRCS) \
 	gssd.c \
-	gssd_main_loop.c \
 	gssd_proc.c \
 	krb5_util.c \
 	\
diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index dc84b3e..5e580e7 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -1,7 +1,7 @@
 /*
   gssd.c
 
-  Copyright (c) 2000 The Regents of the University of Michigan.
+  Copyright (c) 2000, 2004 The Regents of the University of Michigan.
   All rights reserved.
 
   Copyright (c) 2000 Dug Song <dugsong@UMICH.EDU>.
@@ -40,9 +40,15 @@
 #include <config.h>
 #endif	/* HAVE_CONFIG_H */
 
+#ifndef _GNU_SOURCE
+#define _GNU_SOURCE
+#endif
+
 #include <sys/param.h>
 #include <sys/socket.h>
+#include <sys/poll.h>
 #include <rpc/rpc.h>
+#include <netinet/in.h>
 
 #include <unistd.h>
 #include <err.h>
@@ -51,13 +57,17 @@
 #include <stdlib.h>
 #include <string.h>
 #include <signal.h>
+#include <memory.h>
+#include <fcntl.h>
+#include <dirent.h>
+
 #include "gssd.h"
 #include "err_util.h"
 #include "gss_util.h"
 #include "krb5_util.h"
 #include "nfslib.h"
 
-char pipefs_dir[PATH_MAX] = GSSD_PIPEFS_DIR;
+static char pipefs_dir[PATH_MAX] = GSSD_PIPEFS_DIR;
 char keytabfile[PATH_MAX] = GSSD_DEFAULT_KEYTAB_FILE;
 char ccachedir[PATH_MAX] = GSSD_DEFAULT_CRED_DIR ":" GSSD_USER_CRED_DIR;
 char *ccachesearch[GSSD_MAX_CCACHE_SEARCH + 1];
@@ -66,8 +76,213 @@ int  root_uses_machine_creds = 1;
 unsigned int  context_timeout = 0;
 unsigned int  rpc_timeout = 5;
 char *preferred_realm = NULL;
+extern struct pollfd *pollarray;
+extern unsigned long pollsize;
+
+#define POLL_MILLISECS	500
+
+static volatile int dir_changed = 1;
+
+static void dir_notify_handler(__attribute__((unused))int sig)
+{
+	dir_changed = 1;
+}
+
+static void
+scan_poll_results(int ret)
+{
+	int			i;
+	struct clnt_info	*clp;
+
+	for (clp = clnt_list.tqh_first; clp != NULL; clp = clp->list.tqe_next)
+	{
+		i = clp->gssd_poll_index;
+		if (i >= 0 && pollarray[i].revents) {
+			if (pollarray[i].revents & POLLHUP) {
+				clp->gssd_close_me = 1;
+				dir_changed = 1;
+			}
+			if (pollarray[i].revents & POLLIN)
+				handle_gssd_upcall(clp);
+			pollarray[clp->gssd_poll_index].revents = 0;
+			ret--;
+			if (!ret)
+				break;
+		}
+		i = clp->krb5_poll_index;
+		if (i >= 0 && pollarray[i].revents) {
+			if (pollarray[i].revents & POLLHUP) {
+				clp->krb5_close_me = 1;
+				dir_changed = 1;
+			}
+			if (pollarray[i].revents & POLLIN)
+				handle_krb5_upcall(clp);
+			pollarray[clp->krb5_poll_index].revents = 0;
+			ret--;
+			if (!ret)
+				break;
+		}
+	}
+}
+
+static int
+topdirs_add_entry(struct dirent *dent)
+{
+	struct topdirs_info *tdi;
+
+	tdi = calloc(sizeof(struct topdirs_info), 1);
+	if (tdi == NULL) {
+		printerr(0, "ERROR: Couldn't allocate struct topdirs_info\n");
+		return -1;
+	}
+	tdi->dirname = malloc(PATH_MAX);
+	if (tdi->dirname == NULL) {
+		printerr(0, "ERROR: Couldn't allocate directory name\n");
+		free(tdi);
+		return -1;
+	}
+	snprintf(tdi->dirname, PATH_MAX, "%s/%s", pipefs_dir, dent->d_name);
+	tdi->fd = open(tdi->dirname, O_RDONLY);
+	if (tdi->fd == -1) {
+		printerr(0, "ERROR: failed to open %s\n", tdi->dirname);
+		free(tdi);
+		return -1;
+	}
+	fcntl(tdi->fd, F_SETSIG, DNOTIFY_SIGNAL);
+	fcntl(tdi->fd, F_NOTIFY, DN_CREATE|DN_DELETE|DN_MODIFY|DN_MULTISHOT);
+
+	TAILQ_INSERT_HEAD(&topdirs_list, tdi, list);
+	return 0;
+}
+
+static void
+topdirs_free_list(void)
+{
+	struct topdirs_info *tdi;
+
+	TAILQ_FOREACH(tdi, &topdirs_list, list) {
+		free(tdi->dirname);
+		if (tdi->fd != -1)
+			close(tdi->fd);
+		TAILQ_REMOVE(&topdirs_list, tdi, list);
+		free(tdi);
+	}
+}
+
+static int
+topdirs_init_list(void)
+{
+	DIR		*pipedir;
+	struct dirent	*dent;
+	int		ret;
 
-void
+	TAILQ_INIT(&topdirs_list);
+
+	pipedir = opendir(pipefs_dir);
+	if (pipedir == NULL) {
+		printerr(0, "ERROR: could not open rpc_pipefs directory '%s': "
+			 "%s\n", pipefs_dir, strerror(errno));
+		return -1;
+	}
+	for (dent = readdir(pipedir); dent != NULL; dent = readdir(pipedir)) {
+		if (dent->d_type != DT_DIR ||
+		    strcmp(dent->d_name, ".") == 0  ||
+		    strcmp(dent->d_name, "..") == 0) {
+			continue;
+		}
+		ret = topdirs_add_entry(dent);
+		if (ret)
+			goto out_err;
+	}
+	if (TAILQ_EMPTY(&topdirs_list)) {
+		printerr(0, "ERROR: rpc_pipefs directory '%s' is empty!\n", pipefs_dir);
+		return -1;
+	}
+	closedir(pipedir);
+	return 0;
+out_err:
+	topdirs_free_list();
+	return -1;
+}
+
+#ifdef HAVE_PPOLL
+static void gssd_poll(struct pollfd *fds, unsigned long nfds)
+{
+	sigset_t emptyset;
+	int ret;
+
+	sigemptyset(&emptyset);
+	ret = ppoll(fds, nfds, NULL, &emptyset);
+	if (ret < 0) {
+		if (errno != EINTR)
+			printerr(0, "WARNING: error return from poll\n");
+	} else if (ret == 0) {
+		printerr(0, "WARNING: unexpected timeout\n");
+	} else {
+		scan_poll_results(ret);
+	}
+}
+#else	/* !HAVE_PPOLL */
+static void gssd_poll(struct pollfd *fds, unsigned long nfds)
+{
+	int ret;
+
+	/* race condition here: dir_changed could be set before we
+	 * enter the poll, and we'd never notice if it weren't for the
+	 * timeout. */
+	ret = poll(fds, nfds, POLL_MILLISECS);
+	if (ret < 0) {
+		if (errno != EINTR)
+			printerr(0, "WARNING: error return from poll\n");
+	} else if (ret == 0) {
+		/* timeout */
+	} else { /* ret > 0 */
+		scan_poll_results(ret);
+	}
+}
+#endif	/* !HAVE_PPOLL */
+
+static void
+gssd_run(void)
+{
+	struct sigaction	dn_act = {
+		.sa_handler = dir_notify_handler
+	};
+	sigset_t		set;
+
+	sigemptyset(&dn_act.sa_mask);
+	sigaction(DNOTIFY_SIGNAL, &dn_act, NULL);
+
+	/* just in case the signal is blocked... */
+	sigemptyset(&set);
+	sigaddset(&set, DNOTIFY_SIGNAL);
+	sigprocmask(SIG_UNBLOCK, &set, NULL);
+
+	if (topdirs_init_list() != 0) {
+		/* Error msg is already printed */
+		exit(1);
+	}
+	init_client_list();
+
+	printerr(1, "beginning poll\n");
+	while (1) {
+		while (dir_changed) {
+			dir_changed = 0;
+			if (update_client_list()) {
+				/* Error msg is already printed */
+				exit(1);
+			}
+
+			daemon_ready();
+		}
+		gssd_poll(pollarray, pollsize);
+	}
+	topdirs_free_list();
+
+	return;
+}
+
+static void
 sig_die(int signal)
 {
 	/* destroy krb5 machine creds */
@@ -77,7 +292,7 @@ sig_die(int signal)
 	exit(0);
 }
 
-void
+static void
 sig_hup(int signal)
 {
 	/* don't exit on SIGHUP */
@@ -215,3 +430,4 @@ main(int argc, char *argv[])
 	printerr(0, "gssd_run returned!\n");
 	abort();
 }
+
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 84479e8..e16b187 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -58,9 +58,6 @@
  */
 enum {AUTHTYPE_KRB5, AUTHTYPE_LIPKEY};
 
-
-
-extern char			pipefs_dir[PATH_MAX];
 extern char			keytabfile[PATH_MAX];
 extern char			*ccachesearch[];
 extern int			use_memcache;
@@ -102,7 +99,6 @@ void init_client_list(void);
 int update_client_list(void);
 void handle_krb5_upcall(struct clnt_info *clp);
 void handle_gssd_upcall(struct clnt_info *clp);
-void gssd_run(void);
 
 
 #endif /* _RPC_GSSD_H_ */
diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
deleted file mode 100644
index 9787883..0000000
--- a/utils/gssd/gssd_main_loop.c
+++ /dev/null
@@ -1,262 +0,0 @@
-/*
-  Copyright (c) 2004 The Regents of the University of Michigan.
-  All rights reserved.
-
-  Redistribution and use in source and binary forms, with or without
-  modification, are permitted provided that the following conditions
-  are met:
-
-  1. Redistributions of source code must retain the above copyright
-     notice, this list of conditions and the following disclaimer.
-  2. Redistributions in binary form must reproduce the above copyright
-     notice, this list of conditions and the following disclaimer in the
-     documentation and/or other materials provided with the distribution.
-  3. Neither the name of the University nor the names of its
-     contributors may be used to endorse or promote products derived
-     from this software without specific prior written permission.
-
-  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
-  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
-  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
-  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
-  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
-  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
-  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-*/
-
-#ifdef HAVE_CONFIG_H
-#include <config.h>
-#endif	/* HAVE_CONFIG_H */
-
-#ifndef _GNU_SOURCE
-#define _GNU_SOURCE
-#endif
-
-#include <sys/param.h>
-#include <sys/socket.h>
-#include <sys/poll.h>
-#include <netinet/in.h>
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <string.h>
-#include <memory.h>
-#include <errno.h>
-#include <fcntl.h>
-#include <signal.h>
-#include <unistd.h>
-#include <dirent.h>
-
-#include "gssd.h"
-#include "err_util.h"
-#include "nfslib.h"
-
-extern struct pollfd *pollarray;
-extern unsigned long pollsize;
-
-#define POLL_MILLISECS	500
-
-static volatile int dir_changed = 1;
-
-static void dir_notify_handler(__attribute__((unused))int sig)
-{
-	dir_changed = 1;
-}
-
-static void
-scan_poll_results(int ret)
-{
-	int			i;
-	struct clnt_info	*clp;
-
-	for (clp = clnt_list.tqh_first; clp != NULL; clp = clp->list.tqe_next)
-	{
-		i = clp->gssd_poll_index;
-		if (i >= 0 && pollarray[i].revents) {
-			if (pollarray[i].revents & POLLHUP) {
-				clp->gssd_close_me = 1;
-				dir_changed = 1;
-			}
-			if (pollarray[i].revents & POLLIN)
-				handle_gssd_upcall(clp);
-			pollarray[clp->gssd_poll_index].revents = 0;
-			ret--;
-			if (!ret)
-				break;
-		}
-		i = clp->krb5_poll_index;
-		if (i >= 0 && pollarray[i].revents) {
-			if (pollarray[i].revents & POLLHUP) {
-				clp->krb5_close_me = 1;
-				dir_changed = 1;
-			}
-			if (pollarray[i].revents & POLLIN)
-				handle_krb5_upcall(clp);
-			pollarray[clp->krb5_poll_index].revents = 0;
-			ret--;
-			if (!ret)
-				break;
-		}
-	}
-}
-
-static int
-topdirs_add_entry(struct dirent *dent)
-{
-	struct topdirs_info *tdi;
-
-	tdi = calloc(sizeof(struct topdirs_info), 1);
-	if (tdi == NULL) {
-		printerr(0, "ERROR: Couldn't allocate struct topdirs_info\n");
-		return -1;
-	}
-	tdi->dirname = malloc(PATH_MAX);
-	if (tdi->dirname == NULL) {
-		printerr(0, "ERROR: Couldn't allocate directory name\n");
-		free(tdi);
-		return -1;
-	}
-	snprintf(tdi->dirname, PATH_MAX, "%s/%s", pipefs_dir, dent->d_name);
-	tdi->fd = open(tdi->dirname, O_RDONLY);
-	if (tdi->fd == -1) {
-		printerr(0, "ERROR: failed to open %s\n", tdi->dirname);
-		free(tdi);
-		return -1;
-	}
-	fcntl(tdi->fd, F_SETSIG, DNOTIFY_SIGNAL);
-	fcntl(tdi->fd, F_NOTIFY, DN_CREATE|DN_DELETE|DN_MODIFY|DN_MULTISHOT);
-
-	TAILQ_INSERT_HEAD(&topdirs_list, tdi, list);
-	return 0;
-}
-
-static void
-topdirs_free_list(void)
-{
-	struct topdirs_info *tdi;
-
-	TAILQ_FOREACH(tdi, &topdirs_list, list) {
-		free(tdi->dirname);
-		if (tdi->fd != -1)
-			close(tdi->fd);
-		TAILQ_REMOVE(&topdirs_list, tdi, list);
-		free(tdi);
-	}
-}
-
-static int
-topdirs_init_list(void)
-{
-	DIR		*pipedir;
-	struct dirent	*dent;
-	int		ret;
-
-	TAILQ_INIT(&topdirs_list);
-
-	pipedir = opendir(pipefs_dir);
-	if (pipedir == NULL) {
-		printerr(0, "ERROR: could not open rpc_pipefs directory '%s': "
-			 "%s\n", pipefs_dir, strerror(errno));
-		return -1;
-	}
-	for (dent = readdir(pipedir); dent != NULL; dent = readdir(pipedir)) {
-		if (dent->d_type != DT_DIR ||
-		    strcmp(dent->d_name, ".") == 0  ||
-		    strcmp(dent->d_name, "..") == 0) {
-			continue;
-		}
-		ret = topdirs_add_entry(dent);
-		if (ret)
-			goto out_err;
-	}
-	if (TAILQ_EMPTY(&topdirs_list)) {
-		printerr(0, "ERROR: rpc_pipefs directory '%s' is empty!\n", pipefs_dir);
-		return -1;
-	}
-	closedir(pipedir);
-	return 0;
-out_err:
-	topdirs_free_list();
-	return -1;
-}
-
-#ifdef HAVE_PPOLL
-static void gssd_poll(struct pollfd *fds, unsigned long nfds)
-{
-	sigset_t emptyset;
-	int ret;
-
-	sigemptyset(&emptyset);
-	ret = ppoll(fds, nfds, NULL, &emptyset);
-	if (ret < 0) {
-		if (errno != EINTR)
-			printerr(0, "WARNING: error return from poll\n");
-	} else if (ret == 0) {
-		printerr(0, "WARNING: unexpected timeout\n");
-	} else {
-		scan_poll_results(ret);
-	}
-}
-#else	/* !HAVE_PPOLL */
-static void gssd_poll(struct pollfd *fds, unsigned long nfds)
-{
-	int ret;
-
-	/* race condition here: dir_changed could be set before we
-	 * enter the poll, and we'd never notice if it weren't for the
-	 * timeout. */
-	ret = poll(fds, nfds, POLL_MILLISECS);
-	if (ret < 0) {
-		if (errno != EINTR)
-			printerr(0, "WARNING: error return from poll\n");
-	} else if (ret == 0) {
-		/* timeout */
-	} else { /* ret > 0 */
-		scan_poll_results(ret);
-	}
-}
-#endif	/* !HAVE_PPOLL */
-
-void
-gssd_run()
-{
-	struct sigaction	dn_act = {
-		.sa_handler = dir_notify_handler
-	};
-	sigset_t		set;
-
-	sigemptyset(&dn_act.sa_mask);
-	sigaction(DNOTIFY_SIGNAL, &dn_act, NULL);
-
-	/* just in case the signal is blocked... */
-	sigemptyset(&set);
-	sigaddset(&set, DNOTIFY_SIGNAL);
-	sigprocmask(SIG_UNBLOCK, &set, NULL);
-
-	if (topdirs_init_list() != 0) {
-		/* Error msg is already printed */
-		exit(1);
-	}
-	init_client_list();
-
-	printerr(1, "beginning poll\n");
-	while (1) {
-		while (dir_changed) {
-			dir_changed = 0;
-			if (update_client_list()) {
-				/* Error msg is already printed */
-				exit(1);
-			}
-
-			daemon_ready();
-		}
-		gssd_poll(pollarray, pollsize);
-	}
-	topdirs_free_list();
-
-	return;
-}

