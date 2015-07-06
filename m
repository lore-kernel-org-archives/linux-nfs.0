Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-db3on0092.outbound.protection.outlook.com ([157.55.234.92]:38784
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751319AbbGFHkw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jul 2015 03:40:52 -0400
Message-ID: <559A2991.3040304@mellanox.com>
Date: Mon, 6 Jul 2015 10:09:05 +0300
From: Haggai Eran <haggaie@mellanox.com>
MIME-Version: 1.0
To: Steve Wise <swise@opengridcomputing.com>, <dledford@redhat.com>
CC: <sagig@mellanox.com>, <ogerlitz@mellanox.com>, <roid@mellanox.com>,
        <linux-rdma@vger.kernel.org>, <eli@mellanox.com>,
        <target-devel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <trond.myklebust@primarydata.com>, <bfields@fieldses.org>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
References: <20150705231831.12029.80307.stgit@build2.ogc.int>
 <20150705232158.12029.25472.stgit@build2.ogc.int>
In-Reply-To: <20150705232158.12029.25472.stgit@build2.ogc.int>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/07/2015 02:22, Steve Wise wrote:
> +int rdma_device_access_flags(struct ib_pd *pd, int roles, int attrs)
> +{
> +	int access_flags = attrs;
> +
> +	if (roles & RDMA_MRR_RECV)
> +		access_flags |= IB_ACCESS_LOCAL_WRITE;
> +
> +	if (roles & RDMA_MRR_WRITE_DEST)
> +		access_flags |= IB_ACCESS_LOCAL_WRITE | IB_ACCESS_REMOTE_WRITE;
> +
> +	if (roles & RDMA_MRR_READ_DEST) {
> +		access_flags |= IB_ACCESS_LOCAL_WRITE;
> +		if (rdma_protocol_iwarp(pd->device,
> +					rdma_start_port(pd->device)))
> +			access_flags |= IB_ACCESS_REMOTE_WRITE;
> +	}
> +
> +	if (roles & RDMA_MRR_READ_SOURCE)
> +		access_flags |= IB_ACCESS_REMOTE_READ;
> +
> +	if (roles & RDMA_MRR_ATOMIC_DEST)
> +		access_flags |= IB_ACCESS_LOCAL_WRITE | IB_ACCESS_REMOTE_ATOMIC;

I think you need LOCAL_WRITE for ATOMIC_SOURCE in order to receive the
results of the atomic operation.

> +
> +	if (roles & RDMA_MRR_MW_BIND)
> +		access_flags |= IB_ACCESS_MW_BIND;
> +
> +	return access_flags;
> +}
> +EXPORT_SYMBOL(rdma_device_access_flags);

