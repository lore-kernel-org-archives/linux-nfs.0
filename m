Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f177.google.com ([209.85.128.177]:62869 "EHLO
	mail-ve0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754364AbaFTPbO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jun 2014 11:31:14 -0400
Received: by mail-ve0-f177.google.com with SMTP id i13so3683080veh.36
        for <linux-nfs@vger.kernel.org>; Fri, 20 Jun 2014 08:31:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1403268301-29719-1-git-send-email-smayhew@redhat.com>
References: <1403268301-29719-1-git-send-email-smayhew@redhat.com>
Date: Fri, 20 Jun 2014 11:31:14 -0400
Message-ID: <CAHQdGtREqDtZB-pX2ubYKxmLUdN6NfO44yRnaWhCt63OmAuXrw@mail.gmail.com>
Subject: Re: [PATCH] nfs: Fix handling of change_attr updates in nfs_update_inode()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Scott Mayhew <smayhew@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 20, 2014 at 8:45 AM, Scott Mayhew <smayhew@redhat.com> wrote:
> When we detect that the change attribute has changed on the server, it's
> only necessary to invalidate our caches if we're not holding a write
> delegation.  Otherwise, the change attribute is changing as the result
> of our modifications and we can just silently update our copy.
>
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  fs/nfs/inode.c | 20 +++++++++++---------
>  1 file changed, 11 insertions(+), 9 deletions(-)
>
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index c496f8a..186562d 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1563,15 +1563,17 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>         /* More cache consistency checks */
>         if (fattr->valid & NFS_ATTR_FATTR_CHANGE) {
>                 if (inode->i_version != fattr->change_attr) {
> -                       dprintk("NFS: change_attr change on server for file %s/%ld\n",
> -                                       inode->i_sb->s_id, inode->i_ino);
> -                       invalid |= NFS_INO_INVALID_ATTR
> -                               | NFS_INO_INVALID_DATA
> -                               | NFS_INO_INVALID_ACCESS
> -                               | NFS_INO_INVALID_ACL
> -                               | NFS_INO_REVAL_PAGECACHE;
> -                       if (S_ISDIR(inode->i_mode))
> -                               nfs_force_lookup_revalidate(inode);
> +                       if (!NFS_PROTO(inode)->have_delegation(inode, FMODE_WRITE)) {
> +                               dprintk("NFS: change_attr change on server for file %s/%ld\n",
> +                                               inode->i_sb->s_id, inode->i_ino);
> +                               invalid |= NFS_INO_INVALID_ATTR
> +                                       | NFS_INO_INVALID_DATA
> +                                       | NFS_INO_INVALID_ACCESS
> +                                       | NFS_INO_INVALID_ACL
> +                                       | NFS_INO_REVAL_PAGECACHE;
> +                               if (S_ISDIR(inode->i_mode))
> +                                       nfs_force_lookup_revalidate(inode);
> +                       }
>                         inode->i_version = fattr->change_attr;
>                 }
>         } else if (server->caps & NFS_CAP_CHANGE_ATTR)
> --
> 1.9.3
>

Hi Scott,

This circumvents the INO_REVAL_FORCED flag, which is set in those
situations where the changes to the file are not a priori known to be
covered by the delegation.

In either case, we already have the check for ->have_delegation()
before deciding whether or not to apply the 'invalid' flags to
nfsi->cache_validity at the end of the function.

Cheers
  Trond



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
