Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qy0-f174.google.com ([209.85.216.174]:46265 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754641Ab2BAPpB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2012 10:45:01 -0500
Received: by qcqw6 with SMTP id w6so740319qcq.19
        for <linux-nfs@vger.kernel.org>; Wed, 01 Feb 2012 07:45:00 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v5 0/9] nfsdcld: add a daemon to track NFSv4 client names on stable storage
Date: Wed,  1 Feb 2012 10:44:47 -0500
Message-Id: <1328111096-28430-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset is the userspace portion of the knfsd client name tracking
overhaul. See this patch series for an explanation:

    nfsd: overhaul the client name tracking code

This version scales back some of the changes in the last set. Since
then, it's become clear that I'm not entirely certain what changes we'll
need in order to handle this in a clustered configuration. Instead of
trying to anticipate those changes, I've decided just to focus on the
single-server case and leave any other changes for later once it becomes
more clear what (if anything) is needed.

The main changes from the last set are:

- the "remove" upcall has been readded

- the "init" upcall has been removed

- the "check" and "update" upcalls no longer return a client index
  to the kernel

- the pipe open and reopen code has been overhauled and consolidated.
  Instead of looping indefinitely when trying to reopen the file, it will
  abort the daemon if the open fails with anything besides ENOENT. If
  the pipe isn't present when the daemon starts, it now uses the inotify
  event callback to handle the opening.

Jeff Layton (9):
  nfsdcld: add client tracking daemon stub
  nfsdcld: add autoconf goop for sqlite
  nfsdcld: add routines for a sqlite backend database
  nfsdcld: add remove functionality
  nfsdcld: add check/update functionality
  nfsdcld: add function to remove unreclaimed client records
  nfsdcld: make it watch for inotify events in the containing directory
  nfsdcld: add a manpage for nfsdcld
  nfsdcld: update the README

 README                    |   25 ++-
 aclocal/libsqlite3.m4     |   33 +++
 configure.ac              |   21 ++
 utils/Makefile.am         |    4 +
 utils/nfsdcld/Makefile.am |   14 ++
 utils/nfsdcld/nfsdcld.c   |  528 +++++++++++++++++++++++++++++++++++++++++++++
 utils/nfsdcld/nfsdcld.man |  180 +++++++++++++++
 utils/nfsdcld/nfsdcld.pod |   67 ++++++
 utils/nfsdcld/sqlite.c    |  390 +++++++++++++++++++++++++++++++++
 utils/nfsdcld/sqlite.h    |   29 +++
 10 files changed, 1289 insertions(+), 2 deletions(-)
 create mode 100644 aclocal/libsqlite3.m4
 create mode 100644 utils/nfsdcld/Makefile.am
 create mode 100644 utils/nfsdcld/nfsdcld.c
 create mode 100644 utils/nfsdcld/nfsdcld.man
 create mode 100644 utils/nfsdcld/nfsdcld.pod
 create mode 100644 utils/nfsdcld/sqlite.c
 create mode 100644 utils/nfsdcld/sqlite.h

-- 
1.7.7.6

