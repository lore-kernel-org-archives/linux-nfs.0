From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 1/7] lockd: Use AF_INET6 listener only when IPv6
 support is built in
Date: Fri, 30 Jan 2009 16:18:10 -0500
Message-ID: <1233350290.9741.42.camel@heimdal.trondhjem.org>
References: <20090130200021.22301.22618.stgit@ingres.1015granger.net>
	 <20090130201041.22301.60941.stgit@ingres.1015granger.net>
	 <1233347546.9741.31.camel@heimdal.trondhjem.org>
	 <130964B3-CDE1-440F-B0E0-33620036E239@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:39611 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753051AbZA3VSQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Jan 2009 16:18:16 -0500
In-Reply-To: <130964B3-CDE1-440F-B0E0-33620036E239@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-01-30 at 15:46 -0500, Chuck Lever wrote:
> On Jan 30, 2009, at Jan 30, 2009, 3:32 PM, Trond Myklebust wrote:
> > How about using something like a 'symbol_request(ipv6_getsockopt)' to
> > probe whether or not IPv6 is available.
> 
> That's a good idea.  I was about to go looking for the right way to  
> check if the module is available.

Note that this isn't really sufficient to prevent races. Somebody may
remove the ipv6 module before we get so far as to setting up the
sockets.

> I've been discussing this with Steve.  He'd like some way for lockd to  
> recover if only an IPv4 mount is requested, but the logic to do this  
> (and to report real errors on IPv6 mounts, and to handle the NFSD  
> cases) might get complicated.  Plus, once we start lockd with an  
> AF_INET listener, we are stuck with IPv4-only until lockd is restarted  
> from scratch.
> 
> I think we want any issues in this area to be handled at mount/export  
> time, and not specifically by lockd or the callback server.  What do  
> you think?

Yes and no. I thought the motivation for doing what you currently do was
to avoid mixing AF_INET and AF_INET6 sockets, since the latter listen on
both IPv4 (via the IPv4 mapping) and IPv6? If so, it sounds to me as if
we _must_ have lockd and the callback server set up IPv6 sockets
whenever they are available.

Cheers
  Trond

