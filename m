From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 2/2] nfsd: default to kernel default for minorversion 1
Date: Fri, 5 Feb 2010 11:10:02 -0500
Message-ID: <20100205161001.GB24926@fieldses.org>
References: <1264631166-21898-1-git-send-email-bfields@citi.umich.edu> <1264631166-21898-2-git-send-email-bfields@citi.umich.edu> <20100201195821.GB19418@fieldses.org> <4B6B480C.1050307@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51086 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754062Ab0BEQJp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Feb 2010 11:09:45 -0500
In-Reply-To: <4B6B480C.1050307-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 04, 2010 at 05:19:56PM -0500, Steve Dickson wrote:
> On 02/01/2010 02:58 PM, J. Bruce Fields wrote:
> > On Wed, Jan 27, 2010 at 05:26:06PM -0500, J. Bruce Fields wrote:
> >> The current kernel code should not be enabled by default, because it
> >> does not yet attempt to be a conform completely to the rfc; for example,
> >> some required pieces of protocol are missing.
> >>
> >> Therefore the kernel defaults to leaving minorversion1 off.  When the
> >> code matures sufficiently, that default will change.
> >>
> >> That kernel default becomes meaningless if nfs-utils always explicitly
> >> turns 4.1 on or off.  So, nfs-utils should by default do nothing.
> >>
> >> Provide a --enable-experimental-v41-support option to turn it on
> >> explicitly.  The option is intentionally spelled out (and has no short
> >> equivalent), to help ensure that users know what they're getting into.
> Command options like this are so hard to get rid of.... We just can't introduce
> an option one release and then have it go away a few releases down the road.
> That's sure fire way to breaking existing configurations which something that is, 
> has been and will continue to be unacceptable... 

OK, fair enough.  It shouldn't be a problem to keep it indefinitely,
though.

> >> Once 4.1 defaults to on, that option will become unnecessary (and can
> >> probably just be dropped from nfs-utils), and only the -N 4.1 option
> >> will be necessary.
> > 
> > We need to figure out how we're going to handle this.  The current
> > situation (ignoring the kernel's default) isn't acceptable.
> Why can't each distro simple turn it off with there init scripts?

On the server-side the kernel doesn't have a separate config option for
V4.1; the only way for the kernel to indicate whether it has a mature
version of V4.1 is by its choice of default.

> > We need to figure out something for v4 as well.  If every distro has run
> > nfsd without -N4, depending on the lack of fsid=0 to keep nfsv4 off by
> > default, then we're effectively turning v4 on by default with the
> > pseudoroot changes.  But there are good reasons why the v4 server code
> > is still marked experimental.
> I agree that with the latest kernels, v4 will be the default version. But
> there are ways to override this on both the server and client. So why let
> the users decided what they want?

I don't understand.

--b.
