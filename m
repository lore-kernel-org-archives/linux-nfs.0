Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f180.google.com ([209.85.192.180]:35890 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbbANQpG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jan 2015 11:45:06 -0500
Received: by mail-pd0-f180.google.com with SMTP id fl12so10696029pdb.11
        for <linux-nfs@vger.kernel.org>; Wed, 14 Jan 2015 08:45:05 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 00/50] Add Flexfile Layout Module
Date: Wed, 14 Jan 2015 08:44:06 -0800
Message-Id: <1421253896-73106-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

This patchset introduces the Flexfile Layout Module for the
client.

It corresponds to draft 4
(http://tools.ietf.org/id/draft-ietf-nfsv4-flex-files-04.txt)
of the Parallel NFS (pNFS) Flexible File Layout
(https://datatracker.ietf.org/doc/draft-ietf-nfsv4-flex-files/).

These changes from v3 are based off of additional review comments
from Christoph and Anna. And I updated the Documentation for
the Layout Types.

The [flexfiles] branch of 

git://git.linux-nfs.org/projects/loghyr/linux-nfs.git

also has this code.

Thanks,
Tom


Peng Tao (35):
  nfs41: pull data server cache from file layout to generic pnfs
  nfs41: pull decode_ds_addr from file layout to generic pnfs
  nfs41: pull nfs4_ds_connect from file layout to generic pnfs
  nfs41: allow LD to choose DS connection auth flavor
  nfs41: move file layout macros to generic pnfs
  nfsv3: introduce nfs3_set_ds_client
  nfs41: allow LD to choose DS connection version/minor_version
  nfs41: create NFSv3 DS connection if specified
  nfs: allow different protocol in nfs_initiate_commit
  nfs4: pass slot table to nfs40_setup_sequence
  nfs4: export nfs4_sequence_done
  nfs: allow to specify cred in nfs_initiate_pgio
  nfs: set hostname when creating nfsv3 ds connection
  nfs/flexclient: export pnfs_layoutcommit_inode
  nfs41: close a small race window when adding new layout to global list
  nfs41: serialize first layoutget of a file
  nfs: save server READ/WRITE/COMMIT status
  nfs41: pass iomode through layoutreturn args
  nfs41: make a helper function to send layoutreturn
  nfs41: add a helper to mark layout for return
  nfs41: don't use a layout if it is marked for returning
  nfs41: send layoutreturn in last put_lseg
  nfs41: clear NFS_LAYOUT_RETURN if layoutreturn is sent or failed to
    send
  nfs/filelayout: use pnfs_error_mark_layout_for_return
  nfs41: add a debug warning if we destroy an unempty layout
  nfs: only reset desc->pg_mirror_idx when mirroring is supported
  nfs: add nfs_pgio_current_mirror helper
  pnfs: allow LD to ask to resend read through pnfs
  nfs41: add range to layoutreturn args
  nfs41: allow async version layoutreturn
  nfs41: introduce NFS_LAYOUT_RETURN_BEFORE_CLOSE
  nfs/flexfiles: send layoutreturn before freeing lseg
  nfs41: add NFS_LAYOUT_RETRY_LAYOUTGET to layout header flags
  nfs: add a helper to set NFS_ODIRECT_RESCHED_WRITES to direct writes
  nfs41: wait for LAYOUTRETURN before retrying LAYOUTGET

Tom Haynes (5):
  pnfs: Prepare for flexfiles by pulling out common code
  pnfs: Do not grab the commit_info lock twice when rescheduling writes
  pnfs: Add nfs_rpc_ops in calls to nfs_initiate_pgio
  pnfs/flexfiles: Add the FlexFile Layout Driver
  pnfs: Update documentation on the Layout Drivers

Trond Myklebust (1):
  NFSv4.1/NFSv3: Add pNFS callbacks for nfs3_(read|write|commit)_done()

Weston Andros Adamson (9):
  sunrpc: add rpc_count_iostats_idx
  nfs: introduce pg_cleanup op for pgio descriptors
  pnfs: release lseg in pnfs_generic_pg_cleanup
  nfs: handle overlapping reqs in lock_and_join
  nfs: rename pgio header ds_idx to ds_commit_idx
  pnfs: pass ds_commit_idx through the commit path
  nfs: add mirroring support to pgio layer
  nfs: mirroring support for direct io
  pnfs: fail comparison when bucket verifier not set

 Documentation/filesystems/nfs/pnfs.txt    |   13 +-
 fs/nfs/Kconfig                            |    5 +
 fs/nfs/Makefile                           |    3 +-
 fs/nfs/blocklayout/blocklayout.c          |    2 +
 fs/nfs/direct.c                           |  108 +-
 fs/nfs/filelayout/filelayout.c            |  315 +-----
 fs/nfs/filelayout/filelayout.h            |   40 -
 fs/nfs/filelayout/filelayoutdev.c         |  469 +--------
 fs/nfs/flexfilelayout/Makefile            |    5 +
 fs/nfs/flexfilelayout/flexfilelayout.c    | 1603 +++++++++++++++++++++++++++++
 fs/nfs/flexfilelayout/flexfilelayout.h    |  158 +++
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  552 ++++++++++
 fs/nfs/internal.h                         |   31 +-
 fs/nfs/nfs2xdr.c                          |   10 +-
 fs/nfs/nfs3_fs.h                          |    2 +
 fs/nfs/nfs3client.c                       |   41 +
 fs/nfs/nfs3proc.c                         |    9 +
 fs/nfs/nfs3super.c                        |    2 +-
 fs/nfs/nfs3xdr.c                          |    3 +
 fs/nfs/nfs4_fs.h                          |    6 +
 fs/nfs/nfs4client.c                       |    7 +-
 fs/nfs/nfs4proc.c                         |   48 +-
 fs/nfs/nfs4xdr.c                          |    9 +-
 fs/nfs/objlayout/objio_osd.c              |    5 +-
 fs/nfs/pagelist.c                         |  294 +++++-
 fs/nfs/pnfs.c                             |  419 ++++++--
 fs/nfs/pnfs.h                             |  120 ++-
 fs/nfs/pnfs_nfs.c                         |  808 +++++++++++++++
 fs/nfs/read.c                             |   33 +-
 fs/nfs/write.c                            |   52 +-
 include/linux/nfs4.h                      |    1 +
 include/linux/nfs_fs_sb.h                 |    9 +-
 include/linux/nfs_page.h                  |   22 +-
 include/linux/nfs_xdr.h                   |    6 +-
 include/linux/sunrpc/metrics.h            |    2 +
 net/sunrpc/stats.c                        |   26 +-
 36 files changed, 4221 insertions(+), 1017 deletions(-)
 create mode 100644 fs/nfs/flexfilelayout/Makefile
 create mode 100644 fs/nfs/flexfilelayout/flexfilelayout.c
 create mode 100644 fs/nfs/flexfilelayout/flexfilelayout.h
 create mode 100644 fs/nfs/flexfilelayout/flexfilelayoutdev.c
 create mode 100644 fs/nfs/pnfs_nfs.c

-- 
1.9.3

