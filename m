Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:56967 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533Ab0LNPE5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 10:04:57 -0500
Received: by gyb11 with SMTP id 11so379987gyb.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 07:04:57 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/11] nlm_host cache split for 2.6.38
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 10:04:54 -0500
Message-ID: <20101214150036.2736.98254.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond-

This patch series splits the nlm_host cache into a client-side cache
and a server-side cache.  It lays the groundwork for further work in
this area to simplify and improve the efficiency of these caches by
tuning them for their specific tasks.

Note that the two caches continue to share reboot notification logic,
as statd does not distinguish between client and server peers, and
only a single downcall mechanism exists for both.

---

Chuck Lever (9):
      lockd: Remove src_sap and src_len from nlm_lookup_host_info struct
      lockd: Remove nlm_lookup_host()
      lockd: Make nrhosts an unsigned long
      lockd: Rename nlm_hosts
      lockd: Clean up nlmsvc_lookup_host()
      lockd: Create client-side nlm_host cache
      lockd: Split nlm_release_call()
      lockd: Add nlm_destroy_host_locked()
      lockd: Add nlm_alloc_host()

J. Bruce Fields (2):
      lockd: reorganize nlm_host_rebooted
      lockd: define host_for_each{_safe} macros


 fs/lockd/clntlock.c         |    4 
 fs/lockd/clntproc.c         |   18 +-
 fs/lockd/host.c             |  410 ++++++++++++++++++++++++++-----------------
 fs/lockd/svc4proc.c         |   20 +-
 fs/lockd/svclock.c          |    4 
 fs/lockd/svcproc.c          |   28 ++-
 include/linux/lockd/lockd.h |    6 -
 7 files changed, 291 insertions(+), 199 deletions(-)

-- 
Chuck Lever
