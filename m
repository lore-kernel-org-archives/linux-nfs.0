Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793109121;
	b=vlvMohHVOqWM2/C7fegClG367QTTvnkctDhUlmPHVblNyITOWhpY7dupddwxnFQIBkLh
	 yiT1aPeS6DFedsW0zcluEHCaChRwj8A2O+pGIiypbimFf6a2XiFJI4sVUaS4En9Zn52wP
	 mJXNJDEJrnaC2t/AwdWOuzLoznuMnPGTkCIv9niRvz+0kc1HSbQV6b0Sor+dcxuewdBos
	 +L6F4UvpHcLJa5oKocJvVh+zVIBjIqKn0Ec/uR+noXDwBw1CXZIJYpI8y8pEdDsW2N9KN
	 ANb5ip6Hu8GciH/DNgk5iI+/P4vgxI/9JBYzzpPb2264UoyxN9dGfO2C9Ln2aMuE7+w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793109121;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=cV+a/clfsJrV0hmN2N3d9Aj0vwHZqLBllFOfjWYwaNY=;
	b=aMw6N+4JO21GJKmfy89slVpbGxiOzgxqJHJw0wp3BgGnLbD+YIj4YUscPfKcvuPr1xyG
	 XRbLhueTDDnja8OZuRG7LGt5AxEaAaV4dbqbtvVBBM/8+eg4VzLpzcWQrCY/ejQodEaif
	 nLJgoKCXVH5h/Mc0qar9DeoAz9Olm7H3SPKbctPpQFNOUSjox5IgKvWv5vkPGqukRY+wC
	 vR0ZLDJfP1CeWAKplwbg5Bx8kIvMteH8rZ1s9eRRE1ZKQYx/35PtRr+kot7cuqrnClWy2
	 69SvgEDj1PxeMlCiGrhsscoFzPeIBkWEPqnsFCMhNfaTq+Ux6310ldm2yWTVftQsgVA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PUb4++y+;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D89A5606A31A
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 13:52:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PUb4++y+
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A92C41F01828;
	Tue, 27 Oct 2026 13:51:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793109120;
	bh=cV+a/clfsJrV0hmN2N3d9Aj0vwHZqLBllFOfjWYwaNY=;
	h=From:To:Cc:Subject:Date;
	b=PUb4++y+xzTl1AX16Zm1/T+28fZIDz074NvmwhUXmn5Tseuaiwj92gbbd0kO13QGH
	 IlGEeRA6rHQrbPkAxaRsT2DFqeqRVr3IA2EP46Ak6GP7ozNnEMC3/sOD/tAnl3YRa0
	 y/yytId4TJq9KVftJnMUM6xV38tSRDzQztDLLmedwYz6AMpwLlv1hNlV03C9T3suRg
	 Nympoz7QB87+WjWKMHuLu/Nax9carFE4M3a/r9yTIgZsuRvV50MBb9iyC8lqw6yF2Z
	 BWiauv+8zILQwvWU8aWOty1ph5AVp9AL4Qj2kKR8fxAVHly/tncwqIjiQbjpZHBDXh
	 p8a9xCn1ECEdg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 0/2] User namespaces for NFSD's NFS_ACL implementation
Date: Tue, 27 Oct 2026 09:51:56 -0400
Message-ID: <20261027135158.164034-1-cel@kernel.org>
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

Interpret NFS_ACL UIDs and GIDs within the server's user namespace.
This matches the way NFSv2 and NFSv3 handle UIDs and GIDs.

The NFS_ACLv2 support is probably never going to be used at this
point, but it is harmless to keep feature parity with v3.

Chuck Lever (2):
  NFSD: Map NFS_ACLv2 entry IDs through the request's user namespace
  NFSD: Map NFS_ACLv3 entry IDs through the request's user namespace

 fs/nfsd/nfs2acl.c | 14 ++++++++------
 fs/nfsd/nfs3acl.c | 14 ++++++++------
 2 files changed, 16 insertions(+), 12 deletions(-)

-- 
2.56.0

