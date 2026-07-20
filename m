Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 14A15417355
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 14:14:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784556885; cv=none; b=PifUXS/c/UI9+T4oqRN2KhGCUidT88uNWe49Plh2w/NzCpgMAkooF5CMYkqK0McxobaD7Nw5g/aWgiG2ZBM5mxA2hYyYFJWI08VACphO43X6XDinLU4tyBhfVDyDvUulsnAX0K5L5g2vjS7/A1+MYFYheWcz2OU+1oYxQ8GXOXQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784556885; c=relaxed/simple;
	bh=O16S1tdrwxpKnAIppfTKWEZqgmuwxjU24WEZt9y5bwk=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=RAsJCtoP6N9Fmrvkz1NpzUy1sBvzmK2DoXkruMTlbpmetZm1dP4kp8I5wpP2Tg4TOqyCCVgr7OTERkVgwPWBA+RpjsfRxLjP17ncEcaNFIzum5hHenyeov8Gm01o022f8/m0WsVagTbTHSBoUZ7UasiRgGC07LZOha84LSDcLko=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bzsAQI8C; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bzsAQI8C"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2FA571F00A3A;
	Mon, 20 Jul 2026 14:14:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784556883;
	bh=cdQjruX0YMuF8b97n0+Q+tzZtp8hx/TDB3DzwsrWvGg=;
	h=From:To:Cc:Subject:Date;
	b=bzsAQI8CMcNDKGNFIu+uVNWWKy4s83weg1twsmR+pV0gXO1bH+co+y8/YfOXQzsG/
	 hTyxY45nJaz8nPjfHEXMi3p3QPMMnodXYJTdVwJuV+0uRlzO7tkeAZHGYmtbQ6ihFl
	 xWobhCfCWMa8Zb5izHCjZcbrKlHtM+L7oguou6UkQNXTeQABX5voAVGC6meeHB82ot
	 IlYWvYEjGB4uTmeHqCptxu+UbTvUZJgJNSP0UHeGbdPvi4wbPgFE2L+GkueUGr71Ou
	 gxVvZ9DphccHq6Im2M+7r3yp9fC36MMX+eTeLbYj6ZpPSDW/D5WNeJZl6Zl5m4iCix
	 pJutdMrbudHHQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/3] Move NFS filehandle defs into separate include
Date: Mon, 20 Jul 2026 10:14:39 -0400
Message-ID: <20260720141442.783935-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

struct nfs_fh is defined in linux/nfs.h, which also pulls in cred.h,
a pair of sunrpc headers, and uapi/linux/nfs.h. A consumer that
wants nothing but the file handle definition drags all of those
items with it.

Relocate struct nfs_fh and its helpers to a new minimal header:
linux/nfs_fh.h. This series introduces two consumers for this
header. More will follow in subsequent series.

Chuck Lever (3):
  NFS: Add linux/nfs_fh.h
  lockd: Switch linux/nfs.h to linux/nfs_fh.h
  NFSD: Use struct knfsd_fh in struct pnfs_ff_layout

 fs/lockd/svc.c              |  1 -
 fs/lockd/trace.h            |  1 -
 fs/lockd/xdr.h              |  2 +-
 fs/nfsd/flexfilelayout.c    |  3 +-
 fs/nfsd/flexfilelayoutxdr.c |  4 +--
 fs/nfsd/flexfilelayoutxdr.h |  3 +-
 include/linux/nfs.h         | 39 ++---------------------
 include/linux/nfs_fh.h      | 63 +++++++++++++++++++++++++++++++++++++
 8 files changed, 71 insertions(+), 45 deletions(-)
 create mode 100644 include/linux/nfs_fh.h

-- 
2.54.0

