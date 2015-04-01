Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.tv2.hu ([91.82.156.6]:50337 "EHLO mail.tv2.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751298AbbDAQVi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2015 12:21:38 -0400
From: =?iso-8859-2?Q?G=E1l=2C_Bal=E1zs?= <balazs.gal@tv2.hu>
To: Christoph Hellwig <hch@infradead.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: Linux kernel 3.18+ blocklayout driver support only 4k pNFS block
 size
Date: Wed, 1 Apr 2015 16:21:31 +0000
Message-ID: <AM3PR03MB0885CFC7D549D892D8FCF002BAF30@AM3PR03MB0885.eurprd03.prod.outlook.com>
References: <DB3PR03MB0891F4C3C510AB5C7565A4D0BAF40@DB3PR03MB0891.eurprd03.prod.outlook.com>
 <20150401084702.GA21858@infradead.org>
In-Reply-To: <20150401084702.GA21858@infradead.org>
Content-Type: text/plain; charset="iso-8859-2"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> There is no concept of a max pNFS file size.  Do you mean a maximum layout size?  There is no real delibrate limit.

This is the maximum file size, what can be handled by the block layout driver, because of the maximum layout size limit (at least with EMC).
Every file what is bigger than this, will be handled over the IP network.
I'm not familiar with the layout, maybe an offset can be used, but seems this is not the case.

The client layout request:
layout type: LAYOUT4_BLOCK_VOLUME
IO mode: IOMODE_RW
offset: 0 !!!
length: 524288000 !!!
min length: 4096
stateid.maxount: 4096 !!!

The server will respond with NFS4ERR_TOOSMALL Status to indicate the layout can't be fit in 4k, what seems is an acceptable behavior.

> Do you mean a maximum layout size?  

Yes. (The stateid.maxcount)

> Linux can't handle writeback in guaranteed bigger than 4k sizes.  The old code tried to work around this deep down in the stack in an extremely dead-lock prone way.  We could do this less
> dead lock prone but also a lot less performant when reading in data.  Either way we'd need some deeply technical resource with access to the 8k servers to help to test and debug the support.

This would be great. Maybe EMC can support this with a test environment. We are in contact with EMC, we can push them to provide one.

Our pNFS story started at EMC in 01/22/2015, we are still waiting for a patch. Currently we will not use pNFS, because seems it's not production ready.

Thx

Balazs


-----Original Message-----
From: Christoph Hellwig [mailto:hch@infradead.org] 
Sent: Wednesday, April 01, 2015 10:47 AM
To: Gál, Balázs
Cc: linux-nfs@vger.kernel.org
Subject: Re: Linux kernel 3.18+ blocklayout driver support only 4k pNFS block size

On Tue, Mar 31, 2015 at 03:16:41PM +0000, G?l, Bal?zs wrote:
> The page size is 4k on x64, but we use an EMC VNX5300 storage as a pNFS server, which use a hardcoded 8k file system block size.
> So I'm not able to use the VNX pNFS functionality with the current kernel anymore.
> 
> As I know, EMC is not the only one solution with the 8k block size, so this can brake lot of product on the market.

Which others pNFS block server is around?

> There is another issue with the client layout get requests implementation, what will limit the pNFS max file size in 524MB with the maximum 4k layout length in the request.

There is no concept of a max pNFS file size.  Do you mean a maximum layout size?  There is no real delibrate limit.

> I'm just a dummy user from the broadcast Industry, and I want report it only, but it would be great if this problem can be handled by someone/somehow.

Linux can't handle writeback in guaranteed bigger than 4k sizes.  The old code tried to work around this deep down in the stack in an extremely dead-lock prone way.  We could do this less dead lock prone but also a lot less performant when reading in data.  Either way we'd need some deeply technical resource with access to the 8k servers to help to test and debug the support.
