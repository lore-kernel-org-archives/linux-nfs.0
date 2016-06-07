Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:59716 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756687AbcFGUtp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jun 2016 16:49:45 -0400
Date: Tue, 7 Jun 2016 14:49:41 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 09/20] xprtrdma: Limit the number of rpcrdma_mws
Message-ID: <20160607204941.GA7991@obsidianresearch.com>
References: <20160607194001.18401.88592.stgit@manet.1015granger.net>
 <20160607194732.18401.71941.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160607194732.18401.71941.stgit@manet.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 07, 2016 at 03:47:32PM -0400, Chuck Lever wrote:
> The fixed part of an R_key is 24 bits, but the variant part is only
> 8 bits, allowing 256 unique R_keys concurrenly in flight on one QP.
> 
> Thus an rpcrdma_xprt cannot use more than 256 rpcrdma_mws at a time.
> 
> Capping the number of rpcrdma_mws should prevent ro_map from
> re-using an R_key, which could change the MR co-ordinates or access
> settings while an RPC is still in progress. It also reduces the
> number of pre-allocated FRMRs per transport, allowing more
> transports per device.
> 
> To get more R_keys in flight at once, additional QPs will be
> necessary.

??

The 24 bit / 8 bit thing doesn't create new MRs, it just disambiguates
the life cycle of a single MR. Further, the MR is connected to a PD,
not a QP, there is no such thing as '256 unique R_keys concurrenly in
flight on one QP' ???

This is why no ULP has ever needed this constant before:

> +enum {
> +	RPCRDMA_RKEYS_PER_QP	= 256
> +};

Because you never need to care when working with FRMRs.

Either the number in queue is limited by the invalidation
synchronization point to 2, or in the case of iwarp read, it doesn't
matter since everything executes serially in order and the value can
safely wrap.

Jason
