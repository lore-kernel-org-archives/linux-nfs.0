Received: from canpmsgout12.his.huawei.com (canpmsgout12.his.huawei.com [113.46.200.227])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3674A4749DD;
	Thu, 24 Sep 2026 10:22:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.227
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790245349; cv=none; b=DmeXEwj3u/j4FypJ4BwhAhL87kP4KOb/CHtfOpwvVm4CvjZEpXSvBZIMQVgJNQ1GtHJcoif3i/2cULEEG1GKVgeNHl7cz4TdhrCe8xY2nQoVhwBcBxIweVFI+6jyfLs89aErGewtoV/6V/y7GWr5zNeFbrP34R/XSinAcs4m2os=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790245349; c=relaxed/simple;
	bh=JD32s8eD5JSHh277X1R2SZ0l+uvehg9HATseGnbtzJs=;
	h=From:To:CC:Subject:Date:Message-ID:MIME-Version:Content-Type; b=sryAPB1rELBDZA5+S9wmG7TvgJiQHXGa3AgvB1rmh82t09jDr1Dz5BuC2+sqz1TLkBolWDB7bJ7CUjUnvKskUnb8YLZT79crZeRrrHfbgGBKxq3hlcLhusvnkPisVRjUzuKDZiRidNFK2p6lLpbIiCn9ud/fOdOuCtzNdc0ZWrg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=xrjONZAS; arc=none smtp.client-ip=113.46.200.227
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="xrjONZAS"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=yg/c5dnmZTi6xyPOZ86hk74blfRQhWYpuq7fF3Kbs7A=;
	b=xrjONZASgZH2dB4W12aPwAUjOwKHhuoT3i4U1FLpQsZw+cPLUW1gCi4qySKYwWAnY/2fa/nMH
	2Ic97JDw8b/I36cpUZTVgECBEPpkkhCD2kgT43L9L8RjG93PnEkKKNXn8tuIFP5pJjIu1GAV6CL
	P/HreNo6hafJvlYVPC1YGdY=
Received: from mail.maildlp.com (unknown [172.19.163.15])
	by canpmsgout12.his.huawei.com (SkyGuard) with ESMTPS id 4hr8j419d9znTVd;
	Thu, 24 Sep 2026 18:10:16 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id EA04D40578;
	Thu, 24 Sep 2026 18:22:19 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 24 Sep 2026 18:22:15 +0800
From: Cai Xinchen <caixinchen1@huawei.com>
To: <mic@digikod.net>, <gnoack@google.com>, <paul@paul-moore.com>,
	<jmorris@namei.org>, <serge@hallyn.com>, <corbet@lwn.net>,
	<skhan@linuxfoundation.org>
CC: <rdunlap@infradead.org>, <gregkh@linuxfoundation.org>,
	<rafael@kernel.org>, <dakr@kernel.org>, <dlemoal@kernel.org>, <hch@lst.de>,
	<axboe@kernel.dk>, <viro@zeniv.linux.org.uk>, <brauner@kernel.org>,
	<jack@suse.cz>, <dhowells@redhat.com>, <code@tyhicks.com>,
	<linkinjeon@kernel.org>, <sj1557.seo@samsung.com>, <yuezhang.mo@sony.com>,
	<hirofumi@mail.parknet.co.jp>, <cel@kernel.org>, <jlayton@kernel.org>,
	<neil@brown.name>, <okorniev@redhat.com>, <Dai.Ngo@oracle.com>,
	<tom@talpey.com>, <miklos@szeredi.hu>, <amir73il@gmail.com>,
	<senozhatsky@chromium.org>, <chenxiaosong@chenxiaosong.com>,
	<zohar@linux.ibm.com>, <roberto.sassu@huawei.com>,
	<dmitry.kasatkin@gmail.com>, <eric.snowberg@oracle.com>,
	<stephen.smalley.work@gmail.com>, <omosnacek@gmail.com>,
	<casey@schaufler-ca.com>, <nanx95726@gmail.com>, <djwong@kernel.org>,
	<daniel@iogearbox.net>, <linux-security-module@vger.kernel.org>,
	<linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<driver-core@lists.linux.dev>, <linux-block@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <netfs@lists.linux.dev>,
	<ecryptfs@vger.kernel.org>, <exfat@lists.linux.dev>,
	<linux-nfs@vger.kernel.org>, <linux-unionfs@vger.kernel.org>,
	<linux-cifs@vger.kernel.org>, <linux-integrity@vger.kernel.org>,
	<selinux@vger.kernel.org>, <linux-kselftest@vger.kernel.org>,
	<xiujianfeng@huawei.com>, <caixinchen1@huawei.com>, <lujialin4@huawei.com>
