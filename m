Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:47096 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933729Ab2JXP0G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2012 11:26:06 -0400
Received: by mail-vb0-f46.google.com with SMTP id ff1so663936vbb.19
        for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 08:26:05 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 00/10] nfsdcltrack: create a new usermodehelper upcall program for tracking clients
Date: Wed, 24 Oct 2012 11:25:49 -0400
Message-Id: <1351092359-25842-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a respin of the set that I sent on Oct 1st. The main differences
from that set are:

- a new legacy transition mechanism has been added and the manpage has
  been updated to document it

- the nfsdcld daemon is being removed wholesale. Steve D. requested that
  we just go ahead and pull the plug on it, and I didn't see any reason
  to object

- the default is now to build nfsdcltrack if all of the dependencies
  for it are in place

It's a fairly simple program and I've tested it as best I can. At this
point, I'd like to see this patchset go into the next nfs-utils release.

Jeff Layton (10):
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
  nfsdcltrack: flip the default in autoconf to "yes" for it

 README                            |  23 +-
 configure.ac                      |  34 ++-
 utils/Makefile.am                 |   4 +-
 utils/nfsdcld/Makefile.am         |  14 -
 utils/nfsdcld/nfsdcld.c           | 607 --------------------------------------
 utils/nfsdcld/nfsdcld.man         | 185 ------------
 utils/nfsdcld/sqlite.c            | 386 ------------------------
 utils/nfsdcld/sqlite.h            |  29 --
 utils/nfsdcltrack/Makefile.am     |  13 +
 utils/nfsdcltrack/nfsdcltrack.c   | 526 +++++++++++++++++++++++++++++++++
 utils/nfsdcltrack/nfsdcltrack.man | 211 +++++++++++++
 utils/nfsdcltrack/sqlite.c        | 400 +++++++++++++++++++++++++
 utils/nfsdcltrack/sqlite.h        |  30 ++
 13 files changed, 1206 insertions(+), 1256 deletions(-)
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

