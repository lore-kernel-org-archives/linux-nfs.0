Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:50857 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520AbcDZUOM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Apr 2016 16:14:12 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2 11/18] xprtrdma: Save I/O direction in struct rpcrdma_frwr
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <571FCBBD.9070200@grimberg.me>
Date: Tue, 26 Apr 2016 16:14:06 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <DDD1E1BA-B4FA-407A-BE02-A07F6391BC76@oracle.com>
References: <20160425185956.3566.64142.stgit@manet.1015granger.net> <20160425192218.3566.13233.stgit@manet.1015granger.net> <571FCBBD.9070200@grimberg.me>
To: Sagi Grimberg <sagi@grimberg.me>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 26, 2016, at 4:12 PM, Sagi Grimberg <sagi@grimberg.me> wrote:
> 
> 
>> Move the the I/O direction field from rpcrdma_mr_seg into the
>> rpcrdma_frmr. This makes it possible to perform the DMA unmapping
>> long after the rpcrdma_mr_seg has been released and re-used.
> 
> A little explanation on why this is desired/useful would help understand
> this patch.

Can do.

--
Chuck Lever



