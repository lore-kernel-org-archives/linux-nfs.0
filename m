Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:31270 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755207Ab0KNMFR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Nov 2010 07:05:17 -0500
Message-ID: <4CDFD07A.5040300@panasas.com>
Date: Sun, 14 Nov 2010 14:05:14 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/22] SQUASHME: allow cb_sequence changes to compile
 without v4.1
References: <1289551724-18575-1-git-send-email-iisaman@netapp.com> <1289551724-18575-9-git-send-email-iisaman@netapp.com>
In-Reply-To: <1289551724-18575-9-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-11-12 10:48, Fred Isaman wrote:
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
>  fs/nfs/callback.h      |   26 ++++++++++++++++++++++++++
>  fs/nfs/callback_proc.c |    6 ------
>  fs/nfs/callback_xdr.c  |    3 +--
>  fs/nfs/internal.h      |    4 ++++
>  4 files changed, 31 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
> index 89fee05..0b1f3c4 100644
> --- a/fs/nfs/callback.h
> +++ b/fs/nfs/callback.h
> @@ -8,6 +8,8 @@
>  #ifndef __LINUX_FS_NFS_CALLBACK_H
>  #define __LINUX_FS_NFS_CALLBACK_H
>  
> +#include "internal.h"
> +
>  #define NFS4_CALLBACK 0x40000000
>  #define NFS4_CALLBACK_XDRSIZE 2048
>  #define NFS4_CALLBACK_BUFSIZE (1024 + NFS4_CALLBACK_XDRSIZE)
> @@ -158,6 +160,30 @@ extern unsigned nfs4_callback_layoutrecall(
>  	struct cb_layoutrecallargs *args,
>  	void *dummy, struct cb_process_state *cps);
>  
> +static inline void put_session_client(struct nfs4_session *session)
> +{
> +	if (session)  /* matched by cb_sequence find_client_with_session */

nit: comment out of scope.  belongs to the call site, not here...

> +		nfs_put_client(session->clp);
> +}
> +
> +static inline struct nfs_client *
> +find_client_from_cps(struct cb_process_state *cps, struct sockaddr *addr)
> +{
> +	return cps->session ? cps->session->clp : nfs_find_client(addr, 4);
> +}
> +
> +#else

nit: /* CONFIG_NFS_V4_1 */ comment missing

(I'll fix both in my tree)

Benny

> +
> +static inline struct nfs_client *
> +find_client_from_cps(struct cb_process_state *cps, struct sockaddr *addr)
> +{
> +	return nfs_find_client(addr, 4);
> +}
> +
> +static inline void put_session_client(struct nfs4_session *session)
> +{
> +}
> +
>  #endif /* CONFIG_NFS_V4_1 */
>  
>  extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 2e62155..d02997a 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -21,12 +21,6 @@
>  #define NFSDBG_FACILITY NFSDBG_CALLBACK
>  #endif
>  
> -static struct nfs_client *
> -find_client_from_cps(struct cb_process_state *cps, struct sockaddr *addr)
> -{
> -	return cps->session ? cps->session->clp : nfs_find_client(addr, 4);
> -}
> -
>  __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
>  			     struct cb_getattrres *res,
>  			     struct cb_process_state *cps)
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index 1650ab0..01688ce 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -770,8 +770,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
>  
>  	*hdr_res.status = status;
>  	*hdr_res.nops = htonl(nops);
> -	if (cps.session) /* matched by cb_sequence find_client_with_session */
> -		nfs_put_client(cps.session->clp);
> +	put_session_client(cps.session);
>  	dprintk("%s: done, status = %u\n", __func__, ntohl(status));
>  	return rpc_success;
>  }
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 755e555..6f14089 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -2,6 +2,8 @@
>   * NFS internal definitions
>   */
>  
> +#ifndef __LINUX_FS_NFS_INTERNAL_H
> +#define __LINUX_FS_NFS_INTERNAL_H
>  #include "nfs4_fs.h"
>  #include <linux/mount.h>
>  #include <linux/security.h>
> @@ -415,3 +417,5 @@ static inline int nfs_restart_rpc(struct rpc_task *task, const struct nfs_client
>  		return rpc_restart_call_prepare(task);
>  	return rpc_restart_call(task);
>  }
> +
> +#endif /* __LINUX_FS_NFS_INTERNAL_H */
