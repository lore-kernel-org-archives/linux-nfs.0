Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51273 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756831AbaLIFla (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 00:41:30 -0500
Subject: [PATCH 08/19] nfs-utils: gssd - use libevent
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com
Date: Tue, 09 Dec 2014 06:41:20 +0100
Message-ID: <20141209054120.24756.30143.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using libevent (which is already in use in idmap) saves about a hundred
lines of hand-rolled event loop code.

Signed-off-by: David Härdeman <david@hardeman.nu>
---
 utils/gssd/Makefile.am |   23 +++-
 utils/gssd/gssd.c      |  309 ++++++++++++++----------------------------------
 utils/gssd/gssd.h      |   15 +-
 3 files changed, 116 insertions(+), 231 deletions(-)

diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
index 0f0142b..cb040b3 100644
--- a/utils/gssd/Makefile.am
+++ b/utils/gssd/Makefile.am
@@ -43,12 +43,23 @@ gssd_SOURCES = \
 	krb5_util.h \
 	write_bytes.h
 
-gssd_LDADD =	../../support/nfs/libnfs.a \
-		$(RPCSECGSS_LIBS) $(KRBLIBS) $(GSSAPI_LIBS) $(LIBTIRPC)
-gssd_LDFLAGS = $(KRBLDFLAGS)
-
-gssd_CFLAGS = $(AM_CFLAGS) $(CFLAGS) \
-	      $(RPCSECGSS_CFLAGS) $(KRBCFLAGS) $(GSSAPI_CFLAGS)
+gssd_LDADD = \
+	../../support/nfs/libnfs.a \
+	$(LIBEVENT) \
+	$(RPCSECGSS_LIBS) \
+	$(KRBLIBS) \
+	$(GSSAPI_LIBS) \
+	$(LIBTIRPC)
+
+gssd_LDFLAGS = \
+	$(KRBLDFLAGS)
+
+gssd_CFLAGS = \
+	$(AM_CFLAGS) \
+	$(CFLAGS) \
+	$(RPCSECGSS_CFLAGS) \
+	$(KRBCFLAGS) \
+	$(GSSAPI_CFLAGS)
 
 svcgssd_SOURCES = \
 	$(COMMON_SRCS) \
diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 7fa27c8..632d1a1 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -64,6 +64,7 @@
 #include <fcntl.h>
 #include <dirent.h>
 #include <netdb.h>
+#include <event.h>
 
 #include "gssd.h"
 #include "err_util.h"
@@ -80,8 +81,6 @@ unsigned int  context_timeout = 0;
 unsigned int  rpc_timeout = 5;
 char *preferred_realm = NULL;
 
-#define POLL_MILLISECS	500
-
 TAILQ_HEAD(clnt_list_head, clnt_info) clnt_list;
 
 TAILQ_HEAD(topdirs_list_head, topdirs_info) topdirs_list;
@@ -92,22 +91,9 @@ struct topdirs_info {
 	char				dirname[];
 };
 
-static volatile int dir_changed = 1;
-
-static void dir_notify_handler(__attribute__((unused))int sig)
-{
-	dir_changed = 1;
-}
-
-
 /*
- * pollarray:
- *      array of struct pollfd suitable to pass to poll. initialized to
- *      zero - a zero struct is ignored by poll() because the events mask is 0.
- *
  * clnt_list:
- *      linked list of struct clnt_info which associates a clntXXX directory
- *	with an index into pollarray[], and other basic data about that client.
+ *      linked list of struct clnt_info with basic data about a clntXXX dir.
  *
  * Directory structure: created by the kernel
  *      {rpc_pipefs}/{dir}/clntXX         : one per rpc_clnt struct in the kernel
@@ -127,10 +113,6 @@ static void dir_notify_handler(__attribute__((unused))int sig)
  *      and rescan the whole {rpc_pipefs} when this happens.
  */
 
-static struct pollfd * pollarray;
-
-static unsigned long pollsize;  /* the size of pollaray (in pollfd's) */
-
 /* Avoid DNS reverse lookups on server names */
 static int avoid_dns = 1;
 
@@ -335,15 +317,19 @@ fail:
 static void
 destroy_client(struct clnt_info *clp)
 {
-	if (clp->krb5_poll_index != -1)
-		memset(&pollarray[clp->krb5_poll_index], 0,
-					sizeof(struct pollfd));
-	if (clp->gssd_poll_index != -1)
-		memset(&pollarray[clp->gssd_poll_index], 0,
-					sizeof(struct pollfd));
-	if (clp->dir_fd != -1) close(clp->dir_fd);
-	if (clp->krb5_fd != -1) close(clp->krb5_fd);
-	if (clp->gssd_fd != -1) close(clp->gssd_fd);
+	if (clp->krb5_fd >= 0) {
+		close(clp->krb5_fd);
+		event_del(&clp->krb5_ev);
+	}
+
+	if (clp->gssd_fd >= 0) {
+		close(clp->gssd_fd);
+		event_del(&clp->gssd_ev);
+	}
+
+	if (clp->dir_fd >= 0)
+		close(clp->dir_fd);
+
 	free(clp->dirname);
 	free(clp->pdir);
 	free(clp->servicename);
@@ -362,8 +348,7 @@ insert_new_clnt(void)
 			 strerror(errno));
 		goto out;
 	}
