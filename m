Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39407 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754808Ab3EFPcR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 May 2013 11:32:17 -0400
Date: Mon, 6 May 2013 11:32:14 -0400
To: Weston Andros Adamson <dros@netapp.com>
Cc: chuck.lever@oracle.com, Trond.Myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSv3: match sec= flavor against server list
Message-ID: <20130506153214.GE15476@fieldses.org>
References: <1367846874-1234-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1367846874-1234-1-git-send-email-dros@netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 06, 2013 at 09:27:54AM -0400, Weston Andros Adamson wrote:
> Older clients match the 'sec=' mount option flavor against the server's
> flavor list (if available) and return EPERM if the specified flavor is not
> found. Recent changes would skip this step and allow the vfs mount even
> though no operations will succeed.
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> 
> Hey Chuck,
> 
> This fixes a regression that was introduced with the recent nfs_select_flavor 
> changes - I'm pretty sure we want to match the specified flavor instead of just
> using it.
> 
> Example of the regression:
> 
> the server's /etc/exports:
> 
> /export/krb5      *(sec=krb5,sec=none,rw,no_root_squash)
> 
> old client behavior:
> 
> $ uname -a
> Linux one.apikia.fake 3.8.8-202.fc18.x86_64 #1 SMP Wed Apr 17 23:25:17 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux
> $ sudo mount -v -o sec=sys,vers=3 zero:/export/krb5 /mnt
> mount.nfs: timeout set for Sun May  5 17:32:04 2013
> mount.nfs: trying text-based options 'sec=sys,vers=3,addr=192.168.100.10'
> mount.nfs: prog 100003, trying vers=3, prot=6
> mount.nfs: trying 192.168.100.10 prog 100003 vers 3 prot TCP port 2049
> mount.nfs: prog 100005, trying vers=3, prot=17
> mount.nfs: trying 192.168.100.10 prog 100005 vers 3 prot UDP port 20048
> mount.nfs: mount(2): Permission denied
> mount.nfs: access denied by server while mounting zero:/export/krb5
> 
> recently changed behavior:
> 
> $ uname -a
> Linux one.apikia.fake 3.9.0-testing+ #2 SMP Fri May 3 20:29:32 EDT 2013 x86_64 x86_64 x86_64 GNU/Linux
> $ sudo mount -v -o sec=sys,vers=3 zero:/export/krb5 /mnt
> mount.nfs: timeout set for Sun May  5 17:37:17 2013
> mount.nfs: trying text-based options 'sec=sys,vers=3,addr=192.168.100.10'
> mount.nfs: prog 100003, trying vers=3, prot=6
> mount.nfs: trying 192.168.100.10 prog 100003 vers 3 prot TCP port 2049
> mount.nfs: prog 100005, trying vers=3, prot=17
> mount.nfs: trying 192.168.100.10 prog 100005 vers 3 prot UDP port 20048
> $ ls /mnt
> ls: cannot open directory /mnt: Permission denied
> $ sudo ls /mnt
> ls: cannot open directory /mnt: Permission denied
> $ sudo df /mnt
> df: ‘/mnt’: Permission denied
> df: no file systems processed
> $ sudo umount /mnt
> $
> 
> I also made an attempt to support "AUTH_NULL means the server will ignore the
> cred, so just use the specified flavor" behavior from much older kernels, but 
> I'm not sure if we want this logic.
> 
> I'd actually prefer getting rid of this AUTH_NULL logic, it's just that some 
> older clients (RHEL 5, etc) would succeed in mounting when sec=sys specified,
> server list = [AUTH_NULL] (the client ends up sending AUTH_UNIX creds that are
> ignored by the server), while newer kernels do not. The workaround in newer
> kernels is to specify sec=none.

Nit: the above examples would actually be really useful, for example, to
a distribution maintainer trying to figure out whether this patch would
solve a given user problem.

Could you include them in the changelog?

--b.

> 
> Thoughts?
> 
>  -dros
> 
>  fs/nfs/super.c | 39 ++++++++++++++++++++++++++++++++-------
>  1 file changed, 32 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index eb494f6..6476b5d 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1611,14 +1611,12 @@ out_security_failure:
>   * Select a security flavor for this mount.  The selected flavor
>   * is planted in args->auth_flavors[0].
>   */
> -static void nfs_select_flavor(struct nfs_parsed_mount_data *args,
> +static int nfs_select_flavor(struct nfs_parsed_mount_data *args,
>  			      struct nfs_mount_request *request)
>  {
>  	unsigned int i, count = *(request->auth_flav_len);
>  	rpc_authflavor_t flavor;
> -
> -	if (args->auth_flavors[0] != RPC_AUTH_MAXFLAVOR)
> -		goto out;
> +	bool auth_null_seen = false;
>  
>  	/*
>  	 * The NFSv2 MNT operation does not return a flavor list.
> @@ -1634,6 +1632,26 @@ static void nfs_select_flavor(struct nfs_parsed_mount_data *args,
>  		goto out_default;
>  
>  	/*
> +	 * If the sec= mount option is used, the flavor must be in the list
> +	 * returned by the server.
> +	 *
> +	 * One exception is when the server's flavor list includes AUTH_NULL:
> +	 * Some servers implement AUTH_NULL by completely ignoring the rpc
> +	 * cred, so the client can use any flavor.
> +	 */
> +	if (args->auth_flavors[0] != RPC_AUTH_MAXFLAVOR) {
> +		for (i = 0; i < count; i++) {
> +			if (args->auth_flavors[0] == request->auth_flavs[i])
> +				goto out;
> +			if (request->auth_flavs[i] == RPC_AUTH_NULL)
> +				auth_null_seen = true;
> +		}
> +		if (auth_null_seen)
> +			goto out;
> +		goto out_nomatch;
> +	}
> +
> +	/*
>  	 * RFC 2623, section 2.7 suggests we SHOULD prefer the
>  	 * flavor listed first.  However, some servers list
>  	 * AUTH_NULL first.  Avoid ever choosing AUTH_NULL.
> @@ -1654,11 +1672,19 @@ static void nfs_select_flavor(struct nfs_parsed_mount_data *args,
>  	}
>  
>  out_default:
> -	flavor = RPC_AUTH_UNIX;
> +	/* use default if flavor not already set */
> +	flavor = (args->auth_flavors[0] == RPC_AUTH_MAXFLAVOR) ?
> +		RPC_AUTH_UNIX : args->auth_flavors[0];
>  out_set:
>  	args->auth_flavors[0] = flavor;
>  out:
>  	dfprintk(MOUNT, "NFS: using auth flavor %d\n", args->auth_flavors[0]);
> +	return 0;
> +
> +out_nomatch:
> +	dfprintk(MOUNT, "NFS: auth flavor %d not supported by server\n",
> +		args->auth_flavors[0]);
> +	return -EPERM;
>  }
>  
>  /*
> @@ -1721,8 +1747,7 @@ static int nfs_request_mount(struct nfs_parsed_mount_data *args,
>  		return status;
>  	}
>  
> -	nfs_select_flavor(args, &request);
> -	return 0;
> +	return nfs_select_flavor(args, &request);
>  }
>  
>  struct dentry *nfs_try_mount(int flags, const char *dev_name,
> -- 
> 1.7.12.4 (Apple Git-37)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
