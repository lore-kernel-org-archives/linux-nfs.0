Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:16564 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753571Ab0LPMrx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Dec 2010 07:47:53 -0500
Message-ID: <4D0A0A77.9010802@panasas.com>
Date: Thu, 16 Dec 2010 14:47:51 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: Fred Isaman <iisaman@netapp.com>, Benny Halevy <bhalevy@panasas.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 22/22] pnfs-submit: Turn off layoutcommits
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com> <1291944177-7819-23-git-send-email-iisaman@netapp.com>
In-Reply-To: <1291944177-7819-23-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 12/10/2010 03:22 AM, Fred Isaman wrote:
> Recent changes to close can delay pending layoutcommit until umount,
> when the async layoutcommits can come tricklng in after we have destroyed
> the session.  

Then "Recent changes" are broken and should be fixed. It was fine
before. New broken code is not acceptable.

> Since file does not need them, just turn them off for
> the moment.  Non-file layouts will probably have to trigger them in
> some fashion at close.
> 

Rrrr. Are we back to this argument. We stand down win an argument
and 2 weeks later you are back on it has if we never talked about it.

NO!!! only "coherent clustered filesystems" do not need them. It has
nothing to do with layout type. A none-clustered aggregated parallel
filesystem will need them just the same as blocks and objects.

AND THE STD DOES NOT GIVE YOU A CHOICE!!!

> A better solution is to just push all the layoutcommit code outside
> of the pnfs-submit branch.  This is really just a stop gap until code
> is rearranged to make that easier.
> 

Than all this is not finished. Please keep it in the shops until the
final solution is presented and we can actually see the new compared
to the old system. Until then we should keep what worked and was tested.

Boaz

> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
>  fs/nfs/nfs4proc.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 9b15535..224bdfe 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3098,7 +3098,6 @@ static void pnfs4_update_write_done(struct nfs_inode *nfsi, struct nfs_write_dat
>  {
>  #ifdef CONFIG_NFS_V4_1
>  	pnfs_update_last_write(nfsi, data->args.offset, data->res.count);
> -	pnfs_need_layoutcommit(nfsi, data->args.context);
>  #endif /* CONFIG_NFS_V4_1 */
>  }
>  

