Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx144.netapp.com ([216.240.21.25]:49226 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753198AbbBCO6n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Feb 2015 09:58:43 -0500
Message-ID: <54D0E220.4080205@Netapp.com>
Date: Tue, 3 Feb 2015 09:58:40 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Tom Haynes <thomas.haynes@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v6 00/53] Add Flexfile Layout Module
References: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tom,

Just a heads up that these patches aren't applying to Trond's [testing] branch.  Git is complaining about merge conflicts and missing sha1 information (and that's only in the first 5 patches so far).

Anna 

On 02/02/2015 05:38 PM, Tom Haynes wrote:
> Hi Trond,
> 
> This patchset introduces the Flexfile Layout Module for the
> client.
> 
> It will correspond to draft 5
> (http://tools.ietf.org/id/draft-ietf-nfsv4-flex-files-05.txt)
> of the Parallel NFS (pNFS) Flexible File Layout
> (https://datatracker.ietf.org/doc/draft-ietf-nfsv4-flex-files/).
> 
> This version has been rebased to v3.19-rc7 and is ready
> for inclusion in 3.20.
> 
> The difference from v5 is that:
> - we fixed 3 nits found by the kbuild test robot
> - we fixed the generic helper functions for .init_read and .init_write
> - we fixed handling multiple layout segments with the blocklayout
> 
> The [flexfiles] branch of
> 
> git://git.linux-nfs.org/projects/loghyr/linux-nfs.git
> 
> also has this code.
> 
> Thanks,
> Tom
> 
> Peng Tao (37):
>   nfs41: pull data server cache from file layout to generic pnfs
>   nfs41: pull decode_ds_addr from file layout to generic pnfs
>   nfs41: pull nfs4_ds_connect from file layout to generic pnfs
>   nfs41: allow LD to choose DS connection auth flavor
>   nfs41: move file layout macros to generic pnfs
>   nfsv3: introduce nfs3_set_ds_client
>   nfs41: allow LD to choose DS connection version/minor_version
>   nfs41: create NFSv3 DS connection if specified
>   nfs: allow different protocol in nfs_initiate_commit
>   nfs4: pass slot table to nfs40_setup_sequence
>   nfs4: export nfs4_sequence_done
>   nfs: allow to specify cred in nfs_initiate_pgio
>   nfs: set hostname when creating nfsv3 ds connection
>   nfs/flexclient: export pnfs_layoutcommit_inode
>   nfs41: close a small race window when adding new layout to global list
>   nfs41: serialize first layoutget of a file
>   nfs: save server READ/WRITE/COMMIT status
>   nfs41: pass iomode through layoutreturn args
>   nfs41: make a helper function to send layoutreturn
>   nfs41: add a helper to mark layout for return
>   nfs41: don't use a layout if it is marked for returning
>   nfs41: send layoutreturn in last put_lseg
>   nfs41: clear NFS_LAYOUT_RETURN if layoutreturn is sent or failed to
>     send
>   nfs/filelayout: use pnfs_error_mark_layout_for_return
>   nfs41: add a debug warning if we destroy an unempty layout
>   nfs: only reset desc->pg_mirror_idx when mirroring is supported
>   nfs: add nfs_pgio_current_mirror helper
>   pnfs: allow LD to ask to resend read through pnfs
>   nfs41: add range to layoutreturn args
>   nfs41: allow async version layoutreturn
>   nfs41: introduce NFS_LAYOUT_RETURN_BEFORE_CLOSE
>   nfs/flexfiles: send layoutreturn before freeing lseg
>   nfs41: add NFS_LAYOUT_RETRY_LAYOUTGET to layout header flags
>   nfs: add a helper to set NFS_ODIRECT_RESCHED_WRITES to direct writes
>   nfs41: wait for LAYOUTRETURN before retrying LAYOUTGET
>   nfs: count DIO good bytes correctly with mirroring
>   nfs41: .init_read and .init_write can be called with valid pg_lseg
> 
> Tom Haynes (5):
>   pnfs: Prepare for flexfiles by pulling out common code
>   pnfs: Do not grab the commit_info lock twice when rescheduling writes
>   pnfs: Add nfs_rpc_ops in calls to nfs_initiate_pgio
>   pnfs/flexfiles: Add the FlexFile Layout Driver
>   pnfs: Update documentation on the Layout Drivers
> 
> Trond Myklebust (1):
>   NFSv4.1/NFSv3: Add pNFS callbacks for nfs3_(read|write|commit)_done()
> 
> Weston Andros Adamson (10):
>   sunrpc: add rpc_count_iostats_idx
>   nfs: introduce pg_cleanup op for pgio descriptors
>   pnfs: release lseg in pnfs_generic_pg_cleanup
>   nfs: handle overlapping reqs in lock_and_join
>   nfs: rename pgio header ds_idx to ds_commit_idx
>   pnfs: pass ds_commit_idx through the commit path
>   nfs: add mirroring support to pgio layer
>   nfs: mirroring support for direct io
>   pnfs: fail comparison when bucket verifier not set
>   pnfs: lookup new lseg at lseg boundary
> 
>  Documentation/filesystems/nfs/pnfs.txt    |   13 +-
>  fs/nfs/Kconfig                            |    5 +
>  fs/nfs/Makefile                           |    3 +-
>  fs/nfs/blocklayout/blocklayout.c          |    2 +
>  fs/nfs/direct.c                           |  112 +-
>  fs/nfs/filelayout/filelayout.c            |  315 +-----
>  fs/nfs/filelayout/filelayout.h            |   40 -
>  fs/nfs/filelayout/filelayoutdev.c         |  469 +--------
>  fs/nfs/flexfilelayout/Makefile            |    5 +
>  fs/nfs/flexfilelayout/flexfilelayout.c    | 1574 +++++++++++++++++++++++++++++
>  fs/nfs/flexfilelayout/flexfilelayout.h    |  155 +++
>  fs/nfs/flexfilelayout/flexfilelayoutdev.c |  552 ++++++++++
>  fs/nfs/idmap.c                            |    3 +-
>  fs/nfs/internal.h                         |   31 +-
>  fs/nfs/nfs2xdr.c                          |   10 +-
>  fs/nfs/nfs3_fs.h                          |    2 +
>  fs/nfs/nfs3client.c                       |   41 +
>  fs/nfs/nfs3proc.c                         |    9 +
>  fs/nfs/nfs3super.c                        |    2 +-
>  fs/nfs/nfs3xdr.c                          |    3 +
>  fs/nfs/nfs4_fs.h                          |    6 +
>  fs/nfs/nfs4client.c                       |    7 +-
>  fs/nfs/nfs4proc.c                         |   48 +-
>  fs/nfs/nfs4super.c                        |    3 +
>  fs/nfs/nfs4xdr.c                          |    9 +-
>  fs/nfs/objlayout/objio_osd.c              |    5 +-
>  fs/nfs/pagelist.c                         |  294 +++++-
>  fs/nfs/pnfs.c                             |  470 +++++++--
>  fs/nfs/pnfs.h                             |  121 ++-
>  fs/nfs/pnfs_nfs.c                         |  840 +++++++++++++++
>  fs/nfs/read.c                             |   33 +-
>  fs/nfs/write.c                            |   52 +-
>  include/linux/nfs4.h                      |    1 +
>  include/linux/nfs_fs_sb.h                 |    9 +-
>  include/linux/nfs_idmap.h                 |    2 +
>  include/linux/nfs_page.h                  |   22 +-
>  include/linux/nfs_xdr.h                   |    6 +-
>  include/linux/sunrpc/metrics.h            |    4 +
>  net/sunrpc/stats.c                        |   26 +-
>  39 files changed, 4263 insertions(+), 1041 deletions(-)
>  create mode 100644 fs/nfs/flexfilelayout/Makefile
>  create mode 100644 fs/nfs/flexfilelayout/flexfilelayout.c
>  create mode 100644 fs/nfs/flexfilelayout/flexfilelayout.h
>  create mode 100644 fs/nfs/flexfilelayout/flexfilelayoutdev.c
>  create mode 100644 fs/nfs/pnfs_nfs.c
> 

