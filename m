Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.219
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793101091;
	b=GtfS4ao7UEXhcL3Mlb2ilbuwrBi5kik5Y/32SkmIBPQDDGoq5rPOSE5VZWgFt8D+mC5w
	 QErBWDisoKR0bv82UrmCNF1Hg/5JV49dLEFMl7iZfjiaHDyBtTHNVj/LA11NZwS/GsQ6M
	 ZmSrhl0KmokP8zzG9uWZiwex1SDWNDnW3492yIk72NRgqeAqmmO9V/zjmC7ehJO1lLg5+
	 UMEMPdNuCr5Qhx1CSwSgKd1LhF6twcjmBaOW+5UPhWJPcuN+sd1vtF/sEGP/e6V+kzMVX
	 tWIL+gVfYRsme+VWfelDErCv50HK2Vj8cZvEbZe4dBBAgfZ5y3/QjJYzd3ZEc1utvcA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793101091;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:X-Originating-IP:X-ClientProxiedBy;
	bh=LWyfT9A94nxLJhqbaGE64JokHioc+waUYIEWWOe2AXU=;
	b=Iu0npP6RSax+dlG9C6sYw7ZBcD9AgdaygPYf12ohWVLU0ZT9JI2mhpZaXSu5WzFw6l5u
	 gYJpLSNrmcBj5/1lax4mNVmFREhd8U9+c6BSbdEsGbovFpRJwrSY032VixvJ8nD/5m3hZ
	 6vnTE2k9vw3l2nKGucF4/GxqL5B1pijiD98FCH09FTx/nkqQzeOnAZFPTzPypzlDUmcuX
	 N1lx+N4wu2PyNCbgtwsl9g2J+s1Bv9O4rnpNN+JRR+5uO2pyfTBeui5+IpMiqYil4NWwX
	 IQpaKpycLkjAlqyaf3WwdaKb2L4Eh5iysxOffXx0UwIDUKffw7OIZIEGA8ZFxlQbxdQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b="s/ySzqws";
	arc=none smtp.remote-ip=113.46.200.219
Received: from canpmsgout04.his.huawei.com (canpmsgout04.his.huawei.com [113.46.200.219])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 775E7606A31B;
	Tue, 27 Oct 2026 11:38:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 775E7606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=s/ySzqws
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=LWyfT9A94nxLJhqbaGE64JokHioc+waUYIEWWOe2AXU=;
	b=s/ySzqwsMJN7JHSHqug0jf29kkiX+Exogl+4yCafpF9XlrIKMXa1yZd6RsRcjqPk74cc0xFyP
	g2UkNP03BiMY956QzbeCN7fAJUF1guZuLT47120YKEtsXcuSIvbMvDMZsYLoHoArH6Nv70g7r6w
	ZsmTcuAIl/PT/IQxXA2JuAA=
Received: from mail.maildlp.com (unknown [172.19.163.104])
	by canpmsgout04.his.huawei.com (SkyGuard) with ESMTPS id 4jDT4x2H4hz1prLL;
	Tue, 27 Oct 2026 19:37:53 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id D43944058F;
	Tue, 27 Oct 2026 19:38:00 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Tue, 27 Oct 2026 19:37:55 +0800
