Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:30895 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752390Ab3F1UCc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Jun 2013 16:02:32 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/5] NFS: Never use user credentials for lease renewal
Date: Fri, 28 Jun 2013 20:02:30 +0000
Message-ID: <1372449749.20188.0.camel@leira.trondhjem.org>
References: <20130625162233.36416.34947.stgit@seurat.1015granger.net>
	 <20130625162346.36416.25389.stgit@seurat.1015granger.net>
In-Reply-To: <20130625162346.36416.25389.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-06-25 at 12:23 -0400, Chuck Lever wrote:
> Don't try to use a non-UID-0 user credential for lease management,
> as that credential can change out from under us.  The server will
> block NFSv4 lease recovery with NFS4ERR_CLID_INUSE.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfs/nfs4proc.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index d7ba561..5ba38b3 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -6919,7 +6919,7 @@ static const struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
>  	.recover_open	= nfs4_open_reclaim,
>  	.recover_lock	= nfs4_lock_reclaim,
>  	.establish_clid = nfs4_init_clientid,
> -	.get_clid_cred	= nfs4_get_setclientid_cred,
> +	.get_clid_cred	= nfs4_get_exchange_id_cred,
>  	.detect_trunking = nfs40_discover_server_trunking,
>  };
>  
> @@ -6942,7 +6942,7 @@ static const struct nfs4_state_recovery_ops nfs40_nograce_recovery_ops = {
>  	.recover_open	= nfs4_open_expired,
>  	.recover_lock	= nfs4_lock_expired,
>  	.establish_clid = nfs4_init_clientid,
> -	.get_clid_cred	= nfs4_get_setclientid_cred,
> +	.get_clid_cred	= nfs4_get_exchange_id_cred,
>  };
>  
>  #if defined(CONFIG_NFS_V4_1)
> 

Clearly not compile tested...
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
