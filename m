Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:63529 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756564AbaHVOtK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Aug 2014 10:49:10 -0400
Received: by mail-vc0-f174.google.com with SMTP id la4so12223431vcb.5
        for <linux-nfs@vger.kernel.org>; Fri, 22 Aug 2014 07:49:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140822140759.GA31775@ada>
References: <20140822140759.GA31775@ada>
Date: Fri, 22 Aug 2014 10:49:09 -0400
Message-ID: <CAHQdGtQGWBkH23eTF-1=dGcz18QK8atHEom0vy9eWhPXPtCsfg@mail.gmail.com>
Subject: Re: [PATCH] nfs: delegation: Replace rcu_assign_pointer() with RCU_INIT_POINTER()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andreea-Cristina Bernat <bernat.ada@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 22, 2014 at 10:07 AM, Andreea-Cristina Bernat
<bernat.ada@gmail.com> wrote:
> The use of "rcu_assign_pointer()" is NULLing out the pointer.
> According to RCU_INIT_POINTER()'s block comment:
> "1.   This use of RCU_INIT_POINTER() is NULLing out the pointer"
> it is better to use it instead of rcu_assign_pointer() because it has a
> smaller overhead.
>
> The following Coccinelle semantic patch was used:
> @@
> @@
>
> - rcu_assign_pointer
> + RCU_INIT_POINTER
>   (..., NULL)
>
> Signed-off-by: Andreea-Cristina Bernat <bernat.ada@gmail.com>
> ---
>  fs/nfs/delegation.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index 5d8ccec..349e63b 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -249,7 +249,7 @@ nfs_detach_delegation_locked(struct nfs_inode *nfsi,
>         list_del_rcu(&delegation->super_list);
>         delegation->inode = NULL;
>         nfsi->delegation_state = 0;
> -       rcu_assign_pointer(nfsi->delegation, NULL);
> +       RCU_INIT_POINTER(nfsi->delegation, NULL);
>         spin_unlock(&delegation->lock);
>         return delegation;
>  }
> --
> 1.9.1

Sorry, but NACK.

We do need the memory barriers here, as the nfs_inode is globally
visible, and other threads may be checking nfsi->delegation_state
and/or delegation->inode in order to conclude whether or not there is
still a delegation associated with this inode.

Cheers
  Trond
-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
