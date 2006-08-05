From: Olaf Kirch <okir@suse.de>
Subject: [PATCH 18/22] Export nsm_local_state to user space via sysctl
Date: Sat, 5 Aug 2006 15:06:48 +0200
Message-ID: <20060805130648.GA8107@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9Lrh-000794-KZ
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:53 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G9Lrh-0000U5-FN
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:54 -0700
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 2DC78101B2
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
Subject: Export nsm_local_state to user space via sysctl

  Every NLM call includes the client's NSM state. Currently,
  the Linux client always reports 0 - which seems not to cause
  any problems, but is not what the protocol says.

  This patch exposes the kernel's internal variable to user
  space via a sysctl, which can be set at system boot time
  by statd.

Signed-off-by: Olaf Kirch <okir@suse.de>


 fs/lockd/mon.c                 |    2 +-
 fs/lockd/svc.c                 |    9 +++++++++
 include/linux/lockd/sm_inter.h |    2 +-
 3 files changed, 11 insertions(+), 2 deletions(-)

Index: build/fs/lockd/mon.c
===================================================================
--- build.orig/fs/lockd/mon.c
+++ build/fs/lockd/mon.c
@@ -24,7 +24,7 @@ static struct rpc_program	nsm_program;
 /*
  * Local NSM state
  */
-u32				nsm_local_state;
+int				nsm_local_state;
 
 /*
  * Common procedure for SM_MON/SM_UNMON calls
Index: build/fs/lockd/svc.c
===================================================================
--- build.orig/fs/lockd/svc.c
+++ build/fs/lockd/svc.c
@@ -32,6 +32,7 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svcsock.h>
 #include <linux/lockd/lockd.h>
+#include <linux/lockd/sm_inter.h>
 #include <linux/nfs.h>
 
 #define NLMDBG_FACILITY		NLMDBG_SVC
@@ -385,6 +386,14 @@ static ctl_table nlm_sysctls[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nsm_local_state",
+		.data		= &nsm_local_state,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 
 	{ .ctl_name = 0 }
 };
Index: build/include/linux/lockd/sm_inter.h
===================================================================
--- build.orig/include/linux/lockd/sm_inter.h
+++ build/include/linux/lockd/sm_inter.h
@@ -42,6 +42,6 @@ struct nsm_res {
 
 int		nsm_monitor(struct nlm_host *);
 int		nsm_unmonitor(struct nlm_host *);
-extern u32	nsm_local_state;
+extern int	nsm_local_state;
 
 #endif /* LINUX_LOCKD_SM_INTER_H */

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