Subject: [PATCH RFC -next 00/12] landlock: Add READ_METADATA and WRITE_METADATA access rights
Date: Thu, 24 Sep 2026 18:48:19 +0800
Message-ID: <20260924104831.1081137-1-caixinchen1@huawei.com>
X-Mailer: git-send-email 2.18.0.huawei.25
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
X-ClientProxiedBy: kwepems200001.china.huawei.com (7.221.188.67) To
 whupemk100010.china.huawei.com (7.152.184.41)

This series adds two new Landlock filesystem access rights,
LANDLOCK_ACCESS_FS_READ_METADATA and LANDLOCK_ACCESS_FS_WRITE_METADATA,
which control access to file and directory metadata such as inode
attributes (mode, ownership, timestamps), extended attributes and POSIX
ACLs.  It picks up the work from the "landlock: add chmod and chown
support" series [1] and follows the coarse-grained grouping discussed in
that thread [2]: instead of separate chmod/chown rights, metadata
operations are grouped into one read and one write right.

Landlock evaluates access rights on a per-path basis, but the metadata
related LSM hooks (inode_getattr, inode_setattr, inode_setxattr,
inode_getxattr, inode_listxattr, inode_removexattr, inode_set_acl,
inode_get_acl, inode_remove_acl) only receive the dentry of the accessed
object.  Patches 1-7 therefore first pass struct path instead of dentry
through the metadata-related VFS helpers and LSM hooks.  This is a pure
refactoring with no behavior change, split so that every patch builds
and works on its own:

  1: notify_change() and its callers
  2: inode_setsecctx hook (must come before 3: the SELinux and Smack
     implementations call __vfs_setxattr_locked internally)
  3: xattr helpers, which also drops a redundant EVM xattr size sanity
     check whose vfs_getxattr() call only has a dentry and therefore
     cannot be migrated to the new path-based signature
  4: POSIX ACL helpers
  5: inode_setattr hook
  6: inode xattr hooks
  7: inode POSIX ACL hooks

Two deliberate scoping decisions for this refactor:

- The hooks consistently take struct path rather than struct file.  The
  VFS call sites involved (chmod(2), chown(2), utimensat(2), xattr(2)
  and ACL syscalls) operate on paths, and several of them (lstat(2),
  lchown(2), llistxattr(2), ...) have no struct file to begin with.

- struct inode_operations->setattr still receives (idmap, dentry, attr).
  Only the VFS boundary (notify_change()) and the LSM hook layer see the
  path, which keeps the refactor contained to fs/attr.c and the LSM
  infrastructure instead of touching every filesystem.

Patches 8-12 then implement the new rights, their tests, the sandboxer
sample and the documentation.  Semantics:

- READ_METADATA covers stat(2) and friends, getxattr(2) and friends,
  listxattr(2) and friends, and POSIX ACL reads.
- WRITE_METADATA covers chmod(2), chown(2), utimensat(2), setxattr(2),
  removexattr(2) and friends, and POSIX ACL set and remove.
- Only explicit metadata changes requested by user space are restricted.
  Implicit changes performed by the kernel (e.g. timestamp updates on
  write(2), size changes on truncate(2)) are not, and neither are
  chmod(2)/chown(2) calls that change nothing (e.g. chown(2) with
  (-1, -1), which never reaches the hook), matching the SELinux
  inode_setattr behavior.
- Kernel-internal accesses performed with override_creds() (e.g.
  overlayfs, cachefiles) and kernel threads without a Landlock domain
  (e.g. nfsd, ksmbd) are not restricted.

The Landlock ABI version is incremented from 11 to 12.

