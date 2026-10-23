Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792789912;
	b=ZIUHyJRAgxTkAOfitqckJ63K6pjjGNWtUkPgMcC2HsrGsDZTqWFnXi2ywWks2wJEwrtw
	 SCpGDO/TPTZEwHHN1J7Gwpqstto5TmPTL2ElYLV/eStH1PFH3WXmedewtCm8BPCXsCHJe
	 yhY7y6tuzxzXVBpjeNCRf5IUNVwiOc6NGtOxISt+OfNsAW4+LlBxa6nAw2Z4nNaP9qxSJ
	 7QPPBsEyWTVTkIsBPnpFCYBrphV8QI81NFtF+mjAS1kUrk0+RujbI5LHzlqO18w0RWQvH
	 xeKO5nxR5W1zhEMqtgNN5TWmbtUeVHTKuQCcZofU2gMDwE0VsbeuMGCb1RzJfAPGR2w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792789912;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Type:Content-Transfer-Encoding;
	bh=4BdW6OI7woyrNw3g7V3FStfomukHSGT51EXRCyHNXGM=;
	b=Y/0T3RynzYCW8b6QjyLId2kxuEr9VBmGfqMwThUQqKysQ0GzgLrTTH2W/gJo7/HMUYew
	 feSaICXazpOaDTGZKRt3WsN2ox3sCjozDEHXIyMGXOisYjITauH2bXqqiCXjoU53jbpWF
	 MWRSA7Sxv4LA0b6jY+r1L4Ie7JotW2eGfyESY+etObK5QF37Ka/KtBYMQHZcBGI8Bn7eq
	 Kqyc3L5k76ca0YreHhP5jbNUED965mblc/hHv0B1MZ8sHci6/jKQ1YKrC6HSwMyQSwySD
	 AfxYTNcA5kpG0IZEgNP5DdtwCV3ge15hK3T85D7uyy9i52+0tKuqY50qCIkESmm0nxw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nlRSLwQ5;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 257DE606A31A
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 21:11:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nlRSLwQ5
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7CDA61F01825;
	Fri, 23 Oct 2026 21:11:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792789911;
	bh=4BdW6OI7woyrNw3g7V3FStfomukHSGT51EXRCyHNXGM=;
	h=From:To:Cc:Subject:Date;
	b=nlRSLwQ5aTU7j03IAyRLi/UDKzIZfP3072BLp7mSE0dNDZ1jJ4fLDlFfaiqE6hZWU
	 To72LFIVOBZh1dw510Uw4HD3kBfbCIdBviFRrH5ZHEzOejNRUNQ5HGDSqZH/sj35GQ
	 pKlPpuhAx+4aFx1Fsobxj46q9/Lo1xvol23uVpfJ2krPUUtoWNRikulnshJXtFHvVj
	 9TaHDZql6KV9wJqxATSswgty5H7ciTJG5EIQIyrtf+idYdZvXkXzuXtPtYzVV3Xg2R
	 I3AAk2LnQVQvQYFvDXnRnM1Tn4ZngWNX2zLAuI8wUfT1TweZwP4aD1Lpz+H6/zygTi
	 Iwb2G0mBMS64Q==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	torvalds@linux-foundation.org
Cc: anna@kernel.org
Subject: [GIT PULL] Please Pull NFS Client Updates for Linux 7.4
Date: Fri, 23 Oct 2026 17:11:49 -0400
Message-ID: <20261023211150.485518-1-anna@kernel.org>
X-Mailer: git-send-email 2.56.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Hi Linus,

The following changes since commit a90ee4305c4a5df72c11b31dacfdc76e00fcf78a:

  Linux 7.3-rc6 (2026-10-04 13:45:25 -0700)

are available in the Git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-7.4-1

for you to fetch changes up to ef30b3efb7e8bae94d790a6503a595e1051323e7:

  Merge commit '211cda4fdf33011cee39f8970c4625b207142d6b' of git://git.linux-nfs.org/projects/trondmy/linux-nfs.git into anna/linux-next (2026-10-21 14:26:57 -0400)

----------------------------------------------------------------
NFS Client Updates for Linux 7.4

New Features:
 * Modernize the direct I/O path
 * Size the LAYOUTGET reply buffer for wide flexfiles layouts
 * Flexfiles device notifications and caching for wide striped layouts
 * isolate mTLS client credentials by network namespace

Bugfixes:
 * Various localio, flexfiles, xprtrdma, and TLS fixes
 * Merged bugfixes from Trond that he was unable to send during the 7.3-rc cycle

