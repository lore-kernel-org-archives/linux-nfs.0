Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54914 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965300AbeEJOQv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 10 May 2018 10:16:51 -0400
Date: Thu, 10 May 2018 10:16:51 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Scott Mayhew <smayhew@redhat.com>
Cc: jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: make nfsd4_scsi_identify_device retry with a
 larger buffer
Message-ID: <20180510141651.GA29678@fieldses.org>
References: <20180507130131.7221-1-smayhew@redhat.com>
 <20180507184520.GF4749@fieldses.org>
 <20180507201740.4m6rff36bjuuv55t@tonberry.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180507201740.4m6rff36bjuuv55t@tonberry.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 07, 2018 at 04:17:40PM -0400, Scott Mayhew wrote:
> On Mon, 07 May 2018, J. Bruce Fields wrote:
> 
> > On Mon, May 07, 2018 at 09:01:31AM -0400, Scott Mayhew wrote:
> > > nfsd4_scsi_identify_device() performs a single IDENTIFY command for the
> > > device identification VPD page using a small buffer.  If the reply is
> > > too large to fit in this buffer then the GETDEVICEINFO reply will not
> > > contain any info for the SCSI volume aside from the registration key.
> > > This can happen for example if the device has descriptors using long
> > > SCSI name strings.
> > > 
> > > When the initial reply from the device indicates a larger buffer is
> > > needed, retry once using the page length from that reply.
> > 
> > Looks good, but how did you choose 65532 as the maximum?  Does the scsi
> > layer give us any maximum?
> 
> So I wasn't quite sure about that.  The allocation length field for an
> INQUIRY command is two bytes.  There are various fields that the SPC-3
> doc says have to be a multiple of 4, but I couldn't find anything that
> says whether that applies to the allocation length.  Since the initial
> value 252 is a muliple of 4, I figured it wouldn't hurt anything to have
> the maximum be a multiple of 4 too.
> 
> OTOH if you look at scsi_get_vpd_buf() in drivers/scsi/scsi.c, the
> initial buffer size is SCSI_VPD_PG_LEN, which is 255.

OK.  Well, till we have some input from a scsi expert, would you mind
just adding a brief summary of the above as a code comment?

--b.

> 
> -Scott
> 
> > 
> > Also, I don't know why this is bothering me, but: I'd prefer "buflen" to
> > "bufflen".
> > 
> > --b.
> > 
> > > 
> > > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > > ---
> > >  fs/nfsd/blocklayout.c | 18 +++++++++++++-----
> > >  1 file changed, 13 insertions(+), 5 deletions(-)
> > > 
> > > diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
> > > index 70b8bf7..0cd9249 100644
> > > --- a/fs/nfsd/blocklayout.c
> > > +++ b/fs/nfsd/blocklayout.c
> > > @@ -216,13 +216,14 @@ static int nfsd4_scsi_identify_device(struct block_device *bdev,
> > >  	struct request_queue *q = bdev->bd_disk->queue;
> > >  	struct request *rq;
> > >  	struct scsi_request *req;
> > > -	size_t bufflen = 252, len, id_len;
> > > +	size_t bufflen = 252, maxlen = 65532, len, id_len;
> > >  	u8 *buf, *d, type, assoc;
> > > -	int error;
> > > +	int retries = 1, error;
> > >  
> > >  	if (WARN_ON_ONCE(!blk_queue_scsi_passthrough(q)))
> > >  		return -EINVAL;
> > >  
> > > +again:
> > >  	buf = kzalloc(bufflen, GFP_KERNEL);
> > >  	if (!buf)
> > >  		return -ENOMEM;
> > > @@ -255,9 +256,16 @@ static int nfsd4_scsi_identify_device(struct block_device *bdev,
> > >  
> > >  	len = (buf[2] << 8) + buf[3] + 4;
> > >  	if (len > bufflen) {
> > > -		pr_err("pNFS: INQUIRY 0x83 response invalid (len = %zd)\n",
> > > -			len);
> > > -		goto out_put_request;
> > > +		if (len < maxlen && retries--) {
> > > +			blk_put_request(rq);
> > > +			kfree(buf);
> > > +			bufflen = len;
> > > +			goto again;
> > > +		} else {
> > > +			pr_err("pNFS: INQUIRY 0x83 response invalid (len = %zd)\n",
> > > +				len);
> > > +			goto out_put_request;
> > > +		}
> > >  	}
> > >  
> > >  	d = buf + 4;
> > > -- 
> > > 2.9.5
