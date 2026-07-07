Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1909B3DEAC0;
	Tue,  7 Jul 2026 10:25:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783419958; cv=none; b=lmx2u1tXs9AWt36WgWdwDf34GRUhuMR9AbZaDH6j7YsM3mkuIp5mZknrRVJFfZp/HT/OHJMTvQlqSNVyB9Le25GeWGQtMej3Cv2OzrfgKsB/LZI0dYAmUBvbZir3zhEMDdIdUcZ9CFTiYlo/GJJZR8c0EzX1N6wklxOM4ouqR20=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783419958; c=relaxed/simple;
	bh=lavQzsFzLuud4owucqXOAe7/TStmFbzpIYigj/qMI58=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=SrCnpOr92D1RRDDAgg0ss2Qa1XPhHp4hDpQS+/o/tEBDnMTqqrxqjuUjshA7JqAAd0OgAPQtthNjpAK0K6WddrsMdSYsTB1O/v+XAPPrAih0TQ6J5tZRFse/mM5vTF1MP9e4ZRDKgxLL97E3ClNBsIgZJiAbjGQKtWs3Tusz+Wo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=H8uhI0od; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="H8uhI0od"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B8D7F1F00A3A;
	Tue,  7 Jul 2026 10:25:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783419953;
	bh=mnX0Xor/Tw8U/V1nZ7vUJbpJLhv1WXsPVIqYsN1S9JI=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=H8uhI0odf1+Nyc1vY1CAo56e01lIQRebr/i+R9T6Kt2TRVpmlVOcGQ6Im6ER4Sy/t
	 RRY9GlYhnqkRfIVTXtJSw3hSLRXgIF6Uq5Kz0sVb07aSArilOz021PEGns2rlw2r8v
	 6Pdnt/z6u0ati+bODvS9XJzgNCsrvJxU7lKZxjig+ODoqnGicqXLwJ6sJU3oxAryqq
	 32rIazm76gCZ+a4BPcXhpECSGZ2Amk22Yx57OiChxpZ73lHbx5VnjTF3K/Ulnxuhu+
	 YaAbd3UpBZ4cjSCcbIUGXQiGel3HL8yFdfM+AH2G7pDPedlo3ahuUlYqhjjSiZ+SX7
	 DO1SsLFw/wo0g==
Date: Tue, 7 Jul 2026 13:25:46 +0300
From: Leon Romanovsky <leon@kernel.org>
To: Erni Sri Satya Vennela <ernis@linux.microsoft.com>
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
Message-ID: <20260707102546.GM15188@unreal>
References: <20260703060329.896125-1-ernis@linux.microsoft.com>
 <20260706084950.GK15188@unreal>
 <akzS9EdxScQsx9n8@linuxonhyperv3.guj3yctzbm1etfxqx2vob5hsef.xx.internal.cloudapp.net>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <akzS9EdxScQsx9n8@linuxonhyperv3.guj3yctzbm1etfxqx2vob5hsef.xx.internal.cloudapp.net>

