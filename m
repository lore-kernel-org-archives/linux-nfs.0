Received: from mout.gmx.net (mout.gmx.net [212.227.15.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F97341D4F7;
	Sun, 18 Oct 2026 18:01:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.15.19
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792346512; cv=none; b=Ay0M9meqAwOK8Z2se5dI6vguEsq5CtnPaq5qtR2HhjzOJS3D3I9DoVLnRE83wNXzizQEGjlH3kXvXO969IZtJUedkhAazMDvcKfIZNdT5vTNhJ7vfVK/OorUZzcUfs0y4d8YFbb5agSNxYsRGnhnc9JxDemvX5p0JkHd1nELG/k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792346512; c=relaxed/simple;
	bh=ageNDPYWIhd9KhjS3gHwLkNjskkbbgQqugg3dLvMc0Y=;
	h=Message-ID:From:Subject:To:Cc:Date; b=CjEehGF0w9p2YCVfmROOaF3lvonQq7MV8UN5Rbw5m8aWOPe5oDhOteVTZrRsQObi6/yjNJoopNq9a/M17ord7pAG83VjzUv6icGJnBmEB2P3aQvYseQn02/CZ9tJVGi3+XNNzl5Fj/S4eV2KsRbgAAJvBvY6RRguEbpVffFnt2o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net; spf=pass smtp.mailfrom=gmx.net; dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b=YAH6EX3x; arc=none smtp.client-ip=212.227.15.19
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmx.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b="YAH6EX3x"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmx.net;
	s=s31663417; t=1792346485; x=1792951285; i=jan.koester@gmx.net;
	bh=FGXwAV5FlqNNKmOFoL4+VdXtdCQZWjh95Jssa5zckpc=;
	h=X-UI-Sender-Class:Message-ID:From:Subject:To:Cc:Date:
	 Content-Transfer-Encoding:cc:content-transfer-encoding:
	 content-type:date:from:message-id:mime-version:reply-to:subject:
	 to;
	b=YAH6EX3xjJ5xfWMKJHOE+v08FE6AHao+TlSECZ1517D/BWplNf/k8IWM0/iCoOGR
	 qU6NdkvM/Pv3ecp77V2O4vFzXCJiGkD39nyFQRdjHKe6LpDSwKDDN/iJRxuYzl36N
	 jk6e8kGZNq6FrQ8st78jDyl5WGrTMDcp9oeW0PriDEX/PbtgtyGOUHhGPniISQ5H5
	 mj9a93e83sUHPALuEm/sLI5u1cbAO/nc8zNFbD4b3Kr5lAy7RrhkRrcMHKkOEurPe
	 qs6JzyO6fNdQcEgvcPzm/z/FofxFND4doTvcY3yboeBwq522eHedC4/LtWYRv3epb
	 XsMPdVJw0Nkwpy0E2w==
X-UI-Sender-Class: 724b4f7f-cbec-4199-ad4e-598c01a50d3a
Received: from client.hidden.invalid by mail.gmx.net (mrgmx004
 [212.227.17.190]) with ESMTPSA (Nemesis) id 1MS3mz-1xCGyc181L-00KrJY; Sun, 18
 Oct 2026 20:01:25 +0200
Message-ID: <cover.1792346472.git.jan.koester@gmx.net>
From: Jan Koester <jan.koester@gmx.net>
Subject: [RFC PATCH 00/41] UUID and GUID user and group ids (*_r system calls)
To: Christian Brauner <brauner@kernel.org>,
    Alexander Viro <viro@zeniv.linux.org.uk>,
    "Serge E. Hallyn" <serge@hallyn.com>
Cc: Jan Kara <jack@suse.cz>,
    "Theodore Y. Ts'o" <tytso@mit.edu>,
    Paul Moore <paul@paul-moore.com>,
    Arnd Bergmann <arnd@arndb.de>,
    linux-fsdevel@vger.kernel.org,
    linux-api@vger.kernel.org,
    linux-security-module@vger.kernel.org,
    linux-arch@vger.kernel.org,
    linux-ext4@vger.kernel.org,
    linux-nfs@vger.kernel.org,
    linux-cifs@vger.kernel.org,
    netdev@vger.kernel.org,
    audit@vger.kernel.org,
    keyrings@vger.kernel.org,
    linux-kernel@vger.kernel.org
Date: Sun, 18 Oct 2026 20:01:21 +0200
X-Provags-ID: V03:K1:/UaS9IwzjNpWjpyCJP+i+Z7A13I3YF5jusQobGcragCPwJcoKV3
 DnU2StS3Pg2+PW3Y5sCFfX+S6LcF2hRLeAjLNV/rRAd31TxTZW3patAZhkScOU8eFc1pgfZ
 kLVVSDu23qERjdrz//wDaNMj2Wlb375PbAnMulAAT/PaqbXDPCi29H8Zrs+TzutyMlEyk0o
 mOcGufTmCHOERJX3Swj5Q==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:ublCxbxYzgI=;dqn0Jb3hFbViD0fX3DdJZTMN+YJ
 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
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

Hi,

this RFC series lets a user or group id be a UUID (RFC 9562, version 4)
or a Microsoft GUID as well as a classic 32-bit number. Processes can run
as such a user, files can be owned by one, and credentials, ACLs, keys,
System V IPC, sockets, signals, audit and procfs carry the whole id.

Why
=2D--
Directory services name users by 128-bit ids: Active Directory by
objectGUID (and SIDs), LDAP directories often by entryUUID. Today every
system that serves such users (winbind, sssd, nfsidmap, ksmbd user
space) maps them to 32-bit numbers through ranges, hashes or a local
database. The numbers differ between machines unless the mapping is
configured the same everywhere, mappings can collide, and ownership
written to shared storage or a backup depends on the machine that wrote
it. With the 128-bit id in the kernel, the id the directory hands out is
also the owner on disk and in every credential, and no mapping table is
needed.

Design
=2D-----
- kuid_t and kgid_t become a tagged union (legacy number, UUID, GUID)
  instead of a u32. There is no table that maps UUIDs to numbers: the
  kernel compares, hashes and stores the whole id. uid_eq(), uid_lt()
  and the other helpers keep their meaning. Patches 1-3 add the UAPI
  type and helpers. Patches 4-8 fix places that relied on kuid_t being
  a u32: sk_uid is now read through a seqcount, and af_unix, netlink and
  Bluetooth keep only classic ids in skb->cb. Patch 9 changes the type.

- UUIDs and GUIDs exist only in the initial user namespace. They are not
  part of any uid_map or gid_map, show as the overflow id in other
  namespaces, and no capability in a child namespace gives privilege
  over them. Idmapped mounts pass them through unchanged.

- The classic system calls keep their 32-bit ids and show a UUID or GUID
  as the overflow id, as the 16-bit calls do for ids above 65535. A new
  family, named after the old calls with an _r suffix (getuid_r,
  setresuid_r, setgroups_r, fchownat_r, ...), takes a 20-byte
  __kernel_uid_r_t:

	typedef struct __kernel_uid_r {
		__u32 type;	/* UID_R_NONE, _LEGACY, _UUID, _GUID */
		union {
			__u32 legacy;
			__u8 uuid[16];
			__u8 guid[16];
		};
	} __kernel_uid_r_t;

  It has the same layout on every ABI, so none of the calls needs a
  compat entry.

- Existing interfaces get _R variants where an id is in the ABI:
  STATX_UID_R/STATX_GID_R, SO_PEERCRED_R, SO_PEERGROUPS_R,
  SCM_CREDENTIALS_R, si_uid_r in siginfo (offset 96 in every layout),
  IPC_STAT_R/IPC_SET_R, KEYCTL_CHOWN_R, and version 3 of the POSIX ACL
  xattr. procfs, audit records, key descriptions and the RPCSEC_GSS
  upcall use a text form (decimal, UUID, or GUID in braces).

- A filesystem has to declare that it can store such owners
  (SB_I_UID_R). Everywhere else, chown and creating a file as such a
  user fail with EOVERFLOW, so a UUID never turns into a wrong number
  on disk. tmpfs, ramfs and devpts declare it, overlayfs does when its
  upper layer does, and ext4 does with a new read-only compatible
  feature, uid_r (patches 31, 32 and 34; 256-byte inodes). NFSv4 and
  ksmbd carry the ids as text or as SIDs (S-1-22-3/4/5/6-...).

- Things that can't carry a 128-bit id fail closed instead of mapping:
  quotas don't account such owners, AUTH_SYS sends the overflow id,
  unprivileged ublk devices are refused, and gssd versions that don't
  know uid_r=3D refuse the upcall.

Documentation/userspace-api/uid_r.rst (patches 35 and 41) describes the
whole ABI and its limitations.

Testing
=2D------
- tools/testing/selftests/uid_r (patch 36): 14/14 pass.
- A boot test suite (nolibc init on QEMU, ext4 images with and without
  uid_r): 88/88 pass, on a kernel with USER_NS, overlayfs, tmpfs, POSIX
  ACLs and audit enabled.
- End to end on a full distribution (FenrirOS: patched libc, e2fsprogs,
  OpenSSH, rsync, libarchive, a ksmbd and NFS server): UUID users log in
  over ssh, own files on ext4, and reach ksmbd and NFSv4 shares.
- The runtime tests above ran on the same series on top of v7.2.9 and
  v7.2.11. On v7.3-rc7, the series has so far been built for x86_64
  (bzImage and modules, with USER_NS, audit, ecryptfs, fscrypt, quota,
  ublk, NFS, Bluetooth and the LSMs enabled), not yet booted.
- The syscall tables of the other architectures are wired up (patch 22)
  but haven't been built.

The e2fsprogs changes (mke2fs/tune2fs -O uid_r, e2fsck, debugfs, ACL
conversion in libext2fs) will be sent to linux-ext4 separately.

Open questions
=2D-------------
- Is a tagged union in kuid_t acceptable, or would you rather see the
  128-bit id kept beside a u32 kuid_t?
- The new calls copy the classic get/set*id() and chown() families
  one by one (20 entries). A single setid_r(which, ...) call would need
  fewer syscall numbers. Which do you prefer?
- Should the series be split per subsystem (core/uidgid, fs and VFS,
  net, ext4, nfsd/ksmbd) after this RFC?

The series is based on v7.3-rc7. The syscall numbers (473-492 on most
architectures) are placeholders and will follow whatever is merged first.

Jan Koester (41):
  uuid: move uuid_t and guid_t into <linux/uuid_types.h>
  uapi: add <linux/uidgid_r.h> for 128 bit capable user and group ids
  uidgid: add uid_is_legacy() and gid_is_legacy()
  net: sock: read sk_uid through a seqcount
  af_unix: keep sender ids in skb->cb only when they are classic ids
  netlink: keep classic sender ids in skb->cb
  Bluetooth: keep classic sender ids in skb->cb
  smb: client: use __kuid_val() for the unix SIDs of the caller
  uidgid: let kuid_t and kgid_t hold a UUID or a GUID
  uidgid: convert between kernel ids and the ids of the *_r system calls
  fscrypt: show the whole uid in the description of user key claims
  keys: name per-user keyrings of UUID and GUID users by the whole uid
  ublk: refuse unprivileged devices to UUID and GUID users
  nfsd: don't hand out uid 0 for read layouts of UUID-owned files
  SUNRPC: name UUID and GUID users to gssd as uid_r=3D
  ecryptfs: hash daemons by kuid_hash()
  quota: don't account UUID and GUID owners
  fs: keep UUID and GUID owners off filesystems that can't store them
  cred: add the *_r variants of the get/set*id() system calls
  groups: add getgroups_r() and setgroups_r()
  fs: add chown_r(), lchown_r(), fchown_r() and fchownat_r()
  arch: wire up the *_r uid and gid system calls
  statx: report UUID and GUID owners
  shmem, ramfs: allow UUID and GUID owners
  uidgid: parse and print ids in their text form
  proc: show UUID and GUID ids in status, accept them for loginuid
  audit: log UUID and GUID ids in full
  net: add SO_PEERCRED_R, SO_PEERGROUPS_R and SCM_CREDENTIALS_R
  signal: report the sender's UUID or GUID uid in si_uid_r
  ipc: add IPC_STAT_R and IPC_SET_R
  ext4: add the uid_r feature for UUID and GUID owners
  ext4: let uid_r be turned on while the filesystem is mounted
  posix_acl: support UUID and GUID entries
  ext4: store ACLs with UUID and GUID entries on uid_r filesystems
  Documentation: describe UUID and GUID user and group ids
  selftests: add tests for UUID and GUID ids
  ovl: allow UUID and GUID owners when the upper layer does
  devpts: allow UUID and GUID owners
  ksmbd: log in UUID and GUID users and map them to SIDs
  nfsd, nfs: carry UUID and GUID owners as their text form
  Documentation: uid_r: describe SMB and NFSv4

 Documentation/userspace-api/index.rst       |   1 +
 Documentation/userspace-api/uid_r.rst       | 186 +++++++
 arch/alpha/include/uapi/asm/socket.h        |   5 +
 arch/alpha/kernel/syscalls/syscall.tbl      |  20 +
 arch/arm/tools/syscall.tbl                  |  20 +
 arch/arm64/tools/syscall_32.tbl             |  20 +
 arch/m68k/kernel/syscalls/syscall.tbl       |  20 +
 arch/microblaze/kernel/syscalls/syscall.tbl |  20 +
 arch/mips/include/uapi/asm/socket.h         |   5 +
 arch/mips/kernel/syscalls/syscall_n32.tbl   |  20 +
 arch/mips/kernel/syscalls/syscall_n64.tbl   |  20 +
 arch/mips/kernel/syscalls/syscall_o32.tbl   |  20 +
 arch/parisc/include/uapi/asm/socket.h       |   5 +
 arch/parisc/kernel/syscalls/syscall.tbl     |  20 +
 arch/powerpc/kernel/syscalls/syscall.tbl    |  20 +
 arch/s390/kernel/syscalls/syscall.tbl       |  20 +
 arch/sh/kernel/syscalls/syscall.tbl         |  20 +
 arch/sparc/include/uapi/asm/socket.h        |   5 +
 arch/sparc/kernel/syscalls/syscall.tbl      |  20 +
 arch/x86/entry/syscalls/syscall_32.tbl      |  20 +
 arch/x86/entry/syscalls/syscall_64.tbl      |  20 +
 arch/xtensa/kernel/syscalls/syscall.tbl     |  20 +
 drivers/block/ublk_drv.c                    |  17 +-
 drivers/tty/tty_audit.c                     |   7 +-
 fs/attr.c                                   |   7 +
 fs/crypto/keyring.c                         |   7 +-
 fs/devpts/inode.c                           |   2 +
 fs/ecryptfs/messaging.c                     |   2 +-
 fs/ext4/acl.c                               | 109 +++-
 fs/ext4/acl.h                               |  34 +-
 fs/ext4/ext4.h                              |  27 +-
 fs/ext4/inode.c                             | 115 ++++-
 fs/ext4/ioctl.c                             |  30 +-
 fs/ext4/super.c                             |  45 +-
 fs/mnt_idmapping.c                          |  14 +
 fs/nfs/nfs4idmap.c                          |  53 ++
 fs/nfs/super.c                              |   2 +
 fs/nfsd/flexfilelayout.c                    |   6 +-
 fs/nfsd/nfs4idmap.c                         |  68 ++-
 fs/open.c                                   | 144 +++++-
 fs/overlayfs/super.c                        |   3 +
 fs/posix_acl.c                              | 123 ++++-
 fs/proc/array.c                             |  17 +-
 fs/proc/base.c                              |  38 +-
 fs/quota/dquot.c                            |   3 +
 fs/ramfs/inode.c                            |   1 +
 fs/signalfd.c                               |   3 +
 fs/smb/client/cifsacl.c                     |   2 +-
 fs/smb/client/smb2pdu.c                     |   7 +-
 fs/smb/server/ksmbd_netlink.h               |  15 +-
 fs/smb/server/mgmt/user_config.c            |  35 +-
 fs/smb/server/mgmt/user_config.h            |   4 +-
 fs/smb/server/smb2pdu.c                     |  10 +-
 fs/smb/server/smb_common.c                  |  18 +-
 fs/smb/server/smbacl.c                      | 178 +++++--
 fs/smb/server/smbacl.h                      |  19 +-
 fs/smb/server/transport_ipc.c               |   4 +-
 fs/smb/server/vfs_cache.c                   |   9 +-
 fs/smb/server/vfs_cache.h                   |   4 +-
 fs/stat.c                                   |  24 +-
 include/linux/audit.h                       |   8 +-
 include/linux/compat.h                      |   6 +
 include/linux/fs.h                          |  29 +-
 include/linux/fs/super_types.h              |   1 +
 include/linux/mnt_idmapping.h               |  74 ++-
 include/linux/netlink.h                     |   2 +-
 include/linux/posix_acl_xattr.h             |  31 ++
 include/linux/ptrace.h                      |   2 +-
 include/linux/quota.h                       |  18 +
 include/linux/signal.h                      |  22 +
 include/linux/signal_types.h                |   5 +-
 include/linux/socket.h                      |   1 +
 include/linux/syscalls.h                    |  44 ++
 include/linux/uidgid.h                      | 165 +++++-
 include/linux/uidgid_types.h                |  32 +-
 include/linux/uuid.h                        |  11 +-
 include/linux/uuid_types.h                  |  21 +
 include/net/bluetooth/bluetooth.h           |   2 +-
 include/net/scm.h                           |  28 +
 include/net/sock.h                          |  32 +-
 include/uapi/asm-generic/siginfo.h          |  17 +
 include/uapi/asm-generic/socket.h           |   5 +
 include/uapi/asm-generic/unistd.h           |  43 +-
 include/uapi/linux/ipc.h                    |  17 +
 include/uapi/linux/keyctl.h                 |   1 +
 include/uapi/linux/posix_acl_xattr.h        |  19 +
 include/uapi/linux/signalfd.h               |   4 +-
 include/uapi/linux/socket.h                 |   9 +
 include/uapi/linux/stat.h                   |  10 +-
 include/uapi/linux/uidgid_r.h               |  45 ++
 io_uring/waitid.c                           |  32 +-
 io_uring/waitid.h                           |   1 +
 ipc/mqueue.c                                |   4 +-
 ipc/msg.c                                   |  40 +-
 ipc/sem.c                                   |  31 +-
 ipc/shm.c                                   |  32 +-
 ipc/util.c                                  | 112 +++-
 ipc/util.h                                  |  23 +-
 kernel/Makefile                             |   1 +
 kernel/audit.c                              |  50 +-
 kernel/audit.h                              |   4 +-
 kernel/auditsc.c                            |  63 ++-
 kernel/exit.c                               |  18 +-
 kernel/exit.h                               |   3 +
 kernel/groups.c                             |  94 +++-
 kernel/signal.c                             |  48 +-
 kernel/sys.c                                | 472 ++++++++++++-----
 kernel/sys_ni.c                             |  12 +
 kernel/ucount.c                             |   2 +-
 kernel/uidgid_r.c                           | 467 +++++++++++++++++
 kernel/user.c                               |   2 +-
 kernel/user_namespace.c                     |  10 +-
 lib/kobject_uevent.c                        |   8 +-
 mm/oom_kill.c                               |   2 +-
 mm/shmem.c                                  |   2 +
 net/bluetooth/hci_sock.c                    |   8 +-
 net/core/dev.c                              |   8 +-
 net/core/scm.c                              |  94 ++--
 net/core/sock.c                             |  90 +++-
 net/netlabel/netlabel_user.c                |   4 +-
 net/netlink/af_netlink.c                    |   4 +-
 net/socket.c                                |   5 +-
 net/sunrpc/auth_gss/auth_gss.c              |  44 +-
 net/unix/af_unix.c                          |  53 +-
 net/unix/af_unix.h                          |  11 +-
 scripts/syscall.tbl                         |  20 +
 security/apparmor/file.c                    |   8 +-
 security/integrity/ima/ima_policy.c         |   8 +-
 security/integrity/integrity_audit.c        |   6 +-
 security/ipe/audit.c                        |  12 +-
 security/keys/compat.c                      |   3 +
 security/keys/internal.h                    |   3 +
 security/keys/keyctl.c                      |  61 ++-
 security/keys/persistent.c                  |  11 +-
 security/keys/process_keys.c                |  36 +-
 security/keys/request_key.c                 |  12 +-
 security/selinux/selinuxfs.c                |   8 +-
 security/selinux/ss/services.c              |   4 +-
 tools/testing/selftests/Makefile            |   1 +
 tools/testing/selftests/uid_r/.gitignore    |   1 +
 tools/testing/selftests/uid_r/Makefile      |   6 +
 tools/testing/selftests/uid_r/config        |   4 +
 tools/testing/selftests/uid_r/uid_r_test.c  | 535 ++++++++++++++++++++
 143 files changed, 4425 insertions(+), 605 deletions(-)
 create mode 100644 Documentation/userspace-api/uid_r.rst
 create mode 100644 include/linux/uuid_types.h
 create mode 100644 include/uapi/linux/uidgid_r.h
 create mode 100644 kernel/uidgid_r.c
 create mode 100644 tools/testing/selftests/uid_r/.gitignore
 create mode 100644 tools/testing/selftests/uid_r/Makefile
 create mode 100644 tools/testing/selftests/uid_r/config
 create mode 100644 tools/testing/selftests/uid_r/uid_r_test.c


base-commit: 32c52ec87d6245ee2d12ed5dd509e40062939b50
=2D-=20
2.56.0

