From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NLM] 2.6.27.14 breakage when grace period expires
Date: Thu, 12 Feb 2009 14:10:37 -0500
Message-ID: <1234465837.7190.62.camel@heimdal.trondhjem.org>
References: <20090211112318.GA29133@janus>
	 <20090211203555.GC27686@fieldses.org> <20090211203703.GA9662@janus>
	 <20090211203948.GD27686@fieldses.org> <20090212142830.GA28107@janus>
	 <1234451789.7190.38.camel@heimdal.trondhjem.org>
	 <20090212153634.GB28107@janus>
	 <1234462647.7190.53.camel@heimdal.trondhjem.org>
	 <20090212182943.GA1945@janus>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Frank van Maarseveen <frankvm@frankvm.com>,
	"Mr. Charles Edward Lever" <Chuck.Lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:44862 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755348AbZBLTKp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Feb 2009 14:10:45 -0500
In-Reply-To: <20090212182943.GA1945@janus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-02-12 at 19:29 +0100, Frank van Maarseveen wrote:
> On Thu, Feb 12, 2009 at 01:17:27PM -0500, Trond Myklebust wrote:
> > On Thu, 2009-02-12 at 16:36 +0100, Frank van Maarseveen wrote:
> > > A little theorizing:
> > > If the unlock of a yet unrecovered lock has failed up to that point then
> > > the client sure must remember the lock somehow. That might explain the
> > > secondary error when a conflicting lock is granted by the server.
> > 
> > Sorry, but that doesn't hold water. The client will release the VFS
> > 'mirror' of the lock before it attempts to unlock. Otherwise, you could
> > have some nasty races between the unlock thread and the recovery
> > thread...
> > Besides, the granted callback handler on the client only checks the list
> > of blocked locks for a match.
> 
> ok, then we have more than one NLM bug to resolve.
> 
> > 
> > Oh, bugger, I know what this is... It's the same thing that happened to
> > the NFSv4 callback server. If you compile with CONFIG_IPV6 or
> > CONFIG_IPV6_MODULE enabled, and also set CONFIG_SUNRPC_REGISTER_V4, then
> > the NLM server will listen on an IPv6 socket, and so the RPC request
> > come in with their IPv4 address mapped into the IPv6 namespace.
> 
> Nope:
> 
> 	$ zgrep IPV6 /proc/config.gz 
> 	# CONFIG_IPV6 is not set
> 	$ zgrep SUNRPC /proc/config.gz 
> 	CONFIG_SUNRPC=y
> 	CONFIG_SUNRPC_GSS=y
> 	# CONFIG_SUNRPC_BIND34 is not set

Sorry, yes... 2.6.27.x should be OK. The lockd v4mapped addresses bug is
specific to 2.6.29. Chuck, are you planning on fixing this before
2.6.29-final comes out?

> And remember this is not a recent regression.

It would help if you sent us the full binary tcpdump, instead of just
the summary. That should enable us to figure out which of the tests is
failing in nlmclnt_grant().

Trond

