Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:40105 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753428Ab0IMRUv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 13:20:51 -0400
Received: by gxk23 with SMTP id 23so2101445gxk.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Sep 2010 10:20:51 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/12] Next series of mountd IPv6 support patches
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 13 Sep 2010 13:20:48 -0400
Message-ID: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This series enables support for IPv6 addresses when receiving mountd
requests and processing export records.

The final series (later this week, or next) will enable mountd to
listen on IPv6 transports.

---

Chuck Lever (12):
      libexport.a: Enable IPv6 support in hostname.c
      mountd: Ensure cache downcall can handle IPv6 addresses
      mountd: Handle IPv6 addresses in kernel auth_unix_ip upcalls
      mountd: clean up cache API
      exportfs: Enable IPv6 support in matchhostname()
      mountd: Support IPv6 in mountlist_list()
      mountd: Handle memory exhaustion in mountlist_list()
      mountd: Add mountlist_freeall()
      mountd: support IPv6 in mountlist_del_all()
      mountd: Support IPv6 in mountd's svc routines
      mountd: add IPv6 support in auth_authenticate()
      libnfs.a: Fix API for getfh() & friends


 support/export/hostname.c |   31 +++++++--------
 support/include/nfslib.h  |    9 +++-
 support/nfs/getfh.c       |   64 ++++++++++++++++++++++++++++---
 utils/exportfs/exportfs.c |   23 +----------
 utils/mountd/auth.c       |   52 +++++++++++++------------
 utils/mountd/cache.c      |   57 +++++++++++++++++++++-------
 utils/mountd/mountd.c     |   92 +++++++++++++++++++++++++++++++--------------
 utils/mountd/mountd.h     |   11 ++++-
 utils/mountd/rmtab.c      |   72 +++++++++++++++++++++++------------
 9 files changed, 270 insertions(+), 141 deletions(-)

-- 
Chuck Lever
