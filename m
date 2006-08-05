From: Olaf Kirch <okir@suse.de>
Subject: [PATCH 1/22] lockd: make NLM_HOST_MAX tunable
Date: Sat, 5 Aug 2006 15:06:47 +0200
Message-ID: <20060805130647.GA8016@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9Lrf-00078G-7g
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:51 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G9Lre-0000Sv-PG
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:51 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id C1DE11FFB5
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
Subject: lockd: make NLM_HOST_MAX tunable
Patch-mainline: not-yet

  This patch makes NLM_HOST_MAX tunable, and exports the
  new variable as a sysctl.
  The old value (64 clients) just wasn't adequate anymore.

Signed-off-by: Olaf Kirch <okir@suse.de>

 fs/lockd/host.c             |    7 +++----
 fs/lockd/svc.c              |   10 ++++++++++
 include/linux/lockd/lockd.h |    1 +
 3 files changed, 14 insertions(+), 4 deletions(-)

Index: build/fs/lockd/svc.c
===================================================================
--- build.orig/fs/lockd/svc.c
+++ build/fs/lockd/svc.c
@@ -59,6 +59,7 @@ static DECLARE_WAIT_QUEUE_HEAD(lockd_exi
 static unsigned long		nlm_grace_period;
 static unsigned long		nlm_timeout = LOCKD_DFLT_TIMEO;
 static int			nlm_udpport, nlm_tcpport;
+int				nlm_max_hosts = 256;
 
 /*
  * Constants needed for the sysctl interface.
@@ -367,6 +368,15 @@ static ctl_table nlm_sysctls[] = {
 		.extra1		= (int *) &nlm_port_min,
 		.extra2		= (int *) &nlm_port_max,
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nlm_max_hosts",
+		.data		= &nlm_max_hosts,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+
 	{ .ctl_name = 0 }
 };
 
Index: build/include/linux/lockd/lockd.h
===================================================================
--- build.orig/include/linux/lockd/lockd.h
+++ build/include/linux/lockd/lockd.h
@@ -144,6 +144,7 @@ extern struct svc_procedure	nlmsvc_proce
 #endif
 extern int			nlmsvc_grace_period;
 extern unsigned long		nlmsvc_timeout;
+extern int			nlm_max_hosts;
 
 /*
  * Lockd client functions
Index: build/fs/lockd/host.c
===================================================================
--- build.orig/fs/lockd/host.c
+++ build/fs/lockd/host.c
@@ -20,12 +20,11 @@
 
 
 #define NLMDBG_FACILITY		NLMDBG_HOSTCACHE
-#define NLM_HOST_MAX		64
 #define NLM_HOST_NRHASH		32
 #define NLM_ADDRHASH(addr)	(ntohl(addr) & (NLM_HOST_NRHASH-1))
 #define NLM_HOST_REBIND		(60 * HZ)
-#define NLM_HOST_EXPIRE		((nrhosts > NLM_HOST_MAX)? 300 * HZ : 120 * HZ)
-#define NLM_HOST_COLLECT	((nrhosts > NLM_HOST_MAX)? 120 * HZ :  60 * HZ)
+#define NLM_HOST_EXPIRE		((nrhosts > nlm_max_hosts)? 300 * HZ : 120 * HZ)
+#define NLM_HOST_COLLECT	((nrhosts > nlm_max_hosts)? 120 * HZ :  60 * HZ)
 #define NLM_HOST_ADDR(sv)	(&(sv)->s_nlmclnt->cl_xprt->addr)
 
 static struct nlm_host *	nlm_hosts[NLM_HOST_NRHASH];
@@ -128,7 +127,7 @@ nlm_lookup_host(int server, struct socka
 	INIT_LIST_HEAD(&host->h_granted);
 	INIT_LIST_HEAD(&host->h_reclaim);
 
-	if (++nrhosts > NLM_HOST_MAX)
+	if (++nrhosts > nlm_max_hosts)
 		next_gc = 0;
 
 nohost:

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
