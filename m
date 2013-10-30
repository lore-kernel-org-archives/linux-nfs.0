Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44239 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754473Ab3J3Ofy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Oct 2013 10:35:54 -0400
Date: Wed, 30 Oct 2013 10:35:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/7] nfsd4: fix recall_lock use in unhash_delegation
Message-ID: <20131030143552.GE3227@fieldses.org>
References: <526F81DE.6060704@primarydata.com>
 <1383039544-27157-1-git-send-email-bhalevy@primarydata.com>
 <20131029144658.GR31322@fieldses.org>
 <52711187.10202@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52711187.10202@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 30, 2013 at 04:02:47PM +0200, Benny Halevy wrote:
> On 2013-10-29 16:46, J. Bruce Fields wrote:
> > On Tue, Oct 29, 2013 at 11:39:04AM +0200, Benny Halevy wrote:
> >> Access to dp->dl_perclnt must be synchronized by the recall_lock
> > 
> > Are you sure?  recall_lock is for stuff that's needed in the delegation
> > break callback (nfsd_break_deleg_cb() and any of the subsequent callback
> > handling).  I don't think that includes dl_perclnt.
> 
> I was mislead by the fact that destroy_client and nfs4_state_shutdown_net
> care to acquire the recall_lock for traversing the clp->cl_delegations
> and nn->del_recall_lru lists, respectively.
> 
> Now nfs4_state_shutdown_net, although its comment says it should be
> called with the state lock held (SHOULD or should, or should it be MUST? :)
> It doesn't seem like nfsd_shutdown_net acquires the state lock.

Good point.

> Therefore, we either need to grab the state lock in nfs4_state_shutdown_net
> which adds yet another problem to fix,

That sounds simplest as the short-term fix....  What problem do you see?

--b.

commit 2c9407ae694dad8a1ad6394d9bf6077024b9fae7
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Oct 30 10:33:09 2013 -0400

    nfsd4: nfsd_shutdown_net needs state lock
    
    A comment claims the caller should take it, but that's not being done.
    Note we don't want it around the cancel_delayed_work_sync since that may
    wait on work which holds the client lock.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 21eb678..e03e8ef 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5124,7 +5124,6 @@ out_recovery:
 	return ret;
 }
 
-/* should be called with the state lock held */
 void
 nfs4_state_shutdown_net(struct net *net)
 {
@@ -5135,6 +5134,7 @@ nfs4_state_shutdown_net(struct net *net)
 	cancel_delayed_work_sync(&nn->laundromat_work);
 	locks_end_grace(&nn->nfsd4_manager);
 
+	nfs4_lock_state();
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&recall_lock);
 	list_for_each_safe(pos, next, &nn->del_recall_lru) {
@@ -5149,6 +5149,7 @@ nfs4_state_shutdown_net(struct net *net)
 
 	nfsd4_client_tracking_exit(net);
 	nfs4_state_destroy_net(net);
+	nfs4_unlock_state();
 }
 
 void
