Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f170.google.com ([209.85.192.170]:62329 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbaLPUsi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 15:48:38 -0500
Received: by mail-pd0-f170.google.com with SMTP id v10so14652452pde.1
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 12:48:38 -0800 (PST)
Date: Tue, 16 Dec 2014 12:48:35 -0800
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 00/50] *** Add Flexfile Layout Module ***
Message-ID: <20141216204835.GB95519@kitty>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
 <549089C9.2000006@Netapp.com>
 <20141216203303.GB95356@kitty>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20141216203303.GB95356@kitty>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 16, 2014 at 12:33:03PM -0800, Tom Haynes wrote:
> On Tue, Dec 16, 2014 at 02:36:41PM -0500, Anna Schumaker wrote:
> > On 12/16/2014 02:01 PM, Tom Haynes wrote:
> > > Hi,
> > > 
> > > This patchset introduces the Flexfile Layout Module for the
> > > client.
> > > 
> > > It corresponds to draft 2
> > > (http://tools.ietf.org/id/draft-ietf-nfsv4-flex-files-02.txt)
> > > of the Parallel NFS (pNFS) Flexible File Layout
> > > (https://datatracker.ietf.org/doc/draft-ietf-nfsv4-flex-files/).
> > > 
> > > There are some XDR changes that occur by draft 4, but as there
> > > will be changes for draft 5, I decided to go with the slightly
> > > older version of the draft.
> > > 
> > > I'm _not_ looking at this for the 3.19 merge window, but rather
> > > the 3.20.
> > 
> > How big are the upcoming xdr changes?  Would it make sense to give the draft more time to stabilize before merging in code to prevent compatibility issues?
> 
> They are not that big and this current set of XDR has been in there for over 2 months.
> 
> Bringing the current code up to draft version 4 would take a day. And I’d have to
> spend the same amount of time on the server code to do testing.

Okay, I lied, it will not take that long. Since we do not yet implement
the LAYOUTSTATS and that is the piece of code which is changing the
most in the XDR, I can make, test, and push the XDR changes to get
us up to draft 4 in this patch set.

> 
> The changes from version 4 to version 5 will be localized to the ff_layoutupdate4
> structure (note that draft 4 has this as layoutupdate4).

And just to tie off the loop here, these changes are in the stats
and not yet implemented.

> 
> 
> > 
> > Anna
> > 
> > > 
> > > Enjoy,
> > > Tom
> > > 
> > > Peng Tao (36):
> > >   nfs41: pull data server cache from file layout to generic pnfs
> > >   nfs41: pull nfs4_ds_connect from file layout to generic pnfs
> > >   nfs41: pull decode_ds_addr from file layout to generic pnfs
> > >   nfs41: allow LD to choose DS connection auth flavor
> > >   nfs41: move file layout macros to generic pnfs
> > >   nfsv3: introduce nfs3_set_ds_client
> > >   nfs41: allow LD to choose DS connection version/minor_version
> > >   nfs41: create NFSv3 DS connection if specified
> > >   nfs: allow different protocol in nfs_initiate_commit
> > >   nfs4: pass slot table to nfs40_setup_sequence
> > >   nfs4: export nfs4_sequence_done
> > >   nfs: allow to specify cred in nfs_initiate_pgio
> > >   nfs: set hostname when creating nfsv3 ds connection
> > >   nfs/flexclient: export pnfs_layoutcommit_inode
> > >   nfs41: close a small race window when adding new layout to global list
> > >   nfs41: serialize first layoutget of a file
> > >   nfs: save server READ/WRITE/COMMIT status
> > >   nfs41: pass iomode through layoutreturn args
> > >   nfs41: make a helper function to send layoutreturn
> > >   nfs41: add a helper to mark layout for return
> > >   nfs41: don't use a layout if it is marked for returning
> > >   nfs41: send layoutreturn in last put_lseg
> > >   nfs41: clear NFS_LAYOUT_RETURN if layoutreturn is sent or failed to
> > >     send
> > >   nfs/filelayout: use pnfs_error_mark_layout_for_return
> > >   nfs41: add a debug warning if we destroy an unempty layout
> > >   nfs/flexfiles: send layoutreturn before freeing lseg
> > >   nfs: only reset desc->pg_mirror_idx when mirroring is supported
> > >   nfs: add nfs_pgio_current_mirror helper
> > >   pnfs: allow LD to ask to resend read through pnfs
> > >   nfs41: add range to layoutreturn args
> > >   nfs41: allow async version layoutreturn
> > >   nfs41: introduce NFS_LAYOUT_RETURN_BEFORE_CLOSE
> > >   nfs/flexfiles: defer sending layoutreturn in pnfs_put_lseg
> > >   nfs41: add NFS_LAYOUT_RETRY_LAYOUTGET to layout header flags
> > >   nfs: add a helper to set NFS_ODIRECT_RESCHED_WRITES to direct writes
> > >   nfs41: wait for LAYOUTRETURN before retrying LAYOUTGET
> > > 
> > > Tom Haynes (4):
> > >   pnfs: Prepare for flexfiles by pulling out common code
> > >   pnfs: Do not grab the commit_info lock twice when rescheduling writes
> > >   pnfs: Add nfs_rpc_ops in calls to nfs_initiate_pgio
> > >   pnfs/flexfiles: Add the FlexFile Layout Driver
> > > 
> > > Trond Myklebust (1):
> > >   NFSv4.1/NFSv3: Add pNFS callbacks for nfs3_(read|write|commit)_done()
> > > 
> > > Weston Andros Adamson (9):
> > >   sunrpc: add rpc_count_iostats_idx
> > >   nfs: introduce pg_cleanup op for pgio descriptors
> > >   pnfs: release lseg in pnfs_generic_pg_cleanup
> > >   nfs: handle overlapping reqs in lock_and_join
> > >   nfs: rename pgio header ds_idx to ds_commit_idx
> > >   pnfs: pass ds_commit_idx through the commit path
> > >   nfs: add mirroring support to pgio layer
> > >   nfs: mirroring support for direct io
> > >   pnfs: fail comparison when bucket verifier not set
> > > 
> > >  fs/nfs/Kconfig                            |    5 +
> > >  fs/nfs/Makefile                           |    3 +-
> > >  fs/nfs/blocklayout/blocklayout.c          |    2 +
> > >  fs/nfs/direct.c                           |  108 +-
> > >  fs/nfs/filelayout/filelayout.c            |  315 +-----
> > >  fs/nfs/filelayout/filelayout.h            |   40 -
> > >  fs/nfs/filelayout/filelayoutdev.c         |  469 +--------
> > >  fs/nfs/flexfilelayout/Makefile            |    5 +
> > >  fs/nfs/flexfilelayout/flexfilelayout.c    | 1575 +++++++++++++++++++++++++++++
> > >  fs/nfs/flexfilelayout/flexfilelayout.h    |  152 +++
> > >  fs/nfs/flexfilelayout/flexfilelayoutdev.c |  519 ++++++++++
> > >  fs/nfs/internal.h                         |   34 +-
> > >  fs/nfs/nfs3client.c                       |   41 +
> > >  fs/nfs/nfs3proc.c                         |    9 +
> > >  fs/nfs/nfs3super.c                        |    2 +-
> > >  fs/nfs/nfs3xdr.c                          |    3 +
> > >  fs/nfs/nfs4_fs.h                          |    6 +
> > >  fs/nfs/nfs4client.c                       |    7 +-
> > >  fs/nfs/nfs4proc.c                         |   45 +-
> > >  fs/nfs/nfs4xdr.c                          |    9 +-
> > >  fs/nfs/objlayout/objio_osd.c              |    5 +-
> > >  fs/nfs/pagelist.c                         |  294 +++++-
> > >  fs/nfs/pnfs.c                             |  407 ++++++--
> > >  fs/nfs/pnfs.h                             |  119 ++-
> > >  fs/nfs/pnfs_dev.c                         |  522 ++++++++++
> > >  fs/nfs/pnfs_nfsio.c                       |  283 ++++++
> > >  fs/nfs/read.c                             |   33 +-
> > >  fs/nfs/write.c                            |   49 +-
> > >  include/linux/nfs4.h                      |    1 +
> > >  include/linux/nfs_page.h                  |   22 +-
> > >  include/linux/nfs_xdr.h                   |    6 +-
> > >  include/linux/sunrpc/metrics.h            |    2 +
> > >  net/sunrpc/stats.c                        |   26 +-
> > >  33 files changed, 4119 insertions(+), 999 deletions(-)
> > >  create mode 100644 fs/nfs/flexfilelayout/Makefile
> > >  create mode 100644 fs/nfs/flexfilelayout/flexfilelayout.c
> > >  create mode 100644 fs/nfs/flexfilelayout/flexfilelayout.h
> > >  create mode 100644 fs/nfs/flexfilelayout/flexfilelayoutdev.c
> > >  create mode 100644 fs/nfs/pnfs_nfsio.c
> > > 
> > 
