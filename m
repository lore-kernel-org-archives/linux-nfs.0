Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794653266;
	b=nwk1epyYXc3X7q3TnKSjwzkNUqXt/5fAK9bNfeCfXy3cbneeXPk+3lI0BYGLK79RPfSV
	 w1mWJCMUZFMw8Fg4B6HHbHPqbx7CFLIjn33a4ezf1vAtyAsJAgIOhbh0T/3yOf5HdPI06
	 LGQRXhRsqNVREKUEPi8M6Cf7Szhq4WaCiylq/ZW3gdVeNbZpHzZcQeHYtuStWUiMVWPeb
	 GNRqbk6JYX9LyNIVk5U4pwQTdJiEnWnJDRLpt1ciS2CzBiiEphAMpMXAKdEmQybUWCE9i
	 u+o+IGTP6qYY/t8F3yWLCwmna+Jr057oOv1+p+GBdugp2oO3DwSKUBJwFrFlqUycJDw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794653266;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=MQkMYpMW6c9dbXl0kUtYm0qMWUey+Dbbncjy0mbm15w=;
	b=SJKUTiP5iWK4vhmb4kc6G0fyZq5AXBg5jMjjoP4TUzE8JT2cW4DIkTmKQ5rrhSJhfgEm
	 Zz6BX/CKbgbaxsc/kWS1+W7wZ7Ol7BRJaJ7FbsOf5rm1SeLc2EuwiDaCltDaWb7qjoS71
	 lFGVvnGGFFGjLKPFD5a/VNceRyKIA7nQFasWZ/V7y9eZy8XbUODY+lsJ73C9hRXHensoM
	 GNq0MR79tgPvM9187SOAasgg9bk9LbRMH+k9XcCQ3yCDfSFmU81q7Oi8Z2/mANg6jme6L
	 f+xxxPStdYBAkHyHONYFjnJgVRcQYfFv7evOwUVkVoL+eFwgqNb3nUnm7XbfuTDnZfg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CvNkoJDi;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2D7A4606A323;
	Sat, 14 Nov 2026 10:47:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CvNkoJDi
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1FC5B1F000C4;
	Sat, 14 Nov 2026 10:47:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794653265;
	bh=MQkMYpMW6c9dbXl0kUtYm0qMWUey+Dbbncjy0mbm15w=;
	h=From:Subject:Date:To:Cc;
	b=CvNkoJDiE35EFSDc8g0xEAhwcQfoyoBvSdVQ8uGD4VeiHEw6rERFnX+DK0Fbwmzp/
	 zyVVbirh1X/d0oNUC+8XXfP9HEsn3DWR4u30tnDkIrxNvnwkG745QFKgtZHfpbh+uc
	 Lqj+43Lb/bY+jK2EGU6kqfFn8cuflksc/VaA8obg/msYeRgb3xAqmWKSEMYZd7vmwQ
	 qK3CDxNjLU5ZoAmvOKzZ8Zpf4WXoO8AfH2HvQwLbAbNhaniuwhlc9U3F4qC/HIptoq
	 Sx6onCIZn5vmlBi9Sm85k9i3gzAw3NbvKKvb8K6yTHKw9YIGCjV56vHWz0vg1WHgsu
	 xxP+8nPL/I0ZQ==
From: Christian Brauner <brauner@kernel.org>
Subject: [PATCH 00/12] fs: take freeze protection for writes to backing
 files
Date: Sat, 14 Nov 2026 11:47:07 +0100
Message-Id: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/1WMQQrCMBBFr1Jm7ZQmShWvIiJJnNhRSGSmWrH07
 ia6cvk+778ZlIRJYd/MIPRk5ZwKmFUDYXDpQsjnwmA72xtj1jhluWFUjJLflE6T8EiK3cYGt+2
 tj34H5XsXivz6dg/HH+vDXymMNVYN75TQi0thqFPNtlHbv2xbJViWDwd/hFymAAAA
