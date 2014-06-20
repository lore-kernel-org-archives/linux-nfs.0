Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:34010 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755024AbaFTRl1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jun 2014 13:41:27 -0400
Received: by mail-ie0-f173.google.com with SMTP id y20so3564232ier.18
        for <linux-nfs@vger.kernel.org>; Fri, 20 Jun 2014 10:41:26 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Scott Mayhew <smayhew@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/3] nfs: ensure cached data is correct before using delegation
Date: Fri, 20 Jun 2014 13:41:20 -0400
Message-Id: <1403286083-14345-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <20140620125140.GH4510@tonberry.usersys.redhat.com>
References: <20140620125140.GH4510@tonberry.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Scott,

How about the following 2 extra patches on top of yours? Do they help
with the performance regression?

Cheers
  Trond

Scott Mayhew (1):
  nfs: Fix cache_validity check in nfs_write_pageuptodate()

Trond Myklebust (2):
  NFS: Clear NFS_INO_REVAL_PAGECACHE when we update the file size
  NFS: Don't mark the data cache as invalid if it has been flushed

 fs/nfs/inode.c | 76 +++++++++++++++++++++++++++++++---------------------------
 fs/nfs/write.c |  4 +++-
 2 files changed, 44 insertions(+), 36 deletions(-)

-- 
1.9.3

