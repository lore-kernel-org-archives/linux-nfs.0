Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f170.google.com ([209.85.213.170]:55829 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932163AbaBKThM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Feb 2014 14:37:12 -0500
Received: by mail-ig0-f170.google.com with SMTP id m12so100725iga.1
        for <linux-nfs@vger.kernel.org>; Tue, 11 Feb 2014 11:37:11 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] Allow parallel opens in NFSv4.1
Date: Tue, 11 Feb 2014 14:37:03 -0500
Message-Id: <1392147428-23087-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patch set converts the sequence id locking code to allow
parallel OPEN calls that are serialised with OPEN_DOWNGRADE and CLOSE.

Trond Myklebust (5):
  NFSv4: Don't update the open stateid unless it is newer than the old
    one
  NFSv4: Refactor NFS sequence id counter
  NFSv4: Convert NFS sequence id lock into a shared/exclusive lock
  NFSv4.1: Allow parallel OPEN requests
  NFSv4: Use correct locking when updating nfs4_state in nfs4_close_done

 fs/nfs/nfs4_fs.h   |  32 ++++++++++--
 fs/nfs/nfs4proc.c  |  84 ++++++++++++++++++------------
 fs/nfs/nfs4state.c | 150 +++++++++++++++++++++++++++++++++++++++++------------
 3 files changed, 195 insertions(+), 71 deletions(-)

-- 
1.8.5.3

