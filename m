Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35167 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679AbcEZRFV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2016 13:05:21 -0400
Received: by mail-pf0-f171.google.com with SMTP id g64so32867003pfb.2
        for <linux-nfs@vger.kernel.org>; Thu, 26 May 2016 10:05:20 -0700 (PDT)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Subject: [V3 0/2] Super simple flex file server
Date: Thu, 26 May 2016 10:05:09 -0700
Message-Id: <1464282311-103795-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

The following patches make a flex file server in which
the mds and the ds are the same machine. And the same inode
services both metadata and data.

v3:
- Extra word help for selecting NFSD_FLEXFILELAYOUT
- Do not allow WRITE permissions on an IOMODE_READ segment

v2:
- Remove patch 2: nfsd: Can leak pnfs_block_extent on error
- Consolidate 3rd and 4th patch
- Fix the rsize and wsize to come out of the rqstp as per Jeff's
  review comments
- Sort the available layout types such that scsi beats block which
  beats flex file
- Address the points brought up by Christoph in his review

These patches are also in my flex_server branch at
git://git.linux-nfs.org/projects/loghyr/linux-nfs.git

Thanks,
Tom

Tom Haynes (2):
  nfsd: flex file device id encoding will need the server address
  nfsd: Add a super simple flex file server

 fs/nfsd/Kconfig             |  17 ++++++
 fs/nfsd/Makefile            |   1 +
 fs/nfsd/blocklayout.c       |   2 +
 fs/nfsd/flexfilelayout.c    | 133 ++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/flexfilelayoutxdr.c | 115 ++++++++++++++++++++++++++++++++++++++
 fs/nfsd/flexfilelayoutxdr.h |  49 ++++++++++++++++
 fs/nfsd/nfs4layouts.c       |  12 +++-
 fs/nfsd/nfs4proc.c          |   2 +-
 fs/nfsd/pnfs.h              |   4 ++
 9 files changed, 333 insertions(+), 2 deletions(-)
 create mode 100644 fs/nfsd/flexfilelayout.c
 create mode 100644 fs/nfsd/flexfilelayoutxdr.c
 create mode 100644 fs/nfsd/flexfilelayoutxdr.h

-- 
1.8.3.1

