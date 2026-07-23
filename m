Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 033D83C09F2
	for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2026 18:20:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784830855; cv=none; b=RK2RN+Rt10gmMceDkzGqU5Hhot/14HkEhAgX1XVxrybN2v91l0LG147VjHkpMHLilO5EdDl9T9z3kwtt/gaNe7UbhG2uw4vF/16/XaYUwliD2aDmZw5L5oZaEVG3zM7VH2345rN1ddbgsy6j7qEqoAwBII2FTGkjbSfgOe0p9Y8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784830855; c=relaxed/simple;
	bh=Z022369DOyUz75SV/XeeAKIUVM9KC4Unr/zf63AFv7E=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=aiFTL8ymYUVfmtQXwOI3O5d5jFFKxS6+BfooPV2brHBuGeo8vnU9AwTt9O56mwWXIbyZwK0Yq8UtRn6g2oLUlDt8zwCfQcA3UwLABINL8mSXEji1+uTDQ7U+I+S04H09EqpgZ5nsf6wSPX2hA7v0pgWwhoAwmgGEiaGSli1tx7w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C0FCF1F000E9;
	Thu, 23 Jul 2026 18:20:44 +0000 (UTC)
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] NFSD: Decouple the write path from NFSv3 XDR constants
Date: Thu, 23 Jul 2026 14:20:41 -0400
Message-ID: <20260723182043.990391-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

NFSD's internal write helpers are meant to be NFS-version-agnostic,
yet nfsd_write() has taken an NFSv3 stable_how value lifted straight
off the wire, and the NFSv4 WRITE and COPY paths borrow those same
NFSv3 constants for their own stable values, correct only because
stable_how and stable_how4 happen to share numeric values. That
coincidence is the debt: it binds version-neutral VFS helpers to one
protocol version's XDR and leaves NFSv4 depending on nfs3.h.

To remove the API's dependence on version-specific wire protocol,
change the generic VFS helpers to take IOCB flags instead of a
stable_how value. This removes a dependency on the nfs3.h header
in code that is not related to NFSv3.

Chuck Lever (2):
  NFS: Move definition of enum nfs3_stable_how
  NFSD: Replace nfsd_write()'s "stable" argument with "iocb_flags"

 fs/nfsd/nfs3proc.c       | 17 ++++++++++++++++-
 fs/nfsd/nfs3xdr.c        |  2 ++
 fs/nfsd/nfs4proc.c       | 18 ++++++++++++++++--
 fs/nfsd/nfs4xdr.c        |  2 +-
 fs/nfsd/nfsproc.c        |  2 +-
 fs/nfsd/vfs.c            | 30 ++++++++++--------------------
 fs/nfsd/vfs.h            |  6 ++++--
 fs/nfsd/xdr3.h           |  2 +-
 include/linux/nfs.h      |  9 ---------
 include/linux/nfs3.h     |  8 ++++++++
 include/linux/nfs4.h     |  6 ++++++
 include/trace/misc/nfs.h |  1 +
 12 files changed, 66 insertions(+), 37 deletions(-)

-- 
2.54.0

