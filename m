Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45546 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753779Ab0BET2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Feb 2010 14:28:42 -0500
Date: Fri, 5 Feb 2010 14:28:59 -0500
From: "J. Bruce Fields" <bfields@citi.umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: default to kernel default for minorversion 1
Message-ID: <20100205192859.GE24926@fieldses.org>
References: <1264631166-21898-1-git-send-email-bfields@citi.umich.edu> <1264631166-21898-2-git-send-email-bfields@citi.umich.edu> <20100201195821.GB19418@fieldses.org> <4B6B480C.1050307@RedHat.com> <20100205161001.GB24926@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100205161001.GB24926@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Feb 05, 2010 at 11:10:02AM -0500, J. Bruce Fields wrote:
> On Thu, Feb 04, 2010 at 05:19:56PM -0500, Steve Dickson wrote:
> > On 02/01/2010 02:58 PM, J. Bruce Fields wrote:
> > > On Wed, Jan 27, 2010 at 05:26:06PM -0500, J. Bruce Fields wrote:
> > >> The current kernel code should not be enabled by default, because it
> > >> does not yet attempt to be a conform completely to the rfc; for example,
> > >> some required pieces of protocol are missing.
> > >>
> > >> Therefore the kernel defaults to leaving minorversion1 off.  When the
> > >> code matures sufficiently, that default will change.
> > >>
> > >> That kernel default becomes meaningless if nfs-utils always explicitly
> > >> turns 4.1 on or off.  So, nfs-utils should by default do nothing.
> > >>
> > >> Provide a --enable-experimental-v41-support option to turn it on
> > >> explicitly.  The option is intentionally spelled out (and has no short
> > >> equivalent), to help ensure that users know what they're getting into.
> > Command options like this are so hard to get rid of.... We just can't introduce
> > an option one release and then have it go away a few releases down the road.
> > That's sure fire way to breaking existing configurations which something that is, 
> > has been and will continue to be unacceptable... 
> 
> OK, fair enough.  It shouldn't be a problem to keep it indefinitely,
> though.

Actually, an even simpler option: instead of adding a new option, just
modify the code so that the *absence* of -N4.1 isn't taken to mean
"please turn on 4.1".  People can always just do their own

	echo +4.1 >/proc/fs/nfsd/version

if that's what they want.

--b.
