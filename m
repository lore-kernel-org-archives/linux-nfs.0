Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:52215 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbbAYARY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jan 2015 19:17:24 -0500
Received: by mail-ie0-f169.google.com with SMTP id rl12so3369649iec.0
        for <linux-nfs@vger.kernel.org>; Sat, 24 Jan 2015 16:17:23 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] Parallelise LOCK/LOCKU in NFSv4.x (x>0)
Date: Sat, 24 Jan 2015 19:17:16 -0500
Message-Id: <1422145041-81669-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a follow up to yesterday's patchset to parallelise OPEN/CLOSE,
and basically extends the parallelism to cover LOCK/LOCKU. There is one
caveat, and that is that we still serialise the _first_ lock on a file.

Please apply on top of the patch series "Parallelise
OPEN/OPEN_DOWNGRADE/CLOSE in NFSv4.x (x>0)"

Trond Myklebust (5):
  NFSv4: Fix atomicity problems with lock stateid updates
  NFSv4: Always do open_to_lock_owner if the lock stateid is
    uninitialised
  NFSv4: Fix lock on-wire reordering issues
  NFSv4: Update of VFS byte range lock must be atomic with the stateid
    update
  NFSv4.1: Allow parallel LOCK/LOCKU calls

 fs/nfs/nfs4proc.c       | 112 +++++++++++++++++++++++++++++++-----------------
 fs/nfs/nfs4xdr.c        |   6 +--
 include/linux/nfs_xdr.h |   7 +--
 3 files changed, 79 insertions(+), 46 deletions(-)

-- 
2.1.0

