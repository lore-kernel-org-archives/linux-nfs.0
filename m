Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41680 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223AbbC0ORr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 10:17:47 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v2 00/15] NFS/RDMA patches proposed for 4.1
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <c541888a-6b49-4b9f-98ba-a1d77df1d071@CMEXHTCAS2.ad.emulex.com>
Date: Fri, 27 Mar 2015 09:17:47 -0500
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Meghana Cheripady <Meghana.Cheripady@Emulex.Com>
Message-Id: <AFCD874E-D85C-4788-A409-17906D841C5B@oracle.com>
References: <20150324201849.2311.53599.stgit@manet.1015granger.net> <55145274.203@Netapp.com> <EE7902D3F51F404C82415C4803930ACD5DC3B914@CMEXMB1.ad.emulex.com> <c541888a-6b49-4b9f-98ba-a1d77df1d071@CMEXHTCAS2.ad.emulex.com>
To: Devesh Sharma <Devesh.Sharma@Emulex.Com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 27, 2015, at 12:44 AM, Devesh Sharma <Devesh.Sharma@Emulex.Com> wrote:

>> -----Original Message-----
>> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
>> owner@vger.kernel.org] On Behalf Of Devesh Sharma
>> Sent: Friday, March 27, 2015 11:13 AM
>> To: Anna Schumaker; Chuck Lever; linux-rdma@vger.kernel.org; linux-
>> nfs@vger.kernel.org
>> Subject: RE: [PATCH v2 00/15] NFS/RDMA patches proposed for 4.1
>> 
>> Hi Chuck,
>> 
>> I have validated these set of patches with ocrdma device, iozone passes with
>> these.
> 
> 
> Thanks to Meghna.

Hi Devesh-

Is there a Tested-by tag that Anna can add to these patches?


>> 
>> -Regards
>> Devesh
>> 
>>> -----Original Message-----
>>> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
>>> owner@vger.kernel.org] On Behalf Of Anna Schumaker
>>> Sent: Friday, March 27, 2015 12:10 AM
>>> To: Chuck Lever; linux-rdma@vger.kernel.org; linux-nfs@vger.kernel.org
>>> Subject: Re: [PATCH v2 00/15] NFS/RDMA patches proposed for 4.1
>>> 
>>> Hey Chuck,
>>> 
>>> I didn't see anything that needs to be fixed up in these patches.  Are
>>> they ready for me?
>>> 
>>> Anna
>>> 
>>> On 03/24/2015 04:30 PM, Chuck Lever wrote:
>>>> This is a series of client-side patches for NFS/RDMA. In preparation
>>>> for increasing the transport credit limit and maximum rsize/wsize,
>>>> I've re-factored the memory registration logic into separate files,
>>>> invoked via a method API.
>>>> 
>>>> The two main optimizations in v1 of this series have been dropped.
>>>> Sagi Grimberg didn't like the complexity of the solution, and there
>>>> isn't enough time to rework it, test the new version, and get it
>>>> reviewed before the 4.1 merge window opens. I'm going to prepare
>>>> these for 4.2.
>>>> 
>>>> Fixes suggested by reviewers have been included before the
>>>> refactoring patches to make it easier to backport them to previous kernels.
>>>> 
>>>> The series is available in the nfs-rdma-for-4.1 topic branch at
>>>> 
>>>> git://linux-nfs.org/projects/cel/cel-2.6.git
>>>> 
>>>> Changes since v1:
>>>> - Rebased on 4.0-rc5
>>>> - Main optimizations postponed to 4.2
>>>> - Addressed review comments from Anna, Sagi, and Devesh
>>>> 
>>>> ---
>>>> 
>>>> Chuck Lever (15):
>>>>      SUNRPC: Introduce missing well-known netids
>>>>      xprtrdma: Display IPv6 addresses and port numbers correctly
>>>>      xprtrdma: Perform a full marshal on retransmit
>>>>      xprtrdma: Byte-align FRWR registration
>>>>      xprtrdma: Prevent infinite loop in rpcrdma_ep_create()
>>>>      xprtrdma: Add vector of ops for each memory registration strategy
>>>>      xprtrdma: Add a "max_payload" op for each memreg mode
>>>>      xprtrdma: Add a "register_external" op for each memreg mode
>>>>      xprtrdma: Add a "deregister_external" op for each memreg mode
>>>>      xprtrdma: Add "init MRs" memreg op
>>>>      xprtrdma: Add "reset MRs" memreg op
>>>>      xprtrdma: Add "destroy MRs" memreg op
>>>>      xprtrdma: Add "open" memreg op
>>>>      xprtrdma: Handle non-SEND completions via a callout
>>>>      xprtrdma: Make rpcrdma_{un}map_one() into inline functions
>>>> 
>>>> 
>>>> include/linux/sunrpc/msg_prot.h    |    8
>>>> net/sunrpc/xprtrdma/Makefile       |    3
>>>> net/sunrpc/xprtrdma/fmr_ops.c      |  208 +++++++++++
>>>> net/sunrpc/xprtrdma/frwr_ops.c     |  353 ++++++++++++++++++
>>>> net/sunrpc/xprtrdma/physical_ops.c |   94 +++++
>>>> net/sunrpc/xprtrdma/rpc_rdma.c     |   87 ++--
>>>> net/sunrpc/xprtrdma/transport.c    |   61 ++-
>>>> net/sunrpc/xprtrdma/verbs.c        |  699 +++---------------------------------
>>>> net/sunrpc/xprtrdma/xprt_rdma.h    |   90 ++++-
>>>> 9 files changed, 882 insertions(+), 721 deletions(-)  create mode
>>>> 100644 net/sunrpc/xprtrdma/fmr_ops.c  create mode 100644
>>>> net/sunrpc/xprtrdma/frwr_ops.c  create mode 100644
>>>> net/sunrpc/xprtrdma/physical_ops.c
>>>> 
>>>> --
>>>> Chuck Lever
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
>>>> in the body of a message to majordomo@vger.kernel.org More majordomo
>>>> info at  http://vger.kernel.org/majordomo-info.html
>>>> 
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-rdma"
>>> in the body of a message to majordomo@vger.kernel.org More majordomo
>>> info at http://vger.kernel.org/majordomo-info.html
>>   칻 & ~ &   +-  ݶ  w  ˛   m b  kvf   ^n r   z   h    &   G   h ( 階 ݢj"   m     z
>> ޖ   f   h   ~ m

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



