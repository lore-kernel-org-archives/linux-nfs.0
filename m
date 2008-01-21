From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC,PATCH] svc: Modify svc_xprt_create to take a sockaddr
Date: Mon, 21 Jan 2008 14:24:55 -0500
Message-ID: <1200943495.25562.52.camel@heimdal.trondhjem.org>
References: <20080121171105.29028.61809.stgit@dell3.ogc.int>
	 <9ECEB764-A93C-4DF2-BB6E-273C33C02B6E@oracle.com>
	 <1200938366.25562.14.camel@heimdal.trondhjem.org>
	 <FD665904-E655-48E9-8508-D9E118762C84@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:51643 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751130AbYAUTY7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jan 2008 14:24:59 -0500
In-Reply-To: <FD665904-E655-48E9-8508-D9E118762C84@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-01-21 at 13:30 -0500, Chuck Lever wrote:

> Not sure what you are getting at here.
> 
> The goal of using string transport identifiers in the RPC client is  
> that the value of "proto=" could be passed directly to the RPC  
> client.  The way it works today, we have to add support in the NFS  
> mount option parser for any new RPC transport capability.
> 
> One of the goals of the client-side transport switch has always been  
> to allow new transport capabilities to be dynamically loaded without  
> needing to make code changes to the NFS client to support them.
> 
> For example, it would be nice to have an SCTP transport capability,  
> or a single-socket-per-client UDP transport capability, in addition  
> to the default socket-based transports we have now.  With the current  
> arrangement, we'll have to add code in the NFS mount option parser to  
> allow users to select these.  If the proto= value were simply passed  
> through, it would be simple for the RPC client to match the value to  
> an identifier string specified by the new transport.

It is also important to be able to check arbitrary user data such as
that provided in the mount command for sanity. It should be a
requirement that we do that in one place only, else we'll be chasing
down security issues until the cows come home.

IOW: I don't care if you want to pass the 'proto' argument as a string,
but I'm not at all convinced that we need to be passing unparsed mount
data to the RPC layer.

  Trond

