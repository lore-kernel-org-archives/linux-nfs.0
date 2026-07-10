Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DE0E73B0AE3
	for <linux-nfs@vger.kernel.org>; Fri, 10 Jul 2026 20:51:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783716680; cv=none; b=pYUkip4NUYzfblZ6rFZ1/TkBoFfAkYG0hlt4XcyNyIDBdsGuVejtU7WdC7zJ8pm1t5zmgGJQQRX0RyR09NPuEQJdfMFW0GqifHmmeonkJi+Wouf+cSDZ/s8hKhTdQfBD9dgBqUe/bk7CrcL4Va5qy1MPlGNsyZMtA4iKCQekGLk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783716680; c=relaxed/simple;
	bh=zbxFsuFgy5nlVMqKFyf+0wuR51+5RSt8f53gKKY2awc=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Y8sUz+b4S/6MdmDpLSVrc9ynbtq87qEC7DwmWWAsouN69X0dij+Qi4Vmi4PU29QSpzwCN275qUL0dOOYfM2gpkUXlKqCh1+gFNj9SPIO2dE1wB0uETxKaQY3ef3mneNgRu9edwAkl1xu6DEFXKJBel+9PQFTpqKp2dvlfroG//0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Qwlrfutb; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Qwlrfutb"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2060C1F000E9;
	Fri, 10 Jul 2026 20:51:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783716678;
	bh=ZmDn0mWRibkfRO1OuY0hgxNvlvxGWma+ZpJnKkA8VvA=;
	h=From:To:Cc:Subject:Date;
	b=QwlrfutbO/aXbhonIxLerATj5thEQ37nx5NKdLdZbdDIzLPd52B+TTYUYp88uW2u1
	 uVcARMjDsE1gBNggVRe3iR7h0nO7Vgtuc1WCIP8Kd9OxK7dg9udvFGmLz1fVa+fiSj
	 IMu7DAbmuTBXq00Z2TGflxEnIa4uTvVUTcGLO90RETK7tso2UNNEqqAqPlq9xHOG5I
	 VuO5HkMmtfENyFuMQEkR4RRaVyQOUoF0sPOvFNp3ZD+xKpcbWQWqp2Vg4O45/CLSFW
	 nzZWQ72JEGilVuGghuOEnhIDP4eJhOyGnak3Wv5DSZFTVfPqDLEq8fp1nlMVKnDiuu
	 VR+T6lm934rNg==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	torvalds@linux-foundation.org
Cc: anna@kernel.org
Subject: [GIT PULL] Please Pull NFS Client Bugfixes for Linux 7.2-rc3
Date: Fri, 10 Jul 2026 16:51:17 -0400
Message-ID: <20260710205117.622337-1-anna@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi Linus,

The following changes since commit 8cdeaa50eae8dad34885515f62559ee83e7e8dda:

  Linux 7.2-rc2 (2026-07-05 14:44:06 -1000)

are available in the Git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-7.2-2

for you to fetch changes up to 27934d02cbeb8a957dd11c985a579e58d30c5270:

  NFS: Charge unstable writes by request size, not folio size (2026-07-08 14:43:40 -0400)

----------------------------------------------------------------
NFS Client Bugfixes for Linux 7.2-rc3

Bugfixes:
 * SUNRPC: Release lower rpc_clnt if killed waiting for XPRT_LOCKED
 * SUNRPC: Pin upper rpc_clnt across the TLS connect_worker
 * NFS: Include MAY_WRITE in open permission mask for O_TRUNC
 * NFS: Charge unstable writes by request size, not folio size

 Thanks,
 Anna

----------------------------------------------------------------
Benjamin Coddington (2):
      NFSv4: include MAY_WRITE in open permission mask for O_TRUNC
      NFS: Charge unstable writes by request size, not folio size

Chuck Lever (2):
      SUNRPC: release lower rpc_clnt if killed waiting for XPRT_LOCKED
      SUNRPC: pin upper rpc_clnt across the TLS connect_worker

 fs/nfs/dir.c                |  2 ++
 fs/nfs/internal.h           | 12 +++++++-----
 fs/nfs/pnfs_nfs.c           |  2 +-
 fs/nfs/write.c              | 14 ++++++++------
 include/linux/sunrpc/clnt.h |  1 +
 net/sunrpc/clnt.c           | 19 +++++++++++++++++--
 net/sunrpc/xprtsock.c       | 16 ++++++++++++++--
 7 files changed, 50 insertions(+), 16 deletions(-)
