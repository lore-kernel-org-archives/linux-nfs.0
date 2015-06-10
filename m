Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42334 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754422AbbFJSJ2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Jun 2015 14:09:28 -0400
Date: Wed, 10 Jun 2015 14:09:26 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stefan Hajnoczi <stefanha@redhat.com>
Cc: linux-nfs@vger.kernel.org, Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        asias.hejun@gmail.com, netdev@vger.kernel.org,
        Daniel Berrange <berrange@redhat.com>,
        "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC 00/10] NFS: add AF_VSOCK support to NFS client
Message-ID: <20150610180926.GC8922@fieldses.org>
References: <1433436353-6761-1-git-send-email-stefanha@redhat.com>
 <20150608210247.GB27887@fieldses.org>
 <20150610164315.GD17294@stefanha-thinkpad.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150610164315.GD17294@stefanha-thinkpad.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 10, 2015 at 05:43:15PM +0100, Stefan Hajnoczi wrote:
> On Mon, Jun 08, 2015 at 05:02:47PM -0400, J. Bruce Fields wrote:
> > On Thu, Jun 04, 2015 at 05:45:43PM +0100, Stefan Hajnoczi wrote:
> > > The approach in this series
> > > ---------------------------
> > > AF_VSOCK stream sockets can be used for NFSv4.1 much in the same way as TCP.
> > > RFC 1831 record fragments divide messages since SOCK_STREAM semantics are
> > > present.  The backchannel shares the connection just like the default TCP
> > > configuration.
> > 
> > So the NFSv4 backchannel isn't handled for now, I assume.
> 
> Right, I did not touch nfs4_callback_up_net(), only
> nfs41_callback_up_net().
> 
> If I'm reading the code right NFSv4 uses a separate listen port for the
> backchannel instead of sharing the client's socket?

Right.

> This is possible to implement with AF_VSOCK but I have only tested
> NFSv4.1 so far.  Should I go ahead and do this?

Personally I'd make it a lower priority--I don't see why you can't make
4.1 a requirement for the new transport--but I'd be curious what others
have to say.

> > And I guess
> > NFSv2/v3 is out too thanks to rpcbind?  Which maybe is fine.
> 
> Yes, I ignored rpcbind and didn't test NFSv2/v3.
> 
> > Do we need an IETF draft or similar to document how NFS should work over
> > AF_VSOCK?
> 
> I am not familiar with the standards process but I came across a few
> places where it makes sense to have a standard:
> 
>  * SUNRPC netid for AF_VSOCK (currently "tcp", "udp", and others exist)
>  * The uaddr string format ("vsock:...")

Off the top of my head I can't remember where else that's used in the
protocol other than in setting up the 4.0 callback connection (and in
rpcbind).

>  * Use of RFC 1831 record fragments (just like TCP) over AF_VSOCK
>    SOCK_STREAM sockets

As far as I can tell, 1831 claims to be independent of any transport
protocol details: "The RPC protocol can be implemented on several
different transport protocols.  The RPC protocol does not care how a
message is passed from one process to another, but only with
specification and interpretation of messages."  And: "When RPC messages
are passed on top of a byte stream transport protocol (like TCP)"....
So perhaps there's nothing more to say here.

> These are all at the SUNRPC level rather than at the NFS protocol level.
> 
> Any idea who I need to talk to?

Anyay, if there is anything to be worked out, nfsv4@ietf.org is the
place to go.

--b.
