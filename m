Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59894 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932862AbcEYRmR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 May 2016 13:42:17 -0400
Date: Wed, 25 May 2016 13:42:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Tom Haynes <thomas.haynes@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 3/4] nfsd: Add a super simple flex file server
Message-ID: <20160525174216.GA12306@fieldses.org>
References: <1464152979-103988-1-git-send-email-loghyr@primarydata.com>
 <1464152979-103988-4-git-send-email-loghyr@primarydata.com>
 <1464179444.3037.15.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1464179444.3037.15.camel@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 25, 2016 at 08:30:44AM -0400, Jeff Layton wrote:
> Maybe it's time to start thinking about how to support multiple layout
> types per export?

It looks like nobody would want this flex file code in production.  The
only users will be testers and developers.

And the scsi layout is really just a replacement for the block layout,
nobody should be supporting both of those at once either.

Would it be too much of a burden just to make flexfiles and developers
build their own kernels?

> It doesn't look like it would be that hard. I think
> we could convert ex_layout_type into a bitmap that shows which types
> are supported.

ex_layout_type is only used internally, the only external interface is
an export flag, so we'd need some new interface.

--b.

> The harder work looks to be on the client. You'd need some heuristic to choose when you get back multiple layout types and fix that to work properly.
