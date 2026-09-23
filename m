Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 96CBB52ED5D
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 13:28:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790170094; cv=none; b=MwYGcHgVgxp7DrUOYtRvX++ZO7DPQtfwuPvHhK69NHmD/k4MT6nxzF4vyUu1DPBCcyI0d4NPNPgk12hJWpZjsZZ//LPFHq5oDMP0GHwbt9QArL0XWWTqpa/YxjcIT9LB30b2RogzLtP9x4JqPM960bODhT0H30zsnzG4zIlRtcw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790170094; c=relaxed/simple;
	bh=KS/E8GUHmWnB2sK4Z9s+X78Z5fLNg7YlQndJ4TkAo9g=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ApCVWgVDtkXDccLRyklBXzeYT17XFdHabz1wgySlc1EvGUAhmQ4rBjCI8b5bI/5JKO2ae7RNAZmKeYvCqiqvKy3qzrwFAn9JpfYibp/2/3/kyXOK4GX3qt7l/3aVnDmLxJJsHSh30LCbAgEESyLDcYRDc3Dwhc0xgADZuc/FzpY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OPbxzt/Q; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OPbxzt/Q"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D964C1F000FF;
	Wed, 23 Sep 2026 13:28:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790170093;
	bh=qYICDR5dqtZTe8VbucIq/nvkzEI/WY2dGly5ynaIaik=;
	h=From:To:Cc:Subject:Date;
	b=OPbxzt/QDgvGEyj98N8ldVXaf4VRmwrL055THrayDqeuUL2IsGvgCd6ELKiuEfBoo
	 a9ri2mN5HaMhm4dVc38pSEokHlSBSx1WasJSZHkZVWYMbkz4ab8XMmmxqsevwPFVgs
	 7QkfsHTxcXQIRprDAOtC0awz4xUGnl+lw1u3xYnZDE5HwGUgdNJItpljhYlkGT98u3
	 c5o4B1v3Ls8YG7Jq2Rkpj2aLMBxhYeY49w1M7M/xgyFbslDCSPg5iPMAVhJU/KqINc
	 XCZNPDQTc4GPV861S7Rbmh+6hUD91WJYwFGlywcjbDcXHbFqbSHPNnanYaxuNIhgBZ
	 lFUYOMEFcmIOA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 00/33] Convert server-side NFSv3 XDR to use xdrgen
Date: Wed, 23 Sep 2026 09:27:38 -0400
Message-ID: <20260923132811.244160-1-cel@kernel.org>
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
 fs/nfsd/nfs3proc.c                 | 2545 ++++++++++++------
 fs/nfsd/nfs3xdr.c                  | 1391 +++-------
 fs/nfsd/nfs3xdr_gen.c              | 3862 ++++++++++++++++++++++++++++
 fs/nfsd/nfs3xdr_gen.h              |   82 +
 fs/nfsd/nfsctl.c                   |    1 -
 fs/nfsd/nfserr.h                   |    2 +-
 fs/nfsd/nfsfh.c                    |    1 -
 fs/nfsd/vfs.c                      |   76 +-
 fs/nfsd/xdr3.h                     |  293 +--
 include/linux/nfs3.h               |    3 -
 include/linux/sunrpc/xdrgen/nfs3.h | 1092 ++++++++
 15 files changed, 8104 insertions(+), 2151 deletions(-)
 create mode 100644 Documentation/sunrpc/xdr/nfs3.x
 create mode 100644 fs/nfsd/nfs3xdr_gen.c
 create mode 100644 fs/nfsd/nfs3xdr_gen.h
 create mode 100644 include/linux/sunrpc/xdrgen/nfs3.h

-- 
2.55.0

