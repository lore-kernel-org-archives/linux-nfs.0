From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils 2 of 10 - Incorporate some clean up code from Ulrich
 Drepper
Date: Fri, 23 Sep 2005 10:44:32 -0400
Message-ID: <433414D0.8030905@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090408060908060004000205"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EIon0-0005mv-98
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 07:44:38 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EIomz-0002Rb-D2
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 07:44:38 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id j8NEiY7P014051
	for <nfs@lists.sourceforge.net>; Fri, 23 Sep 2005 10:44:34 -0400
Received: from [172.16.50.33] (vpn50-33.rdu.redhat.com [172.16.50.33])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j8NEiXV12659
	for <nfs@lists.sourceforge.net>; Fri, 23 Sep 2005 10:44:33 -0400
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------090408060908060004000205
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------090408060908060004000205
Content-Type: text/x-patch;
 name="nfs-utils-1.0.6-fd-sig-cleanup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.6-fd-sig-cleanup.patch"

Incorporate some clean up code from Ulrich Drepper (bz# 134025)

As stated in https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=134025
Various daemons in nfs-utils close all file descriptors before
starting work.  This happens in a very inefficient way.  All iterate
over all possible descriptor values and make a close(2) call.  Image
what happens if the file descriptor limit is high?

There is no reason for this, programs can learn exactly which
descriptors are used from the /proc/self/fd directory.

Signed-off-by: Steve Dickson <steved@redhat.com>
---------
--- nfs-utils-1.0.6/utils/mountd/mountd.c.orig	2004-11-01 16:39:37.823132000 -0500
+++ nfs-utils-1.0.6/utils/mountd/mountd.c	2004-11-01 16:41:23.098656000 -0500
@@ -18,6 +18,7 @@
 #include <getopt.h>
 #include <errno.h>
 #include <fcntl.h>
+#include <dirent.h>
 #include <sys/resource.h>
 #include "xmalloc.h"
 #include "misc.h"
@@ -553,9 +554,23 @@
 
 	/* Daemons should close all extra filehandles ... *before* RPC init. */
 	if (!foreground) {
-		int fd = sysconf (_SC_OPEN_MAX);
-		while (--fd > 2)
-			(void) close(fd);
+		DIR *dir = opendir("/proc/self/fd");
+		if (dir != NULL) {
+			int dfd = dirfd(dir);
+			struct dirent *d;
+
+			while ((d = readdir(dir)) != NULL) {
+				char *endp;
+				long n = strtol(d->d_name, &endp, 10);
+				if (*endp == '\0' && n > 2 && n != dfd)
+					(void) close(n);
+			}
+			closedir(dir);
+		} else {
+			int fd = sysconf (_SC_OPEN_MAX);
+			while (--fd > 2)
+				(void) close(fd);
+		}
 	}
 
 	new_cache = check_new_cache();
--- nfs-utils-1.0.6/utils/nfsd/nfsd.c.orig	2002-09-12 17:08:42.000000000 -0400
+++ nfs-utils-1.0.6/utils/nfsd/nfsd.c	2004-11-01 16:41:23.111659000 -0500
@@ -18,6 +18,7 @@
 #include <getopt.h>
 #include <syslog.h>
 #include <netdb.h>
+#include <dirent.h>
 #include "nfslib.h"
 
 static void	usage(const char *);
@@ -27,6 +28,7 @@
 {
 	int	count = 1, c, error, port, fd;
 	struct servent *ent;
+	DIR *dir;
 
 	ent = getservbyname ("nfs", "udp");
 	if (ent != NULL)
@@ -80,9 +82,22 @@
 		(void) dup2(fd, 1);
 		(void) dup2(fd, 2);
 	}
-	fd = sysconf(_SC_OPEN_MAX);
-	while (--fd > 2)
-		(void) close(fd);
+	dir = opendir("/proc/self/fd");
+	if (dir != NULL) {
+		int dfd = dirfd(dir);
+		struct dirent *d;
+		while ((d = readdir(dir)) != NULL) {
+			char *endp;
+			long int n = strtol(d->d_name, &endp, 10);
+			if (*endp == '\0' && n > 2 && n != dfd)
+				(void) close(n);
+		}
+		closedir(dir);
+	} else {
+		fd = sysconf(_SC_OPEN_MAX);
+		while (--fd > 2)
+			(void) close(fd);
+	}
 
 	if ((error = nfssvc(port, count)) < 0) {
 		int e = errno;
--- nfs-utils-1.0.6/utils/statd/statd.c.orig	2004-11-01 16:39:37.860131000 -0500
+++ nfs-utils-1.0.6/utils/statd/statd.c	2004-11-01 16:45:33.853911000 -0500
@@ -15,6 +15,7 @@
 #include <errno.h>
 #include <string.h>
 #include <getopt.h>
+#include <dirent.h>
 #include <rpc/rpc.h>
 #include <rpc/pmap_clnt.h>
 #include <rpcmisc.h>
@@ -227,6 +228,7 @@
 	int arg;
 	int port = 0, out_port = 0;
 	struct rlimit rlim;
+	struct sigaction sa;
 
 	int pipefds[2] = { -1, -1};
 	char status;
@@ -368,6 +370,7 @@
 	
 	if (!(run_mode & MODE_NODAEMON)) {
 		int filedes, fdmax, tempfd;
+		DIR *dir;
 
 		if (pipe(pipefds)<0) {
 			perror("statd: unable to create pipe");
@@ -401,13 +404,27 @@
 			}
 		}
 		tempfd = open("/dev/null", O_RDWR);
-		close(0); dup2(tempfd, 0);
-		close(1); dup2(tempfd, 1);
-		close(2); dup2(tempfd, 2);
-		fdmax = sysconf (_SC_OPEN_MAX);
-		for (filedes = 3; filedes < fdmax; filedes++) 
-			if (filedes != pipefds[1])
-				close (filedes);
+		dup2(tempfd, 0);
+		dup2(tempfd, 1);
+		dup2(tempfd, 2);
+		dir = opendir("/proc/self/fd");
+		if (dir != NULL) {
+			int dfd = dirfd(dir);
+			struct dirent *d;
+			while ((d = readdir(dir)) != NULL) {
+				char *endp;
+				long int n = strtol(d->d_name, &endp, 10);
+				if (*endp == '\0' && n > 2 && n != dfd &&
+				    n != pipefds[1])
+					(void) close(n);
+			}
+			closedir(dir);
+		} else {
+			fdmax = sysconf (_SC_OPEN_MAX);
+			for (filedes = 3; filedes < fdmax; filedes++) 
+				if (filedes != pipefds[1])
+					close (filedes);
+		}
 
 	}
 
@@ -417,9 +434,16 @@
 
 	log_modes();
 
-	signal (SIGHUP, killer);
-	signal (SIGINT, killer);
-	signal (SIGTERM, killer);
+	sa.sa_handler = killer;
+	sigemptyset(&sa.sa_mask);
+    sigaddset(&sa.sa_mask, SIGINT);
+	sigaddset(&sa.sa_mask, SIGTERM);
+	sigaddset(&sa.sa_mask, SIGHUP);
+	sa.sa_flags = 0;
+	(void) sigaction(SIGINT, &sa, NULL);
+	(void) sigaction(SIGTERM, &sa, NULL);
+	(void) sigaction(SIGHUP, &sa, NULL);
+
 	/* PRC: trap SIGUSR1 to re-read notify list from disk */
 	signal(SIGUSR1, sigusr);
 	/* WARNING: the following works on Linux and SysV, but not BSD! */
--- nfs-utils-1.0.6/utils/idmapd/idmapd.c.orig	2004-11-01 16:39:37.630133000 -0500
+++ nfs-utils-1.0.6/utils/idmapd/idmapd.c	2004-11-01 16:47:53.804606000 -0500
@@ -58,6 +58,7 @@
 #include <grp.h>
 #include <limits.h>
 #include <ctype.h>
+#include <dirent.h>
 #include <nfsidmap.h>
 
 #ifdef HAVE_CONFIG_H
@@ -859,14 +860,28 @@
 	}
 
 	if (noclose == 0) {
+		DIR *dir;
 		tempfd = open("/dev/null", O_RDWR);
-		close(0); dup2(tempfd, 0);
-		close(1); dup2(tempfd, 1);
-		close(2); dup2(tempfd, 2);
-		fdmax = sysconf (_SC_OPEN_MAX);
-		for (filedes = 3; filedes < fdmax; filedes++)
-			if (filedes != pipefds[1])
-				close (filedes);
+ 		dup2(tempfd, 0);
+ 		dup2(tempfd, 1);
+ 		dup2(tempfd, 2);
+ 		dir = opendir("/proc/self/fd");
+ 		if (dir != NULL) {
+ 			int dfd = dirfd(dir);
+ 			struct dirent *d;
+ 			while ((d = readdir(dir)) != NULL) {
+ 				char *endp;
+ 				long int n = strtol(d->d_name, &endp, 10);
+ 				if (*endp == '\0' && n > 2 && n != dfd &&
+ 				    n != pipefds[1])
+ 					(void) close(n);
+ 			}
+ 		} else {
+ 			fdmax = sysconf (_SC_OPEN_MAX);
+ 			for (filedes = 3; filedes < fdmax; filedes++) 
+ 				if (filedes != pipefds[1])
+ 					close (filedes);
+ 		}
 	}
 
 	return;
