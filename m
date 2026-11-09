Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794254010;
	b=b1OgRQIXO65oOuvXvNVqB99t+pXvf83MNK8i4BB2FM4rwvKLQHKh17qqWI5CDNeRr6Ki
	 VARqpX8XI53v7sHA0nRk5cwM89HdxfvHgeAZNlqKNwRdgH4UNnoWplfxPbZYT2E2EgdXZ
	 pw36gByTC2f5usOTAw3E4+4XO2ls0LhSLaxUHI+BIaoxndckAoC7zbMI1rLJrBB+F1UDK
	 z0V3yZ/nIXkKKJe6080WVpmh+ltOL4stQZElO16WXvDO0PzpX81GwxJMg0BlLHb2pyg0P
	 MEWSOQ/DQjASow1jW8hx0kkN1shnRBYhZYpxOLFu1Hkp7o0WW5TLDemIBWqGmSa1awg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794254010;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=knj6PiH8eRc0ubGmCl+dX7YkVYwV5uayueKD3zMEfhI=;
	b=KjViKMmULiUORcN1d10TSSoj5jd8ReWyEwqeMUVLTHsMz4zAc3uhdz1jupw490kvSPRd
	 uh1+NW7EfG/CSkRnnoIZyCGD5D2Wp1hDvuJ9pXq9+/W2RFDbw5XdY6Ctb09qkwsjsO2gW
	 UzRutmqmxUpwA+dieCudk2d6ff6x9c/yniwN8pyVomq1wXGCf3AsdZn2WJAgd3uLXwlGe
	 p+dpjNMM/42P0KaunP3F7Wh055bNbURDF06wds8Y4t4Ti3C/1b/JsP+uIFxjfIYRgoThO
	 FXevMpmha1FA/nAdJIM+qtEwdrTJ6E2ULEXTtBwB/MK4sEQ5fFQgY3MMdsiGk5IsZ9A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iur2x88z;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8A90C60A2636
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 19:53:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iur2x88z
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9BCDA1F008AB;
	Mon,  9 Nov 2026 19:53:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794254010;
	bh=knj6PiH8eRc0ubGmCl+dX7YkVYwV5uayueKD3zMEfhI=;
	h=From:Subject:Date:To:Cc;
	b=iur2x88z6B5wAnf7l87S+itqlngtptYxxqrvO5bk3ZArZfVrGBm69FCfaD36SGELB
	 S+jDoW6hs7ug8FrztBbhn3Z0hVw5njgpL4FLBJfMLVw3JQpnwdoH5vQ+f3I+sjPlgl
	 T1xPLbUuvPCdVjKQm0hwSIXLBGZek3tQS8e2hULiMsg4pU/knntdvYszF0R2+7GpG+
	 tssXauIw4iWKLFLchnydpvE9K2ArWpiqfHSxzwgDMxm1UsEYDPPfwaJ7vVn56RPA9I
	 CrnrCCmjSvi0oyPpk/nrt6XhbEb1Hd38wh9+P7Mj9oJ9Iaiu87YsZUm6fH7rNCWYuO
	 vznWw2c9EHNiA==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH 00/13] NFSD: Address XDR corner cases
Date: Mon, 09 Nov 2026 14:53:16 -0500
Message-Id: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMywqDMBBFf0Vm3YEk0ID+Sukij4mOi1QyaRHEf
 zexy3O45x4gVJgEpuGAQj8W/uQG+jFAWFyeCTk2BqOM1VqNuMeCm2veOyG0MQQ1Pk2K1kBrtkK
 J9/vv9f6zfP1KofaTvrgzX1wOS1c5ScRKUjnPcJ4XgOYXNZAAAAA=
