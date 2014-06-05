Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:60090 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbaFETQf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 15:16:35 -0400
Received: by mail-ie0-f182.google.com with SMTP id x19so1341676ier.13
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2014 12:16:35 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH v2 0/6] more pgio cleanup
Date: Thu,  5 Jun 2014 15:16:25 -0400
Message-Id: <1401995791-40213-1-git-send-email-dros@primarydata.com>
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

Updates in v2:
  - dropped "pnfs: merge identical functions" as Anna Schumaker is working on
    similar cleanups
  - dropped "nfs: clean up function decls in nfs_page.h" as it changed decls
    from the preferred style (thanks Jim Rees).
  - fix "pnfs: clean up *_resend_to_mds" - return nfs_pageio_resend in
     pnfs_read_done_resend_to_mds (thanks Anna Schumaker)

I haven't had time to rename struct nfs_page (as Christoph Hellwig
requested), but I plan on getting to it soon. Now that I mention it,
what should I rename it to?

Trond doesn't like the idea of renaming to nfs_request (or nfs_req) - that's
what they are called everywhere, but it can be confused with other request
structures. These structures describe a region of a page, so maybe something
like 'struct nfs_region'? Not sure I like that name...

I'll be testing all these pgio changes at the bakeathon. I was hoping to at
least get this patchset into the bakeathon branch so others can run it too.


Thanks,
 -dros

Weston Andros Adamson (6):
  nfs: move nfs_pgio_data and remove nfs_rw_header
  nfs: rename members of nfs_pgio_data
  nfs: merge nfs_pgio_data into _header
  nfs: remove unused writeverf code
  nfs: remove pgio_header refcount, related cleanup
  pnfs: clean up *_resend_to_mds

 fs/nfs/blocklayout/blocklayout.c |  99 ++++++++-------
 fs/nfs/direct.c                  |  33 ++---
 fs/nfs/filelayout/filelayout.c   | 179 +++++++++++++--------------
 fs/nfs/internal.h                |  11 +-
 fs/nfs/nfs3proc.c                |  21 ++--
 fs/nfs/nfs4_fs.h                 |   6 +-
 fs/nfs/nfs4proc.c                | 105 ++++++++--------
 fs/nfs/nfs4trace.h               |  28 ++---
 fs/nfs/objlayout/objio_osd.c     |  24 ++--
 fs/nfs/objlayout/objlayout.c     |  81 ++++++------
 fs/nfs/objlayout/objlayout.h     |   8 +-
 fs/nfs/pagelist.c                | 257 ++++++++++++++++++---------------------
 fs/nfs/pnfs.c                    | 161 +++++++-----------------
 fs/nfs/pnfs.h                    |  18 ++-
 fs/nfs/proc.c                    |  27 ++--
 fs/nfs/read.c                    |  48 ++++----
 fs/nfs/write.c                   |  80 +++++-------
 include/linux/nfs_page.h         |  15 ++-
 include/linux/nfs_xdr.h          |  33 ++---
 19 files changed, 550 insertions(+), 684 deletions(-)

-- 
1.8.5.2 (Apple Git-48)

