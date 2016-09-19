Return-Path: <hch@lst.de>
Date: Mon, 19 Sep 2016 21:06:10 +0200
From: Christoph Hellwig <hch@lst.de>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v3] pnfs/blocklayout: update last_write_offset
	atomically with extents
Message-ID: <20160919190610.GA3612@lst.de>
References: <a754067b5a8252a10a0bcfa23c4229cf3d7b1adf.1471535578.git.bcodding@redhat.com> <f50699da22fbcd977842a4fa5dd40b27295fcfcf.1471889187.git.bcodding@redhat.com> <20160919145806.GA12452@infradead.org> <8ECEF67B-FB4D-4289-A656-D98D3175B85E@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <8ECEF67B-FB4D-4289-A656-D98D3175B85E@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 19, 2016 at 03:04:52PM -0400, Benjamin Coddington wrote:
> Are you sure this patch is the problem?  I just tested and things are
> broken for me too, but I think it has something to do with the client
> choosing the block layout over SCSI now that the server is returning
> multiple layout types.

Yes, this is my local kvm test setup which only uses the block layout
for now (and doesn't even have the SCSI layout compiled in on the
server).

> Just wondering if you reverted this patch and saw the problem go away.

Yes, it does.
