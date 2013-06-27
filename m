Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:27036 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753258Ab3F0P5x convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jun 2013 11:57:53 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [PATCH v3 3/3] nfs: have NFSv3 try server-specified auth flavors in turn
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1372348207-26388-4-git-send-email-jlayton@redhat.com>
Date: Thu, 27 Jun 2013 11:57:43 -0400
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org,
        Weston.Adamson@netapp.com
Message-Id: <6915462D-43F4-4418-BB91-EB11AF82CE40@oracle.com>
References: <1372348207-26388-1-git-send-email-jlayton@redhat.com> <1372348207-26388-4-git-send-email-jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 27, 2013, at 11:50 AM, Jeff Layton <jlayton@redhat.com> wrote:

> The current scheme is to try and pick the auth flavor that the server
> prefers. In some cases though, we may find that we're not actually
> able to use that auth flavor later. For instance, the server may
> prefer an AUTH_GSS flavor, but we may not be able to get GSSAPI creds.
> 
> The current code just gives up at that point. Change it instead to
> try the ->create_server call using each of the different authflavors
> in the server's list if one was not specified at mount time. Once
> we have a successful ->create_server call, return the result. Only
> give up and return error if all attempts fail.
> 
> Cc: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> fs/nfs/super.c | 150 ++++++++++++++++++++++++++++++---------------------------
> 1 file changed, 80 insertions(+), 70 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index a0949f5..12ffd7d 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1608,29 +1608,13 @@ out_security_failure:
> }
> 
> /*
> - * Select a security flavor for this mount.  The selected flavor
> - * is planted in args->auth_flavors[0].
> - *
> - * Returns 0 on success, -EACCES on failure.
> + * Ensure that the specified authtype in args->auth_flavors[0] is supported by
> + * the server. Returns 0 if it's ok, and -EACCES if not.
>  */
> -static int nfs_select_flavor(struct nfs_parsed_mount_data *args,
> -			      struct nfs_mount_request *request)
> +static int nfs_verify_authflavor(struct nfs_parsed_mount_data *args,
> +			rpc_authflavor_t *server_authlist, unsigned int count)
> {
> -	unsigned int i, count = *(request->auth_flav_len);
> -	rpc_authflavor_t flavor;
> -
> -	/*
> -	 * The NFSv2 MNT operation does not return a flavor list.
> -	 */
> -	if (args->mount_server.version != NFS_MNT3_VERSION)
> -		goto out_default;
> -
> -	/*
> -	 * Certain releases of Linux's mountd return an empty
> -	 * flavor list in some cases.
> -	 */
> -	if (count == 0)
> -		goto out_default;
> +	unsigned int i;
> 
> 	/*
> 	 * If the sec= mount option is used, the specified flavor or AUTH_NULL
> @@ -1640,60 +1624,19 @@ static int nfs_select_flavor(struct nfs_parsed_mount_data *args,
> 	 * means that the server will ignore the rpc creds, so any flavor
> 	 * can be used.
> 	 */
> -	if (args->auth_flavors[0] != RPC_AUTH_MAXFLAVOR) {
> -		for (i = 0; i < count; i++) {
> -			if (args->auth_flavors[0] == request->auth_flavs[i] ||
> -			    request->auth_flavs[i] == RPC_AUTH_NULL)
> -				goto out;
> -		}
> -		dfprintk(MOUNT, "NFS: auth flavor %d not supported by server\n",
> -			args->auth_flavors[0]);
> -		goto out_err;
> -	}
> -
> -	/*
> -	 * RFC 2623, section 2.7 suggests we SHOULD prefer the
> -	 * flavor listed first.  However, some servers list
> -	 * AUTH_NULL first.  Avoid ever choosing AUTH_NULL.
> -	 */
> 	for (i = 0; i < count; i++) {
> -		struct rpcsec_gss_info info;
> -
> -		flavor = request->auth_flavs[i];
> -		switch (flavor) {
> -		case RPC_AUTH_UNIX:
> -			goto out_set;
> -		case RPC_AUTH_NULL:
> -			continue;
> -		default:
> -			if (rpcauth_get_gssinfo(flavor, &info) == 0)
> -				goto out_set;
> -		}
> +		if (args->auth_flavors[0] == server_authlist[i] ||
> +		    server_authlist[i] == RPC_AUTH_NULL)
> +			goto out;
> 	}
> 
> -	/*
> -	 * As a last chance, see if the server list contains AUTH_NULL -
> -	 * if it does, use the default flavor.
> -	 */
> -	for (i = 0; i < count; i++) {
> -		if (request->auth_flavs[i] == RPC_AUTH_NULL)
> -			goto out_default;
> -	}
> -
> -	dfprintk(MOUNT, "NFS: no auth flavors in common with server\n");
> -	goto out_err;
> +	dfprintk(MOUNT, "NFS: auth flavor %u not supported by server\n",
> +		args->auth_flavors[0]);
> +	return -EACCES;
> 
> -out_default:
> -	/* use default if flavor not already set */
> -	flavor = (args->auth_flavors[0] == RPC_AUTH_MAXFLAVOR) ?
> -		RPC_AUTH_UNIX : args->auth_flavors[0];
> -out_set:
> -	args->auth_flavors[0] = flavor;
> out:
> -	dfprintk(MOUNT, "NFS: using auth flavor %d\n", args->auth_flavors[0]);
> +	dfprintk(MOUNT, "NFS: using auth flavor %u\n", args->auth_flavors[0]);
> 	return 0;
> -out_err:
> -	return -EACCES;
> }
> 
> /*
> @@ -1756,13 +1699,17 @@ static int nfs_request_mount(struct nfs_parsed_mount_data *args,
> 		return status;
> 	}
> 
> -	return nfs_select_flavor(args, &request);
> +	return 0;
> }
> 
> static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_info,
> 					struct nfs_subversion *nfs_mod)
> {
> 	int status;
> +	unsigned int i;
> +	bool tried_auth_unix = false;
> +	bool auth_null_in_list = false;
> +	struct nfs_server *server = ERR_PTR(-EACCES);
> 	struct nfs_parsed_mount_data *args = mount_info->parsed;
> 	rpc_authflavor_t authlist[NFS_MAX_SECFLAVORS];
> 	unsigned int authlist_len = ARRAY_SIZE(authlist);
> @@ -1772,6 +1719,69 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_inf
> 	if (status)
> 		return ERR_PTR(status);
> 
> +	/*
> +	 * The NFSv2 MNT operation does not return a flavor list. Also, some
> +	 * NFS servers (older Linux servers in particular) return an empty list.
> +	 *
> +	 * In that event fake up a list that just has RPC_AUTH_NULL in it since
> +	 * we have no way to know what the server actually supports.
> +	 */
> +	if (args->mount_server.version != NFS_MNT3_VERSION ||
> +	    authlist_len == 0) {
> +		authlist[0] = RPC_AUTH_NULL;
> +		authlist_len = 1;
> +	}