Other Cleanups and Improvements:
 * Split up pNFS block layout and SCSI layout support

Thanks,
 Anna

----------------------------------------------------------------
Anna Schumaker (1):
      Merge commit '211cda4fdf33011cee39f8970c4625b207142d6b' of git://git.linux-nfs.org/projects/trondmy/linux-nfs.git into anna/linux-next

Benjamin Coddington (34):
      NFSv4.1/pnfs: suspend pNFS on NFS4ERR_TOOSMALL from LAYOUTGET
      NFSv4.1/pnfs: derive loga_maxcount from the LAYOUTGET reply buffer
      NFSv4.1/pnfs: retry LAYOUTGET with a larger reply buffer on NFS4ERR_TOOSMALL
      NFSv4.1/pnfs: treat an oversized LAYOUTGET reply as -EMSGSIZE
      NFSv4.1/pnfs: remember when a server needs a larger LAYOUTGET reply buffer
      NFSv4/flexfiles: allocate the per-mirror stripe array with kvzalloc_objs
      NFSv4/pnfs: Free the netid when draining a data-server address list
      NFSv4/flexfiles: Use the full 64-bit stripe_unit
      NFSv4/pnfs: bound the CB_NOTIFY_DEVICEID array count before allocating
      pNFS: Fix CB_NOTIFY_DEVICEID CHANGE to consume ndc_immediate
      NFSv4/flexfiles: Use the full 64-bit offset for read DS selection
      NFSv4/flexfiles: Bound page coalescing on the absolute stripe offset
      NFSv4/filelayout: Anchor page coalescing on pattern_offset
      NFSv4/flexfiles: Reference the device node across DS setup
      NFSv4/flexfiles: Carry the device node reference across each I/O
      NFSv4/flexfiles: Hold a device node reference for layoutstats encoding
      NFSv4/flexfiles: Make the pinned device node pointer RCU-managed
      pNFS: Add a reresolve_deviceid layout driver hook
      NFSv4/flexfiles: Implement in-place device re-resolve on CHANGE
      NFSv4: Dispatch CB_NOTIFY_DEVICEID CHANGE to an in-place refresh
      NFSv4/flexfiles: Honor ndc_immediate on CB_NOTIFY_DEVICEID CHANGE
      pNFS: Discard a GETDEVICEINFO reply that raced a CHANGE notification
      pNFS: Add deviceid reference query and collection walkers
      NFSv4/pnfs: Recover revoked layouts on a deleted deviceID
      NFSv4/pnfs: Confirm a deviceID delete via GETDEVICEINFO
      NFSv4/pnfs: Dispatch CB_NOTIFY_DEVICEID DELETE to race recovery
      NFSv4/pnfs: Grow the deviceid cache hash table
      NFSv4/pnfs: Re-home the data-server cache onto hash buckets
      NFSv4/pnfs: Key the data-server cache by its address set and version
      NFSv4/flexfiles: Add a dataserver_nconnect cap
      NFSv4/flexfiles: report the intended opnum when DS connection setup fails
      pNFS: allow layout drivers to cancel I/O to a single device
      NFSv4/flexfiles: only cancel I/O to a failed mirror instance
      NFSv4/flexfiles: fail I/O to the data server once a lock is lost

Chuck Lever (10):
      xprtrdma: Fix Write chunk payload corruption on a short reply header
      NFS: use TCP for MOUNT when xprtsec= selects TLS
      SUNRPC: reject a client-side TLS alert record that is not two octets
      SUNRPC: treat every client-side TLS error alert as fatal
      SUNRPC: fold xs_sock_process_cmsg() into its only caller
      NFS: name the init_nfs_fs() error labels
      NFS: allocate the .nfs keyring per network namespace
      SUNRPC: pass a keyring serial number to the TLS handshake
      NFS: name the namespace .nfs keyring in the x509 handshake
      NFS: add a key type that reveals the namespace .nfs keyring serial number

Jimmy Zuber (1):
      NFS: Fix stale negative cache on failed nfs_mkdir()

Jinpyo Lee (1):
      nfs/localio: pin UUIDs during global invalidation

Jérémy Jean (1):
      NFS: filelayout: calculate dense stripe width in 64 bits

Mike Snitzer (6):
      NFS/localio: fix nfs_local_dio_misaligned tracepoint
      NFS/localio: detect a short read or write before the iterator has moved
      NFS/localio: report the stability a DIO WRITE actually has
      pNFS/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS over the mdsthreshold hint
      pNFS/flexfiles: don't read through MDS when previous layout forbid it
      pNFS/flexfiles: don't reset to MDS for v4 error when previous layout forbid it

