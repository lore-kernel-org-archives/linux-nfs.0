Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552809;
	b=rxFL68u9RO8YgRBu2+ALiH8cROo8j0fM31sF6MxXDJ44s9BCVhYwIWv1cGoBP19iqQsU
	 liBFB/m1OHYsbjCN4kSuS6tEM4dajikKGZ3W1Dskf3FD1L7nrqxGkPINkbGbjQgZTAk2C
	 4Re7gqUs3tD3DrXbmdfq0j3jGotm/psGzEwNl3PdY7Dc6hOYipA0dF1h63hlmiU+QvvK4
	 A6N6P8sK2HpI7P5iOPXaQyzTxuFZtD81HKiGj7bS6Z98ne3ilJVnwbed/iowNf3QAVwWf
	 LTQ9Ct3U9GgrYR0CBkRE3n32uvWkx9LQeWgImGTxnQ37EALHCxe3pzU6GEV0snedLWQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552809;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:Date:MIME-Version:
	 User-Agent:Subject:From:To:Cc:References:Content-Language:In-Reply-To:
	 Content-Type:Content-Transfer-Encoding;
	bh=IzjzlttjghcxXcVw7Ekvyw7MxBypTlNB49w2eoANCGg=;
	b=xXd1lAVMPhmu0CcgaOt/s7ZTdPw3OjofEwt7JIg1QseKZNszb5TK9OpnwnCgmKyF3QJD
	 Oqtj2QCyCkK7I+ERpWCVC9u6T90+hMpYgCeEs74LqFZ1Sg5AXIgJesBbQGi8KSSTkcMbG
	 08U2KODQc5K9jsC+CvV1odKy2bgwulxNtU/wcXWQyQQTTlb2bifcXx4zQQA6HR9dW4b6j
	 Ky/OZTVjs/hsa/QaLTcv9XNpGLG7Y0uaKWvmsNLnN4EhqRuXyKRvwu3ivgZclvb8O/U8N
	 eWBbKwiOsmzIfyuT7V+s25BqlQXn2Nrv8FTLHByG9GDyI7TAGJ4kX1XV0kX1eEBdKXA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=cmd7YYEe;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4D3BE606A321;
	Wed, 21 Oct 2026 03:20:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4D3BE606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=cmd7YYEe
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552806; bh=3y9Q8AsVoTBFF5EDnjPSG0OScUCmGU6sYl7Gp5g6W7Y=;
	h=Date:Subject:From:To:Cc:References:In-Reply-To:From;
	b=cmd7YYEe7p9+ZHLFZylKS4V/+3nFT8uujqBj7UVchQtWC55g71W19pgG0k+LBBJ56
	 jxpu6kjNmf4Prb38Qkrb1Db0TrfFDPOmRSdArcbZIioOlU8ujRonw2NevW7mbYdtw0
	 4bL3aP4lEkDEwLO5C+GBmHZxFstP3JxY960Jns5E2nri03hTSPXbTl0wvY9cH1RgMM
	 uMSvCCB/h9rMUS71MfH93Ed+a+eYuSQCHxYYZUfXXf3ApZzo4Xd+XeHSwgX3WfDKQf
	 yMSpycA1r7M8j1zqtLgvUfFsKnx9f16VN15yuwUVmn4znv1cxzTJqVEIVdbIu2o3dW
	 Y5AHWl1oVU7yw==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 531FB8A0651;
	Wed, 21 Oct 2026 05:20:05 +0200 (CEST)
Message-ID: <8934b1f2-90dd-42c5-b43b-5d1eeffac84f@tuxist.de>
Date: Wed, 21 Oct 2026 05:20:04 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [RFC PATCH v2 00/41] UUID and GUID user and group ids (*_r system
 calls)
From: jan Koester <jan.koester@tuxist.de>
To: Christian Brauner <brauner@kernel.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>, "Serge E. Hallyn"
 <serge@hallyn.com>
