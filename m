Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.sipwise.com ([92.42.136.241]:41944 "EHLO mx1.sipwise.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964853AbeALSOr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 12 Jan 2018 13:14:47 -0500
Date: Fri, 12 Jan 2018 19:05:28 +0100
From: Guillem Jover <gjover@sipwise.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Do not bind to reserved ports registered in /etc/services
Message-ID: <20180112180528.GA9479@thunder.hadrons.org>
References: <20180110004920.11100-1-gjover@sipwise.com>
 <49E44F63-42CF-4BF8-91E0-F89945D7CFE6@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <49E44F63-42CF-4BF8-91E0-F89945D7CFE6@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi!

On Thu, 2018-01-11 at 10:50:14 -0500, Chuck Lever wrote:
> On Jan 9, 2018, at 7:49 PM, Guillem Jover <gjover@sipwise.com> wrote:
> > When using the bindresvport() function a privileged port will be looked
> > for and bound to a socket. The problem is that any service using a static
> > privileged port registered in the /etc/services file, can get its port
> > taken over by libtirpc users, making the other service fail to start.
> > 
> > Starting the other service before libtircp users is not an option as
> > this does not cover restart situations, for example during package
> > upgrades or HA switchovers and similar.
> > 
> > In addition honoring the /etc/services registry is already done for
> > example by rpc.statd, so it seems obvious to make libtirpc follow this
> > same pattern too.
> 
> Does the glibc version of bindresvport(3) skip ports? I ask because
> this hasn't been a noted problem before. Which service exactly is
> causing the difficulty?

So, this is all a bit of a mess, and apparently it has been known in
some quarters for quite some time. :(

This was reported to glibc a long time ago [B] but at the time upstream
bogusly rejected the idea of using /etc/services (or similar). Instead
someone had to create a workaround to overcome this [P], a daemon which
binds to a port, until the other service requests the port to be released
so that it can itself bind to it, which is still obviously prone to races
during restarts and complicates things.

[B] <https://sourceware.org/bugzilla/show_bug.cgi?id=1014>
    <https://bugzilla.redhat.com/show_bug.cgi?id=103401>
    <https://bugzilla.novell.com/show_bug.cgi?id=262341>
    <https://bugs.debian.org/638322>
[P] <http://cyberelk.net/tim/software/portreserve/>

Then some distributions instead patched their glibc to honor a new
/etc/bindresvport.blacklist file in the bindresvport() function; OpenSUSE
at least, and apparently Debian too [F] (although this is not documented
anywhere). In addition nfs-utils upstream (where an rpc.statd comes from)
already honors /etc/services. To complicate things, rpcbind and other
SunRPC clients using libtirpc do not honor neither /etc/services nor
/etc/bindresvport.blacklist, because libtirpc has its own bindrecvport()
implementation.

[F] <https://sources.debian.org/src/glibc/2.26-3/debian/patches/any/local-bindresvport_blacklist.diff/>

On the above Debian bug report, it was proposed to make libtirpc switch
to use the libc bindresvport() implementation so that at least on those
distributions where it is locally patched it would honor the
/etc/bindresvport.blacklist file. The problem with this, is of course
that it does not help any upstream code on any other non-patched system.

So I decided against using the undocumented /etc/bindresvport.blacklist,
because that requires filling it up with ports that are already present
in /etc/services, which seems pointless. It does not support a fragments
style directory such as /etc/bindresvport.blacklist.d/ anyway which
makes "registering" the ports from each package too difficult. And
because nfs-utils' rpc.statd will honor /etc/services on any system
regardless of the libc implementation, which is not the case for
/etc/bindresvport.blacklist.

But at this point, if you disagree and prefer some other solution, I'm
happy to oblige, because I'd rather have anything at all. :)

> Usually applications that grab a privileged port are short-lived.
> statd is careful to avoid ports in /etc/services because it allocates
> one socket with a privileged port for contacting the kernel, and keeps
> it in place.

The other long-lived libtirpc instance that is causing problems for
us is rpcbind. And fixing this at the root seemed better than patching
just rpcbind.

> > diff --git a/src/bindresvport.c b/src/bindresvport.c
> > index 2d8f2bc..98e5f40 100644
> > --- a/src/bindresvport.c
> > +++ b/src/bindresvport.c
> > @@ -125,6 +129,25 @@ bindresvport_sa(sd, sa)
> >         }
> >         sa->sa_family = af;
> > 
> > +        so_proto_len = sizeof(so_proto);
> > +        if (getsockopt(sd, SOL_SOCKET, SO_PROTOCOL, &so_proto, &so_proto_len) == -1) {
> > +                mutex_unlock(&port_lock);
> > +                return -1;      /* errno is correctly set */
> > +        }
> > +        switch (so_proto) {
> > +        case IPPROTO_UDP:
> > +        case IPPROTO_UDPLITE:
> 
> What is UDPLITE?

<http://man7.org/linux/man-pages/man7/udplite.7.html>. I was trying to
make this as generic as possible, but checking again now, I guess this
might deserve a new protocol name in /etc/services anyway.

> Would it require a separate netid
> or other infrastructure? IMO it's not correct to add
> this transport protocol in this patch. If you resend,
> please remove this line.

Yeah, will drop it. The one not being handled because I was not sure
how, that does appear for example on /etc/services on a Debian system
is "ddp", but given that the library is for SunRPC there's not much
point in trying to handle that case here anyway.

Thanks,
Guillem
