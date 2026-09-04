Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7BBF633D6FA
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:50:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540655; cv=none; b=dYufy/WUmyKzYFA+O8qCCNN14LQsAFmSZEokzvKGJdhpDN/z9D9+Qf4HcZ6RTS6kkuCj6c/xIz2eLjcAT6+e5KP7fNpDm05vW5XN4zqGdt8bXiMMR6mNS1jAzNcyHompp1d+WPP9YAGZSeDPO8Ucs7/BIHC3bxqlI9g1WgL+JTo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540655; c=relaxed/simple;
	bh=jjkOzmC/HoFRAjDM3V+YDuR5j0H8Dkiutn3fc0sXpNE=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=a0aRON/3bN3vdRorC4X/j/P42d+WNgZ5FIf+EBUN33JfO/zLmC01FwUYIAD7a3hqVG4Ck+XtgVLQTjwIHLI/7MTkZ6rRIxq3xoYRiJggWXP6e87arph9ExA7YZDa89MPsa6REoPMVMyqM40tftewzdHjEU5XO0/dt0lcpOXPRQ8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kkncUhtM; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kkncUhtM"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BF9BD1F00A3E;
	Fri,  4 Sep 2026 16:50:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788540654;
	bh=enR5tbwtigYMJjb7h21IL31YeNPWyPdyyZkqR2Gf6GA=;
	h=From:To:Cc:Subject:Date;
	b=kkncUhtMSGaUYiEkuwsnpEskHGVsjTYSZ0bWDSd6K7raFrvMIdbPBlXlVK/QaBFu4
	 L6Jh+SbDYrXUucpMhIbdXt3CN14Sq55PT9Qxbq7qNKX4eVmARzjH6xoA/UREtFNdIZ
	 RzMjpzkIAQzJ3QCDVrRgV6D4pVwlg0JRru1HF4P6hIIuJ4I8oqYRTkSdajQLnO5nqk
	 etdz61oRl8+2ORdibAtucNCWBl9qUkToQ6kL8u2YfBwEl0Oq7Z+HIRxuKwUckfygEO
	 BBr7WVDENYGlPE2+bkZZbsI0EQuKIF2AqTbSwU1ItUyObaJ4D2ar+rYqlJc0SlC4MX
	 qOdVnbzyjIEWA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 00/10] New pragmas for the xdrgen tool
Date: Fri,  4 Sep 2026 12:50:42 -0400
Message-ID: <20260904165052.153327-1-cel@kernel.org>
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
 include/linux/sunrpc/svc.h                    |  77 +++
 include/linux/sunrpc/xdr.h                    |   1 +
 include/linux/sunrpc/xdrgen/_defs.h           |  34 ++
 net/sunrpc/xdr.c                              |   3 +
 tools/net/sunrpc/xdrgen/README                | 146 +++++-
 tools/net/sunrpc/xdrgen/generators/pointer.py |  68 ++-
 tools/net/sunrpc/xdrgen/generators/struct.py  | 197 +++++++-
 tools/net/sunrpc/xdrgen/generators/union.py   |  69 ++-
 tools/net/sunrpc/xdrgen/grammars/xdr.lark     |   2 +
 .../C/pointer/decoder/pages_opaque.j2         |   6 +
 .../C/pointer/definition/pages_opaque.j2      |   5 +
 .../C/pointer/encoder/pages_opaque.j2         |  10 +
 .../C/struct/declaration/aggregate_hooks.j2   |  14 +
 .../C/struct/decoder/aggregate_array.j2       |  35 ++
 .../C/struct/decoder/aggregate_optional.j2    |  31 ++
 .../C/struct/decoder/pages_opaque.j2          |   6 +
 .../C/struct/definition/pages_opaque.j2       |   5 +
 .../C/struct/encoder/aggregate_array.j2       |  39 ++
 .../C/struct/encoder/aggregate_optional.j2    |  29 ++
 .../C/struct/encoder/pages_opaque.j2          |  10 +
 .../templates/C/union/encoder/pages_opaque.j2 |  10 +
 tools/net/sunrpc/xdrgen/xdr_ast.py            | 473 ++++++++++++++++++
 23 files changed, 1228 insertions(+), 43 deletions(-)
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
