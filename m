Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792677223;
	b=IdQ2SMkCTIMSQo0+kaeX29aDHCAHYgVsnjGgPmvj+VwEkM7C/Fg0LC2MetE6hW7xUcoy
	 OgPPssqe5hotp9p+h5CCXuQuWV2mQUrhlrELgCtHb/Fu+iQkBXUh+hISBsyPX6NE/Ri2y
	 p5QGFr3yW5cG8V/1OLZhg2gymeuOXTEP4URltPagAapnFsKkVOmtERjQRQydeEDr/q7lT
	 cRRtpg6kC9QCU8glPkDTE2HgpN6Iiz4/oEiihxQC12J9sJPO9RiQ166EOfmRzoD3m/JEO
	 HjndCtPVTVGvqJ+XkjzuAklZst5SfCfPQsGA3sDkw8BdGUHsntJqck1c7eQm0sDuAXA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792677223;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=1Q8tlPQwrNicQBtuqq1FQpA6tSr3NcHh7NUUWtvF4x8=;
	b=dCqqUr+EGoMWi6ZRPKcQfhm5xYsdKkv5EeJsfKCKYJi0f12+vbckfG/hbUHUtMwP9RLO
	 HCsyj98NChPbp7TTVFnEmF9PJad2ESExmrlY2T5AXRMviwRHKIfih0BUIptZXEsJjoPjV
	 tsJbPefa1hDs+f+vLrRRzk+3AUXGdr0pixiPBxiej2p8hPZ5jKDav7alZdSXj/XvwIyUs
	 +4tOmUXF+DSy+lawcntZjWIkCXbL99rku5sR6TllhpMgsxgxnBhK3VHauhGqIxMRqnI5D
	 nfcEJxHOvCCAbbFKsM/MP63gNbdOvDU02WPad+SGUNsAiiSblMFUVtb5VVNt7/c2a2A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iR8LEeVm;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B00E960A2621
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 13:53:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iR8LEeVm
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E660E1F000C6;
	Thu, 22 Oct 2026 13:53:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792677222;
	bh=1Q8tlPQwrNicQBtuqq1FQpA6tSr3NcHh7NUUWtvF4x8=;
	h=From:To:Cc:Subject:Date;
	b=iR8LEeVmiOzCi5bVMrae8fvxBJlYZ0DP45BM9RIc3qEERTr8sM4l4HgQ0qwNpGfct
	 u1o24TndfxIUFYFkIKlA2O5gXkpw3ecBEoyx1LsXwfQMiHSwxf+5LbeXIRL/Nvp9Qa
	 wWS60gw/vZK8AVwiixDoAnZFiLakLti/LqhuMr19sW40cVceMlQ+Z/8LhH8Jc19Ct2
	 ihcSCqF79/EWDm/epyTM7JL+nMcqp9d/I73F/2NA6nlEKL2eHib/3BfdfunOFjv9NA
	 quVFCDDSYf9Q0XU14DgLHWHi5RNDKTTFgsdbNM/cakE8JBT65yos5igBYtlFlaR05Z
	 6e6i9RYtk6c3g==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 00/17] Convert server-side NFS_ACLv2 XDR to use xdrgen
Date: Thu, 22 Oct 2026 09:53:24 -0400
Message-ID: <20261022135341.14265-1-cel@kernel.org>
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

Replace NFSD's NFS_ACLv2 XDR encoders and decoders with code that is
mechanically generated from the protocol's RPC language description.
No RFC defines NFS_ACL. The description in nfs_acl2.x is copied from
draft-ietf-nfsv4-nfs-acl.

NFS_ACLv2 is the first consumer of the aggregate codec on a counted
array (already queued for v7.4) and the first on the decode side. The
NFSv2 and NFSv3 READDIR conversions exercise only encode of an
optional-data list.

After this series is applied, NFS_ACLv2 reply statuses follow the
draft specification, which has some changes from the previous ad hoc
code. In addition to replacing the status codes defined by the NFSv2
spec, a well-formed but invalid SETACL argument gets ACL2ERR_INVAL,
where the previous decoder returned GARBAGE_ARGS or accepted it. An
undefined GETACL mask bit gets ACL2ERR_INVAL rather than NFSERR_IO.
Statuses that fh_verify() and fh_getattr() produce with no NFSv2
equivalent no longer reach the wire unmapped.

Chuck Lever (17):
  xdrgen: Reject out-of-range unsigned short values on decode
  xdrgen: Reject out-of-range short values on decode
  nfs_common: Export posix_acl_from_nfsacl for server ACL codecs
  NFSD: Remove the unused NFSACL_MAXWORDS macro
  NFSD: Move the definition of NFS_ACL_MAX_ENTRIES
  Documentation: Add the RPC language description of NFS_ACLv2
  NFSD: Add infrastructure for generating NFS_ACLv2 XDR encoders and
    decoders
  NFSD: Remove '#include "xdr3.h"' from nfs2acl.c
  NFSD: Remove '#include "xdr.h"' from nfs2acl.c
  NFSD: Switch to using the NFS_ACLv2 status codes
  NFSD: Use xdrgen XDR functions for the NFS-ACL v2 NULL procedure
  NFSD: Implement NFS-ACL v2 ACL encoding and decoding with xdrgen
  NFSD: Use xdrgen XDR functions for the NFS-ACL v2 GETACL procedure
  NFSD: Use xdrgen XDR functions for the NFS-ACL v2 SETACL procedure
  NFSD: Use xdrgen XDR functions for the NFS-ACL v2 GETATTR procedure
  NFSD: Use xdrgen XDR functions for the NFS-ACL v2 ACCESS procedure
  NFSD: Map every NFS_ACLv2 reply status into aclstat2

 Documentation/sunrpc/xdr/nfs_acl2.x     | 283 ++++++++
 fs/nfs/nfs3acl.c                        |   1 +
 fs/nfs/nfs3client.c                     |   1 +
 fs/nfs/nfs3xdr.c                        |   1 +
 fs/nfs_common/nfsacl.c                  |  15 +-
 fs/nfsd/Makefile                        |  15 +-
 fs/nfsd/nfs2acl.c                       | 892 +++++++++++++++++-------
 fs/nfsd/nfs3acl.c                       |   4 +-
 fs/nfsd/nfs4xdr.c                       |   1 +
 fs/nfsd/nfs_acl2xdr_gen.c               | 869 +++++++++++++++++++++++
 fs/nfsd/nfs_acl2xdr_gen.h               |  40 ++
 fs/nfsd/nfssvc.c                        |   1 +
 include/linux/nfsacl.h                  |   8 +-
 include/linux/sunrpc/xdrgen/_builtins.h |  16 +-
 include/linux/sunrpc/xdrgen/nfs_acl2.h  | 278 ++++++++
 include/uapi/linux/nfsacl.h             |   2 +
 16 files changed, 2155 insertions(+), 272 deletions(-)
 create mode 100644 Documentation/sunrpc/xdr/nfs_acl2.x
 create mode 100644 fs/nfsd/nfs_acl2xdr_gen.c
 create mode 100644 fs/nfsd/nfs_acl2xdr_gen.h
 create mode 100644 include/linux/sunrpc/xdrgen/nfs_acl2.h

-- 
2.56.0

