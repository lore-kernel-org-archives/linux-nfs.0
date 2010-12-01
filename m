Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43672 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751327Ab0LARxu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Dec 2010 12:53:50 -0500
Date: Wed, 1 Dec 2010 12:53:49 -0500
To: Trond Myklebust <trond@netapp.com>, linux-nfs@vger.kernel.org
Subject: backchannel transport
Message-ID: <20101201175348.GF6832@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This is just a small question about the nfsd-side backchannel code that
touches the rpc client code:

There's nothing preventing multiple backchannels from sharing the same
tcp connection, either simultaneously or over time; from rfc 5661
section 2.10.3.1:

	A connection's association with a session is not exclusive.  A
	connection associated with the channel(s) of one session may be
	simultaneously associated with the channel(s) of other sessions
	including sessions associated with other client IDs.

The current code creates a new rpc_xprt every time an rpc client is
created for a backchannel.

But that's wrong: if two sessions share a backchannel, then they don't
necessarily want to share the same rpc_client, but they *do* need to
share the same rpc_xprt, to prevent xid reuse at least.

So I think we should create one rpc_xprt the first time we use a
connection for a backchannel, and then keep it around as long as the
connection is open (in case the client reassociates it with a
backchannel again).

rpc_clone_client() allows clients to share an rpc_xprt.  I could use
that for example by keeping an nfsd-level data structure allowing me to
look up rpc_client's by connection.

However, the server- and client- side xprt's already reference each
other--the client's pointer to the server is used to send requests, and
the server's pointer to the client is used to match incoming replies
with requests.

So it would seem simplest to use the already existing pointer from the
svc_xprt back to the rpc_xprt.

So, that would mean:

	- Allowing nfsd to create a client with the already-existing
	  rpc_xprt--maybe export rpc_new_client()?  Or allow the
	  xprt->setup method to find an already-existing transport?
	- Keeping any backchannel rpc_xprt around somehow as long as the
	  connection is open.  Maybe let svc_xprt keep a reference on
	  the client xprt until svc_delete_xprt()??

--b.
