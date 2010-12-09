Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40556 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755972Ab0LITBi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Dec 2010 14:01:38 -0500
Date: Thu, 9 Dec 2010 14:01:35 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: oops in nfs_flush_incompatible (and possible fix?)
Message-ID: <20101209140135.2d02579d@barsoom.rdu.redhat.com>
In-Reply-To: <1291781972.21760.2.camel@heimdal.trondhjem.org>
References: <20101206145743.4464c79d@tlielax.poochiereds.net>
	<1291758082.3049.42.camel@heimdal.trondhjem.org>
	<20101207165354.32c863f2@tlielax.poochiereds.net>
	<1291768200.3049.51.camel@heimdal.trondhjem.org>
	<20101207200344.68ff29e3@corrin.poochiereds.net>
	<20101207213540.441330db@corrin.poochiereds.net>
	<1291778228.20468.6.camel@heimdal.trondhjem.org>
	<1291779950.21760.1.camel@heimdal.trondhjem.org>
	<1291781972.21760.2.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 07 Dec 2010 23:19:32 -0500
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Tue, 2010-12-07 at 22:45 -0500, Trond Myklebust wrote:
> > On Tue, 2010-12-07 at 22:17 -0500, Trond Myklebust wrote:
> > > OK... I think I see why the hang:
> > > 
> > > I believe that it is basically due to nfs_clear_page_tag_locked() making
> > > the assumption that if req->wb_page != NULL, then the corresponding
> > > nfsi->nfs_page_tree lock tag needs to be cleared.
> > > 
> > > Maybe we can do that differently by just setting a flag to indicate
> > > whether or not this request is mapped into the radix tree...
> > 
> > The following patch is completely untested, but should do the trick....
> 
> ...and it appears to work correctly for me.
> 

Hi Trond,

I've gotten some preliminary results with the patch that I backported
to RHEL5:

-----------------------[snip]------------------

FYI, this version has been running now for about 18 hours on
the same [host] where I originally observed this problem.  A full run takes 48
hours, but this is well beyond the normal point of failure so I thought
I'd share preliminary results.

-----------------------[snip]------------------

So, it looks good so far. If you like, you can add my. I'll let you
know once the run is done.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
