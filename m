Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52154 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727566AbeIMTS0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Sep 2018 15:18:26 -0400
Subject: [PATCH 1/3] request-key: Provide a command line option to suppress
 execution
From: David Howells <dhowells@redhat.com>
To: keyrings@vger.kernel.org
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Date: Thu, 13 Sep 2018 15:08:44 +0100
Message-ID: <153684772475.10049.997401846544926862.stgit@warthog.procyon.org.uk>
In-Reply-To: <153684771698.10049.12488548190876920608.stgit@warthog.procyon.org.uk>
References: <153684771698.10049.12488548190876920608.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow "-x" to be passed on the command line to the request-key program to
suppress side effects and target execution.  This makes it easier to debug
the program and its configuration by allowing it to be driven from the
command line.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 request-key.c |   78 +++++++++++++++++++++++++++++++++------------------------
 1 file changed, 45 insertions(+), 33 deletions(-)

diff --git a/request-key.c b/request-key.c
index 3762e9a..ecd7b79 100644
--- a/request-key.c
+++ b/request-key.c
@@ -24,6 +24,7 @@
 #include <signal.h>
 #include <syslog.h>
 #include <unistd.h>
+#include <getopt.h>
 #include <fcntl.h>
 #include <errno.h>
 #include <ctype.h>
@@ -32,8 +33,9 @@
 #include "keyutils.h"
 
 
-static int xdebug;
+static int verbosity;
 static int xnolog;
+static int debug_mode;
 static char *xkey;
 static char *xuid;
 static char *xgid;
@@ -75,7 +77,7 @@ static void debug(const char *fmt, ...)
 {
 	va_list va;
 
-	if (xdebug) {
+	if (verbosity) {
 		va_start(va, fmt);
 		vfprintf(stderr, fmt, va);
 		va_end(va);
@@ -97,7 +99,7 @@ static void error(const char *fmt, ...)
 {
 	va_list va;
 
-	if (xdebug) {
+	if (verbosity) {
 		va_start(va, fmt);
 		vfprintf(stderr, fmt, va);
 		va_end(va);
@@ -132,7 +134,7 @@ int main(int argc, char *argv[])
 {
 	key_serial_t key;
 	char *ktype, *kdesc, *buf, *callout_info;
-	int ret, ntype, dpos, n, fd;
+	int ret, ntype, dpos, n, fd, opt;
 
 	if (argc == 2 && strcmp(argv[1], "--version") == 0) {
 		printf("request-key from %s (Built %s)\n",
@@ -144,22 +146,25 @@ int main(int argc, char *argv[])
 	signal(SIGBUS, oops);
 	signal(SIGPIPE, SIG_IGN);
 
-	for (;;) {
-		if (argc > 1 && strcmp(argv[1], "-d") == 0) {
-			xdebug++;
-			argv++;
-			argc--;
-		}
-		else if (argc > 1 && strcmp(argv[1], "-n") == 0) {
+	while (opt = getopt(argc, argv, "dnv"),
+	       opt != -1) {
+		switch (opt) {
+		case 'd':
+			debug_mode = 1;
+			break;
+		case 'n':
 			xnolog = 1;
-			argv++;
-			argc--;
-		}
-		else
 			break;
+		case 'v':
+			verbosity++;
+			break;
+		}
 	}
 
-	if (argc != 8 && argc != 9)
+	argc -= optind;
+	argv += optind;
+
+	if (argc != 7 && argc != 8)
 		error("Unexpected argument count: %d\n", argc);
 
 	fd = open("/dev/null", O_RDWR);
@@ -177,24 +182,26 @@ int main(int argc, char *argv[])
 			error("dup failed: %m\n");
 	}
 
-	xkey = argv[2];
-	xuid = argv[3];
-	xgid = argv[4];
-	xthread_keyring = argv[5];
-	xprocess_keyring = argv[6];
-	xsession_keyring = argv[7];
+	xkey = argv[1];
+	xuid = argv[2];
+	xgid = argv[3];
+	xthread_keyring = argv[4];
+	xprocess_keyring = argv[5];
+	xsession_keyring = argv[6];
 
 	key = atoi(xkey);
 
 	/* assume authority over the key
 	 * - older kernel doesn't support this function
 	 */
-	ret = keyctl_assume_authority(key);
-	if (ret < 0 && !(argc == 9 || errno == EOPNOTSUPP))
-		error("Failed to assume authority over key %d (%m)\n", key);
+	if (!debug_mode) {
+		ret = keyctl_assume_authority(key);
+		if (ret < 0 && !(argc == 8 || errno == EOPNOTSUPP))
+			error("Failed to assume authority over key %d (%m)\n", key);
+	}
 
 	/* ask the kernel to describe the key to us */
-	if (xdebug < 2) {
+	if (!debug_mode) {
 		ret = keyctl_describe_alloc(key, &buf);
 		if (ret < 0)
 			goto inaccessible;
@@ -220,7 +227,7 @@ int main(int argc, char *argv[])
 	debug("Key desc: %s\n", kdesc);
 
 	/* get hold of the callout info */
-	callout_info = argv[8];
+	callout_info = argv[7];
 
 	if (!callout_info) {
 		void *tmp;
@@ -234,7 +241,7 @@ int main(int argc, char *argv[])
 	debug("CALLOUT: '%s'\n", callout_info);
 
 	/* determine the action to perform */
-	lookup_action(argv[1],		/* op */
+	lookup_action(argv[0],		/* op */
 		      key,		/* ID of key under construction */
 		      ktype,		/* key type */
 		      kdesc,		/* key description */
@@ -267,7 +274,7 @@ static void lookup_action(char *op,
 
 	/* search the config file for a command to run */
 	if (strlen(ktype) <= sizeof(conffile) - 30) {
-		if (xdebug < 2)
+		if (verbosity < 2)
 			snprintf(conffile, sizeof(conffile) - 1,
 				 "/etc/request-key.d/%s.conf", ktype);
 		else
@@ -280,7 +287,7 @@ static void lookup_action(char *op,
 			error("Cannot open %s: %m\n", conffile);
 	}
 
-	if (xdebug < 2)
+	if (verbosity < 2)
 		snprintf(conffile, sizeof(conffile) - 1, "/etc/request-key.conf");
 	else
 		snprintf(conffile, sizeof(conffile) - 1, "request-key.conf");
@@ -596,7 +603,7 @@ static void execute_program(char *op,
 
 	argv[argc] = NULL;
 
-	if (xdebug) {
+	if (verbosity) {
 		char **ap;
 
 		debug("%s %s\n", pipeit ? "PipeThru" : "Run", prog);
@@ -611,6 +618,11 @@ static void execute_program(char *op,
 	/* if the last argument is a single bar, we spawn off the program dangling on the end of
 	 * three pipes and read the key material from the program, otherwise we just exec
 	 */
+	if (debug_mode) {
+		printf("-- exec disabled --\n");
+		exit(0);
+	}
+
 	if (pipeit)
 		pipe_to_program(op, key, ktype, kdesc, callout_info, prog, argv);
 
@@ -791,7 +803,7 @@ static void pipe_to_program(char *op,
 				nl++;
 				n = nl - errbuf;
 
-				if (xdebug)
+				if (verbosity)
 					fprintf(stderr, "Child: %*.*s", n, n, errbuf);
 
 				if (!xnolog) {
@@ -815,7 +827,7 @@ static void pipe_to_program(char *op,
 			if (espace == 0) {
 				int n = sizeof(errbuf);
 
-				if (xdebug)
+				if (verbosity)
 					fprintf(stderr, "Child: %*.*s", n, n, errbuf);
 
 				if (!xnolog) {
