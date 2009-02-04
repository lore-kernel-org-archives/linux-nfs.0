From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] Bug 11061, NFS mounts dropped
Date: Wed, 4 Feb 2009 13:44:00 -0500
Message-ID: <5552ED43-5E9C-4136-823D-DDDCF129DFAC@oracle.com>
References: <1233459927.3112.54.camel@sibyl.beware.dropbear.id.au> <BD6791E5-9D82-4D42-8016-4731792CA5DA@oracle.com> <1233610918.3077.50.camel@sibyl.beware.dropbear.id.au> <157D0C13-65A3-412D-A266-EDFCF487F632@oracle.com> <1233698189.13862.16.camel@sibyl.beware.dropbear.id.au> <1233699391.7161.11.camel@heimdal.trondhjem.org> <91CE7AFB-2B15-4223-BE43-DF95ABC4B195@oracle.com> <1233771633.7161.35.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:54427 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760303AbZBDSoU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2009 13:44:20 -0500
In-Reply-To: <1233771633.7161.35.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 4, 2009, at Feb 4, 2009, 1:20 PM, Trond Myklebust wrote:
> On Wed, 2009-02-04 at 10:59 -0500, Chuck Lever wrote:
>> On Feb 3, 2009, at Feb 3, 2009, 5:16 PM, Trond Myklebust wrote:
>>> On Wed, 2009-02-04 at 08:26 +1030, Ian Dall wrote:
>>>> On Mon, 2009-02-02 at 16:52 -0500, Chuck Lever wrote:
>>>>
>>>>> Simply define a helper near nfs_sockaddr_match_ipaddr(), included
>>>>> inside the "#if defined(CONFIG_IPV6)," that handles port  
>>>>> comparison,
>>>>> and call that from nfs_match_client().
>>>>>
>>>>> Eventually we will probably extract all of this address family-
>>>>> specific kruft into something that can be shared amongst all of  
>>>>> the
>>>>> NFS-related components, so it will likely end up split out this
>>>>> way in
>>>>> any event.
>>>>
>>>> OK here is version 2 of the patch. It is half the size of version  
>>>> 1,
>>>> although the resultant client.c is slightly bigger and IMO slightly
>>>> inferior than for version 1, but certainly it is around the margin.
>>
>> Trond, how come 9082a5cc doesn't change nfs_match_client() to use
>> mapped-IPv4 address comparison?  Was that just an oversight, or do
>> these two functions really require different address comparison  
>> methods?
>
> It wasn't an oversight. I figure that if someone is mounting using a
> mapped IPv4 address, then they want to use an IPv6 socket, hence I
> preferred not to touch nfs_match_client().
>
> OTOH, nfs_find_client() is used only by the callback channel, which
> doesn't distinguish between requests made over IPv4 and IPv6.

Right.  So, then, can nfs_match_client() use the same address  
comparison method as nfs_find_client()?  I'm inclined to think  
nfs_match_client() can use a more straightforward address comparison  
method.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
