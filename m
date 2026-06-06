Received: from linux.microsoft.com (linux.microsoft.com [13.77.154.182])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 0CDDC1C5F27;
	Sat,  6 Jun 2026 06:49:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=13.77.154.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780728571; cv=none; b=uy6plivLFMlwFHlz6SiDU9pHgN1J3Vnr6RDoqUc/fnDhbRPs3YHgefmzJqcnHaWjJ4QgbTEo8G9MiUFbGRf7BaZb9lxXdOgGrtv1D6ohtECQqLQzO5gpLOFpnpwTiqg90bpoWmUpN1KdSH1Wt9M6pqe7z0AslkmazpDhAr9tWzU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780728571; c=relaxed/simple;
	bh=v/QSH7vXxFyl8DBtESUMMrk/OujChMwxFbvwK5HyuUc=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=FuF4NgmBoQ7vtNSy8IWU6DscDho7Vd7m0rodKHLSNQQt9rQOS5SJxs2gi3I1BsCZaaCzJXpaORLo2+LnOqPKb1qkbjob0reLGpISqUo/ooWBXvuxSte3qu9axoEhu1cODXtgRkNW7k605PmflB04qAjQfXnX5amU0i/HqLIUUzM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.microsoft.com; spf=pass smtp.mailfrom=linux.microsoft.com; dkim=pass (1024-bit key) header.d=linux.microsoft.com header.i=@linux.microsoft.com header.b=fN1/ZLAw; arc=none smtp.client-ip=13.77.154.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.microsoft.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.microsoft.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.microsoft.com header.i=@linux.microsoft.com header.b="fN1/ZLAw"
Received: by linux.microsoft.com (Postfix, from userid 1173)
	id 4B9E620B7168; Fri,  5 Jun 2026 23:49:14 -0700 (PDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 linux.microsoft.com 4B9E620B7168
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linux.microsoft.com;
	s=default; t=1780728554;
	bh=jsHAuFj8qDrb/asd6/0OdPIBZRNfzb9n3bx0A4hh4+Q=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=fN1/ZLAwCc6QU6vEstgU4YpQ182PQpaT+lXfZXLnZSKIWWsInznamLl/Gq7Re790Z
	 6GTjnvrIrWM4o47gTCHOZFz9dWKG9NvabDco+iGUoZavh7ctRRh5lVeutFBYfVyrfg
	 /UZXQZqC1j8TikWl0+urTqePdP59dOTmYl/zXFG0=
Date: Fri, 5 Jun 2026 23:49:14 -0700
From: Erni Sri Satya Vennela <ernis@linux.microsoft.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: mkalderon@marvell.com, Jason Gunthorpe <jgg@ziepe.ca>,
	Leon Romanovsky <leon@kernel.org>, zyjzyj2000@gmail.com,
	sagi@grimberg.me, mgurtovoy@nvidia.com, haris.iqbal@ionos.com,
	jinpu.wang@ionos.com, bvanassche@acm.org, kbusch@kernel.org,
	Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>,
	kch@nvidia.com, smfrench@gmail.com, linkinjeon@kernel.org,
	metze@samba.org, tom@talpey.com, trondmy@kernel.org,
	anna@kernel.org, chuck.lever@oracle.com, jlayton@kernel.org,
	neil@brown.name, okorniev@redhat.com, Dai.Ngo@oracle.com,
	achender@kernel.org, davem@davemloft.net, edumazet@google.com,
	kuba@kernel.org, pabeni@redhat.com, horms@kernel.org,
	kees@kernel.org, ebadger@purestorage.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	target-devel@vger.kernel.org, linux-nvme@lists.infradead.org,
	linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, Jason Gunthorpe <jgg@nvidia.com>
Subject: Re: [PATCH net-next v5] RDMA: Change capability fields in
 ib_device_attr from int to u32
Message-ID: <aiPC6vQC7ICmD7q8@linuxonhyperv3.guj3yctzbm1etfxqx2vob5hsef.xx.internal.cloudapp.net>
References: <20260601091505.1763912-1-ernis@linux.microsoft.com>
 <ah6gWPQP56RO6_ho@ashevche-desk.local>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ah6gWPQP56RO6_ho@ashevche-desk.local>

On Tue, Jun 02, 2026 at 12:20:24PM +0300, Andy Shevchenko wrote:
> On Mon, Jun 01, 2026 at 02:14:44AM -0700, Erni Sri Satya Vennela wrote:
> > The capability counter fields in struct ib_device_attr are declared
> > as signed int, but these values are inherently non-negative. Drivers
> > maintain their cached caps as u32 and assign them directly into these
> > int fields; if a cap exceeds INT_MAX the implicit narrowing yields a
> > negative value visible to the IB core.
> > 
> > Change the signed int capability fields to u32 to match the
> > underlying nature of the data. Also update consumers across the IB
> > core, ULPs, NVMe-oF target, RDS, and NFS/RDMA so the new u32 values
> > are not forced back through signed int or u8 via min()/min_t() or
> > narrowing local variables.
> 
> ...
> 
> >  	attr->max_qp_rd_atom =
> > -	    min(1 << (fls(qattr->max_qp_resp_rd_atomic_resc) - 1),
> > -		attr->max_qp_init_rd_atom);
> > +	    min_t(u32, 1 << (fls(qattr->max_qp_resp_rd_atomic_resc) - 1),
> > +		  attr->max_qp_init_rd_atom);
> 
> Just no. min_t() usage has to be very well justified. It's a beast which may
> stub one in the back. As Linus said in most of the cases one wants clamp()
> rather than min().
> 
> Please, redo this and similar pieces.

Thankyou for the suggestion, Andy.
I'll be updating this in the next version v7.

- Vennela
> 
> -- 
> With Best Regards,
> Andy Shevchenko
> 
