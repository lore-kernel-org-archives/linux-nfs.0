Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 64DA646DFFF
	for <linux-nfs@vger.kernel.org>; Tue, 21 Jul 2026 16:23:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784650989; cv=none; b=ZabEpEoKFe5r1PlpvYZyucyfZ2H8Qe/GUCBr1mLreJmUzmSlwBKofOAoxfj1sR1k5YUp138tboLy9v6zpOsfKfqG8+zYgKzSr1tifU11K9f1La8zmM+uYwt1FT6ndqSDhdQsMLNg/KRE+xeMZ4mlo+92qwtxdz6T27UmuCciSFQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784650989; c=relaxed/simple;
	bh=KpELufdu03AAmix1JR5RNSr19eE4x4TtS1A1P0emjK4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=nGuHXkM+qmHkOLecwhoQ5ZaVX9a94pLzwv+gWgdFUBe9bEuV4ffO+/4rX4PBw6OHkI0mHCR8kwtjJU0n6JMdWA6SLlvJoWQdqngprG0crHatd1mJrCgXQRmSPXaE6dgCnXacOjk9/ebPP1x7/hbnDVSiU55/nSYsuxhjhKSs4VE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Kh3cJtxi; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Kh3cJtxi"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C44E91F00A3A;
	Tue, 21 Jul 2026 16:23:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784650988;
	bh=vlG84+gEYTKzjEVT7Z+F0LG7lnVIQXMPMgS2Vo3Zk/I=;
	h=From:To:Cc:Subject:Date;
	b=Kh3cJtxi48V5wMSAmqHgcCVK29Vse4PXzZJyRdiwsgU/SSYjzZLupuOXDnwI+qEdE
	 II+dm3/9gs/fsiD6eRxDzS8Q29hvczBPh32NJXdd73l04GIRlj8rN593pZ7oSlzLms
	 z13BIvMnuQjWakvjfXfnHdb/YgdKD1RmQiZWYiA8TkYX/PERTvmhx/xMftwwklEdmJ
	 qpS/ARbf1pD6jVPhVgUOdTsr4/GJMlH8BZAECDEUZXZRvRYOk0zq59Ae/mMiW3hY2R
	 GkFPNyJv3E0bHYVcwxxX9uY/oWupGmd1tXQo8yL5W58iaQGc9/7MB0q4jECuQNaghc
	 /KW2bPIB+K5Cg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/4] Confine the inter-server copy interface to fs/nfs_common
Date: Tue, 21 Jul 2026 12:23:02 -0400
Message-ID: <20260721162306.894558-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Inter-server copy has drawn a steady trail of use-after-free and
reference-leak fixes: 75333d48f922, 34e8f9ec4c9a, and d2c343c51caf
among them. They cluster on one object, the source mount that the NFS
client creates and opens while NFSD decides when it may be torn down.
The bookkeeping that tracks it, added by f4e44b393389, has needed
three follow-on repairs of its own. Splitting an object's lifetime
across two modules that are forbidden to call each other directly is
what keeps producing these bugs.

The fix in 75333d48f922 narrowed that split rather than adding
another rule to it. NFSD stopped reaching back through the broker to
deactivate the source superblock, and post-copy clean-up became the
laundromat's business alone. What the fix did not do was retract the
interface it had just stopped using, so the client-side registration
machinery has sat unused since (patch 1).

One implicit contract between the two modules is still in force.
Reading the client ops table without synchronization is safe
only for reasons that live on the caller's side: an inter-server copy
holds an active vers=4.2 mount of the source, that mount pins the
nfsv4 module, and unregister runs only at module exit. Patch 3
replaces that with synchronization the broker owns, so the argument
no longer depends on how a caller in another subsystem manages
mounts.

What remains after that is textual. The header still declares both
sides' interfaces, so each implementation parses the other's types
and inherits its includes, which is how <uapi/linux/nfs.h> reaches
nfs4proc.c. Once the knowledge only NFSD holds has moved into the
broker, splitting that header is mechanical.

None of this fixes a live bug, and the source mount's lifetime still
spans both modules. What changes is that the broker no longer relies
on rules its callers enforce. Inter-server copy behavior is meant to
be unchanged throughout.

Chuck Lever (4):
  nfs_common: Remove unused nfs_ssc_client_ops infrastructure
  NFSD: Hoist nfs42_ssc_open() into fs/nfs_common/nfs_ssc.c
  nfs_common: Synchronize access to the SSC client ops table
  NFSD: Split linux/nfs_ssc.h

 fs/nfs/nfs4file.c        |   1 +
 fs/nfs/super.c           |  25 --------
 fs/nfs_common/nfs_ssc.c  | 126 ++++++++++++++++++++++++---------------
 fs/nfsd/nfs4proc.c       |  22 ++-----
 fs/nfsd/nfs4state.c      |   2 +-
 fs/nfsd/xdr4.h           |  13 ++++
 include/linux/nfs_ssc.h  |  69 ++++-----------------
 include/linux/nfsd_ssc.h |  38 ++++++++++++
 8 files changed, 147 insertions(+), 149 deletions(-)
 create mode 100644 include/linux/nfsd_ssc.h

-- 
2.54.0

