From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 07/10] SUNRPC: Pass full bind address to transports
 after GETPORT/GETADDR
Date: Thu, 16 Jul 2009 17:10:44 -0400
Message-ID: <1247778644.12292.156.camel@heimdal.trondhjem.org>
References: <20090715213842.7883.48947.stgit@matisse.1015granger.net>
	 <20090715214238.7883.91886.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:44649 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933359AbZGPVKr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jul 2009 17:10:47 -0400
In-Reply-To: <20090715214238.7883.91886.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-07-15 at 17:42 -0400, Chuck Lever wrote:
> TI-RPC rpcbind operations provide not just a port number, but a full
> socket address the client should connect to.  This allows rpcbind to
> redirect RPC traffic to specific network interfaces or servers.  The
> Linux kernel rpcbind client implementation currently ignores the
> address.
> 
> Expand the ->set_port transport method so an address is passed to
> transports during an RPC bind operation.  Additional changes to
> individual client transports will be required to replace the peer
> address after an rpcbind operation.

Now I'm worried. We've just spent a lot of time implementing RPCSEC_GSS
security, and yet we're going allow an AUTH_SYS-based RPC call to tell
us to change an IP address that the user supplied us with? It was bad
enough when we allowed it to set the port number...

     Trond

