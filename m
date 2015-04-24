Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:32998 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934204AbbDXA1s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2015 20:27:48 -0400
Received: by wgin8 with SMTP id n8so34784698wgi.0
        for <linux-nfs@vger.kernel.org>; Thu, 23 Apr 2015 17:27:46 -0700 (PDT)
From: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>
To: libtirpc-devel@lists.sourceforge.net
Cc: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>,
        Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/7] Rebase, resend.
Date: Fri, 24 Apr 2015 02:27:35 +0200
Message-Id: <1429835262-16861-1-git-send-email-rep.dot.nop@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Seems i forgot the config.h stuff last time, sorry for that..

Bernhard Reutner-Fischer (7):
  delete src/config.h
  getrpcent: Fix compilation on glibc
  Make sure to include config.h
  configure.ac: Allow for disabling NIS
  configure.ac: Allow for disabling auth DES
  getrpcport: rephrase host lookup
  headers: if 0 out some unbuilt functions

 Makefile.am          |  12 ++++--
 configure.ac         |  24 ++++++++++-
 libtirpc.pc.in       |   2 +-
 src/Makefile.am      |  10 +++--
 src/auth_des.c       |  15 +++++++
 src/auth_time.c      |   6 ++-
 src/config.h         | 110 ---------------------------------------------------
 src/getrpcent.c      |  16 ++++----
 src/getrpcport.c     |  37 +++++++++++------
 src/rpc_soc.c        |   2 +-
 tirpc/rpc/auth.h     |  18 ++++++++-
 tirpc/rpc/auth_des.h |   2 +
 tirpc/rpc/rpc.h      |   2 +
 13 files changed, 113 insertions(+), 143 deletions(-)
 delete mode 100644 src/config.h

-- 
2.1.4

