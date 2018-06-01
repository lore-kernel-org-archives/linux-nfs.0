Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.133]:42614 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751693AbeFAR2l (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jun 2018 13:28:41 -0400
Date: Fri, 1 Jun 2018 10:28:35 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Adam Manzanares <Adam.Manzanares@wdc.com>,
        Christoph Hellwig <hch@lst.de>,
        Al Viro <viro@ZenIV.linux.org.uk>,
        kbuild test robot <lkp@intel.com>,
        "kbuild-all@01.org" <kbuild-all@01.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        Jeff Moyer <jmoyer@redhat.com>,
        Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [vfs:work.aio 10/12] fs/aio.c:1444: undefined reference to
 `ioprio_check_cap'
Message-ID: <20180601172835.GA29651@bombadil.infradead.org>
References: <201806010845.bDzP7QCW%fengguang.wu@intel.com>
 <20180601005448.GN30522@ZenIV.linux.org.uk>
 <20180601051353.GA21589@lst.de>
 <9ad99d87-07c3-6611-3252-49d788f8028e@wdc.com>
 <f24fe7e0-8531-bdca-4571-9a8caa4b4e70@kernel.dk>
 <edac24e9-5562-faf9-c5a6-dce8e832eefe@wdc.com>
 <6f96a8de-143a-6b2c-fa89-72fed88b431e@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <6f96a8de-143a-6b2c-fa89-72fed88b431e@kernel.dk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 01, 2018 at 09:59:03AM -0600, Jens Axboe wrote:
> On 6/1/18 9:57 AM, Adam Manzanares wrote:
> > 
> > 
> > On 6/1/18 8:41 AM, Jens Axboe wrote:
> >> On 6/1/18 9:38 AM, Adam Manzanares wrote:
> >>> On 5/31/18 10:13 PM, Christoph Hellwig wrote:
> >>>>> +extern int ioprio_check_cap(int ioprio);
> >>>>
> >>>> Which then is implemented in block/ioprio.c, which depends on
> >>>> CONFIG_BLOCK.  The code either needs a stub for !CONFIG_BLOCK
> >>>> or moved elsewhere.
> >>>
> >>> My vote would be to move the ioprio code into fs/. At first glance I do
> >>> not see a dependence on the block layer in block/ioprio.c.
> >>>
> >>> Any objections?
> >>
> >> Since it's block ioprio code, I'd prefer a stub instead.
> >>
> > 
> > This feature could be used independently from the block layer. We have 
> > examples (ATA, hopefully NVME soon) where we are reacting to the ioprio 
> > in the device drivers essentially passing the ioprio through the block 
> > layer.
> 
> It could, yes, but it isn't. As it stands, it's system call support to
> pass in IO priority for what ultimately is block storage.

I think it'd be interesting if NFS/SMB decided to start using it.
I think SMB has the concept of io priorities within a single stream ...
Steve?
