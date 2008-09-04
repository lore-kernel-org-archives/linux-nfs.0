From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/16] sm-notify command: clean up error logging
Date: Thu, 04 Sep 2008 12:56:31 -0400
Message-ID: <20080904165630.1471.95600.stgit@manray.1015granger.net>
References: <20080904165122.1471.24485.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:48014 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752881AbYIDQ5V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2008 12:57:21 -0400
In-Reply-To: <20080904165122.1471.24485.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up a few issues with logging in sm-notify.c.

Sometimes in sm-notify, when a system call fails the problem is reported
to stderr but not logged, and then usually sm-notify exits.  In cases like
this, there are probably more hosts to notify, but sm-notify dies silently.

Make sure these errors are logged, and that the log messages explain the
nature of the problem.

Also, if sm-notify exits prematurely, make sure this is always reported at
the LOG_ERR level, not at the LOG_WARNING level.

Remove a couple of unnecessary '\n' in the arguments of nsm_log() calls --
nsm_log() already appends an '\n' to the message.

Finally, use exit() consistently in main().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |   48 ++++++++++++++++++++++++++++-------------------
 1 files changed, 29 insertions(+), 19 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index b69f4cc..e5ca904 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -134,7 +134,7 @@ main(int argc, char **argv)
 			    _SM_STATE_PATH == NULL ||
 			    _SM_DIR_PATH == NULL ||
 			    _SM_BAK_PATH == NULL) {
-				nsm_log(LOG_WARNING, "unable to allocate memory");
+				nsm_log(LOG_ERR, "unable to allocate memory");
 				exit(1);
 			}
 			strcat(strcpy(_SM_STATE_PATH, _SM_BASE_PATH), "/state");
@@ -151,7 +151,7 @@ main(int argc, char **argv)
 usage:		fprintf(stderr,
 			"Usage: sm-notify [-dfq] [-m max-retry-minutes] [-p srcport]\n"
 			"            [-P /path/to/state/directory] [-v my_host_name]\n");
-		return 1;
+		exit(1);
 	}
 
 	if (strcmp(_SM_BASE_PATH, BASEDIR) == 0) {
@@ -164,8 +164,9 @@ usage:		fprintf(stderr,
 		strncpy(nsm_hostname, opt_srcaddr, sizeof(nsm_hostname)-1);
 	} else
 	if (gethostname(nsm_hostname, sizeof(nsm_hostname)) < 0) {
-		perror("gethostname");
-		return 1;
+		nsm_log(LOG_ERR, "Failed to obtain name of local host: %s",
+			strerror(errno));
+		exit(1);
 	}
 
 	backup_hosts(_SM_DIR_PATH, _SM_BAK_PATH);
@@ -183,9 +184,9 @@ usage:		fprintf(stderr,
 		log_syslog = 1;
 
 		if (daemon(0, 0) < 0) {
-			nsm_log(LOG_WARNING, "unable to background: %s",
+			nsm_log(LOG_ERR, "unable to background: %s",
 					strerror(errno));
-			return 1;
+			exit(1);
 		}
 
 		close(0);
@@ -204,10 +205,10 @@ usage:		fprintf(stderr,
 				"Unable to notify %s, giving up",
 				hp->name);
 		}
-		return 1;
+		exit(1);
 	}
 
-	return 0;
+	exit(0);
 }
 
 /*
@@ -224,7 +225,8 @@ notify(void)
  retry:
 	sock = socket(AF_INET, SOCK_DGRAM, 0);
 	if (sock < 0) {
-		perror("socket");
+		nsm_log(LOG_ERR, "Failed to create RPC socket: %s",
+			strerror(errno));
 		exit(1);
 	}
 	fcntl(sock, F_SETFL, O_NONBLOCK);
@@ -236,8 +238,8 @@ notify(void)
 	if (opt_srcaddr) {
 		struct addrinfo *ai = host_lookup(AF_INET, opt_srcaddr);
 		if (!ai) {
-			nsm_log(LOG_WARNING,
-				"Not a valid hostname or address: \"%s\"\n",
+			nsm_log(LOG_ERR,
+				"Not a valid hostname or address: \"%s\"",
 				opt_srcaddr);
 			exit(1);
 		}
@@ -253,7 +255,8 @@ notify(void)
 	if (opt_srcport) {
 		addr_set_port(&local_addr, opt_srcport);
 		if (bind(sock, (struct sockaddr *) &local_addr, sizeof(local_addr)) < 0) {
-			perror("bind");
+			nsm_log(LOG_ERR, "Failed to bind RPC socket: %s",
+				strerror(errno));
 			exit(1);
 		}
 	} else {
@@ -492,7 +495,8 @@ recv_reply(int sock)
 		 * packet)
 		 */
 		if (p <= end) {
-			nsm_log(LOG_DEBUG, "Host %s notified successfully", hp->name);
+			nsm_log(LOG_DEBUG, "Host %s notified successfully",
+					hp->name);
 			unlink(hp->path);
 			free(hp->name);
 			free(hp->path);
@@ -516,7 +520,8 @@ backup_hosts(const char *dirname, const char *bakname)
 	DIR		*dir;
 
 	if (!(dir = opendir(dirname))) {
-		perror(dirname);
+		nsm_log(LOG_WARNING,
+			"Failed to open %s: %s", dirname, strerror(errno));
 		return;
 	}
 
@@ -548,7 +553,8 @@ get_hosts(const char *dirname)
 	DIR		*dir;
 
 	if (!(dir = opendir(dirname))) {
-		perror(dirname);
+		nsm_log(LOG_WARNING,
+			"Failed to open %s: %s", dirname, strerror(errno));
 		return;
 	}
 
@@ -561,6 +567,10 @@ get_hosts(const char *dirname)
 			continue;
 		if (host == NULL)
 			host = calloc(1, sizeof(*host));
+		if (host == NULL) {
+			nsm_log(LOG_WARNING, "Unable to allocate memory");
+			return;
+		}
 
 		snprintf(path, sizeof(path), "%s/%s", dirname, de->d_name);
 		if (stat(path, &stb) < 0)
@@ -665,17 +675,17 @@ nsm_get_state(int update)
 		snprintf(newfile, sizeof(newfile),
 				"%s.new", _SM_STATE_PATH);
 		if ((fd = open(newfile, O_CREAT|O_WRONLY, 0644)) < 0) {
-			nsm_log(LOG_WARNING, "Cannot create %s: %m", newfile);
+			nsm_log(LOG_ERR, "Cannot create %s: %m", newfile);
 			exit(1);
 		}
 		if (write(fd, &state, sizeof(state)) != sizeof(state)) {
-			nsm_log(LOG_WARNING,
+			nsm_log(LOG_ERR,
 				"Failed to write state to %s", newfile);
 			exit(1);
 		}
 		close(fd);
 		if (rename(newfile, _SM_STATE_PATH) < 0) {
-			nsm_log(LOG_WARNING,
+			nsm_log(LOG_ERR,
 				"Cannot create %s: %m", _SM_STATE_PATH);
 			exit(1);
 		}
@@ -784,7 +794,7 @@ static void drop_privs(void)
 
 	if (st.st_uid == 0) {
 		nsm_log(LOG_WARNING,
-			"sm-notify running as root. chown %s to choose different user\n",
+			"sm-notify running as root. chown %s to choose different user",
 		    _SM_DIR_PATH);
 		return;
 	}

