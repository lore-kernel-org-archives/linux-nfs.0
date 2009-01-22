From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
	than 120 seconds"
Date: Thu, 22 Jan 2009 11:44:09 -0500
Message-ID: <20090122164409.GB13129@fieldses.org>
References: <1228169383.20370.3.camel@localhost.localdomain> <1228565812.10856.30.camel@localhost.localdomain> <1229279045.3721.1.camel@localhost.localdomain> <20081216175503.GG16388@fieldses.org> <1229452775.3721.25.camel@localhost.localdomain> <20090107222115.GI965@fieldses.org> <20090108182003.GB17623@fieldses.org> <1231449753.21688.12.camel@localhost.localdomain> <20090108212605.GG19312@fieldses.org> <1232612860.29604.57.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>,
	linux-kernel@vger.kernel.org, gcosta@redhat.com,
	Grant Coady <grant_lkml-rGYn+TmxqGy6c6uEtOJ/EA@public.gmane.org>,
	Tom Tucker <tom@opengridcomputing.com>
To: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:56754 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754662AbZAVQoQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2009 11:44:16 -0500
In-Reply-To: <1232612860.29604.57.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 22, 2009 at 08:27:40AM +0000, Ian Campbell wrote:
> On Thu, 2009-01-08 at 16:26 -0500, J. Bruce Fields wrote:
> > 
> > > > (Merged now, so testing mainline as of today should work too.)
> > > 
> > > The server isn't really a machine I want to test random kernels on,
> > is
> > > there some subset of those changesets which it would be useful for
> > me to
> > > pull back onto the 2.6.26 kernel I'm using to test? (I can most like
> > > manage the backporting myself).
> > > 
> > > These two look like the relevant ones to me but I'm not sure:
> > > 22945e4a1c7454c97f5d8aee1ef526c83fef3223 svc: Clean up deferred
> > requests on transport destruction
> > > 69b6ba3712b796a66595cfaf0a5ab4dfe1cf964a SUNRPC: Ensure the server
> > closes sockets in a timely fashion
> > > 
> > > I think 69b6 was in the set of three I tested previously and the
> > other
> > > two turned into 2294?
> > 
> > Yep, exactly.--b.
> 
> The client machine now has an uptime of ten days without error after
> these two patches were applied to the server.
> 
> Thanks everybody,

Very good, so upstream should be OK.  Thanks for the testing!

--b.
