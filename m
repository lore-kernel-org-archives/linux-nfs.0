Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e32.co.us.ibm.com ([32.97.110.150]:57833 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882Ab2GEPNB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jul 2012 11:13:01 -0400
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Thu, 5 Jul 2012 09:12:51 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 6036719D8088
	for <linux-nfs@vger.kernel.org>; Thu,  5 Jul 2012 15:06:03 +0000 (WET)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q65F5R3M133036
	for <linux-nfs@vger.kernel.org>; Thu, 5 Jul 2012 09:05:48 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q65F5ARl001686
	for <linux-nfs@vger.kernel.org>; Thu, 5 Jul 2012 09:05:12 -0600
Date: Thu, 5 Jul 2012 10:05:09 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andi Kleen <ak@linux.intel.com>, Linux-NFS <linux-nfs@vger.kernel.org>,
        Trond.Myklebust@netapp.com
Subject: Re: rpcauth_lookup_credcache() lock contentions
Message-ID: <20120705150509.GA12981@us.ibm.com>
References: <20120623122604.GA10887@localhost>
 <20120624213417.GI4152@tassilo.jf.intel.com>
 <20120625024211.GA11057@localhost>
 <20120627180353.GO4152@tassilo.jf.intel.com>
 <20120705131105.GA13775@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120705131105.GA13775@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fengguang Wu [fengguang.wu@intel.com] wrote:
> > diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> > index 727e506..645769e 100644
> > --- a/net/sunrpc/auth.c
> > +++ b/net/sunrpc/auth.c
> > @@ -364,13 +364,24 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
> >  	hlist_for_each_entry_rcu(entry, pos, &cache->hashtable[nr], cr_hash) {
> >  		if (!entry->cr_ops->crmatch(acred, entry, flags))
> >  			continue;
> > -		spin_lock(&cache->lock);
> >  		if (test_bit(RPCAUTH_CRED_HASHED, &entry->cr_flags) == 0) {
> > -			spin_unlock(&cache->lock);
> >  			continue;
> >  		}
> > -		cred = get_rpccred(entry);
> > -		spin_unlock(&cache->lock);
> > +		cred = entry;

I know very little about this code, so take this with grain of salt!
The cred symbol is set above but there is no guaranty that you will use
it.  If you don't win, you should set it to NULL.

> > +		if (atomic_add_return(1, &cred->cr_count) == 1) {
> > +			/*
> > +			 * When the count was 0 we could race with the GC.
> > +			 * Take the lock and recheck.
> > +			 */
> > +			spin_lock(&cache->lock);
> > +			if (!test_bit(RPCAUTH_CRED_HASHED, &entry->cr_flags)) {
> > +				/* Lost the race. */
> > +				atomic_dec(&cred->cr_count);
> > +				spin_unlock(&cache->lock);
> > +				continue;

If you execute the above "continue" statement, you will have stale "cred"
where the original code may end up with NULL cred. I don't know if that
can happen really though.

> > +			}
> > +			spin_unlock(&cache->lock);
> > +		}
> >  		break;

Setting cred to entry just before the above break and using entry in the
above code should be fine, I believe.

> >  	}
> >  	rcu_read_unlock();
> > -- 
> > 1.7.7
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

