Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:48123 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243AbaJAScx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Oct 2014 14:32:53 -0400
Received: by mail-qa0-f51.google.com with SMTP id k15so673220qaq.38
        for <linux-nfs@vger.kernel.org>; Wed, 01 Oct 2014 11:32:52 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 1 Oct 2014 14:32:49 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/2] NFSv4: Fix lock recovery when
 CREATE_SESSION/SETCLIENTID_CONFIRM fails
Message-ID: <20141001143249.4e837eb1@synchrony.poochiereds.net>
In-Reply-To: <1411876498-12039-2-git-send-email-trond.myklebust@primarydata.com>
References: <1411876498-12039-1-git-send-email-trond.myklebust@primarydata.com>
	<1411876498-12039-2-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 27 Sep 2014 23:54:57 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> If a NFSv4.x server returns NFS4ERR_STALE_CLIENTID in response to a
> CREATE_SESSION or SETCLIENTID_CONFIRM in order to tell us that it rebooted
> a second time, then the client will currently take this to mean that it must
> declare all locks to be stale, and hence ineligible for reboot recovery.
> 
> RFC3530 and RFC5661 both suggest that the client should instead rely on the
> server to respond to inelegible open share, lock and delegation reclaim
> requests with NFS4ERR_NO_GRACE in this situation.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4state.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 22fe35104c0c..26d510d11efd 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1761,7 +1761,6 @@ static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
>  		break;
>  	case -NFS4ERR_STALE_CLIENTID:
>  		clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
> -		nfs4_state_clear_reclaim_reboot(clp);
>  		nfs4_state_start_reclaim_reboot(clp);
>  		break;
>  	case -NFS4ERR_CLID_INUSE:

What distinguishes between the v4.0 and v4.1+ case here?

For v4.1+, we do want the client to just try to reclaim everything that
it can. For v4.0 though, we need to be a little more careful. Consider:


Client				Server
===================================================================
SETCLIENTID
OPEN (O1)
LOCK (L1)
				reboot (B1)

RENEW				(NFS4ERR_STALE_CLIENTID)
SETCLIENTID			
OPEN(reclaim O1)		(NFS4_OK)

	=== NETWORK PARTITION ===
				Grace period is lifted, but client1's
				lease hasn't expired yet

				Lock that conflicts with L1 is handed out to client2
				
				reboot (B2)
	=== PARTITION HEALS ===
LOCK(reclaim L1)		(NFS4ERR_STALE_CLIENTID)

SETCLIENTID			
OPEN (reclaim O1)		(NFS4_OK)
LOCK (reclaim L1)		(NFS4_OK)


Now we have a conflict. I think that the client should not try to
reclaim L1 after B2 in the v4.0 case. Do we need to do something
to handle the v4.0 vs. v4.1+ cases differently here?

-- 
Jeff Layton <jlayton@primarydata.com>
