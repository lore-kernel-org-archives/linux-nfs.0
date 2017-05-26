Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:41127 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1030445AbdEZGKE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 26 May 2017 02:10:04 -0400
Date: Fri, 26 May 2017 08:10:03 +0200
From: "hch@lst.de" <hch@lst.de>
To: Bart Van Assche <Bart.VanAssche@sandisk.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
        "hch@lst.de" <hch@lst.de>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>,
        "osandov@fb.com" <osandov@fb.com>, "axboe@fb.com" <axboe@fb.com>,
        "axboe@kernel.dk" <axboe@kernel.dk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 06/19] nfsd: Check private request size before
        submitting a SCSI request
Message-ID: <20170526061003.GF18424@lst.de>
References: <20170525184327.23570-1-bart.vanassche@sandisk.com> <20170525184327.23570-7-bart.vanassche@sandisk.com> <20170525184851.GD4298@fieldses.org> <1495743585.2615.6.camel@sandisk.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1495743585.2615.6.camel@sandisk.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 25, 2017 at 08:19:47PM +0000, Bart Van Assche wrote:
> On Thu, 2017-05-25 at 14:48 -0400, J . Bruce Fields wrote:
> > On Thu, May 25, 2017 at 11:43:14AM -0700, Bart Van Assche wrote:
> > > Since using scsi_req() is only allowed against request queues for
> > > which struct scsi_request is the first member of their private
> > > request data, refuse to submit SCSI commands against a queue for
> > > which this is not the case.
> > 
> > Is it possible we could catch this earlier and avoid giving out the
> > layout in the first place?
> 
> Hello Christoph,
> 
> According to what I see in commit 8650b8a05850 you are the author of this
> code? Can the blk_queue_scsi_pdu(q) test fail in nfsd4_scsi_identify_device()?

If the user explicitly asked for a scsi layout export of a non-scsi
device it can.

> If so, can nfsd4_layout_verify() be modified in such a way that it prevents
> that nfsd4_scsi_proc_getdeviceinfo() is ever called for a non-SCSI queue?
> Can you recommend an approach?

Not easily.  The only thing we could do is an export time check, that
would refuse the scsi layout export if the device is not capable.

I can look into that, but it will take some time so for now I think we
should go ahead with your series.
