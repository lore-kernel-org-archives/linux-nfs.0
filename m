Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 292B12E5418
	for <linux-nfs@vger.kernel.org>; Tue, 24 Feb 2026 19:24:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771961080; cv=none; b=JUdGQ2ZfLv7HHlGcxXxJ8MF/An7yh3wkh/ZAU/KP/sV/+oOiWdqYWfbQQBbIO+LtHlY5d2yZuK/oXzKCW+K9//Of+ywJJkgNuanO69u9ZvgjIQkHN8GvTfSN9jqrC0cHKTZelp486D0o+6VZzm/b3rQx+Te/zy/+VMGL8zVtdJY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771961080; c=relaxed/simple;
	bh=qu98V+Mc+qEmM8j+9Fhwi8ZmP1xlXjOtBw80SJKnqMA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=O0JLuaZBdMkUFXvVuqAFPU/LU/r8yn11F58fCbOmziH9WWOp/QLoK3b9kN4XVJisWqYVoaIqNgeuu0PF0rZxb5ADS3iCR4zCWoBnruaHD++gTG7G5R61EwniFHQe6/dfZYxnd+XMfnqz/miB/AvWD/s5EkjgGnQYcbSiTwVV3wc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=r+DfTVxm; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="r+DfTVxm"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8AC9BC116D0;
	Tue, 24 Feb 2026 19:24:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771961079;
	bh=qu98V+Mc+qEmM8j+9Fhwi8ZmP1xlXjOtBw80SJKnqMA=;
	h=From:To:Cc:Subject:Date:From;
	b=r+DfTVxm2u8Jl2KF8jzmMUPyNkQnr/uFvUr+DrfjqlK4/hexz704nVMR705xQomVr
	 l0lzgtnkeDu+lh/z2BwpVHudkkPuqHW1pBZ/aionkbKE8zfeAWQKx18uuDAu0kUy5d
	 tey1eC/hvKcJxAEg41py6ekdfyEhvHy1Af5t+25nSqXzIELWeBu6Xm1dt95Mhbv70q
	 WSFrvLD5LvCngFpdejd7IdKR5KPYR7+feT/PbupPuGUsGgthho795zrDYIx562n2TE
	 q5qiQd0da2PwgJ1G+198IOBa+xaVEzLpOJfH0KeMMRI0w9ymrL2OHgyUd7bXgK46nY
	 O96by/FeLZSRQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna.schumaker@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: [RFC PATCH v2 00/11] NFS/NFSD: nfs4_acl passthru for NFSv4 reexport
Date: Tue, 24 Feb 2026 14:24:27 -0500
Message-ID: <20260224192438.25351-1-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi,

This patchset aims to enable NFS v4.1 ACLs to be fully supported from
an NFS v4.1 client to an NFSD v4.1 export that reexports NFS v4.2
filesystem which has full support for NFS v4.1 ACLs (DACL and SACL).

The first 6 patches focus on nfs4_acl passthru enablement (primarily
for NFSD), patch 7 adds 4.1 nfs4_acl passthru support (DACL and SACL),
patch 8 optimizes particular nfs4_acl passthru implementation in NFSD
to skip memcpy if nfs4_acl passthru isn't needed, patches 9-11 offer
the corresponding required NFSv4 client changes.

This work is based on the nfsd-testing branch (commit 22f4955340fc).

This patchset is marked as RFC because I expect there will be
suggestions for possible NFSD implementation improvements.

All review appreciated, thanks.
Mike

v2: rebased v1 ontop of nfsd-testing commit 22f4955340fc

Mike Snitzer (11):
  exportfs: add ability to advertise NFSv4 ACL passthru support
  NFSD: factor out nfsd_supports_nfs4_acl() to nfsd/acl.h
  NFS/NFSD: data structure enablement for nfs4_acl passthru support
  NFSD: prepare to support SETACL nfs4_acl passthru
  NFSD: add NFS4 reexport support for SETACL nfs4_acl passthru
  NFSD: add NFS4 reexport support for GETACL nfs4_acl passthru
  NFSD: add NFS4ACL_DACL and NFS4ACL_SACL passthru support
  NFSD: avoid extra nfs4_acl passthru work unless needed
  NFSv4: add reexport support for SETACL nfs4_acl passthru
  NFSv4: add reexport support for GETACL nfs4_acl passthru
  NFSv4: set EXPORT_OP_NFSV4_ACL_PASSTHRU flag

 fs/nfs/export.c          |  23 ++++-
 fs/nfs/nfs4proc.c        | 112 +++++++++++++++-------
 fs/nfs/nfs4xdr.c         |   2 +-
 fs/nfsd/acl.h            |  11 ++-
 fs/nfsd/nfs4acl.c        |  69 +++++++++++++-
 fs/nfsd/nfs4proc.c       |  32 +++++--
 fs/nfsd/nfs4xdr.c        | 194 +++++++++++++++++++++++++++++++++------
 fs/nfsd/nfsd.h           |   5 +-
 fs/nfsd/xdr4.h           |   2 +
 include/linux/exportfs.h |  22 +++++
 include/linux/nfs4.h     |  23 ++++-
 include/linux/nfs_xdr.h  |  11 +--
 include/linux/nfsacl.h   |   7 ++
 13 files changed, 431 insertions(+), 82 deletions(-)

-- 
2.44.0

