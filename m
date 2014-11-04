Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f171.google.com ([209.85.213.171]:35439 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbaKDXWS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Nov 2014 18:22:18 -0500
Received: by mail-ig0-f171.google.com with SMTP id hl2so7626961igb.10
        for <linux-nfs@vger.kernel.org>; Tue, 04 Nov 2014 15:22:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1415025403-31914-1-git-send-email-kolga@netapp.com>
References: <1415025403-31914-1-git-send-email-kolga@netapp.com>
Date: Tue, 4 Nov 2014 18:22:17 -0500
Message-ID: <CAN-5tyHVoJ60z7WBaCYvUN3GsCEGh9jGc0evRCuiVt2aA6zP0g@mail.gmail.com>
Subject: Re: [PATCH 1/1] Fixing infinite state recovery loop due to failed
 delegation return
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond, can you please respond to the patch?

As per earlier conversation, in this solution, state recovery is
initiated which marks the locks lost.

Please either accept this patch or let me know what needs to be fixed.

Thank you.

On Mon, Nov 3, 2014 at 9:36 AM, Olga Kornievskaia <kolga@netapp.com> wrote:
> If we get a bad-stateid-type of error when we send OPEN with delegate_cur
> to return currently held delegation, we shouldn't be trying to reclaim locks
> associated with that delegation state_id because we don't have an
> open_stateid to be used for the LOCK operation. Thus, we should
> return an error from the nfs4_open_delegation_recall() in that case.
>
> Furthermore, if an error occurs the delegation code will call
> nfs_abort_delegation_return() which sets again the NFS4CLNT_DELEGRETURN
> flags in the state and it leads the state manager to into an infinite loop
> for trying to reclaim the delegated state.
>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/delegation.c |    5 +++--
>  fs/nfs/nfs4proc.c   |    2 +-
>  2 files changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index 5853f53..8016d89 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -394,7 +394,7 @@ static int nfs_end_delegation_return(struct inode *inode, struct nfs_delegation
>                 err = nfs4_wait_clnt_recover(clp);
>         } while (err == 0);
>
> -       if (err) {
> +       if (err && err != -EIO) {
>                 nfs_abort_delegation_return(delegation, clp);
>                 goto out;
>         }
> @@ -458,7 +458,8 @@ restart:
>                         iput(inode);
>                         if (!err)
>                                 goto restart;
> -                       set_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state);
> +                       if (err != -EIO)
> +                               set_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state);
>                         return err;
>                 }
>         }
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 5aa55c1..6871055 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1655,7 +1655,7 @@ static int nfs4_handle_delegation_recall_error(struct nfs_server *server, struct
>                         nfs_inode_find_state_and_recover(state->inode,
>                                         stateid);
>                         nfs4_schedule_stateid_recovery(server, state);
> -                       return 0;
> +                       return -EIO;
>                 case -NFS4ERR_DELAY:
>                 case -NFS4ERR_GRACE:
>                         set_bit(NFS_DELEGATED_STATE, &state->flags);
> --
> 1.7.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