-	clp->krb5_poll_index = -1;
-	clp->gssd_poll_index = -1;
+
 	clp->krb5_fd = -1;
 	clp->gssd_fd = -1;
 	clp->dir_fd = -1;
@@ -373,23 +358,34 @@ out:
 	return clp;
 }
 
-static int
-get_poll_index(int *ind)
+static void gssd_update_clients(void);
+
+static void
+gssd_clnt_gssd_cb(int UNUSED(fd), short which, void *data)
 {
-	unsigned int i;
+	struct clnt_info *clp = data;
 
-	*ind = -1;
-	for (i=0; i<pollsize; i++) {
-		if (pollarray[i].events == 0) {
-			*ind = i;
-			break;
-		}
+	if (which != EV_READ) {
+		clp->gssd_close_me = true;
+		gssd_update_clients();
+		return;
 	}
-	if (*ind == -1) {
-		printerr(0, "ERROR: No pollarray slots open\n");
-		return -1;
+
+	handle_gssd_upcall(clp);
+}
+
+static void
+gssd_clnt_krb5_cb(int UNUSED(fd), short which, void *data)
+{
+	struct clnt_info *clp = data;
+
+	if (which != EV_READ) {
+		clp->krb5_close_me = true;
+		gssd_update_clients();
+		return;
 	}
-	return 0;
+
+	handle_krb5_upcall(clp);
 }
 
 static int
@@ -397,30 +393,33 @@ process_clnt_dir_files(struct clnt_info * clp)
 {
 	char	name[PATH_MAX];
 	char	gname[PATH_MAX];
+	bool gssd_was_closed;
+	bool krb5_was_closed;
 
 	if (clp->gssd_close_me) {
 		printerr(2, "Closing 'gssd' pipe for %s\n", clp->dirname);
 		close(clp->gssd_fd);
-		memset(&pollarray[clp->gssd_poll_index], 0,
-			sizeof(struct pollfd));
+		event_del(&clp->gssd_ev);
 		clp->gssd_fd = -1;
-		clp->gssd_poll_index = -1;
-		clp->gssd_close_me = 0;
+		clp->gssd_close_me = false;
 	}
+
 	if (clp->krb5_close_me) {
 		printerr(2, "Closing 'krb5' pipe for %s\n", clp->dirname);
 		close(clp->krb5_fd);
-		memset(&pollarray[clp->krb5_poll_index], 0,
-			sizeof(struct pollfd));
+		event_del(&clp->krb5_ev);
 		clp->krb5_fd = -1;
-		clp->krb5_poll_index = -1;
-		clp->krb5_close_me = 0;
+		clp->krb5_close_me = false;
 	}
 
+	gssd_was_closed = clp->gssd_fd < 0 ? true : false;
+	krb5_was_closed = clp->krb5_fd < 0 ? true : false;
+
 	if (clp->gssd_fd == -1) {
 		snprintf(gname, sizeof(gname), "%s/gssd", clp->dirname);
 		clp->gssd_fd = open(gname, O_RDWR);
 	}
+
 	if (clp->gssd_fd == -1) {
 		if (clp->krb5_fd == -1) {
 			snprintf(name, sizeof(name), "%s/krb5", clp->dirname);
@@ -441,6 +440,18 @@ process_clnt_dir_files(struct clnt_info * clp)
 		}
 	}
 
+	if (gssd_was_closed && clp->gssd_fd >= 0) {
+		event_set(&clp->gssd_ev, clp->gssd_fd, EV_READ | EV_PERSIST,
+			  gssd_clnt_gssd_cb, clp);
+		event_add(&clp->gssd_ev, NULL);
+	}
+
+	if (krb5_was_closed && clp->krb5_fd >= 0) {
+		event_set(&clp->krb5_ev, clp->krb5_fd, EV_READ | EV_PERSIST,
+			  gssd_clnt_krb5_cb, clp);
+		event_add(&clp->krb5_ev, NULL);
+	}
+
 	if ((clp->krb5_fd == -1) && (clp->gssd_fd == -1))
 		/* not fatal, files might appear later */
 		return 0;
@@ -454,24 +465,6 @@ process_clnt_dir_files(struct clnt_info * clp)
 				  &clp->protocol, (struct sockaddr *) &clp->addr);
 	}
 
-	if ((clp->gssd_fd != -1) && (clp->gssd_poll_index == -1)) {
-		if (get_poll_index(&clp->gssd_poll_index)) {
-			printerr(0, "ERROR: Too many gssd clients\n");
-			return -1;
-		}
-		pollarray[clp->gssd_poll_index].fd = clp->gssd_fd;
-		pollarray[clp->gssd_poll_index].events |= POLLIN;
-	}
-
-	if ((clp->krb5_fd != -1) && (clp->krb5_poll_index == -1)) {
-		if (get_poll_index(&clp->krb5_poll_index)) {
-			printerr(0, "ERROR: Too many krb5 clients\n");
-			return -1;
-		}
-		pollarray[clp->krb5_poll_index].fd = clp->krb5_fd;
-		pollarray[clp->krb5_poll_index].events |= POLLIN;
-	}
-
 	return 0;
 }
 
