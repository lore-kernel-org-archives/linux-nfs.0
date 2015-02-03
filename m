Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx144.netapp.com ([216.240.21.25]:5449 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965694AbbBCQcc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Feb 2015 11:32:32 -0500
Message-ID: <54D0F81D.7020508@Netapp.com>
Date: Tue, 3 Feb 2015 11:32:29 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Tom Haynes <thomas.haynes@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v6 10/53] nfs41: create NFSv3 DS connection if specified
References: <1422916747-86649-1-git-send-email-loghyr@primarydata.com> <1422916747-86649-11-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1422916747-86649-11-git-send-email-loghyr@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tao and Tom,

I'm compiling with .config options:

CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
CONFIG_NFS_V4=y
CONFIG_NFS_V4_1=n
CONFIG_NFS_V4_2=n

And I'm getting:

fs/nfs/nfs4super.c: In function 'exit_nfs_v4':
fs/nfs/nfs4super.c:350:2: error: implicit declaration of function 'nfs4_pnfs_v3_ds_connect_unload' [-Werror=implicit-function-declaration]
  nfs4_pnfs_v3_ds_connect_unload();
  ^
cc1: all warnings being treated as errors
scripts/Makefile.build:257: recipe for target 'fs/nfs/nfs4super.o' failed
make[2]: *** [fs/nfs/nfs4super.o] Error 1
make[2]: *** Waiting for unfinished jobs....
scripts/Makefile.build:402: recipe for target 'fs/nfs' failed
make[1]: *** [fs/nfs] Error 2
Makefile:939: recipe for target 'fs' failed
make: *** [fs] Error 2

This function probably needs an empty declaration in the case that NFS v4.1 isn't enabled (but v4.0 is).

Anna

