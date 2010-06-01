From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 2/2] pnfsd: fix test in nfsd4_find_pnfs_dlm_device
Date: Tue, 01 Jun 2010 07:36:43 +0300
Message-ID: <4C048E5B.5070001@panasas.com>
References: <1275066921-29335-1-git-send-email-bfields@citi.umich.edu> <1275066921-29335-2-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, Eric Anderle <eanderle@umich.edu>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:44945 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750865Ab0FAEgq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jun 2010 00:36:46 -0400
In-Reply-To: <1275066921-29335-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

merged to pnfsd-files and pnfs-all-2.6.33

Thanks!

Benny

On May. 28, 2010, 20:15 +0300, "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> From: Eric Anderle <eanderle@umich.edu>
> 
> This test is obviously backwards.  Noticed because pnfs_dlm_device was
> allowing us to re-add the same disk multiple times.
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
