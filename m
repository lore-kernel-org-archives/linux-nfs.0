Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8FFF1346784
	for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2026 20:34:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783888496; cv=none; b=GP5Z46r5wF3hcFrrPAA3eTluJ+n+N13+nCU+as5JufmviQ1rUNVtLcszeXQNqXsRDUpibSMlQBZp5LUBHMpIyRiiEQp9YwwNmJesATWUFIT0BjLB7vMzBfI9HgWI7g0sKLKqCIHaPqtoRH0kIuSYIV3Z/kDcVj+QRvx9Mg4rvoI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783888496; c=relaxed/simple;
	bh=oRBIIOtbhtZpW/AWBg744OVhC1Dr/1jvtIlRb++JUCM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=YnHauadadcLeZBAuwuUB2k0voOjy2wbZ6NR5AaeMJX9jl2y4VNa7+4qmDOE1yhip3+JmCe60wrNFlh7oK9roXgB8Ky4DDTf+VFtIgkoLr3Ut4TfDxQ7ZC598Bnk/AqYCDTAGNsEky7Ey8Jf/tqMOc2D/vEHENjAIoGKHWE/iFsk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=P08I5+K2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="P08I5+K2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 54A731F00A3D;
	Sun, 12 Jul 2026 20:34:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783888492;
	bh=pC8+rW3o0ovY1i9TOictWVegS4kPYoX6HpOb2rdlods=;
	h=From:To:Cc:Subject:Date;
	b=P08I5+K2de3uj91VCAcwASMCF5hpXrDs6qU+OAc9Mm3nrl85JfYnCVAVpKsK6M/JX
	 cpEUBBvsmmrQoRUE1MybxdILZQ8EjWgCd/ceOCN12Kr4kMMUR5mLWHZMUX4xpTgRbg
	 eQdkk705NqUhgqtQD3NWVeZE/i2nt7zuu52Unymk/GhJ7ILSghqj84uc+xxhApwrjn
	 8fr5TrVSAOaDiynAMwhZIQBpowdxiG9/zI2iz8LhroxTLUfO73rMBDPq4ZofK155QB
	 PwTAGBoOOFdpC9TaQN8YvaCYMElNzMUFSQ7F7lw6esfRIN+IO0PwnuEvDUD+8I7bXn
	 LGozLDBBEDa6g==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/5] xdrgen: Improve diagnostic reporting
Date: Sun, 12 Jul 2026 16:34:46 -0400
Message-ID: <20260712203451.124902-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Add missing detection and reporting for semantic errors specified in
RFCs 4506 and 5531.

Chuck Lever (5):
  xdrgen: Align the error caret under tab-indented source
  xdrgen: Record the source position of each declared identifier
  xdrgen: Reject specifications that define a name twice
  xdrgen: Enforce RFC 5531 name and number scoping for RPC programs
  xdrgen: Reject out-of-range program, version, and procedure numbers

 .../net/sunrpc/xdrgen/subcmds/declarations.py |  10 +-
 .../net/sunrpc/xdrgen/subcmds/definitions.py  |   7 +-
 tools/net/sunrpc/xdrgen/subcmds/lint.py       |   7 +-
 tools/net/sunrpc/xdrgen/subcmds/source.py     |   7 +-
 .../tests/bad-procedure-number-negative.x     |  20 ++
 .../tests/bad-procedure-number-too-large.x    |  20 ++
 .../tests/bad-program-number-negative.x       |  19 ++
 .../tests/bad-program-number-too-large.x      |  19 ++
 .../tests/bad-version-number-negative.x       |  19 ++
 .../tests/bad-version-number-too-large.x      |  19 ++
 tools/net/sunrpc/xdrgen/xdr_ast.py            | 290 +++++++++++++++---
 tools/net/sunrpc/xdrgen/xdr_parse.py          |  46 ++-
 12 files changed, 428 insertions(+), 55 deletions(-)
 create mode 100644 tools/net/sunrpc/xdrgen/tests/bad-procedure-number-negative.x
 create mode 100644 tools/net/sunrpc/xdrgen/tests/bad-procedure-number-too-large.x
 create mode 100644 tools/net/sunrpc/xdrgen/tests/bad-program-number-negative.x
 create mode 100644 tools/net/sunrpc/xdrgen/tests/bad-program-number-too-large.x
 create mode 100644 tools/net/sunrpc/xdrgen/tests/bad-version-number-negative.x
 create mode 100644 tools/net/sunrpc/xdrgen/tests/bad-version-number-too-large.x

-- 
2.54.0

