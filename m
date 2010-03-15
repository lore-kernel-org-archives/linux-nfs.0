From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 10/22] Add new pipefs file indicating which Kerberos
	enctypes the kernel supports
Date: Mon, 15 Mar 2010 19:43:30 -0400
Message-ID: <20100315234330.GB25710@fieldses.org>
References: <1268655627-18712-1-git-send-email-steved@redhat.com> <1268655627-18712-11-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60752 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932779Ab0COXlw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Mar 2010 19:41:52 -0400
In-Reply-To: <1268655627-18712-11-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 15, 2010 at 08:20:15AM -0400, steved@redhat.com wrote:
> From: Kevin Coffman <kwc@citi.umich.edu>
> 
> New file, krb5_info, indicates which Kerberos encryption types are
> supported by the kernel rpcsecgss code.  This is used by gssd to
> determine which encryption types it should attempt to negotiate
> when creating a context with a server.
> 
> The server principal's database and keytab encryption types are
> what limits what it should negotiate.  Therefore, its keytab
> should be created with only the enctypes listed by this file.
> 
> From: J. Bruce Fields <bfields@citi.umich.edu>
> Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  net/sunrpc/rpc_pipe.c |   31 +++++++++++++++++++++++++++++++
>  1 files changed, 31 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> index 8d63f8f..2230b52 100644
> --- a/net/sunrpc/rpc_pipe.c
> +++ b/net/sunrpc/rpc_pipe.c
> @@ -397,6 +397,31 @@ static const struct file_operations rpc_info_operations = {
>  	.release	= rpc_info_release,
>  };
>  
> +/*
> + * This really belongs in the gss_krb5 code,
> + * but the info file logically belongs here
> + */
> +static int
> +rpc_show_krb5_info(struct seq_file *m, void *v)
> +{
> +	seq_printf(m, "enctypes: 3,1,2\n");

There was originally some idea we should move this to the upcall itself
(so just add "enctypes=3,1,2" to the upcall).

But actually as long as it's not really per-upcall information, I think
it makes sense to leave it in a krb5_info file like this.

--b.

> +	return 0;
> +}
> +
> +static int
> +rpc_krb5_info_open(struct inode *inode, struct file *file)
> +{
> +	return single_open(file, rpc_show_krb5_info, NULL);
> +}
> +
> +static struct file_operations krb5_info_operations = {
> +	.owner		= THIS_MODULE,
> +	.open		= rpc_krb5_info_open,
> +	.read		= seq_read,
> +	.llseek		= seq_lseek,
> +	.release	= single_release,
> +};
> +
>  
>  /*
>   * Description of fs contents.
> @@ -949,6 +974,7 @@ enum {
>  	RPCAUTH_portmap,
>  	RPCAUTH_statd,
>  	RPCAUTH_nfsd4_cb,
> +	RPCAUTH_krb5_info,
>  	RPCAUTH_cache,
>  	RPCAUTH_RootEOF
>  };
> @@ -982,6 +1008,11 @@ static const struct rpc_filelist files[] = {
>  		.name = "cache",
>  		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
>  	},
> +	[RPCAUTH_krb5_info] = {
> +		.name = "krb5_info",
> +		.i_fop = &krb5_info_operations,
> +		.mode = S_IFREG | S_IRUSR,
> +	},
>  };
>  
>  static int
> -- 
> 1.6.6.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
