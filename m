From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 09/38] svc: Add a transport function that checks for
	write space
Date: Thu, 13 Dec 2007 17:28:37 -0500
Message-ID: <20071213222837.GB11768@fieldses.org>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int> <20071211233212.15718.69282.stgit@dell3.ogc.int> <421BFAC5-80AB-45E9-B67A-3770FDF353E9@oracle.com> <20071213213322.GE29496@fieldses.org> <1F79B182-2C72-46E0-A911-CE2722AF17FB@oracle.com> <1197584427.6348.10.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>, neilb@suse.de,
	linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:44425 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759563AbXLMW2n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Dec 2007 17:28:43 -0500
In-Reply-To: <1197584427.6348.10.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 13, 2007 at 04:20:27PM -0600, Tom Tucker wrote:
> 
> On Thu, 2007-12-13 at 16:45 -0500, Chuck Lever wrote:
> > On Dec 13, 2007, at 4:33 PM, J. Bruce Fields wrote:
> > > On Wed, Dec 12, 2007 at 01:10:17PM -0500, Chuck Lever wrote:
> > >> On Dec 11, 2007, at 6:32 PM, Tom Tucker wrote:
> > >>> +	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
> > >>> +	wspace = sk_stream_wspace(svsk->sk_sk);
> > >>> +
> > >>> +	if (wspace < sk_stream_min_wspace(svsk->sk_sk))
> > >>> +		return 0;
> > >>> +	if (required * 2 > wspace)
> > >>> +		return 0;
> > >>
> > >> Since "required" is an int, this test can behave differently than  
> > >> the one
> > >> it replaces.
> > >
> > > If sk_reserved can approach half of 2^31, for example, then surely we
> > > have bigger problems?
> > 
> > 
> > What stops sk_reserved from going negative?
> 
> Nothing actively _stops_ it from going negative. Indirectly it is
> prevented by the "fact" that sv_max_mesg is always greater than the
> amount returned by any read on the socket. If this is not true, then
> sk_reserved can go negative. That would occur in svc_recv when the
> difference between the amount currently reserved (worst case
> sv_max_mesg) and the amount read is subtracted from the amount reserved.
> If the amount read were greater than sv_max_mesg then the result would
> be negative (both meanings intended).
> 
> I could add a BUG_ON and run some tests.

I have to admit, I'm completely and utterly lost here.  Chuck, could you
explain exactly, in detail, how you think this change could cause a bug?

--b.
