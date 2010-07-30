Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:39346 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933224Ab0G3S3G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Jul 2010 14:29:06 -0400
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 0000000000000020
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Bian Naimeng <biannm@cn.fujitsu.com>
Cc: yo mama <mamamia69@gmail.com>, linux-nfs@vger.kernel.org,
        Benny Halevy <bhalevy@panasas.com>
In-Reply-To: <4C5105F8.5050101@cn.fujitsu.com>
References: <AANLkTikYDGpeX8kcK3ygFzjM+bYMFTtqr8Wgx+CygUt8@mail.gmail.com>
	 <4C5105F8.5050101@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 30 Jul 2010 14:28:51 -0400
Message-ID: <1280514531.12852.23.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-07-29 at 12:39 +0800, Bian Naimeng wrote:
> > Hello,
> > 
> > I am running Kernel version 2.6.35-rc5-pnfs and notice there is kernel
> > crash everytime i run iozone on the mounted directory. Is there a
> > patch already developed for this bug which i can apply. Please see the
> > error message from message log.
> > 
> 
>  I'm not sure it's ok, please try it.
> 
> ----
> 
>  nfs_writeargs.lock_context always NULL at direct write procedure,
> it will cause kernel panic when encode stateid.
> 
> Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
> 
> ---
>  fs/nfs/direct.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index 3ef9b0c..cb2e1fd 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -801,6 +801,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
>  		data->cred = msg.rpc_cred;
>  		data->args.fh = NFS_FH(inode);
>  		data->args.context = ctx;
> +		data->args.lock_context = nfs_get_lock_context(ctx);
>  		data->args.offset = pos;
>  		data->args.pgbase = pgbase;
>  		data->args.pages = data->pagevec;
> -- 
> 1.6.5.2
> 

Well caught. There is a similar issue with NFS reads too. I'll fix up
the lock state tracking patch...

Thanks
  Trond

