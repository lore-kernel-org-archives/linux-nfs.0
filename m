From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/6] IPv6 support for nfs-utils tcpwrapper shim
Date: Fri, 15 Jan 2010 12:49:31 -0500
Message-ID: <20100115174426.30104.3492.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:52896 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111Ab0AORty (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jan 2010 12:49:54 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches provide IPv6 support for the tcpwrapper shim inside
nfs-utils.  It assumes that the generic tcpwrapper library can
support IPv6 addresses.  It has not been extensively tested, but
I think the framework is reasonable, and only minor bug fixes might
be needed as we go along.

---

Chuck Lever (6):
      tcpwrapper: Add support for IPv6
      tcpwrapper: Eliminated shadowed declaration warnings
      tcpwrapper: Fix signage problems in the tcp_wrappers hash function
      tcp_wrapper: Clean up logit()
      tcp_wrappers: Use getifaddrs(3) if it is available
      tcpwrappers: Use xlog() instead of perror(3) and syslog(2)


 aclocal/ipv6.m4               |    4 -
 configure.ac                  |    2 
 support/include/tcpwrapper.h  |   12 +-
 support/misc/from_local.c     |  112 +++++++++++++++++++----
 support/misc/tcpwrapper.c     |  203 ++++++++++++++++++++++++-----------------
 utils/mountd/mount_dispatch.c |    6 -
 utils/statd/statd.c           |    5 -
 utils/statd/statd.man         |    3 -
 8 files changed, 223 insertions(+), 124 deletions(-)

-- 
chuck[dot]lever[at]oracle[dot]com
