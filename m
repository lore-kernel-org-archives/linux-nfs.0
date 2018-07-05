Return-Path: <hch@lst.de>
Date: Thu, 5 Jul 2018 21:40:49 +0200
From: Christoph Hellwig <hch@lst.de>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Trond Myklebust <trond.myklebust@hammerspace.com>,
	Christoph Hellwig <hch@lst.de>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	Philippe Ombredanne <pombredanne@nexb.com>,
	Benjamin Coddington <bcodding@redhat.com>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH] pnfs/blocklayout: off by one in bl_map_stripe()
Message-ID: <20180705194049.GA29032@lst.de>
References: <20180704095957.bujo2izpjlcvjanb@kili.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180704095957.bujo2izpjlcvjanb@kili.mountain>
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 04, 2018 at 12:59:58PM +0300, Dan Carpenter wrote:
> "dev->nr_children" is the number of children which were parsed
> successfully in bl_parse_stripe().  It could be all of them and then, in
> that case, it is equal to v->stripe.volumes_count.  Either way, the >
> should be >= so that we don't go beyond the end of what we're supposed
> to.
> 
> Fixes: 5c83746a0cf2 ("pnfs/blocklayout: in-kernel GETDEVICEINFO XDR parsing")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
