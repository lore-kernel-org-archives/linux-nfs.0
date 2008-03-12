From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 04/19] Add new pipefs file indicating which Kerberos
	enctypes the kernel supports
Date: Wed, 12 Mar 2008 12:37:17 -0400
Message-ID: <20080312163717.GD10015@fieldses.org>
References: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu> <20080221184407.19195.62074.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trond@netapp.com>
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33148 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751385AbYCLQhU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Mar 2008 12:37:20 -0400
In-Reply-To: <20080221184407.19195.62074.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 21, 2008 at 01:44:07PM -0500, Kevin Coffman wrote:
> New file, krb5_info, indicates which Kerberos encryption types are
> supported by the kernel rpcsecgss code.  This is used by gssd to
> determine which encryption types it should attempt to negotiate
> when creating a context with a server.
> 
> The server principal's database and keytab encryption types are
> what limits what it should negotiate.  Therefore, its keytab
> should be created with only the enctypes listed by this file.

Trond?  Any comments on this approach?  The new "krb5_info" file is
added to the root directory of rpc_pipefs.

I suppose we could instead add it to the new (text-based) upcall.  My
only objection to that would be that it might be inefficient to add to
the upcall information that's constant across all servers and protocols.
But I suppose it's unlikely to be enough data to matter.

--b.

> 
> From: J. Bruce Fields <bfields@citi.umich.edu>
> Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
> ---
> 
>  net/sunrpc/rpc_pipe.c |   31 +++++++++++++++++++++++++++++++
>  1 files changed, 31 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> index 7e19716..5781862 100644
> --- a/net/sunrpc/rpc_pipe.c
> +++ b/net/sunrpc/rpc_pipe.c
> @@ -385,6 +385,31 @@ static const struct file_operations rpc_info_operations = {
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
>   * We have a single directory with 1 node in it.
> @@ -396,6 +421,7 @@ enum {
>  	RPCAUTH_nfs,
>  	RPCAUTH_portmap,
>  	RPCAUTH_statd,
> +	RPCAUTH_krb5_info,
>  	RPCAUTH_RootEOF
>  };
>  
> @@ -429,6 +455,11 @@ static struct rpc_filelist files[] = {
>  		.name = "statd",
>  		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
>  	},
> +	[RPCAUTH_krb5_info] = {
> +		.name = "krb5_info",
> +		.i_fop = &krb5_info_operations,
> +		.mode = S_IFREG | S_IRUSR,
> +	},
>  };
>  
>  enum {
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
