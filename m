Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oi0-f43.google.com ([209.85.218.43]:51972 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752863AbbBKPnG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2015 10:43:06 -0500
Received: by mail-oi0-f43.google.com with SMTP id z81so34523088oif.2
        for <linux-nfs@vger.kernel.org>; Wed, 11 Feb 2015 07:43:05 -0800 (PST)
Message-ID: <1423669370.7169.7.camel@primarydata.com>
Subject: [GIT PULL] Please pull NFS client changes for 3.20
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Jens Axboe <axboe@kernel.dk>, Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 11 Feb 2015 10:42:50 -0500
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-7FOAniFctrfeBZNMGezG"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-7FOAniFctrfeBZNMGezG
Content-Type: multipart/mixed; boundary="=-2PU2anlKkZyvKxWeZmeg"


--=-2PU2anlKkZyvKxWeZmeg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Linus,

The following changes since commit 2ef47eb1aee171ecf1d83311b9f7fae80f330181=
:

  NFS: Fix use of nfs_attr_use_mounted_on_fileid() (2015-01-21 17:15:41 -05=
00)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.20-=
1

for you to fetch changes up to c627d31ba0696cbd829437af2be2f2dee3546b1e:

  SUNRPC: Cleanup to remove xs_tcp_close() (2015-02-10 11:06:04 -0500)


Please note that there is a known conflict with Jens' block tree in one
of the new files that are added as part of the flexfiles support. I've
attached a patch from Stephen that fixes this conflict up.

Cheers
  Trond

----------------------------------------------------------------
NFS client updates for Linux 3.20

Highlights incluse:

Features:
- Removing the forced serialisation of open()/close() calls in NFSv4.x (x>0=
)
  makes for a significant performance improvement in metadata intensive
  workloads.
- Full support for the pNFS "flexible files" layout type
- Further RPC/RDMA client improvements from Chuck

Bugfixes:
- Stable fix: NFSv4.1 backchannel calls blocking operations with !TASK_RUNN=
ING
- Stable fix: pnfs_generic_pg_init_read/write can be called with lseg =3D=
=3D NULL
- Stable fix: Fix an Oopsable condition when nsm_mon_unmon is called as par=
t
  of the namespace cleanup,
- Stable fix: Ensure we reference the inode for return-on-close in delegret=
urn

- Use SO_REUSEPORT to ensure that NFSv3 TCP connections can rebind to the
  same source address/port combination during a disconnect/reconnect event.
  This is a requirement imposed by most NFSv3 server duplicate reply cache
  implementations.

Optimisations:
- Ask for no NFSv4.1 delegations on OPEN if using O_DIRECT

Other:
- Add Anna Schumaker as co-maintainer for the NFS client

----------------------------------------------------------------
Chuck Lever (22):
      xprtrdma: human-readable completion status
      xprtrdma: Modernize htonl and ntohl
      xprtrdma: Display XIDs in host byte order
      xprtrdma: Clean up hdrlen
      xprtrdma: Rename "xprt" and "rdma_connect" fields in struct rpcrdma_x=
prt
      xprtrdma: Remove rpcrdma_ep::rep_ia
      xprtrdma: Remove rl_mr field, and the mr_chunk union
      xprtrdma: Move credit update to RPC reply handler
      xprtrdma: Remove rpcrdma_ep::rep_func and ::rep_xprt
      xprtrdma: Free the pd if ib_query_qp() fails
      xprtrdma: Take struct ib_device_attr off the stack
      xprtrdma: Take struct ib_qp_attr and ib_qp_init_attr off the stack
      xprtrdma: Simplify synopsis of rpcrdma_buffer_create()
      xprtrdma: Refactor rpcrdma_buffer_create() and rpcrdma_buffer_destroy=
()
      xprtrdma: Add struct rpcrdma_regbuf and helpers
      xprtrdma: Allocate RPC send buffer separately from struct rpcrdma_req
      xprtrdma: Allocate RPC/RDMA send buffer separately from struct rpcrdm=
a_req
      xprtrdma: Allocate RPC/RDMA receive buffer separately from struct rpc=
rdma_rep
      xprtrdma: Allocate zero pad separately from rpcrdma_buffer
      xprtrdma: Clean up after adding regbuf management
      xprtrdma: Update the GFP flags used in xprt_rdma_allocate()
      xprtrdma: Address sparse complaint in rpcr_to_rdmar()

Dan Carpenter (2):
      NFS: a couple off by ones
      pnfs: delete an unintended goto

Jeff Layton (1):
      nfs: don't call blocking operations while !TASK_RUNNING

Omar Sandoval (1):
      nfs: prevent truncate on active swapfile

Peng Tao (37):
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
      nfs41: close a small race window when adding new layout to global lis=
t
      nfs41: serialize first layoutget of a file
      nfs: save server READ/WRITE/COMMIT status
      nfs41: pass iomode through layoutreturn args
      nfs41: make a helper function to send layoutreturn
      nfs41: add a helper to mark layout for return
      nfs41: don't use a layout if it is marked for returning
      nfs41: send layoutreturn in last put_lseg
      nfs41: clear NFS_LAYOUT_RETURN if layoutreturn is sent or failed to s=
end
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
      nfs: count DIO good bytes correctly with mirroring
      nfs41: .init_read and .init_write can be called with valid pg_lseg

Tom Haynes (6):
      pnfs: Prepare for flexfiles by pulling out common code
      pnfs: Do not grab the commit_info lock twice when rescheduling writes
      pnfs: Add nfs_rpc_ops in calls to nfs_initiate_pgio
      pnfs/flexfiles: Add the FlexFile Layout Driver
      pnfs: Update documentation on the Layout Drivers
      pnfs/flexfiles: Do not dprintk after the free

Trond Myklebust (43):
      NFSv4: Fix an atomicity problem in CLOSE
      NFSv4: More CLOSE/OPEN races
      NFSv4: Convert nfs_alloc_seqid() to return an ERR_PTR() if allocation=
 fails
      NFSv4: Check for NULL argument in nfs_*_seqid() functions
      NFSv4.1: Allow parallel OPEN/OPEN_DOWNGRADE/CLOSE
      NFSv4: Fix atomicity problems with lock stateid updates
      NFSv4: Always do open_to_lock_owner if the lock stateid is uninitiali=
sed
      NFSv4: Fix lock on-wire reordering issues
      NFSv4: Update of VFS byte range lock must be atomic with the stateid =
update
      NFSv4.1: Allow parallel LOCK/LOCKU calls
      NFSv4.1: Optimise layout return-on-close
      SUNRPC: Adjust rpciod workqueue parameters
      SUNRPC: Allow waiting on memory allocation
      NFSv4.1: Replace usage of nfs_client->cl_addr in encode_create_sessio=
n
      NFSv4: Deal with atomic upgrades of an existing delegation
      Merge tag 'nfs-rdma-for-3.20' of git://git.linux-nfs.org/projects/ann=
a/nfs-rdma
      NFSv4.1/NFSv3: Add pNFS callbacks for nfs3_(read|write|commit)_done()
      Merge branch 'flexfiles'
      SUNRPC: NULL utsname dereference on NFS umount during namespace clean=
up
      NFS: Add Anna Schumaker as co-maintainer for the NFS client
      NFSv4.1: Ask for no delegation on OPEN if using O_DIRECT
      NFSv4: Ensure we reference the inode for return-on-close in delegretu=
rn
      NFSv4.1: Pin the inode and super block in asynchronous layoutcommit
      NFSv4.1: Pin the inode and super block in asynchronous layoutreturns
      NFSv4.1: pnfs_send_layoutreturn should use GFP_NOFS
      NFSv4.1: Fix pnfs_put_lseg races
      Merge tag 'nfs-rdma-for-3.20-part-2' of git://git.linux-nfs.org/proje=
cts/anna/nfs-rdma
      SUNRPC: Set SO_REUSEPORT socket option for TCP connections
      SUNRPC: Handle EADDRINUSE on connect
      SUNRPC: Do not clear the source port in xs_reset_transport
      SUNRPC: Ensure xs_reset_transport() resets the close connection flags
      SUNRPC: Add helpers to prevent socket create from racing
      SUNRPC: TCP/UDP always close the old socket before reconnecting
      SUNRPC: Remove TCP client connection reset hack
      SUNRPC: Remove TCP socket linger code
      SUNRPC: Cleanup to remove remaining uses of XPRT_CONNECTION_ABORT
      SUNRPC: Ensure xs_tcp_shutdown() requests a full close of the connect=
ion
      SUNRPC: Make xs_tcp_close() do a socket shutdown rather than a sock_r=
elease
      SUNRPC: Remove the redundant XPRT_CONNECTION_CLOSE flag
      SUNRPC: Handle connection reset more efficiently.
      SUNRPC: Define xs_tcp_fin_timeout only if CONFIG_SUNRPC_DEBUG
      SUNRPC: Fix stupid typo in xs_sock_set_reuseport
      SUNRPC: Cleanup to remove xs_tcp_close()

Weston Andros Adamson (10):
      sunrpc: add rpc_count_iostats_idx
      nfs: introduce pg_cleanup op for pgio descriptors
      pnfs: release lseg in pnfs_generic_pg_cleanup
      nfs: handle overlapping reqs in lock_and_join
      nfs: rename pgio header ds_idx to ds_commit_idx
      pnfs: pass ds_commit_idx through the commit path
      nfs: add mirroring support to pgio layer
      nfs: mirroring support for direct io
      pnfs: fail comparison when bucket verifier not set
      pnfs: lookup new lseg at lseg boundary

 Documentation/filesystems/nfs/pnfs.txt    |   13 +-
 MAINTAINERS                               |    1 +
 fs/lockd/mon.c                            |   13 +-
 fs/nfs/Kconfig                            |    5 +
 fs/nfs/Makefile                           |    3 +-
 fs/nfs/blocklayout/blocklayout.c          |    2 +
 fs/nfs/callback.c                         |    8 +-
 fs/nfs/delegation.c                       |   20 +-
 fs/nfs/direct.c                           |  112 +-
 fs/nfs/filelayout/filelayout.c            |  315 +-----
 fs/nfs/filelayout/filelayout.h            |   40 -
 fs/nfs/filelayout/filelayoutdev.c         |  469 +--------
 fs/nfs/flexfilelayout/Makefile            |    5 +
 fs/nfs/flexfilelayout/flexfilelayout.c    | 1574 +++++++++++++++++++++++++=
++++
 fs/nfs/flexfilelayout/flexfilelayout.h    |  155 +++
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  552 ++++++++++
 fs/nfs/idmap.c                            |    3 +-
 fs/nfs/inode.c                            |    7 +-
 fs/nfs/internal.h                         |   53 +-
 fs/nfs/nfs2xdr.c                          |   10 +-
 fs/nfs/nfs3_fs.h                          |    2 +
 fs/nfs/nfs3client.c                       |   41 +
 fs/nfs/nfs3proc.c                         |    9 +
 fs/nfs/nfs3super.c                        |    2 +-
 fs/nfs/nfs3xdr.c                          |    3 +
 fs/nfs/nfs4_fs.h                          |    9 +
 fs/nfs/nfs4client.c                       |    7 +-
 fs/nfs/nfs4proc.c                         |  315 +++---
 fs/nfs/nfs4state.c                        |   31 +-
 fs/nfs/nfs4super.c                        |    3 +
 fs/nfs/nfs4xdr.c                          |  113 ++-
 fs/nfs/nfsroot.c                          |    4 +-
 fs/nfs/objlayout/objio_osd.c              |    5 +-
 fs/nfs/pagelist.c                         |  294 +++++-
 fs/nfs/pnfs.c                             |  471 +++++++--
 fs/nfs/pnfs.h                             |  135 ++-
 fs/nfs/pnfs_nfs.c                         |  840 +++++++++++++++
 fs/nfs/read.c                             |   33 +-
 fs/nfs/super.c                            |    9 +-
 fs/nfs/write.c                            |   52 +-
 include/linux/nfs4.h                      |    1 +
 include/linux/nfs_fs_sb.h                 |    9 +-
 include/linux/nfs_idmap.h                 |    2 +
 include/linux/nfs_page.h                  |   22 +-
 include/linux/nfs_xdr.h                   |   19 +-
 include/linux/sunrpc/clnt.h               |    3 +-
 include/linux/sunrpc/metrics.h            |    4 +
 include/linux/sunrpc/rpc_rdma.h           |   14 +-
 include/linux/sunrpc/svc_rdma.h           |    2 -
 include/linux/sunrpc/xprt.h               |    6 +-
 net/sunrpc/clnt.c                         |   15 +-
 net/sunrpc/rpcb_clnt.c                    |    8 +-
 net/sunrpc/sched.c                        |    7 +-
 net/sunrpc/stats.c                        |   26 +-
 net/sunrpc/xprt.c                         |   38 +-
 net/sunrpc/xprtrdma/rpc_rdma.c            |  108 +-
 net/sunrpc/xprtrdma/transport.c           |  182 ++--
 net/sunrpc/xprtrdma/verbs.c               |  411 +++++---
 net/sunrpc/xprtrdma/xprt_rdma.h           |  112 +-
 net/sunrpc/xprtsock.c                     |  238 ++---
 60 files changed, 5236 insertions(+), 1729 deletions(-)
 create mode 100644 fs/nfs/flexfilelayout/Makefile
 create mode 100644 fs/nfs/flexfilelayout/flexfilelayout.c
 create mode 100644 fs/nfs/flexfilelayout/flexfilelayout.h
 create mode 100644 fs/nfs/flexfilelayout/flexfilelayoutdev.c
 create mode 100644 fs/nfs/pnfs_nfs.c

--=20
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com




--=-2PU2anlKkZyvKxWeZmeg
Content-Disposition: inline
Content-Description: Forwarded message - linux-next: build failure after
 merge of the block tree
Content-Type: message/rfc822

Delivered-To: trondmy@gmail.com
Received: by 10.107.39.135 with SMTP id n129csp1328777ion; Sun, 8 Feb 2015
 20:25:43 -0800 (PST)
X-Received: by 10.112.53.137 with SMTP id b9mr14522749lbp.66.1423455942142;
 Sun, 08 Feb 2015 20:25:42 -0800 (PST)
Return-Path: <sfr@canb.auug.org.au>
Received: from mail-forward4.uio.no (mail-forward4.uio.no.
 [2001:700:100:10::33]) by mx.google.com with ESMTPS id
 c7si7954950laa.63.2015.02.08.20.25.40 for <trondmy@gmail.com>
 (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128); Sun, 08
 Feb 2015 20:25:41 -0800 (PST)
Received-SPF: none (google.com: sfr@canb.auug.org.au does not designate
 permitted sender hosts) client-ip=2001:700:100:10::33;
Authentication-Results: mx.google.com; spf=none (google.com:
 sfr@canb.auug.org.au does not designate permitted sender hosts)
 smtp.mail=sfr@canb.auug.org.au
Received: from exim by mail-out4.uio.no with local-bsmtp (Exim 4.80.1)
 (envelope-from <sfr@canb.auug.org.au>) id 1YKfum-0007B4-7J for
 trondmy@gmail.com; Mon, 09 Feb 2015 05:25:40 +0100
Received: from mail-mx2.uio.no ([129.240.10.30]) by mail-out4.uio.no with
 esmtp (Exim 4.80.1) (envelope-from <sfr@canb.auug.org.au>) id
 1YKfum-0007B0-69 for trondmy@gmail.com; Mon, 09 Feb 2015 05:25:40 +0100
Received: from ozlabs.org ([103.22.144.67]) by mail-mx2.uio.no with esmtps
 (TLSv1.2:DHE-RSA-AES256-GCM-SHA384:256) (Exim 4.80) (envelope-from
 <sfr@canb.auug.org.au>) id 1YKful-0005sa-9T for trond.myklebust@fys.uio.no;
 Mon, 09 Feb 2015 05:25:40 +0100
Received: from authenticated.ozlabs.org (localhost [127.0.0.1]) (using
 TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits)) (No client
 certificate requested) by ozlabs.org (Postfix) with ESMTPSA id 9639114012E;
 Mon,  9 Feb 2015 15:25:31 +1100 (AEDT)
