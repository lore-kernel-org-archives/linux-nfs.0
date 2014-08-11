Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:54607 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636AbaHKRUz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Aug 2014 13:20:55 -0400
Received: by mail-qc0-f173.google.com with SMTP id w7so1826188qcr.18
        for <linux-nfs@vger.kernel.org>; Mon, 11 Aug 2014 10:20:54 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 11 Aug 2014 13:20:53 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] nfsd: allow find_any_file to return a fi_deleg_file
 reference
Message-ID: <20140811132053.7f058eb1@tlielax.poochiereds.net>
In-Reply-To: <20140811170937.GC9095@fieldses.org>
References: <1407594162-28342-1-git-send-email-jlayton@primarydata.com>
	<1407594162-28342-4-git-send-email-jlayton@primarydata.com>
	<20140811160840.GB9095@fieldses.org>
	<20140811124039.7b57888d@tlielax.poochiereds.net>
	<20140811170937.GC9095@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 11 Aug 2014 13:09:37 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Aug 11, 2014 at 12:40:39PM -0400, Jeff Layton wrote:
> > On Mon, 11 Aug 2014 12:08:40 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Sat, Aug 09, 2014 at 10:22:42AM -0400, Jeff Layton wrote:
> > > > It's possible that we'll have a nfs4_file that has nothing in its fds
> > > > array, but that has a populated fi_deleg_file field.
> > > 
> > > Is it really possible?  On a quick skim it looks like this is only used
> > > in the presence of lock stateid's, when we should have an open.
> > > 
> > > OK with the cleanup I'm just not seeing a reason either one way or the
> > > other for the fi_deleg_file change.
> > > 
> > > --b.
> > > 
> > 
> > You're correct. The existing code doesn't specifically require this
> > patch since find_any_file is only used with lock stateids. It
> > should be harmless but it won't hurt anything to drop it.
> > 
> > I did however need this when I rebased some pnfsd patches on top of the
> > state overhaul, and it seemed like a reasonable change from a
> > "future-proofing" standpoint.
> 
> So layout operations depend on this somehow?  (But layouts can outlast
> delegations, so that must not be it.)
> 
> I'm not opposed to future-proofing as long as we have some evidence
> about the future.
> 

The code I'm working on does depend on this, but it's may not be
correct for any arbitrary filesystem.

This filesystem sets return_on_close, and we automatically return the
layout to the fs when all of the open and deleg stateids go away. If
the last one to drop its reference happens to be the delegation
stateid, then you may have nothing in the fi_fds slots, and no way to
get to the inode in order to return the layout.

I've been toying with the idea of keeping an inode reference in the
layout state, but I'm not sure if it's the right thing to do...

> > Do you intend to the take the first two in the series? I would like to
> > see those go in since they move the lease removal outside of spinlocks.
> 
> Yes, just waiting for -rc1 comes out to push out a for-3.18 tree.
> 

Sounds good -- no rush on them.

Thanks!
-- 
Jeff Layton <jlayton@primarydata.com>
