Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:43779 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbaKIVnv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Nov 2014 16:43:51 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v2 02/10] xprtrdma: Cap req_cqinit
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <545F3E46.9040703@dev.mellanox.co.il>
Date: Sun, 9 Nov 2014 16:43:44 -0500
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <9C2B7BB4-B378-4225-BBD1-2B0F58D70342@oracle.com>
References: <20141109010328.8806.5861.stgit@manet.1015granger.net> <20141109011420.8806.1849.stgit@manet.1015granger.net> <545F3E46.9040703@dev.mellanox.co.il>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 9, 2014, at 5:13 AM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:

> On 11/9/2014 3:14 AM, Chuck Lever wrote:
>> Recent work made FRMR registration and invalidation completions
>> unsignaled. This greatly reduces the adapter interrupt rate.
>> 
>> Every so often, however, a posted send Work Request is allowed to
>> signal. Otherwise, the provider's Work Queue will wrap and the
>> workload will hang.
>> 
>> The number of Work Requests that are allowed to remain unsignaled is
>> determined by the value of req_cqinit. Currently, this is set to the
>> size of the send Work Queue divided by two, minus 1.
>> 
>> For FRMR, the send Work Queue is the maximum number of concurrent
>> RPCs (currently 32) times the maximum number of Work Requests an
>> RPC might use (currently 7, though some adapters may need more).
>> 
>> For mlx4, this is 224 entries. This leaves completion signaling
>> disabled for 111 send Work Requests.
>> 
>> Some providers hold back dispatching Work Requests until a CQE is
>> generated.  If completions are disabled, then no CQEs are generated
>> for quite some time, and that can stall the Work Queue.
>> 
>> I've seen this occur running xfstests generic/113 over NFSv4, where
>> eventually, posting a FAST_REG_MR Work Request fails with -ENOMEM
>> because the Work Queue has overflowed. The connection is dropped
>> and re-established.
> 
> Hey Chuck,
> 
> As you know, I've seen this issue too...
> Looking into this is definitely on my todo list.
> 
> Does this happen if you run a simple dd (single request-response inflight)?

Hi Sagi-

I typically run dbench, iozone, and xfstests when preparing patches for
upstream. The generic/113 test I mention in the patch description is the
only test where I saw this issue. I expect single-thread won’t drive
enough Work Queue activity to push the provider into WQ overflow.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



