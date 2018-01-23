Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:22657 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751297AbeAWQmu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Jan 2018 11:42:50 -0500
Subject: Re: [PATCH v3 1/2] rdma/ib: Add trace point macros to display
 human-readable values
To: Chuck Lever <chuck.lever@oracle.com>,
        Jason Gunthorpe <jgg@ziepe.ca>
CC: <dledford@redhat.com>, <leon@kernel.org>,
        <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20180120161440.6488.4311.stgit@manet.1015granger.net>
 <20180120161625.6488.7416.stgit@manet.1015granger.net>
 <20180122174709.GE14372@ziepe.ca>
 <A6F9729C-9922-4C9D-9264-F053DB76B622@oracle.com>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <9414965c-f3e7-b704-a022-a337b07254c6@Netapp.com>
Date: Tue, 23 Jan 2018 11:42:43 -0500
MIME-Version: 1.0
In-Reply-To: <A6F9729C-9922-4C9D-9264-F053DB76B622@oracle.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/23/2018 11:38 AM, Chuck Lever wrote:
> 
> 
>> On Jan 22, 2018, at 9:47 AM, Jason Gunthorpe <jgg@ziepe.ca> wrote:
>>
>> On Sat, Jan 20, 2018 at 11:16:25AM -0500, Chuck Lever wrote:
>>> These can be shared with all kernel ULPs, and more can easily be
>>> added as needed.
>>>
>>> Note: checkpatch.pl has some heartburn with the TRACE_DEFINE_ENUM
>>> macros and the LIST macros. These follow the same style as other
>>> header files under include/tracing/events , thus should be
>>> considered acceptable exceptions.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> include/trace/events/rdma.h |  129 +++++++++++++++++++++++++++++++++++++++++++
>>> 1 file changed, 129 insertions(+)
>>> create mode 100644 include/trace/events/rdma.h
>>
>> Not knowing a lout about trace points, this does seem OK to me:
>>
>> Acked-by: Jason Gunthorpe <jgg@mellanox.com>
>>
>> To flow through Anna's tree
> 
> Thanks, Jason.

Thank you!  I've added the patches to my tree.
> 
> --
> Chuck Lever
> 
> 
> 
