Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:61229 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757711Ab0IGQ0C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 12:26:02 -0400
Received: by gyd8 with SMTP id 8so2026967gyd.19
        for <linux-nfs@vger.kernel.org>; Tue, 07 Sep 2010 09:26:01 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] Handle "proto=rdma" regressions
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 07 Sep 2010 12:25:55 -0400
Message-ID: <20100907162156.3392.90376.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Steve-

This series is entirely untested, and is meant to be only an example
of how we could handle "proto=rdma" and "rdma" in mount.nfs.

The last patch in the series may not work at all.  It depends on the
kernel returning EPROTONOSUPPORT for "vers=4,rdma".

---

Chuck Lever (4):
      mount.nfs: Prepare way for "vers=4,rdma" mounts
      mount.nfs: Support an "rdma" mount option
      mount.nfs: Use nfs_nfs_protocol() for checking for proto=rdma
      getport: Recognize "rdma" and "rdma6" netid


 support/include/nfsrpc.h |    6 ++++++
 support/nfs/getport.c    |   25 +++++++++++++++++++++++++
 utils/mount/network.c    |    9 +++++++--
 utils/mount/nfs.man      |   11 ++++++++++-
 utils/mount/stropts.c    |   16 ++++++++--------
 5 files changed, 56 insertions(+), 11 deletions(-)

-- 
Chuck Lever
