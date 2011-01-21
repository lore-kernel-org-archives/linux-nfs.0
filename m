Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:64642 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605Ab1AUCoj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Jan 2011 21:44:39 -0500
Date: Fri, 21 Jan 2011 10:42:44 +0800
From: Wengang Wang <wen.gang.wang@oracle.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: npiggin@gmail.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wen.gang.wang@oracle.com
Subject: Re: [PATCH] NFS: Fix "BUG at fs/aio.c:554!"
Message-ID: <20110121024244.GB9138@laptop.uk.oracle.com>
References: <20110119223543.30706.10304.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110119223543.30706.10304.stgit@matisse.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 11-01-19 17:36, Chuck Lever wrote:
> Nick Piggin reports:
> 
> > I'm getting use after frees in aio code in NFS
> >
> > [ 2703.396766] Call Trace:
> > [ 2703.396858]  [<ffffffff8100b057>] ? native_sched_clock+0x27/0x80
> > [ 2703.396959]  [<ffffffff8108509e>] ? put_lock_stats+0xe/0x40
> > [ 2703.397058]  [<ffffffff81088348>] ? lock_release_holdtime+0xa8/0x140
> > [ 2703.397159]  [<ffffffff8108a2a5>] lock_acquire+0x95/0x1b0
> > [ 2703.397260]  [<ffffffff811627db>] ? aio_put_req+0x2b/0x60
> > [ 2703.397361]  [<ffffffff81039701>] ? get_parent_ip+0x11/0x50
> > [ 2703.397464]  [<ffffffff81612a31>] _raw_spin_lock_irq+0x41/0x80
> > [ 2703.397564]  [<ffffffff811627db>] ? aio_put_req+0x2b/0x60
> > [ 2703.397662]  [<ffffffff811627db>] aio_put_req+0x2b/0x60
> > [ 2703.397761]  [<ffffffff811647fe>] do_io_submit+0x2be/0x7c0
> > [ 2703.397895]  [<ffffffff81164d0b>] sys_io_submit+0xb/0x10
> > [ 2703.397995]  [<ffffffff8100307b>] system_call_fastpath+0x16/0x1b
> >
> > Adding some tracing, it is due to nfs completing the request then
> > returning something other than -EIOCBQUEUED, so aio.c
> > also completes the request.
> 
> To address this, prevent the NFS direct I/O engine from completing
> async iocbs when the forward path returns an error other than
> EIOCBQUEUED.
> 
> This appears to survive ^C during both "xfstest no. 208" and "fsx -Z."
> 
> Cc: Stable <stable@kernel.org>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> Here's my take.
> 
>  fs/nfs/direct.c |   32 +++++++++++++++++---------------
>  1 files changed, 17 insertions(+), 15 deletions(-)
> 
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index e6ace0d..c2176f4 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -407,15 +407,16 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
>  		pos += vec->iov_len;
>  	}
>  
> -	if (put_dreq(dreq))
> -		nfs_direct_complete(dreq);
> -
> -	if (requested_bytes != 0)
> -		return 0;
> +	/*
> +	 * If no bytes were started, return the error, and let the
> +	 * generic layer handle the completion.
> +	 */

But the put_dreq() -> nfs_direct_complete() does more than complete the
aio.
It also drops ref on dreq with put_dreq() and does

complete_all(&dreq->completion);
nfs_direct_req_release(dreq);

I think we still needs that called somewhere.

regards,
wengang.

> +	if (requested_bytes == 0)
> +		return result < 0 ? result : -EIO;
>  
> -	if (result < 0)
> -		return result;
> -	return -EIO;
> +	if (put_dreq(dreq))
> +		nfs_direct_write_complete(dreq, dreq->inode);
> +	return 0;
>  }
>  
>  static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
> @@ -841,15 +842,16 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
>  		pos += vec->iov_len;
>  	}
>  
> +	/*
> +	 * If no bytes were started, return the error, and let the
> +	 * generic layer handle the completion.
> +	 */
> +	if (requested_bytes == 0)
> +		return result < 0 ? result : -EIO;
> +
>  	if (put_dreq(dreq))
>  		nfs_direct_write_complete(dreq, dreq->inode);
> -
> -	if (requested_bytes != 0)
> -		return 0;
> -
> -	if (result < 0)
> -		return result;
> -	return -EIO;
> +	return 0;
>  }
>  
>  static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
