Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:37142 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811AbaFMVTD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jun 2014 17:19:03 -0400
Received: by mail-qc0-f175.google.com with SMTP id i8so4784313qcq.20
        for <linux-nfs@vger.kernel.org>; Fri, 13 Jun 2014 14:19:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1402683488-23725-2-git-send-email-smayhew@redhat.com>
References: <1402683488-23725-1-git-send-email-smayhew@redhat.com>
	<1402683488-23725-2-git-send-email-smayhew@redhat.com>
Date: Fri, 13 Jun 2014 17:19:01 -0400
Message-ID: <CAABAsM5kJFJK_-VwL4bB4ZUvpdx4pFEYqXKN1S7KqdF6=Xc76g@mail.gmail.com>
Subject: Re: [PATCH RFC] nfs: ensure cached data is correct before using delegation
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 13, 2014 at 2:18 PM, Scott Mayhew <smayhew@redhat.com> wrote:
> nfs_write_pageuptodate()  bypasses the cache_validity flags whenever we
> have a delegation... but in order to do that we need to be sure our
> cached data is correct to begin with.
> ---
>  fs/nfs/delegation.c | 1 +
>  fs/nfs/inode.c      | 1 +
>  fs/nfs/nfs4proc.c   | 5 +++--
>  3 files changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index 5d8ccec..12f3eca 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -167,6 +167,7 @@ void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred,
>                         spin_unlock(&delegation->lock);
>                         rcu_read_unlock();
>                         nfs_inode_set_delegation(inode, cred, res);
> +                       nfs_revalidate_mapping(inode, inode->i_mapping);

If you are reclaiming a delegation after a server reboot, then nobody
is supposed to have changed the file.

>                 }
>         } else {
>                 rcu_read_unlock();
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index c496f8a..95a9d21 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1090,6 +1090,7 @@ int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
>  out:
>         return ret;
>  }
> +EXPORT_SYMBOL_GPL(nfs_revalidate_mapping);
>
>  static unsigned long nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>  {
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 285ad53..a538aac 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1361,11 +1361,12 @@ nfs4_opendata_check_deleg(struct nfs4_opendata *data, struct nfs4_state *state)
>                                    "returning a delegation for "
>                                    "OPEN(CLAIM_DELEGATE_CUR)\n",
>                                    clp->cl_hostname);
> -       } else if ((delegation_flags & 1UL<<NFS_DELEGATION_NEED_RECLAIM) == 0)
> +       } else if ((delegation_flags & 1UL<<NFS_DELEGATION_NEED_RECLAIM) == 0) {
>                 nfs_inode_set_delegation(state->inode,
>                                          data->owner->so_cred,
>                                          &data->o_res);
> -       else
> +               nfs_revalidate_mapping(state->inode, state->inode->i_mapping);
> +       } else
>                 nfs_inode_reclaim_delegation(state->inode,
>                                              data->owner->so_cred,
>                                              &data->o_res);

I'd really prefer to fix this in the part of the code that is actually broken.

I agree that we should ignore the NFS_INO_REVAL_PAGECACHE flag if we
have a delegation and the NFS_INO_REVAL_FORCED is unset. However is it
right to ignore NFS_INO_INVALID_DATA?

Cheers
  Trond
