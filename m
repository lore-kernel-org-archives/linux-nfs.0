Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:60448 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753541AbaIZPsp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2014 11:48:45 -0400
Date: Fri, 26 Sep 2014 17:48:43 +0200
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfs/blocklayout: serialize GETDEVICEINFO calls
Message-ID: <20140926154843.GA22675@lst.de>
References: <1411740170-18611-1-git-send-email-hch@lst.de> <1411740170-18611-2-git-send-email-hch@lst.de> <CAHQdGtTg8Tc8bRqbezW-ZWrcTJdG233uRTrqQMP5CvxAcjW9Fg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtTg8Tc8bRqbezW-ZWrcTJdG233uRTrqQMP5CvxAcjW9Fg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 26, 2014 at 10:29:34AM -0400, Trond Myklebust wrote:
> It worries me that we're putting a mutex directly in the writeback
> path. For small arrays, it might be acceptable, but what if you have a
> block device with 1000s of disks on the back end?
> 
> Is there no better way to fix this issue?

Not without getting rid of the rpc_pipefs interface.  That is on my
very long term TODO list, but it will require new userspace support.

Note that I'm actually worried about GETDEVICEINFO from the writeback
path in general.  There is a lot that happens when we don't have
a device in cache, including the need to open a block device for
the block layout driver, which is a complex operation full of
GFP_KERNEL allocation, or even a more complex scsi device scan
for the object layout.  It's been on my more near term todo list
to look into reproducers for deadlocks in this area which seem
very possible, and then look into a fix for it; I can't really
think of anything less drastic than refusing block or object layout
I/O from memory reclaim if we don't have the device cached yet.
The situation for file layouts seems less severe, so I'll need
help from people more familar with to think about the situation there.

