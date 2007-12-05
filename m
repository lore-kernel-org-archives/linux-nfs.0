From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 7/8] rdma: makefile (second thread)
Date: Tue, 4 Dec 2007 22:08:14 -0500
Message-ID: <783CD96D-DFB4-439D-B726-DD4432FEF705@oracle.com>
References: <20071129224412.14887.14136.stgit@dell3.ogc.int> <20071129224513.14887.8074.stgit@dell3.ogc.int> <2E823541-6441-4605-8F15-440954CED454@oracle.com> <Pine.LNX.4.64.0712031524250.7142@jlentini-linux.nane.netapp.com> <D770E4F7-53C3-4853-B3B5-9E5B3A1FF40D@oracle.com> <Pine.LNX.4.64.0712031656150.7142@jlentini-linux.nane.netapp.com> <F73D3904-0849-43DF-87FC-A5032F6671AF@oracle.com> <Pine.LNX.4.64.0712041800270.7142@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: James Lentini <jlentini@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:49541 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbXLEDLD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Dec 2007 22:11:03 -0500
In-Reply-To: <Pine.LNX.4.64.0712041800270.7142-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 4, 2007, at 6:04 PM, James Lentini wrote:
> On Mon, 3 Dec 2007, Chuck Lever wrote:
> <snip>
>> My sense is that the preferred way to express the dependency between
>> the NFS layer and the RDMA transport provider is to create a CONFIG
>> option to enable the transport, then add a SELECT clause in
>> fs/Kconfig in each NFS section where it's required.
>>
>> Users who want NFS in their kernels don't select SUNRPC as well, for
>> example. CONFIG_SUNRPC itself is in fact a hidden CONFIG option, and
>> it's selected by the upper layer protocols that depend on it.
>>
>> So, you have a CONFIG option that enables RDMA support in the NFS
>> client, and one for the NFS server.  Both of those options would
>> select the (possibly hidden) RPC RDMA transport provider option they
>> want.  Instead of coding CONFIG_NFSD_RDMA in the
>> net/sunrpc/Makefile, you code the hidden sunrpc config option that
>> enables the desired RPC RDMA transport provider.
>>
>> Something like this:
>>
>> config NFS_RDMA
>> 	bool "NFS client support for NFSoRDMA"
>> 	depends on NFS_FS
>> 	select SUNRPC_XPRT_RDMA
>> 	default n
>> 	help
>> 	  Help me
>>
>> and
>>
>> config NFSD_RDMA
>> 	bool "NFS server support for NFSoRDMA"
>> 	depends on NFSD
>> 	select SUNRPC_XPRT_RDMA
>> 	default n
>> 	help
>> 	  Somebody
>>
>> Make the existing SUNRPC_XPRT_RDMA option hidden, just like SUNRPC
>> and SUNRPC_GSS are already.
>>
>> The net/sunrpc/Makefile file already contains:
>>
>> obj-${CONFIG_SUNRPC_XPRT_RDMA) += xprtrdma/
>>
>> Add all the needed dependencies to net/sunrpc/xprtrdma/Makefile for
>> both the client and server side transport provider.  It can even
>> build separate modules, and the kernel can load just one if only one
>> direction is needed on that host.
>>
>> The advantage is that all the dependencies for NFS over RDMA go into
>> the NFS sections of Kconfig, not into the Makefiles.
>>
>> Since the feature is called "NFS over RDMA" the NFS section of
>> Kconfig is where users will start looking to enable the feature.
>>
>> And, if some other ULP comes along that needs RPC over RDMA, it can
>> code that dependency in a Kconfig somewhere as well; we don't need
>> to add anything else in net/sunrpc/Makefile to make it work.
>>
>> I know this arrangement doesn't quite reflect the reality of the
>> source code -- that is, that the NFS server and client
>> implementation haven't actually been changed to support RDMA, for
>> the most part -- most of the work is done in the RPC layer.  My
>> sense, though, is that users will look for NFSoRDMA support in the
>> config sections for NFS, not in the config sections for RPC;
>> especially since SUNRPC is already a hidden config option.
>
> Ok, Tom (Tucker), Tom (Talpey), and I will put this organization
> together and included it with Tom Tucker's next release of the
> NFS/RDMA server patchset.
>
> One question, are you recommending that all the source files be
> located in the xprtrdma directory?


In general, putting the transport providers in subdirectories is  
cleaner source organization, but both don't have to share the same  
subdirectory (though that would be my preference, fwiw).

It also helps because that source build module(s) separate from  
sunrpc, just like the GSS code, which is also in a subdirectory.

The socket transport provider could also be in a subdirectory, but it  
will always be included in the sunrpc module itself.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
