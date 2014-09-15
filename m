Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:33197 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752807AbaIORMQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Sep 2014 13:12:16 -0400
Date: Mon, 15 Sep 2014 19:12:12 +0200
From: Christoph Hellwig <hch@lst.de>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Christoph Hellwig <hch@lst.de>, Benny Halevy <bhalevy@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: layoutcommit space reservation for the objlayout driver
Message-ID: <20140915171212.GA23765@lst.de>
References: <20140914164655.GB13467@lst.de> <5416ABF3.3040403@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5416ABF3.3040403@plexistor.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 15, 2014 at 12:05:55PM +0300, Boaz Harrosh wrote:
> I do not understand. This used to work just fine. Please point me to
> the patch that broke it?
> (And since when are we allowed to brake old code?)

I bet it still works the same way it does as commited, which doesn't
make it right.  The way the NFS XDR buffer allocations work seems to be
that you can actually slightly overun it without things falling apart,
but that doesn't make it right.  E.g. it took a fairly larger overrun
in the block layout driver to finally find the issues, and most of the
time it was just silent truncations, real corruption happened less
often.

But to make sure things work properly in the long run you'd really want
to have the proper allocation.
