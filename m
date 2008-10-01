From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 03/10] lockd: Adjust nlmsvc_lookup_host() to accomodate AF_INET6 addresses
Date: Wed, 1 Oct 2008 11:59:08 -0400
Message-ID: <B3FCEBB6-0F3F-404A-95E8-8ECAA8030E8B@oracle.com>
References: <20080917161337.4963.74674.stgit@ellison.1015granger.net> <20080917161735.4963.86248.stgit@ellison.1015granger.net> <20080926221946.GE7138@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:57524 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbYJAP7X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Oct 2008 11:59:23 -0400
In-Reply-To: <20080926221946.GE7138@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 26, 2008, at Sep 26, 2008, 6:19 PM, J. Bruce Fields wrote:
> On Wed, Sep 17, 2008 at 11:17:35AM -0500, Chuck Lever wrote:
>> Fix up nlmsvc_lookup_host() to pass AF_INET6 source addresses to
>> nlm_lookup_host().
>>
>> To keep stack usage down, we use address-family-specific sockaddr_in
>> and sockaddr_in6 structures instead of sockaddr_storage where
>> appropriate.  The server-side supports only AF_INET and AF_INET6.
>
> Looks like there still is one sockaddr_storage on the stack.  That's  
> 128
> bytes.  Sounds doable, OK.
>
>> +/**
>> + * nlmsvc_lookup_host - Find an NLM host handle matching a remote  
>> client
>> + * @rqstp: incoming NLM request
>> + * @hostname: name of client host
>> + * @hostname_len: length of client hostname
>> + *
>> + * Returns an nlm_host structure that matches the [client address,
>> + * transport protocol, NLM version, client hostname] of the passed- 
>> in
>> + * NLM request.  If one doesn't already exist in the host cache, a
>> + * new handle is created and returned.
>> + *
>> + * Manufacture a specific source address in case the local system
>> + * services clients from multiple IP addresses.
>
> "Manufacture" makes it sound like we're faking one up somehow, but  
> we're
> actually just copying it from the svc_rqst, right?  Maybe make that
> "store the specific source address..." instead?

We really are faking it up, in a sense.  The svc_rqst does not store  
an address family for our source address, so we use an assumption  
(that our source address will always have the same family as the  
sender's address) to construct a full sockaddr.

How about "Construct a sockaddr for a specific source address, in case  
the
local system has multiple network addresses."

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
