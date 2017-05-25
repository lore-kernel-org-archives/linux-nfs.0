Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59142 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1030309AbdEYSsz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 May 2017 14:48:55 -0400
Date: Thu, 25 May 2017 14:48:51 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Bart Van Assche <bart.vanassche@sandisk.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org,
        Christoph Hellwig <hch@lst.de>,
        Jeff Layton <jlayton@poochiereds.net>,
        Jens Axboe <axboe@fb.com>, Omar Sandoval <osandov@fb.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 06/19] nfsd: Check private request size before submitting
 a SCSI request
Message-ID: <20170525184851.GD4298@fieldses.org>
References: <20170525184327.23570-1-bart.vanassche@sandisk.com>
 <20170525184327.23570-7-bart.vanassche@sandisk.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170525184327.23570-7-bart.vanassche@sandisk.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 25, 2017 at 11:43:14AM -0700, Bart Van Assche wrote:
> Since using scsi_req() is only allowed against request queues for
> which struct scsi_request is the first member of their private
> request data, refuse to submit SCSI commands against a queue for
> which this is not the case.

Is it possible we could catch this earlier and avoid giving out the
layout in the first place?

--b.

> 
> References: commit 82ed4db499b8 ("block: split scsi_request out of struct request")
> Signed-off-by: Bart Van Assche <bart.vanassche@sandisk.com>
> Reviewed-by: Hannes Reinecke <hare@suse.com>
> Cc: J. Bruce Fields <bfields@fieldses.org>
> Cc: Jeff Layton <jlayton@poochiereds.net>
> Cc: Jens Axboe <axboe@fb.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Omar Sandoval <osandov@fb.com>
> Cc: linux-nfs@vger.kernel.org
> Cc: linux-block@vger.kernel.org
> ---
>  fs/nfsd/blocklayout.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
> index fb5213afc854..38e14cf7e74a 100644
> --- a/fs/nfsd/blocklayout.c
> +++ b/fs/nfsd/blocklayout.c
> @@ -219,6 +219,9 @@ static int nfsd4_scsi_identify_device(struct block_device *bdev,
>  	u8 *buf, *d, type, assoc;
>  	int error;
>  
> +	if (WARN_ON_ONCE(!blk_queue_scsi_pdu(q)))
> +		return -EINVAL;
> +
>  	buf = kzalloc(bufflen, GFP_KERNEL);
>  	if (!buf)
>  		return -ENOMEM;
> -- 
> 2.12.2
