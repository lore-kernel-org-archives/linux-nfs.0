Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:35135 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754265AbaHGL16 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Aug 2014 07:27:58 -0400
Date: Thu, 7 Aug 2014 13:27:55 +0200
From: Christoph Hellwig <hch@lst.de>
To: Peng Tao <bergwolf@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linuxnfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 17/17] pnfs/blocklayout: allocate separate pages for
	the layoutcommit payload
Message-ID: <20140807112754.GB3437@lst.de>
References: <1407396229-4785-1-git-send-email-hch@lst.de> <1407396229-4785-18-git-send-email-hch@lst.de> <CA+a=Yy7EmafqPefCG=xNKz-is8h0FgKNSFJ23RshEcLwr5sZ9A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+a=Yy7EmafqPefCG=xNKz-is8h0FgKNSFJ23RshEcLwr5sZ9A@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 07, 2014 at 07:05:03PM +0800, Peng Tao wrote:
> On Thu, Aug 7, 2014 at 3:23 PM, Christoph Hellwig <hch@lst.de> wrote:
> > Instead of overflowing the XDR send buffer with our extent list allocate
> > pages and pre-encode the layoutupdate payload into them.  We optimistically
> > allocate a single page use alloc_page and only switch to vmalloc when we
> > have more extents outstanding.  Currently there is only a single testcase
> > (xfstests generic/113) which can reproduce large enough extent lists for
> > this to occur.
> >
> depending on how badly the extents are fragmented, it might worth
> starting an async layoutcommit within blocklayout client when bl_count
> reaches certain limit, so that we don't send an unlimited amount of
> extents in one layoutcommit.

I though about this, but this only reduces the problem and we'd still
need to be able to commit all extents for a data integrity operation,
so we'd still need someting like the above.

The other option I considered and prototyped was to send multiple on the
wire layoutcommit calls from pnfs_layoutcommit_inode, but that did prove
to be even more cumbersome.
