From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: RPC retransmission of write requests containing bogus data
Date: Tue, 11 Nov 2008 13:08:28 +0000
Message-ID: <1226408908.9339.56.camel@zakaz.uk.xensource.com>
References: <1224241273.9053.109.camel@zakaz.uk.xensource.com>
	 <1224247725.7722.4.camel@localhost>
	 <1224248469.9053.119.camel@zakaz.uk.xensource.com>
	 <1224249772.7722.9.camel@localhost>
	 <1224512708.15736.12.camel@zakaz.uk.xensource.com>
	 <1224520738.15736.22.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:27661 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753720AbYKKNId (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Nov 2008 08:08:33 -0500
In-Reply-To: <1224520738.15736.22.camel-o4Be2W7LfRlXesXXhkcM7miJhflN2719@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I cannot find my more recent post in my sent box (although I see it on
gmane.org) so apologies for replying to an older mail instead.

I eventually worked around this issue by not doing retransmissions since
the RPC_CLNT_CREATE_DISCRTRY backport to 2.6.18 was non-trivial. We
handle I/O errors at a higher level in our toolstack anyway so this is
not an issue for us.

Ian.

On Mon, 2008-10-20 at 17:39 +0100, Ian Campbell wrote:
> On Mon, 2008-10-20 at 15:25 +0100, Ian Campbell wrote:
> > On Fri, 2008-10-17 at 09:22 -0400, Trond Myklebust wrote:
> > > On Fri, 2008-10-17 at 14:01 +0100, Ian Campbell wrote:
> > > > On Fri, 2008-10-17 at 08:48 -0400, Trond Myklebust wrote:
> > > > > I don't see how this could be an RPC bug. The networking layer is
> > > > > supposed to either copy the data sent to the socket, or take a reference
> > > > > to any pages that are pushed via the ->sendpage() abi.
> > > > > 
> > > > > IOW: the pages are supposed to be still referenced by the networking
> > > > > layer even if the NFS layer and page cache have dropped their
> > > > > references.
> > > > 
> > > > The pages are still referenced by the networking layer. The problem is
> > > > that the userspace app has been told that the write has completed so it
> > > > is free to write new data to those pages.
> > > > 
> > > > Ian.
> > > 
> > > OK, I see your point.
> > > 
> > > Does this happen at all with NFSv4? I ask because the NFSv4 client will
> > > always ensure that the TCP connection gets broken before a
> > > retransmission. I wouldn't therefore expect any races between a reply to
> > > the previous transmission and the new one...
> > 
> > It does seem to happen with NFSv4 too (see attached).
> 
> Actually, that was NFSv4 on 2.6.18, I guess I should test with something
> newer since it looks like the TCP connection reset stuff is newer (it's
> 43d78ef2ba5bec26d0315859e8324bfc0be23766 right?)
> 

