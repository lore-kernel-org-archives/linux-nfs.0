Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58900 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751852AbdBWRDj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Feb 2017 12:03:39 -0500
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: schumaker.anna@gmail.com, linux-nfs@vger.kernel.org
Subject: [PATCH 0/4] nfs/nfsd/sunrpc: enforce requirement for congestion control protocols in NFSv4
Date: Thu, 23 Feb 2017 12:03:33 -0500
Message-Id: <20170223170337.10686-1-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RFC5661 says:

   Where an NFSv4.1 implementation supports operation over the IP
   network protocol, any transport used between NFS and IP MUST be among
   the IETF-approved congestion control transport protocols.

...and RFC7530 has similar verbiage. The NFS server has never enforced
this requirement, however, so a user could issue NFSv4 calls against
the server via UDP.

This patchset adds a small bit of infrastructure to the sunrpc layer
to enforce this requirement, and has the nfs and nfsd layers set the
appropriate flags for it. It also has knfsd skip registering a UDP
port for NFSv4, using the same flags.

Lightly tested by hand, but it's fairly straightforward.

Jeff Layton (4):
  sunrpc: flag transports as using IETF approved congestion control
    protocols
  sunrpc: turn bitfield flags in svc_version into bools
  nfs/nfsd/sunrpc: enforce congestion control protocol requirement for
    NFSv4
  sunrpc: don't register UDP port with rpcbind when version needs
    congestion control

 fs/nfs/callback_xdr.c                    |  6 ++++--
 fs/nfsd/nfs2acl.c                        |  1 -
 fs/nfsd/nfs3acl.c                        |  1 -
 fs/nfsd/nfs4proc.c                       | 13 +++++++------
 include/linux/sunrpc/svc.h               | 12 ++++++++----
 include/linux/sunrpc/svc_xprt.h          |  1 +
 net/sunrpc/svc.c                         | 22 +++++++++++++++++++++-
 net/sunrpc/svcsock.c                     |  1 +
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  2 ++
 9 files changed, 44 insertions(+), 15 deletions(-)

-- 
2.9.3

