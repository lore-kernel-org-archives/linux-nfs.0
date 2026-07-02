Received: from linux.microsoft.com (linux.microsoft.com [13.77.154.182])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 18DDC22332E;
	Thu,  2 Jul 2026 06:03:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=13.77.154.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782972226; cv=none; b=ZutVD2I3ae+UafbhdW1EfQ/AVzjsQBIVxg76hLsepp8SR+iYKPczlgVqe7g1Uo8pTssjisYD5PzAmdHY3HA86lD5eEkkY4Ie5XTrFinqgSA2jQhNdBJDbojTFSK891SYxSBCiYjUfNsGi6UMa/RKvf6oB4ajiQJfFwxpd2lRAtg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782972226; c=relaxed/simple;
	bh=P+Dfz57Duebop7W0Y9UL+IO/oLzMA4pZeLlFNiZ1qcg=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=XGhLQf7d4jYDd9Ok/N33wwQCcwPg+M+hbWObElistJumR+6eIhy6GDSN8m64tTNCiubeIr+hGjjiizhTD/YgIcp3xV50SWjiL/lc0jIC0Lhz8liZGpnRor6aUwnLSAa4l0NvBPu4YNAUqCZkVdVp0nNSlgMNVTd5bqYcHQYXeOY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.microsoft.com; spf=pass smtp.mailfrom=linux.microsoft.com; dkim=pass (1024-bit key) header.d=linux.microsoft.com header.i=@linux.microsoft.com header.b=YWiewdux; arc=none smtp.client-ip=13.77.154.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.microsoft.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.microsoft.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.microsoft.com header.i=@linux.microsoft.com header.b="YWiewdux"
Received: by linux.microsoft.com (Postfix, from userid 1173)
	id 3C67320B7169; Wed,  1 Jul 2026 23:03:43 -0700 (PDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 linux.microsoft.com 3C67320B7169
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linux.microsoft.com;
	s=default; t=1782972223;
	bh=PYV85AvFz4rVWO3U/hhUvMvhuqB8LpaELOR2jS/qchU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=YWiewduxaLuWS7rWYB1zlKBpG5aA+R24KUAH3I597I72uX/KPA1VykdQbrEWWP7Np
	 ZMXqOfd63PnLfEHvY9exzPQkrEBt5b65twR2m+gfSW+EACtewSCu18K92iq1eEb6eo
	 23jCh8m24d9IZdFNVnC3LvCe85f6mAfC0hsWpNZs=
Date: Wed, 1 Jul 2026 23:03:43 -0700
From: Erni Sri Satya Vennela <ernis@linux.microsoft.com>
To: Jason Gunthorpe <jgg@ziepe.ca>, Leon Romanovsky <leon@kernel.org>,
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
	andriy.shevchenko@linux.intel.com, ebadger@purestorage.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	target-devel@vger.kernel.org, linux-nvme@lists.infradead.org,
	linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com
Cc: Jason Gunthorpe <jgg@nvidia.com>
Subject: Re: [PATCH rdma-next v8] RDMA: Change capability fields in
 ib_device_attr from int to u32
Message-ID: <akX/P/0TiSQ38YdS@linuxonhyperv3.guj3yctzbm1etfxqx2vob5hsef.xx.internal.cloudapp.net>
References: <20260619203107.606359-1-ernis@linux.microsoft.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260619203107.606359-1-ernis@linux.microsoft.com>

On Fri, Jun 19, 2026 at 01:30:39PM -0700, Erni Sri Satya Vennela wrote:
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
> 
> Suggested-by: Jason Gunthorpe <jgg@nvidia.com>
> Signed-off-by: Erni Sri Satya Vennela <ernis@linux.microsoft.com>
> Acked-by: Stefan Metzmacher <metze@samba.org> # smbdirect


Hi,

Just a friendly follow-up on this patch. The Sashiko review mentioned a
low-priority item, and I'd appreciate any guidance on whether the change
is needed.

https://sashiko.dev/#/patchset/20260619203107.606359-1-ernis%40linux.microsoft.com

Thanks,
Vennela
