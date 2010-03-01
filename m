From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: The recent kref_put warning (was: [PATCH] sunrpc: remove
	unnecessary svc_xprt_put)
Date: Mon, 1 Mar 2010 18:19:56 -0500
Message-ID: <20100301231956.GN23539@fieldses.org>
References: <20100226225416.GF26598@fieldses.org> <4B886A1A.7060106@opengridcomputing.com> <20100227123537.6289e326@notabene.brown> <20100227165913.53718449@notabene.brown> <20100228210553.GA27965@fieldses.org> <20100228220723.GB27965@fieldses.org> <20100301105734.7fe935b0@notabene.brown> <20100301034647.GA8462@fieldses.org> <20100301165114.74d2797b@notabene.brown> <20100301145015.GE17660@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>, linux-nfs@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37878 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752628Ab0CAXSt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Mar 2010 18:18:49 -0500
In-Reply-To: <20100301145015.GE17660@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 01, 2010 at 09:50:15AM -0500, J. Bruce Fields wrote:
> On Mon, Mar 01, 2010 at 04:51:14PM +1100, Neil Brown wrote:
> > On Sun, 28 Feb 2010 22:46:47 -0500
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Mon, Mar 01, 2010 at 10:57:34AM +1100, Neil Brown wrote:
> > > > No, you are correct.  "return 0" is wrong, it should be "return -EAGAIN",
> > > > both in the XPT_CLOSE case and the XPT_LISTENER case.
> > > > 
> > > > I observed that in both those cases, 'len' remained at 0 and we didn't do
> > > > much else but 'return len', so I optimised.
> > > > I forgot to factor in:
> > > > 
> > > > 	if (len == 0 || len == -EAGAIN) {
> > > > 		rqstp->rq_res.len = 0;
> > > > 		svc_xprt_release(rqstp);
> > > > 		return -EAGAIN;
> > > > 	}
> > > > 
> > > > So the svc_xprt_release needs to be moved in there as well, I'm not sure
> > > > about the rq_res.len = 0.
> > > > Maybe that was a bad case of premature-optimisation :-)
> > > > 
> > > > We should probably leave that last else clause as it is and just have a
> > > > single return from the function.
> > > 
> > > OK, so the below is what I'm thinking of sending, after some testing;
> > > really just a split-up version of your patches (uh, so credits may be
> > > wrong) with the final cleanup removed:
> > 
> > Credits and code look OK the me, thanks.

And, by the way, this is all ready to submit--but I'd like to avoid
having to revert anything more, and as part of that I'd greatly
appreciate any testing results, however partial.

--b.
