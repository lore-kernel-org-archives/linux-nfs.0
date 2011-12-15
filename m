Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32563 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756260Ab1LOSoC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Dec 2011 13:44:02 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBFIi1sU008064
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2011 13:44:01 -0500
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [10.11.228.66])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id pBFIi17c010403
	for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2011 13:44:01 -0500
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/7] nfsdcld: add a daemon to track NFSv4 client names on stable storage
Date: Thu, 15 Dec 2011 13:43:54 -0500
Message-Id: <1323974641-16515-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset is the userspace portion of the knfsd client name tracking
overhaul. See this patch series for an explanation:

    nfsd: overhaul the client name tracking code (RFC)

The main changes from the last set are:

- the daemon has been renamed from clstated to nfsdcld, per Steve D's
  suggestion

- the client names are no longer tracked on a per-server-address basis.
  Chuck Lever pointed out that doing so would break the UCS migration
  model. This version just keeps a single clients table in the main
  database (which also significantly simplifies the code).

- other bugfixes and cleanups

The daemon listens for upcalls on the rpc_pipefs pipe using libevent,
and handles the requests.

The data is stored using a sqlite database. The main reason for this is
that it takes care of most of the fussy details and atomicity concerns
of tracking the information on stable storage.

Surprisingly, there is some controversy over this, but I believe it's
the right design decision. I'm willing to change that however if there
are legitimate technical concerns. In that event, I'd appreciate
constructive suggestions about what should replace it.

For now, the daemon is only suitable for single-host configurations.
My plan is to later extend this to be suitable for clustered
configurations as well.

The code is still a little rough, so be gentle. It also lacks things
like a manpage. I plan to add all that before doing a "formal" patch
submission, but I wanted to get some early review of the overall design
before to spend a lot of time knocking off the rough edges.

Jeff Layton (7):
  autoconf: fix up libevent autoconf test
  nfsdcld: add client tracking daemon stub
  nfsdcld: add autoconf goop for sqlite
  nfsdcld: add routines for a sqlite backend database
  nfsdcld: add remove functionality
  nfsdcld: add check/update functionality
  nfsdcld: add function to remove unreclaimed client records

 aclocal/libevent.m4       |    3 +-
 aclocal/libsqlite3.m4     |   33 ++++
 configure.ac              |   23 +++
 utils/Makefile.am         |    4 +
 utils/idmapd/Makefile.am  |    2 +-
 utils/nfsdcld/Makefile.am |   14 ++
 utils/nfsdcld/nfsdcld.c   |  332 ++++++++++++++++++++++++++++++++++++++
 utils/nfsdcld/sqlite.c    |  388 +++++++++++++++++++++++++++++++++++++++++++++
 utils/nfsdcld/sqlite.h    |   30 ++++
 9 files changed, 827 insertions(+), 2 deletions(-)
 create mode 100644 aclocal/libsqlite3.m4
 create mode 100644 utils/nfsdcld/Makefile.am
 create mode 100644 utils/nfsdcld/nfsdcld.c
 create mode 100644 utils/nfsdcld/sqlite.c
 create mode 100644 utils/nfsdcld/sqlite.h

