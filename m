Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34922 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751494AbaFDWFc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2014 18:05:32 -0400
Date: Wed, 4 Jun 2014 18:05:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Live lock in silly-rename.
Message-ID: <20140604220531.GA8362@fieldses.org>
References: <20140529164521.02324559@notabene.brown>
 <CAHQdGtTtU9_zBcfzRb_wmEf7XaX9rNg-_Q85ZLX9BYax14D2Gg@mail.gmail.com>
 <20140530075135.753fb7ed@notabene.brown>
 <20140530004423.GA13746@fieldses.org>
 <20140530134442.5a8e5983@notabene.brown>
 <20140530215522.GA27615@fieldses.org>
 <20140531081358.62ae69b3@notabene.brown>
 <20140604173926.53918af3@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140604173926.53918af3@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 04, 2014 at 05:39:26PM +1000, NeilBrown wrote:
> Below is my suggestion.  It seems easy enough.  It even works.

Woah!

Anyway, looks reasonable to me, and it fixes an immediate problem so I'm
inclined to just apply.

The vfs knows about delegations at this point, and there's been this
vague idea we might give user space servers request them at some point,
so we might eventually want this code to fs/locks.c instead of here.

Wonder if filehandle is the right thing to hash on, as opposed to inode
number, or inode pointer, or something else?

--b.

> The approach taken here is to use a bloom filter to record the filehandles
> which are currently blocked from delegation, and to accept the cost of a few
> false positives.
> 
> We have 2 bloom filters, each of which is valid for 30 seconds.   When a
> delegation is recalled the filehandle is added to one filter and will remain
> disabled for between 30 and 60 seconds.
> 
> We keep a count of the number of filehandles that have been added, so when
> that count is zero we can bypass all other tests.
> 
> The bloom filters have 256 bits and 3 hash functions.  This should allow a
> couple of dozen blocked  filehandles with minimal false positives.  If many
> more filehandles are all blocked at once, behaviour will degrade towards
> rejecting all delegations for between 30 and 60 seconds, then resetting and
> allowing new delegations.
> 
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 9a77a5a21557..45101b41fb04 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -41,6 +41,7 @@
>  #include <linux/ratelimit.h>
>  #include <linux/sunrpc/svcauth_gss.h>
>  #include <linux/sunrpc/addr.h>
> +#include <linux/hash.h>
>  #include "xdr4.h"
>  #include "xdr4cb.h"
>  #include "vfs.h"
> @@ -364,6 +365,79 @@ static struct nfs4_ol_stateid * nfs4_alloc_stateid(struct nfs4_client *clp)
>  	return openlockstateid(nfs4_alloc_stid(clp, stateid_slab));
>  }
>  
> +/*
> + * When we recall a delegation, we should be careful not to hand it
> + * out again straight away.
> + * To ensure this we keep a pair of bloom filters ('new' and 'old')
> + * in which the filehandles of recalled delegations are "stored".
> + * If a filehandle appear in either filter, a delegation is blocked.
> + * When a delegation is recalled, the filehandle is stored in the "new"
> + * filter.
> + * Every 30 seconds we swap the filters and clear the "new" one,
> + * unless both are empty of course.
> + *
> + * Each filter is 256 bits.  We hash the filehandle to 32bit and use the
> + * low 3 bytes as hash-table indices.
> + *
> + * 'recall_lock', which is always held when block_delegations() is called,
> + * is used to manage concurrent access.  Testing does not need the lock
> + * except when swapping the two filters.
> + */
> +static struct bloom_pair {
> +	int	entries, old_entries;
> +	time_t	swap_time;
> +	int	new; /* index into 'set' */
> +	DECLARE_BITMAP(set[2], 256);
> +} blocked_delegations;
> +
> +static int delegation_blocked(struct knfsd_fh *fh)
> +{
> +	u32 hash;
> +	struct bloom_pair *bd = &blocked_delegations;
> +
> +	if (bd->entries == 0)
> +		return 0;
> +	if (seconds_since_boot() - bd->swap_time > 30) {
> +		spin_lock(&recall_lock);
> +		if (seconds_since_boot() - bd->swap_time > 30) {
> +			bd->entries -= bd->old_entries;
> +			bd->old_entries = bd->entries;
> +			memset(bd->set[bd->new], 0,
> +			       sizeof(bd->set[0]));
> +			bd->new = 1-bd->new;
> +			bd->swap_time = seconds_since_boot();
> +		}
> +		spin_unlock(&recall_lock);
> +	}
> +	hash = arch_fast_hash(&fh->fh_base, fh->fh_size, 0);
> +	if (test_bit(hash&255, bd->set[0]) &&
> +	    test_bit((hash>>8)&255, bd->set[0]) &&
> +	    test_bit((hash>>16)&255, bd->set[0]))
> +		return 1;
> +
> +	if (test_bit(hash&255, bd->set[1]) &&
> +	    test_bit((hash>>8)&255, bd->set[1]) &&
> +	    test_bit((hash>>16)&255, bd->set[1]))
> +		return 1;
> +
> +	return 0;
> +}
> +
> +static void block_delegations(struct knfsd_fh *fh)
> +{
> +	u32 hash;
> +	struct bloom_pair *bd = &blocked_delegations;
> +
> +	hash = arch_fast_hash(&fh->fh_base, fh->fh_size, 0);
> +
> +	__set_bit(hash&255, bd->set[bd->new]);
> +	__set_bit((hash>>8)&255, bd->set[bd->new]);
> +	__set_bit((hash>>16)&255, bd->set[bd->new]);
> +	if (bd->entries == 0)
> +		bd->swap_time = seconds_since_boot();
> +	bd->entries += 1;
> +}
> +
>  static struct nfs4_delegation *
>  alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct svc_fh *current_fh)
>  {
> @@ -372,6 +446,8 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
>  	dprintk("NFSD alloc_init_deleg\n");
>  	if (num_delegations > max_delegations)
>  		return NULL;
> +	if (delegation_blocked(&current_fh->fh_handle))
> +		return NULL;
>  	dp = delegstateid(nfs4_alloc_stid(clp, deleg_slab));
>  	if (dp == NULL)
>  		return dp;
> @@ -2742,6 +2818,8 @@ static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
>  	/* Only place dl_time is set; protected by i_lock: */
>  	dp->dl_time = get_seconds();
>  
> +	block_delegations(&dp->dl_fh);
> +
>  	nfsd4_cb_recall(dp);
>  }
>  


