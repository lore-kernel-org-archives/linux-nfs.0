From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Thu, 21 Aug 2008 16:46:20 -0400
Message-ID: <20080821204620.GD29466@fieldses.org>
References: <20080814223028.GN23859@fieldses.org> <52C9C44B-750E-437C-B3E8-380DB7371629@oracle.com> <20080820200827.GC21226@fieldses.org> <76bd70e30808201319j7b59de5gc912fcd01594e8@mail.gmail.com> <20080820204751.GE21226@fieldses.org> <76bd70e30808201419g5171d7eob7e6b57dd735e07d@mail.gmail.com> <20080820212902.GH21226@fieldses.org> <76bd70e30808201507l44c85d08o3ec4e8eeb7edda5e@mail.gmail.com> <20080820233024.GC28617@fieldses.org> <76bd70e30808201900r699ca044o884584ecedc6a799@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:55150 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752629AbYHUUqW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Aug 2008 16:46:22 -0400
In-Reply-To: <76bd70e30808201900r699ca044o884584ecedc6a799-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 20, 2008 at 10:00:25PM -0400, Chuck Lever wrote:
> On Wed, Aug 20, 2008 at 7:30 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Wed, Aug 20, 2008 at 06:07:50PM -0400, Chuck Lever wrote:
> >> What may be confusing you is that scope delimiters are used almost
> >> exclusively for link-local addresses, which are valid only on the
> >> local host.
> >>
> >> If you don't want to handle a referral that uses a link-local address,
> >> or you don't want to handle a link-local address with a scope ID, then
> >> there are explicit checks you can do.
> >
> > Well, the current code does allow a referral to point to 127.0.0.1.  I
> > don't know what to think of that; it seems unlikely to be useful for
> > anything but testing, and possibly succeptible to abuse, but of course
> > the protocol doesn't forbid it.
> 
> Link-local is not the same as loopback.
> 
> A link-local address is an address that is constructed by a
> standards-defined method for each active NIC on a host.  It is not a
> route-able address, so it's good only for the local subnet.  It's a
> method by which network service is exposed to higher levels in the
> network layer without having to use an external service like DHCP.
> It's a bootstrap address, more or less.
> 
> > I google around a bit, but still don't get the scope stuff.  Are they
> > really part of an "ipv6 address"?  I thought an ipv6 address was just a
> > 128-bit number?  (Or do they just give another way of writing something
> > that you could already write without the %?)
> 
> Unfortunately good IPv6 documentation is pretty hard to find.  There
> are a lot of RFCs that specify just a little corner of IPv6 (and even
> those usually have corrections or amendments in later RFCs), so it's
> difficult to know where to begin.  IPv6 is nearly a complete
> reconception of the internet, so many IPv4 concepts simply don't
> translate.  I don't think there's anything equivalent to a scope
> delimiter in IPv4.  The following is my understanding of how this
> works.
> 
> This is really a question of how to map a presentation format address
> (a string that represents the numeric form of the address, like
> dotted-quad notation) to a sockaddr.

OK, but what the v4 rfc says isn't that the fs_location field can
contain any representation of a sockaddr; it says that it can contain "a
traditional DNS host name, IPv4 address, or IPv6 address."

Every definition of "IPv6 address" I can find says that it's just the
128 bits you put in sin6_addr.  The scope id field, like a port number,
is something in addition.

So if we see such a string we should just assume it's garbage.

> The sockaddr_sin6 structure has a field for the scope ID,
> sin6_scope_id.  The % delimits the host address from a string that
> identifies a local NIC.  You can specify a device name, like "eth0,"
> or a number, which means the same thing.  The number is referred to as
> an interface index, or a scope ID.  The device name is converted by a
> locally-defined mechanism to a scope ID (the numeric equivalent) and
> stored in the sin6_scope_id field of a sockaddr_sin6.
>
> Link-local addresses require a specific NIC to be identified to work
> properly, even if there is only a single NIC on the host, since the
> "lo" virtual interface also has an interface index.  You can also use
> a scope ID with a non-link-local address to force which NIC is used.
> By and large, these interface indices are not meaningful anywhere but
> on the host that has that link-local address assigned to one of its
> NICs.

OK, so that definitely doesn't sound like something that makes sense
outside the client.

> It really depends on how the referral hostname string is generated,
> but I would say that whatever follows the % should be ignored, or you
> could generate a warning or error.

So I think we should be harsher and just not attempt to parse a string
that looks like this at all.

--b.

> You can let the existing super.c
> address parser handle the '%' and check to see if sin6_scope_id is
> non-zero on return (or just zero it unconditionally if you want to
> ignore these altogether).  If the NFSv4 standard doesn't say anything
> about IPv6 interface IDs, then I suppose we are free to treat this any
> way we think is reasonable.
> 
> I'm still not quite sure how to handle link-local addresses for NFSv4
> callback, for example.  Generally it doesn't make sense to hand the
> server an interface ID that is valid only on the client, so mount.nfs
> just strips the interface ID when generating the callback IP address
> string: it won't pass a scope-delimited presentation format address in
> the clientaddr= option.
> 
> For a link-local callback address, the server then must determine
> which of its own interfaces it must use to contact the client via that
> link-local address, and append it via a % or by setting the
> sin6_scope_id field.  Or it can simply decide not to call a client
> back that passed it a link-local address as a callback address.
> 
> -- 
> Chuck Lever
