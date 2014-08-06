Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f169.google.com ([209.85.217.169]:64408 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbaHFGZQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 02:25:16 -0400
Received: by mail-lb0-f169.google.com with SMTP id s7so1562000lbd.28
        for <linux-nfs@vger.kernel.org>; Tue, 05 Aug 2014 23:25:14 -0700 (PDT)
From: Natanael Copa <natanael.copa@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH v2 00/11] Porting nfs-utils to musl libc
Date: Wed,  6 Aug 2014 08:24:55 +0200
Message-Id: <1407306306-29796-1-git-send-email-ncopa@alpinelinux.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Musl libc is a modern libc for Linux which focuses on correctness in
standards-conformance. We use this libc for Alpine Linux.

This patchset makes nfs-utils build with musl libc and should generally
improve portability.

It would be nice if at least some of the patches could be applied
upstream so we can reduce the number of patches for getting nfs working
on Alpine Linux.

Changes v1 -> v2 based on feedback:
 - Use AC_USE_SYSTEM_EXTENSIONS in configure.ac instead of defining
   _GNU_SOURCE various places. This means that the patch "include
   libgen.h for basename" is strictly no longer needed, but I kept it
   since this is more "correct".
 - Fix typo in "exportfs: only do glibc specific hackery on glibc"

Natanael Copa (11):
  conffile: use standard uint*_t and unsigned char
  Fix header include for definition of NULL
  configure.ac: enable GNU_SOURCE for stat64/statfs64
  replace __attribute_malloc__ with the more portable
    __attribute__((__malloc__))
  mountd: use standard dev_t instead of glibc internals
  nfsstat: replace the legacy SA_ONESHOT with standard SA_RESETHAND
  Allow usage of getrpcbynumber() when getrpcbynumber_r() is unavailable
  Only work around glibc bugs on glibc
  include libgen.h for basename
  exportfs: fix test of NULL pointer in host_pton()
  exportfs: only do glibc specific hackery on glibc

 configure.ac                 |  7 ++-----
 support/export/hostname.c    | 29 +++++++++++++++++------------
 support/include/conffile.h   |  2 +-
 support/include/exportfs.h   | 10 +++++-----
 support/include/sockaddr.h   |  1 +
 support/nfs/conffile.c       | 14 +++++++-------
 support/nfs/svc_create.c     |  2 +-
 support/nfs/svc_socket.c     |  6 ++++++
 tools/rpcdebug/rpcdebug.c    |  1 +
 utils/mount/mount.c          |  1 +
 utils/mount/mount_libmount.c |  1 +
 utils/mountd/cache.c         |  2 +-
 utils/mountd/svc_run.c       |  2 +-
 utils/nfsd/nfsd.c            |  1 +
 utils/nfsidmap/nfsidmap.c    |  1 +
 utils/nfsstat/nfsstat.c      |  2 +-
 utils/statd/hostname.c       |  6 +++---
 utils/statd/sm-notify.c      |  8 ++++----
 utils/statd/statd.h          |  2 +-
 19 files changed, 56 insertions(+), 42 deletions(-)

-- 
2.0.4

