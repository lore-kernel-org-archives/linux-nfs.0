Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51842 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752930Ab2HUX6X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 19:58:23 -0400
Date: Tue, 21 Aug 2012 19:58:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: remove unused listener-removal interfaces
Message-ID: <20120821235818.GA20158@fieldses.org>
References: <20120815234259.GB28054@fieldses.org>
 <20120821172902.GA15958@fieldses.org>
 <20120822083308.3bca78f8@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120822083308.3bca78f8@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 22, 2012 at 08:33:08AM +1000, NeilBrown wrote:
> On Tue, 21 Aug 2012 13:29:02 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Wed, Aug 15, 2012 at 07:43:00PM -0400, J. Bruce Fields wrote:
> > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > 
> > > You can use nfsd/portlist to give nfsd additional sockets to listen on.
> > > In theory you can also remove listening sockets this way.  But nobody's
> > > ever done that as far as I can tell.
> > > 
> > > Also this was partially broken in 2.6.25, by
> > > a217813f9067b785241cb7f31956e51d2071703a "knfsd: Support adding
> > > transports by writing portlist file".
> > > 
> > > (Note that we decide whether to take the "delfd" case by checking for a
> > > digit--but what's actually expected in that case is something made by
> > > svc_one_sock_name(), which won't begin with a digit.)
> > > 
> > > So, let's just rip out this stuff.
> > > 
> > > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > > ---
> > >  fs/nfsd/nfsctl.c               |   78 ----------------------------------------
> > >  include/linux/sunrpc/svcsock.h |    3 --
> > >  net/sunrpc/svcsock.c           |   51 --------------------------
> > >  3 files changed, 132 deletions(-)
> > > 
> > > OK, maybe this is somewhat of a troll patch--but I don't actually know
> > > how to fix this interface, so: do we really have a use for it?
> > 
> > Neil, was the the "-portname" thing originally yours?  Did you have a
> > use case in mind?
> > 
> 
> Yes it was mine.  It seemed like a good idea at a time.
> If you can turn something on, you should be able to turn it off too.
> 
> When do ports get closed?  Just on last-server-exit?  As you know, I don't
> like the idea of things happening on last-server-exit, but it does seem to
> work.  Mostly.
>
> There doesn't seem to be any really need to close sockets independently so we
> may as well rip this code out.  It can be added again if a need is found.
> 
> Acked-by: NeilBrown <neilb@suse.de>

OK, thanks.--b.
