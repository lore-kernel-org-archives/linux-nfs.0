Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BC56C385D86
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 18:41:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784313675; cv=none; b=ozzeBFZL5HsRvVntEcbo7m5aJ8uzYU+T+ayuAqOHAUSx0VjALgVJk2TM+9NGjg1YbgxsTt7hWH4rlJFTwIzDtChqTvm81eR8ynupWg8u7MNtgcFztoDTx5AlDzKt+Y1ZFUadBn8lOgC8t4RnfXC0PoCKaAht32YQLA7SX4oRJfE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784313675; c=relaxed/simple;
	bh=Nsg+t4dMpgLqqXB6LcgqBLo7UtmDSEH0esDVWcTriq4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ayAclwrAP76aMH/oPYQOlhbG0Vd3UQVbwkYVFXsA/UiUzqtsughhuaAtX60DfWVjXRDaEn1V9wW2dnHGloGDZeXnrSM0f841ID4FiJLZ1TFgOfjXesQMF5iRUIrnvwgMoU4hEV0iOedjfEPgY/DL+9YIQQSBlnFjIWvim/pzwy8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Ma6WWzpF; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ma6WWzpF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DF2C51F000E9;
	Fri, 17 Jul 2026 18:41:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784313674;
	bh=D3h/X0KR0kk/7RvJoZJbZF7Za5k2BhMbeOYuqJ0ClpQ=;
	h=From:To:Cc:Subject:Date;
	b=Ma6WWzpF5m5LtcmPPcZ3MjZZ0Ous5UzuKXoyT1NJ7kDATh9RZ93amMkSi0M9jCfsU
	 tvizl7yH2ABfc0KeFUsAzcksWV46s0xSrYbgaZGGGRrd1FAl5/Cqk9At3cpgCSe8bG
	 7fdEo6CJh71rfFPaBqx5s2OlRyt48Hmtuhnrl+dB8WwmOC64I8c08gKX2r2UQe5jS0
	 Fc6dleUH+kAF4Q5zMOwKfmiFqHFw7Z3O5YF+GzTBWjchbtRrII/SPPgsQsUmN9bcqk
	 QZW+a5grGUtFGjnbep7sfWn/s40aZ5pT/JZsilvIH1KsVfTnkCpvs45Sb8FqpUbg0f
	 5igCwQBymjSCg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/6] NFSv4-related tidying
Date: Fri, 17 Jul 2026 14:41:06 -0400
Message-ID: <20260717184112.507548-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Now that Neil's vfs_create() rework has been applied to nfsd-testing,
I feel more comfortable sending along more of these clean-up patches.
The goal is to reduce dependencies on single large individual headers
that pull in items that are irrelevant in many cases.

Chuck Lever (6):
  NFSD: Move XDR encoding helpers out of xdr4.h
  NFSD: Move pre-xdr'ed status codes out of nfsd.h
  NFSD: Remove two unused NFSv4 constants
  NFSD: Relocate NFSv4-internal constants to state.h
  NFSD: Evacuate NFSv4 entry-point prototypes from nfsd.h
  NFSD: Move nfsd_v4client() out of nfsd.h

 fs/nfsd/blocklayout.c        |   1 +
 fs/nfsd/blocklayoutxdr.c     |  11 ++
 fs/nfsd/export.c             |   2 +
 fs/nfsd/filecache.c          |   1 +
 fs/nfsd/flexfilelayout.c     |   1 +
 fs/nfsd/flexfilelayoutxdr.c  |   1 +
 fs/nfsd/lockd.c              |   1 +
 fs/nfsd/nfs2acl.c            |   1 +
 fs/nfsd/nfs3acl.c            |   1 +
 fs/nfsd/nfs3proc.c           |   1 +
 fs/nfsd/nfs3xdr.c            |   1 +
 fs/nfsd/nfs4acl.c            |   1 +
 fs/nfsd/nfs4callback.c       |   1 +
 fs/nfsd/nfs4ctl.h            |  83 ++++++++++++
 fs/nfsd/nfs4idmap.c          |   1 +
 fs/nfsd/nfs4layouts.c        |   1 +
 fs/nfsd/nfs4proc.c           |   2 +
 fs/nfsd/nfs4recover.c        |   1 +
 fs/nfsd/nfs4state.c          |   2 +
 fs/nfsd/nfs4xdr.c            |  93 +++++++++++++
 fs/nfsd/nfscache.c           |   1 +
 fs/nfsd/nfsctl.c             |   2 +
 fs/nfsd/nfsd.h               | 236 +--------------------------------
 fs/nfsd/{nfsd.h => nfserr.h} | 248 +----------------------------------
 fs/nfsd/nfsfh.c              |   1 +
 fs/nfsd/nfsproc.c            |   1 +
 fs/nfsd/nfssvc.c             |   8 ++
 fs/nfsd/nfsxdr.c             |   1 +
 fs/nfsd/state.h              |  19 +++
 fs/nfsd/vfs.c                |   2 +
 fs/nfsd/xdr4.h               | 139 --------------------
 31 files changed, 250 insertions(+), 615 deletions(-)
 create mode 100644 fs/nfsd/nfs4ctl.h
 copy fs/nfsd/{nfsd.h => nfserr.h} (50%)

-- 
2.54.0

