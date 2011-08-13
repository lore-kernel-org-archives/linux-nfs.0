Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:38732 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719Ab1HPNoR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2011 09:44:17 -0400
Received: by gwaa12 with SMTP id a12so3804781gwa.19
        for <linux-nfs@vger.kernel.org>; Tue, 16 Aug 2011 06:44:16 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: benny@tonian.com
Cc: bharrosh@panasas.com, linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/3] recoalesce when ld read/write fails
Date: Fri, 12 Aug 2011 18:00:10 -0700
Message-Id: <1313197213-1651-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Hi,

I have moved the error handling inside mds_ops->rpc_release to reuse code
as suggested by Boaz.

I think we still need to issue the IO even for write because
we don't know if current writeback is the last one. So if we re-dirty the
pages and this is the last flush (flush at file close), then we don't have
a later flusher to writeback the re-dirtied pages. Boaz, please help see if
current approach is OK. Thanks.

The two cleanup patches (pipe upcall and set_lo_fail) are seperated out of
this patchset so they can be merged more easily.

Thanks,
Tao

Peng Tao (3):
  pNFS: recoalesce when ld write pagelist fails
  pNFS: recoalesce when ld read pagelist fails
  pNFS: introduce pnfs private workqueue

 fs/nfs/blocklayout/blocklayout.c |   17 +++++--
 fs/nfs/objlayout/objio_osd.c     |    8 +++
 fs/nfs/objlayout/objlayout.c     |    4 +-
 fs/nfs/pnfs.c                    |   92 +++++++++++++++++++++++++++-----------
 fs/nfs/pnfs.h                    |    8 +++-
 fs/nfs/read.c                    |   13 +++++-
 fs/nfs/write.c                   |   25 ++++++++++-
 7 files changed, 129 insertions(+), 38 deletions(-)

