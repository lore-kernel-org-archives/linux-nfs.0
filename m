Received: from canpmsgout03.his.huawei.com (canpmsgout03.his.huawei.com [113.46.200.218])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AD01851DDEE;
	Thu, 15 Oct 2026 12:19:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.218
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792066794; cv=none; b=t3z3CfHDHdpnVhfEQ5qPO3/pdjMKrJpyL1VSixLLbpZJQZos+rkryRln71fxi6V3XZ9tBJ28RImdaGSZxXa9xVyK/gDxoF4KnSngR/a8P+GBW/2AYrljMxdocr7aiR2LCLMRr06ekuoNtQzrGlO2WbuRUY1FmqJMcMufVe+VOWk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792066794; c=relaxed/simple;
	bh=FSJuhELEP9BBphk1HG7ReW9hYZ7Ctz/v8OyQMbPSEnU=;
	h=From:To:CC:Subject:Date:Message-ID:MIME-Version:Content-Type; b=fz0Sn6BGekfFQQMpoWatzKG4WnpRq6TWSVxTRtctX5O2NPYguLVedMYLf2ERIoUGlUjU4lxEv6+l7LSNgG5lejjNEqhuYg+6CVba/aZ9DFez96Jt/B3A1RtvXqLHiI2m0qTfql0X/osPjL/XpuKlhS18Qh+ZC0WGBzLixa99sIU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=mkH2HjGO; arc=none smtp.client-ip=113.46.200.218
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="mkH2HjGO"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=E17YEsFh6XSH2r7pXJNy8yLvPwELwbsMQXYgrv/NATk=;
	b=mkH2HjGO1yRj5ZEhDW16E+gYaC3mINE9PCQdk6b4emrFZjqLatLCDbD6VcNWEucDEMgg7fjDm
	efRkpsabNJluFnsTPasFB40sF9aZvT70s0fXCNyw96mK+ZjjvMvweP8fYjFjgmFM9TARqnDPP+Z
	two6/q/99KzFphsg8KnLHt4=
Received: from mail.maildlp.com (unknown [172.19.163.0])
	by canpmsgout03.his.huawei.com (SkyGuard) with ESMTPS id 4j56JF5BPpzpT0F;
	Thu, 15 Oct 2026 20:07:09 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id E20DE40537;
	Thu, 15 Oct 2026 20:19:46 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 15 Oct 2026 20:19:41 +0800
From: Cai Xinchen <caixinchen1@huawei.com>
To: <mic@digikod.net>, <gnoack@google.com>, <paul@paul-moore.com>,
	<jmorris@namei.org>, <serge@hallyn.com>, <corbet@lwn.net>,
	<skhan@linuxfoundation.org>
CC: <ast@kernel.org>, <daniel@iogearbox.net>, <andrii@kernel.org>,
	<eddyz87@gmail.com>, <memxor@gmail.com>, <martin.lau@linux.dev>,
	<song@kernel.org>, <yonghong.song@linux.dev>, <jolsa@kernel.org>,
	<emil@etsalapatis.com>, <ihor.solodrai@linux.dev>, <rdunlap@infradead.org>,
	<gregkh@linuxfoundation.org>, <rafael@kernel.org>, <dakr@kernel.org>,
	<johan@kernel.org>, <dlemoal@kernel.org>, <hch@lst.de>, <axboe@kernel.dk>,
	<viro@zeniv.linux.org.uk>, <brauner@kernel.org>, <jack@suse.cz>,
	<dhowells@redhat.com>, <code@tyhicks.com>, <linkinjeon@kernel.org>,
	<sj1557.seo@samsung.com>, <yuezhang.mo@sony.com>,
	<hirofumi@mail.parknet.co.jp>, <cel@kernel.org>, <jlayton@kernel.org>,
	<neil@brown.name>, <okorniev@redhat.com>, <Dai.Ngo@oracle.com>,
	<tom@talpey.com>, <hyc.lee@gmail.com>, <miklos@szeredi.hu>,
	<amir73il@gmail.com>, <senozhatsky@chromium.org>,
	<chenxiaosong@chenxiaosong.com>, <kpsingh@kernel.org>, <matt@bobrowski.net>,
	<rostedt@goodmis.org>, <mhiramat@kernel.org>,
	<mathieu.desnoyers@efficios.com>, <john.johansen@canonical.com>,
	<georgia.garcia@canonical.com>, <zohar@linux.ibm.com>,
	<roberto.sassu@huawei.com>, <dmitry.kasatkin@gmail.com>,
	<eric.snowberg@oracle.com>, <stephen.smalley.work@gmail.com>,
	<omosnacek@gmail.com>, <casey@schaufler-ca.com>, <takedakn@nttdata.co.jp>,
	<penguin-kernel@I-love.SAKURA.ne.jp>, <xiujianfeng@huawei.com>,
	<nanx95726@gmail.com>, <djwong@kernel.org>, <lujialin4@huawei.com>,
	<bpf@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-security-module@vger.kernel.org>,
	<driver-core@lists.linux.dev>, <linux-block@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <netfs@lists.linux.dev>,
	<ecryptfs@vger.kernel.org>, <exfat@lists.linux.dev>,
	<linux-nfs@vger.kernel.org>, <ntfs@lists.linux.dev>,
	<linux-unionfs@vger.kernel.org>, <linux-cifs@vger.kernel.org>,
	<linux-trace-kernel@vger.kernel.org>, <apparmor@lists.ubuntu.com>,
	<linux-integrity@vger.kernel.org>, <selinux@vger.kernel.org>,
	<linux-kselftest@vger.kernel.org>
