From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: mount.nfs: chk_mountpoint()
Date: Thu, 30 Aug 2007 12:19:03 -0400
Message-ID: <20070830161903.GH26863@fieldses.org>
References: <46CC884B.1030207@oracle.com> <46CD82A0.1000408@redhat.com>
	<46CDC7D0.6030803@oracle.com> <46CDD069.3070608@redhat.com>
	<46CDE76C.3040800@oracle.com> <46CDEA2E.10902@redhat.com>
	<20070830101249.GA9880@janus> <46D6AFBC.3000208@redhat.com>
	<46D6E9CF.4000901@oracle.com> <46D6EB44.7050600@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Frank van Maarseveen <frankvm@frankvm.com>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQmje-0004PQ-LE
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 09:19:11 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQmjg-0007qU-7U
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 09:19:15 -0700
In-Reply-To: <46D6EB44.7050600@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, Aug 30, 2007 at 12:07:32PM -0400, Peter Staubach wrote:
> Chuck Lever wrote:
> > From my experience, generally mountd (on most any server 
> > implementation) has been a scalability problem in these scenarios.  It 
> > can't handle more than a few requests per second.
> 
> Perhaps we need to look at multithreading mountd?  Ala Solaris?

Does nfs-utils commit 11d34d1 (below) do the job?

--b.

commit 11d34d11153df198103a57291937ea9ff8b7356e
Author: Greg Banks <gnb@melbourne.sgi.com>
Date:   Wed Jun 14 22:48:10 2006 +1000

    multiple threads for mountd
    
    
    How about the attached patch against nfs-utils tot?  It
    adds a -t option to set the number of forked workers.
    Default is 1 thread, i.e. the old behaviour.
    
    I've verified that showmount -e, the Ogata mount client,
    and a real mount from Linux and IRIX boxes work with and
    without the new option.
    
    I've verified that you can manually kill any of the workers
    without the portmap registration going away, that killing
    all the workers causes the manager process to wake up and
    unregister, and killing the manager process causes the
    workers to be killed and portmap unregistered.
    
    I've verified that all the workers have file descriptors
    for the udp socket and the tcp rendezvous socket, that
    connections are balanced across all the workers if service
    times are sufficiently long, and that performance is
    improved by that parallelism, at least for small numbers
    of threads.  For example, with 60 parallel MOUNT calls
    and a testing patch to make DNS lookups take 100 milliseconds
    time to perform all mounts (averaged over 5 runs) is:
    
    num		elapsed
    threads		time (sec)
     ------		----------
    1		13.125
    2 		 6.859
    3		 4.836
    4	 	 3.841
    5		 3.303
    6		 3.100
    7		 3.078
    8		 3.018
    
    Greg.
    --
    Greg Banks, R&D Software Engineer, SGI Australian Software Group.
    I don't speak for SGI.

diff --git a/support/nfs/svc_socket.c b/support/nfs/svc_socket.c
index a3cb7ce..888c915 100644
--- a/support/nfs/svc_socket.c
+++ b/support/nfs/svc_socket.c
@@ -22,6 +22,7 @@
 #include <netdb.h>
 #include <rpc/rpc.h>
 #include <sys/socket.h>
+#include <sys/fcntl.h>
 #include <errno.h>
 
 #ifdef _LIBC
@@ -112,6 +113,26 @@ svc_socket (u_long number, int type, int protocol, int reuse)
 	}
     }
 
+  if (sock >= 0 && protocol == IPPROTO_TCP)
+    {
+	/* Make the TCP rendezvous socket non-block to avoid
+	 * problems with blocking in accept() after a spurious
+	 * wakeup from the kernel */
+	int flags;
+	if ((flags = fcntl(sock, F_GETFL)) < 0)
+	  {
+	      perror (_("svc_socket: can't get socket flags"));
+	      (void) __close (sock);
+	      sock = -1;
+	  }
+	else if (fcntl(sock, F_SETFL, flags|O_NONBLOCK) < 0)
+	  {
+	      perror (_("svc_socket: can't set socket flags"));
+	      (void) __close (sock);
+	      sock = -1;
+	  }
+    }
+
   return sock;
 }
 
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 43606dd..e402bf8 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -21,6 +21,7 @@
 #include <errno.h>
 #include <fcntl.h>
 #include <sys/resource.h>
+#include <sys/wait.h>
 #include "xmalloc.h"
 #include "misc.h"
 #include "mountd.h"
@@ -43,6 +44,13 @@ int new_cache = 0;
  * send mount or unmount requests -- the callout is not needed for 2.6 kernel */
 char *ha_callout_prog = NULL;
 
+/* Number of mountd threads to start.   Default is 1 and
+ * that's probably enough unless you need hundreds of
+ * clients to be able to mount at once.  */
+static int num_threads = 1;
+/* Arbitrary limit on number of threads */
+#define MAX_THREADS 64
+
 static struct option longopts[] =
 {
 	{ "foreground", 0, 0, 'F' },
@@ -57,24 +65,106 @@ static struct option longopts[] =
 	{ "no-tcp", 0, 0, 'n' },
 	{ "ha-callout", 1, 0, 'H' },
 	{ "state-directory-path", 1, 0, 's' },
+	{ "num-threads", 1, 0, 't' },
 	{ NULL, 0, 0, 0 }
 };
 
 static int nfs_version = -1;
 
