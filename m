Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45555 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753140Ab3BAQFD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Feb 2013 11:05:03 -0500
Date: Fri, 1 Feb 2013 11:05:01 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org,
        Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH v1 08/16] nfsd: break out hashtable search into separate
 function
Message-ID: <20130201160501.GB6508@fieldses.org>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
 <1359402082-29195-9-git-send-email-jlayton@redhat.com>
 <20130201131409.GB30668@fieldses.org>
 <20130201102640.6b1898cb@tlielax.poochiereds.net>
 <20130201155131.GA6508@fieldses.org>
 <20130201110118.210f428a@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130201110118.210f428a@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 01, 2013 at 11:01:18AM -0500, Jeff Layton wrote:
> On Fri, 1 Feb 2013 10:51:31 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Fri, Feb 01, 2013 at 10:26:40AM -0500, Jeff Layton wrote:
> > > On Fri, 1 Feb 2013 08:14:09 -0500
> > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > 
> > > > On Mon, Jan 28, 2013 at 02:41:14PM -0500, Jeff Layton wrote:
> > > > > Later, we'll need more than one call site for this, so break it out
> > > > > into a new function.
> > > > 
> > > > I'm applying these first 8 to the for-3.9 branch at:
> > > > 
> > > > 	git://linux-nfs.org/~bfields/linux.git for-3.9
> > > > 
> > > > --b.
> > > > 
> > > 
> > > Thanks Bruce. I rebased the remaining patches on top of these, and now
> > > I'm seeing this when I try to test against it. I don't think it's due
> > > to the DRC patches, but I haven't started tracking it down yet:
> > 
> > Probably Stanislav's latest patches to the cache upcall code.  I'm
> > surprised I didn't hit it.
> > 
> > --b.
> > 
> 
> My apologies... it was a kABI issue ;)
> 
> I had built a nfsd.ko module to test my changes, but didn't build
> sunrpc.ko to make sure that I got Stanislav's changes. When I did that,
> the oops went away...

Ah, ok, good.--b.
