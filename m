Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:48033 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbbCZSnl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2015 14:43:41 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v2 00/15] NFS/RDMA patches proposed for 4.1
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <55145274.203@Netapp.com>
Date: Thu, 26 Mar 2015 13:43:38 -0500
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D8D8F30A-1E68-49AB-B10C-8A858C27F2E0@oracle.com>
References: <20150324201849.2311.53599.stgit@manet.1015granger.net> <55145274.203@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 26, 2015, at 1:39 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:

> Hey Chuck,
> 
> I didn't see anything that needs to be fixed up in these patches.  Are they ready for me?

Thanks for the review. IMO we can go one of two routes:

 - Wait for HCA vendors to test this latest version of the series, or

 - Merge it now, and simply apply any needed fixes on top before the 4.1
window opens.

What do you prefer? Is it possible to get this series in front of the
zero-day test folks before you merge?


> Anna
> 
> On 03/24/2015 04:30 PM, Chuck Lever wrote:
>> This is a series of client-side patches for NFS/RDMA. In preparation
>> for increasing the transport credit limit and maximum rsize/wsize,
>> I've re-factored the memory registration logic into separate files,
>> invoked via a method API.
>> 
>> The two main optimizations in v1 of this series have been dropped.
>> Sagi Grimberg didn't like the complexity of the solution, and there
>> isn't enough time to rework it, test the new version, and get it
>> reviewed before the 4.1 merge window opens. I'm going to prepare
>> these for 4.2.
>> 
>> Fixes suggested by reviewers have been included before the
>> refactoring patches to make it easier to backport them to previous
>> kernels.
>> 
>> The series is available in the nfs-rdma-for-4.1 topic branch at
>> 
>> git://linux-nfs.org/projects/cel/cel-2.6.git
>> 
>> Changes since v1:
>> - Rebased on 4.0-rc5
>> - Main optimizations postponed to 4.2
>> - Addressed review comments from Anna, Sagi, and Devesh
>> 
>> ---
>> 
>> Chuck Lever (15):
>>      SUNRPC: Introduce missing well-known netids
>>      xprtrdma: Display IPv6 addresses and port numbers correctly
>>      xprtrdma: Perform a full marshal on retransmit
>>      xprtrdma: Byte-align FRWR registration
>>      xprtrdma: Prevent infinite loop in rpcrdma_ep_create()
>>      xprtrdma: Add vector of ops for each memory registration strategy
>>      xprtrdma: Add a "max_payload" op for each memreg mode
>>      xprtrdma: Add a "register_external" op for each memreg mode
>>      xprtrdma: Add a "deregister_external" op for each memreg mode
>>      xprtrdma: Add "init MRs" memreg op
>>      xprtrdma: Add "reset MRs" memreg op
>>      xprtrdma: Add "destroy MRs" memreg op
>>      xprtrdma: Add "open" memreg op
>>      xprtrdma: Handle non-SEND completions via a callout
>>      xprtrdma: Make rpcrdma_{un}map_one() into inline functions
>> 
>> 
>> include/linux/sunrpc/msg_prot.h    |    8 
>> net/sunrpc/xprtrdma/Makefile       |    3 
>> net/sunrpc/xprtrdma/fmr_ops.c      |  208 +++++++++++
>> net/sunrpc/xprtrdma/frwr_ops.c     |  353 ++++++++++++++++++
>> net/sunrpc/xprtrdma/physical_ops.c |   94 +++++
>> net/sunrpc/xprtrdma/rpc_rdma.c     |   87 ++--
>> net/sunrpc/xprtrdma/transport.c    |   61 ++-
>> net/sunrpc/xprtrdma/verbs.c        |  699 +++---------------------------------
>> net/sunrpc/xprtrdma/xprt_rdma.h    |   90 ++++-
>> 9 files changed, 882 insertions(+), 721 deletions(-)
>> create mode 100644 net/sunrpc/xprtrdma/fmr_ops.c
>> create mode 100644 net/sunrpc/xprtrdma/frwr_ops.c
>> create mode 100644 net/sunrpc/xprtrdma/physical_ops.c
>> 
>> --
>> Chuck Lever
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



