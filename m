Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:65501 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755127Ab1CYVh6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Mar 2011 17:37:58 -0400
Received: by gwaa18 with SMTP id a18so632092gwa.19
        for <linux-nfs@vger.kernel.org>; Fri, 25 Mar 2011 14:37:57 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] Three short subjects for nfs-utils
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 25 Mar 2011 17:37:39 -0400
Message-ID: <20110325213559.27166.71461.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Steve-

Here are two minor bug fixes, and a mountd clean up that will help out
with FedFS down the road.  No hurry.

---

Chuck Lever (2):
      statd: Remove vestigial "-w" option from man page synopsis
      mount.nfs: Don't leak socket in nfs_ca_sockname()

Trond Myklebust (1):
      exports: add a configurable time-to-live for the kernel cache entries


 support/include/exportfs.h |    1 +
 support/include/nfslib.h   |    1 +
 support/nfs/exports.c      |    1 +
 utils/mount/network.c      |   28 +++++++++++++---------------
 utils/mountd/cache.c       |   15 ++++++++-------
 utils/statd/statd.man      |    2 +-
 6 files changed, 25 insertions(+), 23 deletions(-)

-- 
Chuck Lever