Date: Mon, 9 Feb 2015 15:25:26 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Jens Axboe <axboe@kernel.dk>, Trond Myklebust
 <trond.myklebust@fys.uio.no>
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Tom Haynes
 <loghyr@primarydata.com>, Weston Andros Adamson <dros@primarydata.com>, Tao
 Peng <bergwolf@primarydata.com>, Christoph Hellwig <hch@lst.de>
Subject: linux-next: build failure after merge of the block tree
Message-ID: <20150209152526.1f2b749e@canb.auug.org.au>
X-Mailer: Claws Mail 3.11.1 (GTK+ 2.24.25; i586-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256; boundary="Sig_/lIBdJTDjWUmiS_SVG5o_Yc_"; protocol="application/pgp-signature"
X-UiO-Spam-info: not spam, SpamAssassin (score=-2.3, required=5.0,
 autolearn=disabled, RCVD_IN_DNSWL_MED=-2.3, uiobl=NO, uiouri=NO)
X-UiO-Scanned: 0674478C028215C185ECFEF09ACB7A7DC9B31E65
X-UiO-SPAM-Test: remote_host: 103.22.144.67 spam_score: -22 maxlevel 30
 minaction 1 bait 0 mail/h: 1 total 11 max/h 2 blacklist 0 greylist 1
 ratelimit 0

--Sig_/lIBdJTDjWUmiS_SVG5o_Yc_
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Jens,

After merging the block tree, today's linux-next build (x86_64 allmodconfig)
failed like this:

fs/nfs/flexfilelayout/flexfilelayout.c: In function 'ff_layout_mark_request=
_commit':
fs/nfs/flexfilelayout/flexfilelayout.c:1369:47: error: 'struct address_spac=
e' has no member named 'backing_dev_info'
   inc_bdi_stat(page_file_mapping(req->wb_page)->backing_dev_info,
                                               ^

Caused by commit b83ae6d42143 ("fs: remove mapping->backing_dev_info")
interacting with commit d67ae825a59d ("pnfs/flexfiles: Add the FlexFile
Layout Driver") from the nfs tree.

I have added this merge fix patch (assuming it is correct, someone
needs to tell Linus about this when the trees get merged):

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 9 Feb 2015 15:20:12 +1100
Subject: [PATCH] pnfs/flexfiles: fix FlexFile Layout Driver for removal
 mapping->backing_dev_info

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout=
/flexfilelayout.c
index f29fb7d7e8f8..c22ecaa86c1c 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1366,7 +1366,7 @@ ff_layout_mark_request_commit(struct nfs_page *req,
 	spin_unlock(cinfo->lock);
 	if (!cinfo->dreq) {
 		inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-		inc_bdi_stat(page_file_mapping(req->wb_page)->backing_dev_info,
+		inc_bdi_stat(inode_to_bdi(page_file_mapping(req->wb_page)->host),
 			     BDI_RECLAIMABLE);
 		__mark_inode_dirty(req->wb_context->dentry->d_inode,
 				   I_DIRTY_DATASYNC);
--=20
2.1.4

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/lIBdJTDjWUmiS_SVG5o_Yc_
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJU2Da7AAoJEMDTa8Ir7ZwVCOYP/2+vvkx3AQSxOvJKyaBxOn6L
jEKSVhKRa0Xf7lj3E5k4RYicqaffkiGBnqfIblsqC2TCboMpKf+0shh02/CWFz76
+7+wveZJ8DPn4hK5WhHTiJiV0FpYND/aANOE1Ho0WIFd5SAaINLqiHIt6AMeiv/Q
gW3aNx9rdBve0Y01Xyt9OklxarG9rNU/yPoQiCI3r/5XNi63Xk3hXx5OAbJozlD2
WD76hNpB6oU1YeBBTKzdroETNIsvgokCPiW9mN60qHUhDenXMhKo3VzFQVjCNZh0
GSbQ0Q1yDsuPz2lKFFwANq55K5T5KY3Q1C2lIgnqm7XE2A5CxNxrLCy5iiDJ8GTM
IXnRCRYbzMGngqSm3P86RZFYqzy96Q/V3xPnzO4vXDODBQqguuyU4ggqGMzf69dp
xNBmqKYDREOz8fAGOEQi7dzOhaCKS7A7db1panv9B3Yzq5uV2QaJtJVMxu+uDRAL
h/YUt4qu93UIGJLAE4MZbsn5/yUB1iWwU7Q2cPm34gWkZuJswxMu49+XFr4Qrvmj
daOSx25PeQYu8TJ3rvE1a6j/s+zPHtJcxXr9FuPCeCmTptzMw31M2lLJ3bneVLnY
JDUPr9JTPxnUO/WEBQOMvpUJBx3o7uBE6hTzD4wRgHllRKaNVxCiiPnonDZzqELQ
8XbL5rWGq3q0sQFkZmBo
=rU1b
-----END PGP SIGNATURE-----

--Sig_/lIBdJTDjWUmiS_SVG5o_Yc_--

--=-2PU2anlKkZyvKxWeZmeg--

--=-7FOAniFctrfeBZNMGezG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJU23iFAAoJEGcL54qWCgDyusAP/jlUefYvoU64mZOavnkVK56T
dvqxhzyrP1cyfQkkbSnax6XGSBGA+xr4bYgnPxub/yxhOE+C2vnBq/GlSIwl2g3t
IfZOqqp3C5pc1hcy+v2+SnNQgNwNsPi6TVKvpV8HCOo8PzGitibD4t3gIPCloVzW
krMBYClPv8miNmj7m2NLCh7jtR2BP+uKjPSzA6q2orFpxUXFPLATDc8EZf+KOGwN
J6IETzWruf79ekqTzVwSCLKLt4o8S84YES3Q1o/9NgpJIJ4PKY1q+M5EmZ7pIH0o
onBwYxev43WY7mEVAojmPcWAhNnAkHzFIQ6AUYgzLScng43EggyHTXPvrxSwdVSj
79+mvfqPUi/AuGDP79Glg/vnHEi8EIiHHbzpch/yYL5mvWNdC2sHu6vaSjtaV6EX
29BBRJJrcCt96yv960g0AvEOSgIXEu3o5t5t7LhLatHxV9Bn94FvKMWZMKfIQvTI
RCXDkC6MxtoV50ZUuJxGXbemAhjJejIBfrrrAD5We8Hl6+1AuFcbAmN8NUFnBL5X
z0OEtviDkNzo9JI+VtB3N1oavDJ4BPz23cO492LetdMOP6xbTqtBAxtsOOlRKYxv
/pRArKPOAJD4mB4k1Y7CgMvGpMn+7r8VxEh+Y/ALGckAIUHK2SXM9dYoL+jXjZzo
0074PYbA//ofzXAkHpQV
=Z3n1
-----END PGP SIGNATURE-----

--=-7FOAniFctrfeBZNMGezG--

