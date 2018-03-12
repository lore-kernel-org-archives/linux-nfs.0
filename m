Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:40852 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751104AbeCLMHH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 12 Mar 2018 08:07:07 -0400
Date: Mon, 12 Mar 2018 08:07:05 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: nfs_commit_inode should redirty inode if the inode
 has outstanding requests
Message-ID: <20180312120704.a5ot7zd26vbbiehf@tonberry.usersys.redhat.com>
References: <20180302160038.1598-1-smayhew@redhat.com>
 <20180305211619.GA29226@fieldses.org>
 <1520286491.21829.13.camel@primarydata.com>
 <20180307195313.kzqdboqk5j2hyrf3@tonberry.usersys.redhat.com>
 <1520455098.2858.4.camel@primarydata.com>
 <20180308130901.h2qbbzsuejggogut@tonberry.usersys.redhat.com>
 <1520529236.3530.16.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1520529236.3530.16.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 08 Mar 2018, Trond Myklebust wrote:

> On Thu, 2018-03-08 at 08:09 -0500, Scott Mayhew wrote:
> > Yes, this works.  I ran it through a dozen fio runs on v4.1 and 1000
> > runs
> > of generic/247 on v3/v4.0/v4.1/v4.2 and didn't see any EBUSY errors.
> > Also ran the xfstests "quick" group (~80-90 tests) plus generic/074
> > on
> > v3/v4.0/v4.1/v4.2.  Finally, I double checked the panic on umount
> > issue
> > that dc4fd9ab01ab3 fixed and that still works too.
> 
> I took a long hard look at what we actually need in that area of the
> code. There are a few things that are still broken there:
> 
> Firstly, we want to keep the inode marked as I_DIRTY_DATASYNC as long
> as we have stable writes that are undergoing commit or are waiting to
> be scheduled. The reason is that ensures sync_inode() behaves correctly
> by calling into nfs_write_inode() so that we can schedule COMMITs and
> wait for them all to complete.
> Currently we are broken in that nfs_write_inode() will not reset
> I_DIRTY_DATASYNC if there are still COMMITs in flight due to having
> called it with wbc->sync_mode == WB_SYNC_NONE.
> 
> Secondly, we want to ensure that if the number of requests is >
> INT_MAX, we loop around and schedule more COMMITs so that
> nfs_commit_inode(inode, FLUSH_SYNC) is reliable on systems with lots of
> memory.
> 
> Finally, it is worth noting that it's only when called from
> __writeback_single_inode(), and the attempt to clean the inode failed
> that we need to reset the inode state. So we can optimise by pushing
> those calls to __mark_inode_dirty() into nfs_write_inode().
> 
> So how about the following v2 patch instead?
> 8<--------------------------------------------
> From 386978cc3ef4494b9f95390747c2268f8318b94b Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Wed, 7 Mar 2018 15:22:31 -0500
> Subject: [PATCH v2] NFS: Fix unstable write completion
> 
> We do want to respect the FLUSH_SYNC argument to nfs_commit_inode() to
> ensure that all outstanding COMMIT requests to the inode in question are
> complete. Currently we may exit early from both nfs_commit_inode() and
> nfs_write_inode() even if there are COMMIT requests in flight, or unstable
> writes on the commit list.
> 
> In order to get the right semantics w.r.t. sync_inode(), we don't need
> to have nfs_commit_inode() reset the inode dirty flags when called from
> nfs_wb_page() and/or nfs_wb_all(). We just need to ensure that
> nfs_write_inode() leaves them in the right state if there are outstanding
> commits, or stable pages.
> 
> Reported-by: Scott Mayhew <smayhew@redhat.com>
> Fixes: dc4fd9ab01ab ("nfs: don't wait on commit in nfs_commit_inode()...")
> Cc: stable@vger.kernel.org # v4.5+: 5cb953d4b1e7: NFS: Use an atomic_long_t
> Cc: stable@vger.kernel.org # v4.5+
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

I ran all the same tests as before and this is working fine.

-Scott

