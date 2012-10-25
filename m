Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:60763 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757202Ab2JYRVv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2012 13:21:51 -0400
Received: by mail-vc0-f174.google.com with SMTP id fk26so2132362vcb.19
        for <linux-nfs@vger.kernel.org>; Thu, 25 Oct 2012 10:21:50 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/9] nfsdcltrack: create a new usermodehelper upcall program for tracking clients
Date: Thu, 25 Oct 2012 13:21:34 -0400
Message-Id: <1351185703-14191-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a respin of the set that I sent yesterday. The main differences
are fairly minor...

- the program no longer strdup()s the basename of the binary

- the autoconf option is still built by default, but if the requirements
  aren't met, configure will error out. Steve felt this was better than
  disabling it and moving on.

Everything else is pretty much the same. If it's easier, these patches
are also in the "nfsdcltrack" branch of my git tree here:

    git://git.linux-nfs.org/projects/jlayton/nfs-utils.git

Thanks for the review so far!

Jeff Layton (9):
  nfsdcltrack: fix segfault in sqlite debug logging
  nfsdcltrack: rename the nfsdcld directory and options to nfsdcltrack
  nfsdcltrack: remove pointless sqlite_topdir variable
  nfsdcltrack: break out a function to open the database handle
  nfsdcltrack: add a new "one-shot" program for manipulating the client
    tracking db
  nfsdcltrack: add a legacy transition mechanism
  nfsdcltrack: add a manpage for nfsdcltrack
  nfsdcltrack: remove the nfsdcld daemon
  nfsdcltrack: update the README about server startup order

 README                            |  23 +-
 configure.ac                      |  20 +-
 utils/Makefile.am                 |   4 +-
 utils/nfsdcld/Makefile.am         |  14 -
 utils/nfsdcld/nfsdcld.c           | 607 --------------------------------------
 utils/nfsdcld/nfsdcld.man         | 185 ------------
 utils/nfsdcld/sqlite.c            | 386 ------------------------
 utils/nfsdcld/sqlite.h            |  29 --
 utils/nfsdcltrack/Makefile.am     |  13 +
 utils/nfsdcltrack/nfsdcltrack.c   | 521 ++++++++++++++++++++++++++++++++
 utils/nfsdcltrack/nfsdcltrack.man | 211 +++++++++++++
 utils/nfsdcltrack/sqlite.c        | 400 +++++++++++++++++++++++++
 utils/nfsdcltrack/sqlite.h        |  30 ++
 13 files changed, 1189 insertions(+), 1254 deletions(-)
 delete mode 100644 utils/nfsdcld/Makefile.am
 delete mode 100644 utils/nfsdcld/nfsdcld.c
 delete mode 100644 utils/nfsdcld/nfsdcld.man
 delete mode 100644 utils/nfsdcld/sqlite.c
 delete mode 100644 utils/nfsdcld/sqlite.h
 create mode 100644 utils/nfsdcltrack/Makefile.am
 create mode 100644 utils/nfsdcltrack/nfsdcltrack.c
 create mode 100644 utils/nfsdcltrack/nfsdcltrack.man
 create mode 100644 utils/nfsdcltrack/sqlite.c
 create mode 100644 utils/nfsdcltrack/sqlite.h

-- 
1.7.11.7

