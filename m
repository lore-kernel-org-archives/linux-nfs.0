From: Chip Salzenberg <chip@pobox.com>
Subject: [PATCH] Rename log() to note() due to conflict with ISO standard
Date: Thu, 21 Aug 2003 12:18:15 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030821161815.GI14355@perlsupport.com>
References: <20030820215835.GA14355@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tandu.perlsupport.com ([66.220.6.226] ident=mail)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ptOK-0008MN-00
	for <nfs@lists.sourceforge.net>; Thu, 21 Aug 2003 10:38:32 -0700
Received: from tytlal.hmsonline.com
	([207.43.94.202] helo=tytlal ident=mail)
	by tandu.perlsupport.com with asmtp (Exim 3.35 #1 (Debian))
	id 19ps8G-0001Bi-00
	for <nfs@lists.sourceforge.net>; Thu, 21 Aug 2003 09:17:52 -0700
Received: from chip by tytlal with local (Exim 3.35 #1 (Debian))
	id 19ps8d-0002sO-00
	for <nfs@lists.sourceforge.net>; Thu, 21 Aug 2003 12:18:15 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <20030820215835.GA14355@perlsupport.com>
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

As I wrote before:
> ISO C reserves the names of standard functions.  It's not legal to
> define a function called log(), and even though gcc happens to permit
> it, the permission comes only with obnoxious warnings.

So this is a patch to rename log() to note().  I'm not totally fond of
the name note(); and if we keep it I'll also rename the L_ constants to
N_ for consistency.  Comments?

Index: callback.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/statd/callback.c,v
retrieving revision 1.2
diff -u -2 -r1.2 callback.c
--- callback.c	24 Oct 2000 14:30:34 -0000	1.2
+++ callback.c	21 Aug 2003 16:14:26 -0000
@@ -34,5 +34,5 @@
 	 * we'd never pass this point. */
 	if (!(lp = rtnl)) {
-		log(L_WARNING, "SM_NOTIFY from %s while not monitoring any hosts.",
+		note(L_WARNING, "SM_NOTIFY from %s while not monitoring any hosts.",
 				argp->mon_name, argp->state);
 		return ((void *) &result);
Index: log.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/statd/log.c,v
retrieving revision 1.6
diff -u -2 -r1.6 log.c
--- log.c	4 Jul 2003 04:22:25 -0000	1.6
+++ log.c	21 Aug 2003 16:14:26 -0000
@@ -37,5 +37,5 @@
 	mypid = getpid();
 
-	log(L_WARNING,"Version %s Starting",version_p);
+	note(L_WARNING,"Version %s Starting",version_p);
 }
 
@@ -55,5 +55,5 @@
 	buffer[1023]=0;
 
-	log(L_FATAL, "%s", buffer);
+	note(L_FATAL, "%s", buffer);
 
 #ifndef DEBUG
@@ -64,5 +64,5 @@
 }
 
-void log(int level, char *fmt, ...)
+void note(int level, char *fmt, ...)
 {
 	char	buffer[1024];
Index: log.h
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/statd/log.h,v
retrieving revision 1.2
diff -u -2 -r1.2 log.h
--- log.h	5 Oct 2000 19:14:27 -0000	1.2
+++ log.h	21 Aug 2003 16:14:26 -0000
@@ -21,5 +21,5 @@
 void	log_enable(int facility);
 int	log_enabled(int facility);
-void	log(int level, char *fmt, ...);
+void	note(int level, char *fmt, ...);
 void	die(char *fmt, ...);
 
@@ -35,7 +35,7 @@
 
 #ifdef DEBUG
-#define dprintf		log
+#define dprintf		note
 #else
-#define dprintf		if (run_mode & MODE_LOG_STDERR) log
+#define dprintf		if (run_mode & MODE_LOG_STDERR) note
 #endif
 
Index: misc.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/statd/misc.c,v
retrieving revision 1.2
diff -u -2 -r1.2 misc.c
--- misc.c	5 Jul 2000 00:16:58 -0000	1.2
+++ misc.c	21 Aug 2003 16:14:26 -0000
@@ -65,5 +65,5 @@
   if (!check || !nlist_gethost(rtnl, host, 0)) {
     if (unlink (tozap) == -1)
-      log (L_ERROR, "unlink (%s): %s", tozap, strerror (errno));
+      note (L_ERROR, "unlink (%s): %s", tozap, strerror (errno));
     else
       dprintf (L_DEBUG, "Unlinked %s", tozap);
Index: monitor.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/statd/monitor.c,v
retrieving revision 1.4
diff -u -2 -r1.4 monitor.c
--- monitor.c	2 Sep 2002 02:16:01 -0000	1.4
+++ monitor.c	21 Aug 2003 16:14:26 -0000
@@ -59,5 +59,5 @@
 	caller = svc_getcaller(rqstp->rq_xprt)->sin_addr;
 	if (caller.s_addr != htonl(INADDR_LOOPBACK)) {
-		log(L_WARNING,
+		note(L_WARNING,
 			"Call to statd from non-local host %s",
 			inet_ntoa(caller));
@@ -78,5 +78,5 @@
 	    (id->my_proc != 16 && id->my_proc != 24))
 	{
-		log(L_WARNING,
+		note(L_WARNING,
 			"Attempt to register callback to %d/%d",
 			id->my_prog, id->my_proc);
@@ -88,5 +88,5 @@
 	 */
 	if (!inet_aton(mon_name, &mon_addr)) {
-		log(L_WARNING,
+		note(L_WARNING,
 			"Attempt to register host %s (not a dotted quad)",
 			mon_name);
@@ -101,13 +101,13 @@
 	/* must check for /'s in hostname!  See CERT's CA-96.09 for details. */
 	if (strchr(mon_name, '/')) {
-		log(L_CRIT, "SM_MON request for hostname containing '/': %s",
+		note(L_CRIT, "SM_MON request for hostname containing '/': %s",
 			mon_name);
-		log(L_CRIT, "POSSIBLE SPOOF/ATTACK ATTEMPT!");
+		note(L_CRIT, "POSSIBLE SPOOF/ATTACK ATTEMPT!");
 		goto failure;
 	} else if (gethostbyname(mon_name) == NULL) {
-		log(L_WARNING, "gethostbyname error for %s", mon_name);
+		note(L_WARNING, "gethostbyname error for %s", mon_name);
 		goto failure;
 	} else if (!(hostinfo = gethostbyname(my_name))) {
-		log(L_WARNING, "gethostbyname error for %s", my_name);
+		note(L_WARNING, "gethostbyname error for %s", my_name);
 		goto failure;
 	} else
@@ -154,5 +154,5 @@
 	 */
 	if (!(clnt = nlist_new(my_name, mon_name, 0))) {
-		log(L_WARNING, "out of memory");
+		note(L_WARNING, "out of memory");
 		goto failure;
 	}
@@ -172,5 +172,5 @@
 	if ((fd = open(path, O_WRONLY|O_SYNC|O_CREAT, S_IRUSR|S_IWUSR)) < 0) {
 		/* Didn't fly.  We won't monitor. */
-		log(L_ERROR, "creat(%s) failed: %m", path);
+		note(L_ERROR, "creat(%s) failed: %m", path);
 		nlist_free(NULL, clnt);
 		free(path);
@@ -187,5 +187,5 @@
 
 failure:
-	log(L_WARNING, "STAT_FAIL to %s for SM_MON of %s", my_name, mon_name);
+	note(L_WARNING, "STAT_FAIL to %s for SM_MON of %s", my_name, mon_name);
 	return (&result);
 }
@@ -213,5 +213,5 @@
 	/* Check if we're monitoring anyone. */
 	if (!(clnt = rtnl)) {
-		log(L_WARNING,
+		note(L_WARNING,
 			"Received SM_UNMON request from %s for %s while not "
 			"monitoring any hosts.", my_name, argp->mon_name);
@@ -241,5 +241,5 @@
 	}
 
-	log(L_WARNING, "Received erroneous SM_UNMON request from %s for %s",
+	note(L_WARNING, "Received erroneous SM_UNMON request from %s for %s",
 		my_name, mon_name);
 	return (&result);
@@ -257,5 +257,5 @@
 
 	if (!(clnt = rtnl)) {
-		log(L_WARNING, "Received SM_UNMON_ALL request from %s "
+		note(L_WARNING, "Received SM_UNMON_ALL request from %s "
 			"while not monitoring any hosts", argp->my_name);
 		return (&result);
Index: notify.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/statd/notify.c,v
retrieving revision 1.2
diff -u -2 -r1.2 notify.c
--- notify.c	2 Sep 2002 02:16:01 -0000	1.2
+++ notify.c	21 Aug 2003 16:14:26 -0000
@@ -58,5 +58,5 @@
 			sprintf(fname, "%s/%s",  SM_BAK_DIR, de->d_name);
 			if (unlink(fname)) 
-				log(L_ERROR, "unlink(%s): %s", 
+				note(L_ERROR, "unlink(%s): %s", 
 					fname, strerror(errno));
 			free(fname);
Index: rmtcall.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/statd/rmtcall.c,v
retrieving revision 1.7
diff -u -2 -r1.7 rmtcall.c
--- rmtcall.c	21 Mar 2001 19:21:08 -0000	1.7
+++ rmtcall.c	21 Aug 2003 16:14:26 -0000
@@ -57,5 +57,5 @@
 
 	if ((sockfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
-		log(L_CRIT, "Can't create socket: %m");
+		note(L_CRIT, "Can't create socket: %m");
 		return -1;
 	}
@@ -91,5 +91,5 @@
 		hname = NL_MY_NAME(lp);
 	if (!inet_aton(hname, &(NL_ADDR(lp)))) {
-		log(L_ERROR, "%s is not an dotted-quad address", hname);
+		note(L_ERROR, "%s is not an dotted-quad address", hname);
 		NL_TIMES(lp) = 0;
 		return 0;
@@ -122,5 +122,5 @@
 
 	if (hp->h_addrtype != AF_INET) {
-		log(L_ERROR, "%s is not an AF_INET address", hname);
+		note(L_ERROR, "%s is not an AF_INET address", hname);
 		NL_TIMES(lp) = 0;
 		return 0;
@@ -226,10 +226,10 @@
 
 	if (!xdr_replymsg(xdrs, &mesg)) {
-		log(L_WARNING, "recv_rply: can't decode RPC message!\n");
+		note(L_WARNING, "recv_rply: can't decode RPC message!\n");
 		goto done;
 	}
 
 	if (mesg.rm_reply.rp_stat != 0) {
-		log(L_WARNING, "recv_rply: [%s] RPC status %d\n", 
+		note(L_WARNING, "recv_rply: [%s] RPC status %d\n", 
 				inet_ntoa(sin->sin_addr),
 				mesg.rm_reply.rp_stat);
@@ -237,5 +237,5 @@
 	}
 	if (mesg.rm_reply.rp_acpt.ar_stat != 0) {
-		log(L_WARNING, "recv_rply: [%s] RPC status %d\n",
+		note(L_WARNING, "recv_rply: [%s] RPC status %d\n",
 				inet_ntoa(sin->sin_addr),
 				mesg.rm_reply.rp_acpt.ar_stat);
@@ -260,5 +260,5 @@
 		if (lp->port == 0) {
 			if (!xdr_u_long(xdrs, portp)) {
-				log(L_WARNING, "recv_rply: [%s] "
+				note(L_WARNING, "recv_rply: [%s] "
 					"can't decode reply body!\n",
 					inet_ntoa(sin->sin_addr));
@@ -291,5 +291,5 @@
 		return NL_TIMES(lp);
 	if (NL_TIMES(lp) == 0) {
-		log(L_DEBUG, "Cannot notify %s, giving up.\n",
+		note(L_DEBUG, "Cannot notify %s, giving up.\n",
 					inet_ntoa(NL_ADDR(lp)));
 		return 0;
@@ -329,5 +329,5 @@
 		break;
 	default:
-		log(L_ERROR, "notify_host: unknown notify type %d",
+		note(L_ERROR, "notify_host: unknown notify type %d",
 				NL_TYPE(lp));
 		return 0;
@@ -336,5 +336,5 @@
 	lp->xid = xmit_call(sockfd, &sin, prog, vers, proc, func, objp);
 	if (!lp->xid) {
-		log(L_WARNING, "notify_host: failed to notify %s\n",
+		note(L_WARNING, "notify_host: failed to notify %s\n",
 				inet_ntoa(lp->addr));
 	}
@@ -369,5 +369,5 @@
 			return 1;
 		}
-		log(L_WARNING, "recv_rply: [%s] service %d not registered",
+		note(L_WARNING, "recv_rply: [%s] service %d not registered",
 			inet_ntoa(lp->addr),
 			NL_TYPE(lp) == NOTIFY_REBOOT? SM_PROG : NL_MY_PROG(lp));
@@ -405,5 +405,5 @@
 			nlist_insert_timer(&notify, entry);
 		} else if (NL_TYPE(entry) == NOTIFY_CALLBACK) {
-			log(L_ERROR,
+			note(L_ERROR,
 				"Can't callback %s (%d,%d), giving up.",
 					NL_MY_NAME(entry),
@@ -412,5 +412,5 @@
 			nlist_free(&notify, entry);
 		} else {
-			log(L_ERROR,
+			note(L_ERROR,
 				"Can't notify %s, giving up.",
 					NL_MON_NAME(entry));
Index: simu.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/statd/simu.c,v
retrieving revision 1.1.1.1
diff -u -2 -r1.1.1.1 simu.c
--- simu.c	18 Oct 1999 23:21:12 -0000	1.1.1.1
+++ simu.c	21 Aug 2003 16:14:26 -0000
@@ -20,5 +20,5 @@
   static char *result = NULL;
 
-  log (L_WARNING, "*** SIMULATING CRASH! ***");
+  note (L_WARNING, "*** SIMULATING CRASH! ***");
   my_svc_exit ();
 
Index: simulate.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/statd/simulate.c,v
retrieving revision 1.4
diff -u -2 -r1.4 simulate.c
--- simulate.c	21 Mar 2001 19:21:08 -0000	1.4
+++ simulate.c	21 Aug 2003 16:14:26 -0000
@@ -93,5 +93,5 @@
 
   if (result->res_stat != STAT_SUCC) {
-    log (L_FATAL, "SM_MON request failed, state: %d", result->state);
+    note (L_FATAL, "SM_MON request failed, state: %d", result->state);
     exit (0);
   } else {
@@ -197,5 +197,5 @@
 sim_killer (int sig)
 {
-  log (L_FATAL, "Simulator caught signal %d, un-registering and exiting.", sig);
+  note (L_FATAL, "Simulator caught signal %d, un-registering and exiting.", sig);
   pmap_unset (sim_port, SIM_SM_VERS);
   exit (0);
Index: stat.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/statd/stat.c,v
retrieving revision 1.1.1.1
diff -u -2 -r1.1.1.1 stat.c
--- stat.c	18 Oct 1999 23:21:12 -0000	1.1.1.1
+++ stat.c	21 Aug 2003 16:14:26 -0000
@@ -26,5 +26,5 @@
 
   if (gethostbyname (argp->mon_name) == NULL) {
-    log (L_WARNING, "gethostbyname error for %s", argp->mon_name);
+    note (L_WARNING, "gethostbyname error for %s", argp->mon_name);
     result.res_stat = STAT_FAIL;
     dprintf (L_DEBUG, "STAT_FAIL for %s", argp->mon_name);
Index: statd.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/statd/statd.c,v
retrieving revision 1.14
diff -u -2 -r1.14 statd.c
--- statd.c	4 Jul 2003 04:22:25 -0000	1.14
+++ statd.c	21 Aug 2003 16:14:26 -0000
@@ -95,5 +95,5 @@
 killer (int sig)
 {
-	log (L_FATAL, "Caught signal %d, un-registering and exiting.", sig);
+	note (L_FATAL, "Caught signal %d, un-registering and exiting.", sig);
 	if (!(run_mode & MODE_NOTIFY_ONLY))
 		pmap_unset (SM_PROG, SM_VERS);
@@ -123,5 +123,5 @@
 		strcat(buf,"Notify-Only ");
 	}
-	log(L_WARNING,buf);
+	note(L_WARNING,buf);
 	/* future: IP aliasing
 	if (run_mode & MODE_NOTIFY_ONLY)
@@ -165,5 +165,5 @@
 	pidfd = dup(fileno(fp));
 	if (fclose(fp) < 0)
-		log(L_WARNING, "Flushing pid file failed.\n");
+		note(L_WARNING, "Flushing pid file failed.\n");
 }
 
@@ -183,5 +183,5 @@
 
 	if (st.st_uid == 0) {
-		log(L_WARNING, "statd running as root. chown %s to choose different user\n",
+		note(L_WARNING, "statd running as root. chown %s to choose different user\n",
 		    SM_DIR);
 		return;
@@ -196,5 +196,5 @@
 	if (setgid(st.st_gid) == -1
 	    || setuid(st.st_uid) == -1) {
-		log(L_ERROR, "Fail to drop privileges");
+		note(L_ERROR, "Fail to drop privileges");
 		exit(1);
 	}
Index: state.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/statd/state.c,v
retrieving revision 1.2
diff -u -2 -r1.2 state.c
--- state.c	17 Aug 2001 16:12:08 -0000	1.2
+++ state.c	21 Aug 2003 16:14:26 -0000
@@ -35,5 +35,5 @@
 
   if (size != 0 && size != sizeof MY_STATE) {
-    log (L_ERROR, "Error in status file format...correcting.");
+    note (L_ERROR, "Error in status file format...correcting.");
 
     if (close (fd) == -1)
@@ -43,5 +43,5 @@
       die ("creat (%s): %s", SM_STAT_PATH, strerror (errno));
   }
-  log (L_DEBUG, "New state: %u", (++MY_STATE % 2) ? MY_STATE : ++MY_STATE);
+  note (L_DEBUG, "New state: %u", (++MY_STATE % 2) ? MY_STATE : ++MY_STATE);
 
   if (lseek (fd, 0, SEEK_SET) == -1)
@@ -52,8 +52,8 @@
 
   if (fsync (fd) == -1)
-    log (L_ERROR, "fsync (%s): %s", SM_STAT_PATH, strerror (errno));
+    note (L_ERROR, "fsync (%s): %s", SM_STAT_PATH, strerror (errno));
 
   if (close (fd) == -1)
-    log (L_ERROR, "close (%s): %s", SM_STAT_PATH, strerror (errno));
+    note (L_ERROR, "close (%s): %s", SM_STAT_PATH, strerror (errno));
 
   if (MY_NAME == NULL) {
@@ -65,5 +65,5 @@
 
     if ((hostinfo = gethostbyname (fullhost)) == NULL)
-      log (L_ERROR, "gethostbyname error for %s", fullhost);
+      note (L_ERROR, "gethostbyname error for %s", fullhost);
     else {
       strncpy (fullhost, hostinfo->h_name, sizeof (fullhost) - 1);
@@ -123,4 +123,4 @@
   }
   if (closedir (nld) == -1)
-    log (L_ERROR, "closedir (%s): %s", SM_DIR, strerror (errno));
+    note (L_ERROR, "closedir (%s): %s", SM_DIR, strerror (errno));
 }
Index: svc_run.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/statd/svc_run.c,v
retrieving revision 1.2
diff -u -2 -r1.2 svc_run.c
--- svc_run.c	15 Feb 2001 01:03:04 -0000	1.2
+++ svc_run.c	21 Aug 2003 16:14:26 -0000
@@ -114,5 +114,5 @@
 			 || errno == ENETUNREACH || errno == EHOSTUNREACH)
 				continue;
-			log(L_ERROR, "my_svc_run() - select: %m");
+			note(L_ERROR, "my_svc_run() - select: %m");
 			return;
 


-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
