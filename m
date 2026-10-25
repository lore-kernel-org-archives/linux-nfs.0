Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792946520;
	b=lsA4dCLtPd/qjW632d9LoTw26klCrCD657fWZG88JiAocBDtJKN37or4zlU0esurteta
	 c53JoEE0RJ1ZI2RVGVUy6R3wanyNW1Qi7i4wAqgetyt8EYyGoY30fQmK1FJqC8DbeHwiZ
	 3R2KE/kHRJDKADmHrqkctpczPY5unq+nSQBKrjQTp9+WOkD2KbtwLk//+21axLJGUQ/91
	 ihUQXffd/GHem1J2tmm2GNgCFyy7zD1drEXVfXuvZftCNaw/pkj+g2D0TSo0lQt0j5R/k
	 +Y5D8I2gUS/4D7Sa7ljY3oLGdDOO2MYTMSQ9ko/7nloDqSgkriWYd4ARoREJJXofF0w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792946520;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=5NBCb+LcYiWfFmw/IJY/SON7i22i/Nab5GONBNYn/AY=;
	b=iJOiPFOW9yh+VwUdq6AO9wHwRlKfXFZuEJnI0JM0R7z88wIq7NkjPI62XjrfcJ2+o/Wv
	 I/s4HAqodZfWnGB/KSitAQXnwOKmDP0txkOOtxi3Ot5nr54AASOf5NzJjb2Mwc9IBcpO/
	 0sho3m4gBzBVFn1hCoS0oXfh/68LkOtlA6I6sMUoEztwviSEg/blu4IphOkV+fLAvUWHE
	 TCEICHDo5bASn7AuRYwUgQ6FYrst3Ho8qSL3InFgLCqtKdkkXT9jDRvUm1+l5D0auRAdj
	 qllBvqnsjUuoJDyNCXPFsr3w8njeocoeFi+TOxiFlG1LsiWK/NzVBxQE0RZJFJxKtOg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ARuc7fTY;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5FC9D606A320
	for <linux-nfs@vger.kernel.org>; Sun, 25 Oct 2026 16:42:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ARuc7fTY
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4F9A01F01829;
	Sun, 25 Oct 2026 16:41:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792946520;
	bh=5NBCb+LcYiWfFmw/IJY/SON7i22i/Nab5GONBNYn/AY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ARuc7fTYOpgBajSxlxY3Qsqa78XAOlwGYxbRqA2AB4ZG6uCWCKuSWLjXvAFAKdlxV
	 FX1mQvmxv8PjUalZaxnT92RMC+97juNJOB/z2qvHAzjGr/uBANKYqk6dJG0sy1t4g4
	 gaI8NI0x3EcfteX+mLX8fEKrEtsLaH+C/A38y3UjGIruMgsk1D+svGxRFuYaKkbkyU
	 oKrbjZJlpkQGT/3L/egeT9wXLgYq3Ts0Ls73VxohcD6W8+ZlkT50LqWlSQt2RZUGJL
	 6p+tsOWpTLivGRxvDziDLPuKmc8tz9pJ+sJFe28GgJBQhTRp3KO2tCgfg4DkhYHLGj
	 jvYHz4KB8DR/w==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 1/4] xdrgen: Handle a union whose arms are all void
Date: Sat, 24 Oct 2026 21:46:13 -0400
Message-ID: <20261025014616.22236-2-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261025014616.22236-1-cel@kernel.org>
References: <20261025014616.22236-1-cel@kernel.org>
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

_XdrUnion.symbolic_width() assigns its result variable only when
an arm's width exceeds the running maximum, and the maximum starts
at zero. A union whose arms are all void has no such arm, so the
return statement reads a variable that was never bound. The
definitions command then reports "cannot access local variable
'width'" and exits without generating the header. The sibling
max_width() method starts from zero and handles the same union.

Start the symbolic width from an empty list, so an all-void union
reports just the width of its discriminant.

Fixes: ce5a75d9939f ("xdrgen: XDR width for union types")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 tools/net/sunrpc/xdrgen/xdr_ast.py | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tools/net/sunrpc/xdrgen/xdr_ast.py b/tools/net/sunrpc/xdrgen/xdr_ast.py
index 5b2a78ca745c..537f056a0c27 100644
--- a/tools/net/sunrpc/xdrgen/xdr_ast.py
+++ b/tools/net/sunrpc/xdrgen/xdr_ast.py
@@ -546,6 +546,7 @@ class _XdrUnion(_XdrAst):
     def symbolic_width(self) -> List:
         """Return list containing XDR width of type's components"""
         max_width = 0
+        width = []
         for case in self.cases:
             if case.arm.max_width() > max_width:
                 max_width = case.arm.max_width()
-- 
2.56.0