X-Change-ID: 20261109-xdr-page-base-6dcc0952fd62
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Mike Snitzer <snitzer@kernel.org>, linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=2251; i=cel@kernel.org;
 h=from:subject:message-id; bh=7s+ztilR9aaoTV0khzIem2QiaStZWFMUv9IpMqnv2JI=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq8iSwF2c3gpoAJ3fEnOGROl0OZnmaRTNa9pHwr
 QfAld4YiieJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavIksAAKCRAzarMzb2Z/
 l0HMD/wISUEzpNDIdaYUzxSfYNGHSnpuFFNZbf3hmPQ61NrlF1fbPSpzHatsSYJoGP6Z8T8wmG9
 wGGYvNzxMbEZaxd1EehPyMHqmZmMkEIZN/FeMX4S8PEbfWr7c1wct0Y+m88f0YdyM+i8xwWJvk4
 sBYjhx1e2f9jfEAc0GLuU6c+Kc4IpJ2cWDBZRpqxYiXL0dT8BRZRiZg3nnacb6OtM5IoJR7IZL0
 fn/T613xr7EtH+4ga2rpzine9fad6VoNoC8hltjpFdII9O3XEpxWuIJuNkenxkmA+mKtXCdiIUu
 yb5YldlG3qdYjL1X+v8qazsGugIGLDJP2qXKNXWfCZBsGGtmzpNZ06wkY+1l0Dyrz+jc57igRxv
 +CgMFRHdym0lTsftgvAdiKf+O1jF1vL9+yERG/73eVbzlMqP9acPdD4cr9soM7jDOI97ePn4jre
 82gktwEhQtGzkG6okYj3UIXvwhh+EUmWYD7k6r02RAZ9KAUOp/DOI9f2G5edz4uRe0CR+AFyhDc
 9fzW6Yk5gS6uEuufHgq9QP1oQb6lNUA4vQ8FYppDpQJEbFdRaq+gQMT1aEAFMu8qXbwJmKvjilI
 S2rHHkM/fPjo9cpoOTBsbMPIIasxEH2Mn6TPkkHTRUrQOhnGrWJqop+j/jDD40PRralKQDtPFKD
 yYXPkN6hVRffhrQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

While I was working on other development efforts, code review
spotted a number of pre-existing bugs.

The git regression suite passes on an NFSv4.1 over RDMA mount point.
Direct READs at unaligned offsets were verified by md5 over krb5i on
NFSv3 and NFSv4.1.

---
Chuck Lever (13):
      NFSD: Drop the READ payload when the NFSv2 GETATTR fails
      NFSD: Pass the link text offset as the READLINK result payload
      NFSD: Check the Write chunk before inserting a spliced READ payload
      SUNRPC: Check the Write chunk before inserting an opaque payload
      NFSD: Return NFS4ERR_IO when a payload overflows the Write chunk
      NFSD: Place a word-unaligned direct READ's XDR pad in the tail
      SUNRPC: Account for page_base when encoding into the reply pages
      SUNRPC: Add KUnit tests for encoding after a nonzero page_base
      SUNRPC: Restore the auth slack before encoding the integrity MIC
      NFSD: Round the session's reply limit down to a word
      NFSD: Account for page_base in reply-space decisions
      NFSD: Allow a word-aligned direct READ in any COMPOUND position
      NFSD: Do not truncate an operation that reported an out-of-space error

 Documentation/filesystems/nfs/nfsd-io-modes.rst |  15 +-
 fs/nfsd/nfs4proc.c                              |  12 +-
 fs/nfsd/nfs4state.c                             |   2 +-
 fs/nfsd/nfs4xdr.c                               | 181 +++++++--
 fs/nfsd/nfsproc.c                               |   3 +
 fs/nfsd/trace.h                                 |   2 +
 fs/nfsd/vfs.c                                   |  15 +-
 fs/nfsd/xdr4.h                                  |  32 +-
 include/linux/sunrpc/svc.h                      |  67 +++-
 net/sunrpc/Kconfig                              |  14 +
 net/sunrpc/Makefile                             |   3 +
 net/sunrpc/auth_gss/svcauth_gss.c               |   1 +
 net/sunrpc/tests/xdr_kunit.c                    | 505 ++++++++++++++++++++++++
 net/sunrpc/xdr.c                                |  53 ++-
 14 files changed, 825 insertions(+), 80 deletions(-)
---
base-commit: 2cf04da22a850a733c0e09b17ce95cfd9b642558
change-id: 20261109-xdr-page-base-6dcc0952fd62

Best regards,
--  
Chuck Lever

