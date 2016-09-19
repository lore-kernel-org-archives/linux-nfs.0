Return-Path: <BATV+c607ca0c23ba1afaeb0c+4775+infradead.org+hch@bombadil.srs.infradead.org>
Date: Mon, 19 Sep 2016 07:58:06 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v3] pnfs/blocklayout: update last_write_offset atomically
 with extents
Message-ID: <20160919145806.GA12452@infradead.org>
References: <a754067b5a8252a10a0bcfa23c4229cf3d7b1adf.1471535578.git.bcodding@redhat.com>
 <f50699da22fbcd977842a4fa5dd40b27295fcfcf.1471889187.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <f50699da22fbcd977842a4fa5dd40b27295fcfcf.1471889187.git.bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

So it looks like this patch go in, but when I did my usually NFS
regression tests that I stopped for a few weeks aover the summer it
broke down badly: all the fsx and some other data integrity tests now
fail in xfstests over pNFS blocklayout.

Given how close it is to 4.8-final can we revert it for now?
