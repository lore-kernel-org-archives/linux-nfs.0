Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:41167 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757229Ab0ANR3H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:29:07 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/24] Remaining IPv6 patches for statd
To: steved@redhat.com
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
Date: Thu, 14 Jan 2010 12:28:48 -0500
Message-ID: <20100114172457.26079.66627.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The Fedora 13 feature freeze is next week, and RHEL 6 beta is coming
up in just a month or two.  Because both of these releases should have
at least client-side NFS/IPv6 support, we've decided to accelerate the
submission of nfs-utils IPv6 patches.

This patch set introduces basic IPv6 support to statd and sm-notify.
Functionality when IPv6 and TI-RPC are disabled should be unchanged,
except that monitor record files can now contain more than one line.

---

Chuck Lever (24):
      statd: update rpc.statd(8) and sm-notify(8) to reflect IPv6 support
      statd: Support TI-RPC statd listener
      libnsm.a: retain CAP_NET_BIND when dropping privileges
      statd: Remove NL_ADDR() macro
      statd: Support IPv6 in sm_stat_1_svc()
      statd: Support IPv6 in sm_mon_1_svc()
      statd: Add API to canonicalize mon_names
      libnsm.a: Add support for multiple lines in monitor record files
      libnsm.a: Factor atomic write code out of nsm_get_state()
      sm-notify: Save mon_name and my_name strings
      statd: Support IPv6 in sm_simu_crash_1_svc
      statd: Support IPv6 is caller_is_localhost()
      statd: add IPv6 support in sm_notify_1_svc()
      statd: add nsm_present_address() API
      statd: Introduce statd version of matchhostname()
      nfs-utils: Collect socket address helpers into one location
      sm-notify: Support IPv6 DNS lookups in smn_lookup
      sm-notify: Use getaddrinfo(3) to create bind address in smn_create_socket()
      sm-notify: IPv6 support in reserved port binding in smn_create_socket()
      sm-notify: Support creating a PF_INET6 socket in smn_create_socket()
      sm-notify: factor socket creation out of notify()
      statd: Update rmtcall.c
      sm-notify: Replace RPC code
      libnsm.a: Add RPC construction helper functions


 aclocal/libcap.m4          |   15 +
 configure.ac               |    3 
 support/include/nfsrpc.h   |   12 -
 support/include/nsm.h      |   31 ++-
 support/include/rpcmisc.h  |    7 -
 support/include/sockaddr.h |  237 ++++++++++++++++++++
 support/nfs/Makefile.am    |    3 
 support/nfs/getport.c      |   21 +-
 support/nfs/rpc_socket.c   |   55 +----
 support/nfs/svc_create.c   |  252 +++++++++++++++++++++
 support/nsm/Makefile.am    |    2 
 support/nsm/file.c         |  336 +++++++++++++++++++++++-----
 support/nsm/rpc.c          |  534 ++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/network.c      |   13 -
 utils/mount/stropts.c      |    7 -
 utils/statd/Makefile.am    |    9 -
 utils/statd/callback.c     |   74 +++++-
 utils/statd/hostname.c     |  284 +++++++++++++++++++++++
 utils/statd/monitor.c      |   68 +++---
 utils/statd/notlist.c      |    5 
 utils/statd/notlist.h      |    6 
 utils/statd/rmtcall.c      |  197 ++++------------
 utils/statd/simu.c         |   35 ++-
 utils/statd/sm-notify.c    |  496 ++++++++++++++++++++++++-----------------
 utils/statd/sm-notify.man  |  407 +++++++++++++++++++++++-----------
 utils/statd/stat.c         |   13 +
 utils/statd/statd.c        |   38 +++
 utils/statd/statd.h        |    7 -
 utils/statd/statd.man      |  508 ++++++++++++++++++++++++++++++------------
 29 files changed, 2831 insertions(+), 844 deletions(-)
 create mode 100644 aclocal/libcap.m4
 create mode 100644 support/include/sockaddr.h
 create mode 100644 support/nfs/svc_create.c
 create mode 100644 support/nsm/rpc.c
 create mode 100644 utils/statd/hostname.c

-- 
Signature
