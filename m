From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/4] nfsd: add support for NFSv4 callbacks over IPv6
Date: Wed, 17 Jun 2009 21:28:36 -0700
Message-ID: <FABC727F-1AE8-476A-8B79-593FD7E807B3@oracle.com>
References: <76bd70e30906171223r1f286d0eg1e64510f106d3027@mail.gmail.com> <20090617165522.73606206@tlielax.poochiereds.net> <76bd70e30906171432m29b3f179y6d0f2111e205114c@mail.gmail.com> <20090617210623.4c7860fb@tlielax.poochiereds.net>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:45064 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbZFRE26 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2009 00:28:58 -0400
In-Reply-To: <20090617210623.4c7860fb-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 17, 2009, at 6:06 PM, Jeff Layton wrote:

> On Wed, 17 Jun 2009 14:32:16 -0700
> Chuck Lever <chucklever@gmail.com> wrote:
>
>> On Wed, Jun 17, 2009 at 1:55 PM, Jeff Layton <jlayton@redhat.com>  
>> wrote:
>>
>>> Site local addresses are considered deprecated but AFAIK, they are
>>> indistinguishable from "normal" IPv6 addresses.
>>
>>
>> My impression was site-local addresses may also use a scope ID.
>
> I don't think so. Site local addresses are considered routable and
> should be unique within a "site". I think the intent with them was to
> provide an address space analogous to RFC 1918 addresses.

RFC 3879, which deprecates site local addresses, does discuss the  
concept of using a scope ID with a site-local address (to distinguish  
which site the address belongs to, as a router could be connected to  
two separate subnets that contain hosts with the same site-local  
address).  The wikipedia page you cite below indicates that the  
administrative oversight for ULAs has not been established yet.  So  
the deprecation may or may not be entirely premature.

Anyway, this is all pretty academic at this point.  By the time we get  
global IPv6 address support working, we may come back to do link-local  
and discover the standards have all been changed again.

> There should be no need for a scopeid with them since it's not likely
> that 2 interfaces would have the same subnet ID (doing so would be
> silly given the large address space) and site-local addresses are not
> autoconfigured like link-local ones.
>
> In any case, site-local is deprecated and is supposedly being replaced
> by ULA's which are also routable within cooperating sites:
>
> http://en.wikipedia.org/wiki/Unique_local_address
>
> AFAICT, ULA's also have no need for a scope id.
>
>>> They just have a
>>> designated prefix which should really only have meaning to  
>>> routers. I
>>> don't think that we have to do anything special in order to support
>>> them.
>>>
>>> We really can't reasonably support link-local addresses with this.  
>>> To
>>> use a link-local address you need to know the scopeid. That value  
>>> only
>>> has meaning within a single host. The client has no way to know what
>>> scopeid to send to the server, so it can't send that information  
>>> along
>>> in the callback address.
>>
>> Right.  The callback presentation address string passed via  
>> SETCLIENTID is
>> an RPC universal address, which doesn't have the ability to  
>> represent a
>> scope ID.  However, there are ways around this limitation.  An  
>> incoming
>> site- or link-local universal address in an RPCB_GETADDR inherits  
>> the scope
>> ID from the address used to send the RPCB_GETADDR request, for  
>> example.
>>
>
> Yes, that's the only real way to do that. At the end of the day (at
> least on linux and windows), scopeid == interface number.

That's one way to write a scope ID.  Another is to use a device name.   
Scope ID support, such as it is now in the NFS client, supports both.

> A machine
> will have no idea what the interface number will be in another  
> machine.
> Therefore that info can only reasonably be filled out by the host that
> intends to connect to the remote link-local address.
>
> What we should probably do here for the server is to make sure that
> when a SETCLIENTID call comes in, that we can get the number of the
> interface that received the call and then stuff that info into the
> scopeid if the clientaddr has a link-local prefix.
>
>>> knfsd *might* be able to look for link-local prefixes and  
>>> determine the
>>> scopeid if it knows what interface the connection came in on. I'm  
>>> not
>>> clear if that information bubbles up from the RPC layer however.
>>>
>>> I don't think there's anything in this work that prevents us from
>>> adding link local support later, but it'll probably take some  
>>> research
>>> and work to determine how to make it happen.
>>>
>>> There are client-side implications here too. We'll have to  
>>> consider how
>>> to generate callback addresses when the server's address is a
>>> link-local address (mostly, make sure you use the link-local  
>>> callback
>>> address for the correct interface).
>>
>> See mount.nfs.  It strips the scope ID off of link-local  
>> clientaddr=, and
>> assumes the server will know how to glue an appropriate scope ID  
>> back in.
>> (Or, it _should_ do that... it probably does something that only
>> approximates this now).
>
> That's probably the right thing to do.
>
> The only real trick for mount.nfs is to make sure that when the
> server's address is a link-local addr, that it autogenerates the
> clientaddr= with the link-local address of the interface that matches
> the provided scopeid.


mount.nfs relies on the network layer to do that, I think.  It  
connects a socket to the server address, then scrapes the source  
address off the connected socket.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
