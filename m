From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: RPC retransmission of write requests containing bogus data
Date: Fri, 17 Oct 2008 09:22:52 -0400
Message-ID: <1224249772.7722.9.camel@localhost>
References: <1224241273.9053.109.camel@zakaz.uk.xensource.com>
	 <1224247725.7722.4.camel@localhost>
	 <1224248469.9053.119.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6518 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753898AbYJQNXT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2008 09:23:19 -0400
In-Reply-To: <1224248469.9053.119.camel-o4Be2W7LfRlXesXXhkcM7miJhflN2719@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-10-17 at 14:01 +0100, Ian Campbell wrote:
> On Fri, 2008-10-17 at 08:48 -0400, Trond Myklebust wrote:
> > I don't see how this could be an RPC bug. The networking layer is
> > supposed to either copy the data sent to the socket, or take a reference
> > to any pages that are pushed via the ->sendpage() abi.
> > 
> > IOW: the pages are supposed to be still referenced by the networking
> > layer even if the NFS layer and page cache have dropped their
> > references.
> 
> The pages are still referenced by the networking layer. The problem is
> that the userspace app has been told that the write has completed so it
> is free to write new data to those pages.
> 
> Ian.

OK, I see your point.

Does this happen at all with NFSv4? I ask because the NFSv4 client will
always ensure that the TCP connection gets broken before a
retransmission. I wouldn't therefore expect any races between a reply to
the previous transmission and the new one...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
