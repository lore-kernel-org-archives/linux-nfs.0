Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qw0-f53.google.com ([209.85.216.53]:57475 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753803Ab2AWUCT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2012 15:02:19 -0500
Received: by qabg24 with SMTP id g24so1996566qab.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jan 2012 12:02:18 -0800 (PST)
MIME-Version: 1.0
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 00/11] nfsdcld: add a daemon to track NFSv4 client names on stable storage
Date: Mon, 23 Jan 2012 15:02:00 -0500
Message-Id: <1327348931-785-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset is the userspace portion of the knfsd client name tracking
overhaul. See this patch series for an explanation:

    nfsd: overhaul the client name tracking code

The main changes from the last set are:

- the daemon will now reopen the pipe if it's deleted and recreated. This
  can happen if knfsd is restarted.

- The daemon now implements an "init" upcall. When knfsd starts, it will
  upcall to userspace to ask for a "boot_generation" value. nfsdcld will
  fetch that value out of the DB, increment it and reinsert it (atomically).
  That guarantees uniqueness of the boot generation value even when multiple
  machines are sharing the same nfsdcld db.

- the "create" and "check" upcalls now send the rowid of the record in the
  downcall. Eventually the kernel will use this to track some info about
  lockowners in some situations. For now the kernel ignores this value,
  but the daemon passes it anyway.

- "remove" functionality has been removed from the daemon. The upcall that
  previously requested that has been removed, so we have no need for that
  functionality in the daemon. Client records are now only removed when
  the grace period ends.

Jeff Layton (11):
  nfsdcld: add client tracking daemon stub
  nfsdcld: add autoconf goop for sqlite
  nfsdcld: add routines for a sqlite backend database
  nfsdcld: add check/update functionality
  nfsdcld: add function to remove unreclaimed client records
  nfsdcld: have daemon pass client row index back to kernel
  nfsdcld: implement an init upcall
  nfsdcld: allow daemon to wait for pipe to show up
  nfsdcld: reopen pipe if it's deleted and recreated
  nfsdcld: add a manpage for nfsdcld
  nfsdcld: update the README

 README                    |   25 +++-
 aclocal/libsqlite3.m4     |   33 +++
 configure.ac              |   21 ++
 utils/Makefile.am         |    4 +
 utils/nfsdcld/Makefile.am |   14 ++
 utils/nfsdcld/nfsdcld.c   |  478 +++++++++++++++++++++++++++++++++++++++++++++
 utils/nfsdcld/nfsdcld.man |  180 +++++++++++++++++
 utils/nfsdcld/nfsdcld.pod |   67 +++++++
 utils/nfsdcld/sqlite.c    |  461 +++++++++++++++++++++++++++++++++++++++++++
 utils/nfsdcld/sqlite.h    |   31 +++
 10 files changed, 1312 insertions(+), 2 deletions(-)
 create mode 100644 aclocal/libsqlite3.m4
 create mode 100644 utils/nfsdcld/Makefile.am
 create mode 100644 utils/nfsdcld/nfsdcld.c
 create mode 100644 utils/nfsdcld/nfsdcld.man
 create mode 100644 utils/nfsdcld/nfsdcld.pod
 create mode 100644 utils/nfsdcld/sqlite.c
 create mode 100644 utils/nfsdcld/sqlite.h

-- 
1.7.7.5