Pranjal Shrivastava (5):
      nfs: make nfs_page pin-aware
      nfs: track number of pinned pages in nfs_page
      nfs: introduce nfs_release_request_list helper
      nfs: migrate direct I/O to iov_iter_extract_pages
      nfs: introduce nfs_direct_extract_pages helper

Roberto Bergantinos Corpas (2):
      NFS: return DENIED in decode_lock_denied if we cannot decode owner
      nfs: set gencount on protocol-specific remove

Scott Mayhew (1):
      nfs: split up block layout and SCSI layout support

Tigran Mkrtchyan (4):
      nfs/flexfile: fix doc of nfs4_ff_layout_prepare_ds function
      nfsv4/pnfs: use the MDS authflavor for data server connections
      pNFS/flexfiles: make pg_init retry loops killable
      pNFS/flexfiles: don't report an interrupted DS connect as a DS error

Tim Menninger (1):
      xprtrdma: prevent disconnect feedback during endpoint teardown

Trond Myklebust (1):
      NFSv4: Fix a regression in the handling of CB_RECALL_ANY

Yongjian Mu (1):
      xprtrdma: trim head iovec when the payload arrives via a Write chunk

 Documentation/filesystems/nfs/index.rst   |   1 +
 Documentation/filesystems/nfs/keyring.rst |  69 ++++
 fs/nfs/Kconfig                            |  17 +-
 fs/nfs/blocklayout/Makefile               |   3 +-
 fs/nfs/blocklayout/blocklayout.c          | 119 +++++--
 fs/nfs/blocklayout/dev.c                  |  32 +-
 fs/nfs/callback_proc.c                    |  23 +-
 fs/nfs/callback_xdr.c                     |   9 +-
 fs/nfs/client.c                           |  17 +-
 fs/nfs/delegation.c                       |   3 +-
 fs/nfs/dir.c                              |  15 +-
 fs/nfs/direct.c                           | 139 ++++----
 fs/nfs/filelayout/filelayout.c            |  17 +-
 fs/nfs/filelayout/filelayoutdev.c         |  19 +-
 fs/nfs/flexfilelayout/flexfilelayout.c    | 519 +++++++++++++++++++++---------
 fs/nfs/flexfilelayout/flexfilelayout.h    |  48 +--
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 219 ++++++++-----
 fs/nfs/fs_context.c                       |   2 +
 fs/nfs/inode.c                            | 211 ++++++++----
 fs/nfs/internal.h                         |  34 +-
 fs/nfs/localio.c                          |  31 +-
 fs/nfs/netns.h                            |  14 +-
 fs/nfs/nfs3client.c                       |  10 +-
 fs/nfs/nfs3proc.c                         |   8 +
 fs/nfs/nfs4_fs.h                          |   5 +
 fs/nfs/nfs4client.c                       |  16 +-
 fs/nfs/nfs4proc.c                         | 141 ++++++++
 fs/nfs/nfs4state.c                        |  45 ++-
 fs/nfs/nfs4xdr.c                          |   5 +-
 fs/nfs/nfstrace.h                         |   5 +-
 fs/nfs/pagelist.c                         |  66 +++-
 fs/nfs/pnfs.c                             | 388 ++++++++++++++++++++--
 fs/nfs/pnfs.h                             | 102 +++++-
 fs/nfs/pnfs_dev.c                         |  30 +-
 fs/nfs/pnfs_nfs.c                         | 110 +++++--
 fs/nfs/proc.c                             |   8 +
 fs/nfs/read.c                             |   2 +-
 fs/nfs/write.c                            |   2 +-
 fs/nfs_common/nfslocalio.c                | 101 +++++-
 include/linux/nfs_fs_sb.h                 |   8 +
 include/linux/nfs_page.h                  |   8 +-
 include/linux/nfs_xdr.h                   |   2 +
 include/linux/nfslocalio.h                |  12 +
 include/linux/sunrpc/xprt.h               |   1 +
 net/sunrpc/xprtrdma/rpc_rdma.c            |  39 ++-
 net/sunrpc/xprtrdma/verbs.c               |   9 +-
 net/sunrpc/xprtsock.c                     |  70 ++--
 47 files changed, 2136 insertions(+), 618 deletions(-)
 create mode 100644 Documentation/filesystems/nfs/keyring.rst
