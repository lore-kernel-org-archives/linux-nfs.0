Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 54841435AAA
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 14:24:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786544679; cv=none; b=l0MS5MeLBZqgy/mLomZ6eh4NrGhrPTYZdfqLnBMbWQilho1y4XyFdlBDc9pPMCbA/H6QDtsXsk6z/gUFAvfAQZgT/IPWgkpwkCaS+OWDyB2jOLyED2nOOivyRuxv0apJdIoKq0nMuqWZpgrSCVUEL+VwQE3hCchqpjub61ZTmvQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786544679; c=relaxed/simple;
	bh=Ynb2wAFF6xXVAU9TLG8vgMEi5M51xq4b+eif6XqDTy8=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=rAQEbxVU+SUTJ7atHofWJ2h2ASkVFfIB0+GdV2UW6z5YW4ygAWHQVmoS59Zym6NS7l2g275NJG9eTTO2PV9eqS37GgAMHUic/YfQAdc7jLUFcpGqwi9Ec52MMHA01oGZQllRPO8qnif8++egPyHqLvSqGrCuhZb2g3lTctR6TQc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Dwgw7I2I; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Dwgw7I2I"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 59EF31F000E9;
	Wed, 12 Aug 2026 14:24:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786544677;
	bh=llAN8wj83vBiF/eRt3KDvyj0OaC4Q9dkxaAj+kpMsuY=;
	h=From:To:Cc:Subject:Date;
	b=Dwgw7I2IQxfw7x7BgV+RPNPgRxGVWpEhl9Ih/1bBA6tdeG6yjGG71KdDZVmUjxbS5
	 ou8H+S9w81hNi6Q2a8pb85HQYDeaJd5c1g2rCMn+h9bThTVj0Tf8oXpnsYVIaxzH62
	 QXOuM+rJq1fFjoKWCho75uMKE22AOenaxceCzXUZArHDifKvXkGRfV0yvNMaaMUFBf
	 wjMPQeh8eJ/F6/iA63Zq+peFNsMeTrnavTBMIl9Odg2M38H5KuQiVMZomuSBpQwcuL
	 oXkBsIiO1P0fVjODfd8P27oE/w9dJNZJxX5sHBw+KJsV1s0Xkgvoez2gdSyr+RGB6x
	 shc+n9CkMCiHQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 0/3] Clean up fs/nfsd/vfs.c includes
Date: Wed, 12 Aug 2026 10:24:33 -0400
Message-ID: <20260812142436.35042-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A quick set of clean-ups that permit us to remove more version-
specific material from fs/nfsd/vfs.c.

[ re-posting v1; the first post did not include linux-nfs@ ]

Chuck Lever (3):
  NFSD: Make the write verifier reset helper available outside vfs.c
  NFSD: Move NFSv4-specific CLONE logic into nfsd4_clone()
  NFSD: Remove xdr-related headers from fs/nfsd/vfs.c

 fs/nfsd/nfs4proc.c |  27 ++++++++--
 fs/nfsd/vfs.c      | 129 ++++++++++++++++++++++++++-------------------
 fs/nfsd/vfs.h      |  14 +++--
 3 files changed, 108 insertions(+), 62 deletions(-)

-- 
2.54.0

