Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 48DBD448D10
	for <linux-nfs@vger.kernel.org>; Tue,  4 Aug 2026 16:42:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785861792; cv=none; b=ruGjvfoTHnPF3jcvKT67PV9pTgcQD5QAUoPRmBdRCN1xvDhMz+XFD1XfRpHXddjpfTMeeEICCE5ft1+02/vCj5905iNzgnlywzJ7s3y0cIzfTYeMV6X0HS4joWl+TbMdhFSzKgpr/iXrmlLxYn5wt1I0u3I0xUgRB468AYdMGGI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785861792; c=relaxed/simple;
	bh=zxmCQ/TM1yGOtLlO2mXtI6/WFkTuiDSwmyHqLnUH6c0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Gwq9QQem03HKPmMtt2ogwwZytpvXLWqTEbtyC4Jb9D7A98K+z0kjs7gAOh1rWQTbfPCZhv/ZWC/NAsfYkh+lWf0kKPDMuYSjRG8EzQ0iue+a2pfgwfp5IWY7LWakLHSQu1vzXhJ+dWlSwmtFKdf+Kj2q0kjOhRmvs7Q5JSXk+V8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TgEZnxn7; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TgEZnxn7"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AD95C1F000E9;
	Tue,  4 Aug 2026 16:42:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785861776;
	bh=9PAGdFJqDLiGdSXN1KEY6wg0fZ9vHbYBaHKSqaHgmeA=;
	h=From:To:Cc:Subject:Date;
	b=TgEZnxn7j7g6plzitHpc25Xue46MBHIQnvFtIDxwv9MRvlWpxRJYH6qgwHnk3Rgo5
	 E30T5GG4lnlZXntlzenidvwbUHr26BZy7tUf7ykTyEAzNiCN1K8siR9RHnG0Kl8SNZ
	 4z6KXwnEMn74WOsXTBmSsXIUCl9StuhD4BY+Lu1LKoRy6mRA6TJy8lCYQ3d01/RTtI
	 9J+m+O1wAnSlp4qvK0wsTKY0xHhSfYqaHDLgaRM1gpibd8hAsJ+QyZ7evcxpKi6xVG
	 TMovLHrePVhf2jM7qxYNssl+M8yxAdl27VfPjQILk8RC8aRlsB9pXMMX62ZbAG17yW
	 wZxFGBy/LjvLA==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	torvalds@linux-foundation.org
Cc: anna@kernel.org
Subject: [GIT PULL] Please Pull More NFS Client Bugfixes for Linux 7.2-rc
Date: Tue,  4 Aug 2026 12:42:54 -0400
Message-ID: <20260804164254.463083-1-anna@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi Linus,

The following changes since commit 1590cf0329716306e948a8fc29f1d3ee87d3989f:

  Linux 7.2-rc4 (2026-07-19 13:54:41 -0700)

are available in the Git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-7.2-3

for you to fetch changes up to e053b624f5d36669756990743346157be9f68c34:

  NFSv4.2: fix nfs4_listxattr size accounting (2026-07-31 13:27:25 -0400)

----------------------------------------------------------------
More NFS Client Bugfixes for Linux 7.2-rc

Bugfixes:
 * NFS: Pin the 'struct nfs_server' during a FREE_STATEID call
 * NFS: Decrement refcounts if allocating nfs_free_stateid_data fails
 * NFSv4.2: fix nfs4_listxattr size accounting

Thanks,
Anna

----------------------------------------------------------------
Achilles Gaikwad (1):
      NFSv4.2: fix nfs4_listxattr size accounting

Anna Schumaker (2):
      NFS: Pin the 'struct nfs_server' during a FREE_STATEID call
      NFS: Decrement refcounts if allocating nfs_free_stateid_data fails

 fs/nfs/nfs4proc.c | 27 +++++++++++++++++++++------
 1 file changed, 21 insertions(+), 6 deletions(-)