On Tue, Jul 07, 2026 at 03:20:36AM -0700, Erni Sri Satya Vennela wrote:
> On Mon, Jul 06, 2026 at 11:49:50AM +0300, Leon Romanovsky wrote:
> > > ---
> > >  drivers/infiniband/core/cq.c               |  3 +-
> > >  drivers/infiniband/hw/qedr/verbs.c         |  2 +-
> > >  drivers/infiniband/sw/rxe/rxe_qp.c         | 22 +++++-----
> > >  drivers/infiniband/sw/rxe/rxe_srq.c        | 16 +++----
> > >  drivers/infiniband/ulp/ipoib/ipoib_cm.c    | 10 ++---
> > >  drivers/infiniband/ulp/ipoib/ipoib_verbs.c |  3 +-
> > >  drivers/infiniband/ulp/iser/iser_verbs.c   |  5 +--
> > >  drivers/infiniband/ulp/isert/ib_isert.c    |  7 ++-
> > >  drivers/infiniband/ulp/rtrs/rtrs-clt.c     | 11 ++---
> > >  drivers/infiniband/ulp/rtrs/rtrs-srv.c     | 11 ++---
> > >  drivers/infiniband/ulp/srp/ib_srp.c        |  2 +-
> > >  drivers/infiniband/ulp/srpt/ib_srpt.c      | 21 +++++----
> > >  drivers/nvme/host/rdma.c                   |  8 ++--
> > >  drivers/nvme/target/rdma.c                 | 22 ++++++----
> > >  fs/smb/smbdirect/accept.c                  |  5 ++-
> > >  fs/smb/smbdirect/connect.c                 |  5 ++-
> > >  fs/smb/smbdirect/connection.c              |  8 ++--
> > >  include/linux/sunrpc/svc_rdma.h            |  4 +-
> > >  include/rdma/ib_verbs.h                    | 50 +++++++++++-----------
> > >  net/rds/ib.c                               | 10 ++---
> > >  net/rds/ib_cm.c                            | 10 ++---
> > >  net/sunrpc/xprtrdma/frwr_ops.c             |  7 +--
> > >  net/sunrpc/xprtrdma/svc_rdma_transport.c   |  5 +--
> > >  net/sunrpc/xprtrdma/verbs.c                |  2 +-
> > >  24 files changed, 122 insertions(+), 127 deletions(-)
> > 
> > The following code is still missing. 
> 
> I'll make this change in the next version.
> 
> >Also, what about mxa_srq?
> > Why wasn't it converted as well?
> 
> I originally left max_srq as int because its only consumer pairs it with
> num_comp_vectors (a signed int) in nvmet_rdma, so keeping it int let
> that site stay a plain min() instead of a min_t().
> 
> num_comp_vectors is the completion-vector count, legitimately int and
> never anywhere near INT_MAX, so I'd prefer to leave it signed rather
> than convert it everywhere. Does that work for you, or would you rather
> num_comp_vectors be converted too?

In this patch no, but it is worth to write this in commit message.

Thanks

> 
> If it needs converting, I'll do it as a separate patch, since it lives
> in a different struct (ib_device) and touches many call sites.
> Otherwise, using min_t() for just this one call is fine too.
> 
> Thanks,
> Vennela
> 
> > 
> > diff --git a/drivers/infiniband/core/nldev.c b/drivers/infiniband/core/nldev.c
> > index f599c24b34e8..aae4f3f6bcba 100644
> > --- a/drivers/infiniband/core/nldev.c
> > +++ b/drivers/infiniband/core/nldev.c
> > @@ -454,7 +454,8 @@ static int fill_res_info(struct sk_buff *msg, struct ib_device *device,
> >         };
> > 
> >         struct nlattr *table_attr;
> > -       int ret, i, curr, max;
> > +       u64 curr, max;
> > +       int ret, i;
> > 
> >         if (fill_nldev_handle(msg, device))
> >                 return -EMSGSIZE;
> > diff --git a/drivers/infiniband/core/restrack.c b/drivers/infiniband/core/restrack.c
> > index cfee2071586c..1b2f9df49e28 100644
> > --- a/drivers/infiniband/core/restrack.c
> > +++ b/drivers/infiniband/core/restrack.c
> > @@ -61,7 +61,7 @@ void rdma_restrack_clean(struct ib_device *dev)
> >   * @type: actual type of object to operate
> >   * @show_details: count driver specific objects
> >   */
> > -int rdma_restrack_count(struct ib_device *dev, enum rdma_restrack_type type,
> > +u32 rdma_restrack_count(struct ib_device *dev, enum rdma_restrack_type type,
> >                         bool show_details)
> >  {
> >         struct rdma_restrack_root *rt = &dev->res[type];
> > diff --git a/include/rdma/restrack.h b/include/rdma/restrack.h
> > index 451f99e3717d..c081384740ce 100644
> > --- a/include/rdma/restrack.h
> > +++ b/include/rdma/restrack.h
> > @@ -123,7 +123,7 @@ struct rdma_restrack_entry {
> >         u32 id;
> >  };
> > 
> > -int rdma_restrack_count(struct ib_device *dev, enum rdma_restrack_type type,
> > +u32 rdma_restrack_count(struct ib_device *dev, enum rdma_restrack_type type,
> >                         bool show_details);
> >  /**
> >   * rdma_is_kernel_res() - check the owner of resource
