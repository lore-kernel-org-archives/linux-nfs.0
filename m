Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50856 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751735Ab0JAXJ6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 19:09:58 -0400
Date: Fri, 1 Oct 2010 19:09:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Neil Brown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/7] sunrpc: fix race in new cache_wait code.
Message-ID: <20101001230941.GA12203@fieldses.org>
References: <20100922025009.31745.98237.stgit@localhost.localdomain>
 <20100922025506.31745.67177.stgit@localhost.localdomain>
 <20100922175027.GF15560@fieldses.org>
 <20100923130002.5f2da3e9@notabene>
 <20100923032540.GA13554@fieldses.org>
 <20100923144647.GD1054@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100923144647.GD1054@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 23, 2010 at 10:46:47AM -0400, J. Bruce Fields wrote:
> On Wed, Sep 22, 2010 at 11:25:40PM -0400, J. Bruce Fields wrote:
> > On Thu, Sep 23, 2010 at 01:00:02PM +1000, Neil Brown wrote:
> > > How about this.
> > > It gets rid of the return values (which were confusing anyway) and adds
> > > explicit checks on CAHCE_PENDING where needed.
> > > ??
> > 
> > Thanks, I'll take a look in the morning when my head's (hopefully)
> > clearer.
> 
> Looks reasonable to me on a quick skim.
> 
> > > Also, I noticed there is a race with the call to cache_limit_defers.  The
> > > 'dreq' could be freed before that is called.
> > > 
> > > It looks like I need to resubmit a lot of this - do you want to just discard
> > > it all from your -next and I'll make something new?
> > 
> > I'm trying very hard not to rewind -next; so I'd prefer incremental
> > patches for anything already there, replacements for the rest.
> 
> But I'll wait for a new series.  Thanks!

Well, just to have the bug fixed, I've applied your simple original fix
(1/7), but would still happily take incremental cleanup.

Out of this series that just leaves

	[PATCH 4/7] sunrpc/cache: centralise handling of size limit on
	deferred list.
	        
	[PATCH 5/7] sunrpc/cache: allow thread manager more control of
	whether threads can wait for upcalls

(And with no particular objection to either--they just seemed more RFC's
than "please apply"'s.)

--b.
