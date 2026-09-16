Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 67DDB36F8EB
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 00:41:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789519308; cv=none; b=NN0fw+zt+2R8Ty/gPO3hA6j9IAp0TY5WkSemPZAaCASdIEvIeKTl1sufZzsvHsDzXX/3Du9489ikG2mweKZHysq6uEFVUPwAm4ZkLNxUr1hMTVYxyu8V47HgrrWhZxP2FV3W7oFKR/tvjafyZTvEywdqelbGjn3pe2JE9q42tso=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789519308; c=relaxed/simple;
	bh=9mk6T7NPVNl+GgGoDgpoTaL8ndwtCqcPw8LPQpUkruw=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=efLu5Ht5zh+Fwg7pC2YXjrTamJ7AXZ5cfpIXQOW99vEft0vDAq0niFuBfzIshKhGpkEYNTvXabD7X6L+KSSZueRPOgYArZNm+UG6QdD0MhWx5ACRcwtOcbwje8dhdyHwqejAIq+62Ovy/3qOTEIHdJKtDdGPPfwgFCuvHFJN8Q8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ahuMy69u; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ahuMy69u"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 515CD1F000FF;
	Wed, 16 Sep 2026 00:41:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789519302;
	bh=9cGvql3ETKdWeJCER5wHBc6lMrrcCAYUzn6zW5Fzc2E=;
	h=From:To:Cc:Subject:Date;
	b=ahuMy69ukImwWZHIHLcL04n/GIE0md2hx5fQHGxItegr7djiFVMIuVgS4AzYKkC5D
	 KF86eZ4vWEqpT5xyJ9KToEDn/3Mhgswd7Mrg4iuTIkkgeTWj2OZfQU46aTI660pe04
	 mn0dDjZY1wlfOKvIJTqNlT6T0euOTi2hzQivd9dwSTx01Mj0YVHKEHShu1Ji+5TD4F
	 QxnGl91gjjMgav+mHZet11vzCxHQhH5Djx3YGhD5S1zgu1wpyudEokElr2xz9zj9H7
	 2j00wubwK09XMZT9gG7y7Uz8BZPHj1fvyHkTCLt39534AXkzx7uQFYwjAyuc5Tb4t2
	 c01SCQCLC11Rg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 00/27] Convert server NFSv2 XDR layer to xdrgen
Date: Tue, 15 Sep 2026 20:41:30 -0400
Message-ID: <20260916004141.141884-1-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The series replaces NFSD's NFSv2 hand-written XDR encoders and
decoders with code that was generated mechanically from the RPC
language definition of NFSv2.

The eventual goal is to convert as much of NFSD's XDR layer to
mechanically-derived code as possible to reduce the risks of human
error and memory safety vulnerabilities on the front-line between
network and internal implementation.

Following this series, the next conversion steps are: NFSv3,
NFS_ACLv2, NFS_ACLv3.

I've tested this with some simple fstests runs on NFSv2. No new
issues were found.


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

