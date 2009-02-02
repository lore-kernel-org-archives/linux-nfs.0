From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] Bug 11061, NFS mounts dropped
Date: Mon, 2 Feb 2009 16:52:13 -0500
Message-ID: <157D0C13-65A3-412D-A266-EDFCF487F632@oracle.com>
References: <1233459927.3112.54.camel@sibyl.beware.dropbear.id.au> <BD6791E5-9D82-4D42-8016-4731792CA5DA@oracle.com> <1233610918.3077.50.camel@sibyl.beware.dropbear.id.au>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:22362 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754361AbZBBVw2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2009 16:52:28 -0500
In-Reply-To: <1233610918.3077.50.camel-+Zt617Lp5ASbJVK1MCa92ZvzqaJJnU0YunOrhLTifxA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 2, 2009, at Feb 2, 2009, 4:41 PM, Ian Dall wrote:
> On Mon, 2009-02-02 at 12:00 -0500, Chuck Lever wrote:
>> On Jan 31, 2009, at 10:45 PM, Ian Dall wrote:
>>> The following patch is relative to 2.6.29-rc3. The crux of the
>>> matter is
>>> that sock_addr structures can't be reliably compared using memcmp()
>>> because there are padding bytes in the structure which can't be
>>> guaranteed to be the same even when the sock_addr structures refer  
>>> to
>>> the same thing.
>>>
>>> There have been significant changes to the way address comparison is
>>> done in client.c since my original patch (Kernel Bug Tracker #11061,
>>> comment 19). In particular ipv4 addresses are now mapped to ipv6
>>> addresses for comparison (but only if the kernel is configured for
>>> IPV6). The conditional compilation blocks were quite big and  
>>> contained
>>> duplication. Adding my changes in their original style would have  
>>> only
>>> made matters worse. So I have taken to opportunity to clean up. By
>>> inverting the logic, I was able to reduce the depth of nested ifs,
>>> reduce the number of trivial helper functions and reduce the size of
>>> the
>>> conditional compilation blocks. This is a mater of opinion of  
>>> course,
>>> but I think the result is cleaner and easier to read and maintain.
>>>
>>> This has been tested with kernels configured with and without IPV6.
>>
>> As far as I can tell, this is only an issue in nfs_match_client(), so
>> there isn't any need to rewrite the other pieces.
>
> True. and I can do it that way easily enough if that is more  
> acceptable.
> However I felt it better to keep all the address comparison code with
> the switches on sa_family and compilation conditional on CONFIG_IPV6  
> etc
> together. That way it is less likely that something gets fixed in one
> place and not another and easier to add more network address types,
> should that be necessary at some time down the track. Also, there  
> would
> be a lack of symmetry in that nfs_match_client would then need to  
> "know"
> about the details of a sock_addr, whereas nfs_find_client and
> nfs_find_client_next can treat the sockaddr as an opaque object. Small
> points perhaps.

Simply define a helper near nfs_sockaddr_match_ipaddr(), included  
inside the "#if defined(CONFIG_IPV6)," that handles port comparison,  
and call that from nfs_match_client().

Eventually we will probably extract all of this address family- 
specific kruft into something that can be shared amongst all of the  
NFS-related components, so it will likely end up split out this way in  
any event.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
