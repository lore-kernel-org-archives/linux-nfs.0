Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53669 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758005Ab3DXV4n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Apr 2013 17:56:43 -0400
Date: Wed, 24 Apr 2013 17:56:41 -0400
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 02/17] NFSv4.2: Added NFS v4.2 support to the NFS client
Message-ID: <20130424215640.GM20275@fieldses.org>
References: <1366834683-29075-1-git-send-email-SteveD@redhat.com>
 <1366834683-29075-3-git-send-email-SteveD@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1366834683-29075-3-git-send-email-SteveD@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 24, 2013 at 04:17:48PM -0400, Steve Dickson wrote:
> From: Steve Dickson <steved@redhat.com>
> 
> This enable NFSv4.2 support. To enable this code the
> CONFIG_NFS_V4_2 Kconfig define needs to be set and
> the -o v4.2 mount option need to be used.

Looks fine to me.--b.

> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  fs/nfs/Kconfig       |  9 +++++++++
>  fs/nfs/callback.c    |  1 +
>  fs/nfs/nfs4client.c  |  5 +++++
>  fs/nfs/nfs4proc.c    | 15 +++++++++++++++
>  fs/nfs/super.c       |  7 ++++++-
>  include/linux/nfs4.h |  4 ++++
>  6 files changed, 40 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> index 13ca196..79c500e 100644
> --- a/fs/nfs/Kconfig
> +++ b/fs/nfs/Kconfig
> @@ -104,6 +104,15 @@ config NFS_V4_1
>  
>  	  If unsure, say N.
>  
> +config NFS_V4_2
> +	bool "NFS client support for NFSv4.2"
> +	depends on NFS_V4_1
> +	help
> +	  This option enables support for minor version 1 of the NFSv4 protocol
> +	  in the kernel's NFS client.
> +
> +	  If unsure, say N.
> +
>  config PNFS_FILE_LAYOUT
>  	tristate
>  	depends on NFS_V4_1
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 5088b57..cb35747 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -279,6 +279,7 @@ static int nfs_callback_up_net(int minorversion, struct svc_serv *serv, struct n
>  			ret = nfs4_callback_up_net(serv, net);
>  			break;
>  		case 1:
> +		case 2:
>  			ret = nfs41_callback_up_net(serv, net);
>  			break;
>  		default:
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index 66b6664..a30c6a7 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -66,6 +66,11 @@ struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
>  	if (err)
>  		goto error;
>  
> +	if (cl_init->minorversion > NFS4_MAX_MINOR_VERSION) {
> +		err = -EINVAL;
> +		goto error;
> +	}
> +		
>  	spin_lock_init(&clp->cl_lock);
>  	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
>  	rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 0ad025e..3fd1040 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -6746,11 +6746,26 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
>  };
>  #endif
>  
> +#if defined(CONFIG_NFS_V4_2)
> +static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
> +	.minor_version = 2,
> +	.call_sync = nfs4_call_sync_sequence,
> +	.match_stateid = nfs41_match_stateid,
> +	.find_root_sec = nfs41_find_root_sec,
> +	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
> +	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
> +	.state_renewal_ops = &nfs41_state_renewal_ops,
> +};
> +#endif
> +
>  const struct nfs4_minor_version_ops *nfs_v4_minor_ops[] = {
>  	[0] = &nfs_v4_0_minor_ops,
>  #if defined(CONFIG_NFS_V4_1)
>  	[1] = &nfs_v4_1_minor_ops,
>  #endif
> +#if defined(CONFIG_NFS_V4_2)
> +	[2] = &nfs_v4_2_minor_ops,
> +#endif
>  };
>  
>  const struct inode_operations nfs4_dir_inode_operations = {
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 2f8a29d..29f2d86 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -269,7 +269,7 @@ static match_table_t nfs_local_lock_tokens = {
>  
>  enum {
>  	Opt_vers_2, Opt_vers_3, Opt_vers_4, Opt_vers_4_0,
> -	Opt_vers_4_1,
> +	Opt_vers_4_1, Opt_vers_4_2,
>  
>  	Opt_vers_err
>  };
> @@ -280,6 +280,7 @@ static match_table_t nfs_vers_tokens = {
>  	{ Opt_vers_4, "4" },
>  	{ Opt_vers_4_0, "4.0" },
>  	{ Opt_vers_4_1, "4.1" },
> +	{ Opt_vers_4_2, "4.2" },
>  
>  	{ Opt_vers_err, NULL }
>  };
> @@ -1097,6 +1098,10 @@ static int nfs_parse_version_string(char *string,
>  		mnt->version = 4;
>  		mnt->minorversion = 1;
>  		break;
> +	case Opt_vers_4_2:
> +		mnt->version = 4;
> +		mnt->minorversion = 2;
> +		break;
>  	default:
>  		return 0;
>  	}
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 377fb3f..7e18a66 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -398,11 +398,15 @@ enum lock_type4 {
>  #define NFS4_VERSION 4
>  #define NFS4_MINOR_VERSION 0
>  
> +#if defined(CONFIG_NFS_V4_2)
> +#define NFS4_MAX_MINOR_VERSION 2
> +#else
>  #if defined(CONFIG_NFS_V4_1)
>  #define NFS4_MAX_MINOR_VERSION 1
>  #else
>  #define NFS4_MAX_MINOR_VERSION 0
>  #endif /* CONFIG_NFS_V4_1 */
> +#endif /* CONFIG_NFS_V4_2 */
>  
>  #define NFS4_DEBUG 1
>  
> -- 
> 1.8.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
