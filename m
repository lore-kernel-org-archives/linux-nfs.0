From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 08/10] lockd: struct nlm_reboot should contain a full socket address
Date: Wed, 1 Oct 2008 16:42:51 -0400
Message-ID: <DD686EBC-B11C-4BBF-8BBC-1A6504290132@oracle.com>
References: <20080917161337.4963.74674.stgit@ellison.1015granger.net> <20080917161811.4963.60224.stgit@ellison.1015granger.net> <20080926230938.GK7138@fieldses.org> <E908BC09-5443-440E-9402-E2E319A3BD8E@oracle.com> <20081001181801.GF6001@fieldses.org> <59C7F69A-58EA-41F9-888E-C11039302755@oracle.com> <20081001200839.GB10937@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:15875 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752070AbYJAUnH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Oct 2008 16:43:07 -0400
In-Reply-To: <20081001200839.GB10937@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 1, 2008, at Oct 1, 2008, 4:08 PM, J. Bruce Fields wrote:
> On Wed, Oct 01, 2008 at 03:40:05PM -0400, Chuck Lever wrote:
>> On Oct 1, 2008, at Oct 1, 2008, 2:18 PM, J. Bruce Fields wrote:
>>> On Wed, Oct 01, 2008 at 12:17:02PM -0400, Chuck Lever wrote:
>>>> On Sep 26, 2008, at Sep 26, 2008, 7:09 PM, J. Bruce Fields wrote:
>>>>> On Wed, Sep 17, 2008 at 11:18:11AM -0500, Chuck Lever wrote:
>>>>>> The XDR decoders for the NSM NOTIFY procedure should construct a
>>>>>> full
>>>>>> socket address and store it in the nlm_reboot structure.  In
>>>>>> addition
>>>>>> to being able to store larger addresses, this means upper layer
>>>>>> routines get an address family tag so they can distinguish  
>>>>>> between
>>>>>> AF_INET and AF_INET6 addresses.
>>>>>>
>>>>>> This also keeps potentially large socket addresses off the stack
>>>>>> and
>>>>>> instead in dynamically allocated storage.
>>>>>
>>>>> So one way to think of this would be that you're extending the
>>>>> kernel<->statd interface by using the address family of statd's
>>>>> notify
>>>>> call to communicate the address family of the host that rebooted.
>>>>>
>>>>> Do I have that right?
>>>>
>>>> For statd, we're using the same technique that we used when
>>>> constructing
>>>> the source address in nlmsvc_lookup_host().  There's no family tag
>>>> associated with the address because the 16-byte opaque in the on-
>>>> the-wire
>>>> format has room only for the sin6_addr part of the address.
>>>
>>> OK.  It seems a bit tricky, but I can't see why it doesn't work.
>>
>> Right.  I couldn't think of something simpler.
>>
>> rpc.statd has to continue to work with legacy kernels where the  
>> first 4
>> bytes of the opaque are a 32-bit sin_addr field and the following 12
>> bytes are zero.
>
> Wait a minute, there's something not right there: rpc.statd shouldn't
> interpret the contents of the opaque field at all, should it?

Yes, our rpc.statd and lockd should agree on the contents and  
interpretation of the opaque field.  The field is opaque because it's  
internal content is not defined by a standard.  It's a cookie, just  
like a file handle.

I would certainly *prefer* the use of an entirely arbitrary cookie,  
but that's not the way Linux happens to work today.

>> Apparently you can have a valid IPv6 address that looks
>> like that, but I can't find anything that states this conclusively.
>>
>> The kernel needs to know the address family in order to interpret the
>> contents of the opaque and turn them back into a sockaddr so it can  
>> be
>> matched against an nlm_host.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
