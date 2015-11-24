Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:47879 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753528AbbKXPUj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 10:20:39 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH v1 3/9] xprtrdma: Introduce ro_unmap_sync method
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <565477CC.5070309@dev.mellanox.co.il>
Date: Tue, 24 Nov 2015 10:20:10 -0500
Cc: Christoph Hellwig <hch@infradead.org>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Sagi Grimberg <sagig@mellanox.com>
Message-Id: <0632A14B-5391-4AAC-8F05-1809A092F04B@oracle.com>
References: <20151123220627.32702.62667.stgit@manet.1015granger.net> <20151123221414.32702.87638.stgit@manet.1015granger.net> <20151124064556.GA29141@infradead.org> <565442F5.7080400@dev.mellanox.co.il> <4B2D7C66-31AC-44F3-A8CC-22CC7136015C@oracle.com> <565477CC.5070309@dev.mellanox.co.il>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 24, 2015, at 9:44 AM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:
> 
> Hey Chuck,
> 
>> 
>>> It is painful, too painful. The entire value proposition of RDMA is
>>> low-latency and waiting for the extra HW round-trip for a local
>>> invalidation to complete is unacceptable, moreover it adds a huge loads
>>> of extra interrupts and cache-line pollutions.
>> 
>> The killer is the extra context switches, I’ve found.
> 
> That too...
> 
>> I’ve noticed only a marginal loss of performance on modern
>> hardware.
> 
> Would you mind sharing your observations?

I’m testing with CX-3 Pro on FDR.

NFS READ and WRITE round trip latency, which includes the cost
of registration and now invalidation, is not noticeably longer.
dbench and fio results are marginally slower (in the neighborhood
of 5%).

For NFS, the cost of invalidation is probably not significant
compared to other bottlenecks in our stack (lock contention and
scheduling overhead are likely the largest contributors).

Notice that xprtrdma chains together all the LOCAL_INV WRs for
an RPC, and only signals the final one. Before, every LOCAL_INV
WR was signaled. So this patch actually reduces the send
completion rate.

The main benefit for NFS of waiting for invalidation to complete
is better send queue accounting. Even without the data integrity
issue, we have to ensure the WQEs consumed by invalidation
requests are released before dispatching another RPC. Otherwise
the send queue can be overrun.


--
Chuck Lever




