Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:47671 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750994Ab1ADVZI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 16:25:08 -0500
Date: Tue, 4 Jan 2011 13:25:04 -0800
From: Simon Kirby <sim@hostway.ca>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] NFSv4: Send unmapped uid/gids to the server when
	using auth_sys
Message-ID: <20110104212504.GG27727@hostway.ca>
References: <1291085863-3234-1-git-send-email-Trond.Myklebust@netapp.com> <1291085863-3234-2-git-send-email-Trond.Myklebust@netapp.com> <1291085863-3234-3-git-send-email-Trond.Myklebust@netapp.com> <1291085863-3234-4-git-send-email-Trond.Myklebust@netapp.com> <1291085863-3234-5-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1291085863-3234-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I finally got around to setting up idmapd properly with libnss-mysql, and
in doing so, I forgot that I had enabled nfs4_disable_idmapping=Y with
this patch applied.  With this option set on the client, and the server
set up normally, I get EINVAL from chown's fchowna():

# chown testuser:testuser test
chown: changing ownership of `test': Invalid argument
# echo N > /sys/module/nfs/parameters/nfs4_disable_idmapping
# chown testuser:testuser test
#

This happened on 2.6.37-rc5-git4, but I just reproduced it with
2.6.37-rc8-git5 as well.  The server idmapd logs:

rpc.idmapd[2987]: nss_getpwnam: name '1009999' does not map into domain 'localdomain'
rpc.idmapd[2987]:  Server: (user) name "1009999" -> id "65534"
rpc.idmapd[2987]: nfsdcb: authbuf=10.10.52.0/24 authtype=group
rpc.idmapd[2987]:  Server: (group) name "1009999" -> id "65534"

(1009999 is the current uid/gid here.)

I think you meant for this to fall back automatically, right?

Simon-

On Mon, Nov 29, 2010 at 09:57:43PM -0500, Trond Myklebust wrote:

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
> -- 
> 1.7.3.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
