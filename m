Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36861 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753324AbcDZUdl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Apr 2016 16:33:41 -0400
Subject: Re: [PATCH v2 13/18] xprtrdma: Refactor the FRWR recovery worker
To: Chuck Lever <chuck.lever@oracle.com>
References: <20160425185956.3566.64142.stgit@manet.1015granger.net>
 <20160425192234.3566.63698.stgit@manet.1015granger.net>
 <571FCC8C.5040503@grimberg.me>
 <CAED2A23-CCB8-4C26-B212-2A4699D6B024@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <571FD0A1.90501@grimberg.me>
Date: Tue, 26 Apr 2016 23:33:37 +0300
MIME-Version: 1.0
In-Reply-To: <CAED2A23-CCB8-4C26-B212-2A4699D6B024@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 26/04/16 23:30, Chuck Lever wrote:
>
>> On Apr 26, 2016, at 4:16 PM, Sagi Grimberg <sagi@grimberg.me> wrote:
>>
>>
>>> +static void
>>> +__frwr_reset_and_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mw *mw)
>>> +{
>>> +	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
>>> +	struct rpcrdma_frmr *f = &mw->frmr;
>>> +	int rc;
>>> +
>>> +	rc = __frwr_reset_mr(ia, mw);
>>> +	ib_dma_unmap_sg(ia->ri_device, f->fr_sg, f->fr_nents, f->fr_dir);
>>> +	if (rc)
>>> +		return;
>>> +
>>> +	rpcrdma_put_mw(r_xprt, mw);
>>> +}
>>> +
>>
>> If this is not being called from other sites I'd say just
>> do it in __frwr_recovery_worker instead of having it just bouncing
>> the call...
>
> It will be called from another site in 16/18.

I see, alright then,

Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
