Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34323 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753277AbaKLQxe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Nov 2014 11:53:34 -0500
Date: Wed, 12 Nov 2014 11:53:32 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trondmy@gmail.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Subject: Re: BUG: [<ffffffffa01dac02>] nfsd4_proc_compound+0x432/0x6c0 [nfsd]
Message-ID: <20141112165332.GC5510@fieldses.org>
References: <20141112111955.7e2d3dd9@tlielax.poochiereds.net>
 <20141112162451.GB5510@fieldses.org>
 <20141112112821.22c15580@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141112112821.22c15580@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 12, 2014 at 11:28:21AM -0500, Jeff Layton wrote:
> On Wed, 12 Nov 2014 11:24:51 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Wed, Nov 12, 2014 at 11:19:55AM -0500, Jeff Layton wrote:
> > > Hi Bruce,
> > > 
> > > I've seen the following crash happen on a couple of different kernels
> > > recently. This one is from an older kernel that I just happened to be
> > > testing some other code on, but I've seen the same oops as well on
> > > v3.17.2 kernel from the fedora repos:
> > 
> > Do you have 51904b08072a "nfsd4: fix crash on unknown operation number"
> > ?
> > 
> > --b.
> > 
> 
> Ahh no...neither one has that. I'll apply it to the test kernel I'm
> using and see if it goes away. Thanks!
> 
> That said...wonder what the client would be sending that would cause
> this to fire?

There was a mis-merge, and CAP_SEEK is set in the wrong place in
fs/nfs/nfs4proc.c.  If you grep for CAP_SEEK in that file you'll see the
problem.

Trond, Anna, that still seems to be wrong upstream?  What happened to
that fix?

--b.
