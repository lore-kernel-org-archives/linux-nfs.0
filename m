Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10453 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932174Ab2JJOhE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Oct 2012 10:37:04 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        "Linux Kernel mailing list" <linux-kernel@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client updates for 3.7
Date: Wed, 10 Oct 2012 14:37:01 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9091C74CD@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="=-b3uykmhNyKhmFdPRCR+Z"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-b3uykmhNyKhmFdPRCR+Z
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Linus,

The following changes since commit c46de2263f42fb4bbde411b9126f471e9343cb22=
:

  Merge branch 'for-linus' of git://git.kernel.dk/linux-block (2012-09-19 1=
1:04:34 -0700)

are available in the git repository at:


  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.7-1

for you to fetch changes up to af283885b70248268617955a5ea5476647bd556b:

  pnfsblock: cleanup nfs4_blkdev_get (2012-10-08 19:32:40 -0400)

----------------------------------------------------------------
NFS client updates for Linux 3.7

Features include:

- Remove CONFIG_EXPERIMENTAL dependency from NFSv4.1
  Aside from the issues discussed at the LKS, distros are shipping
  NFSv4.1 with all the trimmings.
- Fix fdatasync()/fsync() for the corner case of a server reboot.
- NFSv4 OPEN access fix: finally distinguish correctly between
  open-for-read and open-for-execute permissions in all situations.
- Ensure that the TCP socket is closed when we're in CLOSE_WAIT
- More idmapper bugfixes
- Lots of pNFS bugfixes and cleanups to remove unnecessary state and
  make the code easier to read.
- In cases where a pNFS read or write fails, allow the client to
  resume trying layoutgets after two minutes of read/write-through-mds.
- More net namespace fixes to the NFSv4 callback code.
- More net namespace fixes to the NFSv3 locking code.
- More NFSv4 migration preparatory patches.
  Including patches to detect network trunking in both NFSv4 and NFSv4.1
- pNFS block updates to optimise LAYOUTGET calls.

----------------------------------------------------------------
Andy Adamson (3):
      NFSv4.0 reclaim reboot state when re-establishing clientid
      NFSv4 reduce attribute requests for open reclaim
      NFSv4 set open access operation call flag in nfs4_init_opendata_res

Bryan Schumaker (5):
      SUNRPC: Set alloc_slot for backchannel tcp ops
      NFS: Always use the open stateid when checking for expired opens
      NFS: Remove bad delegations during open recovery
      NFS: Use kzalloc() instead of kmalloc() in the idmapper
      NFS: Set key construction data for the legacy upcall

Chuck Lever (11):
      NFS: nfs_parsed_mount_options can use unsigned int
      NFS: Slow down state manager after an unhandled error
      SUNRPC: Clean up dprintk messages in rpc_pipe.c
      SUNRPC: Use __func__ in dprintk() in auth_gss.c
      SUNRPC: Refactor rpc_clone_client()
      SUNRPC: Introduce rpc_clone_client_set_auth()
      NFS: Introduce "migration" mount option
      NFS: Use the same nfs_client_id4 for every server
      NFS: Discover NFSv4 server trunking when mounting
      NFS: Add nfs4_unique_id boot parameter
      NFS: nfs41_walk_client_list(): re-lock before iterating

Daniel Walter (1):
      nfs: replace strict_strto* with kstrto*

NeilBrown (1):
      NFS4: avoid underflow when converting error to pointer.

Peng Tao (10):
      NFSv41: fix DIO write_io calculation
      NFS41: fix error of setting blocklayoutdriver
      Revert "pnfsblock: bail out partial page IO"
      pnfsblock: fix partial page buffer wirte
      pnfsblock: fix non-aligned DIO read
      pnfsblock: fix non-aligned DIO write
      NFS: track direct IO left bytes
      NFS41: send real write size in layoutget
      NFS41: send real read size in layoutget
      pnfsblock: cleanup nfs4_blkdev_get