X-Change-ID: 20261113-work-fs-frozen_writes-042ca762bfb8
To: Jan Kara <jack@suse.cz>
Cc: Shakeel Butt <shakeel.butt@linux.dev>, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, 
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, 
 io-uring@vger.kernel.org, Christoph Hellwig <hch@lst.de>, 
 linux-block@vger.kernel.org, linux-nvme@lists.infradead.org, 
 linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, 
 linux-unionfs@vger.kernel.org, bpf@vger.kernel.org, 
 linux-nfs@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=3062; i=brauner@kernel.org;
 h=from:subject:message-id; bh=eh7GvZ6DLWmxHAd9BvErC5zF8vVRkJFT707D3W+n3qQ=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9sLFpvyzxoU3qgPvm31Pv6uzjay3U7fOZUaB4id3QN
 X/G+XvmHSUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABMpT2P4MWmevfWCdaGzE3yD
 jNM384f58Dkcyw38dk1I0XY/E08dI8OOL9Ir+1PjdeOP/U3/ztokqMonbv9+84dMp+RHGV4VPKw A
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

While testing the pseudo filesystem series I noticed that zloop, the
nvme target's file backend and the fileio backend of the scsi target
with fd_async_io=1 call ->write_iter() of their backing files without
taking freeze protection. So their writes go straight through to a
frozen filesystem. ext4 complains loudly:

    WARNING: fs/ext4/ext4_jbd2.c:90 at ext4_journal_check_start+0x1f6/0x2d0

Loop doesn't get it right for discard and write zeroes. Those end up
calling ->fallocate() of the backing file directly. The fileio backend
does the same for UNMAP. And zloop records its write pointers on flush
with vfs_setxattr() which leaves freeze protection to the caller. So all
of them modify a frozen filesystem just the same. Fix them too.

Looking for more of the same turned up a few simple ones. coredump
truncates the core file, overlayfs stores its uuid xattr on mount, nfsd
truncates on OPEN and the BPF xattr kfuncs modify xattrs, all without
freeze protection. Fix those as well. The ones that need more work in
their subsystems I have reported separately.

The fileio backend also frees its aio command in the completion handler
while the filesystem may still be using the kiocb. KASAN catches ext4
doing that for direct reads on v7.4-rc1. ext4 gets its own fix (cf. [1])
but fileio should hold a reference across the submission like loop,
zloop and fs/backing-file.c do.

[1]: https://lore.kernel.org/r/20261113-work-ext4-dio_read_kiocb-v1-1-172a88be803c@kernel.org

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
Christian Brauner (12):
      fs: add kiocb_start_write_trylock()
      zloop: take freeze protection for writes
      nvmet: take freeze protection for writes to files
      target: fileio: don't free the aio command under the filesystem
      target: fileio: take freeze protection for aio writes
      loop: take freeze protection for discard and write zeroes
      zloop: take freeze protection when recording write pointers
      target: fileio: take freeze protection for unmap
      coredump: take freeze protection for the truncate
      ovl: take freeze protection when storing the uuid
      bpf: fs/xattr: take freeze protection in the xattr kfuncs
      nfsd: take freeze protection for the truncate on open

 drivers/block/loop.c              |  2 ++
 drivers/block/zloop.c             | 31 ++++++++++++++++++++-------
 drivers/nvme/target/io-cmd-file.c | 37 +++++++++++++++++++++++++-------
 drivers/target/target_core_file.c | 44 ++++++++++++++++++++++++++++++++-------
 fs/bpf_fs_kfuncs.c                |  8 +++++++
 fs/coredump.c                     |  6 ++++--
 fs/nfsd/nfs4state.c               | 10 ++++++++-
 fs/overlayfs/util.c               |  8 +++++--
 include/linux/fs.h                | 22 ++++++++++++++++++++
 io_uring/rw.c                     |  9 +-------
 10 files changed, 142 insertions(+), 35 deletions(-)
---
base-commit: 6628e7d4c6b25c8d18f1345e3a20d21829aae7e4
change-id: 20261113-work-fs-frozen_writes-042ca762bfb8

