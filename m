Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:3358 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754718Ab0K3JpA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Nov 2010 04:45:00 -0500
Message-ID: <4CF4C798.2000009@panasas.com>
Date: Tue, 30 Nov 2010 11:44:56 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] NFSv4: Send unmapped uid/gids to the server when
 using auth_sys
References: <1291085863-3234-1-git-send-email-Trond.Myklebust@netapp.com> <1291085863-3234-2-git-send-email-Trond.Myklebust@netapp.com> <1291085863-3234-3-git-send-email-Trond.Myklebust@netapp.com> <1291085863-3234-4-git-send-email-Trond.Myklebust@netapp.com> <1291085863-3234-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1291085863-3234-5-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 11/30/2010 04:57 AM, Trond Myklebust wrote:
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/client.c           |   16 ++++++++++++++++
>  fs/nfs/idmap.c            |   21 +++++++++++++--------
>  fs/nfs/nfs4proc.c         |    8 +++++++-
>  include/linux/nfs_fs_sb.h |    1 +
>  4 files changed, 37 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 0870d0d..fb84771 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -58,6 +58,11 @@ static LIST_HEAD(nfs_volume_list);
>  static DECLARE_WAIT_QUEUE_HEAD(nfs_client_active_wq);
>  
>  /*
> + * Turn off NFSv4 uid/gid mapping when using AUTH_SYS
> + */
> +static int nfs4_disable_idmapping = 0;

The double negative is a bit hard. I had to read it 3 times to
register. Perhaps consider reversing the name and the default

+static int nfs4_enable_idmapping = 1;

> +
> +/*
>   * RPC cruft for NFS
>   */
>  static struct rpc_version *nfs_version[5] = {
> @@ -1387,6 +1392,13 @@ static int nfs4_init_server(struct nfs_server *server,
>  	if (error < 0)
>  		goto error;
>  
> +	/*
> +	 * Don't use NFS uid/gid mapping if we're using AUTH_SYS or lower
> +	 * authentication.
> +	 */
> +	if (nfs4_disable_idmapping && data->auth_flavors[0] == RPC_AUTH_UNIX)
> +		server->caps |= NFS_CAP_UIDGID_NOMAP;
> +
>  	if (data->rsize)
>  		server->rsize = nfs_block_size(data->rsize, NULL);
>  	if (data->wsize)
> @@ -1808,3 +1820,7 @@ void nfs_fs_proc_exit(void)
>  }
>  
>  #endif /* CONFIG_PROC_FS */
> +
> +module_param(nfs4_disable_idmapping, bool, 0644);
> +MODULE_PARM_DESC(nfs4_disable_idmapping,
> +		"Turn off NFSv4 idmapping when using 'sec=sys'");
> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
> index 114de76..d816bba 100644
> --- a/fs/nfs/idmap.c
> +++ b/fs/nfs/idmap.c
> @@ -257,17 +257,20 @@ int nfs_map_group_to_gid(const struct nfs_server *server, const char *name, size
>  
>  int nfs_map_uid_to_name(const struct nfs_server *server, __u32 uid, char *buf, size_t buflen)
>  {
> -	int ret;
> -	ret = nfs_idmap_lookup_name(uid, "user", buf, buflen);
> +	int ret = -EINVAL;
> +
> +	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))

Look here and below it is always used as Negative (of negative), perhaps?
+	if (server->caps & NFS_CAP_UIDGID_MAP)


Thanks
Boaz

> +		ret = nfs_idmap_lookup_name(uid, "user", buf, buflen);
>  	if (ret < 0)
>  		ret = nfs_map_numeric_to_string(uid, buf, buflen);
>  	return ret;
>  }
>  int nfs_map_gid_to_group(const struct nfs_server *server, __u32 gid, char *buf, size_t buflen)
>  {
> -	int ret;
> +	int ret = -EINVAL;
>  
> -	ret = nfs_idmap_lookup_name(gid, "group", buf, buflen);
> +	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
> +		ret = nfs_idmap_lookup_name(gid, "group", buf, buflen);
>  	if (ret < 0)
>  		ret = nfs_map_numeric_to_string(gid, buf, buflen);
>  	return ret;
> @@ -750,9 +753,10 @@ int nfs_map_group_to_gid(const struct nfs_server *server, const char *name, size
>  int nfs_map_uid_to_name(const struct nfs_server *server, __u32 uid, char *buf, size_t buflen)
>  {
>  	struct idmap *idmap = server->nfs_client->cl_idmap;
> -	int ret;
> +	int ret = -EINVAL;
>  
> -	ret = nfs_idmap_name(idmap, &idmap->idmap_user_hash, uid, buf);
> +	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
> +		ret = nfs_idmap_name(idmap, &idmap->idmap_user_hash, uid, buf);
>  	if (ret < 0)
>  		ret = nfs_map_numeric_to_string(uid, buf, buflen);
>  	return ret;
> @@ -760,9 +764,10 @@ int nfs_map_uid_to_name(const struct nfs_server *server, __u32 uid, char *buf, s
>  int nfs_map_gid_to_group(const struct nfs_server *server, __u32 uid, char *buf, size_t buflen)
>  {
>  	struct idmap *idmap = server->nfs_client->cl_idmap;
> -	int ret;
> +	int ret = -EINVAL;
>  
> -	ret = nfs_idmap_name(idmap, &idmap->idmap_group_hash, uid, buf);
> +	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
> +		ret = nfs_idmap_name(idmap, &idmap->idmap_group_hash, uid, buf);
>  	if (ret < 0)
>  		ret = nfs_map_numeric_to_string(uid, buf, buflen);
>  	return ret;
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 89b0430..114547a 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -239,7 +239,7 @@ static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
>  /* This is the error handling routine for processes that are allowed
>   * to sleep.
>   */
> -static int nfs4_handle_exception(const struct nfs_server *server, int errorcode, struct nfs4_exception *exception)
> +static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_exception *exception)
>  {
>  	struct nfs_client *clp = server->nfs_client;
>  	struct nfs4_state *state = exception->state;
> @@ -290,6 +290,12 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
>  				break;
>  		case -NFS4ERR_OLD_STATEID:
>  			exception->retry = 1;
> +			break;
> +		case -NFS4ERR_BADOWNER:
> +			if (server->caps & NFS_CAP_UIDGID_NOMAP) {
> +				server->caps &= ~NFS_CAP_UIDGID_NOMAP;
> +				exception->retry = 1;
> +			}
>  	}
>  	/* We failed to handle the error */
>  	return nfs4_map_errors(ret);
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 452d964..6309262 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -177,6 +177,7 @@ struct nfs_server {
>  #define NFS_CAP_CTIME		(1U << 12)
>  #define NFS_CAP_MTIME		(1U << 13)
>  #define NFS_CAP_POSIX_LOCK	(1U << 14)
> +#define NFS_CAP_UIDGID_NOMAP	(1U << 15)
>  
>  
>  /* maximum number of slots to use */

