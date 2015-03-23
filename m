Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:36023 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752788AbbCWPpU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Mar 2015 11:45:20 -0400
Received: by ykcn8 with SMTP id n8so74033815ykc.3
        for <linux-nfs@vger.kernel.org>; Mon, 23 Mar 2015 08:45:17 -0700 (PDT)
Date: Mon, 23 Mar 2015 11:45:14 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: trond.myklebust@primarydata.com, hch@infradead.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] nfsd: return correct openowner when there is a race
 to put one in the hash
Message-ID: <20150323114514.4330985a@tlielax.poochiereds.net>
In-Reply-To: <20150323153614.GB15183@fieldses.org>
References: <1427122424-8078-1-git-send-email-jeff.layton@primarydata.com>
	<1427122424-8078-2-git-send-email-jeff.layton@primarydata.com>
	<20150323153614.GB15183@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 23 Mar 2015 11:36:14 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Mar 23, 2015 at 10:53:42AM -0400, Jeff Layton wrote:
> > alloc_init_open_stateowner can return an already freed entry if there is
> > a race to put openowners in the hashtable.
> 
> Looks like alloc_init_lock_stateowner has the same bug, so I'll apply
> something like this pending testing.
> 
> I wonder if it's actually possible to hit this one?
> 
> --b.
> 
> commit bdff3084f09f
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Mon Mar 23 11:02:30 2015 -0400
> 
>     nfsd: return correct lockowner when there is a race on hash insert
>     
>     alloc_init_lock_stateowner can return an already freed entry if there is
>     a race to put openowners in the hashtable.
>     
>     Noticed by inspection after Jeff Layton fixed the same bug for open
>     owners.  Depending on client behavior, this one may be trickier to
>     trigger in practice.
>     
>     Fixes: c58c6610ec24 "nfsd: Protect adding/removing lock owners using client_lock"
>     Cc: stable@vger.kernel.org>
>     Cc: Trond Myklebust <trond.myklebust@primarydata.com>
>     Cc: Jeff Layton <jeff.layton@primarydata.com>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index d2f2c37dc2db..49ae6116992f 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -5062,7 +5062,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp,
>  	} else
>  		nfs4_free_lockowner(&lo->lo_owner);
>  	spin_unlock(&clp->cl_lock);
> -	return lo;
> +	return ret;
>  }
>  
>  static void

Maybe. Commit b4019c0e219 allows us to do parallel LOCK/LOCKU calls for
the same owner, but it also says:

"Note, however, that we still serialise on the open stateid if the lock
stateid is unconfirmed."

...which I take to mean that the initial LOCK calls likely wouldn't race
this way. Still, it's probably possible to craft a pynfs test or
something that does that.

Either way, it's clearly a bug that should be fixed:

Acked-by: Jeff Layton <jeff.layton@primarydata.com>
