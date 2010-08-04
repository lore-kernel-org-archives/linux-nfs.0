Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:36101 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758119Ab0HDDYc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Aug 2010 23:24:32 -0400
Message-ID: <4C58DD6D.7090904@opengridcomputing.com>
Date: Tue, 03 Aug 2010 21:24:29 -0600
From: Tom Tucker <tom@opengridcomputing.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Tom Tucker <tom@ogc.us>, bfields@fieldses.org, linux-nfs@vger.kernel.org,
        swise@ogc.us
Subject: Re: [PATCH 0/4] nfsrdma: Miscellanseous Bug Fixes
References: <20100803164411.2567.31416.stgit@build.ogc.int> <1280889722.24669.31.camel@heimdal.trondhjem.org>
In-Reply-To: <1280889722.24669.31.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:
> On Tue, 2010-08-03 at 11:44 -0500, Tom Tucker wrote:
>   
>> The following series fixes a number of bugs in the NFSRDMA transport.
>>
>> ---
>>
>> Steve Wise (1):
>>       xprtrdma: Do not truncate iova_start values in frmr registrations.
>>
>> Tom Tucker (3):
>>       rpcrdma: Fix SQ size calculation when memreg is FRMR
>>       svcrdma: Cleanup DMA unmapping in error paths.
>>       svcrdma: Change DMA mapping logic to avoid the page_address kernel API
>>
>>
>>  net/sunrpc/xprtrdma/rpc_rdma.c           |    2 +
>>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   19 ++++---
>>  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   82 ++++++++++++++++++++++--------
>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   41 +++++++--------
>>  net/sunrpc/xprtrdma/verbs.c              |   22 ++++++--
>>  5 files changed, 111 insertions(+), 55 deletions(-)
>>     
>
> Hi Tom,
>
> How do you want to split these patches? The first one looks definitely
> like a client bug, and the next 2 look like server bugs, but what about
> the last patch?
>
>   
Yes, I wrestled with that, but decided to post them as a collection 
since it's the 'same transport' for review. But obviously, the client 
ones will go to your tree and the server ones to Bruce's tree. I'll 
split and repost the final after the review.

Will that work?

Tom

> Cheers
>   Trond
>   

