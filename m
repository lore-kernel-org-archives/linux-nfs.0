Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792946519;
	b=IVlFebuVJQF3XaYwJkjhs8jm4r0W+HSuHby4ia0kQNPY7Ud/h2U7BWJB45Ls0NWio0lS
	 iEd9En9ajMO6hmtzmnIHd2nUL52rdwMoucfRpDIXBlrlvxnJDelzQ1DConQno1xnyWbHz
	 /L1ZVO20oWrnt+xXv2sTahc15wKW/ZBUJ/aTUmZc6CAnBf/Ao0FnjflaDzkL2qbiOwnDF
	 LXptecb+M+EceOSdAdkEzOBUS8jdcU8M34z06JJCfGmbhy6ZJxakPa9eibKCfPAlTjfGc
	 l/JVNXcAc2gNkCUrkULwhTsyi51cZoOvUrxQzVRITqgTDWUuLWq4BS3PvS1PDJS5fEg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792946519;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=FMyzbSBnt+5KvbIq2hA16c9sKO3amj+pJNWPArtZsew=;
	b=QCIsO+0ebtkNQSFod2iqbklfHI4CodfFHJnDj6VjVU2i0kWpDQCgVgse24bQLTZLVp4Z
	 bbWgb9mXV1Ji8riAIIN6sJHwkKA0L0SBuKKw81OQOMuUoGXMQkCxMEdhE/CRYGU0HhTE7
	 wQSs3kVlpn//sKC9lezvCefOxC84PzvJq+WRjK+m9xJ+/LMOWpH8wT+Q9awzkMHNQ6te5
	 Fq5AZUiwEmDcBuYb6zubKieYr9qtaFQPf17EuWKDm5PB3Ofxs/56QNAIH5I038JWpnRXV
	 whaxM16zmhnmblu8BsMSk0P4RU+hwgx2BBKoV4gWm22inVV/f0hkn4a8RLC1nNrrsSw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=h5X6THF2;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8C521606A31A
	for <linux-nfs@vger.kernel.org>; Sun, 25 Oct 2026 16:41:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=h5X6THF2
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D18A61F01825;
	Sun, 25 Oct 2026 16:41:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792946519;
	bh=FMyzbSBnt+5KvbIq2hA16c9sKO3amj+pJNWPArtZsew=;
	h=From:To:Cc:Subject:Date;
	b=h5X6THF2SimgA0zHeVxsqTQKuVw7pmdvvpX8Ki1G1m0ktBqU//tSmpM+tHYbR7aMh
	 kXsmJZNEKZbJSdKl76kxdY3C7Rz1TNPJLJPB39dHnjEuaZbjMKNZILnTrMqWGFjgKh
	 Z7eghN5L7MIFX30UZ8J5LijxjBvUsvNQCkNMndgDtJ20jRf2sSFQZZHsip3KqVHBBU
	 JzOV8DCd39kTh7nj49yh9o5ESWDnuB2BG59etS4iv6Zi5Ogn7PRpsQkN6AuwfPRcH1
	 sPLdOivfDJPA4KxUCNaXLC2T+bqZDxahuSjjDEX0uaUoGomPquIQPl+KwozVE4C4zg
	 +Bi+ZtrJR3HkA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 0/4] xdrgen fixes
Date: Sat, 24 Oct 2026 21:46:12 -0400
Message-ID: <20261025014616.22236-1-cel@kernel.org>
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

Four fixes I found while converting NFSD's NFS_ACLv3 XDR encoders
and decoders to use xdrgen.

Chuck Lever (4):
  xdrgen: Handle a union whose arms are all void
  xdrgen: Key the width tables by type name only
  xdrgen: Register optional-data names only for typedefs
  xdrgen: Take a union's numeric discriminant width from the declaration

 include/linux/sunrpc/xdrgen/nfs3.h     |  8 ++---
 include/linux/sunrpc/xdrgen/nfs_acl2.h |  2 +-
 tools/net/sunrpc/xdrgen/xdr_ast.py     | 42 +++++---------------------
 3 files changed, 13 insertions(+), 39 deletions(-)

-- 
2.56.0

