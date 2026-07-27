Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BC8363E316C
	for <linux-nfs@vger.kernel.org>; Mon, 27 Jul 2026 21:09:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785186586; cv=none; b=rYDelc3cJGoF9kIFAFDKJdyqKLdu7u0L1lHx8mR0edGA+qxPALJs29qhj1cxEkkHYzKuVFRbabCQ8UxJFFhdXVECJVOSclPAdWlvTm1FNTkP8K5t/ZVyqzdbrQmDeJA40EwZIuX4fiSTCV/JKfpjYyvlUSgKrFkjafA2CO9PpgI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785186586; c=relaxed/simple;
	bh=44HJ1ZKtQO+DOAXvpoOYO3Qn0n9E6w4H6cYIYXuO1k0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=QEgUJBB6YdYb10GL6/VbB2td+S+1C4bcsC7Wu40eTbvtPC+vwqpS8fPnOYBoTLp2lPj/Rw+2Zs0xNfITQPRSBtfbwjISHKawYGRI5yn1PHY8YUX8znvLuwwsXLFTv12WdPhgpFGnv0QzkO4VhjP0IFcy4+ZfKcDhCc7nIWE5lFs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Uo1GdC/x; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Uo1GdC/x"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6E4911F000E9;
	Mon, 27 Jul 2026 21:09:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785186584;
	bh=rAmHeX+iz1bYIKGpbmnHpLjHVl8Q8lDkQoGSYyksLjc=;
	h=From:To:Cc:Subject:Date;
	b=Uo1GdC/x2/2u774/wv5ZqP5Lj+UG3PCElWYXI38bXcS6KI4cTavM1xX4/2OXHSsxi
	 uMUMA7gkWyF4AxRXNg5GmO8FvVJNnpISQy+rmnPFT2Tn6BvY+uWhypXz+/9v1H2P9f
	 e3gNApYNm/M/efqxY2ShHxoojHqjO2NnB+eSYHnU/5Bt6gM2w5H09vn1WqiVkmEwvz
	 E9mhO3d9/zK4Xr0SyoHQc0rOa45MJ5laal672mU1sNemAvqGVKXVprwSgNPKwuiX6e
	 KkoDVRxTP/eZk2NN12mcXRxoTUMfhbuzK5EVEriNX07FKKiyUAXXiyT1WI6XL6QKd1
	 7rd6bQ9V0WHcw==
From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 0/6] nfs: NFSv4.2 client support for UNCACHEABLE_FILE_DATA and UNCACHEABLE_DIRENT_METADATA
Date: Mon, 27 Jul 2026 17:09:37 -0400
Message-ID: <cover.1785140181.git.snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This series adds Linux NFSv4.2 client support for two companion,
per-object "uncacheable" attributes that let a server advise the client
to stop caching state that changes faster than client caches can track:

  - UNCACHEABLE_FILE_DATA (FATTR4 87, draft-ietf-nfsv4-uncacheable-files
    [1]) -- a per-regular-file boolean: suppress caching of the file's
    data, both write-behind and read caching.

  - UNCACHEABLE_DIRENT_METADATA (FATTR4 88,
    draft-ietf-nfsv4-uncacheable-directories [2]) -- a per-directory
    boolean: retrieve directory-entry metadata (names and per-entry size
    and timestamps) from the server on each READDIR rather than serving it
    from the client's readdir cache.

Both are OPTIONAL, read-write booleans; the two are independent and apply
to disjoint object types (a regular file may carry 87, a directory 88).
This client honors a server-set attribute; it does not set either (that
is left to server/administrator policy).  The motivating deployments
expose a single namespace concurrently through NFSv4.2, NFSv3, and SMB,
plus server-side policy engines, so file data and directory contents can
change faster than a typical client cache lifetime -- producing stale
reads and read-modify-write "write holes" for file data, and stale
size/timestamp listings for directories.

For UNCACHEABLE_FILE_DATA, a marked regular file is opened O_DIRECT, which
suppresses read and write-behind caching and satisfies the spec's
durability invariant via the existing direct-I/O path.

For UNCACHEABLE_DIRENT_METADATA, readdir on a marked directory bypasses
the readdir cache and refetches from the server, forcing READDIRPLUS so
the per-entry attributes the attribute governs (size and timestamps) are
refreshed rather than served stale from the inode attribute caches.

Each attribute is requested only for the object type it applies to, since
a server must reject a query on any other type with NFS4ERR_INVAL.

The series is organized as:

  1/6  decode UNCACHEABLE_FILE_DATA, track per-exported-filesystem
       support, and record it on the inode.
  2/6  request UNCACHEABLE_FILE_DATA only for regular files.
  3/6  open uncacheable regular files O_DIRECT.
  4/6  decode UNCACHEABLE_DIRENT_METADATA, track per-exported-filesystem
       support, and record it on the inode.
  5/6  request UNCACHEABLE_DIRENT_METADATA only for directories.
  6/6  honor UNCACHEABLE_DIRENT_METADATA: refetch readdir (forcing
       READDIRPLUS) on a marked directory.

