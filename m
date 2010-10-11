Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:38170 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752478Ab0JKAEF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Oct 2010 20:04:05 -0400
Received: by iwn6 with SMTP id 6so2668490iwn.19
        for <linux-nfs@vger.kernel.org>; Sun, 10 Oct 2010 17:04:04 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/15] Fixes for nfs-utils-1.2.4
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Sun, 10 Oct 2010 20:04:01 -0400
Message-ID: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Steve-

Here are fifteen patches which address several mount and mountd bugs
and correct other minor problems in nfs-utils-1.2.3.  Now that the
bake-a-thon event has passed, folks should have some spare moments to
review these.

This series includes the final version of the patch that addresses the
"mountd -p <port> does not work" issue.

The series does not include a patch to address the "remount erases a
mount point's version setting" issue.  The remount problem is not a
1.2.3 regression, it's been around for a very long time.  I'm still
exploring solutions.

These patches are also available in my nfs-utils git repo on
git.linux-nfs.org.

---

Chuck Lever (14):
      mount.nfs: don't show "remount" flag in /etc/mtab
      umount.nfs: Distinguish between nfs4 and nfs mounts
      mount.nfs: mountproto does not support RDMA
      mount.nfs: Eliminate compiler warnings in utils/mount/network.c
      mount.nfs: Eliminate compiler warning in utils/mount/parse_opt.c
      mount.nfs: Eliminate compiler warning in utils/mount/nfsumount.c
      mount.nfs: Eliminate compiler warning in utils/mount/nfsumount.c
      mount.nfs: Eliminate compiler warnings in utils/mount/mount.c
      mount.nfs: Eliminate compiler warning in utils/mount/mount.c
      mount.nfs: Eliminate compiler warnings in utils/mount/version.h
      mount.nfs: Eliminate compiler warning in utils/mount/mount.c
      mount.nfs: Eliminate compiler warnings
      libnfs.a: Allow multiple RPC listeners to share listener port number
      mountd: Clear mountd registrations at start up

Trond Myklebust (1):
      export: Ensure that we free struct exportent->e_uuid


 support/export/export.c       |    1 
 support/nfs/exports.c         |    2 
 support/nfs/svc_create.c      |  252 ++++++++++++++++++++++++++++++++++++++++-
 utils/mount/fstab.c           |   29 +++--
 utils/mount/mount.c           |   10 +-
 utils/mount/mount_config.h    |   21 ++-
 utils/mount/mount_constants.h |    4 +
 utils/mount/network.c         |   29 +++--
 utils/mount/nfsumount.c       |  120 ++++++++++++++++++--
 utils/mount/parse_opt.c       |    2 
 utils/mount/version.h         |    6 -
 utils/mountd/mountd.c         |    1 
 12 files changed, 417 insertions(+), 60 deletions(-)

-- 
Chuck Lever
