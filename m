Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0E2914457AC
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 22:03:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791842613; cv=none; b=WS2njJ3LrXZWSyd4zwQueeCjExI+cxzgbqU72mFfyKvkpfE/nZW2PTC93mpxqig1zj4QNoAYHkOcmwJ+ab9ilXnJ2ec+WHuEG6qJ6W393bE9ozd3sXESslEIwKYxQFUBMNoi7VmbcKon1AVEwwfLnqxW13Wn6grxgUD1mYbqv00=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791842613; c=relaxed/simple;
	bh=Z6LMWilYpaBz4/gcmHie33rByqb/zY+PbnlxT1hpNaA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=pq2bOfbKrIUXCs/5l92VXjHgowDNGUXkj4vScJ9QCGd9lTeO2vb8GyUjKRAgc6EVkS8zXv0UbS9OALGRJzFaSKO3Gpf4lPm3JvWa/6AqLQ/Hoo6gYCV9k9l81VmFeySUj9zon6PsqVR7IEIeZfZLHmWLWovNKiO86bMTreVyeXw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iV51jK6Y; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iV51jK6Y"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1EA861F0089B;
	Mon, 12 Oct 2026 22:03:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791842611;
	bh=zlEr/CRYQCcsnCB3R7e+2wg1Y2XcV9o3EFjbmLm3O3E=;
	h=From:To:Cc:Subject:Date;
	b=iV51jK6YBvYhpw59ivn7x7oWEyK05GUhK1EcKLoFCA7zU9GCghOOER92EcUr/Gy8G
	 ME4jkRX9fP+sTr+dqTjKP7uS5JKgDjEizKYDbQj3S2rPneJlbrYFOsATcHWj5CJOzD
	 wttQDsu1i8vIXUiQ5qKOtxlJYFBmaxjwLOkpwfaqETwG1D+JQxC7OPCM+BqXHoPVtw
	 Byi6olS1of0D8pNDe1KHnWm7nhB51hIvt6gLHDzt+YqwWiAibTdITXN5Q4qJ/bMafS
	 OhpAKMBm9aWj3G9FgYxPSP0xvsDyn4RoNHY14q9MRzlvep8b97bF9pn0rW/QwY6EB9
	 Ljy/peSqXTxCQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 00/34] Convert server-side NFSv3 XDR to use xdrgen
Date: Mon, 12 Oct 2026 18:02:55 -0400
Message-ID: <20261012220329.309998-1-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Replace NFSD's NFSv3 XDR encoders and decoders with code that is
mechanically generated directly from the NFSv3 RPC language
specification. Unlike NFSv2, where there are at least two
incomplete language specifications and much lore, nfs3.x here is
based closely on RFC 1813.

As we convert newer NFS versions to use xdrgen, I expect a reduction
in human coding errors, improved spec compliance, quicker implement-
ation of new protocol, and better memory safety for the more complex
NFS procedures.

Changes in v3:
- Copy the SYMLINK target with nfsd_symlink_target(), moved into vfs.c.
- Add a patch removing the now-unused svc_fill_symlink_pathname().
- Reject a READDIRPLUS entry on its minimum size before the lookup.
- Drop the pr_warn_once() for an unexpected file type in GETATTR.
- Explain why a late readdir host error is not reported as the status.
- Write "committed", not "on the wire", in the first-batch patch.
- Link to v2: https://lore.kernel.org/linux-nfs/20260924171012.3978-1-cel@kernel.org/

Changes in v2:
- Include the generated NFSv3 header directly in nfsfh.c and nfsctl.c.
- Remove the unused struct nfsd3_createargs in the MKDIR patch.
- Regenerate the READDIR and READDIRPLUS result decoders.
- Drop the decode-hook stubs the regenerated decoders no longer call.
- Link to v1: https://lore.kernel.org/linux-nfs/20260923132811.244160-1-cel@kernel.org/

