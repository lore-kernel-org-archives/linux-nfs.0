From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Another possible race in put_rpccred / rpcauth_unhash_cred
Date: Thu, 19 Nov 2009 10:33:38 -0500
Message-ID: <1258644818.30333.13.camel@localhost>
References: <19203.18009.945354.446817@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:52562 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756856AbZKSPdf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Nov 2009 10:33:35 -0500
In-Reply-To: <19203.18009.945354.446817-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-11-18 at 11:56 +1100, Neil Brown wrote: 
> Hi again Trond,
> 
>  I've been looking at a customer report of an oops in
>  rpcauth_lookup_credcache.
>    https://bugzilla.novell.com/show_bug.cgi?id=547137
>  
>  It appears that one of the hash chains in the cache has become
>  corrupted.
> 
>  In trying to guess how this might happen, the one possibility I have
>  found is that it might be possible for hlist_del_rcu to be called on
>  an rpc_cred that is not hashed.  This certainly could cause list
>  corruption.
> 
>  put_rpccred checks if the cred is hashed (RPCAUTH_CRED_HASHED) and if
>  not, it takes a lock and then - if the cred it not uptodate -
>  calls rpcauth_unhash_cred which will call hlist_del_rcu.
>  If some other thread unhashed the cred while this thread was waiting
>  for rpc_credcache_lock, we could get list corruption.
> 
>  The kernel in question did not have commit 5f707eb429 which claims to
>  fix a race in much the same place, however I don't think that patch
>  would fix this problem.
>  
>  I think the simplest fix would be to use hlist_del_init_rcu in place
>  of hlist_del_rcu as shown below.  That version protects again
>  deleting the same element multiple times.
> 
>  Do you agree with this fix?
> 
> Thanks,
> NeilBrown
> 
> 
> 
> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> index 54a4e04..323eff6 100644
> --- a/net/sunrpc/auth.c
> +++ b/net/sunrpc/auth.c
> @@ -118,7 +118,7 @@ static DEFINE_SPINLOCK(rpc_credcache_lock);
>  static void
>  rpcauth_unhash_cred_locked(struct rpc_cred *cred)
>  {
> -	hlist_del_rcu(&cred->cr_hash);
> +	hlist_del_init_rcu(&cred->cr_hash);
>  	smp_mb__before_clear_bit();
>  	clear_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags);
>  }

Hmm... Why not simply convert that 'clear_bit()' into a
'test_and_clear_bit()' and have it protect the hlist_del_rcu?

I can't see anything that would break if we do this. There doesn't seem
to be anything that explicitly depends on the ordering of those two
operations...

Cheers
  Trond

