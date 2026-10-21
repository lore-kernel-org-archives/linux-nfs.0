Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552642;
	b=dK80fWA7IsaNsTU2ji3zEoE3FvMJsfxEdNC2PjNYo8fNday/T8rpL5EfS9qvxzZRX/IU
	 O17tMeL9U0OO7f6CR5NNvw+RTnDtVZst+/SxpeTwRAKBOEMt42ShhCXOF/VAVPTCjYn0L
	 kXmLAHUCgQKskvZUO9xDYjG6LyDPlkqMmyMds2Zpjj8zOc5NLvgmZSul7pNtpqrDJUl1r
	 KfnJvo9kKOkTmKavOMCAybt+8KELIUWrmvIwzLySxD17eIRbKaJJlR4nefVe0c3QKypOF
	 yl3rqgjP7hLvSOeup5Q6lbBWBLEqwEFoPVUGS0iRlESfudvWUBXbtRTtUxwOFHfnV5g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552642;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=tdj0VV7sirueGx4sdVLtYMWM+BMK+LmplvK9FFGAILo=;
	b=VjzwFqwfGTfb5B27wmLGnj4Cy6jlnrl3xqVMrLsKcCJNG423lP6cNrcx53GAtVs+JdWF
	 HOGvh5a8XgZvdQmGHIKQIR5QtKYbhmU5KBzCVSM5edSqkjIkaMT0OSOH9JiwGT5TPWlPd
	 sGSqAV3nfxTbBnGWPiyjXppy24SPQMajajYH4u/55ZHocOIKExMVuT4SLfZc15Qq/CL+5
	 jkJBCIZL/rWukwTO2/dMnAGFSToitp7/rMpHDmKkYycVYcqPgXPpb1VIP/np65gS1Q+d8
	 n6mqadmmtIyo65VkGJhy4gfEN/VaC1qv8DM6xnWU87N7LNGU3P8DC92gWRLUe2Vb6ug==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=ZRz84cAN;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1526460A3E63;
	Wed, 21 Oct 2026 03:17:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1526460A3E63
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=ZRz84cAN
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552640; bh=Vws6vCdcEF3qUKpK8cPCFQjsf4YRBxpo4ZNVRrSM11s=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=ZRz84cANoQeEua855iQ9k3LYxDZP/yGFssDaUiW7U/6rUhzxS9w5N4W32JZiZfNVq
	 Ba4DfguYLYboJNUmVcd0l+n7UBTitI3fMhx/QiiLP9RKYcHtntRsJd/m8DOl6T2qin
	 ofaiGqRLOHWuBAbKv+vl3x4Wx+4/5klCI7ZwLYo21xT6xXY4MhcE6fIo1ur0/NJRmt
	 cIl5/2XWEg6TYNNPWFdHBWIlQkiD2tz3sUnlxD6WXy5nV1ToibP9S3CfnPcxbuiF+n
	 nX+HjySuSoKGkRTdVC2eVwzeFghyD4eUoWZkzo5TW88TZCe508x3MN6tYmKGHl+4tA
	 Guv8oDGJ+v0hw==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id BF59E8A0927;
	Wed, 21 Oct 2026 05:17:19 +0200 (CEST)
Message-ID: <d93b11e2c7d4e82e0076dddf812cc5137bc34771.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 35/41] Documentation: describe UUID and GUID user and
 group ids
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
Date: Wed, 21 Oct 2026 05:15:55 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

Describe __kernel_uid_r_t, the rules for UUID and GUID ids (overflow
ids in classic interfaces, the initial user namespace only, filesystems
with SB_I_UID_R), the *_r system calls, the extended interfaces (statx,
socket credentials, siginfo, SysV IPC, keyctl, POSIX ACLs, procfs,
audit) and the current limitations.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 Documentation/userspace-api/index.rst |   1 +
 Documentation/userspace-api/uid_r.rst | 169 ++++++++++++++++++++++++++
 2 files changed, 170 insertions(+)
 create mode 100644 Documentation/userspace-api/uid_r.rst

diff --git a/Documentation/userspace-api/index.rst b/Documentation/userspace-api/index.rst
index a68b1bea57..fcac7703fa 100644
--- a/Documentation/userspace-api/index.rst
+++ b/Documentation/userspace-api/index.rst
@@ -22,6 +22,7 @@ System calls
    ioctl/index
    mseal
    rseq
