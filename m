Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51368 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750952AbdFAN32 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Jun 2017 09:29:28 -0400
Date: Thu, 1 Jun 2017 09:29:27 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Bart Van Assche <bart.vanassche@sandisk.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org,
        Christoph Hellwig <hch@lst.de>,
        Jeff Layton <jlayton@poochiereds.net>,
        Omar Sandoval <osandov@fb.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 6/6] nfsd: Check queue type before submitting a SCSI
 request
Message-ID: <20170601132927.GO18523@fieldses.org>
References: <20170531214350.31157-1-bart.vanassche@sandisk.com>
 <20170531214350.31157-7-bart.vanassche@sandisk.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170531214350.31157-7-bart.vanassche@sandisk.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Feel free to add

	Acked-by: J. Bruce Fields <bfields@redhat.com>

if you need it.--b.

On Wed, May 31, 2017 at 02:43:50PM -0700, Bart Van Assche wrote:
> Since using scsi_req() is only allowed against request queues for
> which struct scsi_request is the first member of their private
> request data, refuse to submit SCSI commands against a queue for
> which this is not the case.
> 
> References: commit 82ed4db499b8 ("block: split scsi_request out of struct request")
> Signed-off-by: Bart Van Assche <bart.vanassche@sandisk.com>
> Reviewed-by: Hannes Reinecke <hare@suse.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Cc: J. Bruce Fields <bfields@fieldses.org>
> Cc: Jeff Layton <jlayton@poochiereds.net>
> Cc: Omar Sandoval <osandov@fb.com>
> Cc: linux-nfs@vger.kernel.org
> ---
>  fs/nfsd/blocklayout.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
> index fb5213afc854..47ed19c53f2e 100644
> --- a/fs/nfsd/blocklayout.c
> +++ b/fs/nfsd/blocklayout.c
> @@ -219,6 +219,9 @@ static int nfsd4_scsi_identify_device(struct block_device *bdev,
>  	u8 *buf, *d, type, assoc;
>  	int error;
>  
> +	if (WARN_ON_ONCE(!blk_queue_scsi_passthrough(q)))
> +		return -EINVAL;
> +
>  	buf = kzalloc(bufflen, GFP_KERNEL);
>  	if (!buf)
>  		return -ENOMEM;
> -- 
> 2.12.2
