Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:40815 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947AbbLPPJs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2015 10:09:48 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH v3 06/11] xprtrdma: Add ro_unmap_sync method for FRWR
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <56716DE4.8080403@dev.mellanox.co.il>
Date: Wed, 16 Dec 2015 10:09:44 -0500
Cc: anna.schumaker@netapp.com, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <1ED402CD-72B6-4F44-A8FD-88FD379551BA@oracle.com>
References: <20151214211317.16295.70115.stgit@manet.1015granger.net> <20151214211827.16295.76338.stgit@manet.1015granger.net> <56716DE4.8080403@dev.mellanox.co.il>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 16, 2015, at 8:57 AM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:
> 
> 
>> +static void
>> +__frwr_dma_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
>> +		 int rc)
>> +{
>> +	struct ib_device *device = r_xprt->rx_ia.ri_device;
>> +	struct rpcrdma_mw *mw = seg->rl_mw;
>> +	int nsegs = seg->mr_nsegs;
>> +
>> +	seg->rl_mw = NULL;
>> +
>> +	while (nsegs--)
>> +		rpcrdma_unmap_one(device, seg++);
> 
> Chuck, shouldn't this be replaced with ib_dma_unmap_sg?

Looks like this was left over from before the conversion
to use ib_dma_unmap_sg. I'll have a look.

> Sorry for the late comment (Didn't find enough time to properly
> review this...)

--
Chuck Lever




