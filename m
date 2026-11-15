Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794767368;
	b=5kzuJm7Gb9W3WHdv+44Yp9VT5F9tQQAKnkyv8OA2wPxitUm9PjynwbmIyCj5qJNramEW
	 jU5w+kOpZadZT4ItBR19uu7Wuqzo8+ID576TB0WZYvZvOK1Nyw4JPYONeZ/5tFTmQ/Dl0
	 nQK0jSd98LK0QSTok0LLxtTTd15fu0BRCIQ1ZjLlDbvtl9uRdhkhasE+B/vuLSTlR3g8p
	 TiK3QJle6NOql6OgRST5SKKlyyD4VO5falGwx5iZ7BTIYDK5BQKmQHRe5naseuOSYMzuH
	 aZf2JL51uW+q51A0dJJPYSyU4Wt+6OHghagJOX3r5YVWFoNFKNkPXSjFvc7byXwYEmA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794767368;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=WxrxzMdPhMKXyE8awWVCsqvmbDlXmO6SWVz7gLuVilg=;
	b=IRrL1MWDukzBH8GbMKO9flYMcUxAOcbVg9vEy2i+LsKQJ2S85u7kbuX5cFge64mKpMm9
	 cHY4ytRxPo3B/qZ9TiAL5oxvx78RZFf86sPU4Tk0+hA8AORMnJbDfRhrxgGwrCBnHU0ll
	 kCU653kJ2ryFlUqOkAuIjy7k3ljZ3UDLssM4LSbO9UXqS+sHNIHENfun1BebJjZb1OzRc
	 A8fIDw9IOEihmkAPkiVkQX43I/u1y7/YeA+epTF4jBw+cT5Fc2Xd8Q6I+MqY6q9untS1h
	 awjl9np+C8tcXaSFCX2XXAg6thBqT6S7Y3eJVvBuzXDyoeSmtR4O7ly7AFWZdOwXt8A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QXFR2du+;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 38685606A327
	for <linux-nfs@vger.kernel.org>; Sun, 15 Nov 2026 18:29:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QXFR2du+
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6B04E1F000C4;
	Sun, 15 Nov 2026 18:29:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794767367;
	bh=WxrxzMdPhMKXyE8awWVCsqvmbDlXmO6SWVz7gLuVilg=;
	h=From:To:Cc:Subject:Date;
	b=QXFR2du+o18iBG6OADLbxRbykHvOv5dFvrpn01+iI347dECuD+zTSaqvUCJYI5Hpa
	 sTePBqfrhQPrdU6KNc6t76ha169N3PnAexyRmd+g0zje9/xPI8xehSa7A3c9QLfMK4
	 96v/gnVSM1fKGlMR4rfeGMueAyx/bwZkOZ+usDWABuJ99usT+djxTHGLW5I+aXV11x
	 iQ0X2fKygl3J3VwttGTzXe+kQbNZ3gcnsK2Nn+fOk5rPbQ230D0OABdfY9+u5khkS/
	 f1U77KuwukfVEMJUN00Iz7LzVdzmlF0IEetfPyVNbzgbLKolXaVHHgRN2f2J26i34y
	 I6dydqKGCeufw==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	torvalds@linux-foundation.org
Cc: anna@kernel.org
Subject: [GIT PULL] Please Pull NFS Client Bugfixes for Linux 7.4-rc
Date: Sun, 15 Nov 2026 13:29:26 -0500
Message-ID: <20261115182926.1408630-1-anna@kernel.org>
X-Mailer: git-send-email 2.56.1
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

Hi Linus,

The following changes since commit 7475ea8b58616b33c04afb976cf0fbaad9dd63fb:

  Linux 7.4-rc2 (2026-11-08 16:22:20 -0800)

are available in the Git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-7.4-2

for you to fetch changes up to 151d95a1e696979a7d54b23c96338754be2fcc1f:

  NFSv4: Prevent indefinite waits for out-of-order OPEN stateids (2026-11-12 14:20:11 -0500)

