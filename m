From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/2] commit_metadata export operation v6
Date: Mon, 22 Feb 2010 20:14:25 -0500
Message-ID: <20100223011425.GD17409@fieldses.org>
References: <20100217200426.13409.32688.stgit@case> <20100220233804.GA15015@fieldses.org> <20100222195353.GD10942@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, xfs@oss.sgi.com, aelder@sgi.com
To: bpm@sgi.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41470 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751372Ab0BWBNc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Feb 2010 20:13:32 -0500
In-Reply-To: <20100222195353.GD10942@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 22, 2010 at 01:53:53PM -0600, bpm@sgi.com wrote:
> Hey Bruce,
> 
> On Sat, Feb 20, 2010 at 06:38:04PM -0500, J. Bruce Fields wrote:
> > On Wed, Feb 17, 2010 at 02:05:05PM -0600, Ben Myers wrote:
> > > Hey Bruce,
> > > 
> > > Here is the latest version of the knfsd sync changes.  I have addressed the
> > > suggestions provided by Christoph, Trond, Dave, and Alex.
> > > 
> > > In this latest version I have fixed up the few nits in the nfsd patch that
> > > Christoph pointed out yesterday.  I also have simplified the xfs patch as
> > > suggested by Dave.
> > 
> > Thanks, applying.
> > 
> > (Do you the second (xfs) patch to go in through the nfsd tree as well,
> > or should that go in through xfs maintainers after the nfsd merge?)
> 
> I chatted with Alex.  It sounds like the best thing is for both patches
> to go in through the nfsd tree since they need to go in order.

OK, thanks, committed.--b.
