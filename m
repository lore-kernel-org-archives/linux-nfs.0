Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:33200 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751453AbcGXPIH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jul 2016 11:08:07 -0400
Received: by mail-io0-f179.google.com with SMTP id 38so142686972iol.0
        for <linux-nfs@vger.kernel.org>; Sun, 24 Jul 2016 08:08:06 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/7] More layoutreturn nits
Date: Sun, 24 Jul 2016 11:07:30 -0400
Message-Id: <1469372857-29670-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Various non-critical bugfixes and cleanups targeting layoutreturn

v2: Add  CB_LAYOUTRECALL stateid verification fixups

Trond Myklebust (7):
  pNFS: Clear the layout return tracking on layout reinitialisation
  pNFS: Ensure layoutreturn acts as a completion for layout callbacks
  pNFS: Do not set plh_return_seq for non-callback related layoutreturns
  pNFS: Remove redundant stateid invalidation
  NFS: pnfs_mark_matching_lsegs_return() should match the layout
    sequence id
  pNFS: Cleanup - don't open code pnfs_mark_layout_stateid_invalid()
  pNFS: Fix CB_LAYOUTRECALL stateid verification

 fs/nfs/callback_proc.c |  63 ++++++++++++++++++++---------
 fs/nfs/nfs42proc.c     |   3 +-
 fs/nfs/nfs4proc.c      |   3 +-
 fs/nfs/pnfs.c          | 108 ++++++++++++++++++++++++++++++-------------------
 fs/nfs/pnfs.h          |   2 +
 5 files changed, 115 insertions(+), 64 deletions(-)

-- 
2.7.4

