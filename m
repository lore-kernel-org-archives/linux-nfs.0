Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f182.google.com ([209.85.220.182]:60755 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbaLSSvK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Dec 2014 13:51:10 -0500
Received: by mail-vc0-f182.google.com with SMTP id hq12so544330vcb.27
        for <linux-nfs@vger.kernel.org>; Fri, 19 Dec 2014 10:51:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1419012641-8564-1-git-send-email-trond.myklebust@primarydata.com>
References: <CAN-5tyHAckqJoAbD02rmW1jRiGDK_4_oDvm8eDosZwvd_jc3CQ@mail.gmail.com>
	<1419012641-8564-1-git-send-email-trond.myklebust@primarydata.com>
Date: Fri, 19 Dec 2014 13:51:08 -0500
Message-ID: <CAHQdGtQ_aHRknHzebarn8NUos_wBf4BZOCeg627FsLzcK3erOA@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFSv4: Deal with atomic upgrades of an existing delegation
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 19, 2014 at 1:10 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> Ensure that we deal correctly with the case where the server sends us a
> newer instance of the same delegation. If the stateids match, but the
> sequence numbers differ, then treat the new delegation as if it were
> an atomic upgrade.
>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@primarydata.com>
> ---
>  fs/nfs/delegation.c | 20 +++++++++++++++++---
>  1 file changed, 17 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index 7f3f60641344..90413cdbf254 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -301,6 +301,18 @@ nfs_inode_detach_delegation(struct inode *inode)
>         return nfs_detach_delegation(nfsi, delegation, server);
>  }
>
> +static void
> +nfs_update_inplace_delegation(struct nfs_delegation *delegation,
> +               struct nfs_delegation *update)
> +{
> +       if (nfs4_stateid_is_newer(&update->stateid, &delegation->stateid))
> +               return;
> +       delegation->stateid.seqid = update->stateid.seqid;
> +       smp_wmb();
> +       delegation->type == update->type;
> +       nfsi->delegation_state = update->type;

Oops... That wasn't intended. I'll resend an update that actually compiles...

> +}
> +
>  /**
>   * nfs_inode_set_delegation - set up a delegation on an inode
>   * @inode: inode to which delegation applies
> @@ -334,9 +346,11 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
>         old_delegation = rcu_dereference_protected(nfsi->delegation,
>                                         lockdep_is_held(&clp->cl_lock));
>         if (old_delegation != NULL) {
> -               if (nfs4_stateid_match(&delegation->stateid,
> -                                       &old_delegation->stateid) &&
> -                               delegation->type == old_delegation->type) {
> +               /* Is this an update of the existing delegation? */
> +               if (nfs4_stateid_match_other(&old_delegation->stateid,
> +                                       &delegation->stateid)) {
> +                       nfs_update_inplace_delegation(old_delegation,
> +                                       delegation);
>                         goto out;
>                 }
>                 /*
> --
> 2.1.0
>



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