--- nfs-utils-1.0.6/utils/svcgssd/svcgssd.c.orig	2004-11-01 16:39:37.520131000 -0500
+++ nfs-utils-1.0.6/utils/svcgssd/svcgssd.c	2004-11-01 16:49:34.897112000 -0500
@@ -52,6 +52,7 @@
 #include <stdlib.h>
 #include <string.h>
 #include <signal.h>
+#include <dirent.h>
 #include "svcgssd.h"
 #include "gss_util.h"
 #include "err_util.h"
@@ -110,14 +111,29 @@
 	}
 
 	if (noclose == 0) {
+		DIR *dir;
 		tempfd = open("/dev/null", O_RDWR);
-		close(0); dup2(tempfd, 0);
-		close(1); dup2(tempfd, 1);
-		close(2); dup2(tempfd, 2);
-		fdmax = sysconf (_SC_OPEN_MAX);
-		for (filedes = 3; filedes < fdmax; filedes++)
-			if (filedes != pipefds[1])
-				close (filedes);
+ 		dup2(tempfd, 0);
+ 		dup2(tempfd, 1);
+ 		dup2(tempfd, 2);
+ 		dir = opendir("/proc/self/fd");
+ 		if (dir != NULL) {
+ 			int dfd = dirfd(dir);
+ 			struct dirent *d;
+ 			while ((d = readdir(dir)) != NULL) {
+ 				char *endp;
+ 				long int n = strtol(d->d_name, &endp, 10);
+ 				if (*endp == '\0' && n > 2 && n != dfd &&
+ 				    n != pipefds[1])
+ 					(void) close(n);
+ 			}
+ 			closedir(dir);
+ 		} else {
+ 			fdmax = sysconf (_SC_OPEN_MAX);
+ 			for (filedes = 3; filedes < fdmax; filedes++) 
+ 				if (filedes != pipefds[1])
+ 					close (filedes);
+ 		}
 	}
 
 	return;

--------------090408060908060004000205--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
