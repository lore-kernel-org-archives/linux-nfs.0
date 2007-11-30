From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 0/8] RDMA Transport Provider
Date: Fri, 30 Nov 2007 15:48:27 -0500
Message-ID: <A307DF7F-F230-4178-B64E-D6E5AEFA4462@oracle.com>
References: <20071129224412.14887.14136.stgit@dell3.ogc.int> <20071130044553.GA29851@fieldses.org> <1196438368.5432.10.camel@trinity.ogc.int> <20071130171649.GC14943@fieldses.org> <1196451693.5432.35.camel@trinity.ogc.int>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:39428 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090AbXK3Usq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Nov 2007 15:48:46 -0500
In-Reply-To: <1196451693.5432.35.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 30, 2007, at 2:41 PM, Tom Tucker wrote:
> On Fri, 2007-11-30 at 12:16 -0500, J. Bruce Fields wrote:
>> On Fri, Nov 30, 2007 at 09:59:28AM -0600, Tom Tucker wrote:
>>>
> [...snip...]
>>>
>>> I'm mystified as to why I didn't get these warnings. I built on a  
>>> 64 bit
>>> machine. It seems like that would give the warning since unsigned  
>>> long
>>> isn't even the same size as int.
>>
>> Yeah, I can't see how any compiler could miss that.  How do you  
>> usually
>> build?
>
>> From emacs on my desktop...
>
> ssh root@victim "cd /home/tom/src/linux-2.6 && ntpdate <servername>  
> && make && make modules_install && make install"
>
> The target system is an AMD64. Here's uname -a...
>
> Linux demo1 2.6.24-rc3-merged-svc #12 SMP Fri Nov 30 08:51:15 CST  
> 2007 x86_64 x86_64 x86_64 GNU/Linux
>
> The compiler version..
>
> gcc version 4.1.1 20070105 (Red Hat 4.1.1-52)
>
> The output after changing the type back to int ...
>
> ssh root@demo1 "cd /home/tom/src/linux-2.6 && ntpdate dell3 && make"
> 30 Nov 11:21:38 ntpdate[4155]: step time server 10.10.0.102 offset  
> -1.150670 sec
>   CHK     include/linux/version.h
>   CHK     include/linux/utsrelease.h
>   CALL    scripts/checksyscalls.sh
>   CHK     include/linux/compile.h
>   CC [M]  net/sunrpc/svc_rdma.o
>   CC [M]  net/sunrpc/svc_rdma_transport.o
>   CC [M]  net/sunrpc/svc_rdma_marshal.o
>   CC [M]  net/sunrpc/svc_rdma_sendto.o
>   CC [M]  net/sunrpc/svc_rdma_recvfrom.o
>   LD [M]  net/sunrpc/sunrpc.o
>   LD [M]  net/sunrpc/svcrdma.o
> Kernel: arch/x86/boot/bzImage is ready  (#12)
>   Building modules, stage 2.
>   MODPOST 1294 modules
>   LD [M]  net/sunrpc/sunrpc.ko
>   LD [M]  net/sunrpc/svcrdma.ko
>
> No warning...

I've found that gcc on x86_64 tends to be "more forgiving."  I get a  
lot more warnings on x86.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



