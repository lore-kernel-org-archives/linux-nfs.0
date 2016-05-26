Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60748 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753465AbcEZNSJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 May 2016 09:18:09 -0400
Date: Thu, 26 May 2016 09:18:07 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Tom Haynes <thomas.haynes@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 3/4] nfsd: Add a super simple flex file server
Message-ID: <20160526131807.GB21450@fieldses.org>
References: <1464152979-103988-1-git-send-email-loghyr@primarydata.com>
 <1464152979-103988-4-git-send-email-loghyr@primarydata.com>
 <1464179444.3037.15.camel@poochiereds.net>
 <20160525174216.GA12306@fieldses.org>
 <1464213449.7439.12.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1464213449.7439.12.camel@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 25, 2016 at 05:57:29PM -0400, Jeff Layton wrote:
> On Wed, 2016-05-25 at 13:42 -0400, J. Bruce Fields wrote:
> > On Wed, May 25, 2016 at 08:30:44AM -0400, Jeff Layton wrote:
> > > 
> > > Maybe it's time to start thinking about how to support multiple layout
> > > types per export?
> > It looks like nobody would want this flex file code in production.  The
> > only users will be testers and developers.
> > 
> > And the scsi layout is really just a replacement for the block layout,
> > nobody should be supporting both of those at once either.
> > 
> 
> Well...unless you have a mix of clients that just support block and
> some that support scsi. Is that plausible?

Maybe so.  I don't think it would be useful to support, though.

(I'd rather people skipped straight to scsi.  And block never got much
use, so I don't think that should be hard.  But if you're really stuck
with some block clients, I suspect you may as well use block for all of
them--the scsi clients could probably do block layout too, and I think
you only get all the advantages of the scsi layout if all your clients
are using it.)

> > Would it be too much of a burden just to make flexfiles and developers
> > build their own kernels?
> >
> > > It doesn't look like it would be that hard. I think
> > > we could convert ex_layout_type into a bitmap that shows which types
> > > are supported.
> > ex_layout_type is only used internally, the only external interface is
> > an export flag, so we'd need some new interface.
> > 
> 
> I was thinking that with the "pnfs" export option you'd just enable any
> layouts that the fs supports. So here, you could theoretically allow
> nfsd to offer up block, scsi and flexfiles layouts given the right fs,
> and leave the decision of the layout type to actually use up to the
> client.

OK.

In this particular case that seems less interesting than just the
ability to turn flexfiles on and off from user space, so testers can
enable it without having to build a new kernel.

Hopefully we can figure out how to make this useful in production some
day, and then maybe the multiple-layout support becomes more
interesting.

--b.