Subject: [PATCH v2 -next 00/18] landlock: Add READ_METADATA and WRITE_METADATA access rights
Date: Thu, 15 Oct 2026 20:54:06 +0800
Message-ID: <20261015125425.3246251-1-caixinchen1@huawei.com>
X-Mailer: git-send-email 2.18.0.huawei.25
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
X-ClientProxiedBy: kwepems500001.china.huawei.com (7.221.188.70) To
 whupemk100010.china.huawei.com (7.152.184.41)

This series adds two new Landlock filesystem access rights,
LANDLOCK_ACCESS_FS_READ_METADATA and LANDLOCK_ACCESS_FS_WRITE_METADATA,
which control access to file and directory metadata such as inode
attributes (mode, ownership, timestamps), extended attributes, POSIX
ACLs and chattr(1)-style flags.  It picks up the work from the
"landlock: add chmod and chown support" series [1] and follows the
coarse-grained grouping discussed in that thread [2]: instead of
separate chmod/chown rights, metadata operations are grouped into one
read and one write right.

Landlock evaluates access rights on a per-path basis, but the
metadata related LSM hooks (inode_setattr, inode_setsecctx, the inode
xattr, POSIX ACL and fileattr hooks) only receive the dentry of the
accessed object.  Patches 1-8 therefore first pass struct path
instead of dentry through the metadata-related VFS helpers and LSM
hooks.  This is a pure refactoring with no behavior change, split so
that every patch builds on its own:

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
  8: inode fileattr hooks (FS_IOC_[GS]ETFLAGS, FS_IOC_FS[SG]ETXATTR,
     file_[gs]etattr(2)), which also adds __vfs_fileattr_[gs]et()
     counterparts without security checks for the fileattr forwards
     of ecryptfs and overlayfs, following the __vfs_setxattr_noperm()
     precedent, and removes the ovl_security_fileattr() hack

Two deliberate scoping decisions for this refactor:

- The hooks consistently take struct path rather than struct file.  The
  VFS call sites involved (chmod(2), chown(2), utimensat(2), xattr(2)
  and ACL syscalls) operate on paths, and several of them (lstat(2),
  lchown(2), llistxattr(2), ...) have no struct file to begin with.

- struct inode_operations->setattr still receives (idmap, dentry, attr).
  Only the VFS boundary (notify_change()) and the LSM hook layer see the
  path, which keeps the refactor contained to fs/attr.c and the LSM
  infrastructure instead of touching every filesystem.

Since these hooks now operate on paths rather than inodes, patches
10-15 rename them to the path_* naming convention used by the other
hooks that take a struct path (path_chmod, path_chown, path_link,
...).  The inode_getattr hook, which already received a struct path,
is renamed to path_getattr for consistency as well.  These renames
are purely mechanical and can be reviewed, or dropped, independently.

Patch 9 then adds the access rights and implements the hooks, and
patches 16-18 add the selftests, the sandboxer sample update and the
documentation.  Semantics:

- READ_METADATA covers stat(2) and friends, getxattr(2) and friends,
  listxattr(2) and friends, POSIX ACL reads, and the chattr(1)-style
  reads ioctl(FS_IOC_GETFLAGS), ioctl(FS_IOC_FSGETXATTR) and
  file_getattr(2).
