Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qk0-f194.google.com ([209.85.220.194]:56051 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752670AbdKIQPA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Nov 2017 11:15:00 -0500
Received: by mail-qk0-f194.google.com with SMTP id x195so8311207qkb.12
        for <linux-nfs@vger.kernel.org>; Thu, 09 Nov 2017 08:15:00 -0800 (PST)
Message-ID: <1510244098.30919.10.camel@redhat.com>
Subject: Re: [Bug 197817] "Panic: unable to handle kernel page request"  in
 posix_unblock_lock() called from nfs4_laundromat()
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Naofumi Honda <honda@math.sci.hokudai.ac.jp>
Cc: linux-nfs@vger.kernel.org
Date: Thu, 09 Nov 2017 11:14:58 -0500
In-Reply-To: <20171109160728.GI8773@fieldses.org>
References: <bug-197817-198953@https.bugzilla.kernel.org/>
         <bug-197817-198953-0whWrJRFSz@https.bugzilla.kernel.org/>
         <1911104.BiqBl0Bicc@nausicaa> <20171109160728.GI8773@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-11-09 at 11:07 -0500, J. Bruce Fields wrote:
> On Thu, Nov 09, 2017 at 10:08:28AM +0900, Naofumi Honda wrote:
> > Dear Developers:
> > 
> > > https://bugzilla.kernel.org/show_bug.cgi?id=197817
> > > 
> > > --- Comment #1 from bfields@fieldses.org ---
> > > Yes, I think you're right.
> > > 
> > > Would it be possible for you to submit a patch to fix that typo in those two
> > > places?  (Just mail it to me at bfields@fieldses.org, cc: to
> > > linux-nfs@vger.kernel.org).
> > > 
> > 
> > OK,  I have attached the patch.
> 
> Thanks for the investigation and the fix!
> 
> For future reference, we prefer patches to be inline with the email
> message (not attached), and prefer them in "unified" format.
> 
> But for a one-off patch I can fix it up myself; applied as follows.
> 
> --b.
> 
> commit c26806a20fa3
> Author: Naofumi Honda <honda@math.sci.hokudai.ac.jp>
> Date:   Thu Nov 9 10:57:16 2017 -0500
> 
>     nfsd: fix panic in posix_unblock_lock called from nfs4_laundromat
>     
>     From kernel 4.9, my two nfsv4 servers sometimes suffer from
>         "panic: unable to handle kernel page request"
>     in posix_unblock_lock() called from nfs4_laundromat().
>     
>     These panics diseappear if we revert the commit "nfsd: add a LRU list
>     for blocked locks".
>     
>     The cause appears to be a typo in nfs4_laundromat(), which is also
>     present in nfs4_state_shutdown_net().
>     
>     Cc: stable@vger.kernel.org
>     Fixes: 7919d0a27f1e "nfsd: add a LRU list for blocked locks"
>     Cc: jlayton@redhat.com
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 923243369bbc..b99830ab63aa 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4791,7 +4791,7 @@ nfs4_laundromat(struct nfsd_net *nn)
>  	spin_unlock(&nn->blocked_locks_lock);
>  
>  	while (!list_empty(&reaplist)) {
> -		nbl = list_first_entry(&nn->blocked_locks_lru,
> +		nbl = list_first_entry(&reaplist,
>  					struct nfsd4_blocked_lock, nbl_lru);
>  		list_del_init(&nbl->nbl_lru);
>  		posix_unblock_lock(&nbl->nbl_lock);
> @@ -7260,7 +7260,7 @@ nfs4_state_shutdown_net(struct net *net)
>  	spin_unlock(&nn->blocked_locks_lock);
>  
>  	while (!list_empty(&reaplist)) {
> -		nbl = list_first_entry(&nn->blocked_locks_lru,
> +		nbl = list_first_entry(&reaplist,
>  					struct nfsd4_blocked_lock, nbl_lru);
>  		list_del_init(&nbl->nbl_lru);
>  		posix_unblock_lock(&nbl->nbl_lock);

<facepalm>

Well spotted! I wonder if this might be the cause of some crashes we've
seen as well?

Reviewed-by: Jeff Layton <jlayton@redhat.com>
