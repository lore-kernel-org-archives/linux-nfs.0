Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54111 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752134Ab1LUUfX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Dec 2011 15:35:23 -0500
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org, steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 00/10] nfsdcld: add a daemon to track NFSv4 client names on stable storage
Date: Wed, 21 Dec 2011 15:35:12 -0500
Message-Id: <1324499722-10363-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset is the userspace portion of the knfsd client name tracking
overhaul. See this patch series for an explanation:

    nfsd: overhaul the client name tracking code

The main changes from the last set are:

- a bunch of cleanups and better patch "division" for bisectability

- the daemon will downcall with an error now when given an upcall
  command that it doesn't recognize

- it now uses inotify to wait for the pipe instead of polling

- more comprehensive autoconf tests for required headers and libraries

- it's disabled from the build by default. You need to configure with
  --enable-nfsdcld to turn it on. Steve felt that this would help smooth
  the transition for distro packagers.

- a manpage and README update have been added

The daemon listens for upcalls on the rpc_pipefs pipe using libevent,
and handles the requests from the kernel.

The data is stored using a sqlite database. The main reason for this is
that it takes care of most of the fussy details and atomicity concerns
of tracking the information on stable storage.

For now, the daemon is only suitable for single-host configurations.
My plan is to later extend this to be suitable for clustered
configurations as well.

At this point, I think the daemon is ready for inclusion. It would be
good for it to make the next nfs-utils release to coincide with the
kernel patches going into 3.3.

Jeff Layton (10):
  autoconf: fix up libevent autoconf test
  nfsdcld: add client tracking daemon stub
  nfsdcld: add autoconf goop for sqlite
  nfsdcld: add routines for a sqlite backend database
  nfsdcld: add remove functionality
  nfsdcld: add check/update functionality
  nfsdcld: add function to remove unreclaimed client records
  nfsdcld: allow daemon to wait for pipe to show up
  nfsdcld: add a manpage for nfsdcld
  nfsdcld: update the README

 README                    |   25 +++-
 aclocal/libevent.m4       |    3 +-
 aclocal/libsqlite3.m4     |   33 ++++
 configure.ac              |   21 +++
 utils/Makefile.am         |    4 +
 utils/idmapd/Makefile.am  |    2 +-
 utils/nfsdcld/Makefile.am |   14 ++
 utils/nfsdcld/nfsdcld.c   |  410 +++++++++++++++++++++++++++++++++++++++++++++
 utils/nfsdcld/nfsdcld.man |  180 ++++++++++++++++++++
 utils/nfsdcld/nfsdcld.pod |   67 ++++++++
 utils/nfsdcld/sqlite.c    |  385 ++++++++++++++++++++++++++++++++++++++++++
 utils/nfsdcld/sqlite.h    |   29 ++++
 12 files changed, 1169 insertions(+), 4 deletions(-)
 create mode 100644 aclocal/libsqlite3.m4
 create mode 100644 utils/nfsdcld/Makefile.am
 create mode 100644 utils/nfsdcld/nfsdcld.c
 create mode 100644 utils/nfsdcld/nfsdcld.man
 create mode 100644 utils/nfsdcld/nfsdcld.pod
 create mode 100644 utils/nfsdcld/sqlite.c
 create mode 100644 utils/nfsdcld/sqlite.h

