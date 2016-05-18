Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35960 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbcERVIF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 May 2016 17:08:05 -0400
Received: by mail-pf0-f170.google.com with SMTP id c189so22853868pfb.3
        for <linux-nfs@vger.kernel.org>; Wed, 18 May 2016 14:08:04 -0700 (PDT)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: [PATCH 0/3] FF_FLAGS_NO_READ_IO
Date: Wed, 18 May 2016 14:07:53 -0700
Message-Id: <1463605676-82483-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FF_FLAGS_NO_READ_IO is a hint the mds can use to inform the
client that an IOMODE_RW layout segment should not be used
for READ traffic and that the client should instead request
an IOMODE_READ layout segment. This can be used to isolate
only WRITE traffic onto the IOMODE_RW layout segment.

Tom Haynes (3):
  nfs/flexfiles: Helper function to detect FF_FLAGS_NO_READ_IO
  nfs/flexfiles: Use the layout segment for reading unless it a
    IOMODE_RW and reading is disabled
  pnfs: pnfs_update_layout needs to consider if strict iomode checking
    is on

 fs/nfs/filelayout/filelayout.c            |  2 ++
 fs/nfs/flexfilelayout/flexfilelayout.c    | 50 +++++++++++++++++++++++--------
 fs/nfs/flexfilelayout/flexfilelayout.h    | 10 ++++++-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  6 ++++
 fs/nfs/pnfs.c                             | 34 +++++++++++++--------
 fs/nfs/pnfs.h                             |  1 +
 6 files changed, 77 insertions(+), 26 deletions(-)

-- 
1.8.3.1

