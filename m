Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34322 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754883Ab3BUQi2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2013 11:38:28 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, chuck.lever@oracle.com, simo@redhat.com,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/6] gss-proxy upcall for nfsd
Date: Thu, 21 Feb 2013 11:38:19 -0500
Message-Id: <1361464705-12340-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The following patches add support for rpc servers to use gss-proxy
instead of the existing cache-based method to accept new rpcsec_gss
contexts.

The existing cache-based upcall has some increasingly annoying
limitations that would be difficult to fix without incompatible changes,
and gss-proxy looks like a reasonable replacement.

Changes since Simo's last posting:
	- All globals are made per-network-namespace.
	- The new upcall is negotiated by write to a proc file instead
	  of a module parameter, allowing the choice to be made
	  per-container.
	- We reuse a common per-network-namespace rpc client instead of
	  creating a new one for each upcall.
	- Locking is relaxed to allow concurrent upcalls.

--b.

J. Bruce Fields (3):
  SUNRPC: make AF_LOCAL connect synchronous
  SUNRPC: attempt AF_LOCAL connect on setup
  SUNRPC: no idle timeout for AF_LOCAL sockets

Simo Sorce (3):
  SUNRPC: conditionally return endtime from import_sec_context
  SUNRPC: Add RPC based upcall mechanism for RPCGSS auth
  SUNRPC: Use gssproxy upcall for server RPCGSS authentication.

 Documentation/filesystems/nfs/00-INDEX           |    2 +
 Documentation/filesystems/nfs/rpc-server-gss.txt |   91 +++
 include/linux/sunrpc/gss_api.h                   |    2 +
 net/sunrpc/auth_gss/Makefile                     |    3 +-
 net/sunrpc/auth_gss/auth_gss.c                   |    2 +-
 net/sunrpc/auth_gss/gss_krb5_mech.c              |    7 +-
 net/sunrpc/auth_gss/gss_mech_switch.c            |    5 +-
 net/sunrpc/auth_gss/gss_rpc_upcall.c             |  360 +++++++++
 net/sunrpc/auth_gss/gss_rpc_upcall.h             |   47 ++
 net/sunrpc/auth_gss/gss_rpc_xdr.c                |  906 ++++++++++++++++++++++
 net/sunrpc/auth_gss/gss_rpc_xdr.h                |  269 +++++++
 net/sunrpc/auth_gss/svcauth_gss.c                |  350 ++++++++-
 net/sunrpc/clnt.c                                |    1 +
 net/sunrpc/netns.h                               |    6 +
 net/sunrpc/xprtsock.c                            |   41 +-
 15 files changed, 2067 insertions(+), 25 deletions(-)
 create mode 100644 Documentation/filesystems/nfs/rpc-server-gss.txt
 create mode 100644 net/sunrpc/auth_gss/gss_rpc_upcall.c
 create mode 100644 net/sunrpc/auth_gss/gss_rpc_upcall.h
 create mode 100644 net/sunrpc/auth_gss/gss_rpc_xdr.c
 create mode 100644 net/sunrpc/auth_gss/gss_rpc_xdr.h

-- 
1.7.9.5

