Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f41.google.com ([209.85.215.41]:57791 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609AbaG3LX3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 07:23:29 -0400
Received: by mail-la0-f41.google.com with SMTP id s18so781168lam.28
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 04:23:27 -0700 (PDT)
From: Natanael Copa <natanael.copa@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH 00/11] Porting nfs-utils to musl libc
Date: Wed, 30 Jul 2014 13:23:08 +0200
Message-Id: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Musl libc is a modern libc for Linux which focuses on correctness in
standards-conformance. We use this libc for Alpine Linux.

This patchset makes nfs-utils build with musl libc and should generally
improve portability.

It would be nice if at least some of the patches could be applied
upstream so we can reduce the number of patches for getting nfs working
on Alpine Linux.

Natanael Copa (11):
  conffile: use standard uint*_t and unsigned char
  Fix header include for definition of NULL
  replace __attribute_malloc__ with the more portable
    __attribute__((__malloc__))
  exportfs: define _GNU_SOURCE for stat64
  mountd: define _GNU_SOURCE for statfs64 and use standard dev_t
  nfsstat: replace the legacy SA_ONESHOT with standard SA_RESETHAND
  Allow usage of getrpcbynumber() when getrpcbynumber_r() is unavailable
  include libgen.h for basename
  Only work around glibc bugs on glibc
  exportfs: fix test of NULL pointer in host_pton()
  exportfs: only do glibc specific hackery on glibc

 configure.ac                 |  6 +-----
 support/export/hostname.c    | 29 +++++++++++++++++------------
 support/include/conffile.h   |  2 +-
 support/include/exportfs.h   | 10 +++++-----
 support/include/sockaddr.h   |  1 +
 support/nfs/conffile.c       | 14 +++++++-------
 support/nfs/svc_create.c     |  2 +-
 support/nfs/svc_socket.c     |  6 ++++++
 tools/rpcdebug/rpcdebug.c    |  1 +
 utils/exportfs/exportfs.c    |  4 ++++
 utils/mount/mount.c          |  1 +
 utils/mount/mount_libmount.c |  1 +
 utils/mountd/cache.c         |  6 +++++-
 utils/mountd/svc_run.c       |  2 +-
 utils/nfsd/nfsd.c            |  1 +
 utils/nfsidmap/nfsidmap.c    |  1 +
 utils/nfsstat/nfsstat.c      |  2 +-
 utils/statd/hostname.c       |  6 +++---
 utils/statd/sm-notify.c      |  8 ++++----
 utils/statd/statd.h          |  2 +-
 20 files changed, 63 insertions(+), 42 deletions(-)

-- 
2.0.3

