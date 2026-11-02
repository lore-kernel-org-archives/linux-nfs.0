Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793651482;
	b=nDve3vOmoP//EEObjvcdfA66nGj95qp3WJxNXc/zVKyNu0rbMWpq0BpKzEvUifoTiVrf
	 bK7Tl/WCrb4ywg+SN12pJMX/chZR3QtjDRDC68ihB5qODwvKNuW88oTMyWIZX9v5C7t/d
	 lnmUSwyzVxRf44COMUDpmQnC7aAiGb6Lz3Nzm3kb2twnVA8tVaCS1Ou0hjbGLwEAKMSvR
	 L/epD58ROlZcYAnJcgN6jzfp3pMROeRfAfJ9UUyawMZXwaGgZBrrbfdVnyfLbNI/QkF22
	 qSDZaDg6fsWR2TOre+1Or7c8zABHA57IF6qbc6BxqpkqfXmmwcgkVDw4uVlC7BoTsjg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793651482;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=2fMN3WBtI3u0oxmrPVquXsLBrwfApvpq32Jn76MXxEI=;
	b=epeBZVwkU71rOd7MgsI0ALd6pY+XfmqiAa88CscfyREhHzkl5djzc3LqfaNvdXczVB6v
	 4ns6wDg2YMKWSgj15QGZdOSCEjMXckhQmC7AMAgqSAIgaBbWu2F7yLlIl8ISqh1F/dyu0
	 PU69FUyRIwoptI3GP8HKBL5wm5Hv83yPbA1Wr9QahHkb5sLH7NErvLfj96IDfXLBJRFcT
	 piVFMb5CdIeJxtHjVeJAIuSKqi/dRB+PKfi4HMf7v6RACqeNp41pDldR2umHqnz9nC227
	 QoNLJjDDuZk5OZiKnzaQNcQMcErySE6mgRJf+zOhYP52KYjQ8SoWCNI+MkvucznYPPA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LXE2nWfy;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6EDB4606A329
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 20:31:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LXE2nWfy
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BD54A1F00A17;
	Mon,  2 Nov 2026 20:31:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793651482;
	bh=2fMN3WBtI3u0oxmrPVquXsLBrwfApvpq32Jn76MXxEI=;
	h=From:To:Cc:Subject:Date;
	b=LXE2nWfyaPV5K4sU8X78Y5gJT5RwU5+i7poAVX3EuiEuNo38CpqAsiyyO2ATUENvR
	 iDeTBkAayh/F0LlPHi59H2leXhqS6X5EQBs4Fu9COk2T+C1MMbWzOfVosMFpQkPJzt
	 InTHMRBp6vC9GlQnmmtmPgIKBo+jB6eRSH/ajxraKcfx1sA17hXFtCGLGKi0s4kgF3
	 Zlm4LA1H9ynZ8ltEX3HxaPCi32TwhtnlLxy2Xo5EItSfLYtnuBluQEtjf3xPZgGDKM
	 ELBuKZoOKosKrq0zYd8qzsK8f3vQyySIoeG+U4kvB8r64a4M7FKb80lHN0xB7s5chk
	 Crn+S2dwKhx9A==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/4] NFS: keep final releases out of writeback
Date: Mon,  2 Nov 2026 15:31:16 -0500
Message-ID: <20261102203120.14600-1-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
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

v2: https://lore.kernel.org/linux-nfs/20260928185751.98682-1-snitzer@kernel.org/
v1: https://lore.kernel.org/linux-nfs/20260911184239.90154-1-snitzer@kernel.org/

Releasing an open context closes NFSv4 state and drops what may be the
last reference to the dentry, the inode and the superblock.  The flusher
holds sb->s_umount and has set I_SYNC on the inode, so it must not do
either final release.  It would wait for itself, on s_umount in
deactivate_super() or on I_SYNC in evict().  A write normally avoids
this because the RPC release callback of a WRITE or COMMIT runs on
nfsiod.  This series fixes the four ways in which writeback can still
run such a release itself:

Patch 1: nfs_write_error() completes a write that fails before the
client sends it, and it does that in the submitter.  A client hit this
deadlock in the field when its server began to return AUTH_TOOWEAK.

