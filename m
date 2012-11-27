Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:9732 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751729Ab2K0LJd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 06:09:33 -0500
Subject: [PATCH 2/2] nfsd: make NFSv4 grace time per net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 27 Nov 2012 14:11:49 +0300
Message-ID: <20121127111149.10271.51541.stgit@localhost.localdomain>
In-Reply-To: <20121127111007.10271.54338.stgit@localhost.localdomain>
References: <20121127111007.10271.54338.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Grace time is a part of NFSv4 state engine, which is constructed per network
namespace.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/netns.h     |    1 +
 fs/nfsd/nfs4state.c |    9 +++------
 fs/nfsd/nfsctl.c    |    4 +++-
 fs/nfsd/nfsd.h      |    2 --
 4 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 0c20be8..2c4b2e2 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -89,6 +89,7 @@ struct nfsd_net {
 	bool in_grace;
 
 	time_t nfsd4_lease;
+	time_t nfsd4_grace;
 };
 
 extern int nfsd_net_id;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 56b0ebb..36d3983 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -50,9 +50,6 @@
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
-/* Globals */
-time_t nfsd4_grace = 90;
-
 #define all_ones {{~0,~0},~0}
 static const stateid_t one_stateid = {
 	.si_generation = ~0,
@@ -3183,7 +3180,7 @@ nfsd4_end_grace(struct nfsd_net *nn)
 	 * to see the (possibly new, possibly shorter) lease time, we
 	 * can safely set the next grace time to the current lease time:
 	 */
-	nfsd4_grace = nn->nfsd4_lease;
+	nn->nfsd4_grace = nn->nfsd4_lease;
 }
 
 static time_t
@@ -4880,8 +4877,8 @@ nfs4_state_start_net(struct net *net)
 	locks_start_grace(net, &nn->nfsd4_manager);
 	nn->grace_ended = false;
 	printk(KERN_INFO "NFSD: starting %ld-second grace period (net %p)\n",
-	       nfsd4_grace, net);
-	queue_delayed_work(laundry_wq, &nn->laundromat_work, nfsd4_grace * HZ);
+	       nn->nfsd4_grace, net);
+	queue_delayed_work(laundry_wq, &nn->laundromat_work, nn->nfsd4_grace * HZ);
 	return 0;
 }
 
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 4930981..7e41bd1 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -928,7 +928,8 @@ static ssize_t write_leasetime(struct file *file, char *buf, size_t size)
  */
 static ssize_t write_gracetime(struct file *file, char *buf, size_t size)
 {
-	return nfsd4_write_time(file, buf, size, &nfsd4_grace);
+	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
+	return nfsd4_write_time(file, buf, size, &nn->nfsd4_grace);
 }
 
 static ssize_t __write_recoverydir(struct file *file, char *buf, size_t size)
@@ -1073,6 +1074,7 @@ static __net_init int nfsd_init_net(struct net *net)
 	if (retval)
 		goto out_idmap_error;
 	nn->nfsd4_lease = 90;	/* default lease time */
+	nn->nfsd4_grace = 90;
 	return 0;
 
 out_idmap_error:
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index a8f7325..5eea0f5 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -276,8 +276,6 @@ extern struct timeval	nfssvc_boot;
 
 #ifdef CONFIG_NFSD_V4
 
-extern time_t nfsd4_grace;
-
 /* before processing a COMPOUND operation, we have to check that there
  * is enough space in the buffer for XDR encode to succeed.  otherwise,
  * we might process an operation with side effects, and be unable to

