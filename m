From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 22/27] NFS: text-based mounts should support
	multiple	security flavors
Date: Fri, 26 Oct 2007 14:54:27 -0400
Message-ID: <1193424867.7486.43.camel@heimdal.trondhjem.org>
References: <20071026173234.31475.2268.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlUJL-0006rh-0K
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 11:53:41 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IlUJN-0005Cx-A3
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 11:53:40 -0700
In-Reply-To: <20071026173234.31475.2268.stgit@manray.1015granger.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


On Fri, 2007-10-26 at 13:32 -0400, Chuck Lever wrote:
> Add support to the in-kernel NFS mount option parser for handling multiple
> security flavors.
> 
> This does not implement support for multiple security flavors in the
> underlying NFS or mountd clients.  When that support is added, simply crank
> up the value of the MAX_SECURITY_FLAVORS macro, and that will enable the
> mount option parser to grok colons and multiple security flavors.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfs/internal.h |    5 +-
>  fs/nfs/super.c    |  173 ++++++++++++++++++++++++++++++-----------------------
>  2 files changed, 103 insertions(+), 75 deletions(-)
> 
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 99a74a7..5f93512 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -28,6 +28,9 @@ struct nfs_clone_mount {
>  /*
>   * In-kernel mount arguments
>   */
> +
> +#define MAX_SECURITY_FLAVORS	(1)
> +
>  struct nfs_parsed_mount_data {
>  	int			flags;
>  	int			rsize, wsize;
> @@ -37,7 +40,7 @@ struct nfs_parsed_mount_data {
>  	int			namlen;
>  	unsigned int		bsize;
>  	unsigned int		auth_flavor_len;
> -	rpc_authflavor_t	auth_flavors[1];
> +	rpc_authflavor_t	auth_flavors[MAX_SECURITY_FLAVORS];
>  	char			*client_address;
>  
>  	struct {
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index be96a8c..5c553b1 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -590,6 +590,99 @@ static int nfs_verify_server_address(struct sockaddr *addr)
>  }
>  
>  /*
> + * Parse the value of the 'sec=' option.
> + */
> +static int nfs_parse_security_flavors(char *value,
> +				      struct nfs_parsed_mount_data *mnt)
> +{
> +	char *p, *string;
> +
> +	mnt->auth_flavor_len = 0;
> +
> +	while ((p = strsep(&value, ":")) != NULL) {
> +		substring_t args[MAX_OPT_ARGS];
> +		int token;
> +
> +		if (!*p)
> +			continue;
> +
> +		if (mnt->auth_flavor_len >= MAX_SECURITY_FLAVORS)
> +			goto out_inval_auth;
> +
> +		string = match_strdup(args);
> +		if (string == NULL)
> +			goto out_nomem;
> +		token = match_token(string, nfs_secflavor_tokens, args);
> +		kfree(string);
> +
> +		switch (token) {
> +		case Opt_sec_none:
> +			mnt->auth_flavors[mnt->auth_flavor_len] =
> +							RPC_AUTH_NULL;
> +			break;
> +		case Opt_sec_sys:
> +			mnt->auth_flavors[mnt->auth_flavor_len] =
> +							RPC_AUTH_UNIX;
> +			break;
> +		case Opt_sec_krb5:
> +			mnt->auth_flavors[mnt->auth_flavor_len] =
> +							RPC_AUTH_GSS_KRB5;
> +			break;
> +		case Opt_sec_krb5i:
> +			mnt->auth_flavors[mnt->auth_flavor_len] =
> +							RPC_AUTH_GSS_KRB5I;
> +			break;
> +		case Opt_sec_krb5p:
> +			mnt->auth_flavors[mnt->auth_flavor_len] =
> +							RPC_AUTH_GSS_KRB5P;
> +			break;
> +		case Opt_sec_lkey:
> +			mnt->auth_flavors[mnt->auth_flavor_len] =
> +							RPC_AUTH_GSS_LKEY;
> +			break;
> +		case Opt_sec_lkeyi:
> +			mnt->auth_flavors[mnt->auth_flavor_len] =
> +							RPC_AUTH_GSS_LKEYI;
> +			break;
> +		case Opt_sec_lkeyp:
> +			mnt->auth_flavors[mnt->auth_flavor_len] =
> +							RPC_AUTH_GSS_LKEYP;
> +			break;
> +		case Opt_sec_spkm:
> +			mnt->auth_flavors[mnt->auth_flavor_len] =
> +							RPC_AUTH_GSS_SPKM;
> +			break;
> +		case Opt_sec_spkmi:
> +			mnt->auth_flavors[mnt->auth_flavor_len] =
> +							RPC_AUTH_GSS_SPKMI;
> +			break;
> +		case Opt_sec_spkmp:
> +			mnt->auth_flavors[mnt->auth_flavor_len] =
> +							RPC_AUTH_GSS_SPKMP;
> +			break;
> +		default:
> +			goto out_unrec_sec;
> +		}
> +
> +		mnt->auth_flavor_len++;
> +	}
> +
> +	return 1;
> +
> +out_nomem:
> +	printk(KERN_INFO "NFS: not enough memory to parse sec= option\n");
> +	return 0;
> +
> +out_unrec_sec:
> +	printk(KERN_INFO "NFS: unrecognized security flavor\n");
> +	return 0;
> +
> +out_inval_auth:
> +	printk(KERN_INFO "NFS: Too many security flavors\n");
> +	return 0;
> +}
> +

So where do you now set or clear NFS_MOUNT_SECFLAVOUR?

> +/*
>   * Error-check and convert a string of mount options from user space into
>   * a data structure
>   */
> @@ -787,73 +880,10 @@ static int nfs_parse_mount_options(char *raw,
>  			string = match_strdup(args);
>  			if (string == NULL)
>  				goto out_nomem;
> -			token = match_token(string, nfs_secflavor_tokens, args);
> +			token = nfs_parse_security_flavors(string, mnt);
>  			kfree(string);
> -
> -			/*
> -			 * The flags setting is for v2/v3.  The flavor_len
> -			 * setting is for v4.  v2/v3 also need to know the
> -			 * difference between NULL and UNIX.
> -			 */
> -			switch (token) {
> -			case Opt_sec_none:
> -				mnt->flags &= ~NFS_MOUNT_SECFLAVOUR;
> -				mnt->auth_flavor_len = 0;
> -				mnt->auth_flavors[0] = RPC_AUTH_NULL;
> -				break;
> -			case Opt_sec_sys:
> -				mnt->flags &= ~NFS_MOUNT_SECFLAVOUR;
> -				mnt->auth_flavor_len = 0;
> -				mnt->auth_flavors[0] = RPC_AUTH_UNIX;
> -				break;
> -			case Opt_sec_krb5:
> -				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
> -				mnt->auth_flavor_len = 1;
> -				mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5;
> -				break;
> -			case Opt_sec_krb5i:
> -				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
> -				mnt->auth_flavor_len = 1;
> -				mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5I;
> -				break;
> -			case Opt_sec_krb5p:
> -				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
> -				mnt->auth_flavor_len = 1;
> -				mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5P;
> -				break;
> -			case Opt_sec_lkey:
> -				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
> -				mnt->auth_flavor_len = 1;
> -				mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEY;
> -				break;
> -			case Opt_sec_lkeyi:
> -				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
> -				mnt->auth_flavor_len = 1;
> -				mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEYI;
> -				break;
> -			case Opt_sec_lkeyp:
> -				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
> -				mnt->auth_flavor_len = 1;
> -				mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEYP;
> -				break;
> -			case Opt_sec_spkm:
> -				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
> -				mnt->auth_flavor_len = 1;
> -				mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKM;
> -				break;
> -			case Opt_sec_spkmi:
> -				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
> -				mnt->auth_flavor_len = 1;
> -				mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKMI;
> -				break;
> -			case Opt_sec_spkmp:
> -				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
> -				mnt->auth_flavor_len = 1;
> -				mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKMP;
> -				break;
> -			default:
> -				goto out_unrec_sec;
> -			}
> +			if (!token)
> +				return 0;
>  			break;
>  		case Opt_proto:
>  			string = match_strdup(args);
> @@ -955,10 +985,6 @@ out_unrec_xprt:
>  	printk(KERN_INFO "NFS: unrecognized transport protocol\n");
>  	return 0;
>  
> -out_unrec_sec:
> -	printk(KERN_INFO "NFS: unrecognized security flavor\n");
> -	return 0;
> -
>  out_unknown:
>  	printk(KERN_INFO "NFS: unknown mount option: %s\n", p);
>  	return 0;
> @@ -1050,6 +1076,7 @@ static int nfs_validate_mount_data(void *options,
>  	args->acdirmax		= 60;
>  	args->mount_server.protocol = XPRT_TRANSPORT_UDP;
>  	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
> +	args->auth_flavors[0] = RPC_AUTH_UNIX;
>  
>  	switch (data->version) {
>  	case 1:
> @@ -1104,7 +1131,8 @@ static int nfs_validate_mount_data(void *options,
>  		args->nfs_server.hostname = kstrdup(data->hostname, GFP_KERNEL);
>  		args->namlen		= data->namlen;
>  		args->bsize		= data->bsize;
> -		args->auth_flavors[0]	= data->pseudoflavor;
> +		if (data->flags & NFS_MOUNT_SECFLAVOUR)

                     Ehem! Please compare with the line you are moving.

> +			args->auth_flavors[0] = data->pseudoflavor;
>  		break;
>  	default: {
>  		unsigned int len;
> @@ -1138,9 +1166,6 @@ static int nfs_validate_mount_data(void *options,
>  		}
>  	}
>  
> -	if (!(args->flags & NFS_MOUNT_SECFLAVOUR))
> -		args->auth_flavors[0] = RPC_AUTH_UNIX;
> -
>  #ifndef CONFIG_NFS_V3
>  	if (args->flags & NFS_MOUNT_VER3)
>  		goto out_v3_not_compiled;
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
