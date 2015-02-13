Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f180.google.com ([209.85.192.180]:38508 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbbBMVUD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Feb 2015 16:20:03 -0500
Received: by pdbfp1 with SMTP id fp1so17537945pdb.5
        for <linux-nfs@vger.kernel.org>; Fri, 13 Feb 2015 13:20:02 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 0/2] nfs: Clean up the handling of unstable pages
Date: Fri, 13 Feb 2015 13:19:52 -0800
Message-Id: <1423862394-74977-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patches refactor the marking of pages
as unstable and make sure that we use nfs_clear_page_commit()
all places it can be used.

Note that these are applied to Linus' master branch as the
impetus sprung from the mismerge with the bdi changes.

Difference from V1:
- Split patch into logical set of changes

Tom Haynes (2):
  nfs: Provide and use helper functions for marking a page as unstable
  nfs: Can call nfs_clear_page_commit() instead

 fs/nfs/filelayout/filelayout.c         |  9 ++-------
 fs/nfs/flexfilelayout/flexfilelayout.c |  9 ++-------
 fs/nfs/internal.h                      | 13 +++++++++++++
 fs/nfs/write.c                         | 16 ++++------------
 4 files changed, 21 insertions(+), 26 deletions(-)

-- 
1.9.3

