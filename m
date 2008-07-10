From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/14] Support for mounting NFSv4 servers over IPv6
Date: Wed, 09 Jul 2008 20:37:01 -0400
Message-ID: <20080710001725.6137.83845.stgit@tarkus.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:61683 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbYGJEIN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2008 00:08:13 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

Just for fun, here is the latest version of the patches that add support to
the text-based mount.nfs command for mounting NFSv4 servers over IPv6.  This
patch set applies on top of the patches I posted here last week.

It was suggested that these be included in the next release of
nfs-utils, 1.1.3.  Kernel support for these features (such as handling raw
IPv6 NFS server addresses properly when mounting) is planned for 2.6.27, so
inclusion of these patches would allow wider testing during .27's rc period.

Mounting NFSv2/v3 servers over IPv6 is more complex.  It requires support
for a scalable rpcbind/portmap client built into nfs-utils, thus it is not
included in the present patch series.  Anyone interested in looking at my
current prototype for this can check out:

  http://git.linux-nfs.org/?p=cel/nfs-utils.git;a=summary

It includes all the patches in this series and the patches I posted last
week for nfs-utils 1.1.3, client-side support for NFSv2/v3 mounting and
unmounting over IPv6, a prototype IPv6-enabled sm-notify command, and
updates to nfs(5) describing IPv6 support for the NFS client.

For what it's worth, I'll be on holiday next week, but I can field any
questions or comments before this Saturday, or when I return.

---

Chuck Lever (14):
      mount command: Remove RPC headers from network.h
      text-based mount command: remove unnecessary headers from stropts.c
      text-based mount options: rename functions in stropts.c
      text-based mount command: Remove unused IPv4-only functions
      text-based mount command: Support raw IPv6 address hostnames
      text-based mount command: Add IPv6 support to set_mandatory_options
      text-based mount command: "mounthost=" option support for IPv6 addresses
      text-based mount command: "clientaddr=" option support for IPv6 addresses
      text-based mount command: "addr=" option support for IPv6 addresses
      text-based mount command: Add helper to construct network addresses
      text-based mount command:  get_client_address support for IPv6
      mount command: Add functions to manage addresses in string form
      text-based mount command: Add headers needed for IPv6 support
      nfs-utils: Introduce new ./configure option: "--enable-ipv6"


 configure.ac            |   29 ++++++
 utils/mount/Makefile.am |    6 +
 utils/mount/error.c     |    2 
 utils/mount/mount.c     |    1 
 utils/mount/network.c   |  237 +++++++++++++++++++++++++++++++++++++++++------
 utils/mount/network.h   |   17 +--
 utils/mount/nfs4mount.c |    2 
 utils/mount/nfsmount.c  |    7 +
 utils/mount/nfsumount.c |   35 +++----
 utils/mount/parse_dev.c |  230 ++++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/parse_dev.h |   28 ++++++
 utils/mount/stropts.c   |  229 ++++++++++++++++++---------------------------
 12 files changed, 617 insertions(+), 206 deletions(-)
 create mode 100644 utils/mount/parse_dev.c
 create mode 100644 utils/mount/parse_dev.h

-- 
Signature
