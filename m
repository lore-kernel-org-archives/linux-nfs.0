Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33799 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724AbcEYFJp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2016 01:09:45 -0400
Received: by mail-pa0-f52.google.com with SMTP id qo8so13897554pab.1
        for <linux-nfs@vger.kernel.org>; Tue, 24 May 2016 22:09:45 -0700 (PDT)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Subject: [PATCH 0/4] Super simple flex file server
Date: Tue, 24 May 2016 22:09:35 -0700
Message-Id: <1464152979-103988-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

The following patches make a flex file server in which
the mds and the ds are the same machine. And the same inode
services both metadata and data.

My biggest concern is the selection of layout type
in nfsd4_setup_layout_type(). If CONFIG_NFSD_BLOCKLAYOUT,
CONFIG_NFSD_SCSILAYOUT, and CONFIG_NFSD_FLEXFILELAYOUT
are all selected, then the flex file layout type will win. :-)

These patches are also in my flex_server branch at
git://git.linux-nfs.org/projects/loghyr/linux-nfs.git

Thanks,
Tom

Tom Haynes (4):
  nfsd: flex file device id encoding will need the server addres
  nfsd: Can leak pnfs_block_extent on error
  nfsd: Add a super simple flex file server
  nfsd: Provide a config option for flex file layouts

 fs/nfsd/Kconfig             |  13 ++++
 fs/nfsd/Makefile            |   1 +
 fs/nfsd/blocklayout.c       |   6 +-
 fs/nfsd/flexfilelayout.c    | 148 ++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/flexfilelayoutxdr.c | 116 ++++++++++++++++++++++++++++++++++
 fs/nfsd/flexfilelayoutxdr.h |  50 +++++++++++++++
 fs/nfsd/nfs4layouts.c       |  10 +++
 fs/nfsd/nfs4proc.c          |   1 +
 fs/nfsd/pnfs.h              |   4 ++
 9 files changed, 348 insertions(+), 1 deletion(-)
 create mode 100644 fs/nfsd/flexfilelayout.c
 create mode 100644 fs/nfsd/flexfilelayoutxdr.c
 create mode 100644 fs/nfsd/flexfilelayoutxdr.h

-- 
1.8.3.1