[1] https://datatracker.ietf.org/doc/draft-ietf-nfsv4-uncacheable-files/
[2] https://datatracker.ietf.org/doc/draft-ietf-nfsv4-uncacheable-directories/

Changes since v3:
 - Fix a regression that broke regular-file OPEN against any server that
   advertises UNCACHEABLE_DIRENT_METADATA (attr 88).  v3 placed attr 88 in
   the shared request bitmaps (nfs4_fattr_bitmap, nfs4_pnfs_open_bitmap),
   which are used verbatim as the OPEN "open_bitmap" -- a GETATTR that is
   masked only by the server's supported set and is not type-gated -- so
   every regular-file OPEN queried a directory-only attribute and the
   server answered NFS4ERR_INVAL, failing opens broadly.  Patch 4 no
   longer adds attr 88 to those bitmaps; patch 5 instead has
   nfs4_bitmap_copy_adjust() add it for directory targets (gated on server
   support).  attr 87 continues to ride the shared bitmaps: it is legal,
   and wanted, on a regular-file OPEN (to drive O_DIRECT).
 - Patch 2: close the same class of hole in the other direction --
   UNCACHEABLE_FILE_DATA (attr 87) requested on a directory via
   DELEGRETURN.  nfs4_update_changeattr_locked() (which only ever runs on
   directory inodes) was setting the file-only
   NFS_INO_INVALID_UNCACHEABLE_FILE_DATA bit, and nfs4_bitmask_set()
   translated it into a request for attr 87 with no object-type check;
   with directory delegation support, DELEGRETURN of a directory
   delegation would then query attr 87 on a directory and fail with
   NFS4ERR_INVAL.  Drop the bit from the directory-only aggregation and
   request attr 87 in nfs4_bitmask_set() only for regular files.
 - Patch 4: document at the inode recording site why the directory
   attribute needs no NFS_INO_INVALID_* cache-validity bit -- it is
   requested unconditionally for directories via the type gate, so it is
   refetched on every directory GETATTR and cannot go stale.
 - Commit-message tidy-ups (Link: tags, line wrapping); no other changes.

Changes since v2:
 - Patch 1 (nfs4_fattr_bitmap): place FATTR4_WORD2_UNCACHEABLE_FILE_DATA
   as the first, unconditional word2 entry and OR in
   FATTR4_WORD2_SECURITY_LABEL under CONFIG_NFS_V4_SECURITY_LABEL, so the
   word2 initializer no longer begins with a stray '|' (which fails to
   build) when CONFIG_NFS_V4_SECURITY_LABEL is disabled.

Changes since v1:
 - Drop the v1 1/4 xdrgen patch that added Documentation/sunrpc/xdr/
   nfs4_2.x and a generated <linux/sunrpc/xdrgen/nfs4_2.h>.  Instead
   open-code FATTR4_UNCACHEABLE_FILE_DATA in <linux/nfs4.h> alongside the
   other hand-defined FATTR4 protocol-extension constants, and drop the
   generated NFS4_fattr4_uncacheable_file_data_sz macro (its single XDR
   word is folded into nfs4_fattr_value_maxsz).
 - Store the per-inode flag as a bool bitfield (bool
   uncacheable_file_data : 1) and simplify the sites that record it.
 - Remove stray blank lines introduced in nfs4_atomic_open() and the
   nfs4trace.h attribute-flags list.
 - Add client support for the companion UNCACHEABLE_DIRENT_METADATA
   attribute, attr 88 (patches 4-6).

Mike Snitzer (5):
  nfs4.2: request UNCACHEABLE_FILE_DATA only for regular files
  nfs4.2: open UNCACHEABLE_FILE_DATA files with O_DIRECT
  nfs4.2: add UNCACHEABLE_DIRENT_METADATA attribute support
  nfs4.2: request UNCACHEABLE_DIRENT_METADATA only for directories
  nfs4.2: honor UNCACHEABLE_DIRENT_METADATA by refetching readdir

Tom Haynes (1):
  nfs4.2: add UNCACHEABLE_FILE_DATA attribute support

 fs/nfs/dir.c            | 22 ++++++++++--
 fs/nfs/inode.c          | 39 ++++++++++++++++++--
 fs/nfs/nfs4file.c       |  2 ++
 fs/nfs/nfs4proc.c       | 80 ++++++++++++++++++++++++++++++++++++++---
 fs/nfs/nfs4trace.h      |  4 ++-
 fs/nfs/nfs4xdr.c        | 64 ++++++++++++++++++++++++++++++++-
 fs/nfs/nfstrace.h       |  4 ++-
 include/linux/nfs4.h    | 18 ++++++++++
 include/linux/nfs_fs.h  |  5 +++
 include/linux/nfs_xdr.h | 11 +++++-
 10 files changed, 235 insertions(+), 14 deletions(-)

-- 
2.47.3

