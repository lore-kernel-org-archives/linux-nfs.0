Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27724 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753800AbcDZUbC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Apr 2016 16:31:02 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2 13/18] xprtrdma: Refactor the FRWR recovery worker
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <571FCC8C.5040503@grimberg.me>
Date: Tue, 26 Apr 2016 16:30:52 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <CAED2A23-CCB8-4C26-B212-2A4699D6B024@oracle.com>
References: <20160425185956.3566.64142.stgit@manet.1015granger.net> <20160425192234.3566.63698.stgit@manet.1015granger.net> <571FCC8C.5040503@grimberg.me>
To: Sagi Grimberg <sagi@grimberg.me>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 26, 2016, at 4:16 PM, Sagi Grimberg <sagi@grimberg.me> wrote:
> 
> 
>> +static void
>> +__frwr_reset_and_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mw *mw)
>> +{
>> +	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
>> +	struct rpcrdma_frmr *f = &mw->frmr;
>> +	int rc;
>> +
>> +	rc = __frwr_reset_mr(ia, mw);
>> +	ib_dma_unmap_sg(ia->ri_device, f->fr_sg, f->fr_nents, f->fr_dir);
>> +	if (rc)
>> +		return;
>> +
>> +	rpcrdma_put_mw(r_xprt, mw);
>> +}
>> +
> 
> If this is not being called from other sites I'd say just
> do it in __frwr_recovery_worker instead of having it just bouncing
> the call...

It will be called from another site in 16/18.


--
Chuck Lever



