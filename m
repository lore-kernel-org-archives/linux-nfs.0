Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35493 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754978Ab0DEQSA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Apr 2010 12:18:00 -0400
Date: Mon, 5 Apr 2010 12:20:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tom Tucker <tom@opengridcomputing.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Tom Tucker <tom@ogc.us>,
        Steve Wise <swise@opengridcomputing.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH] svcrdma: RDMA support not yet compatible with RPC6
Message-ID: <20100405162020.GJ16370@fieldses.org>
References: <4BB74241.4060308@ogc.us> <4BB9F9D0.1040203@oracle.com> <20100405154850.GG16370@fieldses.org> <4BBA06B8.3090201@opengridcomputing.com> <20100405161618.GI16370@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100405161618.GI16370@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Apr 05, 2010 at 12:16:18PM -0400, J. Bruce Fields wrote:
> On Mon, Apr 05, 2010 at 10:50:16AM -0500, Tom Tucker wrote:
> > J. Bruce Fields wrote:
> >> On Mon, Apr 05, 2010 at 10:55:12AM -0400, Chuck Lever wrote:
> >>   
> >>> On 04/03/2010 09:27 AM, Tom Tucker wrote:
> >>>     
> >>>> RPC6 requires that it be possible to create endpoints that listen
> >>>> exclusively for IPv4 or IPv6 connection requests. This is not currently
> >>>> supported by the RDMA API.
> >>>>
> >>>> Signed-off-by: Tom Tucker<tom@opengridcomputing.com>
> >>>> Tested-by: Steve Wise<swise@opengridcomputing.com>
> >>>>       
> >>> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
> >>>     
> >>
> >> Thanks to all.  I take it the problem began with 37498292a "NFSD: Create
> >> PF_INET6 listener in write_ports"?
> >>
> >>   
> >
> > Yes.
> 
> Thanks.  I'll pass along
> 
> 	git://linux-nfs.org/~bfields/linux.git for-2.6.34
> 
> soon.

And: sorry we didn't catch this when it happened.  I have some of the
equipment I'd need to do basic regression tests, but haven't set it up.

I hope I get to it at some point....  For now I depend on others to
catch even basic rdma regressions--let me know if there's some way I
could make your testing easier.

--b.
