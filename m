Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:36459 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400Ab0IMRRa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 13:17:30 -0400
Received: by gxk23 with SMTP id 23so2100375gxk.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Sep 2010 10:17:29 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Two more fixes for mount.nfs
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 13 Sep 2010 13:17:25 -0400
Message-ID: <20100913171100.18926.77712.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here are a couple of bug fixes for mount.nfs.

The second patch in this series makes remount work again, but there is
a lingering problem with it (and maybe some other corner cases, not
related to "remount"). 

It turns out that "remount" mounts (even legacy remount, AFAICT) have
always completely wiped the mount options in /etc/mtab, and replaced
them with "remount,foo".  This breaks umount.nfs, which relies on
the contents of /etc/mtab to know how to perform the unmount request.

I'm working on a solution, but it will still be some time.  I felt
that the remount fix here was important enough to send now.

---

Chuck Lever (2):
      mount.nfs: Don't do anything fancy if this is a remount
      mount.nfs: Refactor mount version and protocol autonegotiation


 utils/mount/stropts.c |   95 ++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 81 insertions(+), 14 deletions(-)

-- 
Chuck Lever
