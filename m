Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43414 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751888AbcISTE7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Sep 2016 15:04:59 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Christoph Hellwig" <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org,
        "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>,
        "Christoph Hellwig" <hch@lst.de>
Subject: Re: [PATCH v3] pnfs/blocklayout: update last_write_offset atomically
 with extents
Date: Mon, 19 Sep 2016 15:04:52 -0400
Message-ID: <8ECEF67B-FB4D-4289-A656-D98D3175B85E@redhat.com>
In-Reply-To: <20160919145806.GA12452@infradead.org>
References: <a754067b5a8252a10a0bcfa23c4229cf3d7b1adf.1471535578.git.bcodding@redhat.com>
 <f50699da22fbcd977842a4fa5dd40b27295fcfcf.1471889187.git.bcodding@redhat.com>
 <20160919145806.GA12452@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; markup=markdown
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 19 Sep 2016, at 10:58, Christoph Hellwig wrote:

> So it looks like this patch go in, but when I did my usually NFS
> regression tests that I stopped for a few weeks aover the summer it
> broke down badly: all the fsx and some other data integrity tests now
> fail in xfstests over pNFS blocklayout.
>
> Given how close it is to 4.8-final can we revert it for now?

Are you sure this patch is the problem?  I just tested and things are
broken for me too, but I think it has something to do with the client
choosing the block layout over SCSI now that the server is returning
multiple layout types.

I don't have block layout configured properly, but still I don't think
I should be getting -EIO if it isn't configured.  Shouldn't IO fall back
to the MDS?

It works if the server only returns SCSI layout type.. unless you're testing
something I'm not..

Just wondering if you reverted this patch and saw the problem go away.

Ben
