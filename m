Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50630 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756380AbdESTDh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 May 2017 15:03:37 -0400
Date: Fri, 19 May 2017 15:03:14 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Bart Van Assche <bart.vanassche@sandisk.com>
Cc: "Martin K . Petersen" <martin.petersen@oracle.com>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        linux-scsi@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>,
        Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@lst.de>,
        Omar Sandoval <osandov@fb.com>,
        Hannes Reinecke <hare@suse.com>, linux-nfs@vger.kernel.org,
        linux-block@vger.kernel.org
Subject: Re: [PATCH 05/18] nfsd: Check private request size before submitting
 a SCSI request
Message-ID: <20170519190314.GA25811@fieldses.org>
References: <20170519183016.12646-1-bart.vanassche@sandisk.com>
 <20170519183016.12646-6-bart.vanassche@sandisk.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170519183016.12646-6-bart.vanassche@sandisk.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ACK as far as I'm concerned.--b.

On Fri, May 19, 2017 at 11:30:03AM -0700, Bart Van Assche wrote:
> Since using scsi_req() is only allowed against request queues for which
> struct scsi_request is the first member of their private request
> data, refuse to register block layer queues for which the private
> data is smaller than struct scsi_request.
> 
> References: commit 82ed4db499b8 ("block: split scsi_request out of struct request")
> Signed-off-by: Bart Van Assche <bart.vanassche@sandisk.com>
> Cc: J. Bruce Fields <bfields@fieldses.org>
> Cc: Jeff Layton <jlayton@poochiereds.net>
> Cc: Jens Axboe <axboe@fb.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Omar Sandoval <osandov@fb.com>
> Cc: Hannes Reinecke <hare@suse.com>
> Cc: linux-nfs@vger.kernel.org
> Cc: linux-block@vger.kernel.org
> ---
>  fs/nfsd/blocklayout.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
> index fb5213afc854..90d1df31491b 100644
> --- a/fs/nfsd/blocklayout.c
> +++ b/fs/nfsd/blocklayout.c
> @@ -219,6 +219,9 @@ static int nfsd4_scsi_identify_device(struct block_device *bdev,
>  	u8 *buf, *d, type, assoc;
>  	int error;
>  
> +	if (WARN_ON_ONCE(blk_queue_cmd_size(q) < sizeof(struct scsi_request)))
> +		return -EINVAL;
> +
>  	buf = kzalloc(bufflen, GFP_KERNEL);
>  	if (!buf)
>  		return -ENOMEM;
> -- 
> 2.12.2
