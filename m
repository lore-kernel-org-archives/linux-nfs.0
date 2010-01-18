Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:44434 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753957Ab0ARU1g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Jan 2010 15:27:36 -0500
Subject: Re: should mount.nfs prefer IPv4 addresses (was: enabling IPv6)
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com, steved@redhat.com
In-Reply-To: <20100118152047.70f9ab80@tlielax.poochiereds.net>
References: <20100118144746.1e05865e@tlielax.poochiereds.net>
	 <20100118152047.70f9ab80@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 18 Jan 2010 15:27:30 -0500
Message-ID: <1263846450.4127.71.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-01-18 at 15:20 -0500, Jeff Layton wrote: 
> On Mon, 18 Jan 2010 14:47:46 -0500
> Jeff Layton <jlayton@redhat.com> wrote:
> 
> > With the commit of the statd patches over the weekend, we're now
> > positioned to be able to ship IPv6-enabled nfs-utils in distros. There
> > is a potential snag though...
> > 
> > Consider this situation:
> > 
> > Admin has a Linux server set up. Server has both IPv4 and IPv6 addrs.
> > Both addresses are in DNS.
> > 
> > Without an IPv6-enabled nfs-utils, he mounts via IPv4 and all works
> > fine. Now with an IPv6 enabled nfs-utils, mount.nfs prefers the IPv6
> > addr and the mount fails (or hangs for a long time and then fails, if
> > it's using NFSv4)...
> > 
> > While I don't really like it, I think we may need to consider making
> > mount.nfs prefer IPv4 addrs when it can resolve a hostname to both v4
> > and v6. Otherwise, we run the risk of breaking an awful lot of working
> > setups...
> > 
> 
> Apologies for the self reply and non-descript initial title.
> 
> For discussion purposes, here's a patch to do what I'm thinking of. It
> seems to work and do the right thing. You can still force a mount over
> ipv6 by using the right proto/mountproto options.

How do other applications deal with this problem? Surely, not every
application out there is having to filter away IPv6 addresses?

I thought that glibc was by default set up to prefer IPv4 addresses, and
allows you to further configure that using /etc/gai.conf. Why is this
failing?

Cheers
  Trond

