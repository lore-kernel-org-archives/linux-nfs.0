Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:36087 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933500AbbGJUdm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 16:33:42 -0400
Received: by ykey15 with SMTP id y15so76063068yke.3
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jul 2015 13:33:41 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, william@gandi.net, bfields@fieldses.org
Subject: [RFC PATCH 0/4] locks/nfs: fix use-after-free problem in unlock codepath
Date: Fri, 10 Jul 2015 16:33:30 -0400
Message-Id: <1436560414-26306-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

William Dauchy reported some instability after trying to apply
db2efec0caba to the v3.14 stable series kernels. The problem was that
that patch had us taking an extra reference to the filp in the NFSv4
unlock code. If we're unlocking locks on task exit though, then we may
be taking a reference after the last reference had already been put.

This fixes the problem in a different way. Most of the locking code is
not terribly concerned with the actual filp, but rather with the inode.
So we can fix this by adding helpers {flock|posix}_inode_lock_wait
helpers and using those from the NFSv4 code. We _know_ that we hold a
reference to the inode by virtue of the NFS open context, so this should
be safe.

I intend to do some more testing of this set over the weekend, but wanted
to get this out there so we can go ahead and get the patch reverted and
get some early feedback.

Jeff Layton (4):
  Revert "nfs: take extra reference to fl->fl_file when running a LOCKU
    operation"
  locks: have flock_lock_file take an inode pointer instead of a filp
  locks: new helpers - flock_lock_inode_wait and posix_lock_inode_wait
  nfs4: have do_vfs_lock take an inode pointer

 fs/locks.c         | 60 ++++++++++++++++++++++++++++++++++++++----------------
 fs/nfs/nfs4proc.c  | 18 ++++++++--------
 include/linux/fs.h | 14 +++++++++++++
 3 files changed, 65 insertions(+), 27 deletions(-)

-- 
2.4.3

