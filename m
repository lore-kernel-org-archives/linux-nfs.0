Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:61961 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411Ab2JaWOr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2012 18:14:47 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so878688wey.19
        for <linux-nfs@vger.kernel.org>; Wed, 31 Oct 2012 15:14:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1351627595-6462-1-git-send-email-bjschuma@netapp.com>
References: <1351627595-6462-1-git-send-email-bjschuma@netapp.com>
Date: Wed, 31 Oct 2012 18:14:46 -0400
Message-ID: <CAHVgHyXWk86GGJ0Fip3uE5SG94aUpcfuh1A4R+UWr442Q2P5Nw@mail.gmail.com>
Subject: Re: [PATCH] NFS: Wait for session recovery to finish before returning
From: Andy Adamson <androsadamson@gmail.com>
To: bjschuma@netapp.com
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 30, 2012 at 4:06 PM,  <bjschuma@netapp.com> wrote:
> From: Bryan Schumaker <bjschuma@netapp.com>
>
> Currently, we will schedule session recovery and then return to the
> caller of nfs4_handle_exception.  This works for most cases, but causes
> a hang on the following test case:
>
>         Client                          Server
>         ------                          ------
>         Open file over NFS v4.1
>         Write to file
>                                         Expire client
>         Try to lock file
>
> The server will return NFS4ERR_BADSESSION, prompting the client to
> schedule recovery.  However, the client will continue placing lock
> attempts and the open recovery never seems to be scheduled.

I need more detail. Is this what is happening?

When the first NFS4ERR_BADSESSION error arrives, session recovery
starts by setting the NFS4_SESSION_DRAINING bit which places all non
RPC_PRIORITY_PRIVILEGED tasks with OP_SEQUENCE on the slot_tbl_waitq,
so the lock requests should be placed on the slot_tbl_waitq and not go
on the wire.

Once the session is drained,  DESTROY_SESSION and CREATE_SESSION are
called and one will return with NFS4ERR_STALE_CLIENTID kicking off the
EXCHANGE_ID / CREATE_SESSION to establish a new clientid.

Do you see the clientid being recovered?

Once the new session is created, it inherits the slot_tbl_waitq of the
old session, and all the lock requests and any other tasks piled up on
the slot_tbl_waitq will run. At the same time, the state_manager
thread is running recovery for any OPENs established under the old
clientid, and then their associated LOCKs.

The OPEN and LOCK recovery tasks run with RPC_PRIORITY_PRIVILEGE which
should mean that they get run before the RPC tasks with lower
priority.

So my question (finally!): How is open recovery starvation happening?
nfs41_sequence_free_slot => nfs4_check_drain_fc_complete =>
rpc_wake_up_first on the session slot_tbl_waitq, which in turn calls
__rpc_find_next_queued_priority which should choose
RPC_PRIORITY_PRIVILEGE tasks over lower privileged tasks on the
session slot_tbl_waitq.

So even with a bunch of slots, when the first one returns and and free
it's slot, the priority tasks (e.g. open recovery) should run.


-->Andy


> The
> simplest solution is to wait for session recovery to run before retrying
> the lock.

If on the wire RPCs return with NFS4ERR_BADSESSION, and then wait for
session recovery in the exception handler, they will not call their
rpc_release function

>
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
>  fs/nfs/nfs4proc.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 8b04d14..70e0c47 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -338,8 +338,7 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
>                         dprintk("%s ERROR: %d Reset session\n", __func__,
>                                 errorcode);
>                         nfs4_schedule_session_recovery(clp->cl_session, errorcode);
> -                       exception->retry = 1;
> -                       break;
> +                       goto wait_on_recovery;
>  #endif /* defined(CONFIG_NFS_V4_1) */
>                 case -NFS4ERR_FILE_OPEN:
>                         if (exception->timeout > HZ) {
> --
> 1.8.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
