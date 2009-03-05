From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/9] Address type width mismatches between TI-RPC and glibc
Date: Thu, 05 Mar 2009 12:41:45 -0500
Message-ID: <20090305173533.30471.41413.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:17643 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753006AbZCERmS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 12:42:18 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve-

Now that the clean up is finished, here are the patches that actually
fix the type width mismatch problem between glibc headers and the
TI-RPC run-time.

This patch set implements a full switch between TI-RPC run-time and
headers and legacy glibc RPC run-time and headers via --enable-tirpc.

In addition there are a number of configure.ac clean ups.

These are the final patches needed to support TI-RPC and IPv6 properly
in mount.nfs, umount.nfs, and showmount.

---

Chuck Lever (7):
      nfs-utils: Include legacy or TI-RPC headers, not both
      configure: move IPv6 feature checks into aclocal/
      configure: Move rpcsecgss checking into aclocal
      configure: pull common nfsidmap and event checks into aclocal/
      nfs-utils: replace function-specific switches with HAVE_LIBTIRPC
      configure: move TI-RPC checks into aclocal/
      configure: add defensive quoting in some function checks

Jeff Layton (2):
      nfs-utils: clean up handling of libgssglue in gssd Makefile
      nfs-utils: don't need extra libs to do AC_CHECK_LIBS for librpcsecgss


 Makefile.am              |    7 +++
 aclocal/ipv6.m4          |   29 ++++++++++++
 aclocal/libevent.m4      |   11 +++++
 aclocal/libnfsidmap.m4   |   17 +++++++
 aclocal/librpcsecgss.m4  |   19 ++++++++
 aclocal/libtirpc.m4      |   28 ++++++++++++
 aclocal/rpcsec_vers.m4   |   12 +++++
 configure.ac             |  107 +++++++++++++++++-----------------------------
 support/nfs/getport.c    |   40 +++++++++--------
 support/nfs/rpc_socket.c |   95 ++++++++++++-----------------------------
 utils/gssd/Makefile.am   |   10 ++--
 utils/gssd/gssd_proc.c   |    3 +
 utils/gssd/krb5_util.c   |    1 
 utils/gssd/krb5_util.h   |    6 +++
 utils/mountd/svc_run.c   |    4 ++
 15 files changed, 226 insertions(+), 163 deletions(-)
 create mode 100644 aclocal/ipv6.m4
 create mode 100644 aclocal/libevent.m4
 create mode 100644 aclocal/libnfsidmap.m4
 create mode 100644 aclocal/librpcsecgss.m4
 create mode 100644 aclocal/libtirpc.m4
 create mode 100644 aclocal/rpcsec_vers.m4

-- 
Chuck Lever
