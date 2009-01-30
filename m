From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 1/7] lockd: Use AF_INET6 listener only when IPv6
 support is built in
Date: Fri, 30 Jan 2009 17:49:42 -0500
Message-ID: <1233355782.9741.95.camel@heimdal.trondhjem.org>
References: <20090130200021.22301.22618.stgit@ingres.1015granger.net>
	 <20090130201041.22301.60941.stgit@ingres.1015granger.net>
	 <1233347546.9741.31.camel@heimdal.trondhjem.org>
	 <130964B3-CDE1-440F-B0E0-33620036E239@oracle.com>
	 <1233350290.9741.42.camel@heimdal.trondhjem.org>
	 <F0ED35C3-3E01-42E2-BE71-1C1273C1B495@oracle.com>
	 <1233352740.9741.64.camel@heimdal.trondhjem.org>
	 <59D3726F-FB24-4624-891F-55877239B011@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:44423 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753004AbZA3Wtt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Jan 2009 17:49:49 -0500
In-Reply-To: <59D3726F-FB24-4624-891F-55877239B011@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-01-30 at 17:27 -0500, Chuck Lever wrote:
> On Jan 30, 2009, at Jan 30, 2009, 4:59 PM, Trond Myklebust wrote:
> > On Fri, 2009-01-30 at 16:30 -0500, Chuck Lever wrote:
> >>> Yes and no. I thought the motivation for doing what you currently
> >> do
> >>> was
> >>> to avoid mixing AF_INET and AF_INET6 sockets, since the latter
> >>> listen on
> >>> both IPv4 (via the IPv4 mapping) and IPv6?
> >>
> >> AF_INET6 listeners can receive AF_INET packets too, but don't have
> >> to.  My motivation was to use a single listener so we don't have to
> >> support multiple family listeners for each transport protocol in the
> >> server-side code.  Also, having a separate IPv6-only listener means
> >> that someone can come along and hijack the IPv4 packets on that port.
> >>
> >> It's just less of a headache with one listener.
> >
> > The ipv6 manpage says that the port spaces are shared. If so, I don't
> > see how you can have both an AF_INET socket and an AF_INET6 socket  
> > bound
> > to the same port.
> 
> I've been told that the IPV6_V6ONLY socket option modulates this  
> behavior.  If it's set, then the port spaces are separate.
> 
> The question is how to deal with mapped IPv4 traffic.  if IPV6_V6ONLY  
> is set, then what happens to mapped IPv4 traffic?

According to Stevens, the mapped IPv4 traffic is ignored, and so you
have to set up an AF_INET socket in order to catch it.

> >>> If so, it sounds to me as if
> >>> we _must_ have lockd and the callback server set up IPv6 sockets
> >>> whenever they are available.
> >>
> >> That's what the code does now.  The problem is exactly what does
> >> "whenever they are available" mean?
> >>
> >> Are you suggesting we shouldn't ever fall back to AF_INET?  (I'm OK
> >> with that answer, but would like a discussion).  This means that if I
> >> try an IPv4 mount on a system built with an IPv6 module, but the
> >> module is unloadable, all mounts (even IPv4) fail outright.
> >> Apparently a lot of folks blacklist their IPv6 modules.
> >
> > I'd rather advocate that we try to use AF_INET6 at service set up  
> > time,
> > then fall back on AF_INET only if the former isn't available. I'm not
> > sure that we should allow the user to change the service once it has
> > been set up, since it would appear that would force you to close the
> > current socket, and then reopen a new one of a different type. That's
> > both racy and constitutes an interruption of service.
> 
> The listeners will pin the ipv6 module while they exist.  At some  
> point, if the listeners are stopped, the ipv6 module can be  
> blacklisted.  Subsequent NFS mounts will fail at that point, but a  
> reboot (or perhaps unloading the lockd and nfs modules) will make it  
> right again.
> 
> Seems like a good argument for separate listeners.

My point was that you might lose the IPv4 port, however that's moot when
you can set up an IPV6_V6ONLY socket. Note that this appears to be the
technique favoured by ssh.

That said, I think I'd prefer the single socket solution that we have
now. It would certainly make life easier for migration events, and
possibly pnfs. In neither of these cases do you know at mount time what
kind of callback service you will need later, so setting up an IPv4-only
service might turn out wrong.

Trond

Trond

