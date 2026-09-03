Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 638554C77C5
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 15:03:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788447834; cv=none; b=chroPcWkn8sqh+WoMKGpvbsoNGEcNhoJ0LE0A0pBUleEktqWLNu37dCCoKkdUtF3FVn4s+hXzkyVP9zsr1pr/3V0HCiV3ox9nNEdSIGzeyHlI6mgToaDV95A6RB6Y0sAy7G/m6rskVFwFQphNBU2ABrK3E6pR1qbxmMczj/hlYw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788447834; c=relaxed/simple;
	bh=U0dssOtmYZCmnVCo5YeaJsVA7lfRjKNV0Hf54ZG1BKY=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=BYfUSmu5V+nFfx3pZOzAzTRr/t35B9HXiO1QdiZIUigkhtpXtGzauc0KjYGdQWZZ+rfDBv3dRJutm3Jy3jFTzC8zLRwug6gR892WrXveGk1xO+npAdQIQ9kva1DWXJzjAv3KxGC9uavIzhc8t8Hm9h6G0bw+k+drQMVFlw5CcvU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SqEahWsF; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SqEahWsF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A8E521F00A3A;
	Thu,  3 Sep 2026 15:03:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788447833;
	bh=eNLuAJmh3BEZ/Hyz2bMWjh6SQ1WvmCqXMGFagdwNDtE=;
	h=From:To:Cc:Subject:Date;
	b=SqEahWsFyJZc5B+/3uNEJPfe+1j4o4F2ug2qW6wMtPgXwCmO4k8IfymepPvfaALIS
	 0WyhTkPS/JHhy9dlKFyJnnAJz5tyX+N6uZE5GflbXSkQqGdFqwqSbKQboZfm3i6YFH
	 zaZ2mxgrNW48uvTbybRNyWJUpZZKV/ACXtXcqMKfSyyArJGQiofRAsEN276V2Mw4Z4
	 gULUnFUDvc4A432S7XpIgOo2EsC99ECDLBawJObw62rdX8Vxxyju0IiNQhlaFim5Py
	 V938FcT99YY6xyPOTa8Cfbfo9tq+Oya43r2AHQUqmZ8C9yF2/3eE4TkC3E1m7Sb3zP
	 C5DhMtxfxPTyg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 00/10] New pragmas for the xdrgen tool
Date: Thu,  3 Sep 2026 11:03:41 -0400
Message-ID: <20260903150351.9572-1-cel@kernel.org>
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
 include/linux/sunrpc/svc.h                    |  77 +++++
 include/linux/sunrpc/xdr.h                    |   1 +
 include/linux/sunrpc/xdrgen/_defs.h           |  32 ++
 net/sunrpc/xdr.c                              |   3 +
 tools/net/sunrpc/xdrgen/README                | 136 +++++++-
 tools/net/sunrpc/xdrgen/generators/pointer.py |  68 +++-
 tools/net/sunrpc/xdrgen/generators/struct.py  | 197 +++++++++++-
 tools/net/sunrpc/xdrgen/generators/union.py   |  69 +++-
 tools/net/sunrpc/xdrgen/grammars/xdr.lark     |   2 +
 .../C/pointer/decoder/pages_opaque.j2         |   6 +
 .../C/pointer/definition/pages_opaque.j2      |   5 +
 .../C/pointer/encoder/pages_opaque.j2         |  10 +
 .../C/struct/declaration/aggregate_hooks.j2   |  14 +
 .../C/struct/decoder/aggregate_array.j2       |  35 ++
 .../C/struct/decoder/aggregate_optional.j2    |  31 ++
 .../C/struct/decoder/pages_opaque.j2          |   6 +
 .../C/struct/definition/pages_opaque.j2       |   5 +
 .../C/struct/encoder/aggregate_array.j2       |  39 +++
 .../C/struct/encoder/aggregate_optional.j2    |  29 ++
 .../C/struct/encoder/pages_opaque.j2          |  10 +
 .../templates/C/union/encoder/pages_opaque.j2 |  10 +
 tools/net/sunrpc/xdrgen/xdr_ast.py            | 300 ++++++++++++++++++
 23 files changed, 1043 insertions(+), 43 deletions(-)
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

