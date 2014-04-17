Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:19206 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750838AbaDQVJt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Apr 2014 17:09:49 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 00/17] NFS: Create a common path used by reads and writes
Date: Thu, 17 Apr 2014 17:09:24 -0400
Message-ID: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I noticed that much of the read and write code was almost identical, with
only minor differences in argument types and names.  These patches seek to
unify these two codepaths wherever possible in order to make future changes
easier.

Table of contents:
	Patches 01 - 05: Set up common data structures.
	Patches 06 - 10: Set up a shared rpc_call_ops struct.
	Patches 11 - 15: Set up a shared nfs_pageio_ops struct.

Some of the commit setup was moved into common code, but I'm willing to
move this back into write.c if this looks to be a problem.

Future work:
	I have rough pNFS patches that don't currently apply.  They need
	more testing, and I figured this was enough code churn already.

Testing:
	I tested every version of NFS using the cthon and xfs tests without
	hitting anything new.  Any extra testing would be great seeing how
	the read and write paths are vitally important.

Questions?  Comments?  Death threats?

Anna


Anna Schumaker (17):
  NFS: Create a common argument structure for reads and writes
  NFS: Create a common results structure for reads and writes
  NFS: Create a common read and write data struct
  NFS: Create a common read and write header struct
  NFS: Move the write verifier into the nfs_pgio_header
  NFS: Create a common pgio_alloc and pgio_release function
  NFS: Create a common rw_header_alloc and rw_header_free function
  NFS: Create a common pgio_rpc_prepare function
  NFS: Create a common nfs_pgio_result_common function
  NFS: Create a common pgio_common_ops struct
  NFS: Create a common rpcsetup function for reads and writes
  NFS: Create a common pgio_error function
  NFS: Create a generic_pgio function
  NFS: Create a common initiate_pgio() function
  NFS: Create a common multiple_pgios() function
  NFS: Create a common generic_pg_pgios()
  NFS: Create a common nfs_pageio_ops instance

 fs/nfs/Makefile                  |   2 +-
 fs/nfs/blocklayout/blocklayout.c |  22 +-
 fs/nfs/direct.c                  |   4 +-
 fs/nfs/internal.h                |  31 ++-
 fs/nfs/nfs2xdr.c                 |  14 +-
 fs/nfs/nfs3proc.c                |  19 +-
 fs/nfs/nfs3xdr.c                 |  16 +-
 fs/nfs/nfs4_fs.h                 |   4 +-
 fs/nfs/nfs4filelayout.c          |  40 ++--
 fs/nfs/nfs4proc.c                |  52 ++---
 fs/nfs/nfs4trace.h               |   8 +-
 fs/nfs/nfs4xdr.c                 |  19 +-
 fs/nfs/objlayout/objio_osd.c     |   6 +-
 fs/nfs/objlayout/objlayout.c     |  16 +-
 fs/nfs/objlayout/objlayout.h     |   8 +-
 fs/nfs/pageio.c                  | 386 +++++++++++++++++++++++++++++++++++
 fs/nfs/pagelist.c                |   2 +
 fs/nfs/pnfs.c                    |  46 ++---
 fs/nfs/pnfs.h                    |  10 +-
 fs/nfs/proc.c                    |  19 +-
 fs/nfs/read.c                    | 348 +++-----------------------------
 fs/nfs/write.c                   | 425 +++++----------------------------------
 include/linux/nfs_fs.h           |   3 +-
 include/linux/nfs_page.h         |  13 ++
 include/linux/nfs_xdr.h          |  94 +++------
 25 files changed, 661 insertions(+), 946 deletions(-)
 create mode 100644 fs/nfs/pageio.c

-- 
1.9.2

