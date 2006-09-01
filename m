From: NeilBrown <neilb@suse.de>
Subject: [PATCH 017 of 19] knfsd: Export nsm_local_state to user space
	via sysctl
Date: Fri, 1 Sep 2006 14:39:38 +1000
Message-ID: <1060901043938.27653@suse.de>
References: <20060901141639.27206.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJ0ol-0005w2-EN
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:39:47 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GJ0ok-0001XS-BD
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:39:48 -0700
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

  Every NLM call includes the client's NSM state. Currently,
  the Linux client always reports 0 - which seems not to cause
  any problems, but is not what the protocol says.

  This patch exposes the kernel's internal variable to user
  space via a sysctl, which can be set at system boot time
  by statd.

Signed-off-by: Olaf Kirch <okir@suse.de>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/lockd/mon.c                 |    2 +-
 ./fs/lockd/svc.c                 |    9 +++++++++
 ./include/linux/lockd/sm_inter.h |    2 +-
 3 files changed, 11 insertions(+), 2 deletions(-)

diff .prev/fs/lockd/mon.c ./fs/lockd/mon.c
--- .prev/fs/lockd/mon.c	2006-09-01 12:11:16.000000000 +1000
+++ ./fs/lockd/mon.c	2006-09-01 12:17:47.000000000 +1000
@@ -24,7 +24,7 @@ static struct rpc_program	nsm_program;
 /*
  * Local NSM state
  */
-u32				nsm_local_state;
+int				nsm_local_state;
 
 /*
  * Common procedure for SM_MON/SM_UNMON calls

diff .prev/fs/lockd/svc.c ./fs/lockd/svc.c
--- .prev/fs/lockd/svc.c	2006-09-01 12:15:24.000000000 +1000
+++ ./fs/lockd/svc.c	2006-09-01 12:19:26.000000000 +1000
@@ -33,6 +33,7 @@
 #include <linux/sunrpc/svcsock.h>
 #include <net/ip.h>
 #include <linux/lockd/lockd.h>
+#include <linux/lockd/sm_inter.h>
 #include <linux/nfs.h>
 
 #define NLMDBG_FACILITY		NLMDBG_SVC
@@ -404,6 +405,14 @@ static ctl_table nlm_sysctls[] = {
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
 

diff .prev/include/linux/lockd/sm_inter.h ./include/linux/lockd/sm_inter.h
--- .prev/include/linux/lockd/sm_inter.h	2006-09-01 12:11:16.000000000 +1000
+++ ./include/linux/lockd/sm_inter.h	2006-09-01 12:17:47.000000000 +1000
@@ -42,6 +42,6 @@ struct nsm_res {
 
 int		nsm_monitor(struct nlm_host *);
 int		nsm_unmonitor(struct nlm_host *);
-extern u32	nsm_local_state;
+extern int	nsm_local_state;
 
 #endif /* LINUX_LOCKD_SM_INTER_H */

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
