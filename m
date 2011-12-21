Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31694 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753101Ab1LUUfC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Dec 2011 15:35:02 -0500
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org, steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/5] nfsd: overhaul the client name tracking code
Date: Wed, 21 Dec 2011 15:34:51 -0500
Message-Id: <1324499696-10318-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the third iteration of this patchset. The main changes since
the last set are fairly minor:

- the new cl_flags field has been merged with the cl_cb_flags field.
  There are only 2 bits being used in cl_cb_flags currently, so it
  made sense not to bloat out the struct with a new field.

- some minor changes to the upcall struct for better alignment (as
  suggested by Benny)

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
"reclaim" to be cluster aware as well. This patchset is a move toward
that goal and covers the initial kernel part of such a change. A
patchset to add a daemon to handle the upcalls will follow.

The goal with this patchset is to replace the existing functionality,
without disturbing the existing code too much. For now, the plan is
to leave the old tracking code in place until it becomes a burden to
maintain. At that point, we'll need to come up with a plan to
transition everyone off of the legacy state tracker.

I think this set is now ready for merge and I'd like to see it go
in for 3.3 if possible. The userspace piece will follow this in
a separate patchset.

Jeff Layton (5):
  nfsd: add nfsd4_client_tracking_ops struct and a way to set it
  sunrpc: create nfsd dir in rpc_pipefs
  nfsd: convert nfs4_client->cl_cb_flags to a generic flags field
  nfsd: add a header describing upcall to nfsdcld
  nfsd: add the infrastructure to handle the cld upcall

 fs/nfsd/nfs4callback.c   |   12 +-
 fs/nfsd/nfs4recover.c    |  439 ++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/nfs4state.c      |   46 ++---
 fs/nfsd/state.h          |   21 ++-
 include/linux/nfsd/cld.h |   56 ++++++
 net/sunrpc/rpc_pipe.c    |    5 +
 6 files changed, 526 insertions(+), 53 deletions(-)
 create mode 100644 include/linux/nfsd/cld.h