On 02/02/2015 05:38 PM, Tom Haynes wrote:
> From: Peng Tao <tao.peng@primarydata.com>
> 
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
> ---
>  fs/nfs/nfs4super.c |  3 ++
>  fs/nfs/pnfs.h      |  3 +-
>  fs/nfs/pnfs_nfs.c  | 88 +++++++++++++++++++++++++++++++++++++++++++++++++++---
>  3 files changed, 89 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
> index 6f340f0..48cea3c 100644
> --- a/fs/nfs/nfs4super.c
> +++ b/fs/nfs/nfs4super.c
> @@ -346,6 +346,9 @@ out:
>  
>  static void __exit exit_nfs_v4(void)
>  {
> +	/* Not called in the _init(), conditionally loaded */
> +	nfs4_pnfs_v3_ds_connect_unload();
> +
>  	unregister_nfs_version(&nfs_v4);
>  	nfs4_unregister_sysctl();
>  	nfs_idmap_quit();
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 70ffec1..9ccaa50 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -323,9 +323,10 @@ void pnfs_generic_write_commit_done(struct rpc_task *task, void *data);
>  void nfs4_pnfs_ds_put(struct nfs4_pnfs_ds *ds);
>  struct nfs4_pnfs_ds *nfs4_pnfs_ds_add(struct list_head *dsaddrs,
>  				      gfp_t gfp_flags);
> +void nfs4_pnfs_v3_ds_connect_unload(void);
>  void nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
>  			  struct nfs4_deviceid_node *devid, unsigned int timeo,
> -			  unsigned int retrans, u32 versoin, u32 minor_version,
> +			  unsigned int retrans, u32 version, u32 minor_version,
>  			  rpc_authflavor_t au_flavor);
>  struct nfs4_pnfs_ds_addr *nfs4_decode_mp_ds_addr(struct net *net,
>  						 struct xdr_stream *xdr,
> diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
> index ad211a4..23c851d 100644
> --- a/fs/nfs/pnfs_nfs.c
> +++ b/fs/nfs/pnfs_nfs.c
> @@ -10,6 +10,7 @@
>  #include <linux/nfs_fs.h>
>  #include <linux/nfs_page.h>
>  #include <linux/sunrpc/addr.h>
> +#include <linux/module.h>
>  
>  #include "nfs4session.h"
>  #include "internal.h"
> @@ -550,7 +551,75 @@ static void nfs4_clear_ds_conn_bit(struct nfs4_pnfs_ds *ds)
>  	wake_up_bit(&ds->ds_state, NFS4DS_CONNECTING);
>  }
>  
> -static int _nfs4_pnfs_ds_connect(struct nfs_server *mds_srv,
> +static struct nfs_client *(*get_v3_ds_connect)(
> +			struct nfs_client *mds_clp,
> +			const struct sockaddr *ds_addr,
> +			int ds_addrlen,
> +			int ds_proto,
> +			unsigned int ds_timeo,
> +			unsigned int ds_retrans,
> +			rpc_authflavor_t au_flavor);
> +
> +static bool load_v3_ds_connect(void)
> +{
> +	if (!get_v3_ds_connect) {
> +		get_v3_ds_connect = symbol_request(nfs3_set_ds_client);
> +		WARN_ON_ONCE(!get_v3_ds_connect);
> +	}
> +
> +	return(get_v3_ds_connect != NULL);
> +}
> +
> +void __exit nfs4_pnfs_v3_ds_connect_unload(void)
> +{
> +	if (get_v3_ds_connect) {
> +		symbol_put(nfs3_set_ds_client);
> +		get_v3_ds_connect = NULL;
> +	}
> +}
> +EXPORT_SYMBOL_GPL(nfs4_pnfs_v3_ds_connect_unload);
> +
> +static int _nfs4_pnfs_v3_ds_connect(struct nfs_server *mds_srv,
> +				 struct nfs4_pnfs_ds *ds,
> +				 unsigned int timeo,
> +				 unsigned int retrans,
> +				 rpc_authflavor_t au_flavor)
> +{
> +	struct nfs_client *clp = ERR_PTR(-EIO);
> +	struct nfs4_pnfs_ds_addr *da;
> +	int status = 0;
> +
> +	dprintk("--> %s DS %s au_flavor %d\n", __func__,
> +		ds->ds_remotestr, au_flavor);
> +
> +	if (!load_v3_ds_connect())
> +		goto out;
> +
> +	list_for_each_entry(da, &ds->ds_addrs, da_node) {
> +		dprintk("%s: DS %s: trying address %s\n",
> +			__func__, ds->ds_remotestr, da->da_remotestr);
> +
> +		clp = get_v3_ds_connect(mds_srv->nfs_client,
> +					(struct sockaddr *)&da->da_addr,
> +					da->da_addrlen, IPPROTO_TCP,
> +					timeo, retrans, au_flavor);
> +		if (!IS_ERR(clp))
> +			break;
> +	}
> +
> +	if (IS_ERR(clp)) {
> +		status = PTR_ERR(clp);
> +		goto out;
> +	}
> +
> +	smp_wmb();
> +	ds->ds_clp = clp;
> +	dprintk("%s [new] addr: %s\n", __func__, ds->ds_remotestr);
> +out:
> +	return status;
> +}
> +
> +static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
>  				 struct nfs4_pnfs_ds *ds,
>  				 unsigned int timeo,
>  				 unsigned int retrans,
> @@ -562,7 +631,7 @@ static int _nfs4_pnfs_ds_connect(struct nfs_server *mds_srv,
>  	int status = 0;
>  
>  	dprintk("--> %s DS %s au_flavor %d\n", __func__, ds->ds_remotestr,
> -		mds_srv->nfs_client->cl_rpcclient->cl_auth->au_flavor);
> +		au_flavor);
>  
>  	list_for_each_entry(da, &ds->ds_addrs, da_node) {
>  		dprintk("%s: DS %s: trying address %s\n",
> @@ -609,8 +678,19 @@ void nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
>  	if (test_and_set_bit(NFS4DS_CONNECTING, &ds->ds_state) == 0) {
>  		int err = 0;
>  
> -		err = _nfs4_pnfs_ds_connect(mds_srv, ds, timeo, retrans,
> -					    minor_version, au_flavor);
> +		if (version == 3) {
> +			err = _nfs4_pnfs_v3_ds_connect(mds_srv, ds, timeo,
> +						       retrans, au_flavor);
> +		} else if (version == 4) {
> +			err = _nfs4_pnfs_v4_ds_connect(mds_srv, ds, timeo,
> +						       retrans, minor_version,
> +						       au_flavor);
> +		} else {
> +			dprintk("%s: unsupported DS version %d\n", __func__,
> +				version);
> +			err = -EPROTONOSUPPORT;
> +		}
> +
>  		if (err)
>  			nfs4_mark_deviceid_unavailable(devid);
>  		nfs4_clear_ds_conn_bit(ds);
> 

