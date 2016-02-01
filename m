Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:34493 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbcBAElO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Jan 2016 23:41:14 -0500
Received: by mail-io0-f170.google.com with SMTP id 9so65717509iom.1
        for <linux-nfs@vger.kernel.org>; Sun, 31 Jan 2016 20:41:14 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 00/13] Basic multipathing support and demonstrator
Date: Sun, 31 Jan 2016 23:40:17 -0500
Message-Id: <1454301630-17358-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

The following patchset is intended as an RFC to demonstrate how we could
implement multipathing in NFS.
It adds basic support for attaching multiple RPC transports to a client,
an embryonic policy mechanism for switching tasks across those transports
(with a round-robin policy implementation), as well as helpers to allow
iteration of tasks across all tranports (for instance in order to
support NFSv4.1's BIND_CONN_TO_SESSION).

A lot of polish and finishing touches are missing. For instance, I have yet
to add support in debugfs for these transports, and there is no support
for mounting with NFSv4.1 session trunking. However there is a demonstrator
that implements pNFS multipathing over NFSv3. Adding support for NFSv4.1
requires that you call EXCHANGE_ID to allow verification of the
major/minor server and scopeid fields, which should not be too hard.

More to come, but in the meantime, comments are welcome...

Cheers
  Trond

Trond Myklebust (13):
  SUNRPC: Remove unused function rpc_task_reset_client
  SUNRPC: Reorder rpc_task to put waitqueue related info in same
    cachelines
  SUNRPC: Uninline xprt_get(); It isn't performance critical.
  SUNRPC: Make freeing of struct xprt rcu-safe
  SUNRPC: Add a structure to track multiple transports
  SUNRPC: Make rpc_clnt store the multipath iterators
  SUNRPC: Use the multipath iterator to assign a transport to each task
  SUNRPC: Allow caller to specify the transport to use
  SUNRPC: Add a helper to apply a function to all the rpc_clnt's
    transports
  SUNRPC: Make NFS swap work with multipath
  NFSv4.1: nfs4_proc_bind_conn_to_session must iterate over all
    connections
  SUNRPC: Allow addition of new transports to a struct rpc_clnt
  pnfs/NFSv4.1: Add multipath capabilities to pNFS flexfiles servers
    over NFSv3

 fs/nfs/nfs4proc.c                    |  51 +++-
 fs/nfs/pnfs_nfs.c                    |  16 +-
 include/linux/sunrpc/clnt.h          |  18 +-
 include/linux/sunrpc/sched.h         |  32 +--
 include/linux/sunrpc/xprt.h          |  22 +-
 include/linux/sunrpc/xprtmultipath.h |  69 +++++
 net/sunrpc/Makefile                  |   3 +-
 net/sunrpc/auth_gss/auth_gss.c       |   4 +-
 net/sunrpc/clnt.c                    | 326 ++++++++++++++++++------
 net/sunrpc/rpcb_clnt.c               |  10 +-
 net/sunrpc/sched.c                   |   2 +
 net/sunrpc/xprt.c                    |  42 ++--
 net/sunrpc/xprtmultipath.c           | 473 +++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtsock.c                |   4 +-
 14 files changed, 938 insertions(+), 134 deletions(-)
 create mode 100644 include/linux/sunrpc/xprtmultipath.h
 create mode 100644 net/sunrpc/xprtmultipath.c

-- 
2.5.0

