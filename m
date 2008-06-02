From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/3] [RFC] knfsd: convert to kthread API and	remove
 signaling for shutdown
Date: Mon, 2 Jun 2008 06:41:32 -0400
Message-ID: <20080602064132.10c69c88@tleilax.poochiereds.net>
References: <1211078114-18384-1-git-send-email-jlayton@redhat.com>
	<18481.6416.571430.593722@notabene.brown>
	<4831F860.6050801@melbourne.sgi.com>
	<4833364A.4010803@melbourne.sgi.com>
	<20080520214823.576ad7a7@tleilax.poochiereds.net>
	<48339730.3060206@melbourne.sgi.com>
	<20080530122517.4f18c48e@tleilax.poochiereds.net>
	<48438A76.6000400@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40161 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751892AbYFBKlh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Jun 2008 06:41:37 -0400
In-Reply-To: <48438A76.6000400-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 02 Jun 2008 00:51:50 -0500
Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org> wrote:

> Jeff Layton wrote:
> >
> > I started to do this patch as part of the kthread conversion, but it's
> > actually pretty independent. We can probably treat it separately.
> > This hasn't been tested on an actual NUMA machine yet, but any thoughts
> > on the following patch?
> > [...]
> >  
> > -	rqstp = kzalloc(sizeof(*rqstp), GFP_KERNEL);
> > +	rqstp = kmalloc_node(sizeof(*rqstp), GFP_KERNEL | __GFP_ZERO, node);
> >  	if (!rqstp)
> >  		goto out_enomem;
> >   
> I'm not an expert, but from looking at the slab code I don't think
> __GFP_ZERO works the way you're expecting on the kmalloc() family, only
> on the alloc_pages() family.  In particular it's not used when the
> object is allocated on the slab fastpath. kzalloc() seems to be a
> kmalloc() followed by a memset().  Perhaps you'd be better off either
> adding a kzalloc_node() or doing kmalloc_node() plus memset().
> 

I'm certainly no VM expert either, but where are you seeing the
kmalloc + memset? The only definition I see is the inlined function
in slab.h which is:

static inline void *kzalloc(size_t size, gfp_t flags)
{
        return kmalloc(size, flags | __GFP_ZERO);
}

Still though, you're probably right. A kzalloc_node() might be handy for
other uses. I'll consider it once I unravel what kzalloc actually
does...

-- 
Jeff Layton <jlayton@redhat.com>
