Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:46654 "EHLO
	mx01.colomx.prod.int.phx2.redhat.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932666Ab0JFQB0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Oct 2010 12:01:26 -0400
Date: Wed, 6 Oct 2010 12:01:25 -0400 (EDT)
From: Sachin Prabhu <sprabhu@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <3901595.16.1286380884167.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
In-Reply-To: <18697573.14.1286380841649.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
Subject: Re: NFS4 clients cannot reclaim locks
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:
> ...Here is the second patch.
> 
> Cheers
>   Trond
> ------------------------------------------------------------------------------------------------------
> NFSv4: Don't call nfs4_state_mark_reclaim_reboot() from error
> handlers
> 
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> In the case of a server reboot, the state recovery thread starts by
> calling
> nfs4_state_end_reclaim_reboot() in order to avoid edge conditions
> when
> the server reboots while the client is in the middle of recovery.
> 
> However, if the client has already marked the nfs4_state as requiring
> reboot recovery, then the above behaviour will cause the recovery
> thread to
> treat the open as if it was part of such an edge condition: the open
> will
> be recovered as if it was part of a lease expiration (and all the
> locks
> will be lost).
> Fix is to remove the call to nfs4_state_mark_reclaim_reboot from
> nfs4_async_handle_error(), and nfs4_handle_exception(). Instead we
> leave it
> to the recovery thread to do this for us.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/nfs/nfs4proc.c |    6 ------
>  1 files changed, 0 insertions(+), 6 deletions(-)
> 
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 01b4817..74aa54e 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -255,9 +255,6 @@ static int nfs4_handle_exception(const struct
> nfs_server *server, int errorcode,
>  			nfs4_state_mark_reclaim_nograce(clp, state);
>  			goto do_state_recovery;
>  		case -NFS4ERR_STALE_STATEID:
> -			if (state == NULL)
> -				break;
> -			nfs4_state_mark_reclaim_reboot(clp, state);
>  		case -NFS4ERR_STALE_CLIENTID:
>  		case -NFS4ERR_EXPIRED:
>  			goto do_state_recovery;
> @@ -3493,9 +3490,6 @@ nfs4_async_handle_error(struct rpc_task *task,
> const struct nfs_server *server,
>  			nfs4_state_mark_reclaim_nograce(clp, state);
>  			goto do_state_recovery;
>  		case -NFS4ERR_STALE_STATEID:
> -			if (state == NULL)
> -				break;
> -			nfs4_state_mark_reclaim_reboot(clp, state);
>  		case -NFS4ERR_STALE_CLIENTID:
>  		case -NFS4ERR_EXPIRED:
>  			goto do_state_recovery;

Yes. The patch works for me.

An open call is made to the server with claim-type set to claim previous. This resets the stateid and the write operation can continue.

Thank You

Sachin Prabhu

