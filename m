From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfs over ipv6 support
Date: Fri, 14 Mar 2008 10:45:37 -0400
Message-ID: <8E101D4F-7A8E-4589-9664-808E3A6512EC@oracle.com>
References: <206342.91146.qm@web30507.mail.mud.yahoo.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org, aime.le-rouzic@bull.net,
	aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, gilles.quillard@bull.net
To: Rajesham Gajjela <rajeshamg@yahoo.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:40739 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756867AbYCNOq0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 10:46:26 -0400
In-Reply-To: <206342.91146.qm-uHTUF03blOmvuULXzWHTWIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 13, 2008, at 9:00 PM, Rajesham Gajjela wrote:
> Thanks Chuck for the quick reply.
>  - this support is not there even in latest
>    kernels (2.6.24 and such) ?

IPv6 support in Linux NFS is not complete even in the latest upstream  
kernels, although more of it has been filled in than existed in the  
2.6.12 patches.

>  - Whats is your plan on this ? Do you think,
>    it can be done any time soon ?

I gave a short presentation at LSF '08 a couple of weeks ago  
describing progress and plans:

   http://oss.oracle.com/~cel/LSF-08-NFS-IPv6.pdf

The slides are rather sparse, but there was hand waving that went  
with the slides.

> --- Chuck Lever <chuck.lever@oracle.com> wrote:
>
>> Rajesham-
>>
>> IPv6 is not supported for NFS.  The code you are
>> looking at is a
>> development snapshot.
>>
>> On Mar 13, 2008, at 10:31 AM, Rajesham Gajjela
>> wrote:
>>>> Mar 13 19:32:20 DXi5500-12345 kernel: RPC:
>> transport
>>>> (2/17) not supported
>>>
>>> After looking at the code
>> (include/linux/socket.h):
>>> #define AF_INET         2       /* Internet IP
>>> Protocol         */
>>>
>>> include/linux/in.h:
>>>   IPPROTO_UDP = 17,             /* User Datagram
>>> Protocol               */
>>>
>>> Why 2/17 (which is AF_INET/IPPROTO_UDP) not
>>> registered ?
>>>
>>> Looking at the register code:
>> net/sunrpc/xprtsock.c:
>>> static int __init init_xs_transport(void)
>>> {
>>>         xprt_register(&xs_udp4_type);
>>> #if defined(CONFIG_IPV6) ||
>>> defined(CONFIG_IPV6_MODULE)
>>>         xprt_register(&xs_udp6_type);
>>> #endif
>>>         xprt_register(&xs_tcp4_type);
>>> #if defined(CONFIG_IPV6) ||
>>> defined(CONFIG_IPV6_MODULE)
>>>         xprt_register(&xs_tcp6_type);
>>> }
>>>
>>> The above code must add to "xprt_list". Note that,
>>> I configured my kernel with CONFIG_IPV6.
>>>
>>>
>>>
>>> --- Rajesham Gajjela <rajeshamg@yahoo.com> wrote:
>>>
>>>>
>>>> Did any body test nfs (v2 and v3) over ipv6 ?
>>>> do you guys claim "this feature suppose to work"
>> ?
>>>>
>>>> It did not work for me. Here are the details of
>>>> experiments I did (for me server and client is
>>>> same):
>>>>
>>>> 1) Kernel side : Linux-2.6.12-5 +
>>>>       linux-2.6.12-rc6-CITI_NFS4_ALL-1.dif +
>>>>       Chuck Lever Transport Patch
>>>>
>>>
>>
> (http://oss.oracle.com/~cel/linux-2.6/2.6.12/release-notes.html)
>>>>
>>>> 2) User land (tools) side: libtirpc-0.1.7-1 +
>>>>      rpcbind-0.1.4 + nfs-utils-1.1.1 +
>> quota-3.12-5
>>>> (Ref:
>>>>
>>>
>>
> http://nfsv4.bullopensource.org/patches/nfsv4_ipv6-2)
>>>>
>>>> 3) rpcbind suppose to recognize ipv6/ipv4 tcp/udp
>>>>    protocols (after modifying /etc/netconfig). I
>> did
>>>>
>>>>    softlink of /usr/bin/rpcbind to
>> /sbin/portmap).
>>>>    Then did "service portmap restart".
>>>>    Then "service nfs restart". NFS services
>> failed.
>>>>
>>>> syslog messages:
>>>>
>>>> Mar 13 19:32:20 DXi5500-12345 nfs: Starting NFS
>>>> services:  succeeded
>>>> Mar 13 19:32:20 DXi5500-12345 nfs: rpc.rquotad
>>>> startup
>>>> succeeded
>>>> Mar 13 19:32:20 DXi5500-12345 kernel: RPC:
>> transport
>>>> (2/17) not supported
>>>> Mar 13 19:32:20 DXi5500-12345 last message
>> repeated
>>>> 2
>>>> times
>>>> Mar 13 19:32:20 DXi5500-12345 nfsd[12453]:
>> nfssvc:
>>>> Input/output error
>>>> Mar 13 19:32:20 DXi5500-12345 nfs: rpc.nfsd
>> startup
>>>> failed
>>>> Mar 13 19:32:20 DXi5500-12345 nfs: rpc.mountd
>>>> startup
>>>> succeeded
>>>> Mar 13 19:32:20 DXi5500-12345 rpc.idmapd:
>>>> nfsdreopen:
>>>> Opening '/proc/net/rpc/nfs4.idtoname/channel'
>>>> failed:
>>>> errno 2 (No such file or directory)
>>>> Mar 13 19:32:20 DXi5500-12345 rpc.idmapd:
>>>> nfsdreopen:
>>>> Opening '/proc/net/rpc/nfs4.nametoid/channel'
>>>> failed:
>>>> errno 2 (No such file or directory)
>>>> Mar 13 19:32:20 DXi5500-12345 rpcidmapd:
>> rpc.idmapd
>>>> -SIGHUP succeeded
>>>>
>>>>
>>>>
>>>>
>>>>
>>>
>>
> ______________________________________________________________________
>>
>>> ______________
>>>> Never miss a thing.  Make Yahoo your home page.
>>>> http://www.yahoo.com/r/hs
>>>>
>>>
>>>
>>>
>>>
>>>
>>
> ______________________________________________________________________
>>
>>> ______________
>>> Never miss a thing.  Make Yahoo your home page.
>>> http://www.yahoo.com/r/hs
>>> --
>>> To unsubscribe from this list: send the line
>> "unsubscribe linux-
>>> nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at
>> http://vger.kernel.org/majordomo-info.html
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line
>> "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at
>> http://vger.kernel.org/majordomo-info.html
>>
>
>
>
>        
> ______________________________________________________________________ 
> ______________
> Never miss a thing.  Make Yahoo your home page.
> http://www.yahoo.com/r/hs

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