Stanislav Kinsbursky (18):
      NFS: pass net to nfs_callback_down()
      NFS: callback service creation function introduced
      NFS: move per-net callback thread initialization to nfs_callback_up_n=
et()
      NFS: callback up - transport backchannel cleanup
      NFS: callback service start function introduced
      NFS: callback up - users counting cleanup
      NFS: make nfs_callback_tcpport per network context
      NFS: make nfs_callback_tcpport6 per network context
      NFS: callback per-net usage counting introduced
      NFS: add debug messages to callback down function
      lockd: per-net NSM client creation and destruction helpers introduced
      lockd: use rpc client's cl_nodename for id encoding
      lockd: create and use per-net NSM RPC clients on MON/UNMON requests
      nfs: include NFSv4 header in netns.h
      nfs: declare nfs_callback_tcp_port in header
      nfs: declare nfs_xdev_mount as static
      nfs: include nfs4_fh.h in nfs4sysctl.c
      nfs: include internal.h in getroot.h

Trond Myklebust (58):
      SUNRPC: Ensure that the TCP socket is closed when in CLOSE_WAIT
      SUNRPC: Fix the return value of xdr_align_pages()
      NFSv4.1: decode_getdeviceinfo should check xdr_read_pages() return va=
lue
      NFSv4: Remove BUG_ON() and ACCESS_ONCE() calls in the idmapper
      NFSv4: Clean up the legacy idmapper upcall
      NFSv4: Ensure that idmap_pipe_downcall sanity-checks the downcall dat=
a
      SUNRPC: Optimise away unnecessary data moves in xdr_align_pages
      NFS: Convert nfs_get_lock_context to return an ERR_PTR on failure
      NFS: Clean up helper function nfs4_select_rw_stateid()
      NFSv4: Convert the nfs4_lock_state->ls_flags to a bit field
      NFS: Fix fdatasync/fsync() when confronted with a server reboot
      NFS: Write the entire file if a server reboot occurs during fsync()
      SUNRPC: Get rid of the redundant xprt->shutdown bit field
      NFS: Clean up the pNFS layoutget interface
      NFSv4.1: Cleanup add a "pnfs_" prefix to mark_matching_lsegs_invalid
      NFSv4.1: Cleanup; add "pnfs_" prefix to get_layout_hdr() and put_layo=
ut_hdr()
      NFSv4.1: Cleanup; add "pnfs_" prefix to put_lseg() and get_lseg()
      NFSv4.1: Replace get_device_info() with filelayout_get_device_info()
      NFSv4.1: Replace dprintk() in pnfs_update_layout with something less =
buggy
      NFSv4.1: Add helpers for setting/reading the I/O fail bit
      NFSv4.1: Retry pNFS after a 2 minute timeout
      NFSv4.1: pNFS data servers may be temporarily offline
      NFSv4.1: Fix a reference leak in pnfs_update_layout
      NFSv4.1: Don't drop the pnfs_layout_hdr after a layoutget failure
      NFSv4.1: pnfs_layout_io_set_failed must clear invalid lsegs
      NFSv4.1: Fix a race in the pNFS return-on-close code
      NFSv4.1: Simplify the pNFS return-on-close code
      NFSv4.1: Get rid of pNFS layout state "NFS_LAYOUT_INVALID"
      NFSv4.1: reset the inode MDS threshold counters on layout destruction
      NFSv4.1: Rename the pnfs_put_lseg_common to pnfs_layout_remove_lseg
      NFSv4.1: Remove redundant reference to the pnfs_layout_hdr
      NFSv4.1: Free the pnfs_layout_hdr outside the inode->i_lock
      NFSv4.1: Clean up the removal of pnfs_layout_hdr from the server list
      NFSv4.1: Clean up pnfs_put_lseg()
      NFSv4.1: Balance pnfs_layout_hdr refcount in pnfs_layout_(insert|remo=
ve)_lseg
      NFSv4.1: Get rid of pNFS spin lock debugging asserts...
      NFSv4.1: Remove unused 'default allocation' for pnfs_alloc_layout_hdr=