Chuck Lever (34):
  NFSD: Report a first-batch readdir error in the reply status
  Documentation: Add the RPC language description of NFSv3
  NFSD: Add infrastructure for generating NFSv3 XDR encoders and
    decoders
  NFSD: Replace nfs3.h with nfs3xdr_gen.h
  NFSD: Replace the nfsd3_createres macro
  NFSD: Relocate the NFSv3 XDR storage union into nfs3proc.c
  NFSD: Use xdrgen XDR functions for the NFSv3 NULL procedure
  NFSD: Use xdrgen XDR functions for NFSv3 GETATTR procedure
  NFSD: Use xdrgen XDR functions for NFSv3 SETATTR procedure
  NFSD: Use xdrgen XDR functions for the NFSv3 LOOKUP procedure
  NFSD: Use xdrgen XDR functions for NFSv3 ACCESS procedure
  NFSD: Use xdrgen XDR functions for NFSv3 READLINK procedure
  NFSD: Use xdrgen XDR functions for NFSv3 READ procedure
  NFSD: Use xdrgen XDR functions for NFSv3 WRITE procedure
  NFSD: Use xdrgen XDR functions for NFSv3 CREATE procedure
  NFSD: Use xdrgen XDR functions for NFSv3 MKDIR procedure
  NFSD: Use xdrgen XDR functions for NFSv3 SYMLINK procedure
  NFSD: Use xdrgen XDR functions for NFSv3 MKNOD procedure
  NFSD: Use xdrgen XDR functions for the NFSv3 REMOVE procedure
  NFSD: Use xdrgen XDR functions for the NFSv3 RMDIR procedure
  NFSD: Use xdrgen XDR functions for the NFSv3 RENAME procedure
  NFSD: Use xdrgen XDR functions for the NFSv3 LINK procedure
  NFSD: Use xdrgen XDR functions for the NFSv3 FSSTAT procedure
  NFSD: Use xdrgen XDR functions for the NFSv3 FSINFO procedure
  NFSD: Use xdrgen XDR functions for the NFSv3 PATHCONF procedure
  NFSD: Use xdrgen XDR functions for the NFSv3 COMMIT procedure
  NFSD: Use xdrgen XDR functions for NFSv3 READDIR arguments
  NFSD: Use xdrgen XDR functions for NFSv3 READDIRPLUS arguments
  NFSD: Refactor NFSv3 directory cookie encoding
  NFSD: Refactor NFSv3 directory entry encoding
  NFSD: Split struct nfsd3_readdirres
  NFSD: Use xdrgen XDR functions for NFSv3 READDIR results
  NFSD: Use xdrgen XDR functions for NFSv3 READDIRPLUS results
  SUNRPC: Remove svc_fill_symlink_pathname()

 Documentation/sunrpc/xdr/nfs3.x    |  839 ++++++
 fs/nfsd/Makefile                   |   15 +-
 fs/nfsd/nfs2acl.c                  |   41 +-
 fs/nfsd/nfs3acl.c                  |   12 +-
 fs/nfsd/nfs3proc.c                 | 2541 +++++++++++++------
 fs/nfsd/nfs3xdr.c                  | 1374 +++-------
 fs/nfsd/nfs3xdr_gen.c              | 3808 ++++++++++++++++++++++++++++
 fs/nfsd/nfs3xdr_gen.h              |   82 +
 fs/nfsd/nfsctl.c                   |    2 +-
 fs/nfsd/nfserr.h                   |    2 +-
 fs/nfsd/nfsfh.c                    |    2 +-
 fs/nfsd/nfsproc.c                  |   22 -
 fs/nfsd/vfs.c                      |  105 +-
 fs/nfsd/vfs.h                      |    1 +
 fs/nfsd/xdr3.h                     |  300 +--
 include/linux/nfs3.h               |    3 -
 include/linux/sunrpc/svc.h         |    3 -
 include/linux/sunrpc/xdrgen/nfs3.h | 1092 ++++++++
 net/sunrpc/svc.c                   |   50 -
 19 files changed, 8052 insertions(+), 2242 deletions(-)
 create mode 100644 Documentation/sunrpc/xdr/nfs3.x
 create mode 100644 fs/nfsd/nfs3xdr_gen.c
 create mode 100644 fs/nfsd/nfs3xdr_gen.h
 create mode 100644 include/linux/sunrpc/xdrgen/nfs3.h

-- 
2.55.0

