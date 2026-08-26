Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3627239902B;
	Wed, 26 Aug 2026 20:57:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787777832; cv=none; b=Q8v2gztfyvs2MEUmKhLqns5ibtkb1v5NJJwYxBrIf9fvCpnklvmNMfd0W734J0Anw019crQl1Nfqj1boVok2MC7Y2hBOtuHegGfcxDJ3hJS3IZqed1S5kF5VCstmRVhrVItfhlSY8wAGUYjO21PCdfwf88lEDCEMfKm5hZvj/Kg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787777832; c=relaxed/simple;
	bh=n7YFBJhGLAUs6CDkJlExThDJtIfc9gb/TJkosJ+s6Sw=;
	h=Message-ID:Subject:From:To:Cc:Date:Content-Type:MIME-Version; b=CvlpgnIWrQu2OsBWsfgohh51L7jGlREp/Q6C6FliJgQeY+g24mzo0EVEz69I+yEcnJ2vg4+zfzusLSFPXOgx7QPdsYDLHGgDcutPWjNBfF+3rC+hgXxN0c5r/nzqDHLl7sfLrCoJuz6SgaTr3+mLCcvTX5ePn2YFpUGvL3MTH5M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LFaCE7Pr; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LFaCE7Pr"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 86FDB1F000E9;
	Wed, 26 Aug 2026 20:57:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787777830;
	bh=a1U5Jp6KNy8NA73cOgZJBYh6FC9HUpwjguOAtoXioMU=;
	h=Subject:From:To:Cc:Date;
	b=LFaCE7Pr2fkxWNoOwo5RYPoAzvDxlEDIg3QSMQ3mkQkdjrhpD2BopVQHnBKdvLDDP
	 FO+sIXLmTCyA1ntL7ggLsvVyilYgl1xnnNfR/E7Dwlb3Sj0H1ykS8F3ySnepcXAgpD
	 i9LVpWxqZsxY/jPzf7o8qpm4iotgaAcE+xUEOa7CvMXsMFYkPOzsZ6JoZDx/MpTw20
	 GZO7Opj0tQX5v2Bev0EgBjeFMj8uM6Q+mQJXLNtR93EPMmSWqiQK/2MF7PgmSnKFXR
	 VbH25jetG32dMNl482oxgbUPF8sn/sdZKracUDagbStwTVxB/AKuRiMtEz4Qb8fo0m
	 ygH+ZxfXSiQZw==
Message-ID: <ebcd172da92ef6a8aafb5f0c6f84d0c6a735cb01.camel@kernel.org>
Subject: [GIT PULL] Please pull NFS client fixes for Linux 7.3
From: Trond Myklebust <trondmy@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>, Linux Kernel
 Mailing List <linux-kernel@vger.kernel.org>
Date: Wed, 26 Aug 2026 16:57:09 -0400
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

The following changes since commit db2ddb87143519e20a95aa36c60b36107b736a58=
:

  Linux 7.2-rc7 (2026-08-09 14:54:50 -0700)

are available in the Git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-7.3-1

for you to fetch changes up to ee5a386cfe60f3f8286de16a9db8e1a08f0bc124:

  NFSv4.1: fix layout segment leak on the pnfs_layout_process() forget path=
 (2026-08-20 15:18:20 -0700)

Thanks!
  Trond
----------------------------------------------------------------
NFS client updates for Linux 7.3

Highlights include:

Stable fixes:
- SunRPC: Use-after-free fixes for the sunrpc client code
- NFSv4: Delegation hash table leak
- lockd: NULL dereference on lockowner allocation failure
- SunRPC: Fix a handshake completion race in the TLS code
- NFSv4.1/pNFS: Fix an error sign checking issue when deciding whether
  the layout is still in use, or can be returned.
- NFSv4.1: Fix a layout segment leak in pnfs_layout_process()

Other bugfixes:
- SunRPC: Fix a missing NULL check in the rpcbind client
- SunRPC: annotate shared socket callbacks with READ_ONCE/WRITE_ONCE
- NFSv4: nfs_inode_set_delegation() error paths should return the delegatio=
n
- NFSv4: Use clear_and_wake_up_bit() in nfs_clear_invalid_mapping() and
  the pNFS code.
- NFSv4: Fix the nfs4_alloc_client() error paths to free the IDR
  allocation
- NFS: fix folio dereference before NULL check in nfs_inode_remove_request(=
)
- NFS: Fix delayed delegation return
- NFSv4: Fix another state manager race with umount
- pNFS/blocklayout: Fix device leaks on parse failure
- pNFS: Avoid cancelling in-flight I/O during a layout recall if the
  server doesn't require it
- NFSv4/flexfiles: report cancelled I/O as a layout error
- NFSv4/flexfiles: fix NULL dereference for NFSv4.0 data servers
- NFSv4: Fix incorrect argument passed to nfs4_delete_lease()
- NFSv3: Fix several symlink issues resulting from nfs_atomic_open_v23()
- NFSv4.1: Fix an uninitialised variable issue in the callback code
- NFSv4.2: fix LAYOUTSTATS send buffer exhaustion

Features and cleanups:
- NFSv4.2: Allow the server to specify that file data may not be cached
- NFS/localio: optimise I/O submission when when not doing memory reclaim
- NFS/localio: Remove duplicate wait code in nfs_local_commit
- NFSv4/flexfiles: support loosely coupled NFSv4.x data servers
- NFSv4/pnfs: key the data server cache on the NFS version

