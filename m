Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1FAF131715B
	for <linux-nfs@vger.kernel.org>; Tue, 30 Jun 2026 23:42:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782862980; cv=none; b=e8lxyIejhnnOh4CH3Jv4gj+pGaimjW+ieh0B6HD8VU9YzYgmGmjSsfa4oxYR5ucBvvW/LfVkciyq6Ml+7TIlL1VwFC3NXsus0Y1wx0TmuGzZdUfKXJeHBl4HaAx1sJx7z6qjsx1i1FiB7sY6PWTN+oYP/m0dzfEISZcJkbd4N5I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782862980; c=relaxed/simple;
	bh=qcab9m7jtOp8vGOo5dZxMilNAJzZamsmLwaRrJtWaCI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=X9l0QCgJGzDNv9ynYSYprsj9IWf+d28jZr0a6yooEPPew+80fnVFHOaWmxceLiUGmkSnKU63lm/jNguOUe+pFzF1ypA0CrlI5zpJSqFmvkwOo/gsmSJjOs0dCBOnkwUK4LzgLXuaNcoZBF/P2+DNv8WI+sys8HBh9SsYXYC+g1U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ISobaWNF; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ISobaWNF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 819CE1F000E9;
	Tue, 30 Jun 2026 23:42:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782862978;
	bh=pyQqGiWcQBpur56JQ0rAAFxAZ4yjkEVd9AlpwC5JOE4=;
	h=From:To:Cc:Subject:Date;
	b=ISobaWNFHa7zDN1zglivk5P8Ib8MaWg1+OjNdK+dPvseSVI8+DbYtllCX+PjU9v8z
	 Z2Dp3F8Ikx6xcSbg+H7rIatxhrA1w29dB1kpctKWM4t9mSqTybe0wuTzdiaNastfk0
	 +o9MGzt54HQBmKS1qnF6SMiPRw42Da9oyfLabSWRasguhyyBunxRW52RVGqKyd8LzY
	 edQqIxsbl7kuHid7DG84vTi1h23n3Afec9ddzV5ufQ9oXCOzM085zaytcejy8wZGaB
	 GNVJBVtJWHcS/FkgT0/0JUgBQDU7Lq4JKzB3uFVphpdCrjYy87zZc/wUUNmP+5yhBU
	 o07O9eMOGvzYg==
From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Tom Haynes <loghyr@hammerspace.com>,
	Chuck Lever <cel@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/6] nfs: NFSv4.2 client support for UNCACHEABLE_FILE_DATA and UNCACHEABLE_DIRENT_METADATA
Date: Tue, 30 Jun 2026 19:42:51 -0400
Message-ID: <20260630234257.5615-1-snitzer@kernel.org>
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

 fs/nfs/dir.c            | 22 ++++++++++++--
 fs/nfs/inode.c          | 32 ++++++++++++++++++--
 fs/nfs/nfs4file.c       |  2 ++
 fs/nfs/nfs4proc.c       | 67 ++++++++++++++++++++++++++++++++++++++---
 fs/nfs/nfs4trace.h      |  4 ++-
 fs/nfs/nfs4xdr.c        | 64 ++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfstrace.h       |  4 ++-
 include/linux/nfs4.h    | 18 +++++++++++
 include/linux/nfs_fs.h  |  5 +++
 include/linux/nfs_xdr.h | 11 ++++++-
 10 files changed, 215 insertions(+), 14 deletions(-)

-- 
2.47.3

