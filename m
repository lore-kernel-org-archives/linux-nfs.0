From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 2/2] pnfsd: fix test in nfsd4_find_pnfs_dlm_device
Date: Fri, 28 May 2010 13:20:04 -0400
Message-ID: <20100528172004.GB29366@fieldses.org>
References: <1275066921-29335-1-git-send-email-bfields@citi.umich.edu> <1275066921-29335-2-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Eric Anderle <eanderle@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43381 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755136Ab0E1RUE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 May 2010 13:20:04 -0400
In-Reply-To: <1275066921-29335-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 28, 2010 at 01:15:21PM -0400, J. Bruce Fields wrote:
> From: Eric Anderle <eanderle@umich.edu>
> 
> This test is obviously backwards.  Noticed because pnfs_dlm_device was
> allowing us to re-add the same disk multiple times.

But how did getdeviceinfo ever work?

--b.

> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfsd/nfs4pnfsdlm.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
> index 0351d71..1cf1b69 100644
> --- a/fs/nfsd/nfs4pnfsdlm.c
> +++ b/fs/nfsd/nfs4pnfsdlm.c
> @@ -53,7 +53,7 @@ nfsd4_find_pnfs_dlm_device(char *disk_name)
>  
>  	spin_lock(&dlm_device_list_lock);
>  	list_for_each_entry(dlm_pdev, &dlm_device_list, dlm_dev_list) {
> -		if (memcmp(dlm_pdev->disk_name, disk_name, strlen(disk_name))) {
> +		if (!memcmp(dlm_pdev->disk_name, disk_name, strlen(disk_name))) {
>  			spin_unlock(&dlm_device_list_lock);
>  			return dlm_pdev;
>  		}
> -- 
> 1.7.0.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
