Received: from linux.microsoft.com (linux.microsoft.com [13.77.154.182])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 3851D2309AA;
	Sat,  6 Jun 2026 07:01:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=13.77.154.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780729291; cv=none; b=VDSjR0qszphfqDqZfPn/wXNORYubVUzbNcBRhneu9e7KH3e0t8nmIZILR7nePnbIoSRNAe8t9VwbXz3B63TK/ucZg2wsVeWTTwJLwgqJczI9+616DsfBAx1boLGIG/I1c+h+x6hBXoLMRbZarff3Hsjrk1/gZEiSj7NvC+fHSOY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780729291; c=relaxed/simple;
	bh=50E34gE5VHddO0NTCTLmIghu1TtNR4sFpaf2gC/8Pak=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=EAiaQy+/1iQoTgPKGdpZas4YMG062Bi6syAamX6+PhPS1iOJb2iGVoWoGudVTXD4q3vN9RpGd2bsq55Zuyv8cjMpcWmtqsN0lb1lRmUcONfSFdlR77noyB+U8SYmalo9xcA7nY52N/fQyi3TCfs8O4DTSIkY1LcfZvKtyE0qtxY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.microsoft.com; spf=pass smtp.mailfrom=linux.microsoft.com; dkim=pass (1024-bit key) header.d=linux.microsoft.com header.i=@linux.microsoft.com header.b=lfiYLgAy; arc=none smtp.client-ip=13.77.154.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.microsoft.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.microsoft.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.microsoft.com header.i=@linux.microsoft.com header.b="lfiYLgAy"
Received: by linux.microsoft.com (Postfix, from userid 1173)
	id 36F9220B7168; Sat,  6 Jun 2026 00:01:14 -0700 (PDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 linux.microsoft.com 36F9220B7168
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linux.microsoft.com;
	s=default; t=1780729274;
	bh=cMzcioYuB6Di79ZAvhskrIxXkdQtLzFhYkxDW4jk4RA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=lfiYLgAyM5X/Pp8g7mBNzlfTZuGrIEceOzfPeiO/YB1r6+Ng/0LarUrvfKUDmqic6
	 1yqjSp4BBat3h2X0imFMfW3HbOFJ3MP7LYUm2rV90O1SlNLucv3fblEEH+a83yxxU3
	 tC0IfjxdahYBZIqi0Rl7RSFPogCClEYIOy+uUBRM=
Date: Sat, 6 Jun 2026 00:01:14 -0700
From: Erni Sri Satya Vennela <ernis@linux.microsoft.com>
To: David Laight <david.laight.linux@gmail.com>
Cc: mkalderon@marvell.com, Jason Gunthorpe <jgg@ziepe.ca>,
	Leon Romanovsky <leon@kernel.org>, zyjzyj2000@gmail.com,
	sagi@grimberg.me, mgurtovoy@nvidia.com, haris.iqbal@ionos.com,
	jinpu.wang@ionos.com, bvanassche@acm.org, kbusch@kernel.org,
	Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>,
	kch@nvidia.com, smfrench@gmail.com, linkinjeon@kernel.org,
	metze@samba.org, tom@talpey.com, chuck.lever@oracle.com,
	jlayton@kernel.org, neil@brown.name, okorniev@redhat.com,
	Dai.Ngo@oracle.com, trondmy@kernel.org, anna@kernel.org,
	achender@kernel.org, davem@davemloft.net, edumazet@google.com,
	kuba@kernel.org, pabeni@redhat.com, horms@kernel.org,
	kees@kernel.org, andriy.shevchenko@linux.intel.com,
	ebadger@purestorage.com, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, target-devel@vger.kernel.org,
	linux-nvme@lists.infradead.org, linux-cifs@vger.kernel.org,
	samba-technical@lists.samba.org, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	Jason Gunthorpe <jgg@nvidia.com>
Subject: Re: [PATCH rdma-next v6] RDMA: Change capability fields in
 ib_device_attr from int to u32
Message-ID: <aiPFuqrpy0gJQB73@linuxonhyperv3.guj3yctzbm1etfxqx2vob5hsef.xx.internal.cloudapp.net>
References: <20260601092534.1764560-1-ernis@linux.microsoft.com>
 <20260602123327.35aa286a@pumpkin>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260602123327.35aa286a@pumpkin>

On Tue, Jun 02, 2026 at 12:33:27PM +0100, David Laight wrote:
 > diff --git a/drivers/infiniband/ulp/rtrs/rtrs-srv.c b/drivers/infiniband/ulp/rtrs/rtrs-srv.c
> > index 6482ad859bd1..852213365ecd 100644
> > --- a/drivers/infiniband/ulp/rtrs/rtrs-srv.c
> > +++ b/drivers/infiniband/ulp/rtrs/rtrs-srv.c
> > @@ -1731,7 +1731,7 @@ static int create_con(struct rtrs_srv_path *srv_path,
> >  		 * All receive and all send (each requiring invalidate)
> >  		 * + 2 for drain and heartbeat
> >  		 */
> > -		max_send_wr = min_t(int, wr_limit,
> > +		max_send_wr = min_t(u32, wr_limit,
> >  				    SERVICE_CON_QUEUE_DEPTH * 2 + 2);
> 
> That should compile as min().
> (The constant is known to be non-negative.)

Okay, I'll update this in the next version.
> 
> ...
> > diff --git a/drivers/nvme/target/rdma.c b/drivers/nvme/target/rdma.c
> > index e6e2c3f9afdf..fd6923198ec1 100644
> > --- a/drivers/nvme/target/rdma.c
> > +++ b/drivers/nvme/target/rdma.c
> ...
> > @@ -1553,8 +1554,8 @@ static int nvmet_rdma_cm_accept(struct rdma_cm_id *cm_id,
> >  
> >  	param.rnr_retry_count = 7;
> >  	param.flow_control = 1;
> > -	param.initiator_depth = min_t(u8, p->initiator_depth,
> > -		queue->dev->device->attrs.max_qp_init_rd_atom);
> > +	param.initiator_depth = (u8)min_t(u32, p->initiator_depth,
> > +		min_t(u32, U8_MAX, queue->dev->device->attrs.max_qp_init_rd_atom));
> 
> I think you've change one of those to min_3().
> Nesting min() is a good way to bloat the pre-processor output.
> You don't need any of the casts.
> 	
> 	param.initiator_depth = min_3(p->initiator_depth,
> 		queue->dev->device->attrs.max_qp_init_rd_atom, U8_MAX);
> should be fine - if a bit long.
> 
> There are also (u32)U8_MAX casts lurking - pointless.
> 
Okay. I'll use min3 as suggested in the next version and remove
unneccesary casts.

Thanks,
Vennela
> -- David