> ---
>  fs/nfs/write.c | 83 ++++++++++++++++++++++++++++++----------------------------
>  1 file changed, 43 insertions(+), 40 deletions(-)
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 7428a669d7a7..e7d8ceae8f26 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1876,40 +1876,43 @@ int nfs_generic_commit_list(struct inode *inode, struct list_head *head,
>  	return status;
>  }
>  
> -int nfs_commit_inode(struct inode *inode, int how)
> +static int __nfs_commit_inode(struct inode *inode, int how,
> +		struct writeback_control *wbc)
>  {
>  	LIST_HEAD(head);
>  	struct nfs_commit_info cinfo;
>  	int may_wait = how & FLUSH_SYNC;
> -	int error = 0;
> -	int res;
> +	int ret, nscan;
>  
>  	nfs_init_cinfo_from_inode(&cinfo, inode);
>  	nfs_commit_begin(cinfo.mds);
> -	res = nfs_scan_commit(inode, &head, &cinfo);
> -	if (res)
> -		error = nfs_generic_commit_list(inode, &head, how, &cinfo);
> +	for (;;) {
> +		ret = nscan = nfs_scan_commit(inode, &head, &cinfo);
> +		if (ret <= 0)
> +			break;
> +		ret = nfs_generic_commit_list(inode, &head, how, &cinfo);
> +		if (ret < 0)
> +			break;
> +		ret = 0;
> +		if (wbc && wbc->sync_mode == WB_SYNC_NONE) {
> +			if (nscan < wbc->nr_to_write)
> +				wbc->nr_to_write -= nscan;
> +			else
> +				wbc->nr_to_write = 0;
> +		}
> +		if (nscan < INT_MAX)
> +			break;
> +		cond_resched();
> +	}
>  	nfs_commit_end(cinfo.mds);
> -	if (res == 0)
> -		return res;
> -	if (error < 0)
> -		goto out_error;
> -	if (!may_wait)
> -		goto out_mark_dirty;
> -	error = wait_on_commit(cinfo.mds);
> -	if (error < 0)
> -		return error;
> -	return res;
> -out_error:
> -	res = error;
> -	/* Note: If we exit without ensuring that the commit is complete,
> -	 * we must mark the inode as dirty. Otherwise, future calls to
> -	 * sync_inode() with the WB_SYNC_ALL flag set will fail to ensure
> -	 * that the data is on the disk.
> -	 */
> -out_mark_dirty:
> -	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> -	return res;
> +	if (ret || !may_wait)
> +		return ret;
> +	return wait_on_commit(cinfo.mds);
> +}
> +
> +int nfs_commit_inode(struct inode *inode, int how)
> +{
> +	return __nfs_commit_inode(inode, how, NULL);
>  }
>  EXPORT_SYMBOL_GPL(nfs_commit_inode);
>  
> @@ -1919,11 +1922,11 @@ int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
>  	int flags = FLUSH_SYNC;
>  	int ret = 0;
>  
> -	/* no commits means nothing needs to be done */
> -	if (!atomic_long_read(&nfsi->commit_info.ncommit))
> -		return ret;
> -
>  	if (wbc->sync_mode == WB_SYNC_NONE) {
> +		/* no commits means nothing needs to be done */
> +		if (!atomic_long_read(&nfsi->commit_info.ncommit))
> +			goto check_requests_outstanding;
> +
>  		/* Don't commit yet if this is a non-blocking flush and there
>  		 * are a lot of outstanding writes for this mapping.
>  		 */
> @@ -1934,16 +1937,16 @@ int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
>  		flags = 0;
>  	}
>  
> -	ret = nfs_commit_inode(inode, flags);
> -	if (ret >= 0) {
> -		if (wbc->sync_mode == WB_SYNC_NONE) {
> -			if (ret < wbc->nr_to_write)
> -				wbc->nr_to_write -= ret;
> -			else
> -				wbc->nr_to_write = 0;
> -		}
> -		return 0;
> -	}
> +	ret = __nfs_commit_inode(inode, flags, wbc);
> +	if (!ret) {
> +		if (flags & FLUSH_SYNC)
> +			return 0;
> +	} else if (atomic_long_read(&nfsi->commit_info.ncommit))
> +		goto out_mark_dirty;
> +
> +check_requests_outstanding:
> +	if (!atomic_read(&nfsi->commit_info.rpcs_out))
> +		return ret;
>  out_mark_dirty:
>  	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
>  	return ret;
> -- 
> 2.14.3
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
