Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:32297 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020AbaIXVNM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 17:13:12 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH V3] svcrdma: advertise the correct max payload
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <5422B14C.3040502@dev.mellanox.co.il>
Date: Wed, 24 Sep 2014 14:12:58 -0700
Cc: Steve Wise <swise@opengridcomputing.com>, fields@fieldses.org,
        linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <55D3FB7C-3DDD-42B0-96F7-8134096F745C@oracle.com>
References: <20140923221122.24227.91718.stgit@build.ogc.int> <5422B14C.3040502@dev.mellanox.co.il>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 24, 2014, at 4:55 AM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:

> On 9/24/2014 1:11 AM, Steve Wise wrote:
>> Svcrdma currently advertises 1MB, which is too large.  The correct value
>> is the minimum of RPCSVC_MAXPAYLOAD and the max scatter-gather allowed
>> in an NFSRDMA IO chunk * the host page size. This bug is usually benign
>> because the Linux X64 NFSRDMA client correctly limits the payload size to
>> the correct value (64*4096 = 256KB).  But if the Linux client is PPC64
>> with a 64KB page size, then the client will indeed use a payload size
>> that will overflow the server.
>> 
> 
> Maybe I'm a bit late with this, but can you explain why SG table is
> limited to 64 (fastreg MR and page_list probably bound it). Where is it
> coming from? Naturally it needs to be bound by some figure, but why 64?

It’s arbitrary, AFAIK. It has been used to allocate some data structures
on the stack, for example, so it can’t be too large.

It’s something we need to look at.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



