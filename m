Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:23474 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759214Ab0HENEI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Aug 2010 09:04:08 -0400
Subject: Re: [PATCH 2/2] We should clear NFS_DELEGATED_STATE after return
 delegation
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Bian Naimeng <biannm@cn.fujitsu.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <4C5A213F.9000506@cn.fujitsu.com>
References: <4C592F85.8070308@cn.fujitsu.com>
	 <4C59306A.9090302@cn.fujitsu.com>
	 <1280925913.3011.23.camel@heimdal.trondhjem.org>
	 <4C5A213F.9000506@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 05 Aug 2010 09:03:43 -0400
Message-ID: <1281013423.2948.1.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-08-05 at 10:26 +0800, Bian Naimeng wrote:
> > On Wed, 2010-08-04 at 17:18 +0800, Bian Naimeng wrote:
> >> We should clear NFS_DELEGATED_STATE bit for inode->open_states after return delegation.
> >>
> >> Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
> >>
> >> ---
> >>  fs/nfs/nfs4proc.c |   15 ++++++++++++++-
> >>  1 files changed, 14 insertions(+), 1 deletions(-)
> >>
> >> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> >> index 70015dd..76cdef4 100644
> >> --- a/fs/nfs/nfs4proc.c
> >> +++ b/fs/nfs/nfs4proc.c
> 
>   ... snip ...
> 
> >>  
> >>  static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
> > 
> > It is way too late to clear the NFS_DELEGATED_STATE flag _after_ we've
> > returned the delegation. We should be doing it as part of
> > nfs_delegation_claim_opens().
> > 
> > Why isn't the following patch sufficient?
> > 
> > Cheers
> >   Trond
> > 
> > ----------------------------------------------------------------------------------
> > NFSv4: Remember to clear NFS_DELEGATED_STATE in nfs_delegation_claim_opens
> > 
> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > 
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> > 
> >  fs/nfs/delegation.c |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > 
> > diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> > index 3016345..56d5d1a 100644
> > --- a/fs/nfs/delegation.c
> > +++ b/fs/nfs/delegation.c
> > @@ -102,10 +102,10 @@ again:
> >  		state = ctx->state;
> >  		if (state == NULL)
> >  			continue;
> > -		if (!test_bit(NFS_DELEGATED_STATE, &state->flags))
> > -			continue;
> >  		if (memcmp(state->stateid.data, stateid->data, sizeof(state->stateid.data)) != 0)
> >  			continue;
> > +		if (!test_and_clear_bit(NFS_DELEGATED_STATE, &state->flags))
> > +			continue;
> >  		get_nfs_open_context(ctx);
> >  		spin_unlock(&inode->i_lock);
> >  		err = nfs4_open_delegation_recall(ctx, state, stateid);
> > 
> 
>  Thanks Trond.
>  But why we must remove test_and_clear_bit behind memcmp?
> 
>  Always test_bit and memcmp have same result, and I think test_and_clear_bit is fast 
>  than memcmp, so i suggest we should call test_and_clear_bit first. right?

We can't clear the bit before the memcmp() test. What we could do is
keep the current test_bit() and then do a clear_bit after the memcmp().

Cheers
  Trond
