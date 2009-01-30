From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 1/7] lockd: Use AF_INET6 listener only when IPv6
 support is built in
Date: Fri, 30 Jan 2009 17:21:39 -0500
Message-ID: <1233354099.9741.78.camel@heimdal.trondhjem.org>
References: <20090130200021.22301.22618.stgit@ingres.1015granger.net>
	 <20090130201041.22301.60941.stgit@ingres.1015granger.net>
	 <1233347546.9741.31.camel@heimdal.trondhjem.org>
	 <130964B3-CDE1-440F-B0E0-33620036E239@oracle.com>
	 <1233350290.9741.42.camel@heimdal.trondhjem.org>
	 <F0ED35C3-3E01-42E2-BE71-1C1273C1B495@oracle.com>
	 <1233352740.9741.64.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:47779 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754107AbZA3WVq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Jan 2009 17:21:46 -0500
In-Reply-To: <1233352740.9741.64.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-01-30 at 16:59 -0500, Trond Myklebust wrote:
> On Fri, 2009-01-30 at 16:30 -0500, Chuck Lever wrote:
> > > Yes and no. I thought the motivation for doing what you currently
> > do  
> > > was
> > > to avoid mixing AF_INET and AF_INET6 sockets, since the latter  
> > > listen on
> > > both IPv4 (via the IPv4 mapping) and IPv6?
> > 
> > AF_INET6 listeners can receive AF_INET packets too, but don't have  
> > to.  My motivation was to use a single listener so we don't have to  
> > support multiple family listeners for each transport protocol in the  
> > server-side code.  Also, having a separate IPv6-only listener means  
> > that someone can come along and hijack the IPv4 packets on that port.
> > 
> > It's just less of a headache with one listener.
> 
> The ipv6 manpage says that the port spaces are shared. If so, I don't
> see how you can have both an AF_INET socket and an AF_INET6 socket bound
> to the same port.

Never mind. I just found the IPV6_V6ONLY socket option. I wonder why
that isn't documented in any manpages...

Trond

