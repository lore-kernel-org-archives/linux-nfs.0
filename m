From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] Bug 11061, NFS mounts dropped
Date: Tue, 17 Feb 2009 16:00:26 -0500
Message-ID: <ECC52203-3B12-44EF-B819-F7259CE482E4@oracle.com>
References: <1233459927.3112.54.camel@sibyl.beware.dropbear.id.au> <BD6791E5-9D82-4D42-8016-4731792CA5DA@oracle.com> <1233610918.3077.50.camel@sibyl.beware.dropbear.id.au> <157D0C13-65A3-412D-A266-EDFCF487F632@oracle.com> <1233698189.13862.16.camel@sibyl.beware.dropbear.id.au> <1233699391.7161.11.camel@heimdal.trondhjem.org> <91CE7AFB-2B15-4223-BE43-DF95ABC4B195@oracle.com> <1233771633.7161.35.camel@heimdal.trondhjem.org> <5552ED43-5E9C-4136-823D-DDDCF129DFAC@oracle.com> <1233773231.7161.51.camel@heimdal.trondhjem.org> <1234094116.13862.162.camel@sibyl.beware.dropbear.id.au> <7ED0098B-1D71-4E43-A8E4-D5859F13DD38@oracle.com> <1234355861.13862.239.camel@sibyl.beware.dropbear.id.au> <985DCB56-4365-40FC-B48D-43C28742908F@oracle.com> <1234402083.13862.273.camel@sibyl.beware.dropbear.id.au> <C7F
 F32B1-AF6D-470B-96DB-4BD77E90C50C@oracle.com> <1234711952.25265.34.camel@sibyl.beware.dropbear.id.au> <5E2B57AC-1977-449B-B595-354717A6ECD3@oracle.com> <1234872202.14585.33.camel@sibyl.bewa!
 re.dropbear.id.au>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:47961 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913AbZBQVAs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Feb 2009 16:00:48 -0500
In-Reply-To: <1234872202.14585.33.camel-+Zt617Lp5ASbJVK1MCa92ZvzqaJJnU0YunOrhLTifxA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 17, 2009, at Feb 17, 2009, 7:03 AM, Ian Dall wrote:
> On Mon, 2009-02-16 at 11:24 -0500, Chuck Lever wrote:
>> On Feb 15, 2009, at 10:32 AM, Ian Dall wrote:
>>
>>> I believe this includes all comments so far. I have also swatted  
>>> up on
>>> Documentation/CodingStyle, and modified the comments somewhat to
>>> conform.
>>
>> There is also a Perl script called scripts/checkpatch.pl that you
>> should run against your patch before submitting.  It can identify and
>> report many common style problems.
>
> Thanks for that, it threw up a few white space issues which I have
> fixed.
>
>
>> I've thought more about this.  I think we don't want the scope ID
>> comparison here at all.  The scope ID is not really part of an IPv6
>> address.  A unique host address is contained only in the sin6_addr
>> field; the scope ID is simply local routing information.  I can't
>> think of a case where two unique remotes would have identical link-
>> local addresses.
>
> Isn't that exactly what makes link local addresses, well, link local?
> They only have to be unique to the link (which seems to be in  
> practice a
> lan or vlan - a bunch of hosts connected without any routing at the ip
> level). They don't have to be globally unique. A single host can be on
> multiple lans or vlans.
>
> Finding anything authoritative on this is difficult. The RFC's are
> vague. However, following discussion on ietf mail archives, and other
> reasonably reputable sources like documentation from IBM, Sun and
> FreeBSD  makes me think that my interpretation is correct. Indeed, the
> way the BSD crowd seem to do it is to embed the scope_id in the link
> local address (internally to the kernel) and thence forth just compare
> the address. So they treat it *exactly* like part of the address.
>
> See for example:
>
> http://www.freebsd.org/doc/en/books/developers-handbook/ipv6.html  
> section 8.1.1.3.
>
> http://msdn.microsoft.com/en-us/library/ms739166(VS.85).aspx
>
> http://books.google.com/books?id=6nNjcItz6H4C&pg=PA53&lpg=PA53&dq=sin6_scope_id+%22link+local%22&source=bl&ots=MFyiwYwO5I&sig=hZDvlVcJ8hLOwt7EXoL4lEzT4V4&hl=en&ei=eqCaSdiGD8PDkAWskMmZCw&sa=X&oi=book_result&resnum=7&ct=result
>
> Note especially, section 1.8.1 "Since link local addresses may not be
> unique on different links ..."
>
> The only reasons I can see which would justify omitting the check are:
>
>      * For some reason you could never have a nfs server on a link
>        local address.

I should mention that this may be a problem for TI-RPC and NFSv4.   
There's currently no way to represent a scope ID in a universal  
address (the string used during rpcbind registration, or for sending  
the callback address to an NFSv4 server).  So, in that case, we may  
have to bail on link-local support entirely.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