Clever.

Instead of faking up the list here, you could construct the fake list in nfs_mount().  Then this code could assume there is always a non-empty list.

This is the same tactic we use in other places for NFSv2.


> +
> +	/*
> +	 * Was a sec= authflavor specified in the options? First, verify
> +	 * whether the server supports it, and then just try to use it if so.
> +	 */
> +	if (args->auth_flavors[0] != RPC_AUTH_MAXFLAVOR) {
> +		status = nfs_verify_authflavor(args, authlist, authlist_len);
> +		dfprintk(MOUNT, "NFS: using auth flavor %u\n", args->auth_flavors[0]);
> +		if (status)
> +			return ERR_PTR(status);
> +		return nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
> +	}
> +
> +	/*
> +	 * No sec= option was provided. RFC 2623, section 2.7 suggests we
> +	 * SHOULD prefer the flavor listed first. However, some servers list
> +	 * AUTH_NULL first. Avoid ever choosing AUTH_NULL.
> +	 */
> +	for (i = 0; i < authlist_len; ++i) {
> +		rpc_authflavor_t flavor;
> +		struct rpcsec_gss_info info;
> +
> +		flavor = authlist[i];
> +		switch (flavor) {
> +		case RPC_AUTH_UNIX:
> +			tried_auth_unix = true;
> +			break;
> +		case RPC_AUTH_NULL:
> +			auth_null_in_list = true;
> +			continue;
> +		default:
> +			if (rpcauth_get_gssinfo(flavor, &info) != 0)
> +				continue;
> +			/* Fallthrough */
> +		}
> +		dfprintk(MOUNT, "NFS: attempting to use auth flavor %u\n", flavor);
> +		args->auth_flavors[0] = flavor;
> +		server = nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
> +		if (!IS_ERR(server))
> +			return server;
> +	}
> +
> +	/*
> +	 * Nothing we tried so far worked. As a last ditch effort, try to use
> +	 * AUTH_UNIX if we haven't already, and AUTH_NULL was in server's list.
> +	 */
> +	if (tried_auth_unix || !auth_null_in_list)
> +		return server;
> +
> +	dfprintk(MOUNT, "NFS: attempting to use auth flavor %u\n", RPC_AUTH_UNIX);
> +	args->auth_flavors[0] = RPC_AUTH_UNIX;
> 	return nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
> }
> 
> -- 
> 1.8.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




