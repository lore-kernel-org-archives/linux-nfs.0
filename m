From: NeilBrown <neilb@suse.de>
Subject: [PATCH 001 of 19] knfsd: Hide use of lockd's h_monitored flag
Date: Fri, 1 Sep 2006 14:38:08 +1000
Message-ID: <1060901043808.27427@suse.de>
References: <20060901141639.27206.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJ0nM-0005k9-K4
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:38:20 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GJ0nK-0004Ff-HD
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:38:21 -0700
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: Olaf Kirch <okir@suse.de>

  This patch moves all checks of the h_monitored flag into
  the nsm_monitor/unmonitor functions.
  A subsequent patch will replace the mechanism by which we
  mark a host as being monitored.

  There is still one occurence of h_monitored outside of
  mon.c and that is in clntlock.c where we respond to a
  reboot. The subsequent patch will modify this too.

Signed-off-by: Olaf Kirch <okir@suse.de>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/lockd/clntproc.c |    2 +-
 ./fs/lockd/host.c     |    9 ++++++---
 ./fs/lockd/mon.c      |   19 ++++++++++++-------
 ./fs/lockd/svc4proc.c |    2 +-
 ./fs/lockd/svcproc.c  |    2 +-
 5 files changed, 21 insertions(+), 13 deletions(-)

diff .prev/fs/lockd/clntproc.c ./fs/lockd/clntproc.c
--- .prev/fs/lockd/clntproc.c	2006-08-31 16:12:30.000000000 +1000
+++ ./fs/lockd/clntproc.c	2006-08-31 16:12:30.000000000 +1000
@@ -499,7 +499,7 @@ nlmclnt_lock(struct nlm_rqst *req, struc
 	unsigned char fl_flags = fl->fl_flags;
 	int status = -ENOLCK;
 
-	if (!host->h_monitored && nsm_monitor(host) < 0) {
+	if (nsm_monitor(host) < 0) {
 		printk(KERN_NOTICE "lockd: failed to monitor %s\n",
 					host->h_name);
 		goto out;

diff .prev/fs/lockd/host.c ./fs/lockd/host.c
--- .prev/fs/lockd/host.c	2006-08-31 16:12:30.000000000 +1000
+++ ./fs/lockd/host.c	2006-08-31 16:12:30.000000000 +1000
@@ -331,9 +331,12 @@ nlm_gc_hosts(void)
 			}
 			dprintk("lockd: delete host %s\n", host->h_name);
 			*q = host->h_next;
-			/* Don't unmonitor hosts that have been invalidated */
-			if (host->h_monitored && !host->h_killed)
-				nsm_unmonitor(host);
+
+			/*
+			 * Unmonitor unless host was invalidated (i.e. lockd restarted)
+			 */
+			nsm_unmonitor(host);
+
 			if ((clnt = host->h_rpcclnt) != NULL) {
 				if (atomic_read(&clnt->cl_users)) {
 					printk(KERN_WARNING

diff .prev/fs/lockd/mon.c ./fs/lockd/mon.c
--- .prev/fs/lockd/mon.c	2006-08-31 16:12:30.000000000 +1000
+++ ./fs/lockd/mon.c	2006-08-31 16:12:30.000000000 +1000
@@ -74,6 +74,8 @@ nsm_monitor(struct nlm_host *host)
 	int		status;
 
 	dprintk("lockd: nsm_monitor(%s)\n", host->h_name);
+	if (host->h_monitored)
+		return 0;
 
 	status = nsm_mon_unmon(host, SM_MON, &res);
 
@@ -91,15 +93,18 @@ int
 nsm_unmonitor(struct nlm_host *host)
 {
 	struct nsm_res	res;
-	int		status;
+	int		status = 0;
 
 	dprintk("lockd: nsm_unmonitor(%s)\n", host->h_name);
-
-	status = nsm_mon_unmon(host, SM_UNMON, &res);
-	if (status < 0)
-		printk(KERN_NOTICE "lockd: cannot unmonitor %s\n", host->h_name);
-	else
-		host->h_monitored = 0;
+	if (!host->h_monitored)
+		return 0;
+	host->h_monitored = 0;
+
+	if (!host->h_killed) {
+		status = nsm_mon_unmon(host, SM_UNMON, &res);
+		if (status < 0)
+			printk(KERN_NOTICE "lockd: cannot unmonitor %s\n", host->h_name);
+	}
 	return status;
 }
 

diff .prev/fs/lockd/svc4proc.c ./fs/lockd/svc4proc.c
--- .prev/fs/lockd/svc4proc.c	2006-08-31 16:12:30.000000000 +1000
+++ ./fs/lockd/svc4proc.c	2006-08-31 16:12:30.000000000 +1000
@@ -39,7 +39,7 @@ nlm4svc_retrieve_args(struct svc_rqst *r
 
 	/* Obtain host handle */
 	if (!(host = nlmsvc_lookup_host(rqstp))
-	 || (argp->monitor && !host->h_monitored && nsm_monitor(host) < 0))
+	 || (argp->monitor && nsm_monitor(host) < 0))
 		goto no_locks;
 	*hostp = host;
 

diff .prev/fs/lockd/svcproc.c ./fs/lockd/svcproc.c
--- .prev/fs/lockd/svcproc.c	2006-08-31 16:12:30.000000000 +1000
+++ ./fs/lockd/svcproc.c	2006-08-31 16:12:30.000000000 +1000
@@ -67,7 +67,7 @@ nlmsvc_retrieve_args(struct svc_rqst *rq
 
 	/* Obtain host handle */
 	if (!(host = nlmsvc_lookup_host(rqstp))
-	 || (argp->monitor && !host->h_monitored && nsm_monitor(host) < 0))
+	 || (argp->monitor && nsm_monitor(host) < 0))
 		goto no_locks;
 	*hostp = host;
 

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
