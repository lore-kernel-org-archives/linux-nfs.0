Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 32A87517BDF
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576142; cv=none; b=hCXQm41/YqmJT8gawTgHxNGmmdoWetR+dIjmb31d/JpaHiMv/PwMJ+2+Z8YsrDIi/yug7es4i2a/UFYeLPymYrx14bs6J8umAL7f1wl1rX4SA4q6RS0E1dUrg1F27P3ym9FtHzKRJ+J6ccnYr3wnpY5fZL2pKS6vPQr/KM99XY4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576142; c=relaxed/simple;
	bh=7ZwXSn5qS+ma1/TnHL+JZYCKBYmgYp/ytzu8bZJg6xo=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Pe+HEI1vt0da3YpQH0uzlFK1BFqJIAb9wMtiUOFHcyHA496AfKHeikv0q48WiRLhdVQFr4F1QfKVSEhKrpSINPyd416vnvCeRW5YYgf5CLXIDIFVGcKWDMWmUCFcysIDn4NJkyOs4/DY/muf405ZosxNumSosUpSIS3amcZuqis=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ihZEGOLG; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ihZEGOLG"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F16F31F00893;
	Wed, 16 Sep 2026 16:28:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576140;
	bh=ldKl4GS5/Gpfu5euB2e9qen9AxsyZbuRplOXxPAzqUQ=;
	h=From:To:Cc:Subject:Date;
	b=ihZEGOLGK1dIgSqKpU5O0bwNWMwu+VyL1mFIi/MkiPSLga1zjpH0dz9crP8xjkZqH
	 TUxDsNbzdpS4kcEVlxT6NTdQde4EVUD1VPirkxBbSWaV09KsCoawT6bByVjF5DVp9y
	 pBdVxPGXg4RbRz6uKDH9H752wmr1jl5L1MVOn8pGstFI/4xHQKLzfaq90RtVbuD/9a
	 Jy/DLtgzRXQCsbGhU0KoqHcb/xBcv1E+6HQ+WXe25Zqp5SFEzefLSr7qyMehnVFqyC
	 3Cn4v0vFSGQGU1R0mrJ58TbVwoFkBaXuC97wUJH0sZr+ODfQJwie3YBZ3+PyeC60pc
	 upxs1+OHYzrzQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 00/27] Convert server-side NFSv2 XDR to use xdrgen
Date: Wed, 16 Sep 2026 12:28:29 -0400
Message-ID: <20260916162859.2051-1-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Replace NFSD's NFSv2 XDR encoders and decoders with code that is
mechanically generated directly from the NFSv2 RPC language
specification.

The benefits for NFSv2 are marginal. When we eventually convert
newer NFS versions to use xdrgen, I expect a reduction in human
coding errors, improved spec compliance, and better memory safety
for those more complex NFS programs.

These patches have been lightly tested with fstests run against an
xfs export.

Chuck Lever (27):
  Documentation: Add the RPC language description of NFSv2
  NFSD: Add infrastructure for generating NFSv2 XDR encoders and
    decoders
  NFSD: Use xdrgen-generated NFSv2 protocol definitions
  NFSD: Remove '#include "xdr.h"' from fs/nfsd/xdr3.h
  NFSD: Relocate the NFSv2 XDR storage union into nfsproc.c
  NFSD: Use xdrgen XDR functions for the NFSv2 NULL procedure
  NFSD: Use xdrgen XDR functions for NFSv2 GETATTR procedure
  NFSD: Use xdrgen XDR functions for NFSv2 SETATTR procedure
  NFSD: Use xdrgen XDR functions for the NFSv2 ROOT procedure
  NFSD: Use xdrgen XDR functions for the NFSv2 LOOKUP procedure
  NFSD: Use xdrgen XDR functions for NFSv2 READLINK procedure
  NFSD: Use xdrgen XDR functions for NFSv2 READ procedure
  NFSD: Use xdrgen XDR functions for the NFSv2 WRITECACHE procedure
  NFSD: Use xdrgen XDR functions for NFSv2 WRITE procedure
  NFSD: Refactor nfsd_proc_create()
  NFSD: Use xdrgen XDR functions for NFSv2 CREATE procedure
  NFSD: Use xdrgen XDR functions for the NFSv2 REMOVE procedure
  NFSD: Use xdrgen XDR functions for the NFSv2 RENAME procedure
  NFSD: Use xdrgen XDR functions for the NFSv2 LINK procedure
  NFSD: Use xdrgen XDR functions for NFSv2 SYMLINK procedure
  NFSD: Use xdrgen XDR functions for NFSv2 MKDIR procedure
  NFSD: Use xdrgen XDR functions for NFSv2 RMDIR procedure
  NFSD: Use xdrgen XDR functions for the NFSv2 STATFS procedure
  NFSD: Use xdrgen XDR functions for NFSv2 READDIR arguments
  NFSD: Add a streaming directory reader
  NFSD: Refactor NFSv2 directory cookie encoding
  NFSD: Use xdrgen XDR functions for NFSv2 READDIR results

 Documentation/sunrpc/xdr/nfs2.x    |  254 +++++
 fs/nfs_common/common.c             |    5 +-
 fs/nfsd/Makefile                   |   15 +-
 fs/nfsd/nfs2acl.c                  |    2 +-
 fs/nfsd/nfs2xdr_gen.c              | 1079 +++++++++++++++++++
 fs/nfsd/nfs2xdr_gen.h              |   46 +
 fs/nfsd/nfs3xdr.c                  |    2 +
 fs/nfsd/nfsd.h                     |    2 -
 fs/nfsd/nfserr.h                   |    2 +-
 fs/nfsd/nfsfh.h                    |    5 +
 fs/nfsd/nfsproc.c                  | 1574 +++++++++++++++++++---------
 fs/nfsd/nfsxdr.c                   |  605 +++--------
 fs/nfsd/vfs.c                      |  239 +++--
 fs/nfsd/vfs.h                      |   40 +
 fs/nfsd/xdr.h                      |  167 +--
 fs/nfsd/xdr3.h                     |    3 +-
 include/linux/nfs_common.h         |    4 +-
 include/linux/sunrpc/xdrgen/nfs2.h |  298 ++++++
 18 files changed, 3121 insertions(+), 1221 deletions(-)
 create mode 100644 Documentation/sunrpc/xdr/nfs2.x
 create mode 100644 fs/nfsd/nfs2xdr_gen.c
 create mode 100644 fs/nfsd/nfs2xdr_gen.h
 create mode 100644 include/linux/sunrpc/xdrgen/nfs2.h

-- 
2.55.0