Patch 2: nfs_initiate_pgio() and nfs_initiate_commit() drop their task
reference with rpc_put_task().  If the task has already completed, that
call runs the release callback in the submitter.  This is the deadlock
that NeilBrown reported in 2014:
https://lore.kernel.org/linux-nfs/20140407135001.56ef9f36@notabene.brown/

Patch 3: the asynchronous LAYOUTCOMMIT that ->write_inode() sends has
the same problem as patch 2.  It pins an inode and the superblock
instead of an open context, and its task has no workqueue.

Patch 4: when LOCALIO cannot allocate its fsync context for a COMMIT,
nfs_local_commit() runs the release of the COMMIT in the submitter.

All four move the release to nfsiod, where every other write already
does it.  None changes how or when a filesystem shuts down, and
nfs_sb_deactive() does not change.

Why not take another reference instead?  These paths take and drop
every reference in balance:

 - Each write request holds its open context.  So a closed file keeps
   its context until the client writes or fails its requests.
 - Since commit 3d4ff43d895c ("nfs_open_context doesn't need struct path
   either"), an open context holds the superblock active.  After umount,
   the last open context can hold the last active reference.
 - The flusher holds s_umount and I_SYNC, but no reference of its own.
   Commit 169ebd90131b ("writeback: Avoid iput() from flusher thread")
   removed its inode reference on purpose.

A missing reference would show as an early release: a use-after-free or
a refcount warning.  Here the opposite happens: a thread waits for locks
that it holds itself, because it drops the last reference.  Another
reference only changes which put is the last one.  The flusher cannot
drop a reference after it releases s_umount and I_SYNC, so the last put
must run in another thread.  For writes that thread is already nfsiod,
and commit bf294b41cefc ("SUNRPC: Close a race in
__rpc_wait_for_completion_task()") added rpc_put_task_async() for this
case.  The series moves the four exceptions to that rule.  It does not
add a new way to defer a release.

Testing: NFSv3 over loopback, with a test-only knob that makes
nfs_do_writepage() see -EACCES in the pageio descriptor.  Dirty a file
through a mapping after closing it, unmount, and let the periodic
flusher write it back.  A plain umount is enough to leave the write
requests as the only thing that keeps the superblock alive.

                  plain file           sillyrenamed file
  v1              shuts down, from     flusher hangs in evict(),
                  v1's work item       waiting for I_SYNC

  this series     shuts down, from     shuts down, from the release
                  the context's        of the sillyrename REMOVE
                  work item

Patch 2 has a test of its own, with a second test-only knob.  The knob
leaves the COMMIT to nfs_write_inode() in the flusher.  There it waits
for the COMMIT to complete before nfs_initiate_commit() puts the task.
Without patch 2, the flusher hangs in deactivate_super(), with the stack
in the commit message of patch 2.  With patch 2, the release runs on
nfsiod and the filesystem shuts down in 2 s.

Patches 3 and 4 close a race and a rare error path, and neither test
exercises them.  Each patch builds with W=1 on Anna's linux-next.

Changes since v2:
- New patch 4, for the LOCALIO COMMIT release on an allocation failure.
- The cover letter now explains why the release is deferred rather than
  another reference taken.  Its subject also covers patch 3.
- Patch 1: put_nfs_open_context_async() is declared without extern.
- Patch 2 now has a test that reproduces its deadlock, see Testing.
- Rebased on Anna's linux-next.  v2's base-commit was not public.

Mike Snitzer (4):
  NFS: don't release the open context of a failed write from writeback
  NFS: don't run the release of a WRITE or COMMIT in the submitter
  NFSv4/pnfs: don't run the release of a LAYOUTCOMMIT in the submitter
  NFS/localio: don't run the release of a failed COMMIT in the submitter

 fs/nfs/inode.c         | 37 ++++++++++++++++++++++++++++++++++---
 fs/nfs/internal.h      |  1 +
 fs/nfs/localio.c       | 28 +++++++++++++++++++++++++++-
 fs/nfs/nfs4proc.c      |  7 ++++++-
 fs/nfs/pagelist.c      |  3 ++-
 fs/nfs/write.c         |  8 +++++++-
 include/linux/nfs_fs.h |  2 ++
 7 files changed, 79 insertions(+), 7 deletions(-)


base-commit: ef30b3efb7e8bae94d790a6503a595e1051323e7
-- 
2.52.0