@@ -600,10 +593,10 @@ process_pipedir(char *pipe_name)
 }
 
 /* Used to read (and re-read) list of clients, set up poll array. */
-static int
-update_client_list(void)
+static void
+gssd_update_clients(void)
 {
-	int retval = -1;
+	int retval;
 	struct topdirs_info *tdi;
 
 	TAILQ_FOREACH(tdi, &topdirs_list, list) {
@@ -613,44 +606,12 @@ update_client_list(void)
 				 tdi->dirname);
 
 	}
-	return retval;
 }
 
 static void
-scan_poll_results(int ret)
+gssd_update_clients_cb(int UNUSED(ifd), short UNUSED(which), void *UNUSED(data))
 {
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
+	gssd_update_clients();
 }
 
 static int
@@ -715,115 +676,11 @@ topdirs_init_list(void)
 	closedir(pipedir);
 }
 
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
-
-#define FD_ALLOC_BLOCK		256
-static void
-init_client_list(void)
-{
-	struct rlimit rlim;
-
-	TAILQ_INIT(&clnt_list);
-
-	/* Eventually plan to grow/shrink poll array: */
-	if (!getrlimit(RLIMIT_NOFILE, &rlim) && rlim.rlim_cur != RLIM_INFINITY)
-		pollsize = rlim.rlim_cur;
-	else
-		pollsize = FD_ALLOC_BLOCK;
-
-	pollarray = calloc(pollsize, sizeof(struct pollfd));
-	if (!pollarray) {
-		printerr(1, "ERROR: calloc failed\n");
-		exit(EXIT_FAILURE);
-	}
-}
-
 static void
