Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36506 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933259AbdC3Rez (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Mar 2017 13:34:55 -0400
Received: by mail-io0-f195.google.com with SMTP id 68so3583373ioh.3
        for <linux-nfs@vger.kernel.org>; Thu, 30 Mar 2017 10:34:54 -0700 (PDT)
Subject: Re: [PATCH 1/1] PNFS fix fallback to MDS if got error on commit to DS
To: Olga Kornievskaia <kolga@netapp.com>,
        Trond.Myklebust@primarydata.com, anna.schumaker@netapp.com
References: <CAN-5tyG5s1B25WShf5HJ0DkYLpM7oQ1OiZO+zvg892yZ=68NoQ@mail.gmail.com>
 <20170330141055.61977-1-kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <1c58c56a-3a16-2a5d-b87c-d0019762ec9e@gmail.com>
Date: Thu, 30 Mar 2017 13:34:52 -0400
MIME-Version: 1.0
In-Reply-To: <20170330141055.61977-1-kolga@netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On 03/30/2017 10:10 AM, Olga Kornievskaia wrote:
> Upong receiving some errors (EACCES) on commit to the DS the code
> doesn't fallback to MDS and intead retrieds to the same DS again.

Just so I know what's going on: do you want this patch instead of the first one in the thread?

Thanks,
Anna
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/filelayout/filelayout.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
> index a3fc48b..59e1efa 100644
> --- a/fs/nfs/filelayout/filelayout.c
> +++ b/fs/nfs/filelayout/filelayout.c
> @@ -202,10 +202,10 @@ static int filelayout_async_handle_error(struct rpc_task *task,
>  			task->tk_status);
>  		nfs4_mark_deviceid_unavailable(devid);
>  		pnfs_error_mark_layout_for_return(inode, lseg);
> -		pnfs_set_lo_fail(lseg);
>  		rpc_wake_up(&tbl->slot_tbl_waitq);
>  		/* fall through */
>  	default:
> +		pnfs_set_lo_fail(lseg);
>  reset:
>  		dprintk("%s Retry through MDS. Error %d\n", __func__,
>  			task->tk_status);
> 
