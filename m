Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50757 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756150Ab3JKVBG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Oct 2013 17:01:06 -0400
Date: Fri, 11 Oct 2013 17:01:04 -0400
To: Weston Andros Adamson <dros@netapp.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Add support for multiple sec= mount options
Message-ID: <20131011210104.GD22160@fieldses.org>
References: <1381517062-11267-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1381517062-11267-1-git-send-email-dros@netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 11, 2013 at 02:44:22PM -0400, Weston Andros Adamson wrote:
> This patch adds support for multiple security options which can be
> specified using a colon-delimited list of security flavors (the same
> syntax as nfsd's exports file).
> 
> This is useful, for instance, when NFSv4.x mounts cross SECINFO
> boundaries. With this patch a user can use "sec=krb5i,krb5p"
> to mount a remote filesystem using krb5i, but can still cross
> into krb5p-only exports.
> 
> New mounts will try all security options before failing.  NFSv4.x
> SECINFO results will be compared against the sec= flavors to
> find the first flavor in both lists or if no match is found will
> return EPERM.
> 
> This patch cleans up some of the auth flavor logic by separating
> the parsed mount options from the currently selected flavor and
> sharing more code between the 'no sec= specified' and 'sec= specified'
> code paths.
> 
> Along with this patch I'm posting a patch to nfs-util's nfs.man to
> reflect these changes.
> 
> I wrote a script to verify that I haven't broken anything, it tests
> all vers= and sec= combinations against a server with the exports:

Is the script something that could be added to Anna's or my regular
regression testing?

--b.

> 
>  /export/sys       *(sec=sys,rw,no_root_squash)
>  /export/krb5a     *(sec=krb5,rw,no_root_squash)
>  /export/krb5i     *(sec=krb5i,rw,no_root_squash)
>  /export/krb5p     *(sec=krb5p,rw,no_root_squash)
>  /export/krb5ip    *(sec=krb5i:krb5p,rw,no_root_squash)
>  /export/krb5aip   *(sec=krb5:krb5i:krb5p,rw,no_root_squash)
> 
> The script runs these tests against all exports, and the versions NFSv3,
> v4.0, v4.1:
>  - no sec= options
>  - all single sec= options
>  - all combinations of multiple sec= options
>  - no sec= SECINFO (mount / then ls export dir, v4.x only)
>  - single sec= SECINFO (mount / then ls export dir, v4.x only)
>  - all combinations of multiple sec= SECINFO (mount / then ls export dir,
>     v4.x only)
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
>  fs/nfs/client.c           |   5 +-
>  fs/nfs/internal.h         |   5 +-
>  fs/nfs/nfs4_fs.h          |   1 -
>  fs/nfs/nfs4client.c       |  10 ++-
>  fs/nfs/nfs4namespace.c    |  21 +++--
>  fs/nfs/nfs4proc.c         |  30 +++++---
>  fs/nfs/super.c            | 190 +++++++++++++++++++++++++++++-----------------
>  include/linux/nfs_fs_sb.h |   1 +
>  include/linux/nfs_xdr.h   |   7 ++
>  9 files changed, 176 insertions(+), 94 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index af03258..006fd52 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -786,8 +786,10 @@ static int nfs_init_server(struct nfs_server *server,
>  		goto error;
>  
>  	server->port = data->nfs_server.port;
> +	server->auth_info = data->auth_info;
>  
> -	error = nfs_init_server_rpcclient(server, &timeparms, data->auth_flavors[0]);
> +	error = nfs_init_server_rpcclient(server, &timeparms,
> +					  data->selected_flavor);
>  	if (error < 0)
>  		goto error;
>  
> @@ -928,6 +930,7 @@ void nfs_server_copy_userdata(struct nfs_server *target, struct nfs_server *sour
>  	target->acdirmax = source->acdirmax;
>  	target->caps = source->caps;
>  	target->options = source->options;
> +	target->auth_info = source->auth_info;
>  }
>  EXPORT_SYMBOL_GPL(nfs_server_copy_userdata);
>  
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 38da8c2..5c9cfe0 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -88,8 +88,8 @@ struct nfs_parsed_mount_data {
>  	unsigned int		namlen;
>  	unsigned int		options;
>  	unsigned int		bsize;
> -	unsigned int		auth_flavor_len;
> -	rpc_authflavor_t	auth_flavors[1];
> +	struct nfs_auth_info    auth_info;
> +	rpc_authflavor_t        selected_flavor;
>  	char			*client_address;
>  	unsigned int		version;
>  	unsigned int		minorversion;
> @@ -323,6 +323,7 @@ extern struct file_system_type nfs_xdev_fs_type;
>  extern struct file_system_type nfs4_xdev_fs_type;
>  extern struct file_system_type nfs4_referral_fs_type;
>  #endif
> +bool nfs_auth_info_match(const struct nfs_auth_info *, rpc_authflavor_t);
>  struct dentry *nfs_try_mount(int, const char *, struct nfs_mount_info *,
>  			struct nfs_subversion *);
>  void nfs_initialise_sb(struct super_block *);
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index 28842ab..cffed27 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -213,7 +213,6 @@ int nfs_atomic_open(struct inode *, struct dentry *, struct file *,
>  extern struct file_system_type nfs4_fs_type;
>  
>  /* nfs4namespace.c */
> -rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *);
>  struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *, struct inode *, struct qstr *);
>  struct vfsmount *nfs4_submount(struct nfs_server *, struct dentry *,
>  			       struct nfs_fh *, struct nfs_fattr *);
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index 511cdce..b446314 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -962,9 +962,13 @@ static int nfs4_init_server(struct nfs_server *server,
>  	/* Initialise the client representation from the mount data */
>  	server->flags = data->flags;
>  	server->options = data->options;
> +	server->auth_info = data->auth_info;
>  
> -	if (data->auth_flavor_len >= 1)
> -		pseudoflavor = data->auth_flavors[0];
> +	/* Use the first specified auth flavor. If this flavor isn't
> +	 * allowed by the server, use the SECINFO path to try the
> +	 * other specified flavors */
> +	if (data->auth_info.flavor_len >= 1)
> +		pseudoflavor = data->auth_info.flavors[0];
>  
>  	/* Get a client record */
>  	error = nfs4_set_client(server,
> @@ -1019,7 +1023,7 @@ struct nfs_server *nfs4_create_server(struct nfs_mount_info *mount_info,
>  	if (!server)
>  		return ERR_PTR(-ENOMEM);
>  
> -	auth_probe = mount_info->parsed->auth_flavor_len < 1;
> +	auth_probe = mount_info->parsed->auth_info.flavor_len < 1;
>  
>  	/* set up the general RPC client */
>  	error = nfs4_init_server(server, mount_info->parsed);
> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
> index 2288cd3..caaa7aa 100644
> --- a/fs/nfs/nfs4namespace.c
> +++ b/fs/nfs/nfs4namespace.c
> @@ -137,15 +137,18 @@ static size_t nfs_parse_server_name(char *string, size_t len,
>  
>  /**
>   * nfs_find_best_sec - Find a security mechanism supported locally
> + * @server:  Nfs server structure
>   * @flavors: List of security tuples returned by SECINFO procedure
>   *
>   * Return the pseudoflavor of the first security mechanism in
> - * "flavors" that is locally supported.  Return RPC_AUTH_UNIX if
> + * "flavors" that is locally supported and in the sec= mount
> + * options if any were specified.  Return RPC_AUTH_UNIX if
>   * no matching flavor is found in the array.  The "flavors" array
>   * is searched in the order returned from the server, per RFC 3530
>   * recommendation.
>   */
> -rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
> +static rpc_authflavor_t nfs_find_best_sec(struct nfs_server *server,
> +					  struct nfs4_secinfo_flavors *flavors)
>  {
>  	rpc_authflavor_t pseudoflavor;
>  	struct nfs4_secinfo4 *secinfo;
> @@ -160,12 +163,20 @@ rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
>  		case RPC_AUTH_GSS:
>  			pseudoflavor = rpcauth_get_pseudoflavor(secinfo->flavor,
>  							&secinfo->flavor_info);
> -			if (pseudoflavor != RPC_AUTH_MAXFLAVOR)
> +
> +			/* make sure pseudoflavor matches sec= mount opt */
> +			if (pseudoflavor != RPC_AUTH_MAXFLAVOR &&
> +			    nfs_auth_info_match(&server->auth_info,
> +						pseudoflavor))
>  				return pseudoflavor;
>  			break;
>  		}
>  	}
>  
> +	/* if there were any sec= options then nothing matched */
> +	if (server->flags & NFS_MOUNT_SECFLAVOUR)
> +		return -EPERM;
> +
>  	return RPC_AUTH_UNIX;
>  }
>  
> @@ -187,7 +198,7 @@ static rpc_authflavor_t nfs4_negotiate_security(struct inode *inode, struct qstr
>  		goto out;
>  	}
>  
> -	flavor = nfs_find_best_sec(flavors);
> +	flavor = nfs_find_best_sec(NFS_SERVER(inode), flavors);
>  
>  out:
>  	put_page(page);
> @@ -390,7 +401,7 @@ struct vfsmount *nfs4_submount(struct nfs_server *server, struct dentry *dentry,
>  
>  	if (client->cl_auth->au_flavor != flavor)
>  		flavor = client->cl_auth->au_flavor;
> -	else if (!(server->flags & NFS_MOUNT_SECFLAVOUR)) {
> +	else {
>  		rpc_authflavor_t new = nfs4_negotiate_security(dir, name);
>  		if ((int)new >= 0)
>  			flavor = new;
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index d2b4845..a926a39 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2864,11 +2864,22 @@ static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
>  	int status = -EPERM;
>  	size_t i;
>  
> -	for (i = 0; i < ARRAY_SIZE(flav_array); i++) {
> -		status = nfs4_lookup_root_sec(server, fhandle, info, flav_array[i]);
> -		if (status == -NFS4ERR_WRONGSEC || status == -EACCES)
> -			continue;
> -		break;
> +	if (server->flags & NFS_MOUNT_SECFLAVOUR) {
> +		for (i = 0; i < server->auth_info.flavor_len; i++) {
> +			status = nfs4_lookup_root_sec(server, fhandle, info,
> +						server->auth_info.flavors[i]);
> +			if (status == -NFS4ERR_WRONGSEC || status == -EACCES)
> +				continue;
> +			break;
> +		}
> +	} else {
> +		for (i = 0; i < ARRAY_SIZE(flav_array); i++) {
> +			status = nfs4_lookup_root_sec(server, fhandle, info,
> +						      flav_array[i]);
> +			if (status == -NFS4ERR_WRONGSEC || status == -EACCES)
> +				continue;
> +			break;
> +		}
>  	}
>  
>  	/*
> @@ -2910,9 +2921,6 @@ int nfs4_proc_get_rootfh(struct nfs_server *server, struct nfs_fh *fhandle,
>  		status = nfs4_lookup_root(server, fhandle, info);
>  		if (status != -NFS4ERR_WRONGSEC)
>  			break;
> -		/* Did user force a 'sec=' mount option? */
> -		if (server->flags & NFS_MOUNT_SECFLAVOUR)
> -			break;
>  	default:
>  		status = nfs4_do_find_root_sec(server, fhandle, info);
>  	}
> @@ -3165,9 +3173,6 @@ static int nfs4_proc_lookup_common(struct rpc_clnt **clnt, struct inode *dir,
>  			err = -EPERM;
>  			if (client != *clnt)
>  				goto out;
> -			/* No security negotiation if the user specified 'sec=' */
> -			if (NFS_SERVER(dir)->flags & NFS_MOUNT_SECFLAVOUR)
> -				goto out;
>  			client = nfs4_create_sec_client(client, dir, name);
>  			if (IS_ERR(client))
>  				return PTR_ERR(client);
> @@ -7617,6 +7622,9 @@ nfs41_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
>  			break;
>  		}
>  
> +		if (!nfs_auth_info_match(&server->auth_info, flavor))
> +			flavor = RPC_AUTH_MAXFLAVOR;
> +
>  		if (flavor != RPC_AUTH_MAXFLAVOR) {
>  			err = nfs4_lookup_root_sec(server, fhandle,
>  						   info, flavor);
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index a03b9c6..84cf276 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -497,7 +497,9 @@ static const char *nfs_pseudoflavour_to_name(rpc_authflavor_t flavour)
>  	static const struct {
>  		rpc_authflavor_t flavour;
>  		const char *str;
> -	} sec_flavours[] = {
> +	} sec_flavours[NFS_AUTH_INFO_MAX_FLAVORS] = {
> +		/* update NFS_AUTH_INFO_MAX_FLAVORS when this list
> +		 * changes */
>  		{ RPC_AUTH_NULL, "null" },
>  		{ RPC_AUTH_UNIX, "sys" },
>  		{ RPC_AUTH_GSS_KRB5, "krb5" },
> @@ -923,8 +925,7 @@ static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(void)
>  		data->mount_server.port	= NFS_UNSPEC_PORT;
>  		data->nfs_server.port	= NFS_UNSPEC_PORT;
>  		data->nfs_server.protocol = XPRT_TRANSPORT_TCP;
> -		data->auth_flavors[0]	= RPC_AUTH_MAXFLAVOR;
> -		data->auth_flavor_len	= 0;
> +		data->selected_flavor	= RPC_AUTH_MAXFLAVOR;
>  		data->minorversion	= 0;
>  		data->need_mount	= true;
>  		data->net		= current->nsproxy->net_ns;
> @@ -1019,13 +1020,48 @@ static void nfs_set_mount_transport_protocol(struct nfs_parsed_mount_data *mnt)
>  	}
>  }
>  
> -static void nfs_set_auth_parsed_mount_data(struct nfs_parsed_mount_data *data,
> -		rpc_authflavor_t pseudoflavor)
> +/*
> + * Add 'flavor' to 'auth_info' if not already present.
> + * Returns true if 'flavor' ends up in the list, false otherwise
> + */
> +static bool nfs_auth_info_add(struct nfs_auth_info *auth_info,
> +			      rpc_authflavor_t flavor)
>  {
> -	data->auth_flavors[0] = pseudoflavor;
> -	data->auth_flavor_len = 1;
> +	unsigned int i;
> +	unsigned int max_flavor_len = (sizeof(auth_info->flavors) /
> +					sizeof(auth_info->flavors[0]));
> +
> +	/* make sure this flavor isn't already in the list */
> +	for (i = 0; i < auth_info->flavor_len; i++) {
> +		if (flavor == auth_info->flavors[i])
> +			return true;
> +	}
> +
> +	if (auth_info->flavor_len + 1 >= max_flavor_len) {
> +		dfprintk(MOUNT, "NFS: too many sec= flavors\n");
> +		return false;
> +	}
> +
> +	auth_info->flavors[auth_info->flavor_len++] = flavor;
> +	return true;
>  }
>  
> +bool nfs_auth_info_match(const struct nfs_auth_info *auth_info,
> +			 rpc_authflavor_t match)
> +{
> +	int i;
> +
> +	if (!auth_info->flavor_len)
> +		return true;
> +
> +	for (i = 0; i < auth_info->flavor_len; i++) {
> +		if (auth_info->flavors[i] == match)
> +			return true;
> +	}
> +	return false;
> +}
> +EXPORT_SYMBOL_GPL(nfs_auth_info_match);
> +
>  /*
>   * Parse the value of the 'sec=' option.
>   */
> @@ -1034,49 +1070,61 @@ static int nfs_parse_security_flavors(char *value,
>  {
>  	substring_t args[MAX_OPT_ARGS];
>  	rpc_authflavor_t pseudoflavor;
> +	char *p;
>  
>  	dfprintk(MOUNT, "NFS: parsing sec=%s option\n", value);
>  
> -	switch (match_token(value, nfs_secflavor_tokens, args)) {
> -	case Opt_sec_none:
> -		pseudoflavor = RPC_AUTH_NULL;
> -		break;
> -	case Opt_sec_sys:
> -		pseudoflavor = RPC_AUTH_UNIX;
> -		break;
> -	case Opt_sec_krb5:
> -		pseudoflavor = RPC_AUTH_GSS_KRB5;
> -		break;
> -	case Opt_sec_krb5i:
> -		pseudoflavor = RPC_AUTH_GSS_KRB5I;
> -		break;
> -	case Opt_sec_krb5p:
> -		pseudoflavor = RPC_AUTH_GSS_KRB5P;
> -		break;
> -	case Opt_sec_lkey:
> -		pseudoflavor = RPC_AUTH_GSS_LKEY;
> -		break;
> -	case Opt_sec_lkeyi:
> -		pseudoflavor = RPC_AUTH_GSS_LKEYI;
> -		break;
> -	case Opt_sec_lkeyp:
> -		pseudoflavor = RPC_AUTH_GSS_LKEYP;
> -		break;
> -	case Opt_sec_spkm:
> -		pseudoflavor = RPC_AUTH_GSS_SPKM;
> -		break;
> -	case Opt_sec_spkmi:
> -		pseudoflavor = RPC_AUTH_GSS_SPKMI;
> -		break;
> -	case Opt_sec_spkmp:
> -		pseudoflavor = RPC_AUTH_GSS_SPKMP;
> -		break;
> -	default:
> -		return 0;
> +	while ((p = strsep(&value, ":")) != NULL) {
> +		switch (match_token(p, nfs_secflavor_tokens, args)) {
> +		case Opt_sec_none:
> +			pseudoflavor = RPC_AUTH_NULL;
> +			break;
> +		case Opt_sec_sys:
> +			pseudoflavor = RPC_AUTH_UNIX;
> +			break;
> +		case Opt_sec_krb5:
> +			pseudoflavor = RPC_AUTH_GSS_KRB5;
> +			break;
> +		case Opt_sec_krb5i:
> +			pseudoflavor = RPC_AUTH_GSS_KRB5I;
> +			break;
> +		case Opt_sec_krb5p:
> +			pseudoflavor = RPC_AUTH_GSS_KRB5P;
> +			break;
> +		case Opt_sec_lkey:
> +			pseudoflavor = RPC_AUTH_GSS_LKEY;
> +			break;
> +		case Opt_sec_lkeyi:
> +			pseudoflavor = RPC_AUTH_GSS_LKEYI;
> +			break;
> +		case Opt_sec_lkeyp:
> +			pseudoflavor = RPC_AUTH_GSS_LKEYP;
> +			break;
> +		case Opt_sec_spkm:
> +			pseudoflavor = RPC_AUTH_GSS_SPKM;
> +			break;
> +		case Opt_sec_spkmi:
> +			pseudoflavor = RPC_AUTH_GSS_SPKMI;
> +			break;
> +		case Opt_sec_spkmp:
> +			pseudoflavor = RPC_AUTH_GSS_SPKMP;
> +			break;
> +		default:
> +			dfprintk(MOUNT,
> +				 "NFS: sec= option '%s' not recognized\n", p);
> +			return 0;
> +		}
> +
> +		if (!nfs_auth_info_add(&mnt->auth_info, pseudoflavor))
> +			return 0;
>  	}
>  
> -	mnt->flags |= NFS_MOUNT_SECFLAVOUR;
> -	nfs_set_auth_parsed_mount_data(mnt, pseudoflavor);
> +	if (mnt->auth_info.flavor_len > 0) {
> +		mnt->flags |= NFS_MOUNT_SECFLAVOUR;
> +		mnt->selected_flavor = mnt->auth_info.flavors[0];
> +	} else
> +		mnt->selected_flavor = RPC_AUTH_MAXFLAVOR;
> +
>  	return 1;
>  }
>  
> @@ -1623,12 +1671,14 @@ out_security_failure:
>  }
>  
>  /*
> - * Ensure that the specified authtype in args->auth_flavors[0] is supported by
> - * the server. Returns 0 if it's ok, and -EACCES if not.
> + * Ensure that a specified authtype in args->auth_info is supported by
> + * the server. Returns 0 and sets args->selected_flavor if it's ok, and
> + * -EACCES if not.
>   */
> -static int nfs_verify_authflavor(struct nfs_parsed_mount_data *args,
> +static int nfs_verify_authflavors(struct nfs_parsed_mount_data *args,
>  			rpc_authflavor_t *server_authlist, unsigned int count)
>  {
> +	rpc_authflavor_t flavor = RPC_AUTH_MAXFLAVOR;
>  	unsigned int i;
>  
>  	/*
> @@ -1640,17 +1690,20 @@ static int nfs_verify_authflavor(struct nfs_parsed_mount_data *args,
>  	 * can be used.
>  	 */
>  	for (i = 0; i < count; i++) {
> -		if (args->auth_flavors[0] == server_authlist[i] ||
> -		    server_authlist[i] == RPC_AUTH_NULL)
> +		flavor = server_authlist[i];
> +
> +		if (nfs_auth_info_match(&args->auth_info, flavor) ||
> +		    flavor == RPC_AUTH_NULL)
>  			goto out;
>  	}
>  
> -	dfprintk(MOUNT, "NFS: auth flavor %u not supported by server\n",
> -		args->auth_flavors[0]);
> +	dfprintk(MOUNT,
> +		 "NFS: specified auth flavors not supported by server\n");
>  	return -EACCES;
>  
>  out:
> -	dfprintk(MOUNT, "NFS: using auth flavor %u\n", args->auth_flavors[0]);
> +	args->selected_flavor = flavor;
> +	dfprintk(MOUNT, "NFS: using auth flavor %u\n", flavor);
>  	return 0;
>  }
>  
> @@ -1738,9 +1791,10 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_inf
>  	 * Was a sec= authflavor specified in the options? First, verify
>  	 * whether the server supports it, and then just try to use it if so.
>  	 */
> -	if (args->auth_flavor_len > 0) {
> -		status = nfs_verify_authflavor(args, authlist, authlist_len);
> -		dfprintk(MOUNT, "NFS: using auth flavor %u\n", args->auth_flavors[0]);
> +	if (args->flags & NFS_MOUNT_SECFLAVOUR) {
> +		status = nfs_verify_authflavors(args, authlist, authlist_len);
> +		dfprintk(MOUNT, "NFS: using auth flavor %u\n",
> +			 args->selected_flavor);
>  		if (status)
>  			return ERR_PTR(status);
>  		return nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
> @@ -1769,7 +1823,7 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_inf
>  			/* Fallthrough */
>  		}
>  		dfprintk(MOUNT, "NFS: attempting to use auth flavor %u\n", flavor);
> -		nfs_set_auth_parsed_mount_data(args, flavor);
> +		args->selected_flavor = flavor;
>  		server = nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
>  		if (!IS_ERR(server))
>  			return server;
> @@ -1785,7 +1839,7 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_inf
>  
>  	/* Last chance! Try AUTH_UNIX */
>  	dfprintk(MOUNT, "NFS: attempting to use auth flavor %u\n", RPC_AUTH_UNIX);
> -	nfs_set_auth_parsed_mount_data(args, RPC_AUTH_UNIX);
> +	args->selected_flavor = RPC_AUTH_UNIX;
>  	return nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
>  }
>  
> @@ -1972,9 +2026,9 @@ static int nfs23_validate_mount_data(void *options,
>  		args->bsize		= data->bsize;
>  
>  		if (data->flags & NFS_MOUNT_SECFLAVOUR)
> -			nfs_set_auth_parsed_mount_data(args, data->pseudoflavor);
> +			args->selected_flavor = data->pseudoflavor;
>  		else
> -			nfs_set_auth_parsed_mount_data(args, RPC_AUTH_UNIX);
> +			args->selected_flavor = RPC_AUTH_UNIX;
>  		if (!args->nfs_server.hostname)
>  			goto out_nomem;
>  
> @@ -2108,9 +2162,6 @@ static int nfs_validate_text_mount_data(void *options,
>  
>  	nfs_set_port(sap, &args->nfs_server.port, port);
>  
> -	if (args->auth_flavor_len > 1)
> -		goto out_bad_auth;
> -
>  	return nfs_parse_devname(dev_name,
>  				   &args->nfs_server.hostname,
>  				   max_namelen,
> @@ -2130,10 +2181,6 @@ out_invalid_transport_udp:
>  out_no_address:
>  	dfprintk(MOUNT, "NFS: mount program didn't pass remote address\n");
>  	return -EINVAL;
> -
> -out_bad_auth:
> -	dfprintk(MOUNT, "NFS: Too many RPC auth flavours specified\n");
> -	return -EINVAL;
>  }
>  
>  static int
> @@ -2144,7 +2191,7 @@ nfs_compare_remount_data(struct nfs_server *nfss,
>  	    data->rsize != nfss->rsize ||
>  	    data->wsize != nfss->wsize ||
>  	    data->retrans != nfss->client->cl_timeout->to_retries ||
> -	    data->auth_flavors[0] != nfss->client->cl_auth->au_flavor ||
> +	    data->selected_flavor != nfss->client->cl_auth->au_flavor ||
>  	    data->acregmin != nfss->acregmin / HZ ||
>  	    data->acregmax != nfss->acregmax / HZ ||
>  	    data->acdirmin != nfss->acdirmin / HZ ||
> @@ -2189,7 +2236,8 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
>  	data->rsize = nfss->rsize;
>  	data->wsize = nfss->wsize;
>  	data->retrans = nfss->client->cl_timeout->to_retries;
> -	nfs_set_auth_parsed_mount_data(data, nfss->client->cl_auth->au_flavor);
> +	data->selected_flavor = nfss->client->cl_auth->au_flavor;
> +	data->auth_info = nfss->auth_info;
>  	data->acregmin = nfss->acregmin / HZ;
>  	data->acregmax = nfss->acregmax / HZ;
>  	data->acdirmin = nfss->acdirmin / HZ;
> @@ -2713,9 +2761,9 @@ static int nfs4_validate_mount_data(void *options,
>  					   data->auth_flavours,
>  					   sizeof(pseudoflavor)))
>  				return -EFAULT;
> -			nfs_set_auth_parsed_mount_data(args, pseudoflavor);
> +			args->selected_flavor = pseudoflavor;
>  		} else
> -			nfs_set_auth_parsed_mount_data(args, RPC_AUTH_UNIX);
> +			args->selected_flavor = RPC_AUTH_UNIX;
>  
>  		c = strndup_user(data->hostname.data, NFS4_MAXNAMLEN);
>  		if (IS_ERR(c))
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index f9c0a6c..b2c3b82 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -149,6 +149,7 @@ struct nfs_server {
>  	struct timespec		time_delta;	/* smallest time granularity */
>  	unsigned long		mount_time;	/* when this fs was mounted */
>  	dev_t			s_dev;		/* superblock dev numbers */
> +	struct nfs_auth_info	auth_info;	/* allowed auth flavors */
>  
>  #ifdef CONFIG_NFS_FSCACHE
>  	struct nfs_fscache_key	*fscache_key;	/* unique key for superblock */
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 49f52c8..488ce9d 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -591,6 +591,13 @@ struct nfs_renameres {
>  	struct nfs_fattr		*new_fattr;
>  };
>  
> +/* parsed sec= options */
> +#define NFS_AUTH_INFO_MAX_FLAVORS 12 /* see fs/nfs/super.c */
> +struct nfs_auth_info {
> +	unsigned int            flavor_len;
> +	rpc_authflavor_t        flavors[NFS_AUTH_INFO_MAX_FLAVORS];
> +};
> +
>  /*
>   * Argument struct for decode_entry function
>   */
> -- 
> 1.7.12.4 (Apple Git-37)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
