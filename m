From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/29] statd: Replace nsm_log() with xlog() in sm-notify
	command
Date: Tue, 10 Nov 2009 16:56:29 -0500
Message-ID: <20091110215629.23822.47441.stgit@matisse.1015granger.net>
References: <20091110215447.23822.15275.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:47716 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758377AbZKJV5P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2009 16:57:15 -0500
In-Reply-To: <20091110215447.23822.15275.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To facilitate code sharing between statd and sm-notify (and with other
components of nfs-utils), replace sm-notify's nsm_log() with xlog().

Since opt_quiet is used in only a handful of insignificant cases, it
is removed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/Makefile.am   |    3 +
 utils/statd/sm-notify.c   |  163 ++++++++++++++++++---------------------------
 utils/statd/sm-notify.man |    6 --
 3 files changed, 67 insertions(+), 105 deletions(-)

diff --git a/utils/statd/Makefile.am b/utils/statd/Makefile.am
index 19ba7b4..f64cd7a 100644
--- a/utils/statd/Makefile.am
+++ b/utils/statd/Makefile.am
@@ -24,7 +24,8 @@ statd_LDADD = ../../support/export/libexport.a \
 	      ../../support/nfs/libnfs.a \
 	      ../../support/misc/libmisc.a \
 	      $(LIBWRAP) $(LIBNSL)
-sm_notify_LDADD = $(LIBNSL)
+sm_notify_LDADD = ../../support/nfs/libnfs.a \
+		  $(LIBNSL)
 
 EXTRA_DIST = sim_sm_inter.x sm_inter.x $(man8_MANS) COPYRIGHT simulate.c
 
diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 72dcff4..1d4403a 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -28,6 +28,8 @@
 #include <errno.h>
 #include <grp.h>
 
+#include "xlog.h"
+
 #ifndef BASEDIR
 # ifdef NFS_STATEDIR
 #  define BASEDIR		NFS_STATEDIR
