Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20117 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750837AbdAXVqI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2017 16:46:08 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2 0/5] Fix "support large inline thresholds"
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <353a72a5-549d-535b-28b7-411ba81483a1@Netapp.com>
Date: Tue, 24 Jan 2017 16:46:02 -0500
Cc: List Linux RDMA Mailing <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <82302622-9524-4020-869E-81F57629EC86@oracle.com>
References: <20170123205159.21699.47373.stgit@manet.1015granger.net> <353a72a5-549d-535b-28b7-411ba81483a1@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 24, 2017, at 4:35 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
> 
> Hi Chuck,
> 
> On 01/23/2017 03:52 PM, Chuck Lever wrote:
>> Hi Anna-
>> 
>> I've received a number of reports that v4.9 commit 655fec6987be
>> ("xprtrdma: Use gathered Send for large inline messages") causes
>> NFS/RDMA mounts to fail for devices that have a small max_sge.
>> 
>> This series addresses that problem. Would you consider this series
>> of bug fixes for v4.10-rc?
> 
> I noticed that patches one and four are the only ones with a "Fixes:" tag.  Do you need all five patches to fix the problem, or can the rest be deferred to 4.11?

5/5 can be deferred if you want. The others are all required to
fix the problem. However, these were tested as a series. I'm
reticent to split them at this point.

Should 1 - 4 have a "Fixes: 655fec6987be ("xprtrdma: Use
gathered Send for large ...")" ?


> Thanks,
> Anna
> 
>> 
>> 
>> Available in the "nfs-rdma-for-4.10-rc" topic branch of this git repo:
>> 
>> git://git.linux-nfs.org/projects/cel/cel-2.6.git
>> 
>> And for online review:
>> 
>> http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=shortlog;h=refs/heads/nfs-rdma-for-4.10-rc
>> 
>> 
>> Changes since v1:
>> - Rebased on v4.10-rc5
>> - Renamed some variables for clarity
>> - Clarified patch descriptions
>> - Added Tested-by and Reviewed-by tags
>> 
>> ---
>> 
>> Chuck Lever (5):
>>      xprtrdma: Fix Read chunk padding
>>      xprtrdma: Per-connection pad optimization
>>      xprtrdma: Disable pad optimization by default
>>      xprtrdma: Reduce required number of send SGEs
>>      xprtrdma: Shrink send SGEs array
>> 
>> 
>> net/sunrpc/xprtrdma/rpc_rdma.c  |   62 +++++++++++++++++++++++++--------------
>> net/sunrpc/xprtrdma/transport.c |    2 +
>> net/sunrpc/xprtrdma/verbs.c     |   15 ++++++---
>> net/sunrpc/xprtrdma/xprt_rdma.h |   14 ++++++---
>> 4 files changed, 60 insertions(+), 33 deletions(-)
>> 
>> --
>> Chuck Lever
>> 

--
Chuck Lever



