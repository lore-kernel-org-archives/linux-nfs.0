Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:53668 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753774Ab0JZP5s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Oct 2010 11:57:48 -0400
Received: by iwn10 with SMTP id 10so2336058iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 26 Oct 2010 08:57:47 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/6] More fix-ups for nfs-utils-1.2.4
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 26 Oct 2010 11:57:43 -0400
Message-ID: <20101026155216.19184.36979.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Steve-

Here are rather more final versions of the patches I posted here last
week for review.  There are a couple of extra clean-ups here as well.
I think these are ready to be considered for nfs-utils 1.2.4.

---

Chuck Lever (6):
      nfs(5): Document remount behavior
      nfs(5): Grammar and style fixes
      mount.nfs: mnt_freq and mnt_pass are always zero
      mount.nfs: Fix memory leak in nfs_sys_mount()
      mount: Fix compiler warning in nfs_parse_retry_option()
      nfs-utils: Remove all uses of AI_ADDRCONFIG


 support/export/hostname.c     |    6 --
 tests/nsm_client/nsm_client.c |    2 -
 utils/mount/mount.c           |   34 +++++++------
 utils/mount/network.c         |    3 -
 utils/mount/nfs.man           |  107 ++++++++++++++++++++++++++++++++---------
 utils/mount/stropts.c         |   20 ++++----
 utils/statd/hostname.c        |    4 --
 utils/statd/sm-notify.c       |    5 --
 8 files changed, 114 insertions(+), 67 deletions(-)

-- 
Chuck Lever
