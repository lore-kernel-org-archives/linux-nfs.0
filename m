From: Olaf Kirch <okir@suse.de>
Subject: [PATCH 2/22] Hide use of lockd's h_monitored flag
Date: Sat, 5 Aug 2006 15:06:47 +0200
Message-ID: <20060805130647.GA8024@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9Lrf-00078A-1T
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:51 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G9Lre-0000Su-PN
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:51 -0700
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id DAD101FFB7
	for <nfs@lists.sourceforge.net>; Sat,  5 Aug 2006 15:06:47 +0200 (CEST)
To: nfs@lists.sourceforge.net
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
Subject: Hide use of lockd's h_monitored flag

  This patch moves all checks of the h_monitored flag into
  the nsm_monitor/unmonitor functions.
  A subsequent patch will replace the mechanism by which we
  mark a host as being monitored.

Signed-off-by: Olaf Kirch <okir@suse.de>

 fs/lockd/clntproc.c |    2 +-
 fs/lockd/host.c     |    9 ++++++---
 fs/lockd/mon.c      |   19 ++++++++++++-------
 fs/lockd/svc4proc.c |    2 +-
 fs/lockd/svcproc.c  |    2 +-
 5 files changed, 21 insertions(+), 13 deletions(-)

Index: build/fs/lockd/clntproc.c
===================================================================
--- build.orig/fs/lockd/clntproc.c
+++ build/fs/lockd/clntproc.c
@@ -499,7 +499,7 @@ nlmclnt_lock(struct nlm_rqst *req, struc
 	unsigned char fl_flags = fl->fl_flags;
 	int status = -ENOLCK;
 
-	if (!host->h_monitored && nsm_monitor(host) < 0) {
+	if (nsm_monitor(host) < 0) {
 		printk(KERN_NOTICE "lockd: failed to monitor %s\n",
 					host->h_name);
 		goto out;
Index: build/fs/lockd/host.c
===================================================================
--- build.orig/fs/lockd/host.c
+++ build/fs/lockd/host.c
@@ -327,9 +327,12 @@ nlm_gc_hosts(void)
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
Index: build/fs/lockd/mon.c
===================================================================
--- build.orig/fs/lockd/mon.c
+++ build/fs/lockd/mon.c
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
 
Index: build/fs/lockd/svc4proc.c
===================================================================
--- build.orig/fs/lockd/svc4proc.c
+++ build/fs/lockd/svc4proc.c
@@ -39,7 +39,7 @@ nlm4svc_retrieve_args(struct svc_rqst *r
 
 	/* Obtain host handle */
 	if (!(host = nlmsvc_lookup_host(rqstp))
-	 || (argp->monitor && !host->h_monitored && nsm_monitor(host) < 0))
+	 || (argp->monitor && nsm_monitor(host) < 0))
 		goto no_locks;
 	*hostp = host;
 
Index: build/fs/lockd/svcproc.c
===================================================================
--- build.orig/fs/lockd/svcproc.c
+++ build/fs/lockd/svcproc.c
@@ -67,7 +67,7 @@ nlmsvc_retrieve_args(struct svc_rqst *rq
 
 	/* Obtain host handle */
 	if (!(host = nlmsvc_lookup_host(rqstp))
-	 || (argp->monitor && !host->h_monitored && nsm_monitor(host) < 0))
+	 || (argp->monitor && nsm_monitor(host) < 0))
 		goto no_locks;
 	*hostp = host;
 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