()
      NFSv4.1: Get rid of the NFS_LAYOUT_DESTROYED state
      NFSv4.1: Clear NFS_LAYOUT_BULK_RECALL when the layout segments are fr=
eed
      NFSv4.1: Remove the NFS_LAYOUT_RETURNED state
      NFSv4.1: _pnfs_return_layout() shouldn't invalidate the layout on fai=
lure
      NFSv4.1: nfs4_proc_layoutreturn must always drop the plh_block_lgets =
count
      SUNRPC: Limit the rpciod workqueue concurrency
      Merge branch 'bugfixes' into nfs-for-next
      NFSv4: Fix up a merge conflict between migration and container change=
s
      NFSv4: Fix the minor version callback channel startup
      NFSv4: nfs4_match_clientids is only used by NFSv4.1
      NFSv4.1: bl_pg_init_write should be static
      NFSv4.1: Handle BAD_STATEID and EXPIRED errors in layoutget
      NFSv4.1: Fix another refcount issue in pnfs_find_alloc_layout
      NFSv4.1: Always set the layout stateid if this is the first layoutget
      NFSv4.1: Deal with wraparound issues when updating the layout stateid
      NFSv4.1: Deal with wraparound when updating the layout "barrier" seqi=
d
      NFSv4: nfs4_open_done first must check that GETATTR decoded a file ty=
pe
      NFSv4.1: Remove the dependency on CONFIG_EXPERIMENTAL
      NFSv4.1: Deal with seqid wraparound in the pNFS return-on-close code
      NFSv4.1: Ensure that the layout sequence id stays 'close' to the curr=
ent
      NFSv4.1: Cleanup ugliness in pnfs_layoutgets_blocked()

Wei Yongjun (2):
      NFS: fix the return value check by using IS_ERR
      pnfsblock: use list_move_tail instead of list_del/list_add_tail

Weston Andros Adamson (4):
      NFSv4: Add ACCESS operation to OPEN compound
      NFSv4.1: don't do two EXCHANGE_IDs on mount
      NFSv4: don't check MAY_WRITE access bit in OPEN
      NFSv4: don't put ACCESS in OPEN compound if O_EXCL

Yanchuan Nian (1):
      NFS: Remove unnecessary semicolons (fs/nfs/client.c)

 Documentation/filesystems/nfs/nfs.txt |  44 +++-
 Documentation/kernel-parameters.txt   |   5 +
 fs/lockd/mon.c                        |  86 +++++--
 fs/lockd/netns.h                      |   4 +
 fs/lockd/svc.c                        |   1 +
 fs/nfs/Kconfig                        |   4 +-
 fs/nfs/blocklayout/blocklayout.c      | 306 +++++++++++++++++++++----
 fs/nfs/blocklayout/blocklayout.h      |   2 +-
 fs/nfs/blocklayout/blocklayoutdev.c   |  25 +-
 fs/nfs/blocklayout/extents.c          |   3 +-
 fs/nfs/callback.c                     | 321 +++++++++++++++++---------
 fs/nfs/callback.h                     |   3 +-
 fs/nfs/callback_proc.c                |  31 ++-
 fs/nfs/client.c                       |  23 +-
 fs/nfs/dir.c                          |  16 +-
 fs/nfs/direct.c                       |  32 ++-
 fs/nfs/file.c                         |  41 +++-
 fs/nfs/getroot.c                      |   2 +
 fs/nfs/idmap.c                        | 114 ++++++----
 fs/nfs/inode.c                        |  10 +-
 fs/nfs/internal.h                     |  15 +-
 fs/nfs/netns.h                        |   4 +
 fs/nfs/nfs4_fs.h                      |  19 +-
 fs/nfs/nfs4client.c                   | 256 ++++++++++++++++++++-
 fs/nfs/nfs4file.c                     |  29 ++-
 fs/nfs/nfs4filelayout.c               |  41 ++--
 fs/nfs/nfs4filelayout.h               |  16 +-
 fs/nfs/nfs4filelayoutdev.c            |  17 +-
 fs/nfs/nfs4namespace.c                |  16 +-
 fs/nfs/nfs4proc.c                     | 342 +++++++++++++++++++++-------
 fs/nfs/nfs4state.c                    | 228 +++++++++++++++++--
 fs/nfs/nfs4sysctl.c                   |   1 +
 fs/nfs/nfs4xdr.c                      |  31 ++-
 fs/nfs/objlayout/objio_osd.c          |   9 +-
 fs/nfs/pagelist.c                     |  12 +-
 fs/nfs/pnfs.c                         | 417 ++++++++++++++++++++----------=
