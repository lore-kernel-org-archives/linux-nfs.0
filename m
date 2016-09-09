Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35768 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754407AbcIIS0c (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Sep 2016 14:26:32 -0400
Received: by mail-oi0-f68.google.com with SMTP id 2so11400002oif.2
        for <linux-nfs@vger.kernel.org>; Fri, 09 Sep 2016 11:26:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1473444253-12433-2-git-send-email-trond.myklebust@primarydata.com>
References: <1473444253-12433-1-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-2-git-send-email-trond.myklebust@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 9 Sep 2016 14:26:30 -0400
Message-ID: <CAN-5tyGt707WXutT+vr-Yy4iRNTzDB=F0J41L3e0FomMGf4unA@mail.gmail.com>
Subject: Re: [PATCH v3 01/12] NFSv4.1: Don't deadlock the state manager on the
 SEQUENCE status flags
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        Oleg Drokin <green@linuxhacker.ru>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 9, 2016 at 2:04 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> As described in RFC5661, section 18.46, some of the status flags exist
> in order to tell the client when it needs to acknowledge the existence of
> revoked state on the server and/or to recover state.
> Those flags will then remain set until the recovery procedure is done.
>
> In order to avoid looping, the client therefore needs to ignore
> those particular flags while recovering.
>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4_fs.h     |  2 +-
>  fs/nfs/nfs4proc.c    |  5 ++++-
>  fs/nfs/nfs4session.h |  1 +
>  fs/nfs/nfs4state.c   | 12 +++++++++++-
>  4 files changed, 17 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index f230aa62ca59..4390d73a92e5 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -439,7 +439,7 @@ extern void nfs4_schedule_path_down_recovery(struct nfs_client *clp);
>  extern int nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
>  extern int nfs4_schedule_migration_recovery(const struct nfs_server *);
>  extern void nfs4_schedule_lease_moved_recovery(struct nfs_client *);
> -extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
> +extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags, bool);
>  extern void nfs41_handle_server_scope(struct nfs_client *,
>                                       struct nfs41_server_scope **);
>  extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 25a2af707233..bd33777f03c4 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -616,6 +616,7 @@ int nfs40_setup_sequence(struct nfs4_slot_table *tbl,
>         }
>         spin_unlock(&tbl->slot_tbl_lock);
>
> +       slot->privileged = args->sa_privileged ? 1 : 0;
>         args->sa_slot = slot;
>         res->sr_slot = slot;
>
> @@ -728,7 +729,8 @@ static int nfs41_sequence_process(struct rpc_task *task,
>                 clp = session->clp;
>                 do_renew_lease(clp, res->sr_timestamp);
>                 /* Check sequence flags */
> -               nfs41_handle_sequence_flag_errors(clp, res->sr_status_flags);
> +               nfs41_handle_sequence_flag_errors(clp, res->sr_status_flags,
> +                               !!slot->privileged);

Is this suppose to be "!!"?

>                 nfs41_update_target_slotid(slot->table, slot, res);
>                 break;
>         case 1:
> @@ -875,6 +877,7 @@ int nfs41_setup_sequence(struct nfs4_session *session,
>         }
>         spin_unlock(&tbl->slot_tbl_lock);
>
> +       slot->privileged = args->sa_privileged ? 1 : 0;
>         args->sa_slot = slot;
>
>         dprintk("<-- %s slotid=%u seqid=%u\n", __func__,
> diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
> index 3bb6af70973c..dae385500005 100644
> --- a/fs/nfs/nfs4session.h
> +++ b/fs/nfs/nfs4session.h
> @@ -23,6 +23,7 @@ struct nfs4_slot {
>         u32                     slot_nr;
>         u32                     seq_nr;
>         unsigned int            interrupted : 1,
> +                               privileged : 1,
>                                 seq_done : 1;
>  };
>
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index cada00aa5096..9801b5bb5fac 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -2227,13 +2227,22 @@ static void nfs41_handle_cb_path_down(struct nfs_client *clp)
>                 nfs4_schedule_state_manager(clp);
>  }
>
> -void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags)
> +void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags,
> +               bool recovery)
>  {
>         if (!flags)
>                 return;
>
>         dprintk("%s: \"%s\" (client ID %llx) flags=0x%08x\n",
>                 __func__, clp->cl_hostname, clp->cl_clientid, flags);
> +       /*
> +        * If we're called from the state manager thread, then assume we're
> +        * already handling the RECLAIM_NEEDED and/or STATE_REVOKED.
> +        * Those flags are expected to remain set until we're done
> +        * recovering (see RFC5661, section 18.46.3).
> +        */
> +       if (recovery)
> +               goto out_recovery;
>
>         if (flags & SEQ4_STATUS_RESTART_RECLAIM_NEEDED)
>                 nfs41_handle_server_reboot(clp);
> @@ -2246,6 +2255,7 @@ void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags)
>                 nfs4_schedule_lease_moved_recovery(clp);
>         if (flags & SEQ4_STATUS_RECALLABLE_STATE_REVOKED)
>                 nfs41_handle_recallable_state_revoked(clp);
> +out_recovery:
>         if (flags & SEQ4_STATUS_BACKCHANNEL_FAULT)
>                 nfs41_handle_backchannel_fault(clp);
>         else if (flags & (SEQ4_STATUS_CB_PATH_DOWN |
> --
> 2.7.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
