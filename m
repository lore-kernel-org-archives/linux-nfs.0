Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 362BA3D9665
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 17:10:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790269815; cv=none; b=OSwyAzzY4qJ1yf3fkPhxdrvlNbkweiw81v7XtrJPbUPH29qdRlQ/Jg4ofKVMBSeNk09CNy4xbdiBqei2rwsDjmJBJq8mKYGpwTIxX5ZcO0nmmtwVcKPs0NMiJrqqos4PSNsgCtRLGpG/yUx+h52L5i01rl37ia3MJy9+ANEtFuU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790269815; c=relaxed/simple;
	bh=UhL8+Ub5b0V/7p/C7Glcr3QbLYNsFBPPX+nDHYhK/CY=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=a7fAUhuuiXgWvqYOi2z8roadi2LnapBbybD75lK3RSw8yLyK2EhRmc1B59In4TRKeGBxa0KYP/OHRyQTc5g1ktbrReekNGsGmxV6/04PyrAyTxxF1x12yQm4vWuPRIXCancy6V20QMgkalJnQcGzuKlz1xttc85NC252+kVpBxQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jkYRwVgq; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jkYRwVgq"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 839251F000FF;
	Thu, 24 Sep 2026 17:10:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790269814;
	bh=thVfsWDfvYkeVTgs6LDOVfS7e6bdcXDsmggzaxc9r60=;
	h=From:To:Cc:Subject:Date;
	b=jkYRwVgqAn9riLdyt4S8HRZTaFgBiWfMwfPFHb8u+C04vbrdHMmdrVngHmfmUV47N
	 Lz8Cct1B4sdXxacnGWzqVPgHSwJbMFpQl7a7IBWk16cOOK6JccGoCe/584hE8zmubt
	 26kmvABgK/Ip525wD4NTnswGXgOQAqwogtkQCk91P2e6sqcRnmCGR0/tq+7VnMgAzf
	 8EQGMcqMOxHDfU9fc40dkunHRLf2C6LycPEmquXXN31+0Z1YyJYunamAsoVtlUSlp4
	 7hZb8rcalsgINVby3To2sYbYsV39cVyK1ktD0irStzovpYBJKe0nUlFjkOEG9GBThn
	 8JG9z8mGjFc3A==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 00/33] Convert server-side NFSv3 XDR to use xdrgen
Date: Thu, 24 Sep 2026 13:09:39 -0400
Message-ID: <20260924171012.3978-1-cel@kernel.org>
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
in human coding errors, improved spec compliance, and better memory
safety for those more complex NFS programs.

Changes in v2:
- Include the generated NFSv3 header directly in nfsfh.c and nfsctl.c.
- Remove the unused struct nfsd3_createargs in the MKDIR patch.
- Regenerate the READDIR and READDIRPLUS result decoders.
- Drop the decode-hook stubs the regenerated decoders no longer call.
- Link to v1: https://lore.kernel.org/linux-nfs/20260923132811.244160-1-cel@kernel.org/

Chuck Lever (33):
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

 Documentation/sunrpc/xdr/nfs3.x    |  839 ++++++
 fs/nfsd/Makefile                   |   15 +-
 fs/nfsd/nfs2acl.c                  |   41 +-
 fs/nfsd/nfs3acl.c                  |   12 +-
 fs/nfsd/nfs3proc.c                 | 2545 +++++++++++++------
 fs/nfsd/nfs3xdr.c                  | 1369 +++-------
 fs/nfsd/nfs3xdr_gen.c              | 3808 ++++++++++++++++++++++++++++
 fs/nfsd/nfs3xdr_gen.h              |   82 +
 fs/nfsd/nfsctl.c                   |    2 +-
 fs/nfsd/nfserr.h                   |    2 +-
 fs/nfsd/nfsfh.c                    |    2 +-
 fs/nfsd/vfs.c                      |   76 +-
 fs/nfsd/xdr3.h                     |  300 +--
 include/linux/nfs3.h               |    3 -
 include/linux/sunrpc/xdrgen/nfs3.h | 1092 ++++++++
 15 files changed, 8021 insertions(+), 2167 deletions(-)
 create mode 100644 Documentation/sunrpc/xdr/nfs3.x
 create mode 100644 fs/nfsd/nfs3xdr_gen.c
 create mode 100644 fs/nfsd/nfs3xdr_gen.h
 create mode 100644 include/linux/sunrpc/xdrgen/nfs3.h

base-commit: 21c66e2ece97c0ac8139b44051d565b29574f821
-- 
2.55.0