From: Cai Xinchen <caixinchen1@huawei.com>
To: <mic@digikod.net>, <gnoack@google.com>, <paul@paul-moore.com>,
	<jmorris@namei.org>, <serge@hallyn.com>, <corbet@lwn.net>,
	<skhan@linuxfoundation.org>, <utilityemal77@gmail.com>,
	<caixinchen1@huawei.com>
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
	<chenxiaosong@chenxiaosong.com>, <dsterba@suse.com>, <mason@kernel.org>,
	<kpsingh@kernel.org>, <matt@bobrowski.net>, <rostedt@goodmis.org>,
	<mhiramat@kernel.org>, <mathieu.desnoyers@efficios.com>,
	<john.johansen@canonical.com>, <georgia.garcia@canonical.com>,
	<zohar@linux.ibm.com>, <roberto.sassu@huawei.com>,
	<dmitry.kasatkin@gmail.com>, <eric.snowberg@oracle.com>,
	<stephen.smalley.work@gmail.com>, <omosnacek@gmail.com>,
	<casey@schaufler-ca.com>, <takedakn@nttdata.co.jp>,
	<penguin-kernel@I-love.SAKURA.ne.jp>, <xiujianfeng@huawei.com>,
	<nanx95726@gmail.com>, <djwong@kernel.org>, <lujialin4@huawei.com>,
	<bpf@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-security-module@vger.kernel.org>,
	<driver-core@lists.linux.dev>, <linux-block@vger.kernel.org>,
	<linux-btrfs@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	<netfs@lists.linux.dev>, <ecryptfs@vger.kernel.org>, <exfat@lists.linux.dev>,
	<linux-nfs@vger.kernel.org>, <ntfs@lists.linux.dev>,
	<linux-unionfs@vger.kernel.org>, <linux-cifs@vger.kernel.org>,
	<linux-trace-kernel@vger.kernel.org>, <apparmor@lists.ubuntu.com>,
	<linux-integrity@vger.kernel.org>, <selinux@vger.kernel.org>,
	<linux-kselftest@vger.kernel.org>
Subject: [PATCH v3 -next 00/18] landlock: Add READ_METADATA and WRITE_METADATA access rights
Date: Tue, 27 Oct 2026 20:11:33 +0800
Message-ID: <20261027121151.1887650-1-caixinchen1@huawei.com>
X-Mailer: git-send-email 2.18.0.huawei.25
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="y"
Content-Transfer-Encoding: 8bit
X-ClientProxiedBy: kwepems500002.china.huawei.com (7.221.188.17) To
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
hooks.  The hooks also receive a struct file argument, set by the
VFS to the file through which the operation is requested when there
is one (i.e. for the file descriptor-based system calls such as
fchmod(2), fchown(2), fgetxattr(2), utimensat(2) on an empty path,
and for the FS_IOC_* ioctls and file_[gs]etattr(2) with
AT_EMPTY_PATH), and NULL otherwise (i.e. for the path-based system
calls and for kernel-internal accesses).  This is a pure refactoring
with no behavior change for the other LSMs, which only have their
hook implementations' signatures updated; the file argument is only
consumed by Landlock (patch 15).  The series is split so that every
patch builds on its own:

  1: notify_change() and its callers
  2: inode_setsecctx hook (must come before 3: the SELinux and Smack
     implementations call __vfs_setxattr_locked internally)
  3: xattr helpers, which also drops a redundant EVM xattr size sanity
     check whose vfs_getxattr() call only has a dentry and therefore
     cannot be migrated to the new path-based signature
  4: POSIX ACL helpers
  5: inode_setattr hook, which now receives the struct file held by
     the fd-based callers (fchmod(2), fchown(2), fchmodat2(2) and
     fchownat(2) with AT_EMPTY_PATH, utimensat(2) on an empty path);
     do_truncate() passes NULL because size changes are governed by
     the truncate hooks
  6: inode xattr hooks, threaded through the xattr helpers so that
     the f[gs]etxattr(2) and io_uring flows pass their file
  7: inode POSIX ACL hooks, threaded through do_set_acl()/do_get_acl()
  8: inode fileattr hooks (FS_IOC_[GS]ETFLAGS, FS_IOC_FS[SG]ETXATTR,
     file_[gs]etattr(2)), which also adds __vfs_fileattr_[gs]et()
     counterparts without security checks for the fileattr forwards
     of ecryptfs and overlayfs, following the __vfs_setxattr_noperm()
     precedent, and removes the ovl_security_fileattr() hack

Three deliberate scoping decisions for this refactor:

- The hooks consistently take struct path rather than struct file as
  their primary object.  The VFS call sites involved (chmod(2),
  chown(2), utimensat(2), xattr(2) and ACL syscalls) operate on
  paths, and several of them (lstat(2), lchown(2), llistxattr(2),
  ...) have no struct file to begin with.  The optional struct file
  argument carries the open-time semantic described below.

- struct inode_operations->setattr still receives (idmap, dentry, attr).
  Only the VFS boundary (notify_change()) and the LSM hook layer see the
  path, which keeps the refactor contained to fs/attr.c and the LSM
  infrastructure instead of touching every filesystem.

