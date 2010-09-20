Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:50620 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855Ab0ITPjl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 11:39:41 -0400
Received: by gyd8 with SMTP id 8so1335929gyd.19
        for <linux-nfs@vger.kernel.org>; Mon, 20 Sep 2010 08:39:40 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Two minor nfs-utils bug fixes
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 20 Sep 2010 11:39:36 -0400
Message-ID: <20100920153714.2604.50581.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Steve-

A couple of minor clean up patches.  I'm still working on the
"remount" issue.

---

Chuck Lever (2):
      nfs-utils: Fix source code character encoding
      libnfs.a: Remove support/nfs/fstab.c


 support/include/conffile.h |    2 
 support/nfs/conffile.c     |    2 
 support/nfs/fstab.c        |  554 --------------------------------------------
 support/nfs/nfs_mntent.c   |    2 
 support/nfs/xcommon.c      |    2 
 utils/mount/fstab.c        |    2 
 utils/mount/nfsmount.c     |    2 
 7 files changed, 6 insertions(+), 560 deletions(-)
 delete mode 100644 support/nfs/fstab.c

-- 
Chuck Lever
