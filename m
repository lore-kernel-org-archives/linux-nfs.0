Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:35171 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751156Ab3IHUWo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Sep 2013 16:22:44 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [PATCH 3/6] NFSv4: Fix security auto-negotiation
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1378595893-60395-4-git-send-email-Trond.Myklebust@netapp.com>
Date: Sun, 8 Sep 2013 16:22:38 -0400
Cc: <linux-nfs@vger.kernel.org>
Message-Id: <198C66BF-35E7-40E8-91BB-1239CA6E89D7@oracle.com>
References: <1378595893-60395-1-git-send-email-Trond.Myklebust@netapp.com> <1378595893-60395-2-git-send-email-Trond.Myklebust@netapp.com> <1378595893-60395-3-git-send-email-Trond.Myklebust@netapp.com> <1378595893-60395-4-git-send-email-Trond.Myklebust@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 7, 2013, at 7:18 PM, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> NFSv4 security auto-negotiation has been broken since
> commit 4580a92d44e2b21c2254fa5fef0f1bfb43c82318 (NFS:
> Use server-recommended security flavor by default (NFSv3))
> because nfs4_try_mount() will automatically select AUTH_SYS
> if it sees no auth flavours.

nfs(5) says this:

       sec=mode       The  RPCGSS  security flavor to use for accessing files on this
                      mount point.  If the sec option is not specified, or if sec=sys
                      is  specified, the NFS client uses the AUTH_SYS security flavor
                      for all NFS requests on this mount point.  

If NFSv4 can negotiate security now, nfs(5) should be updated.


> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Chuck Lever <chuck.lever@oracle.com>
> ---
> fs/nfs/internal.h    |  2 +-
> fs/nfs/nfs4_fs.h     |  2 +-
> fs/nfs/nfs4client.c  | 19 +++++++++++++------
> fs/nfs/nfs4getroot.c |  4 ++--
> fs/nfs/nfs4proc.c    | 17 +++++++++++++----
> fs/nfs/nfs4super.c   |  4 ----
> 6 files changed, 30 insertions(+), 18 deletions(-)
> 
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 23ec6e8..d388302c 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -358,7 +358,7 @@ extern struct dentry *nfs_get_root(struct super_block *, struct nfs_fh *,
> extern struct dentry *nfs4_get_root(struct super_block *, struct nfs_fh *,
> 				    const char *);
> 
> -extern int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh);
> +extern int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh, bool);
> #endif
> 
> struct nfs_pgio_completion_ops;
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index d2db3ce..f520a11 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -221,7 +221,7 @@ struct vfsmount *nfs4_submount(struct nfs_server *, struct dentry *,
> /* nfs4proc.c */
> extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
> extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct nfs4_setclientid_res *arg, struct rpc_cred *);
> -extern int nfs4_proc_get_rootfh(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
> +extern int nfs4_proc_get_rootfh(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *, bool);
> extern int nfs4_proc_bind_conn_to_session(struct nfs_client *, struct rpc_cred *cred);
> extern int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred);
> extern int nfs4_destroy_clientid(struct nfs_client *clp);
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index f798925..cc80085 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -885,7 +885,7 @@ static void nfs4_session_set_rwsize(struct nfs_server *server)
> }
> 
> static int nfs4_server_common_setup(struct nfs_server *server,
> -		struct nfs_fh *mntfh)
> +		struct nfs_fh *mntfh, bool auth_probe)
> {
> 	struct nfs_fattr *fattr;
> 	int error;
> @@ -917,7 +917,7 @@ static int nfs4_server_common_setup(struct nfs_server *server,
> 
> 
> 	/* Probe the root fh to retrieve its FSID and filehandle */
> -	error = nfs4_get_rootfh(server, mntfh);
> +	error = nfs4_get_rootfh(server, mntfh, auth_probe);
> 	if (error < 0)
> 		goto out;
> 
> @@ -949,6 +949,7 @@ out:
> static int nfs4_init_server(struct nfs_server *server,
> 		const struct nfs_parsed_mount_data *data)
> {
> +	rpc_authflavor_t pseudoflavor = RPC_AUTH_UNIX;
> 	struct rpc_timeout timeparms;
> 	int error;
> 
> @@ -961,13 +962,16 @@ static int nfs4_init_server(struct nfs_server *server,
> 	server->flags = data->flags;
> 	server->options = data->options;
> 
> +	if (data->auth_flavor_len >= 1)
> +		pseudoflavor = data->auth_flavors[0];
> +
> 	/* Get a client record */
> 	error = nfs4_set_client(server,
> 			data->nfs_server.hostname,
> 			(const struct sockaddr *)&data->nfs_server.address,
> 			data->nfs_server.addrlen,
> 			data->client_address,
> -			data->auth_flavors[0],
> +			pseudoflavor,
> 			data->nfs_server.protocol,
> 			&timeparms,
> 			data->minorversion,
> @@ -987,7 +991,7 @@ static int nfs4_init_server(struct nfs_server *server,
> 
> 	server->port = data->nfs_server.port;
> 
> -	error = nfs_init_server_rpcclient(server, &timeparms, data->auth_flavors[0]);
> +	error = nfs_init_server_rpcclient(server, &timeparms, pseudoflavor);
> 
> error:
> 	/* Done */
> @@ -1005,6 +1009,7 @@ struct nfs_server *nfs4_create_server(struct nfs_mount_info *mount_info,
> 				      struct nfs_subversion *nfs_mod)
> {
> 	struct nfs_server *server;
> +	bool auth_probe;
> 	int error;
> 
> 	dprintk("--> nfs4_create_server()\n");
> @@ -1013,12 +1018,14 @@ struct nfs_server *nfs4_create_server(struct nfs_mount_info *mount_info,
> 	if (!server)
> 		return ERR_PTR(-ENOMEM);
> 
> +	auth_probe = mount_info->parsed->auth_flavor_len < 1;
> +
> 	/* set up the general RPC client */
> 	error = nfs4_init_server(server, mount_info->parsed);
> 	if (error < 0)
> 		goto error;
> 
> -	error = nfs4_server_common_setup(server, mount_info->mntfh);
> +	error = nfs4_server_common_setup(server, mount_info->mntfh, auth_probe);
> 	if (error < 0)
> 		goto error;
> 
> @@ -1071,7 +1078,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
> 	if (error < 0)
> 		goto error;
> 
> -	error = nfs4_server_common_setup(server, mntfh);
> +	error = nfs4_server_common_setup(server, mntfh, false);
> 	if (error < 0)
> 		goto error;
> 
> diff --git a/fs/nfs/nfs4getroot.c b/fs/nfs/nfs4getroot.c
> index 549462e..c0b3a16 100644
> --- a/fs/nfs/nfs4getroot.c
> +++ b/fs/nfs/nfs4getroot.c
> @@ -9,7 +9,7 @@
> 
> #define NFSDBG_FACILITY		NFSDBG_CLIENT
> 
> -int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh)
> +int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh, bool auth_probe)
> {
> 	struct nfs_fsinfo fsinfo;
> 	int ret = -ENOMEM;
> @@ -21,7 +21,7 @@ int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh)
> 		goto out;
> 
> 	/* Start by getting the root filehandle from the server */
> -	ret = nfs4_proc_get_rootfh(server, mntfh, &fsinfo);
> +	ret = nfs4_proc_get_rootfh(server, mntfh, &fsinfo, auth_probe);
> 	if (ret < 0) {
> 		dprintk("nfs4_get_rootfh: getroot error = %d\n", -ret);
> 		goto out;
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index cb56102..68551ea 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2884,18 +2884,27 @@ static int nfs4_do_find_root_sec(struct nfs_server *server,
>  * @server: initialized nfs_server handle
>  * @fhandle: we fill in the pseudo-fs root file handle
>  * @info: we fill in an FSINFO struct
> + * @auth_probe: probe the auth flavours
>  *
>  * Returns zero on success, or a negative errno.
>  */
> int nfs4_proc_get_rootfh(struct nfs_server *server, struct nfs_fh *fhandle,
> -			 struct nfs_fsinfo *info)
> +			 struct nfs_fsinfo *info,
> +			 bool auth_probe)
> {
> 	int status;
> 
> -	status = nfs4_lookup_root(server, fhandle, info);
> -	if ((status == -NFS4ERR_WRONGSEC) &&
> -	    !(server->flags & NFS_MOUNT_SECFLAVOUR))
> +	switch (auth_probe) {
> +	case false:
> +		status = nfs4_lookup_root(server, fhandle, info);
> +		if (status != -NFS4ERR_WRONGSEC)
> +			break;
> +		/* Did user force a 'sec=' mount option? */
> +		if (server->flags & NFS_MOUNT_SECFLAVOUR)
> +			break;
> +	default:
> 		status = nfs4_do_find_root_sec(server, fhandle, info);
> +	}
> 
> 	if (status == 0)
> 		status = nfs4_server_capabilities(server, fhandle);
> diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
> index 4ad837c..e26acdd 100644
> --- a/fs/nfs/nfs4super.c
> +++ b/fs/nfs/nfs4super.c
> @@ -253,10 +253,6 @@ struct dentry *nfs4_try_mount(int flags, const char *dev_name,
> 
> 	dfprintk(MOUNT, "--> nfs4_try_mount()\n");
> 
> -	if (data->auth_flavor_len < 1) {
> -		data->auth_flavors[0] = RPC_AUTH_UNIX;
> -		data->auth_flavor_len = 1;
> -	}
> 	export_path = data->nfs_server.export_path;
> 	data->nfs_server.export_path = "/";
> 	root_mnt = nfs_do_root_mount(&nfs4_remote_fs_type, flags, mount_info,
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



