Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48584 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935377AbdLRQf7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Dec 2017 11:35:59 -0500
Date: Mon, 18 Dec 2017 11:35:59 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mike Galbraith <efault@gmx.de>
Cc: lkml <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: NFS: 82ms wakeup latency 4.14-rc4
Message-ID: <20171218163559.GA11829@fieldses.org>
References: <1513610231.7998.13.camel@gmx.de>
 <1513611112.7113.1.camel@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1513611112.7113.1.camel@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 18, 2017 at 04:31:52PM +0100, Mike Galbraith wrote:
> On Mon, 2017-12-18 at 16:17 +0100, Mike Galbraith wrote:
> > 
> > ....
> > kworker/-7421    0.N.. 82893us : nfs_release_request <-nfs_commit_release_pages
> > kworker/-7421    0.N.. 82893us : nfs_unlock_and_release_request <-nfs_commit_release_pages
> > kworker/-7421    0.N.. 82893us : nfs_unlock_request <-nfs_unlock_and_release_request
> > kworker/-7421    0.N.. 82893us : nfs_page_group_destroy <-nfs_commit_release_pages
> > kworker/-7421    0.N.. 82893us : nfs_page_group_sync_on_bit <-nfs_page_group_destroy
> > kworker/-7421    0.N.. 82893us : nfs_page_group_lock <-nfs_page_group_sync_on_bit
> > kworker/-7421    0.N.. 82893us : nfs_page_group_unlock <-nfs_page_group_sync_on_bit
> > kworker/-7421    0.N.. 82893us : nfs_free_request <-nfs_page_group_destroy
> > kworker/-7421    0.N.. 82893us : nfs_put_lock_context <-nfs_free_request
> > kworker/-7421    0.N.. 82893us : put_nfs_open_context <-nfs_free_request
> > kworker/-7421    0.N.. 82893us : __put_nfs_open_context <-nfs_free_request
> > kworker/-7421    0.N.. 82894us : kmem_cache_free <-nfs_page_group_destroy
> > kworker/-7421    0.N.. 82894us : __slab_free <-kmem_cache_free
> > kworker/-7421    0.N.. 82894us : clear_wb_congested <-nfs_commit_release_pages
> > kworker/-7421    0.N.. 82894us : nfs_init_cinfo <-nfs_commit_release_pages
> > kworker/-7421    0.N.. 82894us : nfs_init_cinfo_from_inode <-nfs_commit_release_pages
> > kworker/-7421    0.N.. 82894us : nfs_commit_end <-nfs_commit_release_pages
> > kworker/-7421    0.N.. 82894us : nfs_commitdata_release <-rpc_free_task
> > kworker/-7421    0.N.. 82894us : put_nfs_open_context <-nfs_commitdata_release
> > kworker/-7421    0.N.. 82894us : __put_nfs_open_context <-nfs_commitdata_release
> > kworker/-7421    0.N.. 82895us : mempool_free <-rpc_free_task
> > kworker/-7421    0.N.. 82895us : mempool_free_slab <-rpc_free_task
> > kworker/-7421    0.N.. 82895us : kmem_cache_free <-rpc_free_task
> > kworker/-7421    0.N.. 82895us : ___might_sleep <-process_one_work
> > kworker/-7421    0.N.. 82895us : _cond_resched <-process_one_work
> > kworker/-7421    0dN.1 82895us : rcu_note_context_switch <-__schedule
> 
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index d0543e19098a..b42bf3b21e05 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -428,6 +428,7 @@ void nfs_free_request(struct nfs_page *req)
>  	/* Release struct file and open context */
>  	nfs_clear_request(req);
>  	nfs_page_free(req);
> +	cond_resched();
>  }
>  
>  void nfs_release_request(struct nfs_page *req)

This probably just shows I don't understand the issues, but: isn't this
the job of preemption?  If we're not holding any locks that would
prevent scheduling here, shouldn't latency-sensitive users be building
preemptible kernels and letting the scheduler take care of this?  It
seems unfortunate to require explicit cond_resched()s allovers.

Like I say, I don't really understand the issues here, so it's more a
question than an objection....  (I don't know any reason a
cond_resched() would be bad there.)

--b.