----------------------------------------------------------------
NFS Client Bugfixes for Linux 7.4-rc

Bugfixes:
 * Various NFS and SunRPC fixes from Avi Weiss
 * Various localio fixes from Mike Snitzer
 * Delegated timestamp fixes from Jeff Layton
 * CB_NOTIFY_LOCK fixes from Olga Kornievskaia
 * Various sunrpc, flexfiles, and xprtrdma fixes from Tim Menninger

 Thanks,
 Anna

----------------------------------------------------------------
Avi Weiss (13):
      NFSv4.1: retain MDS I/O until both thresholds are met
      NFS: honor UTIME_NOW atime with explicit mtime
      NFS: update ctime for atime-only UTIME_NOW requests
      NFS: Fix inverted cross-directory rename check
      NFS: restore directory index when resuming readdir
      SUNRPC: wake poll waiters when an empty pipe is unlinked
      sunrpc: instantiate rpc_pipefs dentry before publishing it
      SUNRPC: preserve fatal network errors during RPC binding
      SUNRPC: preserve timeout policy when cloning clients
      SUNRPC: preserve transport security policy when cloning clients
      SUNRPC: Fix TCP-with-TLS transport class identification
      SUNRPC: Balance switch queue length on transport removal
      SUNRPC: Balance queue accounting when relocating a task

Jeff Layton (3):
      NFS: don't let delegated c/mtime stamps go backward
      NFS: stamp after the server's ctime when truncating under delegated times
      NFS: stamp after the server's ctime following a CLONE

Mike Snitzer (3):
      NFS/localio: hold the client across an asynchronous LOCALIO probe
      NFS/localio: probe again for LOCALIO when localio_enabled is set to Y
      NFS/localio: give the LOCALIO probe a short timeout of its own

Olga Kornievskaia (2):
      NFSv4: wake blocking lock waiters when a delegated lock is released
      NFSv4: remember that the server may send CB_NOTIFY_LOCK

Tim Menninger (5):
      xprtrdma: serialize unmap_sync with xprt_disconnect
      pNFS: avoid repeatedly cancelling I/O for the same lseg
      SUNRPC: add request-scoped disconnects when cancelling tasks
      NFSv4/flexfiles: limit transport disconnects when cancelling I/O
      NFSv4: Prevent indefinite waits for out-of-order OPEN stateids

 Documentation/filesystems/nfs/localio.rst |  12 +++
 fs/nfs/delegation.h                       |   2 +
 fs/nfs/dir.c                              |   4 +-
 fs/nfs/flexfilelayout/flexfilelayout.c    |  19 ++++-
 fs/nfs/flexfilelayout/flexfilelayout.h    |   1 +
 fs/nfs/inode.c                            |  69 ++++++++++++-----
 fs/nfs/localio.c                          | 121 ++++++++++++++++++++++++++++--
 fs/nfs/nfs42proc.c                        |  25 ++++--
 fs/nfs/nfs4proc.c                         |  26 ++++++-
 fs/nfs/pnfs.c                             |   2 +-
 include/linux/nfs_fs_sb.h                 |   1 +
 include/linux/sunrpc/sched.h              |   4 +
 include/linux/sunrpc/xprt.h               |   5 ++
 net/sunrpc/clnt.c                         | 104 ++++++++++++++++++++-----
 net/sunrpc/rpc_pipe.c                     |   3 +-
 net/sunrpc/sunrpc.h                       |   8 ++
 net/sunrpc/xprt.c                         | 107 ++++++++++++++++++++++++--
 net/sunrpc/xprtrdma/frwr_ops.c            |  89 +++++++++++++---------
 net/sunrpc/xprtrdma/transport.c           |   2 +
 net/sunrpc/xprtrdma/verbs.c               |  16 +++-
 net/sunrpc/xprtrdma/xprt_rdma.h           |  10 ++-
 net/sunrpc/xprtsock.c                     |   2 +-
 22 files changed, 527 insertions(+), 105 deletions(-)