-gssd_run(void)
+gssd_atexit(void)
 {
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
-	topdirs_init_list();
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
-}
-
-static void
-sig_die(int signal)
-{
-	/* destroy krb5 machine creds */
 	if (root_uses_machine_creds)
 		gssd_destroy_krb5_machine_creds();
-	printerr(1, "exiting on signal %d\n", signal);
-	exit(0);
-}
-
-static void
-sig_hup(int signal)
-{
-	/* don't exit on SIGHUP */
-	printerr(1, "Received SIGHUP(%d)... Ignoring.\n", signal);
-	return;
 }
 
 static void
@@ -845,6 +702,8 @@ main(int argc, char *argv[])
 	extern char *optarg;
 	char *progname;
 	char *ccachedir = NULL;
+	struct event sighup_ev;
+	struct event sigdnotify_ev;
 
 	while ((opt = getopt(argc, argv, "DfvrlmnMp:k:d:t:T:R:")) != -1) {
 		switch (opt) {
@@ -968,17 +827,31 @@ main(int argc, char *argv[])
 
 	daemon_init(fg);
 
+	event_init();
+
 	if (chdir(pipefs_dir)) {
 		printerr(1, "ERROR: chdir(%s) failed: %s\n", pipefs_dir, strerror(errno));
 		exit(EXIT_FAILURE);
 	}
 
-	signal(SIGINT, sig_die);
-	signal(SIGTERM, sig_die);
-	signal(SIGHUP, sig_hup);
+	if (atexit(gssd_atexit)) {
+		printerr(1, "ERROR: atexit failed: %s\n", strerror(errno));
+		exit(EXIT_FAILURE);
+	}
+
+	signal_set(&sighup_ev, SIGHUP, gssd_update_clients_cb, NULL);
+	signal_add(&sighup_ev, NULL);
+	signal_set(&sigdnotify_ev, DNOTIFY_SIGNAL, gssd_update_clients_cb, NULL);
+	signal_add(&sigdnotify_ev, NULL);
+
+	topdirs_init_list();
+	TAILQ_INIT(&clnt_list);
+	gssd_update_clients();
+	daemon_ready();
+
+	event_dispatch();
 
-	gssd_run();
-	printerr(0, "gssd_run returned!\n");
-	abort();
+	printerr(1, "ERROR: event_dispatch() returned!\n");
+	return EXIT_FAILURE;
 }
 
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 72e68d9..2417579 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -34,6 +34,8 @@
 #include <sys/types.h>
 #include <sys/queue.h>
 #include <gssapi/gssapi.h>
+#include <event.h>
+#include <stdbool.h>
 
 #ifndef GSSD_PIPEFS_DIR
 #define GSSD_PIPEFS_DIR		"/var/lib/nfs/rpc_pipefs"
@@ -71,15 +73,14 @@ struct clnt_info {
 	int			vers;
 	char			*protocol;
 	int			krb5_fd;
-	int			krb5_poll_index;
-	int			krb5_close_me;
-	int                     gssd_fd;
-	int                     gssd_poll_index;
-	int			gssd_close_me;
-	struct sockaddr_storage addr;
+	struct event		krb5_ev;
+	bool			krb5_close_me;
+	int			gssd_fd;
+	struct event		gssd_ev;
+	bool			gssd_close_me;
+	struct			sockaddr_storage addr;
 };
 
-
 void handle_krb5_upcall(struct clnt_info *clp);
 void handle_gssd_upcall(struct clnt_info *clp);
 

