Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:61338 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753625AbaFIPsl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jun 2014 11:48:41 -0400
Received: by mail-ie0-f182.google.com with SMTP id rp18so1279359iec.27
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jun 2014 08:48:40 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH v3 0/7] more pgio cleanup
Date: Mon,  9 Jun 2014 11:48:32 -0400
Message-Id: <1402328919-5065-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset is more cleanup related to the recent pgio changes.

These patches are on top of trond's testing branch and can be found in my
"pgio_plus" branch at:

git://git.linux-nfs.org/projects/dros/linux-nfs

Most of these patches are dealing with the merge of nfs_pgio_data into
nfs_pgio_header. My recent patchset "[PATCH v3 00/18] nfs: support
multiple requests per page" changes the pgio layer so that an
nfs_pgio_header only ever has one nfs_pgio_data, which allows us to
simplify a lot of things.

Updates in v3:
  - rebased to trond/testing
  - moved nfs_generic_pgio_reset back to nfs_pgio_data_destroy in
    "nfs: remove pgio_header refcount, related cleanup"
  - added "nfs: remove unneeded EXPORTs"
  - applied "Reviewed-by" to reviewed patches


Weston Andros Adamson (7):
  nfs: move nfs_pgio_data and remove nfs_rw_header
  nfs: rename members of nfs_pgio_data
  nfs: merge nfs_pgio_data into _header
  nfs: remove unused writeverf code
  nfs: remove pgio_header refcount, related cleanup
  pnfs: clean up *_resend_to_mds
  nfs: remove unneeded EXPORTs

 fs/nfs/blocklayout/blocklayout.c |  99 ++++++++--------
 fs/nfs/direct.c                  |  33 ++----
 fs/nfs/filelayout/filelayout.c   | 180 +++++++++++++---------------
 fs/nfs/internal.h                |  11 +-
 fs/nfs/nfs3proc.c                |  21 ++--
 fs/nfs/nfs4_fs.h                 |   6 +-
 fs/nfs/nfs4proc.c                | 105 +++++++++--------
 fs/nfs/nfs4trace.h               |  28 ++---
 fs/nfs/objlayout/objio_osd.c     |  24 ++--
 fs/nfs/objlayout/objlayout.c     |  81 ++++++-------
 fs/nfs/objlayout/objlayout.h     |   8 +-
 fs/nfs/pagelist.c                | 248 ++++++++++++++++++---------------------
 fs/nfs/pnfs.c                    | 161 +++++++------------------
 fs/nfs/pnfs.h                    |  18 ++-
 fs/nfs/proc.c                    |  27 +++--
 fs/nfs/read.c                    |  48 ++++----
 fs/nfs/write.c                   |  80 ++++++-------
 include/linux/nfs_page.h         |  15 ++-
 include/linux/nfs_xdr.h          |  33 ++----
 19 files changed, 544 insertions(+), 682 deletions(-)

-- 
1.8.5.2 (Apple Git-48)

