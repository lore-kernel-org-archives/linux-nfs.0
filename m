Received: from mgamail.intel.com (mgamail.intel.com [192.198.163.15])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1C4FE1F2380;
	Tue,  2 Jun 2026 09:20:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=192.198.163.15
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780392037; cv=none; b=rH6OjB7qacdLN2rGhZeLi59ekrIDr+NOg8yIv0kK8X934NPsi8XNDIn54PVCq4Iu8NWskbN91HkkA8aOGvkxDD8oUqPpkv3bzdoJsjzpX2+LnHFVsXmaTsOXJCo8Tb+vfmiVI7gsbE6Cpxdh4Ub7mCD5nrcmkX2FZ0tED6L1Ug0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780392037; c=relaxed/simple;
	bh=6BQsHpGsUXg2fWEevShYArT8/T1HQSJKUOOi9RFcaco=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=D2sP/+hyb9r0Dju4J03hA3/p6pXvbaphO8RoT6NSgYSztxHRYmHsbmQw4+q4VETCh6aTmb6C/24i6OWBYJd6b6yaaTsfXkR8fX2Pe7VbCC1QmGpbgNpzwP7cG86ZoJyY19zMqXVlj+XTQCMoOWyPSdKRiG6e48KGzjopl/t/zHw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com; spf=pass smtp.mailfrom=linux.intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=JOZY3BQd; arc=none smtp.client-ip=192.198.163.15
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="JOZY3BQd"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1780392036; x=1811928036;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=6BQsHpGsUXg2fWEevShYArT8/T1HQSJKUOOi9RFcaco=;
  b=JOZY3BQdS3kMTkEkbHPL+PhTPdPomq/6CjVt1jCKqsn4ClRndtq0QRtl
   v95wZnSa9JrycFwlOMWdG6/m59ooG+p8+AIKL7RIzL9fpuaSYsWWRlGOT
   vbdL+LW1yKUADxRu+s5a+XkDYS5BeUiybEQRmOX48hV4mg+aGT2sBI6yV
   ALnIeGw2r+dhbWPh/oKu/i0kARWGeDbMj8O8BweP4Qrt7O88cNLXHMd2E
   uxLN3vj3yOL2llmaTyKrBxRc3RzQD/+ZrJ62tfS8kOdGk/PhA97lyFT41
   GWT+wEXeSf30SZurV1GEJCY9vTJKYjcHJyTl6eFeN7/kjetZ55vqLNQRr
   g==;
X-CSE-ConnectionGUID: 0zu+gchYTp2BE+eQpk9Luw==
X-CSE-MsgGUID: PHRFtguVRByrI0Zwq88vWw==
X-IronPort-AV: E=McAfee;i="6800,10657,11804"; a="81298075"
X-IronPort-AV: E=Sophos;i="6.24,183,1774335600"; 
   d="scan'208";a="81298075"
Received: from fmviesa007.fm.intel.com ([10.60.135.147])
  by fmvoesa109.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 02 Jun 2026 02:20:35 -0700
X-CSE-ConnectionGUID: O7CD12lDRu+OSzqR/16fAw==
X-CSE-MsgGUID: LeqUzhbQREKqhxz6sCXoyA==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.24,183,1774335600"; 
   d="scan'208";a="240848911"
Received: from mkosciow-mobl1.ger.corp.intel.com (HELO localhost) ([10.245.245.229])
  by fmviesa007-auth.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 02 Jun 2026 02:20:26 -0700
Date: Tue, 2 Jun 2026 12:20:24 +0300
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Erni Sri Satya Vennela <ernis@linux.microsoft.com>
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
Message-ID: <ah6gWPQP56RO6_ho@ashevche-desk.local>
References: <20260601091505.1763912-1-ernis@linux.microsoft.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260601091505.1763912-1-ernis@linux.microsoft.com>
Organization: Intel Finland Oy - BIC 0357606-4 - c/o Alberga Business Park, 6
 krs, Bertel Jungin Aukio 5, 02600 Espoo

On Mon, Jun 01, 2026 at 02:14:44AM -0700, Erni Sri Satya Vennela wrote:
> The capability counter fields in struct ib_device_attr are declared
> as signed int, but these values are inherently non-negative. Drivers
> maintain their cached caps as u32 and assign them directly into these
> int fields; if a cap exceeds INT_MAX the implicit narrowing yields a
> negative value visible to the IB core.
> 
> Change the signed int capability fields to u32 to match the
> underlying nature of the data. Also update consumers across the IB
> core, ULPs, NVMe-oF target, RDS, and NFS/RDMA so the new u32 values
> are not forced back through signed int or u8 via min()/min_t() or
> narrowing local variables.

...

>  	attr->max_qp_rd_atom =
> -	    min(1 << (fls(qattr->max_qp_resp_rd_atomic_resc) - 1),
> -		attr->max_qp_init_rd_atom);
> +	    min_t(u32, 1 << (fls(qattr->max_qp_resp_rd_atomic_resc) - 1),
> +		  attr->max_qp_init_rd_atom);

Just no. min_t() usage has to be very well justified. It's a beast which may
stub one in the back. As Linus said in most of the cases one wants clamp()
rather than min().

Please, redo this and similar pieces.

-- 
With Best Regards,
Andy Shevchenko


