Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43345 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755814Ab0LITZt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Dec 2010 14:25:49 -0500
Date: Thu, 9 Dec 2010 14:25:47 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: oops in nfs_flush_incompatible (and possible fix?)
Message-ID: <20101209142547.17f3a801@barsoom.rdu.redhat.com>
In-Reply-To: <1291922272.6419.7.camel@heimdal.trondhjem.org>
References: <20101206145743.4464c79d@tlielax.poochiereds.net>
	<1291758082.3049.42.camel@heimdal.trondhjem.org>
	<20101207165354.32c863f2@tlielax.poochiereds.net>
	<1291768200.3049.51.camel@heimdal.trondhjem.org>
	<20101207200344.68ff29e3@corrin.poochiereds.net>
	<20101207213540.441330db@corrin.poochiereds.net>
	<1291778228.20468.6.camel@heimdal.trondhjem.org>
	<1291779950.21760.1.camel@heimdal.trondhjem.org>
	<1291781972.21760.2.camel@heimdal.trondhjem.org>
	<20101209140135.2d02579d@barsoom.rdu.redhat.com>
	<1291922272.6419.7.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 09 Dec 2010 14:17:52 -0500
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Thu, 2010-12-09 at 14:01 -0500, Jeff Layton wrote:
> > On Tue, 07 Dec 2010 23:19:32 -0500
> > Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Tue, 2010-12-07 at 22:45 -0500, Trond Myklebust wrote:
> > > > On Tue, 2010-12-07 at 22:17 -0500, Trond Myklebust wrote:
> > > > > OK... I think I see why the hang:
> > > > > 
> > > > > I believe that it is basically due to nfs_clear_page_tag_locked() making
> > > > > the assumption that if req->wb_page != NULL, then the corresponding
> > > > > nfsi->nfs_page_tree lock tag needs to be cleared.
> > > > > 
> > > > > Maybe we can do that differently by just setting a flag to indicate
> > > > > whether or not this request is mapped into the radix tree...
> > > > 
> > > > The following patch is completely untested, but should do the trick....
> > > 
> > > ...and it appears to work correctly for me.
> > > 
> > 
> > Hi Trond,
> > 
> > I've gotten some preliminary results with the patch that I backported
> > to RHEL5:
> > 
> > -----------------------[snip]------------------
> > 
> > FYI, this version has been running now for about 18 hours on
> > the same [host] where I originally observed this problem.  A full run takes 48
> > hours, but this is well beyond the normal point of failure so I thought
> > I'd share preliminary results.
> > 
> > -----------------------[snip]------------------
> > 
> > So, it looks good so far. If you like, you can add my. I'll let you
> > know once the run is done.
> > 
> > Reviewed-by: Jeff Layton <jlayton@redhat.com>
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> Thanks!
> 
> BTW: the reason why the PG_MAPPER is not critical in the RHEL-5 back
> port is because the BKL keeps you safe w.r.t. races between the tests in
> nfs_flush_incompatible() and the nfs_clear_request call in
> nfs_inode_remove_request().
> 
> Cheers
>   Trond
> 


RHEL5 also doesn't have nfs_set/clear_page_tag_locked, so that explains
why we didn't see the hang there.

I still backported the PG_MAPPED change anyway as I think it's cleaner
than testing for a NULL wb_page (which rhel5 does in
nfs_clear_page_writeback).

-- 
Jeff Layton <jlayton@redhat.com>
