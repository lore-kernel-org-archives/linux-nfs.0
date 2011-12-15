Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1570 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751294Ab1LOSn1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Dec 2011 13:43:27 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBFIhQQK007958
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2011 13:43:26 -0500
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [10.11.228.66])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id pBFIhQq4021450
	for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2011 13:43:26 -0500
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/5] nfsd: overhaul the client name tracking code (RFC)
Date: Thu, 15 Dec 2011 13:43:21 -0500
Message-Id: <1323974606-16477-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the second version of this patchset. The main changes are:

- a few minor bugfixes

- some changes to the upcall struct format

- renaming some of the objects to be prefixed with "cld" instead of
  "clstated"

One of the things that Bruce has long had on his wishlist is to replace
the client name tracking code that the kernel uses:

    http://wiki.linux-nfs.org/wiki/index.php/Nfsd4_server_recovery

The existing code manipulates the filesystem directly to track this
info. Not only is that something that makes the VFS maintainers look
askance at knfsd, but it also is unsuitable in a clustered
configuration.

Typically we think of the grace period as a property of the server, but
with a clustered filesystem, we need to consider it as a property of the
cluster as a whole (or of the clustered filesystem). On a cold startup
of the cluster, once any node grants a non-reclaim lock, then no more
reclaim can be allowed on any node. Grace periods must be coordinated
amongst all cluster nodes.

In order to achieve that goal, we need to first allow the client name
reclaim to be cluster aware as well. This patchset is a move toward that
goal and covers the initial kernel part of such a change. A patchset to
add a daemon to handle the upcalls will follow.

Note that this patchset is still a little rough, so consider this an
RFC for the overall design. We'll also need to consider a plan to
deprecate the old client tracking code.

The goal with this patchset is to replace the existing functionality,
without disturbing the existing code too much. There's some room for
more cleanup and reorganization once the old tracker is gone.

Jeff Layton (5):
  nfsd: add nfsd4_client_tracking_ops struct and a way to set it
  sunrpc: create nfsd dir in rpc_pipefs
  nfsd: add a generic flags field to nfs4_client
  nfsd: add a header describing upcall to nfsdcld
  nfsd: add the infrastructure to handle the cld upcall

 fs/nfsd/nfs4recover.c    |  439 ++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/nfs4state.c      |   46 ++---
 fs/nfsd/state.h          |   15 +-
 include/linux/nfsd/cld.h |   57 ++++++
 net/sunrpc/rpc_pipe.c    |    5 +
 5 files changed, 518 insertions(+), 44 deletions(-)
 create mode 100644 include/linux/nfsd/cld.h

