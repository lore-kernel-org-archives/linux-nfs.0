From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/3] [RFC] knfsd: convert to kthread API and	remove
 signaling for shutdown
Date: Tue, 3 Jun 2008 06:51:00 -0400
Message-ID: <20080603065100.289e01b4@tupile.poochiereds.net>
References: <1211078114-18384-1-git-send-email-jlayton@redhat.com>
	<18481.6416.571430.593722@notabene.brown>
	<4831F860.6050801@melbourne.sgi.com>
	<4833364A.4010803@melbourne.sgi.com>
	<20080520214823.576ad7a7@tleilax.poochiereds.net>
	<48339730.3060206@melbourne.sgi.com>
	<20080530122517.4f18c48e@tleilax.poochiereds.net>
	<48438A76.6000400@melbourne.sgi.com>
	<20080602064132.10c69c88@tleilax.poochiereds.net>
	<4844BA3C.3010605@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52317 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752287AbYFCKvp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Jun 2008 06:51:45 -0400
In-Reply-To: <4844BA3C.3010605-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 03 Jun 2008 13:27:56 +1000
Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org> wrote:

> Jeff Layton wrote:
> > On Mon, 02 Jun 2008 00:51:50 -0500
> > Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org> wrote:
> >   
> >
> > I'm certainly no VM expert either, but where are you seeing the
> > kmalloc + memset? The only definition I see is the inlined function
> > in slab.h which is:
> >
> > static inline void *kzalloc(size_t size, gfp_t flags)
> >
> >   
> Sorry, I was looking in the wrong tree (sles10 not tot).  Nevermind :-)
> 

No worries... :-)

I went back and walked through the slab and slub code and it looks like
simply setting __GFP_ZERO on the allocation will do the right thing.
I'll plan to push the patchset today sometime.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
