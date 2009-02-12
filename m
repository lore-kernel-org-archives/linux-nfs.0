From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NLM] 2.6.27.14 breakage when grace period expires
Date: Thu, 12 Feb 2009 13:17:27 -0500
Message-ID: <1234462647.7190.53.camel@heimdal.trondhjem.org>
References: <20090211112318.GA29133@janus>
	 <20090211203555.GC27686@fieldses.org> <20090211203703.GA9662@janus>
	 <20090211203948.GD27686@fieldses.org> <20090212142830.GA28107@janus>
	 <1234451789.7190.38.camel@heimdal.trondhjem.org>
	 <20090212153634.GB28107@janus>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:34344 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755017AbZBLSRd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Feb 2009 13:17:33 -0500
In-Reply-To: <20090212153634.GB28107@janus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-02-12 at 16:36 +0100, Frank van Maarseveen wrote:
> A little theorizing:
> If the unlock of a yet unrecovered lock has failed up to that point then
> the client sure must remember the lock somehow. That might explain the
> secondary error when a conflicting lock is granted by the server.

Sorry, but that doesn't hold water. The client will release the VFS
'mirror' of the lock before it attempts to unlock. Otherwise, you could
have some nasty races between the unlock thread and the recovery
thread...
Besides, the granted callback handler on the client only checks the list
of blocked locks for a match.

Oh, bugger, I know what this is... It's the same thing that happened to
the NFSv4 callback server. If you compile with CONFIG_IPV6 or
CONFIG_IPV6_MODULE enabled, and also set CONFIG_SUNRPC_REGISTER_V4, then
the NLM server will listen on an IPv6 socket, and so the RPC request
come in with their IPv4 address mapped into the IPv6 namespace.
The client, on the other hand, is using an IPv4 socket, 'cos you
specified an IPv4 address to the mount command.
The result is that the call to nlm_cmp_addr() in nlmclnt_grant() always
fails...

Basically, we need to replace nlm_cmp_addr() with something akin to
nfs_sockaddr_match_ipaddr(), which will compare v4 mapped addresses.

The workaround should be simply to turn off CONFIG_SUNRPC_REGISTER_V4 if
you're not planning on ever using NFS-over-IPv6...

Cheers
  Trond

