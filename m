Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49896 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753610Ab3DOTfK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Apr 2013 15:35:10 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/5] (v4) gss-proxy upcall for nfsd
Date: Mon, 15 Apr 2013 15:35:02 -0400
Message-Id: <1366054508-27604-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Changes since my last posting:
	- disable idle timeout by passing down rpc create flags to xprt
	  create and defining a new RPC_CLNT_CREATE_NO_IDLE_TIMEOUT flag
	  instead of hardwiring timeout to 0 in the AF_LOCAL case.
	  (Chuck's suggestion.)
	- Reduce stack usage in gssp_rpc_create by removing some unused
	  structure fields from the xdr code.  I plan to do more, but at
	  this point that function is down to about 500 bytes of stack,
	  which probably makes it not an immediately problem.  (Thanks
	  to Trond for pointing out the problem.)
	- Use C99 initializers to clean up gssp_rpc_create (Trond's
	  suggestion.)

Series description, as before:

The following patches add support for rpc servers to use gss-proxy
instead of the existing cache-based method to accept new rpcsec_gss
contexts.

The existing cache-based upcall has some increasingly annoying
limitations that would be difficult to fix without incompatible changes,
and gss-proxy looks like a reasonable replacement.

J. Bruce Fields (2):
  SUNRPC: attempt AF_LOCAL connect on setup
  SUNRPC: allow disabling idle timeout

Simo Sorce (3):
  SUNRPC: conditionally return endtime from import_sec_context
  SUNRPC: Add RPC based upcall mechanism for RPCGSS auth
  SUNRPC: Use gssproxy upcall for server RPCGSS authentication.

 Documentation/filesystems/nfs/00-INDEX           |    2 +
 Documentation/filesystems/nfs/rpc-server-gss.txt |   91 +++
 include/linux/sunrpc/clnt.h                      |    1 +
 include/linux/sunrpc/gss_api.h                   |    2 +
 include/linux/sunrpc/xprt.h                      |    1 +
 net/sunrpc/auth_gss/Makefile                     |    3 +-
 net/sunrpc/auth_gss/auth_gss.c                   |    2 +-
 net/sunrpc/auth_gss/gss_krb5_mech.c              |    7 +-
 net/sunrpc/auth_gss/gss_mech_switch.c            |    5 +-
 net/sunrpc/auth_gss/gss_rpc_upcall.c             |  357 ++++++++++
 net/sunrpc/auth_gss/gss_rpc_upcall.h             |   47 ++
 net/sunrpc/auth_gss/gss_rpc_xdr.c                |  832 ++++++++++++++++++++++
 net/sunrpc/auth_gss/gss_rpc_xdr.h                |  264 +++++++
 net/sunrpc/auth_gss/svcauth_gss.c                |  350 ++++++++-
 net/sunrpc/clnt.c                                |    2 +
 net/sunrpc/netns.h                               |    6 +
 net/sunrpc/xprt.c                                |    2 +
 net/sunrpc/xprtsock.c                            |    3 +
 18 files changed, 1961 insertions(+), 16 deletions(-)
 create mode 100644 Documentation/filesystems/nfs/rpc-server-gss.txt
 create mode 100644 net/sunrpc/auth_gss/gss_rpc_upcall.c
 create mode 100644 net/sunrpc/auth_gss/gss_rpc_upcall.h
 create mode 100644 net/sunrpc/auth_gss/gss_rpc_xdr.c
 create mode 100644 net/sunrpc/auth_gss/gss_rpc_xdr.h

-- 
1.7.9.5

