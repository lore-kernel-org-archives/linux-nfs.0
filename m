Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:32833 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753551AbcEYObo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2016 10:31:44 -0400
Received: by mail-pf0-f171.google.com with SMTP id b124so19147784pfb.0
        for <linux-nfs@vger.kernel.org>; Wed, 25 May 2016 07:31:43 -0700 (PDT)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: [V2 0/3] FF_FLAGS_NO_READ_IO
Date: Wed, 25 May 2016 07:31:11 -0700
Message-Id: <1464186674-104401-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna,

These are patched against your linux-next branch.

They are available as my linux-next branch at
git://git.linux-nfs.org/projects/loghyr/linux-nfs.git

Tom Haynes (3):
  nfs/flexfiles: Helper function to detect FF_FLAGS_NO_READ_IO
  nfs/flexfiles: Use the layout segment for reading unless it a
    IOMODE_RW and reading is disabled
  pnfs: pnfs_update_layout needs to consider if strict iomode checking
    is on

 fs/nfs/filelayout/filelayout.c            |  2 ++
 fs/nfs/flexfilelayout/flexfilelayout.c    | 50 +++++++++++++++++++++++--------
 fs/nfs/flexfilelayout/flexfilelayout.h    | 11 ++++++-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  6 ++++
 fs/nfs/pnfs.c                             | 34 +++++++++++++--------
 fs/nfs/pnfs.h                             |  1 +
 6 files changed, 78 insertions(+), 26 deletions(-)

-- 
1.8.3.1

