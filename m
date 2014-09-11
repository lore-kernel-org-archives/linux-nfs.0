Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:52861 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756005AbaIKPYZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Sep 2014 11:24:25 -0400
Date: Thu, 11 Sep 2014 17:24:22 +0200
From: Christoph Hellwig <hch@lst.de>
To: Peng Tao <bergwolf@primarydata.com>
Cc: Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 7/9] pnfs/blocklayout: implement the return_range method
Message-ID: <20140911152422.GC6690@lst.de>
References: <1410362617-28018-1-git-send-email-hch@lst.de> <1410362617-28018-8-git-send-email-hch@lst.de> <CAKVebiWGsuHTFbCdfQ+=tYakwok5-KPWK7A=zaWmnuJewS+fGg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKVebiWGsuHTFbCdfQ+=tYakwok5-KPWK7A=zaWmnuJewS+fGg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 11, 2014 at 10:16:56PM +0800, Peng Tao wrote:
> > diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> > index 42b6f9c..a7524c4 100644
> > --- a/fs/nfs/blocklayout/blocklayout.c
> > +++ b/fs/nfs/blocklayout/blocklayout.c
> > @@ -470,6 +470,35 @@ static struct pnfs_layout_segment *bl_alloc_lseg(struct pnfs_layout_hdr *lo,
> >  }
> >
> >  static void
> > +bl_return_range(struct pnfs_layout_hdr *lo,
> > +               struct pnfs_layout_range *range)
> > +{
> > +       struct pnfs_block_layout *bl = BLK_LO2EXT(lo);
> > +       sector_t offset = range->offset >> SECTOR_SHIFT, end;
> > +       int err;
> > +
> > +       if (range->offset % 8) {
> why arbitrary block size? You should be able to use the blocksize
> returned by server, right?

I need to look into it.  Right now the client has all extents properly
aligned, and allowing a smaller size here would change that.  Give me
some time to test it and get back to you.

> 
> btw, did you test your patchset with smaller block size such as 2K/1K?
> Did it work?

I did test a very early version but haven't redone the tests.  It worked
fine because even although the server supported smaller blocks the client
now never asks for anything not aligned to 4k!

