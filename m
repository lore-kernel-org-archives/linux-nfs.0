From: Olaf Kirch <okir@suse.de>
Subject: [PATCH 21/22] [lockd] Make statd support switchable
Date: Sat, 5 Aug 2006 15:06:49 +0200
Message-ID: <20060805130649.GA8123@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9Lri-00079N-CT
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:54 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G9Lri-0000UQ-3z
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:54 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 5716C1FFDF
	for <nfs@lists.sourceforge.net>; Sat,  5 Aug 2006 15:06:49 +0200 (CEST)
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
Subject: [lockd] Make statd support switchable

 This patch adds some plumbing that allows to use different
 methods for nsm_monitor and nsm_unmonitor.

Signed-off-by: Olaf Kirch <okir@suse.de>

 fs/lockd/host.c                |    7 +++++++
 fs/lockd/mon.c                 |   17 +++++++++++++++--
 fs/lockd/svc.c                 |    6 ++++++
 include/linux/lockd/sm_inter.h |    5 +++--
 4 files changed, 31 insertions(+), 4 deletions(-)

Index: build/fs/lockd/host.c
===================================================================
--- build.orig/fs/lockd/host.c
+++ build/fs/lockd/host.c
@@ -32,6 +32,13 @@ static unsigned long		next_gc;
 static int			nrhosts;
 static DEFINE_MUTEX(nlm_host_mutex);
 
+/*
+ * Function pointers - will reference either the
+ * "standard" statd functions that do upcalls to user land,
+ * or the kernel statd functions.
+ */
+int				(*nsm_monitor)(struct nlm_host *);
+int				(*nsm_unmonitor)(struct nlm_host *);
 
 static void			nlm_gc_hosts(void);
 static struct nsm_handle *	__nsm_find(const struct sockaddr_in *,
Index: build/fs/lockd/mon.c
===================================================================
--- build.orig/fs/lockd/mon.c
+++ build/fs/lockd/mon.c
@@ -18,6 +18,8 @@
 #define NLMDBG_FACILITY		NLMDBG_MONITOR
 
 static struct rpc_clnt *	nsm_create(void);
+static int			__nsm_monitor(struct nlm_host *);
+static int			__nsm_unmonitor(struct nlm_host *);
 
 static struct rpc_program	nsm_program;
 
@@ -27,6 +29,17 @@ static struct rpc_program	nsm_program;
 int				nsm_local_state;
 
 /*
+ * Initialize lockd for RPC statd upcalls
+ */
+void
+nsm_statd_upcalls_init()
+{
+	nsm_monitor = __nsm_monitor;
+	nsm_unmonitor = __nsm_unmonitor;
+}
+
+
+/*
  * Common procedure for SM_MON/SM_UNMON calls
  */
 static int
@@ -69,7 +82,7 @@ nsm_mon_unmon(struct nsm_handle *nsm, u3
  * Set up monitoring of a remote host
  */
 int
-nsm_monitor(struct nlm_host *host)
+__nsm_monitor(struct nlm_host *host)
 {
 	struct nsm_handle *nsm = host->h_nsmhandle;
 	struct nsm_res	res;
@@ -94,7 +107,7 @@ nsm_monitor(struct nlm_host *host)
  * Cease to monitor remote host
  */
 int
-nsm_unmonitor(struct nlm_host *host)
+__nsm_unmonitor(struct nlm_host *host)
 {
 	struct nsm_handle *nsm = host->h_nsmhandle;
 	struct nsm_res	res;
Index: build/fs/lockd/svc.c
===================================================================
--- build.orig/fs/lockd/svc.c
+++ build/fs/lockd/svc.c
@@ -119,6 +119,9 @@ lockd(struct svc_rqst *rqstp)
 
 	daemonize("lockd");
 
+	/* Initialize the statd upcalls to rpc.statd */
+	nsm_statd_upcalls_init();
+
 	/* Process request with signals blocked, but allow SIGKILL.  */
 	allow_signal(SIGKILL);
 
@@ -472,6 +475,9 @@ static int __init init_nlm(void)
 {
 	struct ctl_path ctl_path[] = { { CTL_FS, "fs", 0555 }, { -2, "nfs", 0555 }, { 0 } };
 
+	/* Default NSM to making upcalls to statd. */
+	nsm_statd_upcalls_init();
+
 	nlm_sysctl_table = register_sysctl_table_path(nlm_sysctls, ctl_path);
 	return 0;
 }
Index: build/include/linux/lockd/sm_inter.h
===================================================================
--- build.orig/include/linux/lockd/sm_inter.h
+++ build/include/linux/lockd/sm_inter.h
@@ -40,8 +40,9 @@ struct nsm_res {
 	u32		state;
 };
 
-int		nsm_monitor(struct nlm_host *);
-int		nsm_unmonitor(struct nlm_host *);
+extern void	nsm_statd_upcalls_init(void);
+extern int	(*nsm_monitor)(struct nlm_host *);
+extern int	(*nsm_unmonitor)(struct nlm_host *);
 extern int	nsm_local_state;
 
 #endif /* LINUX_LOCKD_SM_INTER_H */

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