+   uid_r
 
 Security-related interfaces
 ===========================
diff --git a/Documentation/userspace-api/uid_r.rst b/Documentation/userspace-api/uid_r.rst
new file mode 100644
index 0000000000..c080485455
--- /dev/null
+++ b/Documentation/userspace-api/uid_r.rst
@@ -0,0 +1,169 @@
+.. SPDX-License-Identifier: GPL-2.0
+
+===========================================
+UUID and GUID user and group ids (``*_r``)
+===========================================
+
+Besides the classic 32 bit numbers, user and group ids can be UUIDs
+(RFC 9562, version 4) or Microsoft GUIDs. A process can run as such a
+user, files can be owned by one, and ACLs, keys, IPC objects, sockets and
+signals carry them. The classic system calls keep their 32 bit ids; a new
+family of calls, named after them with an ``_r`` suffix, and extensions of
+existing interfaces handle all kinds of id.
+
+The id type
+===========
+
+``<linux/uidgid_r.h>`` defines ``__kernel_uid_r_t`` (and
+``__kernel_gid_r_t``, the same type)::
+
+	typedef struct __kernel_uid_r {
+		__u32 type;
+		union {
+			__u32 legacy;
+			__u8 uuid[16];
+			__u8 guid[16];
+		};
+	} __kernel_uid_r_t;
+
+``type`` is one of:
+
+``UID_R_NONE`` (0)
+	No id. An all-zero id is never root. The ``set*id_r()`` and
+	``chown_r()`` calls take it, like a ``NULL`` pointer or a classic
+	``-1``, as "leave unchanged".
+
+``UID_R_LEGACY`` (1)
+	A classic id in ``legacy``.
+
+``UID_R_UUID`` (2)
+	A UUID in ``uuid``, in network byte order. It must be version 4 with
+	the RFC 9562 variant.
+
+``UID_R_GUID`` (3)
+	A GUID in ``guid`` as Windows stores it: Data1, Data2 and Data3
+	little endian. The nil GUID is not allowed.
+
+Bytes past the member ``type`` selects must be zero. The struct is 20
+bytes on every ABI, so none of the calls needs a compat variant.
+
+The text form of an id (in procfs, audit records, key descriptions and
+``/proc/<pid>/loginuid``) is a decimal number, a UUID
+``xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`` or a GUID in braces
+``{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}``.
+
+Rules
+=====
+
+- Interfaces with 32 bit ids show a UUID or GUID as the overflow id
+  (``/proc/sys/kernel/overflowuid`` and ``overflowgid``), as the 16 bit
+  system calls do for ids above 65535.
+
+- UUIDs and GUIDs are not part of any ``uid_map`` or ``gid_map``: they
+  exist in the initial user namespace only. Elsewhere they show as the
+  overflow id, can't be set, and no capability in another namespace gives
+  privilege over them. Only ``CAP_SETUID``/``CAP_SETGID`` in the initial
+  namespace can switch to one.
+
+- Idmapped mounts map classic ids and pass UUIDs and GUIDs unchanged, on
+  filesystems of the initial user namespace.
+
+- Only filesystems that can store them accept UUID and GUID owners and ACL
+  entries; others refuse with ``EOVERFLOW``, for ``chown`` as well as for
+  creating a file as such a user. tmpfs and ramfs do, and ext4 with the
+  ``uid_r`` feature (``mke2fs -O uid_r``; a read-only compatible feature,
+  inodes of at least 256 bytes). ``tune2fs -O uid_r`` turns it on later; on
+  a mounted filesystem through ``EXT4_IOC_SET_TUNE_SB_PARAM``, which makes
+  it usable at once, otherwise at the next mount or remount.
+
+System calls
+============
+
+All take pointers to ``__kernel_uid_r_t`` and return 0 or a negative
+error, unless noted otherwise.
+
+=================  =======================================================
+``getuid_r``       ``(uid_r *uid)``, also ``geteuid_r``, ``getgid_r``,
+                   ``getegid_r``
+``setuid_r``       ``(const uid_r *uid)``, also ``setgid_r``
+``setreuid_r``     ``(const uid_r *ruid, const uid_r *euid)``, also
+                   ``setregid_r``
+``setresuid_r``    ``(const uid_r *ruid, const uid_r *euid, const uid_r
+                   *suid)``, also ``setresgid_r``
+``getresuid_r``    ``(uid_r *ruid, uid_r *euid, uid_r *suid)``, also
+                   ``getresgid_r``; ``NULL`` pointers are skipped
+``setfsuid_r``     ``(const uid_r *uid, uid_r *old)``, also
+                   ``setfsgid_r``. Unlike ``setfsuid()`` it fails with
+                   ``EPERM`` instead of silently, and returns the old id
+                   in ``*old``; a ``NULL`` *uid* only queries it.
+``getgroups_r``    ``(int size, gid_r *list)``, returns the number of
+                   groups like ``getgroups()``
+``setgroups_r``    ``(int size, const gid_r *list)``; "no id" is not
+                   allowed in the list
+``chown_r``        ``(const char *path, const uid_r *user, const gid_r
+                   *group)``, also ``lchown_r``, ``fchown_r(int fd, ...)``
+                   and ``fchownat_r(int dfd, const char *path, ..., int
+                   flags)``
+=================  =======================================================
+
+Supplementary groups are sorted by kind (classic, UUID, GUID) and value.
+
+Other interfaces
+================
+
+``statx()``
+	``STATX_UID_R`` and ``STATX_GID_R`` report ``stx_uid_r`` and
+	``stx_gid_r``.
+
+Sockets
+	``SO_PEERCRED_R`` returns a ``struct __kernel_ucred_r`` (pid, uid,
+	gid), ``SO_PEERGROUPS_R`` the peer's groups as ``__kernel_gid_r_t``.
+	``SO_PASSCRED_R`` asks for ``SCM_CREDENTIALS_R`` messages with a
+	``struct __kernel_ucred_r``; they can be sent with the rules of
+	``SCM_CREDENTIALS``. Netlink keeps classic ids in its messages.
+
+Signals
+	``siginfo_t`` has ``si_uid_r``, the sender's uid, at offset 96 in
+	every layout; ``signalfd_siginfo`` has ``ssi_uid_r``. It is
+	``UID_R_NONE`` where the kernel doesn't set it; ``waitid()`` fills it
+	in.
+
+System V IPC
+	``IPC_STAT_R`` and ``IPC_SET_R`` for ``msgctl()``, ``semctl()`` and
+	``shmctl()`` read and set a ``struct ipc_perm_r`` (key, mode, uid,
+	gid, cuid, cgid).
+
+Keys
+	``KEYCTL_CHOWN_R`` takes ``__kernel_uid_r_t`` owner and group.
+
+POSIX ACLs
+	Version 3 of the ACL xattr format (``POSIX_ACL_XATTR_VERSION_R``)
+	has ``struct posix_acl_xattr_entry_r`` entries with an id kind and
+	16 bytes of id. ``getxattr()`` returns version 3 only if an entry is
+	a UUID or GUID; ``setxattr()`` takes both versions.
+
+procfs
+	``/proc/<pid>/status`` has ``Uid_r:``, ``Gid_r:`` and ``Groups_r:``
+	lines with the text form of the ids; ``/proc/<pid>/loginuid`` reads
+	and writes UUIDs and GUIDs as text.
+
+Audit
+	Records show UUIDs and GUIDs in their text form; classic ids are
+	printed as before.
+
+RPCSEC_GSS upcalls
+	The text (v1) upcall to gssd names a UUID or GUID user as
+	``uid_r=<text form>`` instead of ``uid=<number>``; gssd versions that
+	don't know it find no ``uid=`` and refuse the upcall. A downcall for
+	such a user starts with the uid ``-1`` (never valid) followed by the
+	user as ``__kernel_uid_r_t``, then the usual fields. The binary (v0)
+	upcall can't carry such users and fails with ``EACCES``.
+
+Limitations
+===========
+
+- Quotas don't account UUID and GUID owners; quota files hold 32 bit ids.
+- RPCSEC_GSS needs a gssd that knows ``uid_r=`` for UUID and GUID users.
+- UUID and GUID users can't create unprivileged ublk devices.
+- Audit filter rules, SafeSetID policies and IMA policy rules name
+  classic ids only.
-- 
2.56.0

