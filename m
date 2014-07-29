Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:39134 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbaG2T55 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 15:57:57 -0400
Date: Tue, 29 Jul 2014 21:57:54 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Bruce Fields <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org,
        linux-arch@vger.kernel.org
Subject: Re: [PATCH 1/3] SUNRPC: Reduce contention in svc_xprt_enqueue()
Message-ID: <20140729195754.GQ3935@laptop>
References: <1406260773-16231-1-git-send-email-trond.myklebust@primarydata.com>
 <20140729193108.GC21091@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140729193108.GC21091@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 29, 2014 at 03:31:08PM -0400, Bruce Fields wrote:
> All three patches look good to me, thanks.
> 
> From private email, this:
> 
> On Thu, Jul 24, 2014 at 11:59:31PM -0400, Trond Myklebust wrote:
> > @@ -222,11 +223,12 @@ static void svc_xprt_received(struct svc_xprt *xprt)
> >  	if (!test_bit(XPT_BUSY, &xprt->xpt_flags))
> >  		return;
> >  	/* As soon as we clear busy, the xprt could be closed and
> > -	 * 'put', so we need a reference to call svc_xprt_enqueue with:
> > +	 * 'put', so we need a reference to call svc_xprt_do_enqueue with:
> >  	 */
> >  	svc_xprt_get(xprt);
> > +	smp_mb__before_clear_bit();
> 
> triggered a warning about smp_mb__before_clear_bit noticed by the kbuild
> robot.  Looks like that was due to
> febdbfe8a91ce0d11939d4940b592eb0dba8d663 "arch: Prepare for
> smp_mb__{before,after}_atomic()".
> 
> You questioned whether deprecating smp_mb__{before,after}_clear_bit was
> an unnecessary burden on people maintaining stable kernels or doing
> backports more generally.  Cc'ing some addresses from that commit.

I absolutely do not care one whit for that. The kernel lives, deal with
it.

Memory barriers are hard enough, we do not need multiple versions of the
same thing just to confuse people.

> Whatever--I'll probably just replace do the clear_bit->before_atomic
> replacement and apply unless there's some objection.

The old API was preserved to allow for non-flag-day migration to the new
API. I should do a final sweep and then kill the old API.

The conversion shrank the memory barrier API by 4 variants while
covering more cases, which is an absolute win in my book.
