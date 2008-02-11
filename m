From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: new NFS/RDMA instructions for 2.6.25-rc1
Date: Mon, 11 Feb 2008 16:00:44 -0500
Message-ID: <20080211210044.GA4561@fieldses.org>
References: <Pine.LNX.4.64.0802111223040.23589@jlentini-linux.nane.netapp.com> <20080211173322.GA4755@fieldses.org> <Pine.LNX.4.64.0802111552080.23589@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Talpey <talpey@netapp.com>,
	Tom Tucker <tom@opengridcomputing.com>,
	general-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org, linux-nfs@vger.kernel.org
To: James Lentini <jlentini@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56477 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753182AbYBKVAw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Feb 2008 16:00:52 -0500
In-Reply-To: <Pine.LNX.4.64.0802111552080.23589-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 11, 2008 at 03:56:17PM -0500, James Lentini wrote:
> 
> 
> On Mon, 11 Feb 2008, J. Bruce Fields wrote:
> 
> > On Mon, Feb 11, 2008 at 12:25:14PM -0500, James Lentini wrote:
> > > 
> > > Linux 2.6.25 will be the first official kernel release to contain the
> > > NFS/RDMA server. With the client and server now both available in 
> > > 2.6.25-rc1, we've simplified our NFS/RDMA installation instructions.
> > > The new instructions are available here:
> > >  
> > >  http://nfs-rdma.sourceforge.net/Documents/README
> > 
> > Any reason not to add that to the linux tree, say in
> > Documentation/filesystems/nfs-rdma.txt?
> > 
> > --b.
> 
> That sounds like a good idea Bruce. The current document is strictly a 
> HOWTO. Should we add sections on the design and implementation?

Sure, that'd be great.  But I think it'd be fine to submit the howto
pretty much as it is and add the rest later.

--b.
