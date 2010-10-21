Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:58190 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754029Ab0JUPDP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Oct 2010 11:03:15 -0400
Received: by gyb13 with SMTP id 13so509532gyb.19
        for <linux-nfs@vger.kernel.org>; Thu, 21 Oct 2010 08:03:14 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] Patches for nfs-utils 1.2.4
To: linux-nfs@vger.kernel.org
Cc: kzak@redhat.com
Date: Thu, 21 Oct 2010 11:03:10 -0400
Message-ID: <20101021145747.2866.11537.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

For review only, here are some potential bug fixes for the next
release of nfs-utils.

I have a potential patch for the remount bug (the second in this
series).  Karel, have a look at this one to see if I've captured
your idea about merging mount options.

Anyone else, please offer comments and thoughts.

---

Chuck Lever (4):
      mount.nfs: Fix memory leak in nfs_sys_mount()
      mount.nfs: Preserve options in /etc/mtab during remount
      mount.nfs: freq and pass are always zero
      nfs-utils: Remove all uses of AI_ADDRCONFIG


 support/export/hostname.c     |    6 ---
 tests/nsm_client/nsm_client.c |    2 -
 utils/mount/mount.c           |   89 ++++++++++++++++++++++++++++++++++++++---
 utils/mount/network.c         |    3 -
 utils/mount/stropts.c         |   13 ++----
 utils/statd/hostname.c        |    4 --
 utils/statd/sm-notify.c       |    5 --
 7 files changed, 90 insertions(+), 32 deletions(-)

-- 
Chuck Lever
