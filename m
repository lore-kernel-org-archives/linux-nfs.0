Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33937 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752448AbcGXVbd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jul 2016 17:31:33 -0400
Received: by mail-it0-f68.google.com with SMTP id u186so6481470ita.1
        for <linux-nfs@vger.kernel.org>; Sun, 24 Jul 2016 14:31:33 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 00/14] More layoutreturn nits
Date: Sun, 24 Jul 2016 17:30:45 -0400
Message-Id: <1469395859-83194-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Various non-critical bugfixes and cleanups targeting layoutreturn

v2: Add  CB_LAYOUTRECALL stateid verification fixups
v3: Add more layout stateid update and validity checks
    Fix layout barrier seqid updating
    Reordered for better bisectability
    Further cleanups


Trond Myklebust (14):
  pNFS: LAYOUTRETURN should only update the stateid if the layout is
    valid
  pNFS: Clear the layout return tracking on layout reinitialisation
  pNFS: Always update the layout stateid if NFS_LAYOUT_INVALID_STID is
    set
  pNFS: Always update the layout barrier seqid on LAYOUTGET
  pNFS: Fix CB_LAYOUTRECALL stateid verification
  pNFS: Ensure layoutreturn acts as a completion for layout callbacks
  pNFS: Do not set plh_return_seq for non-callback related layoutreturns
  NFS: pnfs_mark_matching_lsegs_return() should match the layout
    sequence id
  pNFS: Cleanup - don't open code pnfs_mark_layout_stateid_invalid()
  pNFS: Clear the layout metadata if the server changed the layout
    stateid
  pNFS: Remove redundant pnfs_mark_layout_returned_if_empty()
  pNFS: Remove redundant stateid invalidation
  pNFS: Cleanup - do layout segment initialisation in one place
  pNFS: Remove redundant smp_mb() from pnfs_init_lseg()

 fs/nfs/callback_proc.c |  64 ++++++++++++++-------
 fs/nfs/nfs42proc.c     |   3 +-
 fs/nfs/nfs4proc.c      |   6 +-
 fs/nfs/pnfs.c          | 151 +++++++++++++++++++++++++++++--------------------
 fs/nfs/pnfs.h          |  20 +++----
 5 files changed, 143 insertions(+), 101 deletions(-)

-- 
2.7.4

