Received: from mgamail.intel.com (mgamail.intel.com [192.198.163.15])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DE83E367F2F;
	Thu,  2 Jul 2026 08:59:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=192.198.163.15
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782982784; cv=none; b=OYKgmPGTF547KWv3W5YWpO3p8Tf2G0eh/e/SEQJKYcQn+lDWq5Fq4SGSQwfsYNLtnFn95DcpoLGaWlkwRuL/b+6zLJbobAesc1bRfLJQ5T2FK5AcuzVSP1ufwcrF+U7iTuHrxeNzNndscc8r7u2B+W649eIqxHVmLjl4WE1Ph2o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782982784; c=relaxed/simple;
	bh=gYLTkBsJEUClTNfXhPkNzHUVAl7MUmlSeasGQSngDn4=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=QMtUccKUjg3wG6mjtj3n7KEo2ZYvC9VLCf1mXLOcJDw9kbjzDuimkHuxFhihn70SCr77COjdZKOwA62hwgfiutFE61w4aOv+zjgyCMxIq61OJ6QBtc61oIxlNd0HzFODYkh3bbXHY8PldtBWWhY6B4vHdODEWIgo1Kac/x5foRA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com; spf=pass smtp.mailfrom=linux.intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=PisJ7vjl; arc=none smtp.client-ip=192.198.163.15
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="PisJ7vjl"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1782982783; x=1814518783;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=gYLTkBsJEUClTNfXhPkNzHUVAl7MUmlSeasGQSngDn4=;
  b=PisJ7vjlwiWLBlSkdnkDw6wV3LlsKjYcdxuDEpLY8EoFIzK4QVMb4k73
   zr5Ir3cjijjjjqk47iNDCsSDg0Dc5LJBETMUOH0mxLmikcR9e8kGUrDqI
   7T3LSSZl6Wrgg5mOGckHamKxZOxybMktX0ASzthPp8+Rg+rCeQkzspxp/
   ON43gWsZhAVYCk4ZHXLyxTmD4O9x/F+J3vHgbeOzcI4lKxdjJhTPNvoY+
   Uss7++GvmPdS6T4Vm/XSyLRvEg1K1tBIlogqQX8OYf6u7J6t9Q46/Te1O
   6JmnPlRXhu3zceWEWN2i1ZPiNyaNDXbDxvSjD8jZK4S2lfR6w6zphY6Gc
   A==;
X-CSE-ConnectionGUID: YQKrb66CQyC3o2SSeLGkcA==
X-CSE-MsgGUID: 6+t08cZhSYutIJKE6GHvNQ==
X-IronPort-AV: E=McAfee;i="6800,10657,11834"; a="83861764"
X-IronPort-AV: E=Sophos;i="6.25,143,1779174000"; 
   d="scan'208";a="83861764"
Received: from orviesa005.jf.intel.com ([10.64.159.145])
  by fmvoesa109.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 02 Jul 2026 01:59:42 -0700
X-CSE-ConnectionGUID: YjT0r9y3SOWMz/XZRomMBw==
X-CSE-MsgGUID: ZStAWpo+QtOOnZ714iy4cA==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.25,143,1779174000"; 
   d="scan'208";a="257146674"
Received: from ettammin-mobl3.ger.corp.intel.com (HELO localhost) ([10.245.244.213])
  by orviesa005-auth.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 02 Jul 2026 01:59:33 -0700
Date: Thu, 2 Jul 2026 11:59:30 +0300
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Erni Sri Satya Vennela <ernis@linux.microsoft.com>
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
Message-ID: <akYocsiHWdH8Tncq@ashevche-desk.local>
References: <20260619203107.606359-1-ernis@linux.microsoft.com>
 <akX/P/0TiSQ38YdS@linuxonhyperv3.guj3yctzbm1etfxqx2vob5hsef.xx.internal.cloudapp.net>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <akX/P/0TiSQ38YdS@linuxonhyperv3.guj3yctzbm1etfxqx2vob5hsef.xx.internal.cloudapp.net>
Organization: Intel Finland Oy - BIC 0357606-4 - c/o Alberga Business Park, 6
 krs, Bertel Jungin Aukio 5, 02600 Espoo

On Wed, Jul 01, 2026 at 11:03:43PM -0700, Erni Sri Satya Vennela wrote:
> On Fri, Jun 19, 2026 at 01:30:39PM -0700, Erni Sri Satya Vennela wrote:
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
> Just a friendly follow-up on this patch. The Sashiko review mentioned a
> low-priority item, and I'd appreciate any guidance on whether the change
> is needed.

As I read this it needs to be fixed, the problem is that there is
a potential of a weird case (not sure they are IRL) when somebody can use
INT_MIN (in representation of signed number) to actually mean 0x80000000
size.

> https://sashiko.dev/#/patchset/20260619203107.606359-1-ernis%40linux.microsoft.com

-- 
With Best Regards,
Andy Shevchenko