- The path argument of the hooks is only meant to be handed to VFS
  helpers taking a struct path (e.g., notify_change(), the xattr
  helpers): the VFS makes no guarantees with regard to path->mnt,
  whose layout and implementation details are subject to change, and
  implementations must not rely on its properties.  The idmap, in
  contrast, is passed separately so that the VFS and the filesystem
  are guaranteed to see the same idmap.
  
Unlike what was done for LANDLOCK_ACCESS_FS_TRUNCATE, no new file_*
hooks are introduced for the file descriptor flows: the metadata
hooks are already consumed by other LSMs (SELinux, Smack, EVM, IMA,
AppArmor, TOMOYO) on these flows, and routing them to new hooks
would either silently remove the other LSMs' checks, or keep the
path_* hooks as well and check twice with Landlock.  Passing the
struct file to the existing path_* hooks instead keeps the pipeline
and the other LSMs' behavior unchanged, while giving Landlock the
information it needs to apply the open-time semantic below.

Since these hooks now operate on paths rather than inodes, patches
9-14 rename them to the path_* naming convention used by the other
hooks that take a struct path (path_chmod, path_chown, path_link,
...).  The inode_getattr hook, which already received a struct path,
is renamed to path_getattr as well; patch 9 also threads the struct
file held by the fd-based vfs_fstat() and vfs_statx_fd() callers
through it, while the many kernel-internal vfs_getattr() callers
keep a wrapper which passes NULL.  These renames are purely
mechanical and can be reviewed independently.

Patch 15 then adds the access rights and implements their
enforcement, and patches 16-18 add the selftests, the sandboxer
sample update and the documentation.

Patch 15 applies the LANDLOCK_ACCESS_FS_TRUNCATE mechanic to the
new rights, following Mickaël's confirmation [4]: for operations on
already opened files, it is the access rights at the time of open(2)
which decide whether a metadata operation is permitted, not the
rights of the current thread.  READ_METADATA and WRITE_METADATA are
looked up at open time, recorded in the opened file, and consumed by
the metadata hooks when they are called with a file.  As a
consequence:

- A file descriptor opened before sandboxing keeps allowing metadata
  operations whatever the current domain is, which resolves the
  "catch-22" raised by Justin [5]: an already opened file descriptor
  keeps working, it is not an escape hatch because its rights were
  fixed when it was legitimate to open the file.
- Conversely, a restricted file descriptor passed to another
  (possibly non-landlocked) process keeps denying metadata
  operations: the file descriptor carries the rights of the process
  which opened it.
- ioctl(FS_IOC_GETFLAGS) and friends on a file descriptor opened
  without READ_METADATA are now denied, which closes the metadata
  leak Justin was concerned about.
- O_PATH file descriptors are an exception: they are not opened
  through the open permission checks (cf. do_dentry_open()) and
  carry no recorded rights; metadata accesses through them are
  checked against the current domain, like path-based accesses.
- File descriptors obtained without going through the file_open
  hook (e.g. memfd_create(2), pipes, sockets) keep the full access
  rights granted at file allocation time, consistent with the
  truncate behavior.
- deny_masks_t is widened from u8 to u16 to keep tracking one
  nibble per optional access right for the audit logs.
  
The path-based semantics are unchanged from v2:

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

Two review suggestions are deliberately not taken, following the
TRUNCATE precedent and Mickaël's arbitration [4]:

- Requiring READ_METADATA for open(2) and readdir(2) (Günther's
  lockstep proposal) would change the semantics of existing rights;
  the documentation instead recommends granting READ_METADATA
  together with READ_FILE and READ_DIR, as it already recommends
  grouping TRUNCATE with WRITE_FILE.
