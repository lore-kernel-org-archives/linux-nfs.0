Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:63915 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758386AbdLRPRU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Dec 2017 10:17:20 -0500
Message-ID: <1513610231.7998.13.camel@gmx.de>
Subject: NFS: 82ms wakeup latency 4.14-rc4
From: Mike Galbraith <efault@gmx.de>
To: lkml <linux-kernel@vger.kernel.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Date: Mon, 18 Dec 2017 16:17:11 +0100
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greetings,

While doing some generic scheduler latency testing, I stumbled onto
$subject.  To reproduce this, I simply nfs mount my box, cd to one of
it's spinning rust buckets, and do bonnie -s <ramsize>.  With nothing
else going on in the box, I've hit > 100ms wakeup latencies.

(nouveau apparently also thinks this is uncool, and whimpers) 

....
kworker/-7421    0.N.. 82893us : nfs_release_request <-nfs_commit_release_pages
kworker/-7421    0.N.. 82893us : nfs_unlock_and_release_request <-nfs_commit_release_pages
kworker/-7421    0.N.. 82893us : nfs_unlock_request <-nfs_unlock_and_release_request
kworker/-7421    0.N.. 82893us : nfs_page_group_destroy <-nfs_commit_release_pages
kworker/-7421    0.N.. 82893us : nfs_page_group_sync_on_bit <-nfs_page_group_destroy
kworker/-7421    0.N.. 82893us : nfs_page_group_lock <-nfs_page_group_sync_on_bit
kworker/-7421    0.N.. 82893us : nfs_page_group_unlock <-nfs_page_group_sync_on_bit
kworker/-7421    0.N.. 82893us : nfs_free_request <-nfs_page_group_destroy
kworker/-7421    0.N.. 82893us : nfs_put_lock_context <-nfs_free_request
kworker/-7421    0.N.. 82893us : put_nfs_open_context <-nfs_free_request
kworker/-7421    0.N.. 82893us : __put_nfs_open_context <-nfs_free_request
kworker/-7421    0.N.. 82894us : kmem_cache_free <-nfs_page_group_destroy
kworker/-7421    0.N.. 82894us : __slab_free <-kmem_cache_free
kworker/-7421    0.N.. 82894us : clear_wb_congested <-nfs_commit_release_pages
kworker/-7421    0.N.. 82894us : nfs_init_cinfo <-nfs_commit_release_pages
kworker/-7421    0.N.. 82894us : nfs_init_cinfo_from_inode <-nfs_commit_release_pages
kworker/-7421    0.N.. 82894us : nfs_commit_end <-nfs_commit_release_pages
kworker/-7421    0.N.. 82894us : nfs_commitdata_release <-rpc_free_task
kworker/-7421    0.N.. 82894us : put_nfs_open_context <-nfs_commitdata_release
kworker/-7421    0.N.. 82894us : __put_nfs_open_context <-nfs_commitdata_release
kworker/-7421    0.N.. 82895us : mempool_free <-rpc_free_task
kworker/-7421    0.N.. 82895us : mempool_free_slab <-rpc_free_task
kworker/-7421    0.N.. 82895us : kmem_cache_free <-rpc_free_task
kworker/-7421    0.N.. 82895us : ___might_sleep <-process_one_work
kworker/-7421    0.N.. 82895us : _cond_resched <-process_one_work
kworker/-7421    0dN.1 82895us : rcu_note_context_switch <-__schedule