- WRITE_METADATA covers chmod(2) and friends, chown(2) and friends,
  utimensat(2) and friends, setxattr(2) and friends, removexattr(2)
  and friends, POSIX ACL set and remove, and the chattr(1)-style
  writes ioctl(FS_IOC_SETFLAGS), ioctl(FS_IOC_FSSETXATTR) and
  file_setattr(2).
- Only explicit metadata changes requested by user space are
  restricted.  Implicit changes performed by the kernel (e.g.
  timestamp updates and size changes on write(2) or truncate(2)) are
  not, and neither are chmod(2)/chown(2) calls that change nothing
  (e.g. chown(2) with (-1, -1), which never reaches the hook),
  matching the SELinux inode_setattr behavior.
- Clearing the set-user-ID and set-group-ID bits after write(2) or
  truncate(2) does not require WRITE_METADATA either: the mode
  change that the kernel synthesizes from ATTR_KILL_S[UG]ID is
  ignored, like SELinux and Smack do.
- Kernel-internal accesses performed with override_creds() (e.g.
  overlayfs, cachefiles) and kernel threads without a Landlock
  domain (e.g. nfsd, ksmbd) are not restricted.

The Landlock ABI version is incremented from 12 to 13; ABI 12 was
taken by the capability and namespace use restrictions that are
already in linux-next.

