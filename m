Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43396 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754538AbdEZUO5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 26 May 2017 16:14:57 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@poochiereds.net>, bfields@fieldses.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] Fixups for l_pid
Date: Fri, 26 May 2017 16:14:48 -0400
Message-Id: <cover.1495829587.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

LTP fcntl tests (fcntl11 fcntl14 fcntl17 fcntl19 fcntl20 fcntl21) have been
failing for NFSv4 mounts due to an unexpected l_pid.  What follows are some
fixups:

Benjamin Coddington (3):
  fs/locks: Alloc file_lock where practical
  fs/locks: Set fl_nspid at file_lock allocation
  fs/locks: Use fs-specific l_pid for remote locks

 fs/locks.c         | 137 +++++++++++++++++++++++++++++++++--------------------
 include/linux/fs.h |   1 +
 2 files changed, 86 insertions(+), 52 deletions(-)

-- 
2.9.3

