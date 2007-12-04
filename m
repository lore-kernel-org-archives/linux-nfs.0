From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 7/8] rdma: makefile (second thread)
Date: Mon, 3 Dec 2007 19:52:12 -0500
Message-ID: <F73D3904-0849-43DF-87FC-A5032F6671AF@oracle.com>
References: <20071129224412.14887.14136.stgit@dell3.ogc.int> <20071129224513.14887.8074.stgit@dell3.ogc.int> <2E823541-6441-4605-8F15-440954CED454@oracle.com> <Pine.LNX.4.64.0712031524250.7142@jlentini-linux.nane.netapp.com> <D770E4F7-53C3-4853-B3B5-9E5B3A1FF40D@oracle.com> <Pine.LNX.4.64.0712031656150.7142@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: James Lentini <jlentini@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:31540 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbXLDAws (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2007 19:52:48 -0500
In-Reply-To: <Pine.LNX.4.64.0712031656150.7142-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 3, 2007, at 5:29 PM, James Lentini wrote:
> On Mon, 3 Dec 2007, Chuck Lever wrote:
>> On Dec 3, 2007, at 3:29 PM, James Lentini wrote:
>>> On Mon, 3 Dec 2007, Chuck Lever wrote:
>>>> On Nov 29, 2007, at 5:45 PM, Tom Tucker wrote:
>>>>> Add the NFSD_RDMA module to the sunrpc makefile.
>>>>>
>>>>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>>>>> ---
>>>>>
>>>>> net/sunrpc/Makefile |    4 ++++
>>>>> 1 files changed, 4 insertions(+), 0 deletions(-)
>>>>>
>>>>> diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
>>>>> index 92e1dbe..6d03dbf 100644
>>>>> --- a/net/sunrpc/Makefile
>>>>> +++ b/net/sunrpc/Makefile
>>>>> @@ -15,3 +15,7 @@ sunrpc-y := clnt.o xprt.o socklib.o  
>>>>> xprtsock.o sched.o
>>>>> \
>>>>> 	    svc_xprt.o
>>>>> sunrpc-$(CONFIG_PROC_FS) += stats.o
>>>>> sunrpc-$(CONFIG_SYSCTL) += sysctl.o
>>>>> +
>>>>> +obj-$(CONFIG_NFSD_RDMA) += svcrdma.o
>>>>> +svcrdma-y := svc_rdma.o svc_rdma_transport.o \
>>>>> +	svc_rdma_marshal.o svc_rdma_sendto.o svc_rdma_recvfrom.o
>>>>
>>>>
>>>> Maybe it would be better to enable server-side RPC RDMA provider  
>>>> support
>>>> with
>>>> a separate config option, like the client side does it, then  
>>>> build the NFS
>>>> server dependency on that, instead of adding it here in the RPC  
>>>> makefile.
>>>>
>>>> If the client-side and server-side providers are merged, then  
>>>> they could
>>>> both
>>>> be enabled via CONFIG_SUNRPC_XPRT_RDMA.
>>>>
>>>> Comments?
>>>
>>> I vote for keeping the client and server sources and builds  
>>> separate.
>>> I'd keep the sources separate because the interfaces defined in the
>>> xprtrdma files are only used by the client and the interfaces  
>>> defined
>>> in svc_rdma_* files are only used by the server.
>>
>> That's just a design choice.  There's no real reason the two can't  
>> be merged
>> at some later point.
>>
>> I understand that the two sides were developed separately... but  
>> it seems like
>> poor software engineering practice that there is so little code  
>> reuse between
>> the client and server-side RDMA transport providers.  It continues an
>> unfortunate tradition in the Linux RPC implementation.
>
> I believe the differences are the result of (1) the asymmetry in the
> NFS/RDMA protocol, only the RPC responder (NFS server) is allowed to
> launch RDMA operations which results in different memory managements,
> etc. and (2) the interfaces they plug into are different. Both
> implementations do share common definitions when possible (e.g. wire
> formats).

Fair enough, but that's an argument for separate sources, not for  
separate builds.

>>> I'd keep keep the build configuration separate because often
>>> someone will want to an NFS client but not an NFS server or vice
>>> versa.
>>
>> You need both server and client providers to support NFSv4
>> callbacks, right?
>
> You're right. I should have been more precise above.

What I meant here was that eventually both the NFS client and server  
have need for both RDMA providers, since both send and receive RPCs.   
The forward channel would be NFS requests, and the reverse channel  
would be NLM and NFSv4.0 callbacks.

I assume that the long term goal is to support NFSv3, NFSv4, and  
NFSv4.x over RDMA, and at least the first two flavors do require  
sending and receiving RPCs on the both the server and client.

>> I still think it's useful to not add "CONFIG_NFSD_RDMA" to the
>> sunrpc Makefile, and would like to see that changed.
>
> I understand where you are coming from but when I look at the current
> config options (e.g. separate options for enabling the v3/v4 in the
> client and server) it seems natural to me to have these be separate as
> well. Regardless of whether one config option or two are exposed, I
> still believe that it makes sense to build the modules separately.

My sense is that the preferred way to express the dependency between  
the NFS layer and the RDMA transport provider is to create a CONFIG  
option to enable the transport, then add a SELECT clause in fs/ 
Kconfig in each NFS section where it's required.

Users who want NFS in their kernels don't select SUNRPC as well, for  
example.  CONFIG_SUNRPC itself is in fact a hidden CONFIG option, and  
it's selected by the upper layer protocols that depend on it.

So, you have a CONFIG option that enables RDMA support in the NFS  
client, and one for the NFS server.  Both of those options would  
select the (possibly hidden) RPC RDMA transport provider option they  
want.  Instead of coding CONFIG_NFSD_RDMA in the net/sunrpc/Makefile,  
you code the hidden sunrpc config option that enables the desired RPC  
RDMA transport provider.

Something like this:

config NFS_RDMA
	bool "NFS client support for NFSoRDMA"
	depends on NFS_FS
	select SUNRPC_XPRT_RDMA
	default n
	help
	  Help me

and

config NFSD_RDMA
	bool "NFS server support for NFSoRDMA"
	depends on NFSD
	select SUNRPC_XPRT_RDMA
	default n
	help
	  Somebody

Make the existing SUNRPC_XPRT_RDMA option hidden, just like SUNRPC  
and SUNRPC_GSS are already.

The net/sunrpc/Makefile file already contains:

obj-${CONFIG_SUNRPC_XPRT_RDMA) += xprtrdma/

Add all the needed dependencies to net/sunrpc/xprtrdma/Makefile for  
both the client and server side transport provider.  It can even  
build separate modules, and the kernel can load just one if only one  
direction is needed on that host.

The advantage is that all the dependencies for NFS over RDMA go into  
the NFS sections of Kconfig, not into the Makefiles.

Since the feature is called "NFS over RDMA" the NFS section of  
Kconfig is where users will start looking to enable the feature.

And, if some other ULP comes along that needs RPC over RDMA, it can  
code that dependency in a Kconfig somewhere as well; we don't need to  
add anything else in net/sunrpc/Makefile to make it work.

I know this arrangement doesn't quite reflect the reality of the  
source code -- that is, that the NFS server and client implementation  
haven't actually been changed to support RDMA, for the most part --  
most of the work is done in the RPC layer.  My sense, though, is that  
users will look for NFSoRDMA support in the config sections for NFS,  
not in the config sections for RPC; especially since SUNRPC is  
already a hidden config option.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
