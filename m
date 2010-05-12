From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/1] SQUASHME pnfs_submit: move unmount_pnfs_layoutdriver
 call
Date: Wed, 12 May 2010 09:52:17 +0300
Message-ID: <4BEA5021.1080406@panasas.com>
References: <1273616691-4299-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bharrosh@panasas.com, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:31413 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698Ab0ELGwW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 May 2010 02:52:22 -0400
Received: by fg-out-1718.google.com with SMTP id d23so365176fga.1
        for <linux-nfs@vger.kernel.org>; Tue, 11 May 2010 23:52:21 -0700 (PDT)
In-Reply-To: <1273616691-4299-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-05-12 01:24, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> from nfs4_kill_super to nfs_free_server. Fixes a bug reported by Boaz Harrosh
> where the deviceid cache is not defererenced on super block creation error or
> for two mounts that share a super block.

Looks good to me.
Thanks!

Benny

> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/client.c |    9 +++++++++
>  fs/nfs/super.c  |    3 ---
>  2 files changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 56f3d50..0337330 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -884,6 +884,14 @@ static void nfs4_init_pnfs(struct nfs_server *server, struct nfs_fsinfo *fsinfo)
>  #endif /* CONFIG_NFS_V4_1 */
>  }
>  
> +static void nfs4_uninit_pnfs(struct nfs_server *server)
> +{
> +#if defined(CONFIG_NFS_V4_1)
> +	if (nfs4_has_session(server->nfs_client))
> +		unmount_pnfs_layoutdriver(server);
> +#endif /* CONFIG_NFS_V4_1 */
> +}
> +
>  /*
>   * Load up the server record from information gained in an fsinfo record
>   */
> @@ -1039,6 +1047,7 @@ void nfs_free_server(struct nfs_server *server)
>  {
>  	dprintk("--> nfs_free_server()\n");
>  
> +	nfs4_uninit_pnfs(server);
>  	spin_lock(&nfs_client_lock);
>  	list_del(&server->client_link);
>  	list_del(&server->master_link);
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 5fc60cf..7822187 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -2799,9 +2799,6 @@ static void nfs4_kill_super(struct super_block *sb)
>  	dprintk("--> %s\n", __func__);
>  	nfs_super_return_all_delegations(sb);
>  	kill_anon_super(sb);
> -#ifdef CONFIG_NFS_V4_1
> -	unmount_pnfs_layoutdriver(server);
> -#endif
>  	nfs_fscache_release_super_cookie(sb);
>  	nfs_free_server(server);
>  	dprintk("<-- %s\n", __func__);

