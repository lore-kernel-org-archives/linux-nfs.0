Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:33711 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011AbaLSUQp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Dec 2014 15:16:45 -0500
Received: by mail-ie0-f182.google.com with SMTP id x19so1386535ier.27
        for <linux-nfs@vger.kernel.org>; Fri, 19 Dec 2014 12:16:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1419015154-91037-1-git-send-email-trond.myklebust@primarydata.com>
References: <CAHQdGtQ_aHRknHzebarn8NUos_wBf4BZOCeg627FsLzcK3erOA@mail.gmail.com>
	<1419015154-91037-1-git-send-email-trond.myklebust@primarydata.com>
Date: Fri, 19 Dec 2014 15:16:43 -0500
Message-ID: <CAN-5tyGfa6zHPDTF=UQOV8JF44bXnBinOg=NcvYL7kc69x=qUg@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] NFSv4: Deal with atomic upgrades of an existing delegation
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Aha, yes yes yes, that would make sense how it is still returned if
seq ids are different. I'll have this tested asap.

On Fri, Dec 19, 2014 at 1:52 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> Ensure that we deal correctly with the case where the server sends us a
> newer instance of the same delegation. If the stateids match, but the
> sequence numbers differ, then treat the new delegation as if it were
> an atomic upgrade.
>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@primarydata.com>
> ---
>  fs/nfs/delegation.c | 21 ++++++++++++++++++---
>  1 file changed, 18 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index 7f3f60641344..02b5b2a6d557 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -301,6 +301,19 @@ nfs_inode_detach_delegation(struct inode *inode)
>         return nfs_detach_delegation(nfsi, delegation, server);
>  }
>
> +static void
> +nfs_update_inplace_delegation(struct nfs_inode *nfsi,
> +               struct nfs_delegation *delegation,
> +               struct nfs_delegation *update)
> +{
> +       if (nfs4_stateid_is_newer(&update->stateid, &delegation->stateid))
> +               return;
> +       delegation->stateid.seqid = update->stateid.seqid;
> +       smp_wmb();
> +       delegation->type = update->type;
> +       nfsi->delegation_state = update->type;
> +}
> +
>  /**
>   * nfs_inode_set_delegation - set up a delegation on an inode
>   * @inode: inode to which delegation applies
> @@ -334,9 +347,11 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
>         old_delegation = rcu_dereference_protected(nfsi->delegation,
>                                         lockdep_is_held(&clp->cl_lock));
>         if (old_delegation != NULL) {
> -               if (nfs4_stateid_match(&delegation->stateid,
> -                                       &old_delegation->stateid) &&
> -                               delegation->type == old_delegation->type) {
> +               /* Is this an update of the existing delegation? */
> +               if (nfs4_stateid_match_other(&old_delegation->stateid,
> +                                       &delegation->stateid)) {
> +                       nfs_update_inplace_delegation(nfsi, old_delegation,
> +                                       delegation);
>                         goto out;
>                 }
>                 /*
> --
> 2.1.0
>
