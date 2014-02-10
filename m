Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:49856 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752424AbaBJVKQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Feb 2014 16:10:16 -0500
Received: by mail-ie0-f178.google.com with SMTP id rl12so676291iec.23
        for <linux-nfs@vger.kernel.org>; Mon, 10 Feb 2014 13:10:15 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH] NFSv4: Infinite loop in lease recovery when rpc.gssd is not running.
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1392066375-16502-1-git-send-email-steved@redhat.com>
Date: Mon, 10 Feb 2014 16:10:13 -0500
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <D03884DC-C5D3-4496-8F5C-682C3E6372AD@primarydata.com>
References: <1392066375-16502-1-git-send-email-steved@redhat.com>
To: Dickson Steve <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 10, 2014, at 16:06, Steve Dickson <steved@redhat.com> wrote:

> [ Resent with Trond's correct email address ]
> 
> Commit 0ea9de0e introduce a regression in the lease recovery code.
> 
> An infinite loop is caused when nfs4_establish_lease() fails
> with -EACCES. This causes nfs4_handle_reclaim_lease_error()
> to sleep a bit and resets the NFS4CLNT_LEASE_EXPIRED bit.
> This in turn causes nfs4_state_manager() to try and
> reestablished the lease, again, again, again...
> 
> The problem is a valid RPCSEC_GSS client is being created when
> rpc.gssd is not running. This is causing the RPC code to fail
> with the -EACCES sending the lease reestablished off the
> deep end.
> 
> Moving the gssd_running() check back into nfs4_init_client(),
> stopping the RPCSEC_GSS client from being create, stops
> the looping
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> fs/nfs/nfs4client.c |    5 ++++-
> 1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index 860ad26..a60269f 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -372,7 +372,10 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
> 	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
> 	__set_bit(NFS_CS_NO_RETRANS_TIMEOUT, &clp->cl_flags);
> 
> -	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);
> +	error =  -EINVAL;
> +	if (gssd_running(clp->cl_net))
> +		error = nfs_create_rpc_client(clp, timeparms,
> +				RPC_AUTH_GSS_KRB5I);
> 	if (error == -EINVAL)
> 		error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX);
> 	if (error < 0)
> -- 
> 1.7.1
> 

NACK. gssd_running() is not an acceptable solution outside of the RPC layer. 

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

