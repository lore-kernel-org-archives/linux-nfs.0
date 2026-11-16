Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827065;
	b=Mp2w7l8puSqP3/mF7EOi+lC0EvA2gs2oy/OCov4A4yEuYtHGHgdcOggC0KZvLGtvLDFx
	 0XCvFqOW1MT5GKYnKhJ9LXdGi1Ahod1onLqDJoBM/I8RMM7grpdXtmvimAU7xFMa8jWWa
	 01ndclItPf2lv0VY0WmWVAbSkjzr3nr9UTjEFcrySVlXxfofvUq6CiMBGptfwfC9Zulw5
	 OeuOIglFzgaM91DzhdgchTsEobJFFM5Xzr9my9PIh9Y67NnDgBiBzaGp+9NogYn/mDtKz
	 Dya/fJjjNd05LyAvhBE9UAQFRcpjBTY9HW44lF7BShYnYJ1kDk3oHXcdGeawFqtdhGg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827065;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=K6hcsOKot76i6ofOuhnqMqhE4PYGjzAJldUZv2AbfjY=;
	b=TZYjSp03rT+BhHwAj4k+bVnSSruv9QB2cqbeYrkt/vay3puYzYIsXEWTANx4zREiIf0c
	 TDLOQSXShhPwQ/qU6NfrdnahhpaES3HY4LJsSLnd4iRT7Zxqt9MU5dJ6lIMU4+j3Yi00w
	 yiWx3YqE9OZ9bmYljqx44ihORSPhK1DyM2wuUlZgG+jIpdSPYsSnT5XEPUAISs6MnCX2D
	 ADmy6O8HgfjKfIeGIAx2Wn82pRJChEBFHtC6iKMXq6D9QRQ2AmKUqcelP8BfOIg2dIyP5
	 EXHr1zObHA4sRK9oN5BULjo1puzSzVAdYDo6vNVulLxwgChhAy+S+9vdV8OsMiMzKdg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Yv+83Ada;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1331E606A323;
	Mon, 16 Nov 2026 11:04:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Yv+83Ada
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 086591F000D1;
	Mon, 16 Nov 2026 11:04:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827064;
	bh=K6hcsOKot76i6ofOuhnqMqhE4PYGjzAJldUZv2AbfjY=;
	h=From:Subject:Date:To:Cc;
	b=Yv+83AdaI+rMIF6ZcVumQESxSFqk/+q4KEQ/dNYe1vqGAjhO4UZuY0f32upeyeIcL
	 U7luNKMRuAsOI84eZrIlAJi/zJYCE8A/tcPIQNVv+qkGeMR+iT2Qd/a23r3cWeRQU+
	 uTSVeXg9wu6s2JknLRPylmOgOMgs4JvwAc752i150GOLDrUHLrkFmN2Gzfynarvx/9
	 MQjhumagM8tTagR1n3h7iQmHaV8zyZ3rBpUM5zVesg7Yce9jIpL6WN2evAWJQVcUQz
	 5lL6SvuerYCNW4EDL0oKuEOdAKrLTwc4zYsCSCXp8DAReNjFGyaadFvjQMB+WH5CwD
	 iQFheHbOkWpOg==
From: Christian Brauner <brauner@kernel.org>
Subject: [PATCH v2 00/17] fs: take freeze protection for writes to backing
 files
Date: Mon, 16 Nov 2026 12:03:40 +0100
Message-Id: <20261116-work-fs-frozen_writes-v2-0-ecc4a2aac40e@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/3WOQQ6CMBBFr0K6toRWRHTlPQwxbZ1CxbRmBkEl3
 F2KceHC5Zv8eXkjI0AHxPbJyBB6Ry74GeQqYaZRvgbuzjMzmclCCLHmQ8CWW+IWwwv8aUDXAfE
 sl0ZtC6mtLtn8e0Ow7rF4j9WH6a4vYLooiwutCLhG5U0TT1GbWkp/tGkcxXHjqAv4XCp7EaXfo
 PxPUC94xu1GQSFMuSu1OLSAHq5pwJpV0zS9AYIJ+TH6AAAA
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
 "Christian Brauner (Amutable)" <brauner@kernel.org>, stable@vger.kernel.org, 
 Amir Goldstein <amir73il@gmail.com>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=3938; i=brauner@kernel.org;
 h=from:subject:message-id; bh=aJ8lkhUZfSAZD0d0zDSWnIQ89Aj8tUdfJ3u4ID7PtUE=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9eixbv91/Cx9PdNTthXsErvIYvLi4cEr/18tX/HtEJ
 pfvP/W+sKOUhUGMi0FWTJHFod0kXG45T8Vmo0wNmDmsTCBDGLg4BWAie24w/A+ctEfepmXaNH6+
 fUv+voy9HejBG/Od15BdYyPzrWxh5+WMDKe+GJ5fa2TqoDH18nZZNmF57r7kO2y31r/wVrK0UDL
 h4QAA
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
[2]: https://lore.kernel.org/r/20261116064654.GA2964@lst.de

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
Changes in v2:
- Add kiocb_write_iter() and kiocb_end_write_iter() and use them for
  zloop, the nvme target and fileio as per Christoph's suggestion.
- Add a file_write guard and use it for loop discard and write zeroes
  and fileio unmap.
- Convert loop, vfs_iocb_iter_write() and fs/backing-file.c to the new
  helpers.
- Only complete the fileio target command when the last reference to
  the aio command is dropped.
- Link to v1: https://patch.msgid.link/20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org

---
Christian Brauner (17):
      fs: add kiocb_start_write_trylock()
      fs: add kiocb_write_iter() and kiocb_end_write_iter()
      fs: add file_write guard
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
      loop: use kiocb_write_iter()
      fs: use kiocb_write_iter() in vfs_iocb_iter_write()
      backing-file: use kiocb_end_write_iter()

 drivers/block/loop.c              | 13 ++++---
 drivers/block/zloop.c             | 12 +++++--
 drivers/nvme/target/io-cmd-file.c | 20 +++++++----
 drivers/target/target_core_file.c | 31 +++++++++++-----
 fs/backing-file.c                 |  8 ++---
 fs/bpf_fs_kfuncs.c                |  8 +++++
 fs/coredump.c                     |  6 ++--
 fs/nfsd/nfs4state.c               | 10 +++++-
 fs/overlayfs/util.c               |  8 +++--
 fs/read_write.c                   |  7 ++--
 include/linux/fs.h                | 75 +++++++++++++++++++++++++++++++++++++++
 io_uring/rw.c                     |  9 +----
 12 files changed, 158 insertions(+), 49 deletions(-)
---
base-commit: 6628e7d4c6b25c8d18f1345e3a20d21829aae7e4
change-id: 20261113-work-fs-frozen_writes-042ca762bfb8

