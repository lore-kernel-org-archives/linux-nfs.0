From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 07/10] SUNRPC: Pass full bind address to transports
	after GETPORT/GETADDR
Date: Fri, 17 Jul 2009 12:02:30 -0400
Message-ID: <20090717160230.GG10710@fieldses.org>
References: <20090715213842.7883.48947.stgit@matisse.1015granger.net> <20090715214238.7883.91886.stgit@matisse.1015granger.net> <1247778644.12292.156.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57865 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964855AbZGQQCc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Jul 2009 12:02:32 -0400
In-Reply-To: <1247778644.12292.156.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 16, 2009 at 05:10:44PM -0400, Trond Myklebust wrote:
> On Wed, 2009-07-15 at 17:42 -0400, Chuck Lever wrote:
> > TI-RPC rpcbind operations provide not just a port number, but a full
> > socket address the client should connect to.  This allows rpcbind to
> > redirect RPC traffic to specific network interfaces or servers.  The
> > Linux kernel rpcbind client implementation currently ignores the
> > address.
> > 
> > Expand the ->set_port transport method so an address is passed to
> > transports during an RPC bind operation.  Additional changes to
> > individual client transports will be required to replace the peer
> > address after an rpcbind operation.
> 
> Now I'm worried. We've just spent a lot of time implementing RPCSEC_GSS
> security, and yet we're going allow an AUTH_SYS-based RPC call to tell
> us to change an IP address that the user supplied us with? It was bad
> enough when we allowed it to set the port number...

The authentication of the server will use whatever hostname was supplied
on the commandline, so should still provide some protection.

On the other hand: with krb5 (as opposed to krb5i or krb5p), a
man-in-the-middle attack that keeps the rpc headers and replaces the
body is always possible.  But if you can redirect the client to a
port/ip address under your control, that might simplify the attack
significantly.  Similarly, sniffing non-krb5p traffic might become
simpler.

It might also simplify denial of service attacks (possibly with the goal
of making the user give up on gss and downgrade to auth_sys?).

An attacker could do the same stuff with dns, I suppose.

--b.
