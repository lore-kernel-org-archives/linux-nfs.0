Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:36628 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070AbbAXFjd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jan 2015 00:39:33 -0500
Received: by mail-ig0-f182.google.com with SMTP id r10so1027829igi.3
        for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2015 21:39:32 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] Parallelise OPEN/OPEN_DOWNGRADE/CLOSE in NFSv4.x (x>0)
Date: Sat, 24 Jan 2015 00:39:23 -0500
Message-Id: <1422077968-116473-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

The following patchset improves the tracking of stateids in the CLOSE code
to ensure that we can rely on it in situations where we remove the NFSv4.0
serialisation of state that shares the same open owners.
It then proceeds to add a series of changes to the NFSv4.0 seqid code to
ensure that it can be removed in the case of NFSv4.0 opens.
Only lightly tested so far, but it seems to be working...

In principle there is nothing stopping us from doing the same with byte
range locks; we only need to add better atomicity of stateid updates,
so that we can track the seqid number in the stateid and ensure that it
never regresses. The exercise has been left for the reader...

Cheers
  Trond

Trond Myklebust (5):
  NFSv4: Fix an atomicity problem in CLOSE
  NFSv4: More CLOSE/OPEN races
  NFSv4: Convert nfs_alloc_seqid() to return an ERR_PTR() if allocation
    fails
  NFSv4: Check for NULL argument in nfs_*_seqid() functions
  NFSv4.1: Allow parallel OPEN/OPEN_DOWNGRADE/CLOSE

 fs/nfs/nfs4_fs.h        |  3 +++
 fs/nfs/nfs4proc.c       | 50 ++++++++++++++++++++++++++++++++++++++++---------
 fs/nfs/nfs4state.c      | 31 ++++++++++++++++++------------
 fs/nfs/nfs4xdr.c        |  9 ++++++---
 include/linux/nfs_xdr.h |  2 +-
 5 files changed, 70 insertions(+), 25 deletions(-)

-- 
2.1.0

