From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] Bug 11061, NFS mounts dropped
Date: Thu, 12 Feb 2009 09:37:28 -0500
Message-ID: <C7FF32B1-AF6D-470B-96DB-4BD77E90C50C@oracle.com>
References: <1233459927.3112.54.camel@sibyl.beware.dropbear.id.au> <BD6791E5-9D82-4D42-8016-4731792CA5DA@oracle.com> <1233610918.3077.50.camel@sibyl.beware.dropbear.id.au> <157D0C13-65A3-412D-A266-EDFCF487F632@oracle.com> <1233698189.13862.16.camel@sibyl.beware.dropbear.id.au> <1233699391.7161.11.camel@heimdal.trondhjem.org> <91CE7AFB-2B15-4223-BE43-DF95ABC4B195@oracle.com> <1233771633.7161.35.camel@heimdal.trondhjem.org> <5552ED43-5E9C-4136-823D-DDDCF129DFAC@oracle.com> <1233773231.7161.51.camel@heimdal.trondhjem.org> <1234094116.13862.162.camel@sibyl.beware.dropbear.id.au> <7ED0098B-1D71-4E43-A8E4-D5859F13DD38@oracle.com> <1234355861.13862.239.camel@sibyl.beware.dropbear.id.au> <985DCB56-4365-40FC-B48D-43C28742908F@oracle.com> <1234402083.13862.273.camel@sibyl.beware.dropbear.id.au>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:20425 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755993AbZBLOho (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Feb 2009 09:37:44 -0500
In-Reply-To: <1234402083.13862.273.camel-+Zt617Lp5ASbJVK1MCa92ZvzqaJJnU0YunOrhLTifxA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 11, 2009, at 8:28 PM, Ian Dall wrote:
> On Wed, 2009-02-11 at 11:24 -0500, Chuck Lever wrote:
>
>>> +	/* Compare scope_id. This may only matter for link local
>>> +	 * addresses, but it is cheap, and should be harmless, to just
>>> +	 * compare it anyway.
>>> +	 */
>>> +	if (saddr1->sin6_scope_id != saddr2->sin6_scope_id)
>>> +		return 0;
>>
>> I've been thinking about this a bit over the past couple of days.   
>> I'm
>> not yet sure we need this comparison here, but I also don't think  
>> it's
>> harmless to just leave it in.
>
> As I understand it, it is allowed for a host to see two identical link
> local addresses which are on different interfaces but refer to  
> different
> servers, so it would need to be in for the case of link local  
> addresses.
> But in other cases it is not clear and unfortunately RFC 3493 if not
> very helpful on the subject. But non link-local addresses should be
> unique so at least it would be safe to not test it in those cases.
>
>> If you really want to include this particular comparison, it would be
>> better IMO if you check the equivalence of the scope ID fields only  
>> if
>> the addresses are link-local.
>
> This seems like the safest course of action.
>
> With these changes, the nfs_sockaddr_cmp_ip6 function is starting to
> become significant. I was trying to avoid it, but should it be  
> within a
>
>        #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)  ...
>        #endif
>
> block? Someone wanting a minimal (maybe embedded) kernel might  
> object to
> the "bloat".

Define bloat -- can you report object code sizes on a couple of common  
hardware platforms?  I wouldn't expect this new routine to add more  
than a few tens of bytes of instructions.

>>> +	return (saddr1->sin6_port == saddr2->sin6_port);
>>
>> The parentheses are not needed here.
>
> I know, but are they frowned upon? AFAIK there is no shortage of
> parentheses and they often make things clearer even when redundant.

See below.

>> Kernel C coding style frowns on the space between the function name
>> and the argument list.
>
> Is there a style guide or is it more of an osmosis thing?  
> Stylistically,
> there are lots of things I'd do differently (4 character indents for a
> start) but I try and conform with existing practice. Reading the
> existing code isn't always a good guide though.

They have evolved over time, so not all of the kernel is consistent  
with current practices which you can read about here:

   Documentation/CodingStyle

I don't see a specific missive about return values, but the code  
example in Chapter 6 is to the point.  I know that Trond (the NFS  
maintainer) prefers no parens on return values.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
