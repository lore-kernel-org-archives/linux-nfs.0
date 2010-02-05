From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] mount.nfs: set the default family for lookups based on
 Defaultproto= setting
Date: Fri, 5 Feb 2010 16:20:18 -0500
Message-ID: <20100205162018.41ea79d8@tlielax.poochiereds.net>
References: <1265380055-5650-1-git-send-email-jlayton@redhat.com>
	<4B6C39D0.3030704@oracle.com>
	<20100205113052.333f0c05@tlielax.poochiereds.net>
	<4B6C51A4.3070005@oracle.com>
	<20100205124340.6b77902c@tlielax.poochiereds.net>
	<4B6C5F61.9070205@oracle.com>
	<20100205131757.6fd224d0@tlielax.poochiereds.net>
	<20100205145530.61634593@tlielax.poochiereds.net>
	<4B6C78A2.5010703@oracle.com>
	<20100205150511.5e18538f@tlielax.poochiereds.net>
	<4B6C7EB4.9090307@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40816 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751546Ab0BEVUd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Feb 2010 16:20:33 -0500
In-Reply-To: <4B6C7EB4.9090307@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 05 Feb 2010 15:25:24 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> On 02/05/2010 03:05 PM, Jeff Layton wrote:
> > On Fri, 05 Feb 2010 14:59:30 -0500
> > Chuck Lever<chuck.lever@oracle.com>  wrote:
> >
> >> On 02/05/2010 02:55 PM, Jeff Layton wrote:
> >>> On Fri, 5 Feb 2010 13:17:57 -0500
> >>> Jeff Layton<jlayton@redhat.com>   wrote:
> >>>
> >>>>>> I can sort of buy the argument for leaving out the earlier #ifdef
> >>>>>> around the default_value() function.
> >>>>>>
> >>>>>> If you change this one though, then lookups will still return IPv6
> >>>>>> addresses by default even when IPV6_SUPPORTED isn't set. IOW, in the
> >>>>>> absence of a proto= option, you'll pass AF_UNSPEC to getaddrinfo and
> >>>>>> get IPv6 addresses. I don't think that's what we want here for a
> >>>>>> non-ipv6 enabled nfs-utils.
> >>>>>
> >>>>> OK, agreed.  This setting is actually not determining the meaning of any
> >>>>> of the netids, but rather it is determining the default address family
> >>>>> if _no_ netid is specified.
> >>>>>
> >>>>
> >>>> Correct. Ok, I'll respin and repost with the ifdef's in default_value()
> >>>> removed.
> >>>
> >>> New patch sent. Just for giggles, I tested this by building a
> >>> tirpc-enabled/ipv6-disabled nfs-utils and setting Defaultproto=tcp6. It
> >>> does indeed set the address family to IPv6:
> >>>
> >>> # mount -v opensolaris:/export/public /mnt/test
> >>> mount: no type was given - I'll assume nfs because of the colon
> >>> mount.nfs: timeout set for Fri Feb  5 14:51:01 2010
> >>> mount.nfs: trying text-based options 'vers=4,addr=feed::23,clientaddr=feed::22'
> >>>
> >>> ...and the mount succeeds.
> >>>
> >>> So in that situation and also when proto=tcp6 is specified, someone can
> >>> mount an IPv6-capable server even with a nfs-utils that isn't built for
> >>> IPv6 as long as it has tirpc support.
> >>>
> >>> Is that a good thing? I'm not sure -- statd won't work over IPv6 in
> >>> that case, for instance. Would it be better to have mount.nfs fail to
> >>> use IPv6 addrs at all when not built with IPv6 support?
> >>
> >> If IPv6 support is disabled at build time, mount.nfs shouldn't allow a
> >> mount over IPv6, even if the kernel supports it.
> >>
> >> Is that with, or without, my additional protocol family negotiation patches?
> >>
> >
> > With those patches. I haven't tested this without them.
> 
> Ah, I see... you are not talking about by default.
> 
> In that case, you probably want nfs_{nfs,mount}_proto_family to return 
> FALSE if nfs_get_proto returns AF_INET6 and IPV6_SUPPORTED is not defined.
> 
> /me winces
> 
> That would be a separate fix from your config file patch.
> 

If we do that, then in the hypothetical scenario above (someone
specifies Defaultproto=tcp6 in the config file and has a
tirpc-enabled/ipv6-disabled nfs-utils), then their mounts will always
fail unless they override that setting with a proto= option.

Is that the behavior we want here?

(/me struggles not to get lost in the twisty maze of options)
-- 
Jeff Layton <jlayton@redhat.com>
