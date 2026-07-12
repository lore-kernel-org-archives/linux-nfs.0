Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A47D623ABB9
	for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2026 19:31:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783884685; cv=none; b=PkTM5Mx19TP+4yGjFEbNDsFhAuDNHcFdwiHK8xhKZBYMPifvVv8YxMdsGxiTo6eUPbuSe8ER8jCqO0WcttdphY906jEuOYQUSxRtSCpOsVPJ9WuP5qpF6fYhGoXVts2rogfqAG53Pi0hMuDsGRMpU/MSmYoqsSXN16dUQkXIJnU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783884685; c=relaxed/simple;
	bh=b5D/zaYe4qSe+A+FLcjhzvcpUVgvT9DwxZeRNzuxCxo=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=uJ+limnPUgVcMs9WNnNNo8ATdEQ2/ocKA14oFrh+EFaGDpa0XuRTd4pun2iuFCsYjpvlu6JV3JdnUh7jc/P4hm0NUBcZGtCH+3CqLAmqkZTSxuVtiHx/n4OxfyTy8giVx5Exfgy6IK+PvimVp+lgnoDbpuEi22VQW1QYarIWSp4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=a4lKNVsr; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="a4lKNVsr"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C3E111F000E9;
	Sun, 12 Jul 2026 19:31:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783884684;
	bh=99QzLRXRdiOcmXZlgFFZPtcDco3EFK6oXdwJ2NOC9LY=;
	h=From:To:Cc:Subject:Date;
	b=a4lKNVsrc2yzYp2+s3WDwrgMmMV6jLgIL/HA8yujPjR7/cKNO/bqRiEkPjiYcQ3N/
	 svzTkn/kFxkN/e7ffEIui1NWaqHHwVisg4ch+8MYwl+oX5v0VJEqvpQt0CRS/oSTUc
	 UIU+PssHi9I0MwacwvA7EoymadTnKLOSs7qLeefG/GNUKbuiaxAwHQJ0MaROKLODYw
	 wt3V4l5l0R6JubIspqg1oOMJQRPNPnmv+K3DsHbE68FjGbfpIdtQCRlpwkbnGZyLPn
	 26/d/lR5HIhlJPnoYNNfKaiRWt6gwwIzqjVfhkU4W3C57z/gYL858krX2PY0aK/txB
	 dQOEYjj0wYY0w==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/5] Minor fixes for xdrgen
Date: Sun, 12 Jul 2026 15:31:17 -0400
Message-ID: <20260712193122.116845-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

While working on server-side xdrgen conversion for NFSv2 and NFSv3,
I found several unrelated minor issues with the xdrgen tool. They
are collected here in this series.

Chuck Lever (5):
  xdrgen: Emit a blank line ahead of enum declarations
  xdrgen: Share void RPC procedure handlers across programs
  xdrgen: Do not declare union XDR functions in the definitions header
  xdrgen: Add XDR width macros for short integer types
  xdrgen: Fix opaque and string encoders for unbounded members

 fs/lockd/nlm3xdr_gen.c                        | 30 +-------------
 fs/lockd/nlm3xdr_gen.h                        |  4 +-
 fs/lockd/nlm4xdr_gen.c                        | 30 +-------------
 fs/lockd/nlm4xdr_gen.h                        |  4 +-
 fs/lockd/svc4proc.c                           | 40 +++++++++----------
 fs/lockd/svcproc.c                            | 40 +++++++++----------
 fs/nfsd/nfs4xdr_gen.c                         |  2 +-
 fs/nfsd/nfs4xdr_gen.h                         |  5 ++-
 include/linux/sunrpc/xdrgen/_builtins.h       | 32 +++++++++++++++
 include/linux/sunrpc/xdrgen/_defs.h           |  2 +
 include/linux/sunrpc/xdrgen/nfs4_1.h          |  2 +-
 include/linux/sunrpc/xdrgen/nlm3.h            |  2 +-
 include/linux/sunrpc/xdrgen/nlm4.h            |  2 +-
 tools/net/sunrpc/xdrgen/generators/program.py |  8 ++++
 .../templates/C/enum/declaration/enum.j2      |  1 +
 .../templates/C/pointer/encoder/string.j2     |  2 +
 .../pointer/encoder/variable_length_opaque.j2 |  2 +
 .../templates/C/program/decoder/argument.j2   |  4 --
 .../templates/C/program/encoder/result.j2     |  4 --
 .../templates/C/struct/encoder/string.j2      |  2 +
 .../struct/encoder/variable_length_opaque.j2  |  2 +
 .../templates/C/union/definition/close.j2     |  6 ---
 22 files changed, 103 insertions(+), 123 deletions(-)

-- 
2.54.0

