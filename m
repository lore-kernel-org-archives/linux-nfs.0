Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34765 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752784AbdCTVId (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Mar 2017 17:08:33 -0400
Received: by mail-it0-f66.google.com with SMTP id z70so5115053itb.1
        for <linux-nfs@vger.kernel.org>; Mon, 20 Mar 2017 14:08:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87zijsu4ko.fsf@notabene.neil.brown.name>
References: <87y46monel.fsf@notabene.neil.brown.name> <87bmyx3q3u.fsf@notabene.neil.brown.name>
 <C37BA8D0-2EAF-41D7-9086-D8729D4BAD48@primarydata.com> <8737k2354z.fsf@notabene.neil.brown.name>
 <87zijsu4ko.fsf@notabene.neil.brown.name>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 20 Mar 2017 17:00:57 -0400
Message-ID: <CAN-5tyFPVQo26XZ=g0uRuhkJ+x95S8frSyos6J_56HP4U3Ygrg@mail.gmail.com>
Subject: Re: [PATCH resend] NFS: Don't disconnect open-owner on NFS4ERR_BAD_SEQID
To: NeilBrown <neilb@suse.com>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since open_owner is no longer removed then the resources are not
freed. They will not be freed until unmount  (or reboot recovery).

There are (buggy) servers out there that might be forcing the client
to keep creating new open_owners. So if they are no longer released,
can't the client get into trouble here?

On Sun, Dec 18, 2016 at 7:48 PM, NeilBrown <neilb@suse.com> wrote:
>
> When an NFS4ERR_BAD_SEQID is received the open-owner is removed from
> the ->state_owners rbtree so that it will no longer be used.
>
> If any stateids attached to this open-owner are still in use, and if a
> request using one gets an NFS4ERR_BAD_STATEID reply, this can for bad.
>
> The state is marked as needing recovery and the nfs4_state_manager()
> is scheduled to clean up.  nfs4_state_manager() finds states to be
> recovered by walking the state_owners rbtree.  As the open-owner is
> not in the rbtree, the bad state is not found so nfs4_state_manager()
> completes having done nothing.  The request is then retried, with a
> predicatable result (indefinite retries).
>
> If the stateid is for a delegation, this open_owner will be used
> to open files when the delegation is returned.  For that to work,
> a new open-owner needs to be presented to the server.
>
> This patch changes NFS4ERR_BAD_SEQID handling to leave the open-owner
> in the rbtree but updates the 'create_time' so it looks like a new
> open-owner.  With this the indefinite retries no longer happen.
>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>
> Hi Trond,
>  It appears this one got lost too.
>  I've added a comment as I thought an explanation was needed, and
>  renamed the function from "drop" to "reset".
>
> Thanks,
> NeilBrown
>
>  fs/nfs/nfs4state.c | 29 +++++++++++++----------------
>  1 file changed, 13 insertions(+), 16 deletions(-)
>
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index cf869802ff23..1d152f4470cd 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -494,21 +494,18 @@ nfs4_alloc_state_owner(struct nfs_server *server,
>  }
>
>  static void
> -nfs4_drop_state_owner(struct nfs4_state_owner *sp)
> -{
> -       struct rb_node *rb_node = &sp->so_server_node;
> -
> -       if (!RB_EMPTY_NODE(rb_node)) {
> -               struct nfs_server *server = sp->so_server;
> -               struct nfs_client *clp = server->nfs_client;
> -
> -               spin_lock(&clp->cl_lock);
> -               if (!RB_EMPTY_NODE(rb_node)) {
> -                       rb_erase(rb_node, &server->state_owners);
> -                       RB_CLEAR_NODE(rb_node);
> -               }
> -               spin_unlock(&clp->cl_lock);
> -       }
> +nfs4_reset_state_owner(struct nfs4_state_owner *sp)
> +{
> +       /* This state_owner is no longer usable, but must
> +        * remain in place so that state recovery can find it
> +        * and the opens associated with it.
> +        * It may also be used for new 'open' request to
> +        * return a delegation to the server.
> +        * So update the 'create_time' so that it looks like
> +        * a new state_owner.  This will cause the server to
> +        * request an OPEN_CONFIRM to start a new sequence.
> +        */
> +       sp->so_seqid.create_time = ktime_get();
>  }
>
>  static void nfs4_free_state_owner(struct nfs4_state_owner *sp)
> @@ -1113,7 +1110,7 @@ void nfs_increment_open_seqid(int status, struct nfs_seqid *seqid)
>
>         sp = container_of(seqid->sequence, struct nfs4_state_owner, so_seqid);
>         if (status == -NFS4ERR_BAD_SEQID)
> -               nfs4_drop_state_owner(sp);
> +               nfs4_reset_state_owner(sp);
>         if (!nfs4_has_session(sp->so_server->nfs_client))
>                 nfs_increment_seqid(status, seqid);
>  }
> --
> 2.11.0
>
