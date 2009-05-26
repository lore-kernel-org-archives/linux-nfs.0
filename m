From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT PULL] Please pull NFS client bugfixes
Date: Tue, 26 May 2009 15:06:27 -0400
Message-ID: <1243364787.30354.8.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>,
	Steven Whitehouse <swhiteho@redhat.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Vu Pham <vu@mellanox.com>, Tom Talpey <tmtalpey@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52465 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756482AbZEZTHw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 May 2009 15:07:52 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/nfs4proc.c           |    9 +++------
 fs/nfs/nfsroot.c            |    2 +-
 net/sunrpc/xprtrdma/verbs.c |    3 ++-
 3 files changed, 6 insertions(+), 8 deletions(-)

commit 95baa25c7321eb8613246acbf61b97911cc748d3
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue May 26 14:51:00 2009 -0400

    NFSv4: Fix the case where NFSv4 renewal fails
    
    If the asynchronous lease renewal fails (usually due to a soft timeout),
    then we _must_ schedule state recovery in order to ensure that we don't
    lose the lease unnecessarily or, if the lease is already lost, that we
    recover the locking state promptly...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d0367a508af9cf97beb202935bb9ad8883d30cd1
Author: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>
Date:   Tue May 26 14:51:00 2009 -0400

    nfs: fix build error in nfsroot with initconst
    
    fix build error with latest kbuild adjustments to initconst.
    
    The commit a447c0932445f92ce6f4c1bd020f62c5097a7842 ("vfs: Use
    const for kernel parser table") changed:
    
        static match_table_t __initdata tokens = {
    to
        static match_table_t __initconst tokens = {
    
    But the missing const causes powerpc to fail with latest
    updates to __initconst like this:
    
    fs/nfs/nfsroot.c:400: error: __setup_str_nfs_root_setup causes a section type conflict
    fs/nfs/nfsroot.c:400: error: __setup_str_nfs_root_setup causes a section type conflict
    
    The bug is only present with kbuild-next.
    Following patch has been build tested.
    
    Signed-off-by: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>
    Cc: Steven Whitehouse <swhiteho@redhat.com>
    Cc: Stephen Rothwell <sfr@canb.auug.org.au>
    Acked-by: Jan Beulich <jbeulich@novell.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 68743082b560067e3e93eab8b2568f238e486865
Author: Vu Pham <vu@mellanox.com>
Date:   Tue May 26 14:51:00 2009 -0400

    XPRTRDMA: fix client rpcrdma FRMR registration on mlx4 devices
    
    mlx4/connectX FRMR requires local write enable together with remote
    rdma write enable. This fixes NFS/RDMA operation over the ConnectX
    Infiniband HCA in the default memreg mode.
    
    Signed-off-by: Vu Pham <vu@mellanox.com>
    Signed-off-by: Tom Talpey <tmtalpey@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a4d2426..4674f80 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2594,12 +2594,9 @@ static void nfs4_renew_done(struct rpc_task *task, void *data)
 	unsigned long timestamp = (unsigned long)data;
 
 	if (task->tk_status < 0) {
-		switch (task->tk_status) {
-			case -NFS4ERR_STALE_CLIENTID:
-			case -NFS4ERR_EXPIRED:
-			case -NFS4ERR_CB_PATH_DOWN:
-				nfs4_schedule_state_recovery(clp);
-		}
+		/* Unless we're shutting down, schedule state recovery! */
+		if (test_bit(NFS_CS_RENEWD, &clp->cl_res_state) != 0)
+			nfs4_schedule_state_recovery(clp);
 		return;
 	}
 	spin_lock(&clp->cl_lock);
diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index d9ef602..e3ed590 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -129,7 +129,7 @@ enum {
 	Opt_err
 };
 
-static match_table_t __initconst tokens = {
+static const match_table_t tokens __initconst = {
 	{Opt_port, "port=%u"},
 	{Opt_rsize, "rsize=%u"},
 	{Opt_wsize, "wsize=%u"},
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 3b21e0c..465aafc 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1495,7 +1495,8 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	frmr_wr.wr.fast_reg.page_shift = PAGE_SHIFT;
 	frmr_wr.wr.fast_reg.length = i << PAGE_SHIFT;
 	frmr_wr.wr.fast_reg.access_flags = (writing ?
-				IB_ACCESS_REMOTE_WRITE : IB_ACCESS_REMOTE_READ);
+				IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE :
+				IB_ACCESS_REMOTE_READ);
 	frmr_wr.wr.fast_reg.rkey = seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
