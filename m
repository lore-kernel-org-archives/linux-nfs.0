From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Fri, 26 Sep 2008 23:54:15 -0400
Message-ID: <20080927035415.GC12765@fieldses.org>
References: <1221544139.2534.18.camel@localhost.localdomain> <48CF9AC3.6060801@opengridcomputing.com> <1221577412.28572.60.camel@zakaz.uk.xensource.com> <48CFD7C3.5080207@opengridcomputing.com> <1221582285.28572.67.camel@zakaz.uk.xensource.com> <1222156770.6869.13.camel@localhost.localdomain> <1222169589.6869.20.camel@localhost.localdomain> <20080923170344.GC2700@fieldses.org> <1222443426.3949.18.camel@localhost.localdomain> <1222453053.3949.21.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Grant Coady <gcoady.lk@gmail.com>,
	linux-kernel@vger.kernel.org, neilb@suse.de,
	linux-nfs@vger.kernel.org
To: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45864 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751138AbYI0Dy3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 23:54:29 -0400
In-Reply-To: <1222453053.3949.21.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 26, 2008 at 07:17:33PM +0100, Ian Campbell wrote:
> On Fri, 2008-09-26 at 16:37 +0100, Ian Campbell wrote:
> > It's possible, the good case is naturally quite hard to establish with
> > 100% certainty. I declared v2.6.26 OK after an uptime of 4 days and 19
> > hours, compared with failure normally within 1-2 days. It's possible I
> > was premature in doing so. I'll run 2e96d2867 for at least a full week
> > before reporting back.
> 
> Or it'll reproduce after just a few hours :-/
> 
> Looks like a false negative on v2.6.26 -- I'll retest from there.

OK, so apologies, but this has been a long thread, and maybe we could
use a summary of the symptoms and the results so far.  I think you said
2.6.24 or .25 was the last you're *positive* was good?

--b.
