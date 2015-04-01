Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:53022 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbbDAIrD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2015 04:47:03 -0400
Date: Wed, 1 Apr 2015 01:47:02 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "G?l, Bal?zs" <balazs.gal@tv2.hu>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Linux kernel 3.18+ blocklayout driver support only 4k pNFS block
 size
Message-ID: <20150401084702.GA21858@infradead.org>
References: <DB3PR03MB0891F4C3C510AB5C7565A4D0BAF40@DB3PR03MB0891.eurprd03.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <DB3PR03MB0891F4C3C510AB5C7565A4D0BAF40@DB3PR03MB0891.eurprd03.prod.outlook.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 31, 2015 at 03:16:41PM +0000, G?l, Bal?zs wrote:
> The page size is 4k on x64, but we use an EMC VNX5300 storage as a pNFS server, which use a hardcoded 8k file system block size.
> So I'm not able to use the VNX pNFS functionality with the current kernel anymore.
> 
> As I know, EMC is not the only one solution with the 8k block size, so this can brake lot of product on the market.

Which others pNFS block server is around?

> There is another issue with the client layout get requests implementation, what will limit the pNFS max file size in 524MB with the maximum 4k layout length in the request.

There is no concept of a max pNFS file size.  Do you mean a maximum
layout size?  There is no real delibrate limit.

> I'm just a dummy user from the broadcast Industry, and I want report it only, but it would be great if this problem can be handled by someone/somehow.

Linux can't handle writeback in guaranteed bigger than 4k sizes.  The
old code tried to work around this deep down in the stack in an
extremely dead-lock prone way.  We could do this less dead lock prone
but also a lot less performant when reading in data.  Either way we'd
need some deeply technical resource with access to the 8k servers to
help to test and debug the support.