Cc: Jan Kara <jack@suse.cz>, "Theodore Y. Ts'o" <tytso@mit.edu>,
 Paul Moore <paul@paul-moore.com>, Arnd Bergmann <arnd@arndb.de>,
 linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
 linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
 linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org,
 linux-cifs@vger.kernel.org, netdev@vger.kernel.org, audit@vger.kernel.org,
 keyrings@vger.kernel.org, linux-kernel@vger.kernel.org
References: <cover.1792552161.git.jan.koester@tuxist.de>
Content-Language: en-US
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Hi,

i have already submitted but not all patches arrives now i use a other  mailbox sorry.

best regards

Jan Koester

Am 21.10.26 um 05:15 schrieb Jan Koester:
> Hi,
>
> this RFC series lets a user or group id be a UUID (RFC 9562, version 4)
> or a Microsoft GUID as well as a classic 32-bit number. Processes can run
> as such a user, files can be owned by one, and credentials, ACLs, keys,
> System V IPC, sockets, signals, audit and procfs carry the whole id.
>
> Why
> ---
> Directory services name users by 128-bit ids: Active Directory by
> objectGUID (and SIDs), LDAP directories often by entryUUID. Today every
> system that serves such users (winbind, sssd, nfsidmap, ksmbd user
> space) maps them to 32-bit numbers through ranges, hashes or a local
> database. The numbers differ between machines unless the mapping is
> configured the same everywhere, mappings can collide, and ownership
> written to shared storage or a backup depends on the machine that wrote
> it. With the 128-bit id in the kernel, the id the directory hands out is
> also the owner on disk and in every credential, and no mapping table is
> needed.
>
> Design
> ------
> - kuid_t and kgid_t become a tagged union (legacy number, UUID, GUID)
>   instead of a u32. There is no table that maps UUIDs to numbers: the
>   kernel compares, hashes and stores the whole id. uid_eq(), uid_lt()
>   and the other helpers keep their meaning. Patches 1-3 add the UAPI
>   type and helpers. Patches 4-8 fix places that relied on kuid_t being
>   a u32: sk_uid is now read through a seqcount, and af_unix, netlink and
>   Bluetooth keep only classic ids in skb->cb. Patch 9 changes the type.
>
> - UUIDs and GUIDs exist only in the initial user namespace. They are not
>   part of any uid_map or gid_map, show as the overflow id in other
>   namespaces, and no capability in a child namespace gives privilege
>   over them. Idmapped mounts pass them through unchanged.
>
> - The classic system calls keep their 32-bit ids and show a UUID or GUID
>   as the overflow id, as the 16-bit calls do for ids above 65535. A new
>   family, named after the old calls with an _r suffix (getuid_r,
>   setresuid_r, setgroups_r, fchownat_r, ...), takes a 20-byte
>   __kernel_uid_r_t:
>
> 	typedef struct __kernel_uid_r {
> 		__u32 type;	/* UID_R_NONE, _LEGACY, _UUID, _GUID */
> 		union {
> 			__u32 legacy;
> 			__u8 uuid[16];
> 			__u8 guid[16];
> 		};
> 	} __kernel_uid_r_t;
>
>   It has the same layout on every ABI, so none of the calls needs a
>   compat entry.
>
> - Existing interfaces get _R variants where an id is in the ABI:
>   STATX_UID_R/STATX_GID_R, SO_PEERCRED_R, SO_PEERGROUPS_R,
>   SCM_CREDENTIALS_R, si_uid_r in siginfo (offset 96 in every layout),
>   IPC_STAT_R/IPC_SET_R, KEYCTL_CHOWN_R, and version 3 of the POSIX ACL
>   xattr. procfs, audit records, key descriptions and the RPCSEC_GSS
>   upcall use a text form (decimal, UUID, or GUID in braces).
>
> - A filesystem has to declare that it can store such owners
>   (SB_I_UID_R). Everywhere else, chown and creating a file as such a
>   user fail with EOVERFLOW, so a UUID never turns into a wrong number
>   on disk. tmpfs, ramfs and devpts declare it, overlayfs does when its
>   upper layer does, and ext4 does with a new read-only compatible
>   feature, uid_r (patches 31, 32 and 34; 256-byte inodes). NFSv4 and
>   ksmbd carry the ids as text or as SIDs (S-1-22-3/4/5/6-...).
>
> - Things that can't carry a 128-bit id fail closed instead of mapping:
>   quotas don't account such owners, AUTH_SYS sends the overflow id,
>   unprivileged ublk devices are refused, and gssd versions that don't
>   know uid_r= refuse the upcall.
>
> Documentation/userspace-api/uid_r.rst (patches 35 and 41) describes the
> whole ABI and its limitations.
>
> Testing
> -------
> - tools/testing/selftests/uid_r (patch 36): 14/14 pass.
> - A boot test suite (nolibc init on QEMU, ext4 images with and without
>   uid_r): 88/88 pass, on a kernel with USER_NS, overlayfs, tmpfs, POSIX
>   ACLs and audit enabled.
> - End to end on a full distribution (FenrirOS: patched libc, e2fsprogs,
>   OpenSSH, rsync, libarchive, a ksmbd and NFS server): UUID users log in
>   over ssh, own files on ext4, and reach ksmbd and NFSv4 shares.
> - The selftests and the boot test suite ran on the same series on top
>   of v7.2.9 and v7.2.11. On v7.3-rc7, the series is built for x86_64
>   (bzImage and modules, with USER_NS, audit, ecryptfs, fscrypt, quota,
>   ublk, NFS, Bluetooth and the LSMs enabled) and boots in QEMU, where an
>   integration test with a full user space passes 24/24: ssh sessions
>   with a pty as UUID users, UUID owners on tmpfs and overlayfs, SMB
>   logins of UUID users through ksmbd with S-1-22-3-... owner SIDs, and
>   NFSv4 showing and setting UUID owners. ext4 uid_r was not part of it.
> - The syscall tables of the other architectures are wired up (patch 22)
>   but haven't been built.
>
> The e2fsprogs changes (mke2fs/tune2fs -O uid_r, e2fsck, debugfs, ACL
> conversion in libext2fs) will be sent to linux-ext4 separately.
>
> Open questions
> --------------
> - Is a tagged union in kuid_t acceptable, or would you rather see the
>   128-bit id kept beside a u32 kuid_t?
> - The new calls copy the classic get/set*id() and chown() families
>   one by one (20 entries). A single setid_r(which, ...) call would need
>   fewer syscall numbers. Which do you prefer?
> - Should the series be split per subsystem (core/uidgid, fs and VFS,
>   net, ext4, nfsd/ksmbd) after this RFC?
>
> Changes in v2:
> - No code changes. v1 reached the lists only up to patch 11, the mail
>   provider throttled the rest; this is the complete series, now sent
>   from jan.koester@tuxist.de (author and Signed-off-by changed to it).
> - Hunk offsets refreshed against v7.3-rc7, testing section updated.
> - v1: https://lore.kernel.org/r/cover.1792346472.git.jan.koester@gmx.net
>
> The series is based on v7.3-rc7. The syscall numbers (473-492 on most
> architectures) are placeholders and will follow whatever is merged first.
>
> Jan Koester (41):
>   uuid: move uuid_t and guid_t into <linux/uuid_types.h>
>   uapi: add <linux/uidgid_r.h> for 128 bit capable user and group ids
>   uidgid: add uid_is_legacy() and gid_is_legacy()
>   net: sock: read sk_uid through a seqcount
>   af_unix: keep sender ids in skb->cb only when they are classic ids
>   netlink: keep classic sender ids in skb->cb
>   Bluetooth: keep classic sender ids in skb->cb
>   smb: client: use __kuid_val() for the unix SIDs of the caller
>   uidgid: let kuid_t and kgid_t hold a UUID or a GUID
>   uidgid: convert between kernel ids and the ids of the *_r system calls
>   fscrypt: show the whole uid in the description of user key claims
>   keys: name per-user keyrings of UUID and GUID users by the whole uid
>   ublk: refuse unprivileged devices to UUID and GUID users
>   nfsd: don't hand out uid 0 for read layouts of UUID-owned files
>   SUNRPC: name UUID and GUID users to gssd as uid_r=
>   ecryptfs: hash daemons by kuid_hash()
>   quota: don't account UUID and GUID owners
>   fs: keep UUID and GUID owners off filesystems that can't store them
>   cred: add the *_r variants of the get/set*id() system calls
>   groups: add getgroups_r() and setgroups_r()
>   fs: add chown_r(), lchown_r(), fchown_r() and fchownat_r()
>   arch: wire up the *_r uid and gid system calls
>   statx: report UUID and GUID owners
>   shmem, ramfs: allow UUID and GUID owners
>   uidgid: parse and print ids in their text form
>   proc: show UUID and GUID ids in status, accept them for loginuid
>   audit: log UUID and GUID ids in full
>   net: add SO_PEERCRED_R, SO_PEERGROUPS_R and SCM_CREDENTIALS_R
>   signal: report the sender's UUID or GUID uid in si_uid_r
>   ipc: add IPC_STAT_R and IPC_SET_R
>   ext4: add the uid_r feature for UUID and GUID owners
>   ext4: let uid_r be turned on while the filesystem is mounted
>   posix_acl: support UUID and GUID entries
>   ext4: store ACLs with UUID and GUID entries on uid_r filesystems
>   Documentation: describe UUID and GUID user and group ids
>   selftests: add tests for UUID and GUID ids
>   ovl: allow UUID and GUID owners when the upper layer does
>   devpts: allow UUID and GUID owners
>   ksmbd: log in UUID and GUID users and map them to SIDs
>   nfsd, nfs: carry UUID and GUID owners as their text form
>   Documentation: uid_r: describe SMB and NFSv4
>
>  Documentation/userspace-api/index.rst       |   1 +
>  Documentation/userspace-api/uid_r.rst       | 186 +++++++
>  arch/alpha/include/uapi/asm/socket.h        |   5 +
>  arch/alpha/kernel/syscalls/syscall.tbl      |  20 +
>  arch/arm/tools/syscall.tbl                  |  20 +
>  arch/arm64/tools/syscall_32.tbl             |  20 +
>  arch/m68k/kernel/syscalls/syscall.tbl       |  20 +
>  arch/microblaze/kernel/syscalls/syscall.tbl |  20 +
>  arch/mips/include/uapi/asm/socket.h         |   5 +
>  arch/mips/kernel/syscalls/syscall_n32.tbl   |  20 +
>  arch/mips/kernel/syscalls/syscall_n64.tbl   |  20 +
>  arch/mips/kernel/syscalls/syscall_o32.tbl   |  20 +
>  arch/parisc/include/uapi/asm/socket.h       |   5 +
>  arch/parisc/kernel/syscalls/syscall.tbl     |  20 +
>  arch/powerpc/kernel/syscalls/syscall.tbl    |  20 +
>  arch/s390/kernel/syscalls/syscall.tbl       |  20 +
>  arch/sh/kernel/syscalls/syscall.tbl         |  20 +
>  arch/sparc/include/uapi/asm/socket.h        |   5 +
>  arch/sparc/kernel/syscalls/syscall.tbl      |  20 +
>  arch/x86/entry/syscalls/syscall_32.tbl      |  20 +
>  arch/x86/entry/syscalls/syscall_64.tbl      |  20 +
>  arch/xtensa/kernel/syscalls/syscall.tbl     |  20 +
>  drivers/block/ublk_drv.c                    |  17 +-
>  drivers/tty/tty_audit.c                     |   7 +-
>  fs/attr.c                                   |   7 +
>  fs/crypto/keyring.c                         |   7 +-
>  fs/devpts/inode.c                           |   2 +
>  fs/ecryptfs/messaging.c                     |   2 +-
>  fs/ext4/acl.c                               | 109 +++-
>  fs/ext4/acl.h                               |  34 +-
>  fs/ext4/ext4.h                              |  27 +-
>  fs/ext4/inode.c                             | 115 ++++-
>  fs/ext4/ioctl.c                             |  30 +-
>  fs/ext4/super.c                             |  45 +-
>  fs/mnt_idmapping.c                          |  14 +
>  fs/nfs/nfs4idmap.c                          |  53 ++
>  fs/nfs/super.c                              |   2 +
>  fs/nfsd/flexfilelayout.c                    |   6 +-
>  fs/nfsd/nfs4idmap.c                         |  68 ++-
>  fs/open.c                                   | 144 +++++-
>  fs/overlayfs/super.c                        |   3 +
>  fs/posix_acl.c                              | 123 ++++-
>  fs/proc/array.c                             |  17 +-
>  fs/proc/base.c                              |  38 +-
>  fs/quota/dquot.c                            |   3 +
>  fs/ramfs/inode.c                            |   1 +
>  fs/signalfd.c                               |   3 +
>  fs/smb/client/cifsacl.c                     |   2 +-
>  fs/smb/client/smb2pdu.c                     |   7 +-
>  fs/smb/server/ksmbd_netlink.h               |  15 +-
>  fs/smb/server/mgmt/user_config.c            |  35 +-
>  fs/smb/server/mgmt/user_config.h            |   4 +-
>  fs/smb/server/smb2pdu.c                     |  10 +-
>  fs/smb/server/smb_common.c                  |  18 +-
>  fs/smb/server/smbacl.c                      | 178 +++++--
>  fs/smb/server/smbacl.h                      |  19 +-
>  fs/smb/server/transport_ipc.c               |   4 +-
>  fs/smb/server/vfs_cache.c                   |   9 +-
>  fs/smb/server/vfs_cache.h                   |   4 +-
>  fs/stat.c                                   |  24 +-
>  include/linux/audit.h                       |   8 +-
>  include/linux/compat.h                      |   6 +
>  include/linux/fs.h                          |  29 +-
>  include/linux/fs/super_types.h              |   1 +
>  include/linux/mnt_idmapping.h               |  74 ++-
>  include/linux/netlink.h                     |   2 +-
>  include/linux/posix_acl_xattr.h             |  31 ++
>  include/linux/ptrace.h                      |   2 +-
>  include/linux/quota.h                       |  18 +
>  include/linux/signal.h                      |  22 +
>  include/linux/signal_types.h                |   5 +-
>  include/linux/socket.h                      |   1 +
>  include/linux/syscalls.h                    |  44 ++
>  include/linux/uidgid.h                      | 165 +++++-
>  include/linux/uidgid_types.h                |  32 +-
>  include/linux/uuid.h                        |  11 +-
>  include/linux/uuid_types.h                  |  21 +
>  include/net/bluetooth/bluetooth.h           |   2 +-
>  include/net/scm.h                           |  28 +
>  include/net/sock.h                          |  32 +-
>  include/uapi/asm-generic/siginfo.h          |  17 +
>  include/uapi/asm-generic/socket.h           |   5 +
>  include/uapi/asm-generic/unistd.h           |  43 +-
>  include/uapi/linux/ipc.h                    |  17 +
>  include/uapi/linux/keyctl.h                 |   1 +
>  include/uapi/linux/posix_acl_xattr.h        |  19 +
>  include/uapi/linux/signalfd.h               |   4 +-
>  include/uapi/linux/socket.h                 |   9 +
>  include/uapi/linux/stat.h                   |  10 +-
>  include/uapi/linux/uidgid_r.h               |  45 ++
>  io_uring/waitid.c                           |  32 +-
>  io_uring/waitid.h                           |   1 +
>  ipc/mqueue.c                                |   4 +-
>  ipc/msg.c                                   |  40 +-
>  ipc/sem.c                                   |  31 +-
>  ipc/shm.c                                   |  32 +-
>  ipc/util.c                                  | 112 +++-
>  ipc/util.h                                  |  23 +-
>  kernel/Makefile                             |   1 +
>  kernel/audit.c                              |  50 +-
>  kernel/audit.h                              |   4 +-
>  kernel/auditsc.c                            |  63 ++-
>  kernel/exit.c                               |  18 +-
>  kernel/exit.h                               |   3 +
>  kernel/groups.c                             |  94 +++-
>  kernel/signal.c                             |  48 +-
>  kernel/sys.c                                | 472 ++++++++++++-----
>  kernel/sys_ni.c                             |  12 +
>  kernel/ucount.c                             |   2 +-
>  kernel/uidgid_r.c                           | 467 +++++++++++++++++
>  kernel/user.c                               |   2 +-
>  kernel/user_namespace.c                     |  10 +-
>  lib/kobject_uevent.c                        |   8 +-
>  mm/oom_kill.c                               |   2 +-
>  mm/shmem.c                                  |   2 +
>  net/bluetooth/hci_sock.c                    |   8 +-
>  net/core/dev.c                              |   8 +-
>  net/core/scm.c                              |  94 ++--
>  net/core/sock.c                             |  90 +++-
>  net/netlabel/netlabel_user.c                |   4 +-
>  net/netlink/af_netlink.c                    |   4 +-
>  net/socket.c                                |   5 +-
>  net/sunrpc/auth_gss/auth_gss.c              |  44 +-
>  net/unix/af_unix.c                          |  53 +-
>  net/unix/af_unix.h                          |  11 +-
>  scripts/syscall.tbl                         |  20 +
>  security/apparmor/file.c                    |   8 +-
>  security/integrity/ima/ima_policy.c         |   8 +-
>  security/integrity/integrity_audit.c        |   6 +-
>  security/ipe/audit.c                        |  12 +-
>  security/keys/compat.c                      |   3 +
>  security/keys/internal.h                    |   3 +
>  security/keys/keyctl.c                      |  61 ++-
>  security/keys/persistent.c                  |  11 +-
>  security/keys/process_keys.c                |  36 +-
>  security/keys/request_key.c                 |  12 +-
>  security/selinux/selinuxfs.c                |   8 +-
>  security/selinux/ss/services.c              |   4 +-
>  tools/testing/selftests/Makefile            |   1 +
>  tools/testing/selftests/uid_r/.gitignore    |   1 +
>  tools/testing/selftests/uid_r/Makefile      |   6 +
>  tools/testing/selftests/uid_r/config        |   4 +
>  tools/testing/selftests/uid_r/uid_r_test.c  | 535 ++++++++++++++++++++
>  143 files changed, 4425 insertions(+), 605 deletions(-)
>  create mode 100644 Documentation/userspace-api/uid_r.rst
>  create mode 100644 include/linux/uuid_types.h
>  create mode 100644 include/uapi/linux/uidgid_r.h
>  create mode 100644 kernel/uidgid_r.c
>  create mode 100644 tools/testing/selftests/uid_r/.gitignore
>  create mode 100644 tools/testing/selftests/uid_r/Makefile
>  create mode 100644 tools/testing/selftests/uid_r/config
>  create mode 100644 tools/testing/selftests/uid_r/uid_r_test.c
>
>
> base-commit: 24a19b953e2a3d0ea5a8c4951a0ab8f32720c907

