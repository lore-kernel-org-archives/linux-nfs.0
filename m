Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:23750 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752654AbdGMSgZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Jul 2017 14:36:25 -0400
Subject: Re: [PATCH] NFS: Don't run wake_up_bit() when nobody is waiting...
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
References: <20170711215348.18596-1-trond.myklebust@primarydata.com>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <a7b81bc6-abae-e727-44f0-cf4e1ccfe250@Netapp.com>
Date: Thu, 13 Jul 2017 14:36:18 -0400
MIME-Version: 1.0
In-Reply-To: <20170711215348.18596-1-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On 07/11/2017 05:53 PM, Trond Myklebust wrote:
> "perf lock" shows fairly heavy contention for the bit waitqueue locks
> when doing an I/O heavy workload.
> Use a bit to tell whether or not there has been contention for a lock
> so that we can optimise away the bit waitqueue options in those cases.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/pagelist.c        | 17 ++++++++++++++++-
>  include/linux/nfs_page.h |  2 ++
>  2 files changed, 18 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index ce5f8d2875ae..046162b79b4b 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -155,9 +155,12 @@ nfs_page_group_lock(struct nfs_page *req, bool nonblock)
>  	if (!test_and_set_bit(PG_HEADLOCK, &head->wb_flags))
>  		return 0;
>  
> -	if (!nonblock)
> +	if (!nonblock) {
> +		set_bit(PG_CONTENDED1, &head->wb_flags);
> +		smp_mb__after_atomic();
>  		return wait_on_bit_lock(&head->wb_flags, PG_HEADLOCK,
>  				TASK_UNINTERRUPTIBLE);
> +	}
>  
>  	return -EAGAIN;
>  }
> @@ -175,6 +178,10 @@ nfs_page_group_lock_wait(struct nfs_page *req)
>  
>  	WARN_ON_ONCE(head != head->wb_head);
>  
> +	if (!test_bit(PG_HEADLOCK, &head->wb_flags))
> +		return;
> +	set_bit(PG_CONTENDED1, &head->wb_flags);
> +	smp_mb__after_atomic();
>  	wait_on_bit(&head->wb_flags, PG_HEADLOCK,
>  		TASK_UNINTERRUPTIBLE);
>  }
> @@ -193,6 +200,8 @@ nfs_page_group_unlock(struct nfs_page *req)
>  	smp_mb__before_atomic();
>  	clear_bit(PG_HEADLOCK, &head->wb_flags);
>  	smp_mb__after_atomic();
> +	if (!test_bit(PG_CONTENDED1, &head->wb_flags))
> +		return;
>  	wake_up_bit(&head->wb_flags, PG_HEADLOCK);
>  }
>  
> @@ -383,6 +392,8 @@ void nfs_unlock_request(struct nfs_page *req)
>  	smp_mb__before_atomic();
>  	clear_bit(PG_BUSY, &req->wb_flags);
>  	smp_mb__after_atomic();
> +	if (!test_bit(PG_CONTENDED2, &req->wb_flags))
> +		return;
>  	wake_up_bit(&req->wb_flags, PG_BUSY);
>  }
>  
> @@ -465,6 +476,10 @@ void nfs_release_request(struct nfs_page *req)
>  int
>  nfs_wait_on_request(struct nfs_page *req)
>  {
> +	if (!test_bit(PG_BUSY, &req->wb_flags))
> +		return 0;
> +	set_bit(PG_CONTENDED2, &req->wb_flags);
> +	smp_mb__after_atomic();
>  	return wait_on_bit_io(&req->wb_flags, PG_BUSY,
>  			      TASK_UNINTERRUPTIBLE);
>  }
> diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
> index abbee2d15dce..d67b67ae6c8b 100644
> --- a/include/linux/nfs_page.h
> +++ b/include/linux/nfs_page.h
> @@ -33,6 +33,8 @@ enum {
>  	PG_UPTODATE,		/* page group sync bit in read path */
>  	PG_WB_END,		/* page group sync bit in write path */
>  	PG_REMOVE,		/* page group sync bit in write path */
> +	PG_CONTENDED1,		/* Is someone waiting for a lock? */
> +	PG_CONTENDED2,		/* Is someone waiting for a lock? */

It looks like CONTENDED1 is for page groups, and CONTENDED2 is for requests?  I wonder
if that could be a little more explicit either through this comment or through the names
of the variables themselves.

Thanks,
Anna

>  };
>  
>  struct nfs_inode;
> 
