Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:50152 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776AbaEHOs5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 May 2014 10:48:57 -0400
Received: by mail-ie0-f174.google.com with SMTP id ar20so2691746iec.33
        for <linux-nfs@vger.kernel.org>; Thu, 08 May 2014 07:48:56 -0700 (PDT)
From: Thomas Haynes <thomas.haynes@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Tom Haynes <Thomas.Haynes@primarydata.com>
Subject: [PATCH] Push the file layout driver into a subdirectory
Date: Thu,  8 May 2014 07:48:44 -0700
Message-Id: <1399560525-1913-1-git-send-email-Thomas.Haynes@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Haynes <Thomas.Haynes@primarydata.com>

The object and block layouts already exist in their own
subdirectories. This patch completes the set!

Note that as a layout denotes nfs4 already, I stripped
that prefix out of the file names.

The patch looks longer than it really is, but git
logs are preserved. :-)

Tom Haynes (1):
  Push the file layout driver into a subdirectory

 fs/nfs/Makefile                   |    4 +-
 fs/nfs/filelayout/Kbuild          |    5 +
 fs/nfs/filelayout/filelayout.c    | 1391 +++++++++++++++++++++++++++++++++++++
 fs/nfs/filelayout/filelayout.h    |  156 +++++
 fs/nfs/filelayout/filelayoutdev.c |  843 ++++++++++++++++++++++
 fs/nfs/nfs4filelayout.c           | 1391 -------------------------------------
 fs/nfs/nfs4filelayout.h           |  156 -----
 fs/nfs/nfs4filelayoutdev.c        |  843 ----------------------
 8 files changed, 2396 insertions(+), 2393 deletions(-)
 create mode 100644 fs/nfs/filelayout/Kbuild
 create mode 100644 fs/nfs/filelayout/filelayout.c
 create mode 100644 fs/nfs/filelayout/filelayout.h
 create mode 100644 fs/nfs/filelayout/filelayoutdev.c
 delete mode 100644 fs/nfs/nfs4filelayout.c
 delete mode 100644 fs/nfs/nfs4filelayout.h
 delete mode 100644 fs/nfs/nfs4filelayoutdev.c

-- 
1.9.0

