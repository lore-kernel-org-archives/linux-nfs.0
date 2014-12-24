Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:45278 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662AbaLXHRG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Dec 2014 02:17:06 -0500
Received: by mail-ie0-f181.google.com with SMTP id rl12so5472912iec.40
        for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2014 23:17:05 -0800 (PST)
Date: Tue, 23 Dec 2014 23:17:03 -0800
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 00/49] *** Add Flexfile Layout Module ***
Message-ID: <20141224071703.GA30902@kitty.kitty>
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 23, 2014 at 11:12:39PM -0800, Tom Haynes wrote:
> Hi,
> 
> This patchset introduces the Flexfile Layout Module for the
> client.
> 
> It corresponds to draft 4
> (http://tools.ietf.org/id/draft-ietf-nfsv4-flex-files-02.txt)

Make that http://tools.ietf.org/id/draft-ietf-nfsv4-flex-files-04.txt !

> of the Parallel NFS (pNFS) Flexible File Layout
> (https://datatracker.ietf.org/doc/draft-ietf-nfsv4-flex-files/).
> 
> This version fixes the following review comments:
> 
> 1) XDR should be for Draft 4 and not Draft 2.
> 2) Can you use get_nfs_version() / put_nfs_version() here rather than
>    exposing nfs_v3 to the entire client?  If this *has* to be
>    global then please put it in nfs3_fs.h.
> 3) Can we consolidate "nfs/flexfiles: send layoutreturn before freeing lseg"
>    and "nfs/flexfiles: defer sending layoutreturn in pnfs_put_lseg"
>    to remove some temporary hard to read code?
> 
> Thanks,
> Tom
> 
> Peng Tao (35):
>   nfs41: pull data server cache from file layout to generic pnfs
>   nfs41: pull nfs4_ds_connect from file layout to generic pnfs
>   nfs41: pull decode_ds_addr from file layout to generic pnfs
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
> 
> Tom Haynes (4):
>   pnfs: Prepare for flexfiles by pulling out common code
>   pnfs: Do not grab the commit_info lock twice when rescheduling writes
>   pnfs: Add nfs_rpc_ops in calls to nfs_initiate_pgio
>   pnfs/flexfiles: Add the FlexFile Layout Driver
> 
> Trond Myklebust (1):
>   NFSv4.1/NFSv3: Add pNFS callbacks for nfs3_(read|write|commit)_done()
> 
> Weston Andros Adamson (9):
>   sunrpc: add rpc_count_iostats_idx
>   nfs: introduce pg_cleanup op for pgio descriptors
>   pnfs: release lseg in pnfs_generic_pg_cleanup
>   nfs: handle overlapping reqs in lock_and_join
>   nfs: rename pgio header ds_idx to ds_commit_idx
>   pnfs: pass ds_commit_idx through the commit path
>   nfs: add mirroring support to pgio layer
>   nfs: mirroring support for direct io
>   pnfs: fail comparison when bucket verifier not set
> 
>  fs/nfs/Kconfig                            |    5 +
>  fs/nfs/Makefile                           |    3 +-
>  fs/nfs/blocklayout/blocklayout.c          |    2 +
>  fs/nfs/direct.c                           |  108 +-
>  fs/nfs/filelayout/filelayout.c            |  315 +-----
>  fs/nfs/filelayout/filelayout.h            |   40 -
>  fs/nfs/filelayout/filelayoutdev.c         |  469 +--------
>  fs/nfs/flexfilelayout/Makefile            |    5 +
>  fs/nfs/flexfilelayout/flexfilelayout.c    | 1600 +++++++++++++++++++++++++++++
>  fs/nfs/flexfilelayout/flexfilelayout.h    |  158 +++
>  fs/nfs/flexfilelayout/flexfilelayoutdev.c |  552 ++++++++++
>  fs/nfs/internal.h                         |   31 +-
>  fs/nfs/nfs3_fs.h                          |    3 +-
>  fs/nfs/nfs3client.c                       |   41 +
>  fs/nfs/nfs3proc.c                         |    9 +
>  fs/nfs/nfs3super.c                        |    2 +-
>  fs/nfs/nfs3xdr.c                          |    3 +
>  fs/nfs/nfs4_fs.h                          |    6 +
>  fs/nfs/nfs4client.c                       |    7 +-
>  fs/nfs/nfs4proc.c                         |   45 +-
>  fs/nfs/nfs4xdr.c                          |    9 +-
>  fs/nfs/objlayout/objio_osd.c              |    5 +-
>  fs/nfs/pagelist.c                         |  294 +++++-
>  fs/nfs/pnfs.c                             |  407 ++++++--
>  fs/nfs/pnfs.h                             |  119 ++-
>  fs/nfs/pnfs_dev.c                         |  522 ++++++++++
>  fs/nfs/pnfs_nfsio.c                       |  283 +++++
>  fs/nfs/read.c                             |   33 +-
>  fs/nfs/write.c                            |   49 +-
>  include/linux/nfs4.h                      |    1 +
>  include/linux/nfs_page.h                  |   22 +-
>  include/linux/nfs_xdr.h                   |    6 +-
>  include/linux/sunrpc/metrics.h            |    2 +
>  net/sunrpc/stats.c                        |   26 +-
>  34 files changed, 4182 insertions(+), 1000 deletions(-)
>  create mode 100644 fs/nfs/flexfilelayout/Makefile
>  create mode 100644 fs/nfs/flexfilelayout/flexfilelayout.c
>  create mode 100644 fs/nfs/flexfilelayout/flexfilelayout.h
>  create mode 100644 fs/nfs/flexfilelayout/flexfilelayoutdev.c
>  create mode 100644 fs/nfs/pnfs_nfsio.c
> 
> -- 
> 1.9.3
> 
