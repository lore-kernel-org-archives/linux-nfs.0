From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 7/8] rdma: makefile (second thread)
Date: Mon, 3 Dec 2007 15:52:59 -0500
Message-ID: <D770E4F7-53C3-4853-B3B5-9E5B3A1FF40D@oracle.com>
References: <20071129224412.14887.14136.stgit@dell3.ogc.int> <20071129224513.14887.8074.stgit@dell3.ogc.int> <2E823541-6441-4605-8F15-440954CED454@oracle.com> <Pine.LNX.4.64.0712031524250.7142@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: James Lentini <jlentini@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:63684 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbXLCVKm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2007 16:10:42 -0500
In-Reply-To: <Pine.LNX.4.64.0712031524250.7142-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 3, 2007, at 3:29 PM, James Lentini wrote:
> On Mon, 3 Dec 2007, Chuck Lever wrote:
>
>> On Nov 29, 2007, at 5:45 PM, Tom Tucker wrote:
>>> Add the NFSD_RDMA module to the sunrpc makefile.
>>>
>>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>>> ---
>>>
>>> net/sunrpc/Makefile |    4 ++++
>>> 1 files changed, 4 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
>>> index 92e1dbe..6d03dbf 100644
>>> --- a/net/sunrpc/Makefile
>>> +++ b/net/sunrpc/Makefile
>>> @@ -15,3 +15,7 @@ sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o  
>>> sched.o \
>>> 	    svc_xprt.o
>>> sunrpc-$(CONFIG_PROC_FS) += stats.o
>>> sunrpc-$(CONFIG_SYSCTL) += sysctl.o
>>> +
>>> +obj-$(CONFIG_NFSD_RDMA) += svcrdma.o
>>> +svcrdma-y := svc_rdma.o svc_rdma_transport.o \
>>> +	svc_rdma_marshal.o svc_rdma_sendto.o svc_rdma_recvfrom.o
>>
>>
>> Maybe it would be better to enable server-side RPC RDMA provider  
>> support with
>> a separate config option, like the client side does it, then build  
>> the NFS
>> server dependency on that, instead of adding it here in the RPC  
>> makefile.
>>
>> If the client-side and server-side providers are merged, then they  
>> could both
>> be enabled via CONFIG_SUNRPC_XPRT_RDMA.
>>
>> Comments?
>
> I vote for keeping the client and server sources and builds separate.
> I'd keep the sources separate because the interfaces defined in the
> xprtrdma files are only used by the client and the interfaces defined
> in svc_rdma_* files are only used by the server.

That's just a design choice.  There's no real reason the two can't be  
merged at some later point.

I understand that the two sides were developed separately... but it  
seems like poor software engineering practice that there is so little  
code reuse between the client and server-side RDMA transport  
providers.  It continues an unfortunate tradition in the Linux RPC  
implementation.

> I'd keep keep the
> build configuration separate because often someone will want to an NFS
> client but not an NFS server or vice versa.

You need both server and client providers to support NFSv4 callbacks,  
right?

I still think it's useful to not add "CONFIG_NFSD_RDMA" to the sunrpc  
Makefile, and would like to see that changed.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
