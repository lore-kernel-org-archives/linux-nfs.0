From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] Bug 11061, NFS mounts dropped
Date: Tue, 17 Feb 2009 12:29:14 -0500
Message-ID: <30C44273-7011-46AD-B79B-FCD06E9F25FE@oracle.com>
References: <1233459927.3112.54.camel@sibyl.beware.dropbear.id.au> <BD6791E5-9D82-4D42-8016-4731792CA5DA@oracle.com> <1233610918.3077.50.camel@sibyl.beware.dropbear.id.au> <157D0C13-65A3-412D-A266-EDFCF487F632@oracle.com> <1233698189.13862.16.camel@sibyl.beware.dropbear.id.au> <1233699391.7161.11.camel@heimdal.trondhjem.org> <91CE7AFB-2B15-4223-BE43-DF95ABC4B195@oracle.com> <1233771633.7161.35.camel@heimdal.trondhjem.org> <5552ED43-5E9C-4136-823D-DDDCF129DFAC@oracle.com> <1233773231.7161.51.camel@heimdal.trondhjem.org> <1234094116.13862.162.camel@sibyl.beware.dropbear.id.au> <7ED0098B-1D71-4E43-A8E4-D5859F13DD38@oracle.com> <1234355861.13862.239.camel@sibyl.beware.dropbear.id.au> <985DCB56-4365-40FC-B48D-43C28742908F@oracle.com> <1234402083.13862.273.camel@sibyl.beware.dropbear.id.au> <C7F
 F32B1-AF6D-470B-96DB-4BD77E90C50C@oracle.com> <1234711952.25265.34.camel@sibyl.beware.dropbear.id.au> <5E2B57AC-1977-449B-B595-354717A6ECD3@oracle.com> <1234872202.14585.33.camel@sibyl.bewa!
 re.dropbear.id.au>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:46027 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752761AbZBQR3r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Feb 2009 12:29:47 -0500
In-Reply-To: <1234872202.14585.33.camel-+Zt617Lp5ASbJVK1MCa92ZvzqaJJnU0YunOrhLTifxA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Ian-

On Feb 17, 2009, at Feb 17, 2009, 7:03 AM, Ian Dall wrote:
> On Mon, 2009-02-16 at 11:24 -0500, Chuck Lever wrote:
>>
>> I've thought more about this.  I think we don't want the scope ID
>> comparison here at all.  The scope ID is not really part of an IPv6
>> address.  A unique host address is contained only in the sin6_addr
>> field; the scope ID is simply local routing information.  I can't
>> think of a case where two unique remotes would have identical link-
>> local addresses.
>
> Isn't that exactly what makes link local addresses, well, link local?

No, an IPv6 address is link-local by virtue of having the  
IPV6_ADDR_LINKLOCAL bit set.  Scope IDs came along later.

> They only have to be unique to the link (which seems to be in  
> practice a
> lan or vlan - a bunch of hosts connected without any routing at the ip
> level). They don't have to be globally unique. A single host can be on
> multiple lans or vlans.

Generally the way a link-local address is formed on Linux is by using  
the link's MAC address to form a unique 64-bit EUID, and concatenating  
that to a standard link-local prefix, usually fe80:: .  Each NIC on a  
host therefore has it's own link-local address, generally speaking.

Now, that's certainly not the only way a link-local address can be  
constructed, but this way has the benefit that each NIC (link) on a  
host has a unique link-local address.  So, these addresses,  
practically speaking, happen to be fairly globally unique as long as  
NIC vendors adhere to the guidelines around selecting MAC addresses.

> Finding anything authoritative on this is difficult. The RFC's are
> vague.

Agreed, and I don't claim to be an authority on this either.

> However, following discussion on ietf mail archives, and other
> reasonably reputable sources like documentation from IBM, Sun and
> FreeBSD  makes me think that my interpretation is correct. Indeed, the
> way the BSD crowd seem to do it is to embed the scope_id in the link
> local address (internally to the kernel) and thence forth just compare
> the address. So they treat it *exactly* like part of the address.

On Linux, the scope ID is embedded in presentation format addresses  
with a "%n" or "%dev" suffix.  For socket addresses, it is placed in  
the scope ID field.

I haven't looked at the BSD IPv6 implementation, but there may be  
other reasons for embedding a scope ID in the address (for example,  
this could be an artifact of how link-local addresses behaved before  
there was a separate scope ID field in sockaddr_in6).  I don't see  
this as a convincing argument that this is correct for Linux.

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

Does that imply that unique hosts can have the same link-local  
address, or simply that the same link-local address is permitted to  
appear on different links?  Is it a practical configuration (ie  
something that would be widely deployed) to maintain server hosts with  
the same link-local address on different links?

The point of nfs_match_client is to detect when a mount is going to  
the same server.  If the address is the same, but the scope ID is  
different, do we know that necessarily means these are two distinct  
hosts?

A single server can have multiple NICs, and thus multiple link-local  
addresses.  In general a multi-homed server will always defeat the  
address check in nfs_match_client, so it's not a perfect world in any  
case.

> The only reasons I can see which would justify omitting the check are:
>
>      * For some reason you could never have a nfs server on a link
>        local address.

We specifically want to support accessing link-local servers to allow  
admins to "kick the tires" without assigning real IPv6 addresses.   
Perhaps it even makes sense for a private storage-area network  
configuration, where IPv6 addresses are assigned to clients and  
servers entirely automatically and without router advertisement or  
DHCPv6.

>      * Linux already embeds the scope index in the address for link
>        local addresses, internally in the kernel a la BSD. Which I can
>        find no evidence for either in the code or in documentation.

As far as I know, the scope ID is used on Linux to determine which  
local link is used to access a host.

> There is also the issue that sin6_scope_id == 0 is interpreted as
> "unspecified" rather than a specific id. However, as far as I can  
> tell,
> the scope_id is only ever unspecified (for link_local addresses)  
> before
> a socket is bound. Once a connection is established, the scope id for
> link local addresses should always be specified. So by the time this
> function is called, the scope_id should be set.

I think the correct way to proceed here is to address the original  
problem without adding the scope ID check, then explore the scope ID  
issue separately.  The presenting problem in 11061 affects IPv4  
addresses too if I'm not mistaken, and IPv4 is fairly widely deployed,  
so it needs to be fixed now.

If scope ID matching is a problem in nfs_match_client, then it is also  
an issue for other places in the NFS client, and should be fixed in  
all those places at once, in a single patch that documents the scope  
ID matching requirement.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
