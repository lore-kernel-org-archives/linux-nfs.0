Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f46.google.com ([209.85.213.46]:34601 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821Ab2JALwv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2012 07:52:51 -0400
Received: by yhmm54 with SMTP id m54so314425yhm.19
        for <linux-nfs@vger.kernel.org>; Mon, 01 Oct 2012 04:52:50 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/6] nfsdcltrack: create a new usermodehelper upcall program for tracking clients
Date: Mon,  1 Oct 2012 07:52:39 -0400
Message-Id: <1349092365-23920-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a companion patchset to the kernel set posted earlier. It adds a
new callout program for the kernel that handles client ID tracking.

The nfsdcld directory is first renamed to something more generic and then
a new program is added to handle the callout. The storage backend for
the program is identical to the one used by nfsdcld. This program is
really just a new frontend for that.

We could even (in principle) have them use the same db directory, but
for now I've made this program use a separate one.

Comments and suggestions welcome...

Jeff Layton (6):
  nfsdcltrack: rename the nfsdcld directory and options to nfsdcltrack
  nfsdcltrack: remove pointless sqlite_topdir variable
  nfsdcltrack: break out a function to open the database handle
  nfsdcltrack: add a new "one-shot" program for manipulating the client
    tracking db
  nfsdcltrack: add a manpage for nfsdcltrack
  nfsdcltrack: update the README about server startup order

 README                                     |  12 +-
 configure.ac                               |  20 +-
 utils/Makefile.am                          |   4 +-
 utils/{nfsdcld => nfsdcltrack}/Makefile.am |   8 +-
 utils/{nfsdcld => nfsdcltrack}/nfsdcld.c   |   0
 utils/{nfsdcld => nfsdcltrack}/nfsdcld.man |   0
 utils/nfsdcltrack/nfsdcltrack.c            | 435 +++++++++++++++++++++++++++++
 utils/nfsdcltrack/nfsdcltrack.man          | 194 +++++++++++++
 utils/{nfsdcld => nfsdcltrack}/sqlite.c    |  58 ++--
 utils/{nfsdcld => nfsdcltrack}/sqlite.h    |   3 +-
 10 files changed, 693 insertions(+), 41 deletions(-)
 rename utils/{nfsdcld => nfsdcltrack}/Makefile.am (59%)
 rename utils/{nfsdcld => nfsdcltrack}/nfsdcld.c (100%)
 rename utils/{nfsdcld => nfsdcltrack}/nfsdcld.man (100%)
 create mode 100644 utils/nfsdcltrack/nfsdcltrack.c
 create mode 100644 utils/nfsdcltrack/nfsdcltrack.man
 rename utils/{nfsdcld => nfsdcltrack}/sqlite.c (94%)
 rename utils/{nfsdcld => nfsdcltrack}/sqlite.h (92%)

-- 
1.7.11.4

