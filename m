Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56269 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751379AbaHQUGx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Aug 2014 16:06:53 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1XJ6j6-0006X4-TK
	for linux-nfs@vger.kernel.org; Sun, 17 Aug 2014 16:06:52 -0400
Date: Sun, 17 Aug 2014 16:06:52 -0400
To: linux-nfs@vger.kernel.org
Subject: nfsd branch for 3.18
Message-ID: <20140817200652.GA24959@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've started a for-3.18 branch based on 3.17-rc1 which includes Trond's
scalability patches and a few other things:

	git://linux-nfs.org/~bfields/linux.git for-3.18

--b.

J. Bruce Fields (2):
      nfsd4: remove obsolete comment
      nfsd4: reserve adequate space for LOCK op

Jeff Layton (2):
      nfsd: protect lease-related nfs4_file fields with fi_lock
      nfsd: call nfs4_put_deleg_lease outside of state_lock

Ross Lagerwall (1):
      nfsd3: Check write permission after checking existence

Trond Myklebust (14):
      SUNRPC: Do not override wspace tests in svc_handle_xprt
      lockd: Ensure that lockd_start_svc sets the server rq_task...
      nfs: Ensure that nfs_callback_start_svc sets the server rq_task...
      SUNRPC: Do not grab pool->sp_lock unnecessarily in svc_get_next_xprt
      SUNRPC: get rid of the request wait queue
      SUNRPC: Fix broken kthread_should_stop test in svc_get_next_xprt
      SUNRPC: More optimisations of svc_xprt_enqueue()
      SUNRPC: Optimise away svc_recv_available
      nfsd: Clean up drc cache in preparation for global spinlock elimination
      nfsd: convert the lru list into a per-bucket thing
      nfsd: Remove the cache_hash list
      nfsd: convert num_drc_entries to an atomic_t
      nfsd: split DRC global spinlock into per-bucket locks
      nfsd: Reorder nfsd_cache_match to check more powerful discriminators first

