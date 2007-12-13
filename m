From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 09/38] svc: Add a transport function that checks for
	write space
Date: Thu, 13 Dec 2007 16:20:27 -0600
Message-ID: <1197584427.6348.10.camel@trinity.ogc.int>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int>
	 <20071211233212.15718.69282.stgit@dell3.ogc.int>
	 <421BFAC5-80AB-45E9-B67A-3770FDF353E9@oracle.com>
	 <20071213213322.GE29496@fieldses.org>
	 <1F79B182-2C72-46E0-A911-CE2722AF17FB@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, neilb@suse.de,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:58550 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763666AbXLMWPZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Dec 2007 17:15:25 -0500
In-Reply-To: <1F79B182-2C72-46E0-A911-CE2722AF17FB@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2007-12-13 at 16:45 -0500, Chuck Lever wrote:
> On Dec 13, 2007, at 4:33 PM, J. Bruce Fields wrote:
> > On Wed, Dec 12, 2007 at 01:10:17PM -0500, Chuck Lever wrote:
> >> On Dec 11, 2007, at 6:32 PM, Tom Tucker wrote:
> >>> +	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
> >>> +	wspace = sk_stream_wspace(svsk->sk_sk);
> >>> +
> >>> +	if (wspace < sk_stream_min_wspace(svsk->sk_sk))
> >>> +		return 0;
> >>> +	if (required * 2 > wspace)
> >>> +		return 0;
> >>
> >> Since "required" is an int, this test can behave differently than  
> >> the one
> >> it replaces.
> >
> > If sk_reserved can approach half of 2^31, for example, then surely we
> > have bigger problems?
> 
> 
> What stops sk_reserved from going negative?

Nothing actively _stops_ it from going negative. Indirectly it is
prevented by the "fact" that sv_max_mesg is always greater than the
amount returned by any read on the socket. If this is not true, then
sk_reserved can go negative. That would occur in svc_recv when the
difference between the amount currently reserved (worst case
sv_max_mesg) and the amount read is subtracted from the amount reserved.
If the amount read were greater than sv_max_mesg then the result would
be negative (both meanings intended).

I could add a BUG_ON and run some tests.

> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com

