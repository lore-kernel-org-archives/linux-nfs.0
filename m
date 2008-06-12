From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 15/15] NFSv4: Remove BKL from the nfsv4 state recovery
Date: Thu, 12 Jun 2008 15:28:18 -0400
Message-ID: <20080612192818.24916.76372.stgit@localhost.localdomain>
References: <20080612192817.24916.52065.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11707 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754086AbYFLTtb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:49:31 -0400
Received: from sacexrs01.hq.netapp.com (sacexrs01.hq.netapp.com [10.99.190.105])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJnOlx008577
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:49:30 -0700 (PDT)
In-Reply-To: <20080612192817.24916.52065.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4state.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 856a893..401ef8b 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -940,7 +940,6 @@ static int reclaimer(void *ptr)
 	allow_signal(SIGKILL);
 
 	/* Ensure exclusive access to NFSv4 state */
-	lock_kernel();
 	down_write(&clp->cl_sem);
 	/* Are there any NFS mounts out there? */
 	if (list_empty(&clp->cl_superblocks))
@@ -1000,7 +999,6 @@ restart_loop:
 	nfs_delegation_reap_unclaimed(clp);
 out:
 	up_write(&clp->cl_sem);
-	unlock_kernel();
 	if (status == -NFS4ERR_CB_PATH_DOWN)
 		nfs_handle_cb_pathdown(clp);
 	nfs4_clear_recover_bit(clp);

