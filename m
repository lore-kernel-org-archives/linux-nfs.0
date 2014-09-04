Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:35014 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750796AbaIDBiY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Sep 2014 21:38:24 -0400
Date: Thu, 4 Sep 2014 03:38:21 +0200
From: Christoph Hellwig <hch@lst.de>
To: Anna Schumaker <schumaker.anna@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/6] pnfs/blocklayout: in-kernel GETDEVICEINFO XDR
	parsing
Message-ID: <20140904013821.GB24783@lst.de>
References: <1409719119-2110-1-git-send-email-hch@lst.de> <1409719119-2110-6-git-send-email-hch@lst.de> <54076C7B.2010400@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <54076C7B.2010400@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > +static void
> > +bl_free_device(struct pnfs_block_dev *dev)
> > +{
> > +	if (dev->nr_children) {
> > +		int i;
> > +
> > +		for (i = 0; i < dev->nr_children; i++)
> > +			bl_free_device(&dev->children[i]);
> > +		kfree(dev->children);
> > +	} else {
> > +		if (dev->bdev)
> > +			blkdev_put(dev->bdev, FMODE_READ);
> 
> else if (dev->bdev)? :)

This was ver ymuch intentional to make it clear there's a leaf device and
non-leaf device case.

> Can you make each of these cases a helper function?

I could - in fact I had it that way earlier, but it increased code size and
decreased readability so I merged it back together.

> > +static int
> > +bl_parse_deviceid(struct nfs_server *server, struct pnfs_block_dev *d,
> > +		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask);
> 
> Why put the declaration in the middle of the file?

No good reason - this is about where we start to need it.  I can move
it to the top.

