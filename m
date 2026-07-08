Received: from linux.microsoft.com (linux.microsoft.com [13.77.154.182])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 6B0C73C4163;
	Wed,  8 Jul 2026 07:35:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=13.77.154.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783496142; cv=none; b=KuS3OASDc4gANJ8fTw9ZtEw+ZleRwwwfYNqRdqXJ7zafFzBdPszyZVqYkd6LEaUoXOu13YLp1cN7QMRVsRhyjvdJu4QGcjPBqVEk20u62sZhbN+kIjpN+Dq/niXnvTV+AsoiDOpTZzZXiw/CszF3FPfos/qjqzDB8t2B9a8lO2k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783496142; c=relaxed/simple;
	bh=MqE9Y8BMDYiV70tzBzAEXt6PK0XA3tgk1BxOSWXF4mE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=fl956ksxzztkwwhDHMhY+5FPzZ9rXTtz5IFG5r9HUHAAGcb4Abyp3sLui+R17wde/r60LKCAP6e8UPKfnXSVwGlVTf9Tci7mME4QQZ07Vz0dUX1T7qGowXo/FRT1mMZsUrDA0mfxZE0Q5Ye97uc00fKLLmk+JasZjZyhnMir1Vc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.microsoft.com; spf=pass smtp.mailfrom=linux.microsoft.com; dkim=pass (1024-bit key) header.d=linux.microsoft.com header.i=@linux.microsoft.com header.b=GAsgFV8/; arc=none smtp.client-ip=13.77.154.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.microsoft.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.microsoft.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.microsoft.com header.i=@linux.microsoft.com header.b="GAsgFV8/"
Received: by linux.microsoft.com (Postfix, from userid 1173)
	id 26DD120B7166; Wed,  8 Jul 2026 00:35:24 -0700 (PDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 linux.microsoft.com 26DD120B7166
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linux.microsoft.com;
	s=default; t=1783496124;
	bh=tHbyxUhrsarzNRWmvxSCy2nePku4Gzl46NyrQxhVDTU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=GAsgFV8/gFHDIknrIuM61IsHT48x6Hsbl9j5ukuVc1teGLGUh1Zt8FHbdnALVrRRY
	 RRYuc2/2EKDusilkbW6yOfVYGoTlH6EYPSgM+MQE/8aDz01mTJZKLrqSxb29uA46oC
	 h+ZVMHiTsNZT7wYzxSh5PrBsQOvtxvc8pe/JHbPQ=
Date: Wed, 8 Jul 2026 00:35:24 -0700
From: Erni Sri Satya Vennela <ernis@linux.microsoft.com>
To: Leon Romanovsky <leon@kernel.org>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, mkalderon@marvell.com,
	zyjzyj2000@gmail.com, sagi@grimberg.me, mgurtovoy@nvidia.com,
	haris.iqbal@ionos.com, jinpu.wang@ionos.com, bvanassche@acm.org,
	kbusch@kernel.org, Jens Axboe <axboe@kernel.dk>,
	Christoph Hellwig <hch@lst.de>, kch@nvidia.com, smfrench@gmail.com,
	linkinjeon@kernel.org, metze@samba.org, tom@talpey.com,
	cel@kernel.org, jlayton@kernel.org, neil@brown.name,
	okorniev@redhat.com, Dai.Ngo@oracle.com, trondmy@kernel.org,
	anna@kernel.org, achender@kernel.org, davem@davemloft.net,
	edumazet@google.com, kuba@kernel.org, pabeni@redhat.com,
	horms@kernel.org, kees@kernel.org,
	andriy.shevchenko@linux.intel.com, clm@meta.com,
	ebadger@purestorage.com, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, target-devel@vger.kernel.org,
	linux-nvme@lists.infradead.org, linux-cifs@vger.kernel.org,
	samba-technical@lists.samba.org, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	Jason Gunthorpe <jgg@nvidia.com>
Subject: Re: [PATCH rdma-next v9] RDMA: Change capability fields in
 ib_device_attr from int to u32
Message-ID: <ak39vJTvGCNJSHwi@linuxonhyperv3.guj3yctzbm1etfxqx2vob5hsef.xx.internal.cloudapp.net>
References: <20260703060329.896125-1-ernis@linux.microsoft.com>
 <20260706084950.GK15188@unreal>
 <akzS9EdxScQsx9n8@linuxonhyperv3.guj3yctzbm1etfxqx2vob5hsef.xx.internal.cloudapp.net>
 <20260707102546.GM15188@unreal>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260707102546.GM15188@unreal>

> > I originally left max_srq as int because its only consumer pairs it with
> > num_comp_vectors (a signed int) in nvmet_rdma, so keeping it int let
> > that site stay a plain min() instead of a min_t().
> > 
> > num_comp_vectors is the completion-vector count, legitimately int and
> > never anywhere near INT_MAX, so I'd prefer to leave it signed rather
> > than convert it everywhere. Does that work for you, or would you rather
> > num_comp_vectors be converted too?
> 
> In this patch no, but it is worth to write this in commit message.
> 
> Thanks

Thanks for the confirmation, Leon.

I'll use min_t for max_srq and document it in the commit message.


- Vennela
> 
> > 
> > If it needs converting, I'll do it as a separate patch, since it lives
> > in a different struct (ib_device) and touches many call sites.
> > Otherwise, using min_t() for just this one call is fine too.
> > 
> > Thanks,
> > Vennela
> > 
> > > 
> > > diff --git a/drivers/infiniband/core/nldev.c b/drivers/infiniband/core/nldev.c
> > > index f599c24b34e8..aae4f3f6bcba 100644
> > > --- a/drivers/infiniband/core/nldev.c
> > > +++ b/drivers/infiniband/core/nldev.c
> > > @@ -454,7 +454,8 @@ static int fill_res_info(struct sk_buff *msg, struct ib_device *device,
> > >         };
> > > 
> > >         struct nlattr *table_attr;
> > > -       int ret, i, curr, max;
> > > +       u64 curr, max;
> > > +       int ret, i;
> > > 
> > >         if (fill_nldev_handle(msg, device))
> > >                 return -EMSGSIZE;
> > > diff --git a/drivers/infiniband/core/restrack.c b/drivers/infiniband/core/restrack.c
> > > index cfee2071586c..1b2f9df49e28 100644
> > > --- a/drivers/infiniband/core/restrack.c
> > > +++ b/drivers/infiniband/core/restrack.c
> > > @@ -61,7 +61,7 @@ void rdma_restrack_clean(struct ib_device *dev)
> > >   * @type: actual type of object to operate
> > >   * @show_details: count driver specific objects
> > >   */
> > > -int rdma_restrack_count(struct ib_device *dev, enum rdma_restrack_type type,
> > > +u32 rdma_restrack_count(struct ib_device *dev, enum rdma_restrack_type type,
> > >                         bool show_details)
> > >  {
> > >         struct rdma_restrack_root *rt = &dev->res[type];
> > > diff --git a/include/rdma/restrack.h b/include/rdma/restrack.h
> > > index 451f99e3717d..c081384740ce 100644
> > > --- a/include/rdma/restrack.h
> > > +++ b/include/rdma/restrack.h
> > > @@ -123,7 +123,7 @@ struct rdma_restrack_entry {
> > >         u32 id;
> > >  };
> > > 
> > > -int rdma_restrack_count(struct ib_device *dev, enum rdma_restrack_type type,
> > > +u32 rdma_restrack_count(struct ib_device *dev, enum rdma_restrack_type type,
> > >                         bool show_details);
> > >  /**
> > >   * rdma_is_kernel_res() - check the owner of resource
