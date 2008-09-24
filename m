From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH] nfsd: use nfs client rpc callback program
Date: Wed, 24 Sep 2008 14:49:34 -0400
Message-ID: <20080924184934.GK5772@fieldses.org>
References: <20080917231018.GA5723@fieldses.org> <48D193EE.2020805@panasas.com> <48D19C74.8000303@panasas.com> <48D2AAF7.6060808@panasas.com> <20080924163528.GB5772@fieldses.org> <1222275582.7390.8.camel@localhost> <20080924172134.GI5772@fieldses.org> <1222277168.7390.19.camel@localhost> <20080924174230.GJ5772@fieldses.org> <1222281745.7390.34.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	linux-nfs@vger.kernel.org, pnfs mailing list <pnfs@linux-nfs.org>,
	Trond Myklebust <trond@netapp.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:46850 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751878AbYIXStl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2008 14:49:41 -0400
In-Reply-To: <1222281745.7390.34.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 24, 2008 at 02:42:25PM -0400, Trond Myklebust wrote:
> On Wed, 2008-09-24 at 13:42 -0400, J. Bruce Fields wrote:
> 
> > If by "broken" you mean, "introduces a new kernel bug", I don't see it.
> 
> I mean it introduces utterly unnecessary complications that may return
> to bite us in the arse at a future time.

OK, that's the answer I was looking for, thanks.

> Remember how we once said that it would never make sense for child
> clones to call the portmapper, and so we added the BUG_ON() in
> rpcb_getport_async; well guess what, we currently have a bug to fix...

No, I don't remember that.  But yes, I can see how in general this sort
of thing could make the code harder to maintain.

> One pretty obvious fix is to simply move the release method so that it
> doesn't occur when you release a child. The disadvantage is that a child
> may then not change its program to one that requires a release method
> (do we need that?).

I doubt we need that, but...

> Another fix would be to add a refcount to the rpc_program structure...

... a refcount seems more straightforward.  Benny, what do you think?

--b.
