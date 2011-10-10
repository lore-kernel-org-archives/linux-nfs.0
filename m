Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12732 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751561Ab1JJVQD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Oct 2011 17:16:03 -0400
Subject: Re: [PATCH][RFC] nfs: don't redirty inode when ncommit == 0 in
 nfs_commit_unstable_pages
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, mikem@redhat.com
Date: Mon, 10 Oct 2011 17:15:42 -0400
In-Reply-To: <1318278838-26653-1-git-send-email-jlayton@redhat.com>
References: <1318278838-26653-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1318281342.14423.63.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-10-10 at 16:33 -0400, Jeff Layton wrote: 
> The current test in nfs_commit_unstable_pages does not handle the edge
> condition properly. When ncommit == 0, then that likely means that the
> kernel doesn't need to do anything more for the inode. The current test
> though will return true in that case, and the inode will end up being
> marked dirty.
> 
> Fix this by not re-marking the inode dirty when ncommit == 0.
> 
> Mike noticed this problem initially in RHEL5 (2.6.18-based kernel) which
> has a backported version of 420e3646. The inode cache there was
> growing very large, but calling sync() would essentially "fix" the
> problem.
> 
> What I'm not clear on is how big a problem this is in mainline kernels
> as the writeback code there is very different. I think this basically
> means that the inode will remain dirty until there's a WB_SYNC_ALL
> flush. Either way, it seems incorrect to mark the inode dirty in this
> case.
> 
> Also, another question I have here -- shouldn't we be holding the i_lock
> when doing this check?
> 
> Reported-by: Mike McLean <mikem@redhat.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/write.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 17e20e4..6395e98 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1557,7 +1557,7 @@ static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_contr
>  		/* Don't commit yet if this is a non-blocking flush and there
>  		 * are a lot of outstanding writes for this mapping.
>  		 */
> -		if (nfsi->ncommit <= (nfsi->npages >> 1))
> +		if (nfsi->ncommit && nfsi->ncommit <= (nfsi->npages >> 1))
>  			goto out_mark_dirty;
>  
>  		/* don't wait for the COMMIT response */

Umm... The above implementation will actually cause you to call
nfs_commit_inode() when nfsi->ncommit is zero, which again causes you to
go through all the hoopla with nfs_commit_set_lock() etc., for a case
when you know you could just exit...

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

