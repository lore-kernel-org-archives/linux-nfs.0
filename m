Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36105 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751829Ab2HRLN6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 18 Aug 2012 07:13:58 -0400
Date: Sat, 18 Aug 2012 07:13:54 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Linux-kernel <linux-kernel@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.0+ NFS issues (bisected)
Message-ID: <20120818111354.GA16611@fieldses.org>
References: <20120817145616.GC11172@fieldses.org>
 <20120817160057.GE11172@fieldses.org>
 <502E7B86.3060702@msgid.tls.msk.ru>
 <20120817171854.GA14015@fieldses.org>
 <502E7EC3.5030006@msgid.tls.msk.ru>
 <502E7F84.3060003@msgid.tls.msk.ru>
 <20120817191800.GA14620@fieldses.org>
 <20120817200807.GB14620@fieldses.org>
 <20120817223253.GA15659@fieldses.org>
 <502F3AFB.4080401@msgid.tls.msk.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <502F3AFB.4080401@msgid.tls.msk.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 18, 2012 at 10:49:31AM +0400, Michael Tokarev wrote:
> On 18.08.2012 02:32, J. Bruce Fields wrote:
> > On Fri, Aug 17, 2012 at 04:08:07PM -0400, J. Bruce Fields wrote:
> >> Wait a minute, that assumption's a problem because that calculation
> >> depends in part on xpt_reserved, which is changed here....
> >>
> >> In particular, svc_xprt_release() calls svc_reserve(rqstp, 0), which
> >> subtracts rqstp->rq_reserved and then calls svc_xprt_enqueue, now with a
> >> lower xpt_reserved value.  That could well explain this.
> > 
> > So, maybe something like this?
> 
> Well.  What can I say?  With the change below applied (to 3.2 kernel
> at least), I don't see any stalls or high CPU usage on the server
> anymore.  It survived several multi-gigabyte transfers, for several
> hours, without any problem.  So it is a good step forward ;)
> 
> But the whole thing seems to be quite a bit fragile.  I tried to follow
> the logic in there, and the thing is quite a bit, well, "twisted", and
> somewhat difficult to follow.  So I don't know if this is the right
> fix or not.  At least it works! :)

Suggestions welcomed.

> And I really wonder why no one else reported this problem before.
> Is me the only one in this world who uses linux nfsd? :)

This, for example:

	http://marc.info/?l=linux-nfs&m=134131915612287&w=2

may well describe the same problem....  It just needed some debugging
persistence, thanks!

--b.
