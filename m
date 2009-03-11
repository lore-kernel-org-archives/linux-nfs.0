From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/6] nfs-utils: convert gssd to TI-RPC and add IPv6 support (RFC)
Date: Wed, 11 Mar 2009 12:42:56 -0400
Message-ID: <1236789782-8867-1-git-send-email-jlayton@redhat.com>
Cc: kwc@citi.umich.edu, chuck.lever@oracle.com
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:32907 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752191AbZCKQnO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 12:43:14 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset is a first draft at adding support for IPv6 to rpc.gssd.
It's based on Chuck Lever's latest nfs-utils git tree. Some of the
needed infrastructure for this is not yet in mainline nfs-utils, so this
isn't really ready for inclusion yet. I'm just posting it to solicit
feedback.

In order to do this, we first have to convert rpc.gssd to use TI-RPC.
The first 5 patches do this and abstract out some of the code to make
this easier. Once that support is in place, the last patch in the series
actually adds the (fairly minimal) changes to add IPv6 support.

The series should be fully bisectable, but I've only really tested the
end result for anything other than to see if it compiles. With this
series on top of Chuck's tree, I've been able to mount an OpenSolaris
server using NFSv4+IPv6+krb5 auth

There's one other significant change in here as well. The current code
does what seems to be an unnecessary lookup on every upcall. It goes
something like this:

1) kernel calls gssd and hands it an address
2) we take that address and reverse-resolve it to a hostname
3) we store that hostname
4) we resolve that hostname back to an address for RPC client creation

Obviously, this could be more efficient. This set changes it so that we
store the address that we get from the upcall and skip the second
lookup.  I have no hard numbers yet, but it seems obvious that it should
improve upcall performance.

My main question here is -- is this OK? I don't see any need for us to
resolve the address forward and backward like we do. We do this sort of
thing in some places (statd, for instance) but the need is a little
clearer there.

Jeff Layton (6):
  nfs-utils: make getnameinfo() required for --enable-gss
  nfs-utils: store the address given in the upcall for later use
  nfs-utils: skip getaddrinfo in create_auth_rpc_client unless we need
    port
  nfs-utils: split out gssd rpc client creation into separate function
  nfs-utils: when TIRPC is enabled, use new API to create RPC client
  nfs-utils: add IPv6 code to gssd

 configure.ac           |    2 +
 utils/gssd/gssd.h      |    2 +-
 utils/gssd/gssd_proc.c |  417 +++++++++++++++++++++++++++++++++++++-----------
 3 files changed, 328 insertions(+), 93 deletions(-)

