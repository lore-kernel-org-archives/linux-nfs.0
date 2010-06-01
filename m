From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/2] pnfsd: make /proc/fs/nfsd/pnfs_dlm_device report
 dlm device list.
Date: Tue, 01 Jun 2010 07:36:19 +0300
Message-ID: <4C048E43.4060500@panasas.com>
References: <1275066921-29335-1-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Eric Anderle <eanderle@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:6922 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750768Ab0FAEg0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jun 2010 00:36:26 -0400
In-Reply-To: <1275066921-29335-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

merged to pnfsd-files

Thanks!

Benny

On May. 28, 2010, 20:15 +0300, "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> From: Eric Anderle <eanderle@umich.edu>
> 
> The ability to read the current device list is useful for debugging.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfsd/nfs4pnfsdlm.c            |   25 +++++++++++++++++++++++++
>  fs/nfsd/nfsctl.c                 |    4 +++-
>  include/linux/nfsd/nfs4pnfsdlm.h |    2 ++
>  3 files changed, 30 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
> index 0cc295c..0351d71 100644
> --- a/fs/nfsd/nfs4pnfsdlm.c
> +++ b/fs/nfsd/nfs4pnfsdlm.c
> @@ -62,6 +62,31 @@ nfsd4_find_pnfs_dlm_device(char *disk_name)
>  	return NULL;
>  }
>  
> +ssize_t
> +nfsd4_get_pnfs_dlm_device_list(char *buf, ssize_t buflen)
> +{
> +	char *pos = buf;
> +	ssize_t size = 0;
> +	struct dlm_device_entry *dlm_pdev;
> +	int ret = -EINVAL;
> +
> +	spin_lock(&dlm_device_list_lock);
> +	list_for_each_entry(dlm_pdev, &dlm_device_list, dlm_dev_list)
> +	{
> +		int advanced;
> +		advanced = snprintf(pos, buflen - size, "%s:%s\n", dlm_pdev->disk_name, dlm_pdev->ds_list);
> +		if (advanced >= buflen - size)
> +			goto out;
> +		size += advanced;
> +		pos += advanced;
> +	}
> +	ret = size;
> +
> +out:
> +	spin_unlock(&dlm_device_list_lock);
> +	return ret;
> +}
> +
>  /*
>   * pnfs_dlm_device string format:
>   *     block-device-path:<ds1 ipv4 address>,<ds2 ipv4 address>
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 51b0ae1..034d96f 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -1352,7 +1352,9 @@ static ssize_t __write_pnfs_dlm_device(struct file *file, char *buf,
>  			return ret;
>  
>  		ret = nfsd4_set_pnfs_dlm_device(pnfs_dlm_device, len);
> -	}
> +	} else
> +		return nfsd4_get_pnfs_dlm_device_list(buf, SIMPLE_TRANSACTION_LIMIT);
> +
>  	return ret <= 0 ? ret : strlen(buf);
>  }
>  
> diff --git a/include/linux/nfsd/nfs4pnfsdlm.h b/include/linux/nfsd/nfs4pnfsdlm.h
> index a961c1e..eb31123 100644
> --- a/include/linux/nfsd/nfs4pnfsdlm.h
> +++ b/include/linux/nfsd/nfs4pnfsdlm.h
> @@ -42,6 +42,8 @@ int nfsd4_set_pnfs_dlm_device(char *pnfs_dlm_device, int len);
>  
>  void nfsd4_pnfs_dlm_shutdown(void);
>  
> +ssize_t nfsd4_get_pnfs_dlm_device_list(char *buf, ssize_t buflen);
> +
>  #else /* CONFIG_PNFSD */
>  
>  static inline void nfsd4_pnfs_dlm_shutdown(void)


-- 
Benny Halevy
Software Architect
Panasas, Inc.
bhalevy@panasas.com
Tel/Fax: +972-3-647-8340
Mobile: +972-54-802-8340

Panasas: The Leader in Parallel Storage
www.panasas.com
