Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:34306 "EHLO
	mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750732AbcEYV5d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2016 17:57:33 -0400
Received: by mail-yw0-f169.google.com with SMTP id c127so60357087ywb.1
        for <linux-nfs@vger.kernel.org>; Wed, 25 May 2016 14:57:32 -0700 (PDT)
Message-ID: <1464213449.7439.12.camel@poochiereds.net>
Subject: Re: [PATCH 3/4] nfsd: Add a super simple flex file server
From: Jeff Layton <jlayton@poochiereds.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Tom Haynes <thomas.haynes@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Date: Wed, 25 May 2016 17:57:29 -0400
In-Reply-To: <20160525174216.GA12306@fieldses.org>
References: <1464152979-103988-1-git-send-email-loghyr@primarydata.com>
	 <1464152979-103988-4-git-send-email-loghyr@primarydata.com>
	 <1464179444.3037.15.camel@poochiereds.net>
	 <20160525174216.GA12306@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-05-25 at 13:42 -0400, J. Bruce Fields wrote:
> On Wed, May 25, 2016 at 08:30:44AM -0400, Jeff Layton wrote:
> > 
> > Maybe it's time to start thinking about how to support multiple layout
> > types per export?
> It looks like nobody would want this flex file code in production.  The
> only users will be testers and developers.
> 
> And the scsi layout is really just a replacement for the block layout,
> nobody should be supporting both of those at once either.
> 

Well...unless you have a mix of clients that just support block and
some that support scsi. Is that plausible?

> Would it be too much of a burden just to make flexfiles and developers
> build their own kernels?
>
> > It doesn't look like it would be that hard. I think
> > we could convert ex_layout_type into a bitmap that shows which types
> > are supported.
> ex_layout_type is only used internally, the only external interface is
> an export flag, so we'd need some new interface.
> 

I was thinking that with the "pnfs" export option you'd just enable any
layouts that the fs supports. So here, you could theoretically allow
nfsd to offer up block, scsi and flexfiles layouts given the right fs,
and leave the decision of the layout type to actually use up to the
client.

-- 
Jeff Layton <jlayton@poochiereds.net>