----
 fs/nfs/pnfs.h                         |  57 ++---
 fs/nfs/pnfs_dev.c                     |  27 +++
 fs/nfs/super.c                        |  31 ++-
 fs/nfs/write.c                        |  11 +-
 include/linux/nfs_fs.h                |  11 +-
 include/linux/nfs_fs_sb.h             |   3 +
 include/linux/nfs_xdr.h               |   5 +-
 include/linux/sunrpc/clnt.h           |   2 +
 include/linux/sunrpc/xprt.h           |   3 +-
 net/sunrpc/auth_gss/auth_gss.c        |  58 ++---
 net/sunrpc/clnt.c                     | 105 +++++----
 net/sunrpc/rpc_pipe.c                 |   8 +-
 net/sunrpc/sched.c                    |   2 +-
 net/sunrpc/xdr.c                      |  21 +-
 net/sunrpc/xprt.c                     |   8 +-
 net/sunrpc/xprtrdma/transport.c       |  22 +-
 net/sunrpc/xprtsock.c                 |  40 ++--
 53 files changed, 2126 insertions(+), 814 deletions(-)

--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

--=-b3uykmhNyKhmFdPRCR+Z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABAgAGBQJQdYgCAAoJEGcL54qWCgDyaW8P/0ClQjY274bPtsunRz5DSc4r
cvQkmZE+GLacysi5YCOZgN1MkSaJ5S2lIobeRPs6KHJcIXSwOsaG4OrxfhLbipee
ZQoIukec4IUFRkpGJXMM7IL3I1Dpv3NSIUD6xLxVym+jnMlTSF2NWpNF6Nrd7syx
EDd43EvPrgFWhEq/vi6qDr7JugLmCkwhGFIBMJX/YCR8AUrqceNn8WfkzB9nMr4G
KWn31kwtn6xiEAs0DYEKZxY6BYvVM21i2qIFxEJlwnoTKWVrUCFwsGWa4o8VvOgo
HEoKYiVI0q98FOKrXj0PLClhb2r+JLAR+aMHM0DvxIfCwXtQ8m9rHehv/xtXFloa
cIhCWkh1VwkE4aK8RY7bLBiQ4z4XAedJiOcF2FWHXOU027LK+4w6ZylmBGhMmShu
NonV6LKczIgfrVhLiTNDAJw/UWBzk9y/4JnpIWtaxraUNrKW/6qFaInYw4kdg6nW
d8UL79ccxUxDE7qpJodqxApzkv+TauJcN7Un7Fc34+q0/fxJWOSkjzcIyPC1La/7
sqtapt4NzyiDbekqOzcluiOFQx7noGkFlu73f8U71mSFHgXjuY/eHbul6Mxk5Vi8
F70KrW6zsWtQ+PDme3aKjCKiOm6BvP1iIEyeu03vNRcw/Nt37i7O8QwvpTbEuWLC
e8jhGui5j1LitTbW7gvF
=a8uC
-----END PGP SIGNATURE-----

--=-b3uykmhNyKhmFdPRCR+Z--
