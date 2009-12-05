From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/3] nfs41: Mark stateids in need of reclaim if state
 manager gets stale clientid
Date: Sat, 05 Dec 2009 15:34:13 -0500
Message-ID: <1260045253.29208.6.camel@localhost>
References: <>
	 <1260043884-16267-1-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1260043884-16267-2-git-send-email-Ricardo.Labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8326 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755484AbZLEUlS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Dec 2009 15:41:18 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB5KfO3j011185
	for <linux-nfs@vger.kernel.org>; Sat, 5 Dec 2009 12:41:25 -0800 (PST)
In-Reply-To: <1260043884-16267-2-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-12-05 at 12:11 -0800, Ricardo Labiaga wrote: 
> The state manager was not marking the stateids as needing to be reclaimed
> after reestablishing the clientid.
> 
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> ---
>  fs/nfs/nfs4state.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 630199d..ae90df8 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1157,6 +1157,7 @@ static void nfs4_session_recovery_handle_error(struct nfs_client *clp, int err)
>  	case -NFS4ERR_STALE_CLIENTID:
>  		set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
>  		set_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
> +		nfs4_state_start_reclaim_reboot(clp);
>  	}
>  }
>  

So, why do we need a special nfs4_session_recovery_handle_error() that
just mirrors the existing nfs4_recovery_handle_error().

Please just get rid of it...

Trond
