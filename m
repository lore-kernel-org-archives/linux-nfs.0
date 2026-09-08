Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F1271501F58
	for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2026 13:42:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788874967; cv=none; b=dK6oHHDM/VqIVzffQ1N8/UMzk7u8cDaDzskM2cESPBhGZaMN4jmxoVE3XAO6kVNan2JtThk86DVqXvQoMVYZ6ynfwTREAWPqSsODtLU3bGSIWixA02ZfV/KpEh7mspke/6Nj7ErS/mrO/vEndQZlZxdZEJP6UuE+eu1uUzMh5II=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788874967; c=relaxed/simple;
	bh=jxrsxOMh1jgIp8B63BjTRxjuVdY94nUPMaAOJ/qQj3g=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=DBtYmWG35kBi91WNZO69LfWaG6OQll1JEBrX10UJz8uSmoq/SC7hYu2zfd6kmCUGul5C398qS0Anu7LkWXtwD7ProrO0MGoZEE+yWYo2Deh1FCE7d2i3lWOrqbD9jtbGUzA1yUsK1uIWg1wMsLacnhgkXoJANUOvQBH2PILmKyQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 81B801F00A3A;
	Tue,  8 Sep 2026 13:42:36 +0000 (UTC)
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 00/10] New pragmas for the xdrgen tool
Date: Tue,  8 Sep 2026 09:42:24 -0400
Message-ID: <20260908134234.512312-1-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The NFSv2, NFSv3, and NFS_ACL conversions to xdrgen-generated codecs
need two important new features in the xdrgen tool to deal with a
few of the more complex structures that XDR can express.

The first is a payload that resides in the Linux page cache.
Currently the generated codec for a variable-length opaque copies
through a data pointer, but a READ result already sits in the pages
of rq_res and a WRITE payload arrives in the pages of the Receive
buffer. Marshaling and unmarshaling this type of payload needs to
avoid copying the payload's content.

The second is an array of non-scalar objects. Examples include the
NFS_ACL aclent<> list, which is the on-the-wire form of the kernel's
posix_acl, and the READDIR entry list, which is produced from a VFS
iteration.

No in-tree XDR specification applies either directive yet, so the
generated output remains unchanged across the whole series.

---
Changes in v3:
- Fail svcxdr_encode_opaque_payload() if the prefix overruns the head.
- Count an array of a "pages" type as reaching its payload twice.
- Reject a "pages" type reachable from both an argument and a result.
- Require a maximum size on an aggregate variable-length array.
- Fail the optional-data aggregate decoder instead of consuming nothing.
- Link to v2: https://lore.kernel.org/r/20260904165052.153327-1-cel@kernel.org

Changes in v2:
- Reject a type whose members reach more than one "pages" payload.
- Reject an aggregate element type with nested variable-length storage.
- Require a pointer element type for an optional-data aggregate.
- Reject an optional-data aggregate in an RPC argument type.
- Document how a producer reports an error that stops the list.
- Link to v1: https://lore.kernel.org/r/20260903150351.9572-1-cel@kernel.org

Chuck Lever (10):
  SUNRPC: Carry a generated-codec context pointer in struct xdr_stream
  SUNRPC: Bind the svc_rqst to its XDR streams
  SUNRPC: Add svcxdr_encode_opaque_payload()
  xdrgen: Pass the containing struct name to member codec emitters
  xdrgen: Add a "pragma pages" directive
  SUNRPC: Add svcxdr_decode_opaque_payload()
  xdrgen: Extend the pages directive to page-resident arguments
  xdrgen: Add hook-driven aggregate codec for variable-length arrays
  xdrgen: Extend the aggregate codec to optional-data list members
  xdrgen: Stream optional-data aggregate lists during encode

 fs/nfsd/nfs4xdr.c                             |   1 +
 include/linux/sunrpc/svc.h                    |  86 +++
 include/linux/sunrpc/xdr.h                    |   1 +
 include/linux/sunrpc/xdrgen/_defs.h           |  34 ++
 net/sunrpc/xdr.c                              |   3 +
 tools/net/sunrpc/xdrgen/README                | 152 +++++-
 tools/net/sunrpc/xdrgen/generators/pointer.py |  68 ++-
 tools/net/sunrpc/xdrgen/generators/struct.py  | 203 ++++++-
 tools/net/sunrpc/xdrgen/generators/union.py   |  69 ++-
 tools/net/sunrpc/xdrgen/grammars/xdr.lark     |   2 +
 .../C/pointer/decoder/pages_opaque.j2         |   6 +
 .../C/pointer/definition/pages_opaque.j2      |   5 +
 .../C/pointer/encoder/pages_opaque.j2         |  10 +
 .../C/struct/declaration/aggregate_hooks.j2   |  14 +
 .../C/struct/decoder/aggregate_array.j2       |  33 ++
 .../C/struct/decoder/aggregate_optional.j2    |  10 +
 .../C/struct/decoder/pages_opaque.j2          |   6 +
 .../C/struct/definition/pages_opaque.j2       |   5 +
 .../C/struct/encoder/aggregate_array.j2       |  37 ++
 .../C/struct/encoder/aggregate_optional.j2    |  29 +
 .../C/struct/encoder/pages_opaque.j2          |  10 +
 .../templates/C/union/encoder/pages_opaque.j2 |  10 +
 tools/net/sunrpc/xdrgen/xdr_ast.py            | 501 ++++++++++++++++++
 23 files changed, 1252 insertions(+), 43 deletions(-)
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/pointer/decoder/pages_opaque.j2
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/pointer/definition/pages_opaque.j2
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/pointer/encoder/pages_opaque.j2
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/struct/declaration/aggregate_hooks.j2
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/struct/decoder/aggregate_array.j2
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/struct/decoder/aggregate_optional.j2
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/struct/decoder/pages_opaque.j2
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/struct/definition/pages_opaque.j2
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/struct/encoder/aggregate_array.j2
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/struct/encoder/aggregate_optional.j2
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/struct/encoder/pages_opaque.j2
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/union/encoder/pages_opaque.j2

-- 
2.55.0

