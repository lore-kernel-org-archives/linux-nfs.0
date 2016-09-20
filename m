Return-Path: <BATV+5b76f26bb9fb8bbdf5ea+4776+infradead.org+hch@bombadil.srs.infradead.org>
Date: Tue, 20 Sep 2016 09:38:13 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] pnfs/blocklayout: last_write_offset incorrectly set to
 end of extent
Message-ID: <20160920163813.GA7005@infradead.org>
References: <a754067b5a8252a10a0bcfa23c4229cf3d7b1adf.1471535578.git.bcodding@redhat.com>
 <f50699da22fbcd977842a4fa5dd40b27295fcfcf.1471889187.git.bcodding@redhat.com>
 <20160919145806.GA12452@infradead.org>
 <8ECEF67B-FB4D-4289-A656-D98D3175B85E@redhat.com>
 <20160919190610.GA3612@lst.de>
 <9FD74439-878E-464E-9334-5F6782145248@redhat.com>
 <ffe9a2cc97ead5b73b985aa4c16219351cac29d5.1474372904.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <ffe9a2cc97ead5b73b985aa4c16219351cac29d5.1474372904.git.bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

This seems to fix the corruption issues.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Tested-by: Christoph Hellwig <hch@lst.de>
