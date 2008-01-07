From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 8/8] SUNRPC: fewer conditionals in the format_ip_address routines
Date: Mon, 7 Jan 2008 16:14:57 -0500
Message-ID: <D8111BA1-9189-4D53-AFFC-F232EA9D116E@oracle.com>
References: <20071220195518.3280.91282.stgit@manray.1015granger.net> <1199396736.1913.7.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:30777 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754118AbYAGVPM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jan 2008 16:15:12 -0500
In-Reply-To: <1199396736.1913.7.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

On Jan 3, 2008, at 4:45 PM, Trond Myklebust wrote:
> On Thu, 2007-12-20 at 14:55 -0500, Chuck Lever wrote:
>> Clean up: have the set up routines explicitly pass the strings to  
>> be used
>> for the transport name and NETID.  This removes a number of  
>> conditionals
>> and dependencies on rpc_xprt.prot, which is overloaded.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>
> NACK to this one. This whole premise of doing a kstrdup() on a  
> bunch of
> constants is silly. It's not as if we need to rewrite the contents of
> address_strings[FOO] every 2 seconds.
>
> If you're going to clean this up, then please do so by making
> address_strings be an array of 'const char *', and just have these
> entries point to the constants "udp", "udp6", "tcp", "tcp6" (just like
> RDMA already does).


Mixing statically and dynamically allocated strings in a char * array  
is poor coding practice.  In general, having more than one way to  
deallocate all the objects in an array of pointers is an invitation  
for problems down the road.

However, I will send you a version of this patch with the requested  
corrections later today.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
