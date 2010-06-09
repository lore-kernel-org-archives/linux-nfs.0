From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 01/24] Revert "pnfs-nonfilelayout: Prelim support for
 non-file layout O_DIRECT"
Date: Wed, 09 Jun 2010 21:06:45 +0300
Message-ID: <4C0FD835.3020308@panasas.com>
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com> <1275970761-31806-2-git-send-email-iisaman@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:18089 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757267Ab0FISGv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jun 2010 14:06:51 -0400
In-Reply-To: <1275970761-31806-2-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/08/2010 07:18 AM, Fred Isaman wrote:
> This reverts commit 05277f5f5236462a11e7a20ebe9009449f8a463d.
> 
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
>  fs/nfs/direct.c |   10 ----------
>  1 files changed, 0 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index e111e9f..02e5918 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -191,22 +191,12 @@ static ssize_t nfs_direct_wait(struct nfs_direct_req *dreq)
>  {
>  	ssize_t result = -EIOCBQUEUED;
>  
> -	if (!pnfs_use_rpc(NFS_SERVER(dreq->inode))) {
> -		/* FIXME: Right now non-rpc layout types must perform
> -		 * syncronous direct i/o.
> -		 * New pNFS callback to wait on outstanding requests?
> -		 */

Just a note for later.
The read/write_pages at layout driver have a sync_io flag (some_where)
Both objlayout and pan_shim fully implement it. Once xxx_pages returns
data is on disk. So no need for the "New pNFS callback to wait"

Boaz

> -		result = 0;
> -		goto set_result;
> -	}
> -
>  	/* Async requests don't wait here */
>  	if (dreq->iocb)
>  		goto out;
>  
>  	result = wait_for_completion_killable(&dreq->completion);
>  
> -set_result:
>  	if (!result)
>  		result = dreq->error;
>  	if (!result)

