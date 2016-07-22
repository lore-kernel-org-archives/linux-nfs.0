Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:38468 "EHLO
	mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928AbcGVTe3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2016 15:34:29 -0400
Received: by mail-it0-f53.google.com with SMTP id j124so56357678ith.1
        for <linux-nfs@vger.kernel.org>; Fri, 22 Jul 2016 12:34:29 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/6] More layoutreturn nits
Date: Fri, 22 Jul 2016 15:33:52 -0400
Message-Id: <1469216038-71882-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Various non-critical bugfixes and cleanups targeting layoutreturn.

Trond Myklebust (6):
  pNFS: Clear the layout return tracking on layout reinitialisation
  pNFS: Ensure layoutreturn acts as a completion for layout callbacks
  pNFS: Do not set plh_return_seq for non-callback related layoutreturns
  pNFS: Remove redundant stateid invalidation
  NFS: pnfs_mark_matching_lsegs_return() should match the layout
    sequence id
  pNFS: Cleanup - don't open code pnfs_mark_layout_stateid_invalid()

 fs/nfs/nfs42proc.c |   3 +-
 fs/nfs/nfs4proc.c  |   3 +-
 fs/nfs/pnfs.c      | 108 +++++++++++++++++++++++++++++++++--------------------
 fs/nfs/pnfs.h      |   2 +
 4 files changed, 71 insertions(+), 45 deletions(-)

-- 
2.7.4

