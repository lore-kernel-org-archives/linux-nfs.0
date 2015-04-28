Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42897 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030291AbbD1QDy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2015 12:03:54 -0400
Date: Tue, 28 Apr 2015 12:03:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org,
        Sachin Bhamare <sachin.bhamare@primarydata.com>,
        Jeff Layton <jlayton@primarydata.com>
Subject: Re: [PATCH 2/2] nfsd: fix pNFS return on close semantics
Message-ID: <20150428160353.GN4083@fieldses.org>
References: <1430139014-28013-1-git-send-email-hch@lst.de>
 <1430139014-28013-3-git-send-email-hch@lst.de>
 <20150427203943.GI4083@fieldses.org>
 <20150427193008.1195d7dd@tlielax.poochiereds.net>
 <20150428081456.GA21413@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150428081456.GA21413@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 28, 2015 at 10:14:56AM +0200, Christoph Hellwig wrote:
> On Mon, Apr 27, 2015 at 07:30:08PM -0400, Jeff Layton wrote:
> > One thing that might be good to do though is to create a dedicated
> > slabcache for these objects. On a pnfs-enabled server, you might end up
> > with quite a few of them, so packing them efficiently is probably a good
> > thing to do. That's just a refinement though and could be done in a
> > later patch.
> 
> Also currently we allocate them for any 4.1 server.  Now that I think about
> it we should at least make it conditional on CONFIG_NFSD_PNFS, or even
> better find a runtime check.
> 
> > > (Also: does this need to go to stable?  If we're potentially leaving
> > > layouts around forever, this sounds pretty serious.)
> 
> We're always returning them on file close, so we're not leaking anything.
> The common case is that we actually return them too early when we close
> the file but still have an outstanding delegation.

Oh, got it, thanks.

> I'm ok with a cc to stable, but it's a bit borderline.  Note that currently
> you even applied my two patches to your 4.2 incoming queue, not even 4.1..

Yeah, those -incoming branches are random works-in-progress and will get
rebased frequently, I'll move the other to for-4.1 and leave this one
for 4.2.

--b.