@@ -69,12 +71,10 @@ struct nsm_host {
 static char		nsm_hostname[256];
 static uint32_t		nsm_state;
 static int		opt_debug = 0;
-static int		opt_quiet = 0;
 static int		opt_update_state = 1;
 static unsigned int	opt_max_retry = 15 * 60;
 static char *		opt_srcaddr = 0;
 static uint16_t		opt_srcport = 0;
-static int		log_syslog = 0;
 
 static unsigned int	nsm_get_state(int);
 static void		notify(void);
@@ -84,7 +84,6 @@ static void		backup_hosts(const char *, const char *);
 static void		get_hosts(const char *);
 static void		insert_host(struct nsm_host *);
 static struct nsm_host *find_host(uint32_t);
-static void		nsm_log(int fac, const char *fmt, ...);
 static int		record_pid(void);
 static void		drop_privs(void);
 static void		set_kernel_nsm_state(int state);
@@ -130,21 +129,12 @@ static struct addrinfo *smn_lookup(const char *name)
 	int error;
 
 	error = getaddrinfo(name, NULL, &hint, &ai);
-	switch (error) {
-	case 0:
-		return ai;
-	case EAI_SYSTEM: 
-		if (opt_debug)
-			nsm_log(LOG_ERR, "getaddrinfo(3): %s",
-					strerror(errno));
-		break;
-	default:
-		if (opt_debug)
-			nsm_log(LOG_ERR, "getaddrinfo(3): %s",
-					gai_strerror(error));
+	if (error) {
+		xlog(D_GENERAL, "getaddrinfo(3): %s", gai_strerror(error));
+		return NULL;
 	}
 
-	return NULL;
+	return ai;
 }
 
 static void smn_forget_host(struct nsm_host *host)
@@ -163,8 +153,15 @@ main(int argc, char **argv)
 {
 	int	c;
 	int	force = 0;
+	char *	progname;
 
-	while ((c = getopt(argc, argv, "dm:np:v:qP:f")) != -1) {
+	progname = strrchr(argv[0], '/');
+	if (progname != NULL)
+		progname++;
+	else
+		progname = argv[0];
+
+	while ((c = getopt(argc, argv, "dm:np:v:P:f")) != -1) {
 		switch (c) {
 		case 'f':
 			force = 1;
@@ -184,9 +181,6 @@ main(int argc, char **argv)
 		case 'v':
 			opt_srcaddr = optarg;
 			break;
-		case 'q':
-			opt_quiet = 1;
-			break;
 		case 'P':
 			_SM_BASE_PATH = strdup(optarg);
 			_SM_STATE_PATH = malloc(strlen(optarg)+1+sizeof("state"));
@@ -196,7 +190,7 @@ main(int argc, char **argv)
 			    _SM_STATE_PATH == NULL ||
 			    _SM_DIR_PATH == NULL ||
 			    _SM_BAK_PATH == NULL) {
-				nsm_log(LOG_ERR, "unable to allocate memory");
+				fprintf(stderr, "unable to allocate memory");
 				exit(1);
 			}
 			strcat(strcpy(_SM_STATE_PATH, _SM_BASE_PATH), "/state");
@@ -211,18 +205,26 @@ main(int argc, char **argv)
 
 	if (optind < argc) {
 usage:		fprintf(stderr,
-			"Usage: sm-notify [-dfq] [-m max-retry-minutes] [-p srcport]\n"
-			"            [-P /path/to/state/directory] [-v my_host_name]\n");
+			"Usage: %s -notify [-dfq] [-m max-retry-minutes] [-p srcport]\n"
+			"            [-P /path/to/state/directory] [-v my_host_name]\n",
+			progname);
 		exit(1);
 	}
 
-	log_syslog = 1;
-	openlog("sm-notify", LOG_PID, LOG_DAEMON);
+	xlog_syslog(1);
+	if (opt_debug) {
+		xlog_stderr(1);
+		xlog_config(D_ALL, 1);
+	} else
+		xlog_stderr(0);
+
+	xlog_open(progname);
+	xlog(L_NOTICE, "Version " VERSION " starting");
 
 	if (strcmp(_SM_BASE_PATH, BASEDIR) == 0) {
 		if (record_pid() == 0 && force == 0 && opt_update_state == 1) {
 			/* already run, don't try again */
-			nsm_log(LOG_NOTICE, "Already notifying clients; Exiting!");
+			xlog(L_NOTICE, "Already notifying clients; Exiting!");
 			exit(0);
 		}
 	}
@@ -231,8 +233,7 @@ usage:		fprintf(stderr,
 		strncpy(nsm_hostname, opt_srcaddr, sizeof(nsm_hostname)-1);
 	} else
 	if (gethostname(nsm_hostname, sizeof(nsm_hostname)) < 0) {
-		nsm_log(LOG_ERR, "Failed to obtain name of local host: %s",
-			strerror(errno));
+		xlog(L_ERROR, "Failed to obtain name of local host: %m");
 		exit(1);
 	}
 
@@ -241,7 +242,7 @@ usage:		fprintf(stderr,
 
 	/* If there are not hosts to notify, just exit */
 	if (!hosts) {
-		nsm_log(LOG_DEBUG, "No hosts to notify; exiting");
+		xlog(D_GENERAL, "No hosts to notify; exiting");
 		return 0;
 	}
 
@@ -250,12 +251,10 @@ usage:		fprintf(stderr,
 	set_kernel_nsm_state(nsm_state);
 
 	if (!opt_debug) {
-		if (!opt_quiet)
-			printf("Backgrounding to notify hosts...\n");
+		xlog(L_NOTICE, "Backgrounding to notify hosts...\n");
 
 		if (daemon(0, 0) < 0) {
-			nsm_log(LOG_ERR, "unable to background: %s",
-					strerror(errno));
+			xlog(L_ERROR, "unable to background: %m");
 			exit(1);
 		}
 
@@ -271,8 +270,7 @@ usage:		fprintf(stderr,
 
 		while ((hp = hosts) != 0) {
 			hosts = hp->next;
-			nsm_log(LOG_NOTICE,
-				"Unable to notify %s, giving up",
+			xlog(L_NOTICE, "Unable to notify %s, giving up",
 				hp->name);
 		}
 		exit(1);
@@ -296,8 +294,7 @@ notify(void)
  retry:
 	sock = socket(AF_INET, SOCK_DGRAM, 0);
 	if (sock < 0) {
-		nsm_log(LOG_ERR, "Failed to create RPC socket: %s",
-			strerror(errno));
+		xlog(L_ERROR, "Failed to create RPC socket: %m");
 		exit(1);
 	}
 	fcntl(sock, F_SETFL, O_NONBLOCK);
@@ -309,7 +306,7 @@ notify(void)
 	if (opt_srcaddr) {
 		struct addrinfo *ai = smn_lookup(opt_srcaddr);
 		if (!ai) {
-			nsm_log(LOG_ERR,
+			xlog(L_ERROR,
 				"Not a valid hostname or address: \"%s\"",
 				opt_srcaddr);
 			exit(1);
@@ -326,8 +323,7 @@ notify(void)
 	if (opt_srcport) {
 		smn_set_port(local_addr, opt_srcport);
 		if (bind(sock, local_addr, sizeof(struct sockaddr_in)) < 0) {
-			nsm_log(LOG_ERR, "Failed to bind RPC socket: %s",
-				strerror(errno));
+			xlog(L_ERROR, "Failed to bind RPC socket: %m");
 			exit(1);
 		}
 	} else {
@@ -383,7 +379,7 @@ notify(void)
 		if (hosts == NULL)
 			return;
 
-		nsm_log(LOG_DEBUG, "Host %s due in %ld seconds",
+		xlog(D_GENERAL, "Host %s due in %ld seconds",
 				hosts->name, wait);
 
 		pfd.fd = sock;
@@ -420,8 +416,7 @@ notify_host(int sock, struct nsm_host *host)
 	if (host->ai == NULL) {
 		host->ai = smn_lookup(host->name);
 		if (host->ai == NULL) {
-			nsm_log(LOG_WARNING,
-				"DNS resolution of %s failed; "
+			xlog_warn("DNS resolution of %s failed; "
 				"retrying later", host->name);
 			return 0;
 		}
@@ -467,7 +462,7 @@ notify_host(int sock, struct nsm_host *host)
 	memcpy(dest, &host->addr, destlen);
 	if (smn_get_port(dest) == 0) {
 		/* Build a PMAP packet */
-		nsm_log(LOG_DEBUG, "Sending portmap query to %s", host->name);
+		xlog(D_GENERAL, "Sending portmap query to %s", host->name);
 
 		smn_set_port(dest, 111);
 		*p++ = htonl(100000);
@@ -484,7 +479,7 @@ notify_host(int sock, struct nsm_host *host)
 		*p++ = 0;
 	} else {
 		/* Build an SM_NOTIFY packet */
-		nsm_log(LOG_DEBUG, "Sending SM_NOTIFY to %s", host->name);
+		xlog(D_GENERAL, "Sending SM_NOTIFY to %s", host->name);
 
 		*p++ = htonl(NSM_PROGRAM);
 		*p++ = htonl(NSM_VERSION);
@@ -504,8 +499,8 @@ notify_host(int sock, struct nsm_host *host)
 	len = (p - msgbuf) << 2;
 
 	if (sendto(sock, msgbuf, len, 0, dest, destlen) < 0)
-		nsm_log(LOG_WARNING, "Sending Reboot Notification to "
-			"'%s' failed: errno %d (%s)", host->name, errno, strerror(errno));
+		xlog_warn("Sending Reboot Notification to "
+			"'%s' failed: errno %d (%m)", host->name, errno);
 	
 	return 0;
 }
@@ -526,7 +521,7 @@ recv_reply(int sock)
 	if (res < 0)
 		return;
 
-	nsm_log(LOG_DEBUG, "Received packet...");
+	xlog(D_GENERAL, "Received packet...");
 
 	p = msgbuf;
 	end = p + (res >> 2);
@@ -557,7 +552,7 @@ recv_reply(int sock)
 		if (port == 0) {
 			/* No binding for statd. Delay the next
 			 * portmap query for max timeout */
-			nsm_log(LOG_DEBUG, "No statd on %s", hp->name);
+			xlog(D_GENERAL, "No statd on %s", hp->name);
 			hp->timeout = NSM_MAX_TIMEOUT;
 			hp->send_next += NSM_MAX_TIMEOUT;
 		} else {
@@ -573,7 +568,7 @@ recv_reply(int sock)
 		 * packet)
 		 */
 		if (p <= end) {
-			nsm_log(LOG_DEBUG, "Host %s notified successfully",
+			xlog(D_GENERAL, "Host %s notified successfully",
 					hp->name);
 			smn_forget_host(hp);
 			return;
@@ -594,8 +589,7 @@ backup_hosts(const char *dirname, const char *bakname)
 	DIR		*dir;
 
 	if (!(dir = opendir(dirname))) {
-		nsm_log(LOG_WARNING,
-			"Failed to open %s: %s", dirname, strerror(errno));
+		xlog_warn("Failed to open %s: %m", dirname);
 		return;
 	}
 
@@ -607,11 +601,8 @@ backup_hosts(const char *dirname, const char *bakname)
 
 		snprintf(src, sizeof(src), "%s/%s", dirname, de->d_name);
 		snprintf(dst, sizeof(dst), "%s/%s", bakname, de->d_name);
-		if (rename(src, dst) < 0) {
-			nsm_log(LOG_WARNING,
-				"Failed to rename %s -> %s: %m",
-				src, dst);
-		}
+		if (rename(src, dst) < 0)
+			xlog_warn("Failed to rename %s -> %s: %m", src, dst);
 	}
 	closedir(dir);
 }
@@ -627,8 +618,7 @@ get_hosts(const char *dirname)
 	DIR		*dir;
 
 	if (!(dir = opendir(dirname))) {
-		nsm_log(LOG_WARNING,
-			"Failed to open %s: %s", dirname, strerror(errno));
+		xlog_warn("Failed to open %s: %m", dirname);
 		return;
 	}
 
@@ -642,7 +632,7 @@ get_hosts(const char *dirname)
 		if (host == NULL)
 			host = calloc(1, sizeof(*host));
 		if (host == NULL) {
-			nsm_log(LOG_WARNING, "Unable to allocate memory");
+			xlog_warn("Unable to allocate memory");
 			return;
 		}
 
@@ -723,17 +713,14 @@ nsm_get_state(int update)
 	int		fd, state;
 
 	if ((fd = open(_SM_STATE_PATH, O_RDONLY)) < 0) {
-		if (!opt_quiet) {
-			nsm_log(LOG_WARNING, "%s: %m", _SM_STATE_PATH);
-			nsm_log(LOG_WARNING, "Creating %s, set initial state 1",
-				_SM_STATE_PATH);
-		}
+		xlog_warn("%s: %m", _SM_STATE_PATH);
+		xlog_warn("Creating %s, set initial state 1",
+			_SM_STATE_PATH);
 		state = 1;
 		update = 1;
 	} else {
 		if (read(fd, &state, sizeof(state)) != sizeof(state)) {
-			nsm_log(LOG_WARNING,
-				"%s: bad file size, setting state = 1",
+			xlog_warn("%s: bad file size, setting state = 1",
 				_SM_STATE_PATH);
 			state = 1;
 			update = 1;
@@ -749,17 +736,17 @@ nsm_get_state(int update)
 		snprintf(newfile, sizeof(newfile),
 				"%s.new", _SM_STATE_PATH);
 		if ((fd = open(newfile, O_CREAT|O_WRONLY, 0644)) < 0) {
-			nsm_log(LOG_ERR, "Cannot create %s: %m", newfile);
+			xlog(L_ERROR, "Cannot create %s: %m", newfile);
 			exit(1);
 		}
 		if (write(fd, &state, sizeof(state)) != sizeof(state)) {
-			nsm_log(LOG_ERR,
+			xlog(L_ERROR,
 				"Failed to write state to %s", newfile);
 			exit(1);
 		}
 		close(fd);
 		if (rename(newfile, _SM_STATE_PATH) < 0) {
-			nsm_log(LOG_ERR,
+			xlog(L_ERROR,
 				"Cannot create %s: %m", _SM_STATE_PATH);
 			exit(1);
 		}
@@ -770,27 +757,6 @@ nsm_get_state(int update)
 }
 
 /*
- * Log a message
- */
-static void
-nsm_log(int fac, const char *fmt, ...)
-{
-	va_list	ap;
-
-	if (fac == LOG_DEBUG && !opt_debug)
-		return;
-
-	va_start(ap, fmt);
-	if (log_syslog)
-		vsyslog(fac, fmt, ap);
-	else {
-		vfprintf(stderr, fmt, ap);
-		fputs("\n", stderr);
-	}
-	va_end(ap);
-}
-
-/*
  * Record pid in /var/run/sm-notify.pid
  * This file should remain until a reboot, even if the
  * program exits.
@@ -806,8 +772,8 @@ static int record_pid(void)
 	if (fd < 0)
 		return 0;
 	if (write(fd, pid, strlen(pid)) != strlen(pid))  {
-		nsm_log(LOG_WARNING, "Writing to pid file failed: errno %d(%s)",
-			errno, strerror(errno));
+		xlog_warn("Writing to pid file failed: errno %d (%m)",
+				errno);
 	}
 	close(fd);
 	return 1;
@@ -827,16 +793,15 @@ static void drop_privs(void)
 	}
 
 	if (st.st_uid == 0) {
-		nsm_log(LOG_WARNING,
-			"sm-notify running as root. chown %s to choose different user",
-		    _SM_DIR_PATH);
+		xlog_warn("Running as 'root'.  "
+			"chown %s to choose different user", _SM_DIR_PATH);
 		return;
 	}
 
 	setgroups(0, NULL);
 	if (setgid(st.st_gid) == -1
 	    || setuid(st.st_uid) == -1) {
-		nsm_log(LOG_ERR, "Fail to drop privileges");
+		xlog(L_ERROR, "Fail to drop privileges");
 		exit(1);
 	}
 }
@@ -851,8 +816,8 @@ static void set_kernel_nsm_state(int state)
 		char buf[20];
 		snprintf(buf, sizeof(buf), "%d", state);
 		if (write(fd, buf, strlen(buf)) != strlen(buf)) {
-			nsm_log(LOG_WARNING, "Writing to '%s' failed: errno %d (%s)",
-				file, errno, strerror(errno));
+			xlog_warn("Writing to '%s' failed: errno %d (%m)",
+				file, errno);
 		}
 		close(fd);
 	}
diff --git a/utils/statd/sm-notify.man b/utils/statd/sm-notify.man
index dd03b8d..a5c1cc5 100644
--- a/utils/statd/sm-notify.man
+++ b/utils/statd/sm-notify.man
@@ -6,7 +6,7 @@
 .SH NAME
 sm-notify \- Send out NSM reboot notifications
 .SH SYNOPSIS
-.BI "/sbin/sm-notify [-dfq] [-m " time "] [-p " port "] [-P " path "] [-v " my_name " ]
+.BI "/sbin/sm-notify [-df] [-m " time "] [-p " port "] [-P " path "] [-v " my_name " ]
 .SH DESCRIPTION
 File locking over NFS (v2 and v3) requires a facility to notify peers in
 case of a reboot, so that clients can reclaim locks after
@@ -101,10 +101,6 @@ to bind to the indicated IP
 number. If this option is not given, it will try to bind to
 a randomly chosen privileged port below 1024.
 .TP
-.B -q
-Be quiet. This suppresses all messages except error
-messages while collecting the list of hosts.
-.TP
 .BI -P " /path/to/state/directory
 If
 .B sm-notify

