Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.133]:46822 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752745AbeEKIHC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 11 May 2018 04:07:02 -0400
Date: Fri, 11 May 2018 01:06:59 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Scott Mayhew <smayhew@redhat.com>
Cc: bfields@fieldses.org, jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: make nfsd4_scsi_identify_device retry with a
 larger buffer
Message-ID: <20180511080659.GA6345@infradead.org>
References: <20180510204929.24328-1-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180510204929.24328-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 10, 2018 at 04:49:29PM -0400, Scott Mayhew wrote:
> nfsd4_scsi_identify_device() performs a single IDENTIFY command for the
> device identification VPD page using a small buffer.  If the reply is
> too large to fit in this buffer then the GETDEVICEINFO reply will not
> contain any info for the SCSI volume aside from the registration key.
> This can happen for example if the device has descriptors using long
> SCSI name strings.
> 
> When the initial reply from the device indicates a larger buffer is
> needed, retry once using the page length from that reply.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  fs/nfsd/blocklayout.c | 25 ++++++++++++++++++++-----
>  1 file changed, 20 insertions(+), 5 deletions(-)
> 
> Changes since v1:
> - added comment explaining the initial and max buffer lengths
> - changed the len-to-maxlen comparison from "<" to "<="
> 
> diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
> index 70b8bf7..aa1c6f9 100644
> --- a/fs/nfsd/blocklayout.c
> +++ b/fs/nfsd/blocklayout.c
> @@ -216,13 +216,21 @@ static int nfsd4_scsi_identify_device(struct block_device *bdev,
>  	struct request_queue *q = bdev->bd_disk->queue;
>  	struct request *rq;
>  	struct scsi_request *req;
> -	size_t bufflen = 252, len, id_len;
> +	/*
> +	 * The allocation length (passed in bytes 3 and 4 of the INQUIRY
> +	 * command descriptor block) specifies the number of bytes that have
> +	 * been allocated for the data-in buffer.
> +	 * 252 is the highest one-byte value that is a multiple of 4.
> +	 * 65532 is the highest two-byte value that is a multiple of 4.
> +	 */
> +	size_t bufflen = 252, maxlen = 65532, len, id_len;
>  	u8 *buf, *d, type, assoc;
> -	int error;
> +	int retries = 1, error;
>  
>  	if (WARN_ON_ONCE(!blk_queue_scsi_passthrough(q)))
>  		return -EINVAL;
>  
> +again:
>  	buf = kzalloc(bufflen, GFP_KERNEL);
>  	if (!buf)
>  		return -ENOMEM;
> @@ -255,9 +263,16 @@ static int nfsd4_scsi_identify_device(struct block_device *bdev,
>  
>  	len = (buf[2] << 8) + buf[3] + 4;
>  	if (len > bufflen) {
> -		pr_err("pNFS: INQUIRY 0x83 response invalid (len = %zd)\n",
> -			len);
> -		goto out_put_request;
> +		if (len <= maxlen && retries--) {
> +			blk_put_request(rq);
> +			kfree(buf);
> +			bufflen = len;
> +			goto again;
> +		} else {
> +			pr_err("pNFS: INQUIRY 0x83 response invalid (len = %zd)\n",
> +				len);
> +			goto out_put_request;

No need for an else after a goto.

Otherwise looks fine:

Reviewed-by: Christoph Hellwig <hch@lst.de>
