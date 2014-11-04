Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cliff.cs.toronto.edu ([128.100.3.120]:48695 "EHLO
	cliff.cs.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869AbaKDRMV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Nov 2014 12:12:21 -0500
From: Chris Siebenmann <cks@cs.toronto.edu>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
cc: cks@cs.toronto.edu
Subject: Best approach for authenticating hosts for NFS (v3)?
Date: Tue, 04 Nov 2014 11:53:13 -0500
Message-Id: <20141104165313.CA9025A04C1@testapps.cs.toronto.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 We have a situation here where for various reasons we need to deal
with the possibility of host impersonation, where someone might take
over the IP address of a machine that's authorized to do NFS v3 mounts.
Our solution on our current Solaris fileservers is authenticating the
clients when and as they make NFS mounts through a callback process
based on intercepting netgroup membership checks with an NSS module.

 We'd like to bring up some sort of host authentication on Linux so that
we can use Linux as an NFS server in our environment. Unfortunately a
straight port of our Solaris solution appears infeasible due to a glibc
issue[*], which leaves me looking around for ideas. The options that I
can think of now are:

- modify the mountd source to stuff in a callout to our authentication
  system at mount time.
  drawback: we'd have to maintain a custom hack to mountd (and figure
  out where in the source to put it).

- use ipsec between clients and servers.
  drawback: the ipsec overhead and speed reduction

- put together some firewall based system that only allows access to
  the NFS and/or mountd ports after host verification.
  drawback: I'd like to automatically trigger verification on mount
  requests rather than require clients to trigger it in an out-of-band
  way and I'm not sure if there's any easy way to do that.
  (Perhaps the answer is the 'spawn' tcpwrappers option to trigger a
  callout.)

 Are there options that I'm not seeing here or that I haven't
considered? Are there good fixes to the drawbacks I've listed
that I'm not seeing?

 Out of the options that people can see (possibly not just these ones),
what do people think would be the best way to do this?

(I suspect that there is no interest in adding some general system for
NFS mount authentication checks to mountd.)

 Thanks in advance for any opinions et al that people feel like
offering.

PS: 'switch to NFS v4 to strongly authenticate user requests' is not an
    option for us. We specifically value things that cannot be done
    with true verification of user identification, like cron, and we
    don't have and don't want to build the infrastructure that would
    be required for strongly authenticated NFS v4.

	- cks
[*: Building a NSS module that supports netgroup lookups requires using
    an internal glibc header file to get a definition of a struct that
    is passed to NSS netgroup lookup functions.
]
