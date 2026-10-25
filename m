Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793050578;
	b=H9hMjprzj7PhNfD0b/czQ5NvXbWXx37Tx6mIfgcagGN1WbUJUCU5j2Fqc1HVgpOSVKCQ
	 Cx9wAsfQlly8NU8jiXt6jxHb16HD6iw/ETL961N+aX1B9tOpt2S7RavgEhxHMHSmDx80m
	 9KzOlQsB5IQcwMPNrsobg+OMMZQpuaveN93fnApnoYjZSUN2LK8b5+sUmf5bKFt6/71J7
	 dw7EA5vKGFqBH4QjdWCK+U+/POjbImpqF9x4UuQUJI5hAV/xDItCosczQ7Aj/Wn7HQ0kC
	 J8Ks9RNbdqEW/5rTq2z/ePknsgH2bBB1aD2ayv+ZbL88NY3s3qT+l8XSsMPQ4ENaWaw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793050578;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=YuAdcjrjSwETmW4PmJxoBaUdM38ukqydHIFaB7wWNM8=;
	b=WxUgMXf5TUOA3zGs+zNNpSrlBY8mBsRZ/GQ7pF/NhdwKmlP5YPdIhdIpSoXM55WDXpSP
	 YkeZG5oRe/N86ORxG2qRRUCFoa+wpoKTVvrcW9FwdrE/Bm3FKO8ujkDdWtckFFQ6atGGf
	 ooa79IKnJr5y9YHEO38lZA6uGylgHh7hbTRmjZV5uoHs0jZlamdU9SQ8JTVOIEutKyo7g
	 m7kdUy+ResvT8OHQBPL2rP7TwjdMAjTEwvIWMkGq5apQXmkfwxtrGDqNjmysYJdMYicac
	 VEnjjvZ/a9OdPIECCs3IuuzVls/SniGh/a4axBr+42AzANKNf7vPO9nDb0e6SUP9f4Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eax2HsYe;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B46E4606A31F
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 21:36:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eax2HsYe
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 81B251F01825;
	Mon, 26 Oct 2026 21:36:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793050577;
	bh=YuAdcjrjSwETmW4PmJxoBaUdM38ukqydHIFaB7wWNM8=;
	h=From:To:Cc:Subject:Date;
	b=eax2HsYeL5m8BB5lpuhmBaYfK6ZEHcao1aztqcrVoQSc86+BFXgDy3NopfAiK5LHa
	 8Z26qaQ2ttJsrYSrdZmFLnz9vlwtLWAXXzOBn6IUwDUl19BitBBq2Jsh9m39u+9ebc
	 R/RTLSdYHm/IPF04sdBUzGelnF+S4jVaB14EHPzpmxiuU5287AejY0ydjA6973dx+9
	 RK83VnUifOjSmRDAe7HUYcZM0u4AWGiYXxiUBlNuVaBU8oiBMZDywPEJXWPbBOW8sL
	 qAnRUNg9ZNx0StXEVzz38PjCs2rc1Jl+du8jlkdw2/6azxgaP2zj9ClsMGyrwRjbTW
	 qOGin2rxG68sw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 00/13] Convert server-side NFS_ACLv3 XDR to use xdrgen
Date: Sun, 25 Oct 2026 11:16:09 -0400
Message-ID: <20261025151622.141025-1-cel@kernel.org>
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
Content-Transfer-Encoding: 8bit

Replace NFSD's NFS_ACLv3 XDR encoders and decoders with code that is
mechanically generated from the protocol's RPC language description.
No RFC defines NFS_ACL. The description in nfs_acl3.x is copied from
draft-ietf-nfsv4-nfs-acl.

Chuck Lever (13):
  Documentation: Add the RPC language description of NFS_ACLv3
  NFSD: Add infrastructure for generating NFS_ACLv3 XDR encoders and
    decoders
  NFSD: Remove '#include "xdr3.h"' from nfs3acl.c
  NFSD: New NFS_ACLv3 status codes
  NFSD: Use xdrgen XDR functions for the NFS-ACL v3 NULL procedure
  NFSD: Implement NFS-ACL v3 ACL encoding and decoding with xdrgen
  NFSD: Use xdrgen XDR functions for the NFS-ACL v3 GETACL procedure
  NFSD: Use xdrgen XDR functions for the NFS-ACL v3 SETACL procedure
  NFSD: Map every NFS_ACLv3 reply status into aclstat3
  NFSD: Remove the hand-coded XDR helpers for the NFS_ACLv3 procedures
  NFS: Move NFSACL_MAXPAGES into fs/nfs/nfs3_fs.h
  NFSD: Share the attribute conversion helpers with the NFS_ACL procs
  nfs_common: Remove the unused NFS ACL stream codecs

 Documentation/sunrpc/xdr/nfs_acl3.x    | 273 ++++++++
 fs/nfs/nfs3_fs.h                       |   3 +
 fs/nfs/nfs3xdr.c                       |   1 +
 fs/nfs_common/nfsacl.c                 | 125 ----
 fs/nfsd/Makefile                       |  13 +-
 fs/nfsd/fattr.h                        |  20 +
 fs/nfsd/nfs2acl.c                      |  99 +--
 fs/nfsd/nfs3acl.c                      | 623 +++++++++++++-----
 fs/nfsd/nfs3xdr.c                      | 166 -----
 fs/nfsd/nfs_acl3xdr_gen.c              | 839 +++++++++++++++++++++++++
 fs/nfsd/nfs_acl3xdr_gen.h              |  36 ++
 fs/nfsd/nfsproc.c                      |   3 +-
 fs/nfsd/xdr3.h                         |   8 +-
 include/linux/nfsacl.h                 |   9 -
 include/linux/sunrpc/xdrgen/nfs_acl3.h | 284 +++++++++
 15 files changed, 1948 insertions(+), 554 deletions(-)
 create mode 100644 Documentation/sunrpc/xdr/nfs_acl3.x
 create mode 100644 fs/nfsd/fattr.h
 create mode 100644 fs/nfsd/nfs_acl3xdr_gen.c
 create mode 100644 fs/nfsd/nfs_acl3xdr_gen.h
 create mode 100644 include/linux/sunrpc/xdrgen/nfs_acl3.h

-- 
2.56.0

