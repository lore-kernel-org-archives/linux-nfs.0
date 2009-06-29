From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/31] mount.nfs patches for next nfs-utils release
Date: Mon, 29 Jun 2009 13:34:49 -0400
Message-ID: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:35882 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757624AbZF2RfN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:35:13 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

This series contains some patches I've had for a little while, and a
bunch of new fixes I made last week to address RH bugzillas 486266 and
505535.

In the short term, these patches should address most of the recent
complaints about the new mount.nfs.  Text-based mounts should behave
a lot more like legacy mounts -- fewer hangs and better negotiation
semantics.

Longer term, we are planning to sink the mount version/transport
negotiation into the kernel.

---

Chuck Lever (31):
      mount.nfs: Squelch compiler warnings in nfs_strerror()
      mount.nfs: Squelch unused parameter warnings on empty functions
      mount.nfs: Fix compiler warning in stropts.c
      umount.nfs: Use correct data type in nfsumount()
      mount.nfs: remove unused @addrlen argument from nfs_string_to_sockaddr()
      mount.nfs: Remove unused @salen parameter from nfs_ca_gai()
      mount.nfs: Fix some nfs_error() nits in network.c
      mount.nfs: Remove unused parameter in try_mount()
      mount.nfs: Use correct data type in discover_nfs_mount_data_version()
      support: Introduce sockaddr helpers to get and set IP port numbers
      mount.nfs: Don't update extra_opts after text-based negotiation
      mount.nfs: Clean up after restructuring version/protocol negotiation
      mount.nfs: Clean up nfs_is_permanent_error()
      mount.nfs: rearchitect mount version/protocol negotiation logic
      mount.nfs: make nfs_options2pmap return errors
      mount.nfs: force rpcbind queries if options aren't specified
      mount.nfs: If port= specifies an unregistered port, retry, then fail
      getport: Convert TCP connection refused to RPC_CANTRECV
      getport: Restore historical TCP connect timeout error code
      mount.nfs: Add more debugging output around nfs_getport()
      getport: Clear shared error fields before trying rpcbind queries
      getport: RPC_PROGNOTREGISTERED is a permanent error
      support: Set proper retransmit timeout for datagram transports
      support: Don't return RPC_UNKNOWNHOST from rpc_socket.c
      support: Use HAVE_LIBTIRPC to switch in bindresvport_sa(3t)
      New versions of libtool add extra aclocal scripts
      getport: Remove unneeded @salen arguments
      getport: replace getnameinfo(NI_NUMERICHOST) with inet_ntop(3)
      getport: Remove AI_ADDRCONFIG from nfs_gp_loopback_address()
      getport: RPCB_GETADDR's r_addr should contain rpcbind port, not zero
      getport: RPCB_GETADDR r_owner should be an empty string


 .gitignore               |    5 +
 support/include/nfsrpc.h |   23 ++-
 support/nfs/getport.c    |  276 +++++++++++++++------------------
 support/nfs/rpc_socket.c |   77 +++++++--
 utils/mount/error.c      |   12 +
 utils/mount/error.h      |    2 
 utils/mount/fstab.c      |    2 
 utils/mount/mount.c      |    8 -
 utils/mount/network.c    |  380 +++++++++++++++++++++++++++++++---------------
 utils/mount/network.h    |    5 -
 utils/mount/nfsumount.c  |    7 +
 utils/mount/parse_dev.c  |    5 -
 utils/mount/stropts.c    |  250 ++++++++++--------------------
 13 files changed, 560 insertions(+), 492 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
