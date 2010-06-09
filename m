From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 05/24] SQUASHME: ensure pnfs_update_lseg clears lsegp
 on error
Date: Wed, 09 Jun 2010 21:18:22 +0300
Message-ID: <4C0FDAEE.3010300@panasas.com>
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com> <1275970761-31806-2-git-send-email-iisaman@netapp.com> <1275970761-31806-3-git-send-email-iisaman@netapp.com> <1275970761-31806-4-git-send-email-iisaman@netapp.com> <1275970761-31806-5-git-send-email-iisaman@netapp.com> <1275970761-31806-6-git-send-email-iisaman@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:35126 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757409Ab0FISSY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jun 2010 14:18:24 -0400
In-Reply-To: <1275970761-31806-6-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/08/2010 07:19 AM, Fred Isaman wrote:
> This should be squashed into my (or alexandros's)submission patches for
> version 2. Compensate for Alexandros returning error but assigning lseg.
> 
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
>  fs/nfs/pnfs.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 2f8fa3c..b990471 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1064,6 +1064,8 @@ pnfs_update_layout(struct inode *ino,
>  	DEFINE_WAIT(__wait);
>  	int result = 0;
>  
> +	if (take_ref)
> +		*lsegpp = NULL;
>  	lo = get_lock_alloc_layout(ino);
>  	if (IS_ERR(lo)) {
>  		dprintk("%s ERROR: can't get pnfs_layout_type\n", __func__);
> @@ -1078,6 +1080,7 @@ pnfs_update_layout(struct inode *ino,
>  			put_lseg(lseg);
>  
>  		/* someone is cleaning the layout */
> +		lseg = NULL;
>  		result = -EAGAIN;
>  		goto out_put;
>  	}

Please get these patchset organised.
* Cleanup which go in permanently - first / separate.
* Degrading B to A patches - later / separate.
  Plus the A to B patch if needed or a note that a simple patch -R will do.
  (Or a TODO: note that an A to B patch is missing)

This kind of patch kills any ability to really see what is happening.

And, as far as code progression and understanding goes:
* Fred's patches should go first - We first get a layout.
* Then Alexandros patches ontop. - Then we return / recall a layout.

Boaz