+static void
+unregister_services (void)
+{
+	if (nfs_version & 0x1)
+		pmap_unset (MOUNTPROG, MOUNTVERS);
+	if (nfs_version & (0x1 << 1))
+		pmap_unset (MOUNTPROG, MOUNTVERS_POSIX);
+	if (nfs_version & (0x1 << 2))
+		pmap_unset (MOUNTPROG, MOUNTVERS_NFSV3);
+}
+
+/* Wait for all worker child processes to exit and reap them */
+static void
+wait_for_workers (void)
+{
+	int status;
+	pid_t pid;
+
+	for (;;) {
+
+		pid = waitpid(0, &status, 0);
+
+		if (pid < 0) {
+			if (errno == ECHILD)
+				return; /* no more children */
+			xlog(L_FATAL, "mountd: can't wait: %s\n",
+					strerror(errno));
+		}
+
+		/* Note: because we SIG_IGN'd SIGCHLD earlier, this
+		 * does not happen on 2.6 kernels, and waitpid() blocks
+		 * until all the children are dead then returns with
+		 * -ECHILD.  But, we don't need to do anything on the
+		 * death of individual workers, so we don't care. */
+		xlog(L_NOTICE, "mountd: reaped child %d, status %d\n",
+				(int)pid, status);
+	}
+}
+
+/* Fork num_threads worker children and wait for them */
+static void
+fork_workers(void)
+{
+	int i;
+	pid_t pid;
+
+	xlog(L_NOTICE, "mountd: starting %d threads\n", num_threads);
+
+	for (i = 0 ; i < num_threads ; i++) {
+		pid = fork();
+		if (pid < 0) {
+			xlog(L_FATAL, "mountd: cannot fork: %s\n",
+					strerror(errno));
+		}
+		if (pid == 0) {
+			/* worker child */
+
+			/* Re-enable the default action on SIGTERM et al
+			 * so that workers die naturally when sent them.
+			 * Only the parent unregisters with pmap and
+			 * hence needs to do special SIGTERM handling. */
+			struct sigaction sa;
+			sa.sa_handler = SIG_DFL;
+			sa.sa_flags = 0;
+			sigemptyset(&sa.sa_mask);
+			sigaction(SIGHUP, &sa, NULL);
+			sigaction(SIGINT, &sa, NULL);
+			sigaction(SIGTERM, &sa, NULL);
+
+			/* fall into my_svc_run in caller */
+			return;
+		}
+	}
+
+	/* in parent */
+	wait_for_workers();
+	unregister_services();
+	xlog(L_NOTICE, "mountd: no more workers, exiting\n");
+	exit(0);
+}
+
 /*
  * Signal handler.
  */
 static void 
 killer (int sig)
 {
-  if (nfs_version & 0x1)
-    pmap_unset (MOUNTPROG, MOUNTVERS);
-  if (nfs_version & (0x1 << 1))
-    pmap_unset (MOUNTPROG, MOUNTVERS_POSIX);
-  if (nfs_version & (0x1 << 2))
-    pmap_unset (MOUNTPROG, MOUNTVERS_NFSV3);
-  xlog (L_FATAL, "Caught signal %d, un-registering and exiting.", sig);
+	unregister_services();
+	if (num_threads > 1) {
+		/* play Kronos and eat our children */
+		kill(0, SIGTERM);
+		wait_for_workers();
+	}
+	xlog (L_FATAL, "Caught signal %d, un-registering and exiting.", sig);
 }
 
 static void
@@ -468,7 +558,7 @@ main(int argc, char **argv)
 
 	/* Parse the command line options and arguments. */
 	opterr = 0;
-	while ((c = getopt_long(argc, argv, "o:n:Fd:f:p:P:hH:N:V:vs:", longopts, NULL)) != EOF)
+	while ((c = getopt_long(argc, argv, "o:n:Fd:f:p:P:hH:N:V:vs:t:", longopts, NULL)) != EOF)
 		switch (c) {
 		case 'o':
 			descriptors = atoi(optarg);
@@ -515,6 +605,9 @@ main(int argc, char **argv)
 				exit(1);
 			}
 			break;
+		case 't':
+			num_threads = atoi (optarg);
+			break;
 		case 'V':
 			nfs_version |= 1 << (atoi (optarg) - 1);
 			break;
@@ -615,6 +708,17 @@ main(int argc, char **argv)
 		setsid();
 	}
 
+	/* silently bounds check num_threads */
+	if (foreground)
+		num_threads = 1;
+	else if (num_threads < 1)
+		num_threads = 1;
+	else if (num_threads > MAX_THREADS)
+		num_threads = MAX_THREADS;
+
+	if (num_threads > 1)
+		fork_workers();
+
 	my_svc_run();
 
 	xlog(L_ERROR, "Ack! Gack! svc_run returned!\n");
@@ -629,6 +733,7 @@ usage(const char *prog, int n)
 "	[-o num|--descriptors num] [-f exports-file|--exports-file=file]\n"
 "	[-p|--port port] [-V version|--nfs-version version]\n"
 "	[-N version|--no-nfs-version version] [-n|--no-tcp]\n"
-"	[-H ha-callout-prog] [-s|--state-directory-path path]\n", prog);
+"	[-H ha-callout-prog] [-s|--state-directory-path path]\n"
+"	[-t num|--num-threads=num]\n", prog);
 	exit(n);
 }
diff --git a/utils/mountd/mountd.man b/utils/mountd/mountd.man
index bac4421..70166c1 100644
--- a/utils/mountd/mountd.man
+++ b/utils/mountd/mountd.man
@@ -125,6 +125,13 @@ If this option is not specified the default of
 .BR /var/lib/nfs
 is used.
 .TP
+.BR "\-t N" " or " "\-\-num\-threads=N"
+This option specifies the number of worker threads that rpc.mountd
+spawns.  The default is 1 thread, which is probably enough.  More
+threads are usually only needed for NFS servers which need to handle
+mount storms of hundreds of NFS mounts in a few seconds, or when
+your DNS server is slow or unreliable.
+.TP
 .B \-V " or " \-\-nfs-version
 This option can be used to request that
 .B rpc.mountd

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
