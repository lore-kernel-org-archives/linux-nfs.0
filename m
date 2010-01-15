Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:48720 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758337Ab0AOVbo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jan 2010 16:31:44 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/6] IPv6 support for nfs-utils tcpwrapper shim (take 2)
To: steved@redhat.com
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
Date: Fri, 15 Jan 2010 16:31:04 -0500
Message-ID: <20100115212102.18214.19398.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

These patches provide IPv6 support for the tcpwrapper shim inside
nfs-utils.

We've confirmed that libwrap.a (at least the version included in
Fedora 12) does support IPv6.  Some of the man pages are missing some
updates.

I've constructed some simple unit tests using an old program that can
send bogus SM_NOTIFY requests.  Switching hostnames and IPv6 addresses
in and out of /etc/hosts.{allow,deny} shows this code with my patches
to be operating as designed, for basic scenarios.

I also added more verbose logging in from_local() to confirm how the
new getifaddrs(3) code is working.  No unpleasant surprises there.

Testing resulted in no operational changes to the logic in any of
these patches, but the extra logging seemed worth including, hence
this redrive.

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
 support/misc/from_local.c     |  121 +++++++++++++++++++++---
 support/misc/tcpwrapper.c     |  203 ++++++++++++++++++++++++-----------------
 utils/mountd/mount_dispatch.c |    6 -
 utils/statd/statd.c           |    5 -
 utils/statd/statd.man         |    3 -
 8 files changed, 232 insertions(+), 124 deletions(-)

-- 
chuck[dot]lever[at]oracle[dot]com
