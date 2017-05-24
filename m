Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57970 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S966308AbdEXGCw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 24 May 2017 02:02:52 -0400
Subject: Re: [PATCH 15/31] nfsd: Check private request size before submitting
 a SCSI request
To: Bart Van Assche <bart.vanassche@sandisk.com>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: linux-scsi@vger.kernel.org, linux-block@vger.kernel.org,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@lst.de>,
        Omar Sandoval <osandov@fb.com>,
        Hannes Reinecke <hare@suse.com>, linux-nfs@vger.kernel.org
References: <20170524003420.5381-1-bart.vanassche@sandisk.com>
 <20170524003420.5381-16-bart.vanassche@sandisk.com>
From: Hannes Reinecke <hare@suse.de>
Message-ID: <ea6d2932-4ae8-5561-763b-628bd4e8429a@suse.de>
Date: Wed, 24 May 2017 08:02:49 +0200
MIME-Version: 1.0
In-Reply-To: <20170524003420.5381-16-bart.vanassche@sandisk.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/24/2017 02:34 AM, Bart Van Assche wrote:
> Since using scsi_req() is only allowed against request queues for
> which struct scsi_request is the first member of their private
> request data, refuse to submit SCSI commands against a queue for
> which this is not the case.
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
> index fb5213afc854..9ca0ca5efbc8 100644
> --- a/fs/nfsd/blocklayout.c
> +++ b/fs/nfsd/blocklayout.c
> @@ -219,6 +219,9 @@ static int nfsd4_scsi_identify_device(struct block_device *bdev,
>  	u8 *buf, *d, type, assoc;
>  	int error;
>  
> +	if (WARN_ON_ONCE(!blk_queue_scsi_sup(q)))
> +		return -EINVAL;
> +
>  	buf = kzalloc(bufflen, GFP_KERNEL);
>  	if (!buf)
>  		return -ENOMEM;
> 
Reviewed-by: Hannes Reinecke <hare@suse.com>

Cheers,

Hannes
-- 
Dr. Hannes Reinecke		   Teamlead Storage & Networking
hare@suse.de			               +49 911 74053 688
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nürnberg
GF: F. Imendörffer, J. Smithard, J. Guild, D. Upmanyu, G. Norton
HRB 21284 (AG Nürnberg)
