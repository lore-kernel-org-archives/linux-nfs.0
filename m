Received: from linux.microsoft.com (linux.microsoft.com [13.77.154.182])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 3CF9F35F5ED;
	Fri,  3 Jul 2026 05:59:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=13.77.154.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783058357; cv=none; b=H3HigKQAtSD5vAKgtCgL/DRChFAVTEnmcJhgQdcbl/jzEMcSGfBfphigx5vvOLZ7bSVgqnPDiXnMtV/YvddPpR0qMaRFPn2d/j08ecZ6vMnAmIO3aHvGxqM+s5txh/epbq6Q+pqKiHZ73l0gANlbjKVVXlJUxrT5uoCm3z8gqpA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783058357; c=relaxed/simple;
	bh=gC0f4IpEEmutBRidcW3TU9mOjFrozAoFQinDjEihXLk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=M4Vtf1yYJbP4i6KFcINn2kkIWgFALCNi0cbopTLtDCMQ7fDIZbdd4w4cZRMmG0yv4ECvLvPfpnjmDXUlWS1c0ioqH5wFiXl9TCkIWObLbu378IuPlBLRbnoz5q+BlpWgMxs0lixsiaPeiqfAuhV1UGfYoO8EHNuSCSgi3UzQEbo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.microsoft.com; spf=pass smtp.mailfrom=linux.microsoft.com; dkim=pass (1024-bit key) header.d=linux.microsoft.com header.i=@linux.microsoft.com header.b=nK7H1bsT; arc=none smtp.client-ip=13.77.154.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.microsoft.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.microsoft.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.microsoft.com header.i=@linux.microsoft.com header.b="nK7H1bsT"
Received: by linux.microsoft.com (Postfix, from userid 1173)
	id EAEDD20B716C; Thu,  2 Jul 2026 22:59:07 -0700 (PDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 linux.microsoft.com EAEDD20B716C
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linux.microsoft.com;
	s=default; t=1783058347;
	bh=YiywiaC4VnDfvSGNTu0J2NjCWbP9RvWAv+silBhR3io=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=nK7H1bsTOvgTzOeO8031IWUUbWeDCb8M0VGxhZhfYl8l9O0m9T3ckRukJcIUBWmxy
	 0i2ZRCut3ROW/57Ckt/bRf4ZENFlE1EtJSj6JUTLvObYyintLzJbwLMFZQqZz/40l9
	 czKWP2W6o19LfU9ENtVCjFPn2ZhljOJtjNn/MafA=
Date: Thu, 2 Jul 2026 22:59:07 -0700
From: Erni Sri Satya Vennela <ernis@linux.microsoft.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Leon Romanovsky <leon@kernel.org>,
	mkalderon@marvell.com, zyjzyj2000@gmail.com, sagi@grimberg.me,
	mgurtovoy@nvidia.com, haris.iqbal@ionos.com, jinpu.wang@ionos.com,
	bvanassche@acm.org, kbusch@kernel.org, Jens Axboe <axboe@kernel.dk>,
	Christoph Hellwig <hch@lst.de>, kch@nvidia.com, smfrench@gmail.com,
	linkinjeon@kernel.org, metze@samba.org, tom@talpey.com,
	trondmy@kernel.org, anna@kernel.org, chuck.lever@oracle.com,
	jlayton@kernel.org, neil@brown.name, okorniev@redhat.com,
	Dai.Ngo@oracle.com, achender@kernel.org, davem@davemloft.net,
	edumazet@google.com, kuba@kernel.org, pabeni@redhat.com,
	horms@kernel.org, kees@kernel.org, markzhang@nvidia.com,
	ebadger@purestorage.com, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, target-devel@vger.kernel.org,
	linux-nvme@lists.infradead.org, linux-cifs@vger.kernel.org,
	samba-technical@lists.samba.org, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	Jason Gunthorpe <jgg@nvidia.com>
Subject: Re: [PATCH rdma-next v8] RDMA: Change capability fields in
 ib_device_attr from int to u32
Message-ID: <akdPqz9L8/IPLqml@linuxonhyperv3.guj3yctzbm1etfxqx2vob5hsef.xx.internal.cloudapp.net>
References: <20260619203107.606359-1-ernis@linux.microsoft.com>
 <akX/P/0TiSQ38YdS@linuxonhyperv3.guj3yctzbm1etfxqx2vob5hsef.xx.internal.cloudapp.net>
 <akYocsiHWdH8Tncq@ashevche-desk.local>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <akYocsiHWdH8Tncq@ashevche-desk.local>

On Thu, Jul 02, 2026 at 11:59:30AM +0300, Andy Shevchenko wrote:
> On Wed, Jul 01, 2026 at 11:03:43PM -0700, Erni Sri Satya Vennela wrote:
> > On Fri, Jun 19, 2026 at 01:30:39PM -0700, Erni Sri Satya Vennela wrote:
> > > The capability counter fields in struct ib_device_attr are declared
> > > as signed int, but these values are inherently non-negative. Drivers
> > > maintain their cached caps as u32 and assign them directly into these
> > > int fields; if a cap exceeds INT_MAX the implicit narrowing yields a
> > > negative value visible to the IB core.
> > > 
> > > Change the signed int capability fields to u32 to match the
> > > underlying nature of the data. Also update consumers across the IB
> > > core, ULPs, NVMe-oF target, RDS, and NFS/RDMA so the new u32 values
> > > are not forced back through signed int or u8 via min()/min_t() or
> > > narrowing local variables.
> > 
> > Just a friendly follow-up on this patch. The Sashiko review mentioned a
> > low-priority item, and I'd appreciate any guidance on whether the change
> > is needed.
> 
> As I read this it needs to be fixed, the problem is that there is
> a potential of a weird case (not sure they are IRL) when somebody can use
> INT_MIN (in representation of signed number) to actually mean 0x80000000
> size.
> 
> > https://sashiko.dev/#/patchset/20260619203107.606359-1-ernis%40linux.microsoft.com
> 
> -- 
> With Best Regards,
> Andy Shevchenko
> 
Thankyou for the confirmation, Andy.
I'll add this change in the next version.

- Vennela
