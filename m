From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [pnfs] [PATCH 4/5] pnfsd: fix DLM file layout no device return
Date: Sun, 07 Feb 2010 11:33:36 +0200
Message-ID: <4B6E88F0.5030305@panasas.com>
References: <1265389813-6823-1-git-send-email-andros@netapp.com>	<1265389813-6823-2-git-send-email-andros@netapp.com>	<1265389813-6823-3-git-send-email-andros@netapp.com>	<1265389813-6823-4-git-send-email-andros@netapp.com> <1265389813-6823-5-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:9025 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751063Ab0BGJdj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Feb 2010 04:33:39 -0500
In-Reply-To: <1265389813-6823-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/05/2010 07:10 PM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfsd/nfs4pnfsdlm.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
> index 8cc7c84..83c4698 100644
> --- a/fs/nfsd/nfs4pnfsdlm.c
> +++ b/fs/nfsd/nfs4pnfsdlm.c
> @@ -316,7 +316,7 @@ static int dlm_ino_hash(struct inode *ino)
>  	 */
>  	de = nfsd4_find_pnfs_dlm_device(ino->i_sb->s_bdev->bd_disk->disk_name);
>  	if (!de)
> -		return -EINVAL;
> +		return -1;
>  	hash_mask = de->num_ds - 1;
>  	return ino->i_ino & hash_mask;
>  }
> @@ -340,7 +340,7 @@ static int nfsd4_pnfs_dlm_layoutget(struct inode *inode,
>  	dprintk("%s first stripe index %d i_ino %lu\n", __func__, index,
>  		inode->i_ino);
>  	if (index < 0)
> -		return index;
> +		return nfserr_layoutunavailable;

You are relaying on a side effect that undefined errors
are nfserr_layoutunavailable. That's not so noble ;)

I wish we would only allow nfserr_* and your first patch
defines the allowed returns from layoutget

(I can fix exofs, easily, if we just agree on protocol)

Thanks
Boaz
>  
>  	res->lg_seg.layout_type = LAYOUT_NFSV4_FILES;
>  	/* Always give out whole file layouts */

