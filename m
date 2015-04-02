Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:45966 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbbDBI1m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2015 04:27:42 -0400
Date: Thu, 2 Apr 2015 01:27:41 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "G?l, Bal?zs" <balazs.gal@tv2.hu>
Cc: Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Linux kernel 3.18+ blocklayout driver support only 4k pNFS block
 size
Message-ID: <20150402082741.GA1202@infradead.org>
References: <DB3PR03MB0891F4C3C510AB5C7565A4D0BAF40@DB3PR03MB0891.eurprd03.prod.outlook.com>
 <20150401084702.GA21858@infradead.org>
 <AM3PR03MB0885CFC7D549D892D8FCF002BAF30@AM3PR03MB0885.eurprd03.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AM3PR03MB0885CFC7D549D892D8FCF002BAF30@AM3PR03MB0885.eurprd03.prod.outlook.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 01, 2015 at 04:21:31PM +0000, G?l, Bal?zs wrote:
> > There is no concept of a max pNFS file size.  Do you mean a maximum layout size?  There is no real delibrate limit.
> 
> This is the maximum file size, what can be handled by the block layout driver, because of the maximum layout size limit (at least with EMC).

So it's a server side limitation.  That also explains why no EMC user
ever saw the instant crash with > 2TB volumes in the old driver..

> Our pNFS story started at EMC in 01/22/2015, we are still waiting for a patch. Currently we will not use pNFS, because seems it's not production ready.

The NFS client driver has been in a very bad shape when I started
testing it against my new server, including crashed, lockups and lots of
data corruption.  This is why I ended up rewriting it entirely for Linux
3.18.  I would not recommend to use the older one at all.