The series is based on linux-next commit 5c4d4169604b ("Add linux-next
specific files for 20260921").

Testing: each patch has been built for aarch64 (gcc, -Werror) and the
landlock selftests (445 tests, including the new ones) pass in QEMU on
aarch64; base_test reports ABI v12.

[1] https://lore.kernel.org/all/20220827111215.131442-1-xiujianfeng@huawei.com/
[2] https://lore.kernel.org/all/abc960a1-e66e-792e-6869-cfd201c29dbe@digikod.net/

Assisted-by: opencode: glm-5.3

Cai Xinchen (12):
  fs: pass struct path to notify_change()
  LSM: pass struct path to the inode_setsecctx hook
  fs: pass struct path to xattr helpers
  fs: pass struct path to POSIX ACL helpers
  LSM: pass struct path to the inode_setattr hook
  LSM: pass struct path to the inode xattr hooks
  LSM: pass struct path to the inode posix acl hooks
  landlock: Add READ_METADATA and WRITE_METADATA access rights
  landlock: Implement metadata access hooks
  selftests/landlock: Add tests for metadata access rights
  samples/landlock: Add metadata rights to sandboxer
  Documentation: Update landlock doc for metadata rights

 Documentation/userspace-api/landlock.rst     |  11 +-
 drivers/base/devtmpfs.c                      |   6 +-
 drivers/block/zloop.c                        |   4 +-
 fs/attr.c                                    |  20 +-
 fs/cachefiles/interface.c                    |   6 +-
 fs/cachefiles/xattr.c                        |  32 +-
 fs/coredump.c                                |   2 +-
 fs/ecryptfs/inode.c                          |  34 +-
 fs/exfat/file.c                              |   3 +-
 fs/fat/file.c                                |   3 +-
 fs/inode.c                                   |   7 +-
 fs/internal.h                                |  17 +-
 fs/namei.c                                   |   7 +-
 fs/nfsd/nfs4ctl.h                            |   4 +-
 fs/nfsd/nfs4state.c                          |  14 +-
 fs/nfsd/nfs4xdr.c                            |   2 +-
 fs/nfsd/state.h                              |   2 +-
 fs/nfsd/vfs.c                                |  73 +++--
 fs/open.c                                    |  18 +-
 fs/overlayfs/copy_up.c                       |   4 +-
 fs/overlayfs/inode.c                         |   4 +-
 fs/overlayfs/overlayfs.h                     |  39 ++-
 fs/overlayfs/xattrs.c                        |  13 +-
 fs/posix_acl.c                               |  46 +--
 fs/smb/server/smb2pdu.c                      |  77 ++---
 fs/smb/server/smb_common.c                   |   2 -
 fs/smb/server/smbacl.c                       |  21 +-
 fs/smb/server/tests/smbacl_kunit.c           |   6 +-
 fs/smb/server/vfs.c                          | 111 +++----
 fs/smb/server/vfs.h                          |  39 +--
 fs/smb/server/vfs_cache.c                    |   3 +-
 fs/utimes.c                                  |   3 +-
 fs/xattr.c                                   |  96 +++---
 include/linux/fs.h                           |   6 +-
 include/linux/landlock.h                     |   4 +-
 include/linux/lsm_hook_defs.h                |  29 +-
 include/linux/posix_acl.h                    |  21 +-
 include/linux/security.h                     |  65 ++--
 include/linux/xattr.h                        |  22 +-
 include/uapi/linux/landlock.h                |  26 +-
 samples/landlock/sandboxer.c                 |  17 +-
 security/commoncap.c                         |  22 +-
 security/integrity/evm/evm_crypto.c          |   8 +-
 security/integrity/evm/evm_main.c            |  36 ++-
 security/integrity/ima/ima_appraise.c        |  17 +-
 security/landlock/fs.c                       |  86 ++++++
 security/landlock/limits.h                   |   2 +-
 security/landlock/syscalls.c                 |   2 +-
 security/security.c                          |  99 +++---
 security/selinux/hooks.c                     |  49 +--
 security/smack/smack_lsm.c                   |  62 ++--
 tools/testing/selftests/landlock/base_test.c |   2 +-
 tools/testing/selftests/landlock/fs_test.c   | 309 ++++++++++++++++++-
 53 files changed, 999 insertions(+), 614 deletions(-)

-- 
2.18.0.huawei.25

