Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:62518 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540Ab0AHSNs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jan 2010 13:13:48 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] Create shared API to access on-disk NSM data
To: steved@redhat.com
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
Date: Fri, 08 Jan 2010 13:13:23 -0500
Message-ID: <20100108180144.452.14970.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The goal of these patches is to replace duplicate code in statd and
sm-notify that accesses the local NSM state number and the on-disk
monitor and notify lists.  This change allows us to fix bugs and add
IPv6 support in one place instead of two.

There should be little behavioral change, since the new code in
libnsm.a is by and large copied from existing code in statd and
sm-notify.  Some error checking is enhanced.  The sync(2) system call
done after an NSM state number update is removed, since the update is
already performed with POSIX file system calls that are all
synchronous with permanent storage.

---

Chuck Lever (3):
      statd: Use the new nsm_ file.c calls in rpc.statd
      statd: Use the new nsm_ file.c calls in sm_notify
      libnsm.a: Introduce common routines to handle persistent storage


 support/include/Makefile.am |    2 
 support/include/nsm.h       |   64 +++
 support/nsm/Makefile.am     |    2 
 support/nsm/file.c          |  819 +++++++++++++++++++++++++++++++++++++++++++
 utils/statd/misc.c          |   24 -
 utils/statd/monitor.c       |  140 ++-----
 utils/statd/sm-notify.c     |  288 +++------------
 utils/statd/statd.c         |  116 +-----
 utils/statd/statd.h         |   23 -
 9 files changed, 1006 insertions(+), 472 deletions(-)
 create mode 100644 support/include/nsm.h
 create mode 100644 support/nsm/file.c

-- 
Chuck Lever <chuck.lever@oracle.com>