The series is based on linux-next commit d419d682257d ("Add linux-next
specific files for 20261014").

Testing: each of the 19 trees (the base plus one per patch) builds
for aarch64 (gcc), with the sandboxer sample cross-compiled at every
step, and the landlock selftests (including the new ones) pass in
QEMU on aarch64 with a kernel built from this series; base_test
reports ABI v13.

Changes since v1 [3]:

- Rebased onto next-20261014; the Landlock ABI version is now 13
  (12 was taken upstream, see above).
- New fileattr coverage: ioctl(FS_IOC_GETFLAGS),
  ioctl(FS_IOC_SETFLAGS), ioctl(FS_IOC_FSGETXATTR) and
  ioctl(FS_IOC_FSSETXATTR) are now controlled as well, through the
  inode_file_getattr and inode_file_setattr hooks, with the ecryptfs
  and overlayfs fileattr forwards taken into account (new patch 8),
  and new selftests: fileattr, fileattr_write_only,
  layout2_overlay.fileattr and overlay_mount_denied.
- Clearing the set-user-ID and set-group-ID bits on write(2) or
  truncate(2) no longer requires WRITE_METADATA (see above); the
  write_metadata selftest now checks it.
- v1 patches 8 ("Add READ_METADATA and WRITE_METADATA access rights")
  and 9 ("Implement the metadata access hooks") are folded into one
  patch (now patch 9).
- New patches 10-15: rename the updated hooks to the path_*
  convention (see above).
- The sandboxer sample and the documentation are updated accordingly.

[1]https://lore.kernel.org/all/20220827111215.131442-1-xiujianfeng@huawei.com/
[2]https://lore.kernel.org/all/abc960a1-e66e-792e-6869-cfd201c29dbe@digikod.net/
[3]https://lore.kernel.org/all/20260924104831.1081137-1-caixinchen1@huawei.com/

Link: https://github.com/landlock-lsm/linux/issues/11

Cai Xinchen (18):
  fs: pass struct path to notify_change()
  LSM: pass struct path to the inode_setsecctx hook
  fs: pass struct path to xattr helpers
  fs: pass struct path to POSIX ACL helpers
  LSM: pass struct path to the inode_setattr hook
  LSM: pass struct path to the inode xattr hooks
  LSM: pass struct path to the inode posix acl hooks
  LSM: pass struct path to the inode fileattr hooks
  landlock: Add READ_METADATA and WRITE_METADATA access rights
  LSM: rename inode_getattr to path_getattr
  LSM: rename inode_setattr to path_setattr
  LSM: rename the inode xattr hooks to path_xattr hooks
  LSM: rename the inode posix acl hooks to path_*_acl hooks
  LSM: rename the inode fileattr hooks to path_file_* hooks
  LSM: rename inode_setsecctx to path_setsecctx
  selftests/landlock: Add tests for metadata access rights
  samples/landlock: Add metadata rights to sandboxer
  Documentation: Update landlock doc for metadata rights

 Documentation/bpf/fs_kfuncs.rst               |   2 +-
 Documentation/userspace-api/landlock.rst      |  47 +-
 drivers/base/devtmpfs.c                       |   6 +-
 drivers/block/zloop.c                         |   4 +-
 fs/attr.c                                     | 107 +++-
 fs/bpf_fs_kfuncs.c                            |   6 +-
 fs/cachefiles/xattr.c                         |  35 +-
 fs/coredump.c                                 |   2 +-
 fs/ecryptfs/inode.c                           |  38 +-
 fs/exfat/file.c                               |   3 +-
 fs/fat/file.c                                 |   3 +-
 fs/file_attr.c                                | 128 ++--
 fs/inode.c                                    |   7 +-
 fs/internal.h                                 |  17 +-
 fs/namei.c                                    |   7 +-
 fs/nfsd/nfs4ctl.h                             |   4 +-
 fs/nfsd/nfs4state.c                           |  14 +-
 fs/nfsd/nfs4xdr.c                             |   2 +-
 fs/nfsd/state.h                               |   2 +-
 fs/nfsd/vfs.c                                 |  75 ++-
 fs/ntfs/named_stream.c                        |   2 +-
 fs/open.c                                     |  18 +-
 fs/overlayfs/copy_up.c                        |   4 +-
 fs/overlayfs/inode.c                          |  53 +-
 fs/overlayfs/overlayfs.h                      |  39 +-
 fs/overlayfs/xattrs.c                         |  10 +-
 fs/posix_acl.c                                |  46 +-
 fs/smb/server/smb2pdu.c                       |  83 +--
 fs/smb/server/smb_common.c                    |   2 -
 fs/smb/server/smbacl.c                        |  21 +-
 fs/smb/server/tests/smbacl_kunit.c            |   6 +-
 fs/smb/server/vfs.c                           | 128 ++--
 fs/smb/server/vfs.h                           |  41 +-
 fs/smb/server/vfs_cache.c                     |   3 +-
 fs/stat.c                                     |   4 +-
 fs/utimes.c                                   |   3 +-
 fs/xattr.c                                    |  96 +--
 include/linux/fileattr.h                      |   8 +-
 include/linux/fs.h                            |   8 +-
 include/linux/landlock.h                      |   4 +-
 include/linux/lsm_hook_defs.h                 |  37 +-
 include/linux/posix_acl.h                     |  21 +-
 include/linux/security.h                      |  77 +--
 include/linux/xattr.h                         |  22 +-
 include/uapi/linux/landlock.h                 |  25 +-
 kernel/bpf/bpf_lsm.c                          |  10 +-
 kernel/trace/bpf_trace.c                      |   2 +-
 samples/landlock/sandboxer.c                  |  16 +-
 security/apparmor/lsm.c                       |   4 +-
 security/commoncap.c                          |  22 +-
 security/integrity/evm/evm_crypto.c           |   8 +-
 security/integrity/evm/evm_main.c             |  60 +-
 security/integrity/ima/ima_appraise.c         |  25 +-
 security/landlock/fs.c                        | 126 ++++
 security/landlock/limits.h                    |   2 +-
 security/landlock/syscalls.c                  |   2 +-
 security/security.c                           | 143 ++---
 security/selinux/hooks.c                      |  85 +--
 security/smack/smack_lsm.c                    |  98 +--
 security/tomoyo/tomoyo.c                      |   6 +-
 .../testing/selftests/bpf/prog_tests/d_path.c |   2 +-
 .../selftests/bpf/prog_tests/fs_kfuncs.c      |  10 +-
 .../testing/selftests/bpf/progs/test_d_path.c |   2 +-
 .../bpf/progs/test_d_path_check_rdonly_mem.c  |   2 +-
 .../bpf/progs/test_d_path_check_types.c       |   2 +-
 .../selftests/bpf/progs/test_get_xattr.c      |   6 +-
 .../bpf/progs/test_set_remove_xattr.c         |  31 +-
 .../bpf/progs/verifier_lsm_init_xattr.c       |   4 +-
 .../selftests/bpf/progs/verifier_vfs_accept.c |   2 +-
 .../selftests/bpf/progs/verifier_vfs_reject.c |   2 +-
 tools/testing/selftests/landlock/base_test.c  |   2 +-
 tools/testing/selftests/landlock/fs_test.c    | 606 +++++++++++++++++-
 .../selftests/landlock/trace_fs_test.c        |   3 +-
 73 files changed, 1683 insertions(+), 870 deletions(-)

-- 
2.18.0.huawei.25

