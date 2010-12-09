Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20685 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752695Ab0LITRy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Dec 2010 14:17:54 -0500
Subject: Re: oops in nfs_flush_incompatible (and possible fix?)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20101209140135.2d02579d@barsoom.rdu.redhat.com>
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
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 09 Dec 2010 14:17:52 -0500
Message-ID: <1291922272.6419.7.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-12-09 at 14:01 -0500, Jeff Layton wrote:
> On Tue, 07 Dec 2010 23:19:32 -0500
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> 
> > On Tue, 2010-12-07 at 22:45 -0500, Trond Myklebust wrote:
> > > On Tue, 2010-12-07 at 22:17 -0500, Trond Myklebust wrote:
> > > > OK... I think I see why the hang:
> > > > 
> > > > I believe that it is basically due to nfs_clear_page_tag_locked() making
> > > > the assumption that if req->wb_page != NULL, then the corresponding
> > > > nfsi->nfs_page_tree lock tag needs to be cleared.
> > > > 
> > > > Maybe we can do that differently by just setting a flag to indicate
> > > > whether or not this request is mapped into the radix tree...
> > > 
> > > The following patch is completely untested, but should do the trick....
> > 
> > ...and it appears to work correctly for me.
> > 
> 
> Hi Trond,
> 
> I've gotten some preliminary results with the patch that I backported
> to RHEL5:
> 
> -----------------------[snip]------------------
> 
> FYI, this version has been running now for about 18 hours on
> the same [host] where I originally observed this problem.  A full run takes 48
> hours, but this is well beyond the normal point of failure so I thought
> I'd share preliminary results.
> 
> -----------------------[snip]------------------
> 
> So, it looks good so far. If you like, you can add my. I'll let you
> know once the run is done.
> 
> Reviewed-by: Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Thanks!

BTW: the reason why the PG_MAPPER is not critical in the RHEL-5 back
port is because the BKL keeps you safe w.r.t. races between the tests in
nfs_flush_incompatible() and the nfs_clear_request call in
nfs_inode_remove_request().

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