- Making READ_FILE imply READ_METADATA (Justin's proposal) would
  break the orthogonality of the access rights; the same
  documentation warning covers the grouping.

The Landlock ABI version is incremented from 12 to 13; ABI 12 was
taken by the capability and namespace use restrictions that are
already in linux-next.

The series is based on linux-next commit f1ac44c32cba ("Add linux-next
specific files for 20261026").

Changes since v2 [3]:

- The idmap is passed separately from the struct path again, instead
  of being derived from path->mnt inside the helpers and the hooks.
  As Christian explains in his review of patch 1, the idmap must be
  taken of the mount at the time it was checked and passed down to
  the filesystem so that the VFS and the filesystem are guaranteed
  to see the same idmap.  The mainline signatures are kept wherever
  they already pass an idmap: notify_change(), the xattr, POSIX ACL
  and fileattr helpers, and the setattr, setxattr, removexattr and
  *_acl hooks, along with their SELinux, Smack, EVM, IMA and
  capability implementations, keep receiving the idmap as a separate
  argument (patches 1, 3-8, 10-12).  The Landlock implementations
  receive it as well (patch 15).  The getxattr and listxattr hooks
  keep taking no idmap, like their mainline counterparts, and the
  new fileattr hooks take none either, as they have no mainline
  counterpart to inherit the argument from.
- The metadata-related LSM hooks now also receive the struct file
  through which the operation is requested, when there is one
  (patches 5-9); see above for why no new file_* hooks are
  introduced.
- Metadata accesses on already opened files are now checked at open
  time, following the LANDLOCK_ACCESS_FS_TRUNCATE mechanic confirmed
  by Mickaël [4] (patch 15).
- The Landlock patch is moved after the hook renames (patch 15 now,
  patch 9 in v2), so that it lands on the hooks' final path_* names.
- The kernel-doc comments of the converted security_*() wrappers and
  of the EVM and Smack hook implementations are completed and fixed:
  the new file and idmap arguments are documented, and the wrappers
  state that the VFS makes no guarantees with regard to path->mnt.
- The selftests are adapted to the open-time semantic (the
  fileattr_write_only and write_metadata denial cases now use file
  descriptors opened after the ruleset is enforced) and extended
  with the metadata_open_time and metadata_transfer tests; the
  documentation describes the open-time semantic and the O_PATH
  exception.

[1]
https://lore.kernel.org/all/20220827111215.131442-1-xiujianfeng@huawei.com/
[2]
https://lore.kernel.org/all/abc960a1-e66e-792e-6869-cfd201c29dbe@digikod.net/
[3]
https://lore.kernel.org/all/20261015125425.3246251-1-caixinchen1@huawei.com/
[4] https://lore.kernel.org/all/20260929.Ahgoo4yeetai@digikod.net/
[5] https://lore.kernel.org/all/arvjb0HJYh1KyEBB@suesslenovo/

Cai Xinchen (18):
  fs: pass struct path to notify_change()
  LSM: pass struct path to the inode_setsecctx hook
  fs: pass struct path to xattr helpers
  fs: pass struct path to POSIX ACL helpers
  LSM: pass struct path and struct file to the inode_setattr hook
  LSM: pass struct path and struct file to the inode xattr hooks
  LSM: pass struct path and struct file to the inode posix acl hooks
  LSM: pass struct path and struct file to the inode fileattr hooks
  LSM: rename inode_getattr to path_getattr and pass struct file
  LSM: rename inode_setattr to path_setattr
  LSM: rename the inode xattr hooks to path_xattr hooks
  LSM: rename the inode posix acl hooks to path_*_acl hooks
  LSM: rename the inode fileattr hooks to path_file_* hooks
  LSM: rename inode_setsecctx to path_setsecctx
  landlock: Add READ_METADATA and WRITE_METADATA access rights
  selftests/landlock: Add tests for metadata access rights
  samples/landlock: Add metadata rights to sandboxer
  Documentation: Update landlock doc for metadata rights

 Documentation/bpf/fs_kfuncs.rst               |   2 +-
 Documentation/userspace-api/landlock.rst      |  92 +-
 drivers/base/devtmpfs.c                       |   6 +-
 drivers/block/zloop.c                         |   9 +-
 fs/attr.c                                     | 113 ++-
 fs/bpf_fs_kfuncs.c                            |   6 +-
 fs/btrfs/volumes.c                            |   2 +-
 fs/cachefiles/xattr.c                         |  45 +-
 fs/coredump.c                                 |   2 +-
 fs/ecryptfs/inode.c                           |  42 +-
 fs/exfat/file.c                               |   4 +-
 fs/fat/file.c                                 |   4 +-
 fs/file_attr.c                                | 159 ++-
 fs/init.c                                     |   6 +-
 fs/inode.c                                    |   7 +-
 fs/internal.h                                 |  26 +-
 fs/namei.c                                    |   5 +-
 fs/nfsd/nfs4ctl.h                             |   4 +-
 fs/nfsd/nfs4state.c                           |  14 +-
 fs/nfsd/nfs4xdr.c                             |   2 +-
 fs/nfsd/state.h                               |   2 +-
 fs/nfsd/vfs.c                                 |  79 +-
 fs/ntfs/named_stream.c                        |   2 +-
 fs/open.c                                     |  63 +-
 fs/overlayfs/copy_up.c                        |   4 +-
 fs/overlayfs/inode.c                          |  54 +-
 fs/overlayfs/overlayfs.h                      |  44 +-
 fs/overlayfs/xattrs.c                         |  12 +-
 fs/posix_acl.c                                |  52 +-
 fs/smb/server/smb2pdu.c                       |  56 +-
 fs/smb/server/smb_common.c                    |  12 +-
 fs/smb/server/smbacl.c                        |  12 +-
 fs/smb/server/vfs.c                           | 100 +-
 fs/smb/server/vfs.h                           |  18 +-
 fs/stat.c                                     |  48 +-
 fs/utimes.c                                   |  23 +-
 fs/xattr.c                                    | 114 ++-
 include/linux/fileattr.h                      |  10 +-
 include/linux/fs.h                            |  14 +-
 include/linux/landlock.h                      |   4 +-
 include/linux/lsm_hook_defs.h                 |  59 +-
 include/linux/posix_acl.h                     |  24 +-
 include/linux/security.h                      | 129 +--
 include/linux/xattr.h                         |  31 +-
 include/uapi/linux/landlock.h                 |  25 +-
 init/initramfs.c                              |   2 +-
 kernel/bpf/bpf_lsm.c                          |  10 +-
 kernel/trace/bpf_trace.c                      |   2 +-
 samples/landlock/sandboxer.c                  |  16 +-
 security/apparmor/lsm.c                       |   5 +-
 security/commoncap.c                          |  24 +-
 security/integrity/evm/evm_crypto.c           |   8 +-
 security/integrity/evm/evm_main.c             |  77 +-
 security/integrity/ima/ima_appraise.c         |  41 +-
 security/landlock/access.h                    |  13 +-
 security/landlock/fs.c                        | 232 ++++-
 security/landlock/limits.h                    |   2 +-
 security/landlock/syscalls.c                  |   2 +-
 security/security.c                           | 169 ++--
 security/selinux/hooks.c                      | 104 +-
 security/smack/smack_lsm.c                    | 124 ++-
 security/tomoyo/tomoyo.c                      |   7 +-
 .../testing/selftests/bpf/prog_tests/d_path.c |   4 +-
 .../selftests/bpf/prog_tests/fs_kfuncs.c      |  10 +-
 .../testing/selftests/bpf/progs/test_d_path.c |   2 +-
 .../bpf/progs/test_d_path_check_rdonly_mem.c  |   2 +-
 .../bpf/progs/test_d_path_check_types.c       |   2 +-
 .../selftests/bpf/progs/test_get_xattr.c      |   7 +-
 .../bpf/progs/test_set_remove_xattr.c         |  34 +-
 .../bpf/progs/verifier_lsm_init_xattr.c       |   8 +-
 .../selftests/bpf/progs/verifier_vfs_accept.c |   2 +-
 .../selftests/bpf/progs/verifier_vfs_reject.c |   2 +-
 tools/testing/selftests/landlock/base_test.c  |   2 +-
 tools/testing/selftests/landlock/fs_test.c    | 921 +++++++++++++++++-
 .../selftests/landlock/trace_fs_test.c        |   3 +-
 75 files changed, 2472 insertions(+), 906 deletions(-)

-- 
2.18.0.huawei.25