----------------------------------------------------------------
Arnaud Bonnet (2):
      nfs: replace atomic bitops sequence with clear_and_wake_up_bit helper
      nfs: refactor pNFS functions using clear_and_wake_up_bit

Benjamin Coddington (3):
      pNFS: report clora_changed in the cb_layoutrecall_file tracepoint
      pNFS: honor clora_changed when recalling a layout
      NFSv4/flexfiles: report cancelled I/O as a layout error

Chuck Lever (1):
      NFS: Return a delegation the client fails to record

Guangshuo Li (1):
      NFS: Fix delayed delegation return list handling

Jeuk Kim (2):
      NFSv4/flexfiles: fix NULL dereference for NFSv4.0 data servers
      NFSv4/flexfiles: support loosely coupled data servers

Jia Zhu (1):
      NFSv4: pin the superblock for active state owners

Jiangshan Yi (1):
      NFS: fix folio dereference before NULL check in nfs_inode_remove_requ=
est()

Junrui Luo (3):
      NFSv4.2: fix LAYOUTSTATS send buffer exhaustion
      NFSv4/pnfs: key the data server cache on the NFS version
      NFSv4.1: fix layout segment leak on the pnfs_layout_process() forget =
path

J=C3=A9r=C3=A9my Jean (2):
      SUNRPC: wait for in-flight client TLS handshake callback
      NFSv4.1: zero referring call lists before decoding

Luxiao Xu (1):
      sunrpc: fix use-after-free in __rpc_clnt_handle_event and __rpc_clnt_=
remove_pipedir

Michael Nemanov (1):
      nfs: fix ENXIO on O_CREAT open of existing symlink over NFSv3

Mike Snitzer (5):
      nfs4.2: request UNCACHEABLE_FILE_DATA only for regular files
      nfs4.2: open UNCACHEABLE_FILE_DATA files with O_DIRECT
      NFS/localio: issue IO inline when not in a memory-reclaim context
      NFS/localio: remove dead FLUSH_SYNC handling from nfs_local_commit
      NFS/localio: issue commit inline when not in a memory-reclaim context

Nate Prodromou (1):
      NFS: fix delegation_hash_table leak when nfs4_server_common_setup() f=
ails

Runyu Xiao (1):
      sunrpc: xprtsock: annotate shared socket callbacks with READ_ONCE/WRI=
TE_ONCE

Ruoyu Wang (1):
      NFSv4: remove callback IDR entry on client allocation failure

Shuangpeng Bai (1):
      lockd: fix NULL dereference on lockowner allocation failure

Tim Menninger (1):
      pNFS: Fix EBUSY check in pnfs_layout_need_return

Tom Haynes (1):
      nfs4.2: add UNCACHEABLE_FILE_DATA attribute support

Weiming Shi (1):
      SUNRPC: check rpc_sockaddr2uaddr() return value in rpcb_register_inet=
4/6

ZhangGuoDong (2):
      pnfs/blocklayout: Fix device leaks on parse failure
      NFS: Verify symlink inode before caching target

Zhansong Gao (1):
      NFSv4: Fix incorrect argument passed to nfs4_delete_lease() in nfs4_a=
dd_lease()

 fs/lockd/clntproc.c                       |  3 ++
 fs/nfs/blocklayout/dev.c                  | 21 +++++++---
 fs/nfs/callback_proc.c                    |  5 ++-
 fs/nfs/callback_xdr.c                     |  2 +-
 fs/nfs/client.c                           | 14 ++++++-
 fs/nfs/delegation.c                       | 20 ++++++---
 fs/nfs/dir.c                              | 17 ++++++++
 fs/nfs/filelayout/filelayoutdev.c         |  5 ++-
 fs/nfs/flexfilelayout/flexfilelayout.c    | 26 +++++++++++-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  6 ++-
 fs/nfs/inode.c                            | 28 ++++++++++---
 fs/nfs/internal.h                         |  8 ++--
 fs/nfs/localio.c                          | 56 +++++++++++++++++++------
 fs/nfs/nfs4client.c                       | 23 +++++++----
 fs/nfs/nfs4file.c                         |  2 +
 fs/nfs/nfs4proc.c                         | 69 +++++++++++++++++++++++++++=
+---
 fs/nfs/nfs4session.c                      | 21 ++++++----
 fs/nfs/nfs4session.h                      |  3 +-
 fs/nfs/nfs4state.c                        | 40 ++++++++++++++----
 fs/nfs/nfs4trace.h                        | 58 +++++++++++++++++++++++++-
 fs/nfs/nfs4xdr.c                          | 35 +++++++++++++++-
 fs/nfs/nfstrace.h                         |  3 +-
 fs/nfs/pnfs.c                             | 60 +++++++++++----------------
 fs/nfs/pnfs.h                             |  8 ++--
 fs/nfs/pnfs_nfs.c                         | 28 ++++++++-----
 fs/nfs/write.c                            | 13 +++---
 include/linux/nfs4.h                      |  9 ++++
 include/linux/nfs_fs.h                    |  4 ++
 include/linux/nfs_xdr.h                   | 10 ++++-
 include/linux/workqueue.h                 |  1 +
 kernel/workqueue.c                        | 24 +++++++++++
 net/sunrpc/clnt.c                         | 22 +++++++---
 net/sunrpc/rpcb_clnt.c                    |  4 ++
 net/sunrpc/xprtsock.c                     | 32 +++++++++-----
 34 files changed, 534 insertions(+), 146 deletions(-)

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
