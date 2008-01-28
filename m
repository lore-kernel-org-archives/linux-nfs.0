From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 021/100] nfsd: fail init on /proc/fs/nfs/exports creation failure
Date: Mon, 28 Jan 2008 14:40:20 -0500
Message-ID: <B595219E-9D7E-4544-8E1C-422D2DC7D996@oracle.com>
References: <20080125231521.GG25141@fieldses.org> <1201303040-7779-1-git-send-email-bfields@citi.umich.edu> <1201303040-7779-2-git-send-email-bfields@citi.umich.edu> <1201303040-7779-3-git-send-email-bfields@citi.umich.edu> <1201303040-7779-4-git-send-email-bfields@citi.umich.edu> <1201303040-7779-5-git-send-email-bfields@citi.umich.edu> <1201303040-7779-6-git-send-email-bfields@citi.umich.edu> <1201303040-7779-7-git-send-email-bfields@citi.umich.edu> <1201303040-7779-8-git-send-email-bfields@citi.umich.edu> <1201303040-7779-9-git-send-email-bfields@citi.umich.edu> <1201303040-7779-10-git-send-email-bfields@citi.umich.edu> <1201303040-7779-11-git-send-email-bfields@citi.umich.edu> <1201303040-7779-12-git-send-email-bfields@citi.umich.edu> <1201303040-7779-13-git-send-email-bfields@citi.umi
 ch.edu> <1201303040-7779-14-git-send-email-bfields@citi.umich.edu> <1201303040-7779-15-git-send-email-bfields@citi.umich.edu> <1201303040-7779-16-git-send-email-bfields@citi.umich.edu> <120!
 1303040-7779-17-git-send-email-bfields@citi.umich.edu> <1201303040-7779-18-git-send-email-bfields@citi.umich.edu> <1201303040-7779-19-git-send-email-bfields@citi.umich.edu> <1201303040-7779-20-git-send-email-bfields@citi.umich.edu> <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:61979 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758723AbYA1Tk4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2008 14:40:56 -0500
In-Reply-To: <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 25, 2008, at 6:16 PM, J. Bruce Fields wrote:
> I assume the reason failure of creation was ignored here was just to
> continue support embedded systems that want nfsd but not proc.
>
> However, in cases where proc is supported it would be clearer to fail
> entirely than to come up with some features disabled.
>
> Acked-by: NeilBrown <neilb@suse.de>
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfsd/nfsctl.c |   37 ++++++++++++++++++++++++++++---------
>  1 files changed, 28 insertions(+), 9 deletions(-)
>
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 2bfda9b..63d8075 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -674,6 +674,27 @@ static struct file_system_type nfsd_fs_type = {
>  	.kill_sb	= kill_litter_super,
>  };
>
> +#ifdef CONFIG_PROC_FS
> +static inline int create_proc_exports_entry(void)

Nit: "inline" is probably not needed here.

> +{
> +	struct proc_dir_entry *entry;
> +
> +	entry = proc_mkdir("fs/nfs", NULL);
> +	if (!entry)
> +		return -ENOMEM;
> +	entry = create_proc_entry("fs/nfs/exports", 0, NULL);
> +	if (!entry)
> +		return -ENOMEM;
> +	entry->proc_fops =  &exports_operations;
> +	return 0;
> +}
> +#else /* CONFIG_PROC_FS */
> +static inline int create_proc_exports_entry(void)
> +{
> +	return 0;
> +}
> +#endif
> +
>  static int __init init_nfsd(void)
>  {
>  	int retval;
> @@ -689,23 +710,21 @@ static int __init init_nfsd(void)
>  	nfsd_export_init();	/* Exports table */
>  	nfsd_lockd_init();	/* lockd->nfsd callbacks */
>  	nfsd_idmap_init();      /* Name to ID mapping */
> -	if (proc_mkdir("fs/nfs", NULL)) {
> -		struct proc_dir_entry *entry;
> -		entry = create_proc_entry("fs/nfs/exports", 0, NULL);
> -		if (entry)
> -			entry->proc_fops =  &exports_operations;
> -	}
> +	retval = create_proc_exports_entry();
> +	if (retval)
> +		goto out_free_idmap;
>  	retval = register_filesystem(&nfsd_fs_type);
>  	if (retval)
>  		goto out_free_all;
>  	return 0;
>  out_free_all:
> -	nfsd_idmap_shutdown();
> -	nfsd_export_shutdown();
> -	nfsd_reply_cache_shutdown();
>  	remove_proc_entry("fs/nfs/exports", NULL);
>  	remove_proc_entry("fs/nfs", NULL);
> +	nfsd_idmap_shutdown();
> +out_free_idmap:
>  	nfsd_lockd_shutdown();
> +	nfsd_export_shutdown();
> +	nfsd_reply_cache_shutdown();
>  out_free_stat:
>  	nfsd_stat_shutdown();
>  	nfsd4_free_slabs();

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
