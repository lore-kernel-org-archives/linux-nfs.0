From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils - 3 of 6 -statd - Ensure child process is
 running for before the parent exits
Date: Wed, 18 Jun 2003 13:54:35 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EF0A75B.6010307@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070406080201000202020304"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Sh7p-0007Ls-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 10:53:37 -0700
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.9.3) with ESMTP id h5IHrPK15050
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 13:53:25 -0400
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------070406080201000202020304
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

To make sure the correct start-up status is returned
to the rc script during boot, the parent statd process
must know if the child process (i.e. "real" daemon)
was able to successfully start. Otherwise, the
child can die and the parent will returns success which
would cause networks lock to hang (unexplainable)....

SteveD.

--------------070406080201000202020304
Content-Type: text/plain;
 name="nfs-utils-1.0.3-03-statd-pipe.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.3-03-statd-pipe.patch"

--- ./utils/statd/statd.c.org	2003-06-02 15:20:53.000000000 -0400
+++ ./utils/statd/statd.c	2003-06-02 15:25:07.000000000 -0400
@@ -46,6 +46,7 @@ char *  SM_STAT_PATH = DEFAULT_SM_STAT_P
 
 short int restart = 0;
 int	run_mode = 0;		/* foreground logging mode */
+int pfds[2] = {-1, -1};            /* pipe fds */
 
 /* LH - I had these local to main, but it seemed silly to have 
  * two copies of each - one in main(), one static in log.c... 
@@ -79,14 +80,20 @@ extern void simulator (int, char **);
  */
 static const char *piddir="/var/run/rpc.statd";
 static const char *pidfile="/var/run/rpc.statd/rpc.statd.pid";
+static const char *mypidfile = NULL;
 static void
 delete_pidfile(void)
 {
-	if (unlink(pidfile) < 0) {
-		log(L_WARNING,"Unlinking %s failed: errno %d (%s)\n", pidfile,
-			errno, strerror(errno));
+	/*
+	 * Only delete the pidfile if this is
+	 * the process that created it
+	 */ 
+	if (mypidfile) {
+		if (unlink(mypidfile) < 0) {
+			log(L_WARNING,"Unlinking %s failed: errno %d (%s)\n", mypidfile,
+				errno, strerror(errno));
+		}
 	}
-
 	return;
 }
 static void
@@ -115,9 +122,20 @@ create_pidfile(void)
 		log(L_WARNING,"Closing %s failed: errno %d (%s)\n", pidfile,
 			errno, strerror(errno));
 	}
+	mypidfile = pidfile;
 
 	return;
 }
+/*
+ * Called when the child exits
+ */
+static void
+child_exit(void)
+{
+	delete_pidfile();
+	if (pfds[1] > -1)
+		close(pfds[1]);
+}
 
 /*
  * Privilege dropper
@@ -254,6 +272,7 @@ int main (int argc, char **argv)
 	int pid;
 	int arg;
 	int port = 0, out_port = 0;
+	int status=-1;
 
 	/* Default: daemon mode, no other options */
 	run_mode = 0;
@@ -373,11 +392,24 @@ int main (int argc, char **argv)
 	if (!(run_mode & MODE_NODAEMON)) {
 		int filedes, fdmax, tempfd;
 
+		if (pipe(pfds) < 0) {
+			fprintf(stderr, "Unable to create a pipe(2):"
+				" errno %d (%s)\n", errno, strerror(errno));
+			exit(-1);
+		}
 		if ((pid = fork ()) < 0) {
 			perror ("Could not fork");
-			exit (1);
+			exit(-1);
 		} else if (pid != 0) {
 			/* Parent. */
+			/*
+			 * Wait for status from the child 
+			 */
+			close(pfds[1]);
+			if (read(pfds[0], &status, sizeof(status)) < 1)
+				exit(-1); /* the child died */
+			if (status != 0)
+				exit(-1); /* the child failed */
 			exit (0);
 		}
 		/* Child.	*/
@@ -390,13 +422,16 @@ int main (int argc, char **argv)
 		close(2); dup2(tempfd, 2);
 		fdmax = sysconf (_SC_OPEN_MAX);
 		for (filedes = 3; filedes < fdmax; filedes++) {
-			close (filedes);
+			if (filedes != pfds[1]) 
+				close (filedes);
 		}
+		atexit(child_exit);
 	}
 
 	log_init (name_p, version_p);
 	create_pidfile();
-	atexit(delete_pidfile);
+	if (run_mode & MODE_NODAEMON)
+		atexit(delete_pidfile);
 
 	/* Child. */
 	signal (SIGHUP, killer);
@@ -432,6 +467,15 @@ int main (int argc, char **argv)
 	if (access(".", R_OK|W_OK|X_OK) != 0)
 		die("Cannot access current directory after dropping privs: access()\n");
 
+	/* Tell the parent everthing is ok... */
+	status=0;
+	if (write(pfds[1], &status, sizeof(status)) < 0) {
+		log(L_WARNING,"Writting to pipe[1] failed: errno %d (%s)\n",
+		errno, strerror(errno));
+	}
+	close(pfds[1]);
+	pfds[1] = -1;
+
 	for (;;) {
 		if (!(run_mode & MODE_NOTIFY_ONLY)) {
 			/* Do not do pmap_unset() when running in notify mode.

--------------070406080201000202020304--



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
